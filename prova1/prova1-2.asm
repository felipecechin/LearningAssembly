.data
	a: .space 40
.text
	
	
	la $t1, a
	beq $t0, 0, caso0
	beq $t0, 1, caso1
	beq $t0, 2, caso2
	j fim
	caso0:
		sll $t0, $t0, 2
		add $t1, $t1, $t0
		lw $t2, ($t1)
		subi $t2, $t2, 1
		sw $t2, ($t1)
		j fim
	caso1:
		sll $t0, $t0, 2
		add $t1, $t1, $t0
		lw $t2, ($t1)
		addi $t2, $t2, 1
		sw $t2, ($t1)
		j fim
	caso2:
		sll $t0, $t0, 2
		add $t1, $t1, $t0
		lw $t2, ($t1)
		subi $t2, $t2, 10
		sw $t2, ($t1)
		j fim
	fim:
		li $v0, 10
		syscall