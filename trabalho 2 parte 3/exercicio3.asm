.data
	msg_entreNumero: .asciiz "Entre com um numero: "
	const1: .double 0.4  # constante 0.4, em ponto flutuante
  
    
   
.text
main:
	jal leiaNumeroPF  # le um numero em ponto flutuante
    mov.d $f12, $f0 # $f12 e o primeiro argumento para a funcao
    jal funcao
	li $v0, 10
	syscall
  
################################################################################    
fatorial:
#prologo
            addiu $sp, $sp, -8      # ajusta a pilha para receber 2 itens
            sw    $ra, 4($sp)       # salva o endereço de retorno
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
# fim do procedimento fatorial
################################################################################    

funcao:
	la $t0, const1
	ldc1 $f10, 0($t0)
	c.lt.d  $f12, $f10
    bc1t funcao_retorna_zero          
	addi $a0, $zero, 3
    jal fatorial
    mtc1.d $v0, $f12
  	cvt.d.w $f12, $f12
    li $v0, 3
    syscall
    j funcao_fim
	funcao_retorna_zero:
		li $v0, 0
	funcao_fim:
		jr $ra
	
	
exponential: 
    	addi	$sp,	$sp,	-4
    	sw	$t0,	4($sp)
    	move	$t0,	$zero
    	li	$v0,	1
    loop: 
    	beq	$t0,	$a1,	end	# Checks to see if $t0 is equal to $a1 if not
    					# it continues, if it is it jumps to end
    	mul	$v0,	$v0,	$a0	# Multiplies the value in $a0 by the value in $v0
    	addi	$t0,	$t0,	1	# Adds 1 to $t0 and stores it in $t0 because
    					# $t0 is the loop counter
    	j	loop			# Jumps to the beginning of the loop to start
    					# the process over
    end:
    	#restore $t0 and the stack
    	lw	$t0,	4($sp)
    	addi	$sp,	$sp,	4
    	jr	$ra
	


###############################################################################
# imprime uma mensagem, pedindo a entrada de um numero
# leia um numero em ponto flutuante no formato duplo
leiaNumeroPF:
#---------------------------------------------------------------
    la $a0, msg_entreNumero
    li $v0, 4
    syscall
    li      $v0, 7             # servico para ler um numero em ponto flutuante
    syscall                    # faz uma chamada ao sistema
    jr      $ra                # retorna em $f0 numero em ponto flutuante, precisao dupla
###############################################################################
