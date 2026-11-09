f% =========================================================================
% Disciplina: Paradigmas de Programacao
% Trabalho II - Programacao Logica Prolog
% Puzzle: Wolkenkratzer (Arranha-Ceu)
% =========================================================================

:- use_module(library(clpfd)).

% -------------------------------------------------------------------------
% Exemplos de Tabuleiros (Fatos de Entrada)
% -------------------------------------------------------------------------

% Exemplo 1: Da imagem fornecida (Tabuleiro 6x6, alturas de 1 a 5 + parques)
% Representamos os parques (celulas vazias) pelo numero 0.
puzzle(exemplo_imagem, 6, 5,
    [3, 3, 1, 2, 1, 3], % Topo
    [2, 1, 4, 3, 5, 3], % Base
    [4, 3, 3, 3, 1, 2], % Esquerda
    [2, 2, 2, 1, 2, 2], % Direita
    [ [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _] ]
).

% Exemplo 2: Tabuleiro 6x6 classico (alturas de 1 a 6, sem parques)
% Dica 0 significa que nao ha restricao de visibilidade naquela borda.
puzzle(exemplo_6x6_classico, 6, 6,
    [4, 2, 1, 2, 3, 2], % Topo
    [1, 4, 3, 2, 2, 2], % Base
    [3, 2, 3, 1, 2, 3], % Esquerda
    [2, 2, 1, 3, 4, 2], % Direita
    [ [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _],
      [_, _, _, _, _, _] ]
).

% -------------------------------------------------------------------------
% Regra Principal do Resolvedor
% -------------------------------------------------------------------------

resolver(NomePuzzle) :-
    puzzle(NomePuzzle, N, Max, Topo, Base, Esquerda, Direita, Tabuleiro),
    
    % 1. Define a estrutura do tabuleiro NxN e extrai as colunas
    length(Tabuleiro, N),
    maplist( mesmaLargura(N), Tabuleiro ),
    transpose(Tabuleiro, Colunas),
    
    % 2. Aplica restricoes de dominio e unicidade nas linhas e colunas
    maplist(configurar_linha(N, Max), Tabuleiro),
    maplist(configurar_linha(N, Max), Colunas),
    
    % 3. Aplica restricoes de visibilidade nas 4 direcoes (bordas)
    aplicar_dicas(Tabuleiro, Esquerda),
    maplist(reverse, Tabuleiro, LinhasInvertidas),
    aplicar_dicas(LinhasInvertidas, Direita),
    
    aplicar_dicas(Colunas, Topo),
    maplist(reverse, Colunas, ColunasInvertidas),
    aplicar_dicas(ColunasInvertidas, Base),
    
    % 4. Busca a solucao (Labeling com heuristica First-Fail para otimizacao)
    append(Tabuleiro, Variaveis),
    labeling([ff], Variaveis),
    
    % 5. Imprime o resultado formatado
    nl, writeln('=== Solucao Encontrada ==='), nl,
    imprimir_tabuleiro(Topo, Base, Esquerda, Direita, Tabuleiro).

% Auxiliar para garantir que cada linha tenha N colunas
mesmaLargura(N, Linha) :- length(Linha, N).

% -------------------------------------------------------------------------
% Regras de Restricao (Dominio, Unicidade e Parques)
% -------------------------------------------------------------------------

% Caso 1: Tabuleiro classico sem parques (Max == N)
configurar_linha(N, N, Linha) :-
    !,
    Linha ins 1..N,
    all_distinct(Linha).

% Caso 2: Tabuleiro com parques/celulas vazias representadas por 0 (Max < N)
configurar_linha(N, Max, Linha) :-
    Max < N,
    Linha ins 0..Max,
    % Cada altura de 1 ate Max deve aparecer exatamente 1 vez na linha/coluna
    numlist(1, Max, Alturas),
    maplist(ocorrencia_unica(Linha), Alturas).

igual_a(A, X, B) :- B #<==> (X #= A).

ocorrencia_unica(Linha, Altura) :-
    maplist(igual_a(Altura), Linha, Bs),
    sum(Bs, #=, 1).

% -------------------------------------------------------------------------
% Regras de Visibilidade dos Predios
% -------------------------------------------------------------------------

aplicar_dicas([], []).
aplicar_dicas([Linha|RestoLinhas], [Dica|RestoDicas]) :-
    visiveis(Linha, Dica),
    aplicar_dicas(RestoLinhas, RestoDicas).

% Se a dica for 0, nao ha restricao de visibilidade naquela posicao
visiveis(_, 0) :- !.
visiveis(Linha, Dica) :-
    contar_visiveis(Linha, 0, 0, TotalVisiveis),
    TotalVisiveis #= Dica.

% Percorre a linha mantendo a altura maxima vista ate o momento (MaxAtual).
% Um predio H e visivel se e somente se H > MaxAtual.
contar_visiveis([], _, Acumulador, Acumulador).
contar_visiveis([H|T], MaxAtual, Acumulador, Total) :-
    Visivel #<==> (H #> MaxAtual),
    NovoMax #= max(MaxAtual, H),
    NovoAcumulador #= Acumulador + Visivel,
    contar_visiveis(T, NovoMax, NovoAcumulador, Total).

% -------------------------------------------------------------------------
% Regras de Impressao (Saida Formatada)
% -------------------------------------------------------------------------

imprimir_tabuleiro(Topo, Base, Esquerda, Direita, Tabuleiro) :-
    write('    '), maplist(imprimir_dica, Topo), nl,
    write('  +'), length(Topo, N), imprimir_tracos(N), writeln('+'),
    imprimir_linhas(Tabuleiro, Esquerda, Direita),
    write('  +'), imprimir_tracos(N), writeln('+'),
    write('    '), maplist(imprimir_dica, Base), nl.

imprimir_dica(D) :-
    (D =:= 0 -> write('  ') ; format('~w ', [D])).

imprimir_tracos(0) :- !.
imprimir_tracos(N) :-
    write('--'),
    N1 is N - 1,
    imprimir_tracos(N1).

imprimir_linhas([], [], []).
imprimir_linhas([Linha|RL], [E|RE], [D|RD]) :-
    (E =:= 0 -> write('  | ') ; format('~w | ', [E])),
    maplist(imprimir_celula, Linha),
    (D =:= 0 -> writeln('|') ; format('| ~w~n', [D])),
    imprimir_linhas(RL, RE, RD).

% Imprime espaco vazio '.' para parques (0) ou a altura do predio
imprimir_celula(C) :-
    (C =:= 0 -> write('. ') ; format('~w ', [C])).
