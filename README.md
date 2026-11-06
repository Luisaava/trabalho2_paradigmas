# Trabalho II - Arranha-Céu (Wolkenkratzer) em Prolog

Este projeto contém um resolvedor para o puzzle **Arranha-Céu (Wolkenkratzer)** escrito em Prolog utilizando a biblioteca de Programação por Restrições (`clpfd`). 

O código suporta a versão clássica do jogo e a versão com parques (células vazias).

## Pré-requisitos

Para executar este código, precisará do **SWI-Prolog** instalado.
* É possível baixá-lo em: [https://www.swi-prolog.org/Download.html](https://www.swi-prolog.org/Download.html)

## Como Executar

1. Salve o código fonte do programa em um arquivo chamado `arranha_ceu.pl` no mesmo diretório deste README.
2. Abra o terminal (ou prompt de comando) e navegue até a pasta onde o arquivo foi salvo.
3. Inicie o interpretador do SWI-Prolog digitando:
   ```bash
   swipl
   ```
4. Dentro do interpretador Prolog, carregue o arquivo usando o comando:
   ```prolog
   ?- ['arranha_ceu.pl'].
   ```
   *(Não se esqueça do ponto final no comando).*

## Rodando os Testes

O código já possui dois tabuleiros pré-configurados prontos para teste. Para resolvê-los, basta chamar a regra `resolver/1` passando o nome do puzzle.

**Teste 1: Tabuleiro 6x6 da imagem com parques (alturas de 1 a 5)**
No interpretador, digite:
```prolog
?- resolver(exemplo_imagem).
```

**Teste 2: Tabuleiro 6x6 clássico (alturas de 1 a 6)**
No interpretador, digite:
```prolog
?- resolver(exemplo_6x6_classico).
```

## Como Sair

Para sair do interpretador do SWI-Prolog, digite:
```prolog
?- halt.
```
