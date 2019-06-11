	.data
matriz_mapa: 	.space 324 	# matriz_mapa armazena os valores da célula
matriz_user: 	.space 324 	# matriz_mapa armazena a renderização
				# 324 = 9*9 Maior matriz porssível
prompt_opcoes: 		.asciiz "Escolha um dos tamanhos:\n5) 5x5\n7) 7x7\n9) 9x9\nTamanho: "
prompt_coordenada_i: 	.asciiz "Informe a linha:\n"
prompt_coordenada_j: 	.asciiz "Informe a coluna:\n"
msg_tamanho_errado: 	.asciiz "\n\nO tamanho informado é inválido!\n\n"
print_nova_linha: 	.asciiz "\n"
print_espaco:	 	.asciiz " "
interrogacao:	 	.asciiz "?"

tamanho:	.word 0		# Armazena o tamanho do campo escolhido
jogo_andamento:	.byte 1		# Armazena a informação que controla execução
				# Quando jogo_andamento passa ser 0, significa que
				# que o usuário perdeu ou ganhou
vitoria_user:	.byte 0		# Quando usuário ja abriu todos campos sem que nenhum fosse uma bomba
derrota_user:	.byte 0		# Quando usuário abriu um campo com bomba

qtd_disponivel:	.byte 0		# Controla quantidade de campos disponíveis para abrir
qtd_explorado:	.byte 0		# Controla quantidade de campos já abertos


#FUNCAO INJETACA (INSERE_BOMBA)
campo:			.space		324
semente:		.asciiz		"\nEntre com a semente da funcao Rand: "
espaco:			.asciiz		" "
nova_linha:		.asciiz		"\n"
posicao:		.asciiz		"\nPosicao: "
salva_S0:		.word		0
salva_ra:		.word		0
salva_ra1:		.word		0
#FUNCAO INJETACA (INSERE_BOMBA)

	.text
main:

	# CORREÇÕES:
	# Passar inicialia_array como argumento
	
	
	# PRE JOGO
	##### CORRIGIR AQUI #####
	
	
	
	
	# inicializa array mapa com 0
	la   $a0, matriz_mapa # a0 -> matriz
	move $a1, $0          # a1 -> valor inicial
	jal  inicializa_array
	# inicializa array user com -1
	la   $a0, matriz_user # a0 -> matriz
	addi $a1, $0, -1      # a1 -> valor inicial
	jal  inicializa_array
	
	# obtem tamanho do mapa
	jal  obtem_tamanho
	# salvar o valor na label tamanho
	la   $t1, tamanho # endereco da referencia de tamanho
 	sw   $v0, 0($t1)  # salva o resultado
	
	# carrega bombas no array mapa
	la   $a0, matriz_mapa # a0 -> matriz
	lw   $a1, tamanho     # a1 -> qtd linhas
	jal  INSERE_BOMBA
	
	la   $a0, matriz_mapa
	lw   $a1, tamanho
	jal  renderiza_mapa
	
	# calcula valor das posições
	
	
	
	
	# INICIO
	# loop enquanto jogo esta em andamento
	# le IxJ informado pelo usuario
	# acessa valor no mapa
	# se o campo for 9
		# seta derrota e finalizar loop
	# incrementa controle de campos
	# replica o valor no mapa de renderização
	# jogo finaliza quando qtd explorado == qtd disponivel
	
	
	# POS JOGO
	# exibe mensagens conforme resultado
	j    fim
	
fim:
	addi $v0, $zero, 10 # exit 
	syscall
		
		
		
		

#########################
#    RENDERIZA MAPA     #
#########################
# Argumentos:
# $a0 -> Endereço do array
# $a1 -> Numero de linhas e colunas
# 
# Retorno:
# void
#
# Descrição:
# Intera array informado e exibe no console
# o grid do mapa.
# Para valores negativos, é exibido '?' ao 
# invés de exibir o número negativo
#########################
renderiza_mapa:
	add  $t0, $zero, $zero # i = linha
	move $t7, $a1 # salva o endereço para liberar registrador $a
	move $t6, $a0

loop_renderiza_mapa_i:
	slt  $t3, $t0, $t7 # i < tamanho
	beq  $t3, $zero, return_renderiza_mapa
	add  $t1, $zero, $zero # j = coluna
loop_renderiza_mapa_j:
	slt  $t3, $t1, $t7 # j < tamanho
	beq  $t3, $zero, fim_loop_renderiza_mapa_j
	
	# leitura da posicao
	mul  $t4, $t0, $t7 # posicao = (i * tamanho)
	add  $t4, $t4, $t1 # posicao = j + (i * tamanho)
	sll  $t4, $t4, 2   # posicao = 4 * (j + (i * tamanho))
	add  $t2, $t6, $t4 # array[posicao]
	lw   $s0, 0($t2)
	
	# print do valor
	sge  $t3, $s0, 0 # valores negativos imprime '?'
	beq  $t3, $zero, loop_renderiza_print_interrogacao
	addi $v0, $zero, 1 # print integer
	la   $a0, 0($s0)
	syscall
	j    loop_renderiza_print_espaco	
loop_renderiza_print_interrogacao:
	addi $v0, $zero, 4 # print string
	la   $a0, interrogacao
	syscall

loop_renderiza_print_espaco:
	# print espaço
	addi $v0, $zero, 4 # print string
	la   $a0, print_espaco
	syscall

	addi $t1, $t1, 1 # incremento coluna
	j    loop_renderiza_mapa_j
fim_loop_renderiza_mapa_j:
	addi $t0, $t0, 1 # incremento linha

	# print novalinha
	addi $v0, $zero, 4 # print string
	la   $a0, print_nova_linha
	syscall
	j    loop_renderiza_mapa_i

return_renderiza_mapa:
	jr   $ra





#########################
#   INICIALIZA ARRAY    #
#########################
# Argumentos:
# $a0 -> Endereço do array
# $a1 -> Valor para inicializar
# 
# Retorno:
# void
#
# Descrição:
# Intera array informado e seta
# em todos os campos o valor passado
# pelo parâmetro
#########################
inicializa_array:
	add  $t0, $zero, $zero 
	la   $t2, matriz_mapa
	la   $t3, matriz_user
	addi $t4, $zero, -1 # valor inicial para o mapa renderizado

loop_inicializa_array:
	slti $t5, $t0, 9 # count < 9
	beq  $t5, $zero, return_inicializa_array
	sw   $zero, 0($t2) # seta 0 na posição count para o array mapa
	sw   $t4,   0($t3) # seta -1 na posição count para o array user
	addi $t2, $t2, 4 # apontador do enderço array_mapa
	addi $t3, $t3, 4 # apontador do enderço array_user
	addi $t0, $t0, 1 # incremento do contador
	j    loop_inicializa_array
	
return_inicializa_array:
	jr   $ra
	
	
	
	
	
	
#########################
#     OBTER TAMANHO     #
#########################
# Argumentos:
# null
# 
# Retorno:
# $vo -> Tamanho informado pelo usuário
#
# Descrição:
# Exibe para o usuário as opções de tamanho.
# Caso o usuário insira um valor inválido,
# a função e reprocessada.
#########################
obtem_tamanho:
	# Mensagem para informar tamanho
	addi $v0, $0, 4 # print info
	la   $a0, prompt_opcoes 
	syscall
	addi $v0, $0, 5 # entrada de dados
	syscall
	# verifica se o valor é valido
	beq  $v0, 5, return_obtem_tamanho
	beq  $v0, 7, return_obtem_tamanho
	beq  $v0, 9, return_obtem_tamanho
	
	# Mensagem de tamanho errado
	addi $v0, $0, 4 # print info
	la   $a0, msg_tamanho_errado
	syscall
	j    obtem_tamanho
	
return_obtem_tamanho:
	jr   $ra







#FUNCAO INJETACA (INSERE_BOMBA)
INSERE_BOMBA:
		la	$t0, salva_S0
		sw  $s0, 0($t0)		# salva conteudo de s0 na memoria
		la	$t0, salva_ra
		sw  $ra, 0($t0)		# salva conteudo de ra na memoria
		
		add $t0, $zero, $a0	# salva a0 em t0
		add $t1, $zero, $a1	# salva a1 em t1
		
		li	$v0, 4			# 
		la	$a0, nova_linha
		syscall			

verifica_menor_que_5:
		slti $t3, $t1, 5
		beq	 $t3, $0, verifica_maior_que_9
		addi $t1, $0, 5			#se tamanho do campo menor que 5 atribui 5
		add  $a1, $0, $t1
verifica_maior_que_9:
		slti $t3, $t1, 9
		bne	 $t3, $0, testa_5
		addi $t1, $0, 9			
		add  $a1, $0, $t1
testa_5:
		addi $t3, $0, 5
		bne  $t1, $t3, testa_7
		addi $t2, $0, 10 # 10 bombas no campo 5x5
		j	 pega_semente
testa_7:
		addi $t3, $0, 7
		bne  $t1, $t3, testa_9
		addi $t2, $0, 20 # 20 bombas no campo 7x7
		j	 pega_semente
testa_9:
		addi $t3, $0, 9
		bne  $t1, $t3, else_qtd_bombas
		addi $t2, $0, 40 # 40 bombas no campo 9x9
		j	 pega_semente
else_qtd_bombas:
		addi $t2, $0, 25 # seta para 25 bomas no else		
pega_semente:
		jal SEED
		add $t3, $zero, $zero # inicia contador de bombas com 0
INICIO_LACO:
		beq $t2, $t3, FIM_LACO
		
		add $a0, $zero, $t1 # carrega limite para %
		jal PSEUDO_RAND
		add $t4, $zero, $v0	# pega linha sorteada e coloca em t4
   		jal PSEUDO_RAND
		add $t5, $zero, $v0	# pega coluna sorteada e coloca em t5
		mult $t4, $t1
		mflo $t4
		add  $t4, $t4, $t5  # calcula (L * tam) + C
		add  $t4, $t4, $t4  # multtiplica por 2
		add  $t4, $t4, $t4  # multtiplica por 4
		add	 $t4, $t4, $t0	# calcula Base + deslocamento
		lw	$t5, 0($t4)		# Le posicao de memoria LxC

		
		addi $t6, $zero, 9	
		beq  $t5, $t6, PULA_ATRIB
		sw   $t6, 0($t4)
		addi $t3, $t3, 1		
PULA_ATRIB:
		j	INICIO_LACO
FIM_LACO:	
		la	$t0, salva_S0
		lw  $s0, 0($t0)		# recupera conteudo de s0 da memória
		la	$t0, salva_ra
		lw  $ra, 0($t0)		# recupera conteudo de ra da memória		
		jr $ra
SEED:
	li	$v0, 4			# lendo semente da funcao rand
	la	$a0, semente
	syscall
	li	$v0, 5		#
	syscall
	add	$a0, $zero, $v0	# coloca semente de bombas em a0
	bne  $a0, $zero, DESVIA
	lui  $s0,  1		# carrega semente 100001
 	ori $s0, $s0, 34465	# 
	jr $ra	
DESVIA:
	add	$s0, $zero, $a0		# carrega semente passada em a0
	jr $ra
	
PSEUDO_RAND:
	addi $t6, $zero, 125  	# carrega 125
	lui  $t5,  42			# carrega fator: 2796203
	ori $t5, $t5, 43691 	#-
	
	mult  $s0, $t6			# a * 125
	mflo $s0				# a = (a * 125)
	div  $s0, $t5			# a % 2796203
	mfhi $s0				# a = (a % 2796203)
	div  $s0, $a0			# a % lim
	mfhi $v0                # v0 = a % lim
	jr $ra
#FUNCAO INJETACA (INSERE_BOMBA)
