.data
	a: .space 40
	
.text
	main:
		li $t1, 0 #variavel i
		li $t2, 0 #variavel f
		li $t3, 0 #variavel temporaria
		la $t4, a #endereco memoria a
		sw $t3, 0($t4)
		li $t3, 1
		sw $t3, 4($t4)
		li $t1, 2
		main_loop:
			slti $s1, $t1, 10
			beq $s1, 0, main_fim
			sll $s2, $t1, 2
			add $t3, $t4, $s2
			addi $t5, $t3, -8
			addi $t6, $t3, -4
			lw $t5, ($t5)
			lw $t6, ($t6)
			add $s0, $t5, $t6
			sw $s0, ($t3)
			add $a0, $t5, $zero
			add $a1, $t6, $zero
			add $a2, $s0, $zero
			jal p1
			add $t2, $v0, $zero
			addi $t1, $t1, 1
			j main_loop
		main_fim:
			li $v0, 10
			syscall
	
	p1:
		addi $sp, $sp, -12
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $ra, 8($sp)
		
		add $s0, $a0, $zero
		addi $a0, $a0, 1
		jal p2
		add $v0, $v0, $s0
				
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra
		
	p2:
		addi $sp, $sp, -12
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $ra, 8($sp)
		
		add $s0, $a1, $zero
		addi $a1, $a1, 1
		jal p3
		add $v0, $v0, $s0
				
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra
	
	p3:
		addi $sp, $sp, -12
		sw $s0, 0($sp)
		sw $s1, 4($sp)
		sw $ra, 8($sp)
		
		bgt $a0, $a1, p3_verdadeiro
		add $s0, $a0, $a1
		j p3_fim
		p3_verdadeiro:
			add $s0, $a2, $zero
		p3_fim:		
			add $v0, $s0, $zero
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $ra, 8($sp)
			addi $sp, $sp, 12
			jr $ra
		
		
		