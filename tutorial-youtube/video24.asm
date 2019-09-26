.data
	message: .asciiz "O numero eh menor que o outro"
.text
	addi $t0, $zero, 1
	addi $t1, $zero, 200
	
	slt $s0, $t0, $t1
	beq $s0, 1, menor
	
	li $v0, 10
	syscall
	
	menor:
		li $v0, 4
		la $a0, message
		syscall
