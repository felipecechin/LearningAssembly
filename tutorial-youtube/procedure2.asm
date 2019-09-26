.data
	
.text
	main:
		addi $a1, $zero, 50 #argumentos se usa a1 ao a3
		addi $a2, $zero, 100
		jal addNumbers
		
		li $v0, 1
		addi $a0, $v1, 0
		syscall
		
		li $v0, 10
		syscall
		
	addNumbers:
		add $v1, $a1, $a2 #retorno de procedimento se usa v1
		jr $ra