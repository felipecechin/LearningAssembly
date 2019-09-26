.data
	vetorA: .word 1,2,3,4,5
	variavel_I: .space 4	
.text
	la $t1, variavel_I
	li $t2, 4
	sw $t2, 0($t1)
	
	la $t2, vetorA
	lw $t3, 0($t1)
	add $t2, $t2, $t3
	li $v0, 1
	lw $a0, 0($t2)
	syscall
	
	li $v0, 10
	syscall
	