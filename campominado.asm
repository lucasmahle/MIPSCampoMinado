	.data
matriz_mapa: 	.space 324 	# matriz_mapa armazena os valores da célula
matriz_user: 	.space 324 	# matriz_mapa armazena a renderização
				# 324 = 9*9 Maior matriz porssível
prompt_opcoes: 		.asciiz "Escolha um dos tamanhos:\n5) 5x5\n7) 7x7\n9) 9x9\nTamanho: "
prompt_coordenada_i: 	.asciiz "Informe a linha:\n"
prompt_coordenada_j: 	.asciiz "Informe a coluna:\n"
msg_tamanho_errado: 	.asciiz "\n\nO tamanho informado é inválido!\n\n"
nova_linha:	 	.asciiz "\n"
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

	.text
main:

	# CORREÇÕES:
	# Passar inicialia_array como argumento
	
	# PRE JOGO
	# inicializa array mapa com 0
	# inicializa array user com -1
	jal  inicializa_array
	
	# obtem tamanho do mapa
	jal  obtem_tamanho
	# salvar o valor na label tamanho
	la   $t1, tamanho # endereco da referencia de tamanho
 	sw   $v0, 0($t1)  # salva o resultado
	
	# carrega bombas no array mapa
	la   $a0, matriz_mapa # a0 -> matriz
	lw   $a1, tamanho     # a1 -> qtd linhas
	jal  insere_bombas
	
	la   $a0, matriz_user
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
	
	
	# Funcoes
#nome_funcao:
# 	j   return_nome_funcao
#return_nome_funcao:
#	jr   $ra

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
	sgt  $t3, $s0, 0 # valores negativos imprime '?'
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
	la   $a0, nova_linha
	syscall
	j    loop_renderiza_mapa_i

return_renderiza_mapa:
	jr   $ra

############# APAGAR ISSO ANTES DE ENVIAR #################
insere_bombas:
	# coloca bombas especificas 
	#lw   $t0, tamanho # t0 -> tamanho 
	#lw   $t1, 1 # t1 = i (linha)
	#lw   $t2, 2 # t2 = j (colunas)
	#mul  $t1, $t1, $a1 # t1 = i * tamanho
	#add  $t4, $t1, $t2 # n = (i * tamanho) + j
	addi $t0, $zero, 9
	addi $t4, $a0, 28 # bomba fixa na posicao 2x3
	addi $t5, $a0, 68 # bomba fixa na posicao 4x3
	sw   $t0, 0($t4)
	sw   $t0, 0($t5)
 	j return_insere_bombas
return_insere_bombas:
	jr   $ra
############# APAGAR ISSO ANTES DE ENVIAR #################

	
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

fim:
