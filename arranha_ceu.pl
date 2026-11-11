% =========================================================================
% Disciplina: Paradigmas de Programacao
% Trabalho II - Programacao Logica Prolog
% Puzzle: Wolkenkratzer (Arranha-Ceu)
% =========================================================================

:- discontiguous puzzle/8.
:- use_module(library(clpfd)).

% -------------------------------------------------------------------------
% Exemplo de Tabuleiro (Fato de Entrada Único)
% -------------------------------------------------------------------------

% Tabuleiro 6x6 clássico extraído da imagem
% N = 6, Max = 6 (alturas de 1 a 6, sem parques)
puzzle(exemplo_6x6, 6, 6,
    [4, 1, 2, 2, 3, 2], % Topo
    [1, 3, 5, 2, 4, 2], % Base
    [2, 3, 3, 4, 2, 1], % Esquerda
    [2, 4, 2, 3, 1, 4], % Direita
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
    maplist(mesmaLargura(N), Tabuleiro),
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
    
    % 4. Busca a solucao (Labeling com heuristica First-Fail)
    append(Tabuleiro, Variaveis),
    labeling([ff], Variaveis),
    
    % 5. Imprime o resultado formatado
    nl, writeln('=== Solucao Encontrada ==='), nl,
    imprimir_tabuleiro(Topo, Base, Esquerda, Direita, Tabuleiro).

% Auxiliar para garantir que cada linha tenha N colunas
mesmaLargura(N, Linha) :- length(Linha, N).

% -------------------------------------------------------------------------
% Regras de Restricao (Dominio e Unicidade)
% -------------------------------------------------------------------------

% Caso clássico sem parques (Max == N)
configurar_linha(N, N, Linha) :-
    !,
    Linha ins 1..N,
    all_distinct(Linha).

% Caso com parques/celulas vazias representadas por 0 (Max < N)
configurar_linha(N, Max, Linha) :-
    Max < N,
    Linha ins 0..Max,
    numlist(1, Max, Alturas),
    maplist(ocorrencia_unica(Linha), Alturas).

ocorrencia_unica(Linha, Altura) :-
    maplist(igual_a(Altura), Linha, Bs),
    sum(Bs, #=, 1).

% Reificação: B recebe 1 se X for igual a A, senao 0
igual_a(A, X, B) :- B #<==> (X #= A).

% -------------------------------------------------------------------------
% Regras de Visibilidade dos Predios
% -------------------------------------------------------------------------

aplicar_dicas([], []).
aplicar_dicas([Linha|RestoLinhas], [Dica|RestoDicas]) :-
    visiveis(Linha, Dica),
    aplicar_dicas(RestoLinhas, RestoDicas).

% Dica 0 indica ausencia de restricao
visiveis(_, 0) :- !.
visiveis(Linha, Dica) :-
    contar_visiveis(Linha, 0, 0, TotalVisiveis),
    TotalVisiveis #= Dica.

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

imprimir_celula(C) :-
    (C =:= 0 -> write('. ') ; format('~w ', [C])).
