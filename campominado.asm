	.data
matriz_mapa: 	.space 324 	# matriz_mapa armazena os valores da célula
matriz_user: 	.space 324 	# matriz_mapa armazena a renderização
				# 324 = 9*9 Maior matriz porssível
prompt_opcoes: 		.asciiz "Escolha um dos tamanhos:\n5) 5x5\n7) 7x7\n9) 9x9\nTamanho: "
prompt_coordenada_i: 	.asciiz "\nInforme a linha (a partir de 1): "
msg_i_errado:	 	.asciiz "Linha informada é inválida\n"
prompt_coordenada_j: 	.asciiz "\nInforme a coluna (a partir de 1): "
msg_j_errado:	 	.asciiz "Coluna informada é inválida\n"
msg_tamanho_errado: 	.asciiz "\n\nO tamanho informado é inválido!\n\n"
print_nova_linha: 	.asciiz "\n"
print_espaco:	 	.asciiz " "
interrogacao:	 	.asciiz "?"
msg_vitoria: 		.asciiz "\n\n--- NINJA DAS BOMBAS ---\nVocê conseguiu desviar de todas as bombas =D\nParabéns, você ganhou o jogo YUPI!!\n\n"
msg_derrota: 		.asciiz "\n\n--- Marcha Funebre para você ---\nInfelizmente você pisou numa bomba :(\nAgora você é uma estelinha no céu :')\n\n"

tamanho:	.word 0		# Armazena o tamanho do campo escolhido

qtd_disponivel:	.word 0		# Controla quantidade de campos disponíveis para abrir
qtd_explorado:	.word 0		# Controla quantidade de campos já abertos


#FUNCAO INJETADA (INSERE_BOMBA)
campo:			.space		324
semente:		.asciiz		"\nEntre com a semente da funcao Rand: "
espaco:			.asciiz		" "
nova_linha:		.asciiz		"\n"
posicao:		.asciiz		"\nPosicao: "
salva_S0:		.word		0
salva_ra:		.word		0
salva_ra1:		.word		0
#FUNCAO INJETADA (INSERE_BOMBA)

	.text
main:
	# PRE JOGO
	# inicializa array mapa com 0
	la   $a0, matriz_mapa # a0 -> matriz
	add  $a1, $0, $0      # a1 -> valor inicial
	jal  inicializa_array
	
	# inicializa array user com -1
	la   $a0, matriz_user # a0 -> matriz
	addi $a1, $0, -1      # a1 -> valor inicial
	jal  inicializa_array
	
	# obtem tamanho do mapa
	jal  obtem_tamanho
	# salvar o valor na label tamanho
	la   $t1, tamanho
 	sw   $v0, 0($t1)
 		
	# carrega bombas no array mapa
	la   $a0, matriz_mapa # a0 -> matriz
	lw   $a1, tamanho     # a1 -> qtd linhas
	jal  INSERE_BOMBA
	
	# calcula valor das posições
	la   $a0, matriz_mapa
	lw   $a1, tamanho
	jal  calcula_mapa
	
	# inicia contadores
	sw   $0,  qtd_explorado
	la   $a0, matriz_mapa # a0 -> matriz
	lw   $a1, tamanho     # a1 -> qtd linhas
	jal  obtem_qtd_bombas	
	# determina a quantidade de celulas disponíveis
	lw   $t0, tamanho     # qtd linhas
	mul  $t0, $t0, $t0    # qtd * qtd = numero celulas
	sub  $t0, $t0, $v0    # qtd disponivel = numero celulas - qtd bombas
	sw   $t0, qtd_disponivel

	
	# INICIO	
loop_jogo:	
	# renderiza mapa a cada rodada
	la   $a0, matriz_user
	lw   $a1, tamanho
	jal  renderiza_mapa

	# le IxJ informado pelo usuario
	lw   $a0, tamanho
	jal  obtem_ij_usuario
	# as entradas de i e j são a partir de 1
	# para tratar via cálculo, precisamos a partir de 0
	# por isso é subtraído um no momento momento
	# que salva em variáveis temporárias
	addi $s0, $v0, -1 #i 
	addi $s1, $v1, -1 #j
	
	# acessa endereço ref i e j do mapa
	la   $a0, matriz_mapa # endereço array
	lw   $a1, tamanho     # tamanho matriz
	add  $a2, $0, $s0     # i
	add  $a3, $0, $s1     # j
	jal  obtem_addr_matriz
	lw   $s2, 0($v0) # valor do campo
	
	# se o campo for 9, então fim de jogo
	beq  $s2, 9, campo_bomba
	j    campo_seguro

campo_seguro:
	# replica o valor no mapa de renderização
	# user[i][j] = mapa[i][j] 
	la   $a0, matriz_user # endereço array
	lw   $a1, tamanho     # tamanho matriz
	add  $a2, $0, $s0     # i
	add  $a3, $0, $s1     # j
	jal  obtem_addr_matriz
	lw   $t0, 0($v0) # valor atual do campo
	sw   $s2, 0($v0) # replica o valor do campo
	
	# incrementa controle de campos somente
	# quando valor for -1
	# se não for -1, significa que foi
	# um campo já explorado
	seq  $t1, $t0, -1
	beq  $t1, $0, fim_rodada
	
	lw   $t0, qtd_explorado
	addi $t0, $t0, 1
	sw   $t0, qtd_explorado
	
	j    fim_rodada
	
campo_bomba:
	# user[i][j] = mapa[i][j] 
	la   $a0, matriz_user # endereço array
	lw   $a1, tamanho     # tamanho matriz
	add  $a2, $0, $s0     # i
	add  $a3, $0, $s1     # j
	jal  obtem_addr_matriz
	sw   $s2, 0($v0) # replica o valor do campo
	
	# finalizar loop
	j    fim_jogo_derrota

fim_rodada:	
	lw   $t0, qtd_explorado
	lw   $t1, qtd_disponivel
	# jogo finaliza quando qtd explorado == qtd disponivel
	beq  $t0, $t1, fim_jogo_vitoria
	j    loop_jogo
	
	
	# POS JOGO
fim_jogo_vitoria:
	la   $a0, matriz_user
	lw   $a1, tamanho
	jal  renderiza_mapa
	
	# mensagem de fim do jogo
	addi $v0, $0, 4 # print string
	la   $a0, msg_vitoria
	syscall

	# exibe mensagens conforme resultado
	j    fim
	
fim_jogo_derrota:
	la   $a0, matriz_user
	lw   $a1, tamanho
	jal  renderiza_mapa
	
	# mensagem de fim do jogo
	addi $v0, $0, 4 # print string
	la   $a0, msg_derrota
	syscall
	
	# renderiza
	la   $a0, matriz_user
	lw   $a1, tamanho
	jal  renderiza_mapa
	
	# exibe mensagens conforme resultado
	j    fim
	
fim:
	addi $v0, $zero, 10 # exit 
	syscall

		
	
	
	
#########################
#   OBTEM QTD BOMBAS    #
#########################
# Argumentos:
# $a0 -> Endereço matriz
# $a1 -> Tamanho da matriz
# 
# Retorno:
# $v0 -> Quantidade de bombas na matriz
#
# Descrição:
# Retorna um valor inteiro referente
# a quantidade de bombas existentes na matriz informada
#########################
obtem_qtd_bombas:
	# Salva os argumentos
	add  $t0, $zero, $zero # $t0 i -> linha
			       # $t1 j -> coluna
	add  $t2, $zero, $zero # $t2 -> quantidade de bombas
	add  $t6, $zero, $a0   # endereço da matriz
	add  $t7, $zero, $a1   # tamanho da matriz
	
loop_obtem_qtd_bombas_i:
	slt  $t3, $t0, $t7 # i < tamanho
	beq  $t3, $zero, return_obtem_qtd_bombas
	add  $t1, $zero, $zero # zera registrador de j
	
loop_obtem_qtd_bombas_j:
	slt  $t3, $t1, $t7 # j < tamanho
	beq  $t3, $zero, fim_loop_obtem_qtd_bombas_j
	
	# leitura da posicao
	mul  $t3, $t0, $t7 # posicao = (i * tamanho)
	add  $t3, $t3, $t1 # posicao = j + (i * tamanho)
	sll  $t3, $t3, 2   # posicao = 4 * (j + (i * tamanho))
	add  $t3, $t3, $t6 # array[posicao]
	lw   $t4, 0($t3)
	
	addi $t1, $t1, 1 # incremento coluna
	bne  $t4, 9, loop_obtem_qtd_bombas_j 
	addi $t2, $t2, 1 # incrementar contagem de bombas
	j    loop_obtem_qtd_bombas_j
		
fim_loop_obtem_qtd_bombas_j:
	addi $t0, $t0, 1 # incremento linha
	j    loop_obtem_qtd_bombas_i

return_obtem_qtd_bombas:
	add  $v0, $zero, $t2
	jr   $ra

		
	
	
	
#########################
#   OBTEM ADDR MATRIZ   #
#########################
# Argumentos:
# $a0 -> Endereço matriz
# $a1 -> Tamanho da matriz
# $a2 -> Linha
# $a3 -> Colina
# 
# Retorno:
# $v0 -> Endereço do campo
#
# Descrição:
# Retorna o endereço do campo apontado
# por i e j
# Obs: i e j a partir de 0
#########################
obtem_addr_matriz:
	# Salva o argumentos
	add  $t0, $0, $a0 # enderço
	add  $t1, $0, $a1 # tamanho
	add  $t2, $0, $a2 # i
	add  $t3, $0, $a3 # j

	# leitura da posicao
	mul  $t4, $a2, $a1 # posicao = (i * tamanho)
	add  $t4, $t4, $a3 # posicao = j + (i * tamanho)
	sll  $t4, $t4, 2   # posicao = 4 * (j + (i * tamanho))
	add  $t4, $t4, $a0 # array[posicao]

	add  $v0, $0, $t4
	
return_obtem_addr_matriz:
	jr   $ra

		
	
	
	
#########################
#   OBTEM I J USUARIO   #
#########################
# Argumentos:
# $a0 -> Numero de linhas e colunas
# 
# Retorno:
# $v0 -> Linha
# $v1 -> Coluna
#
# Descrição:
# Exibe mensagem para informar a linha
# e a coluna deseja. Caso seja um valor
# inválido, é repetida a entrada
#########################
obtem_ij_usuario:
	# Salva o argumento do tamanho
	add  $t0, $0, $a0
i_obtem_ij_usuario:
	# Mensagem para informar linha
	addi $v0, $0, 4 # print string
	la   $a0, prompt_coordenada_i
	syscall
	addi $v0, $0, 5 # entrada de dados
	syscall
	# verifica se o valor é valido
	add  $t1, $0, $v0
	sgt  $t2, $t1, $0 # valor negativo
	beq  $t2, 0, erro_i_ij_usuario
	sgt  $t2, $t1, $t0 # maior que o limite
	bne  $t2, 0, erro_i_ij_usuario
	add  $t6, $0, $t1
	
j_obtem_ij_usuario:
	# Mensagem para informar linha
	addi $v0, $0, 4 # print string
	la   $a0, prompt_coordenada_j
	syscall
	addi $v0, $0, 5 # entrada de dados
	syscall
	# verifica se o valor é valido
	add  $t1, $0, $v0
	sgt  $t2, $t1, $0 # valor negativo
	beq  $t2, 0, erro_j_ij_usuario
	sgt  $t2, $t1, $t0 # maior que o limite
	bne  $t2, 0, erro_j_ij_usuario
	add  $t7, $0, $t1
	
	j    return_obtem_ij_usuario
	
erro_i_ij_usuario:
	# Mensagem de linha errada
	addi $v0, $0, 4 # print info
	la   $a0, msg_i_errado
	syscall
	j    i_obtem_ij_usuario
	
erro_j_ij_usuario:
	# Mensagem de linha errada
	addi $v0, $0, 4 # print info
	la   $a0, msg_j_errado
	syscall
	j    j_obtem_ij_usuario

return_obtem_ij_usuario:
	add  $v0, $0, $t6
	add  $v1, $0, $t7
	jr   $ra

		
	
	
	
#########################
#     CALCULA ARRAY     #
#########################
# Argumentos:
# $a0 -> Endereço do array
# $a1 -> Numero de linhas e colunas
# 
# Retorno:
# void
#
# Descrição:
# Intera array em busca das bombas
# e incrementa valores nos vizinhos
#########################
calcula_mapa:
	add  $s2, $zero, $zero # i = linha
	move $s0, $a0 # endereço array
	move $s1, $a1 # tamanho
	move $s4, $ra # salva retorno

loop_calcula_mapa_i:
	slt  $t3, $s2, $s1 # i < tamanho
	beq  $t3, $zero, return_calcula_mapa
	add  $s3, $zero, $zero # j = coluna
	
loop_calcula_mapa_j:
	slt  $t3, $s3, $s1 # j < tamanho
	beq  $t3, $zero, fim_loop_calcula_mapa_j
	
	# leitura da posicao
	mul  $t4, $s2, $s1 # posicao = (i * tamanho)
	add  $t4, $t4, $s3 # posicao = j + (i * tamanho)
	sll  $t4, $t4, 2   # posicao = 4 * (j + (i * tamanho))
	add  $t4, $t4, $s0 # array[posicao]
	lw   $t6, 0($t4)
	
	# se nao for bomba, continua a procura
	bne  $t6, 9, jump_calcula_mapa
	# mas se for, chama a funcao de incremento dos vizinhos
	move $a0, $s0 # $a0 -> endereço do array
	move $a1, $s1 # $a1 -> tamanho
	move $a2, $s2 # $a2 -> i
	move $a3, $s3 # $a3 -> j
	jal  incrementa_bomba_vizinho

jump_calcula_mapa:
	addi $s3, $s3, 1 # incremento coluna
	j    loop_calcula_mapa_j
	
fim_loop_calcula_mapa_j:
	addi $s2, $s2, 1 # incremento linha
	j    loop_calcula_mapa_i

return_calcula_mapa:
	move $ra, $s4 # seta o retorno
	jr   $ra

		
	
	
	
############################
# INCREMENTA BOMBA VIZINHO #
############################
# Argumentos:
# $a0 -> Endereço do array
# $a1 -> Numero de linhas e colunas
# $a2 -> Linha (i)
# $a3 -> Coluna (j)
# 
# Retorno:
# void
#
# Descrição:
# Calcula a posicao dos vizinhos e
# incrementa o valor deles
#########################
incrementa_bomba_vizinho:
	addi $t0, $0, 1 # $t0 -> maxI 
	addi $t1, $0, 1 # $t1 -> maxJ
	beq  $a2, 0, pula_i_incrementa_bomba_vizinho # i == 0 não volta a linha
	addi $t0, $0, 0 # se volta linha, então maxI começa com 0
	addi $a2, $a2, -1 # volta linha
	
pula_i_incrementa_bomba_vizinho:
	beq  $a3, 0, pula_j_incrementa_bomba_vizinho # j == 0 não volta a coluna
	addi $t1, $0, 0 # se volta linha, então maxJ começa com 0
	addi $a3, $a3, -1 # volta coluna
	
pula_j_incrementa_bomba_vizinho:
	add  $t4, $0, $t1 # $t4 -> grava o inicio da contagem da coluna
	add  $t5, $0, $a3 # $t5 -> grava o inicio de j
	j    loop_incrementa_bomba_vizinho

loop_incrementa_bomba_vizinho_i:
	add  $t0, $t0, 1 # maxI++
	add  $a2, $a2, 1 # i++
	beq  $t0, 3, return_incrementa_bomba_vizinho # maxI == 3
	beq  $t0, $a1, return_incrementa_bomba_vizinho # maxI == tamanho
	add  $t1, $0, $t4 # seta novamente o valor inicial da contagem de coluna
	add  $a3, $0, $t5 # reset em j
	
	# $a2 -> i
	# $a3 -> j
loop_incrementa_bomba_vizinho:	
	# leitura da posicao
	mul  $t3, $a2, $a1 # posicao = (i * tamanho)
	add  $t3, $t3, $a3 # posicao = j + (i * tamanho)
	sll  $t3, $t3, 2   # posicao = 4 * (j + (i * tamanho))
	add  $t3, $t3, $a0 # array[posicao]
	lw   $t7, 0($t3)   # lê valor da posicao
	beq  $t7, 9, loop_incrementa_bomba_vizinho_j # ignora o campo bomba
	addi $t7, $t7, 1   # adiciona o valor da posicao
	sw   $t7, 0($t3)   # escreve valor na posicao
	
loop_incrementa_bomba_vizinho_j:	
	add  $t1, $t1, 1 # maxJ++
	add  $a3, $a3, 1 # j++
	beq  $t1, 3, loop_incrementa_bomba_vizinho_i # maxJ == 3
	beq  $a3, $a1, loop_incrementa_bomba_vizinho_i # j == tamanho
	j    loop_incrementa_bomba_vizinho

return_incrementa_bomba_vizinho:                          
	jr   $ra
		
		
		
		

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
	
	# print novalinha
	addi $v0, $zero, 4 # print string
	la   $a0, print_nova_linha
	syscall
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
	add  $t0, $zero, $zero # count
	add  $t1, $0, $a0 # t1 -> endereço do mapa
	add  $t2, $0, $a1 # t2 -> valor inicial

loop_inicializa_array:
	slti $t5, $t0, 81 # count < 9
	beq  $t5, $zero, return_inicializa_array
	sw   $t2, 0($t1) # seta o valor passado por parametro na posição count
	addi $t1, $t1, 4 # apontador do enderço do array
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







#FUNCAO INJETADA (INSERE_BOMBA)
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
#FUNCAO INJETADA (INSERE_BOMBA)
