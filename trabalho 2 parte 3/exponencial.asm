    # Program to:
     # 1 ask the user to type in the value for two variables x and y
     # 2 calculate the exponential function: F(x,y) = x^y
     
     .data 				#variable used follow this line
     promptX: .asciiz "Enter a number for X: "
     promptY: .asciiz "Enter a number for Y: "
     promptR: .asciiz "The result of the exponential funcion: F(x,y) = x^y is "
    .text
    main:
    	li	$v0,	4		# System call code for print string
    	la	$a0,	promptX 	# Load address of the promptX string
    	syscall 			# call OS to Print promptX
    	li 	$v0,	5 		# System call code for read integer
    	syscall 			# call OS to Read integer into $v0
    	move 	$s0,	$v0 		# Move the integer into $s0
    	li	$v0,	4		# System call code for print string
    	la	$a0,	promptY		# Load address of the promptY string
    	syscall 			# call OS to Print promptY
    	li 	$v0,	5 		# System call code for read integer
    	syscall 			# call OS to Read integer into $v0
    	move 	$s1,	$v0 		# Move the integer into $s1
    	move	$a0,	$s0		# Move the integer in $s0 into $a0
    	move	$a1,	$s1		# Move the integer in $s1 into $a1
    	jal	exponential		# Jum and link to exponential sub routine
    	
    	# Print out the result
    	move	$a0,	$v0
    	li	$v0,	1
    	syscall 
    	# End the Program
    	li 	$v0,	10		#System call code to Exit
    	syscall				#call OS to Exit the program
    exponential: 
    	addi	$sp,	$sp,	-4
    	sw	$t0,	4($sp)
    	move	$t0,	$zero
    	li	$v0,	1
    loop: 
    	beq	$t0,	$a1,	end	# Checks to see if $t0 is equal to $a1 if not
    					# it continues, if it is it jumps to end
    	mul	$v0,	$v0,	$a0	# Multiplies the value in $a0 by the value in $v0
    	addi	$t0,	$t0,	1	# Adds 1 to $t0 and stores it in $t0 because
    					# $t0 is the loop counter
    	j	loop			# Jumps to the beginning of the loop to start
    					# the process over
    end:
    	#restore $t0 and the stack
    	lw	$t0,	4($sp)
    	addi	$sp,	$sp,	4
    	jr	$ra
