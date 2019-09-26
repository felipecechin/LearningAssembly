.data
	message: .asciiz "Oi para todos.\nMeu nome eh Felipe.\n"
.text
	main:
		jal displayMessage
		
		addi $s0, $zero, 5
		li $v0, 1
		add $a0, $zero, $s0
		syscall
		
		li $v0, 10
		syscall
	displayMessage:
		li $v0, 4
		la $a0, message
		syscall
		jr $ra