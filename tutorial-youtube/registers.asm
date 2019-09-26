.data
	newLine: .asciiz "\n"
.text
	main:
		addi $s0, $zero, 10
		jal increaseMyRegister
		
		#imprime \n
		li $v0, 4
		la $a0, newLine
		syscall
		
		#imprime
		li $v0, 1
		move $a0, $s0
		syscall
		
	
	
	li $v0, 10
	syscall
	
	#convencao:
	#registradores s nao podem ser modificados nos procedimentos, por isso o uso da pilha
	#registradores t podem ser modificados nos procedimentos
	increaseMyRegister:
		add $sp, $sp, -4
		sw $s0, 0($sp)
		
		#faz o que tiver que fazer
		addi $s0, $s0, 30
		li $v0, 1
		move $a0, $s0
		syscall
		#fim do que tiver que fazer
		
		lw $s0, 0($sp)
		addi $sp, $sp, 4
		
		jr $ra