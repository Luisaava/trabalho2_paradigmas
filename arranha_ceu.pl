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
% a altura maxima é igual ao tamanho do tabuleiro, então cada linha/coluna
% tem todos os números de 1 a N, sem repetir (igual ao Sudoku)
configurar_linha(N, N, Linha) :-
    !,                          % corte: se entrou aqui, nao tenta a proxima clausula
    Linha ins 1..N,             % cada casa so pode ter valor entre 1 e N
    all_distinct(Linha).        % nenhum valor pode se repetir na linha

% Caso com parques/celulas vazias representadas por 0 (Max < N)
configurar_linha(N, Max, Linha) :-
    Max < N,                    % so entra aqui se nao caiu no caso anterior
    Linha ins 0..Max,           % agora cada casa pode ser 0 (parque) ou 1..Max
    numlist(1, Max, Alturas),   % cria a lista [1, 2, ..., Max]
    maplist(ocorrencia_unica(Linha), Alturas).  % cada altura aparece exatamente uma vez

% garante que a altura "Altura" aparece exatamente uma vez na linha
ocorrencia_unica(Linha, Altura) :-
    maplist(igual_a(Altura), Linha, Bs),  % Bs = lista de 0/1: 1 onde a casa == Altura
    sum(Bs, #=, 1).                        % soma dos 0/1 tem que dar 1, so uma casa

% Reificacao: B recebe 1 se X for igual a A, senao 0
% B #<==> (...) liga a variavel booleana B a condicao, sem decidir o valor ainda
igual_a(A, X, B) :- B #<==> (X #= A).

% -------------------------------------------------------------------------
% Regras de Visibilidade dos Predios
% -------------------------------------------------------------------------

% percorre a lista de linhas e a lista de dicas juntas, uma dica por vez
aplicar_dicas([], []).                      % sem linhas e sem dicas -> acabou
aplicar_dicas([Linha|RestoLinhas], [Dica|RestoDicas]) :-
    visiveis(Linha, Dica),                  % aplica a dica nessa linha
    aplicar_dicas(RestoLinhas, RestoDicas). % continua com o resto

% Dica 0 indica ausencia de restricao
visiveis(_, 0) :- !.                        % dica 0 = nao tem regra, nada a checar
visiveis(Linha, Dica) :-
    contar_visiveis(Linha, 0, 0, TotalVisiveis),  % conta quantos predios aparecem
    TotalVisiveis #= Dica.                          % tem que bater com a dica

% conta os predios visiveis da esquerda pra direita
% um predio é visivel se for mais alto que todos os anteriores
% MaxAtual = maior altura vista ate agora
% Acumulador = quantos predios visiveis ja contamos
contar_visiveis([], _, Acumulador, Acumulador).  % fim da lista -> o total é o acumulador
contar_visiveis([H|T], MaxAtual, Acumulador, Total) :-
    Visivel #<==> (H #> MaxAtual),           % Visivel = 1 se H for mais alto que o maximo anterior
    NovoMax #= max(MaxAtual, H),             % atualiza o maximo para o proximo passo
    NovoAcumulador #= Acumulador + Visivel,  % soma 1 se o predio apareceu
    contar_visiveis(T, NovoMax, NovoAcumulador, Total).

% -------------------------------------------------------------------------
% Regras de Impressao (Saida Formatada)
% -------------------------------------------------------------------------

% desenha o tabuleiro: dicas do topo, bordas, linhas com dicas laterais e dicas da base
imprimir_tabuleiro(Topo, Base, Esquerda, Direita, Tabuleiro) :-
    write('    '), maplist(imprimir_dica, Topo), nl,       % linha de cima com dicas do topo
    write('  +'), length(Topo, N), imprimir_tracos(N), writeln('+'),  % borda superior
    imprimir_linhas(Tabuleiro, Esquerda, Direita),         % corpo do tabuleiro
    write('  +'), imprimir_tracos(N), writeln('+'),        % borda inferior
    write('    '), maplist(imprimir_dica, Base), nl.       % linha de baixo com dicas da base

% imprime a dica; se for 0 imprime espacos em branco no lugar
imprimir_dica(D) :-
    (D =:= 0 -> write('  ') ; format('~w ', [D])).

% imprime N vezes "--" pra fazer a borda
imprimir_tracos(0) :- !.
imprimir_tracos(N) :-
    write('--'),
    N1 is N - 1,
    imprimir_tracos(N1).

% imprime linha por linha: dica da esquerda, celulas e dica da direita
imprimir_linhas([], [], []).
imprimir_linhas([Linha|RL], [E|RE], [D|RD]) :-
    (E =:= 0 -> write('  | ') ; format('~w | ', [E])),  % dica da esquerda (ou espaco)
    maplist(imprimir_celula, Linha),                     % as celulas da linha
    (D =:= 0 -> writeln('|') ; format('| ~w~n', [D])),   % dica da direita (ou so a borda)
    imprimir_linhas(RL, RE, RD).

% celula 0 vira "." (parque); qualquer outro valor é impresso como numero
imprimir_celula(C) :-
    (C =:= 0 -> write('. ') ; format('~w ', [C])).
