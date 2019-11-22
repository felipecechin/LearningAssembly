.text

	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	beq $t9, $at, loop
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b

loop:
	sw $fp, 0x00000018($t0)
	j target
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	addi $s3, $ra, 0x7b
	
target:
	lw $a0, 0x28($a1)