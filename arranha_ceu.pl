% =========================================================================
% Disciplina: Paradigmas de Programacao
% Trabalho II - Programacao Logica Prolog
% Puzzle: Wolkenkratzer (Arranha-Ceu)
% =========================================================================

% predicados podem aparecer espalhados; não contínuos
:- discontiguous puzzle/8.
% pode declarar relações matemáticas com variáveis que não conhecemos o valor ainda
:- use_module(library(clpfd)).

% -------------------------------------------------------------------------
% Exemplo de Tabuleiro (Fato de Entrada Único)
% -------------------------------------------------------------------------

% Pegamos o primeiro exemplo de 6x6
% N = 6, Max = 6 (alturas de 1 a 6, sem valores 0)
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

%funçao resolver, que vai receber o puzzle (algo como exemplo_6x6)
% :- é igual a if
resolver(NomePuzzle) :-
    % busca o puzzle com o nome que foi passado como parâmetro
    puzzle(NomePuzzle, N, Max, Topo, Base, Esquerda, Direita, Tabuleiro),

    % garante que o tabuleiro tenha comprimento N (ou seja, N linhas horizontais)
    % maplist vai percorrendo as linhas do tabuleiro e aplicando essa regra 
    % transpose calcula a matriz transposta e coloca em Colunas
    length(Tabuleiro, N),
    maplist(mesmaLargura(N), Tabuleiro),
    transpose(Tabuleiro, Colunas),
    
    % aplica a regra de configurar_linha pra cada linha do tabuleiro
    % decide quais números podem ter e que não pode haver repetição
    maplist(configurar_linha(N, Max), Tabuleiro),
    maplist(configurar_linha(N, Max), Colunas),
    
    % impõe que cada linha tenha a quantidade de prédios visíveis indicada na esquerda
    aplicar_dicas(Tabuleiro, Esquerda),
    % inverte ordem dos prédios e guarda em linhas invertidas
    maplist(reverse, Tabuleiro, LinhasInvertidas),
    % pareia cada linha invertida com a quantidade na direita
    aplicar_dicas(LinhasInvertidas, Direita),
    
    % pareia cada coluna com as dicas do topo
    aplicar_dicas(Colunas, Topo),
    % inverte as colunas
    maplist(reverse, Colunas, ColunasInvertidas),
    % agora usa as dicas da base com as colunas invertidas
    aplicar_dicas(ColunasInvertidas, Base),

    % achata a lista de listas (tabuleiro) em uma lista só
    append(Tabuleiro, Variaveis),
    
    % esse ff é first fail -> o prolog preenche primeiro as casas com menos opções possíveis
    labeling([ff], Variaveis),
    
    % imprime o resultado
    nl, writeln('=== Solucao Encontrada ==='), nl,
    imprimir_tabuleiro(Topo, Base, Esquerda, Direita, Tabuleiro).

% verifica se cada linha tem comprimento N
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
:- initialization(resolver(exemplo_6x6)).
