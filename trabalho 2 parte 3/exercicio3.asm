# Alunos: Bruno Frizzo e Felipe Cechin
# Exercicio 3 - trabalho 2 parte 3

.data
	msg_digite_numero: .asciiz "Digite um numero: "
	msg_resultado_funcao: .asciiz "Resultado de f(x): "
	const: .double 0.4  # constante 0.4, em ponto flutuante
  	const_um: .double 1.0 # constante 1.0, em ponto flutuante
  	const_zero: .double 0.0 # constante 0.0, em ponto flutuante
.text
main:
	jal leia_numero_pf  # le um numero em ponto flutuante
    mov.d $f12, $f0 # $f12 e o primeiro argumento para a funcao
    # $f12 <- x
    jal funcao
    # imprime o valor de resultado da funcao
    mov.d $f12, $f0
    la $a0, msg_resultado_funcao
    li $v0, 4
    syscall
    li $v0, 3
    syscall
	li $v0, 10
	syscall
  
################################################################################
# calcula o fatorial de um numero
fatorial:
#prologo
            addiu $sp, $sp, -8      # ajusta a pilha para receber 2 itens
            sw    $ra, 4($sp)       # salva o endereco de retorno
            sw    $a0, 0($sp)       # salva o argumento da funcao
# corpo do procedimento
            bne   $zero, $a0, n_nao_igual_0 # se n!=0  calcule n*fatorial(n-1)
n_igual_0:
            add   $v0, $zero, 1     # retorna 1 = 0!
            j fatorial_epilogo      # epilogo do procedimento
n_nao_igual_0:
            # precisamos retornar n* fatorial(n-1)
            # n esta na pilha
            # calculamos fatorial(n-1)
            addi  $a0, $a0, -1      # a0 <- n-1
            jal   fatorial          # chamamos fatorial(n-1)
            lw    $a0, 0($sp)       # a0 <- n, restauramos n
            mul   $v0, $a0, $v0     # v0 <- n*fatorial(n-1), v0 valor de retorno
            lw    $ra, 4($sp)       # restaura o endereco de retorno
# epilogo
fatorial_epilogo:
            add   $sp, $sp, 8       # restaura a pilha - eliminamos 2 itens
            jr    $ra               # retorna para o procedimento chamador
################################################################################    

################################################################################
# procedimento que calcula o resultado de f(x)
funcao:
	#prologo
	addiu $sp, $sp, -8
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	
	#corpo
	la $s0, const
	ldc1 $f4, 0($s0) # $f4 <- 0.4
	# $f12 contem o valor de X
	c.lt.d $f12, $f4 # se $f12 < $f4, seta flag 0 true
    bc1t funcao_retorna_zero # se flag 0 for true, pula para retornar zero
    # X >= 0.4
	#busca o resultado de fatorial de 3
	addi $a0, $zero, 3
    jal fatorial
    mtc1.d $v0, $f4
  	cvt.d.w $f4, $f4 # $f4 <- 3!
  	# $f12 contem o valor de X, argumento da funcao exponencial
   	addi $a0, $zero, 3
   	jal exponencial
   	mov.d $f6, $f0 # $f6 <- x^3
   	div.d $f4, $f6, $f4 # $f4 <- (x^3)/3!
   	#busca o resultado de fatorial de 5
	addi $a0, $zero, 5
    jal fatorial
    mtc1.d $v0, $f6
  	cvt.d.w $f6, $f6 # $f6 <- 5!
  	# $f12 contem o valor de X, argumento da funcao exponencial
   	addi $a0, $zero, 5
   	jal exponencial
   	mov.d $f8, $f0 # $f8 <- x^5
   	div.d $f6, $f8, $f6 # $f6 <- (x^5)/5!
   	#busca o resultado de fatorial de 7
	addi $a0, $zero, 7
    jal fatorial
    mtc1.d $v0, $f10
  	cvt.d.w $f10, $f10 # $f10 <- 7!
  	# $f12 contem o valor de X, argumento da funcao exponencial
   	addi $a0, $zero, 7
   	jal exponencial
   	mov.d $f16, $f0 # $f16 <- x^7
   	div.d $f10, $f16, $f10 # $f10 <- (x^7)/7!
   	sub.d $f0, $f12, $f4 # $f0 <- x - ((x^3)/3!)
   	sub.d $f6, $f6, $f10 # $f6 <- ((x^5)/5!)-((x^7)/7!)
   	add.d $f0, $f0, $f6 # $f0 <- $f0 + $f6
    # $f0 contem o resultado
    j funcao_fim # finaliza o procedimento
	funcao_retorna_zero:
		ldc1 $f0, const_zero # $f0 <- 0
		
	#epilogo
	funcao_fim:
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		addiu $sp, $sp, 8
		jr $ra
###############################################################################


###############################################################################
# imprime uma mensagem, pedindo a entrada de um numero
# leia um numero em ponto flutuante no formato duplo
leia_numero_pf:
    la $a0, msg_digite_numero
    li $v0, 4
    syscall
    li $v0, 7 # servico para ler um numero em ponto flutuante
    syscall # faz uma chamada ao sistema
    jr $ra # retorna em $f0 numero em ponto flutuante, precisao dupla
###############################################################################

###############################################################################
# procedimento que calcula o exponencial de um numero em ponto flutuante com precisao dupla
exponencial:
    	addiu $sp, $sp, -4
    	sw $s0, 0($sp)
    	li $s0, 0
    	ldc1 $f0, const_um
    exponencial_loop:
    	beq	$s0, $a0, exponencial_end
    	mul.d $f0, $f0, $f12
    	addi $s0, $s0, 1
    	j exponencial_loop
    exponencial_end:
    	lw $s0, 0($sp)
    	addiu $sp, $sp,	4
    	jr $ra
###############################################################################
