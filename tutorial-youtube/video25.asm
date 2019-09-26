.data
	message: .asciiz "Ola, como esta"
.text
	main:
		addi $s0, $zero, 14
		addi $s1, $zero, 10
		
		bgt $s0, $s1, mostra
	
	li $v0, 10
	syscall
	
	mostra:
		li $v0, 4
		la $a0, message
		syscall
