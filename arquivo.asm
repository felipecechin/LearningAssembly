.data  
fin: .asciiz "text.bin"      # filename for input
buffer: .space 2048
palavra: .space 4

.text
#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 2048     # hardcoded buffer length
syscall            # read from file

la $s0, buffer
la $s1, palavra
li $s2, 0
proximo_comando:
	li $s3, 0
imprime_byte:
	beq $s3, 4, proximo_comando
	add $s0, $s0, $s2
	lbu $s1, ($s0)
	beq $s1, $s3, continua
	li $v0, 34
	add $a0, $s1, $zero
	syscall
	addi $s2, $s2, 1
	addi $s3, $s3, 1
	j imprime_byte
	

continua:
# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file
