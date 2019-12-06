.text

	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	loop:
	addi $s3, $ra, 0x7b #loop
	addi $s3, $ra, 0x7b
	beq $s2, $t9, loop 
	addi $s3, $ra, 0x7b

alvo:
	sw $fp, 0x00000018($t0)
	j target
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	
target:
	lw $a0, 0x28($a1)
