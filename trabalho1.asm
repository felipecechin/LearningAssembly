#*******************************************************************************
# exercicio0.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Este programa mostra como utilizar a ferramenta keyboard and 
# display MMIO (memory-mapped I/O) simulator. Para demostrar a ferramenta,
# lemos os caracteres do teclado e ecoamos para o terminal
#
# Para o keyboard, usamos os seguintes registradores
# RCR - receiver control register    | 0xFFFF0000
# RDR - receiver data register       | 0xFFFF0004
#
# Para o display temos os seguintes registradores
# TCR - transmitter control register | 0xFFFF0008
# TDR - transmitter data register    | 0xFFFF000C
#
# Para ler um caracter do keyboard
# 1. leia o conteúdo do endereço 0xFFFF0000 (receiver control register)
# 2. Verifique o bit menos significativo do receiver control register
# 3. Se 0 vá para o item 1 senão leia o caracter digitado do endreço
#    0xFFFF0004 (receiver data register)
#
# Para escrever um caracter em display
# 1. leia o conteúdo do endereço 0xFFFF0008 (transmitter control register)
# 2. Verifique o bit menos significativo do dado lido
# 3. Se 0 vá para o item 1 (continue esperando até que o bit menos
#    significativo do transmitter control register seja igual a 1).
#    Se 1 escreva no display. Isto é feito escrevendo um dado no
#    endereço 0xFFFF000C (transmitter data register).
#
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    09/09/2019 GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #

#segmento de dados
.data
	linha_comando: .space 80
	#backspace: .word 8
	#enter: .word 10
.text
main:
	li $t3, 0
	jal limpa_vetor
laco1:
    lw    $t1, 0xFFFF0000       # $t1 <- conteúdo do RCR
    andi  $t1, $t1, 0x0001  # isolamos o bit menos significativo
    beqz  $t1, laco1 
    lw    $t2, 0xFFFF0004       # $t2 <- caracter do terminal
    beqz $t2, laco1
    beq $t2, 8, laco1
    jal armazena_vetor
    beq $t2, 10, imprime_linha
	j laco1
    # epílogo    
    li    $v0, 10           # serviço 10 - exit
    syscall
armazena_vetor:
    la $s0, linha_comando
    add $s0, $s0, $t3
    sw $t2, 0($s0)
    addi $t3, $t3, 4
    jr $ra
imprime_linha:
   	# endereço do TCR
    lw    $s0, 0xFFFF0008       # $t1 <- conteúdo do TCR
    andi  $s0, $s0, 0x0001  # isolamos o bit menos significativo
    beqz  $s0, imprime_linha
    # escrevemos o carcatere no display
    # endereço do TDR
    li $s2, 0
    imprime_linha_loop:
    	la $s1, linha_comando
    	add $s1, $s1, $s2
    	lw $s1, 0($s1)
    	beqz $s1, main
    	sw    $s1, 0xFFFF000C
    	add $s2, $s2, 4	
    	j imprime_linha_loop
    jr $ra
limpa_vetor:
	li $s1, 0
	limpa_vetor_loop:
    	la $s0, linha_comando
    	add $s0, $s0, $s1
    	lw $s2, 0($s0)
    	beqz $s2, laco1
    	sw $zero, 0($s0)
    	add $s1, $s1, 4	
    	j limpa_vetor_loop
