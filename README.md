Instruções:

Trabalho Individual

Entregar o arquivo .asm ou .s exclusivamente através do ambiente Moodle

O programa deve ser comentado, sendo que estes fazem parte da avaliação.

Descrição:

Implemente um programa que permita ao usuário jogar Campo Minado.

O programa deve ser implementado utilizando o conjunto de instruções do MIPS e deve ser executado no simulador SPIM ou no simulador MARS.

No início o programa permite ao usuário escolher o tamanho do campo: a) 5x5; b) 7x7; c) 9x9. A matriz (chamada campo) deve possuir internamente tamanho fixo de 9x9 e é composta de números inteiros a qual deve ser inicializada com zeros pelo programador.

O programa deve ser implementado com uma função principal (main) e pelo menos duas outras funções:

- a função calcula_bombas com o seguinte protótipo:

void calcula_bombas(int * campo[], int num_linhas);

- a função mostra_campo (cada aluno pode definir o protótipo da mesma).

Os parâmetros de calcula_bombas devem ser passado nos registradores $a0 e $a1, respectivamente.

Após inicializar as variáveis de controle o programa deve chamar uma função chamada insere_bombas, com o seguinte protótipo:

void insere_bombas(int * campo[], int num_linhas);

A função insere_bombas não precisa ser codificada pelo aluno pois será implementada pelo professsor quando da correção do programa. Os parâmetros de insere_bombas deve ser passado nos registradores $a0 e $a1, respectivamente. Esta função colocará as bombas na matriz campo.

Por convenção as bombas recebem o valor 9. Assim, na matriz campo as casas que possuirem o valor 9 possuem bomba naquela posição.

O programa deve apresentar uma interface para o usuário digitar o número da linha e da coluna que pretende abrir. Caso tenha uma bomba naquela posição o programa deve indicar que uma bomba explodiu e o usuário perdeu (mostrando na interface a quantidade de bombas no entorno das posições já jogadas e as posições das bombas); Caso não tenha uma bomba naquela posição o programa deve mostrar a situação do campo (mostrando a quantidade de bombas no entorno das posições já jogadas) e em seguida solicitar a nova jogada.

Na interface com o usuário os números de linha e coluna começam com 1.
