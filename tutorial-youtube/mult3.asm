.data

.text
	addi $s0, $zero, 4
	sll $t0, $s0, 2 #exponencial -> 2 representa multiplicar por 4, 1 representa multiplicar por 2, 3 representa multiplicar por 8
	
	li $v0, 1
	add $a0, $zero, $t0
	syscall
