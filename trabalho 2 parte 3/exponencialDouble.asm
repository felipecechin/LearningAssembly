    # Program to:
     # 1 ask the user to type in the value for two variables x and y
     # 2 calculate the exponential function: F(x,y) = x^y
     
     .data 				#variable used follow this line
     promptX: .asciiz "Enter a number for X: "
     promptY: .asciiz "Enter a number for Y: "
     promptR: .asciiz "The result of the exponential funcion: F(x,y) = x^y is "
     number: .double 3.5
     numero1: .double 1.0
    .text
    main:
    	
    	ldc1 $f12, number
    	addi $a1, $zero, 3
    	jal	exponential		# Jum and link to exponential sub routine
    	mov.d $f12, $f10
    	li $v0, 3
    	syscall
    	li 	$v0,	10		#System call code to Exit
    	syscall				#call OS to Exit the program
    exponential:
    	addiu $sp, $sp, -4
    	sw $s0, 0($sp)
    	li $s0, 0
    	ldc1 $f10, numero1
    exponential_loop: 
    	beq	$s0, $a1, exponential_end	# Checks to see if $t0 is equal to $a1 if not
    	mul.d $f10,	$f10,	$f12	# Multiplies the value in $a0 by the value in $v0
    	addi $s0, $s0, 1	# Adds 1 to $t0 and stores it in $t0 because
    	j exponential_loop			# Jumps to the beginning of the loop to start
    					# the process over
    exponential_end:
    	#restore $t0 and the stack
    	lw $s0, 0($sp)
    	addiu $sp, $sp,	4
    	jr $ra
