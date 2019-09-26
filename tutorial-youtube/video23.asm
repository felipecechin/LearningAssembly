.data
	message: .asciiz "Os numeros sao iguais"
	message2: .asciiz "Nada aconteceu"
.text
	main:
		addi $t0, $zero, 20
		addi $t1, $zero, 20
		
		beq $t0, $t1, numbersEqual

	li $v0, 10
	syscall
	
	numbersEqual:
		li $v0, 4
		la $a0, message
		syscall