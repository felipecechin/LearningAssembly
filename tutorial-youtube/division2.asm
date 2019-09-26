.data

.text
	addi $t0, $zero, 30
	addi $t1, $zero, 7
	
	div $t0, $t1
	
	mflo $s0 #quociente
	mfhi $s1 #Resto
	
	li $v0, 1
	add $a0, $zero, $s0
	syscall