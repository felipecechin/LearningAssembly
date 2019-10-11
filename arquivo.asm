.data  
fin: .asciiz "text.bin"      # filename for input
buffer: .space 2048
palavra: .space 2048

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

la $a0, buffer
jal carrega_dados_arquivo
    
# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

li $v0, 10
syscall

carrega_dados_arquivo:
    #prologo
    addiu $sp, $sp, -24
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    sw $s1, 8($sp)
    sw $s2, 12($sp)
    sw $s3, 16($sp)
    sw $s4, 20($sp)
    
    #corpo 
    add $s0, $a0, $zero #$s0 dados do arquivo
    la $s1, palavra
    li $s2, 0
    li $s3, 0
    j imprime_byte
    proximo_comando:
    	addi $s1, $s1, 4
        li $s3, 0
    imprime_byte:
        beq $s3, 4, verifica_palavra
        j continua
        verifica_palavra:
        	add $a0, $s1, $zero
        	jal verifica_palavra_nula
        	beq $v0, 1, carrega_dados_arquivo_fim
        	j proximo_comando
        continua:
        	add $s4, $s1, $s3
        	add $s0, $s0, $s2
        	lbu $s4, ($s0)
        	addi $s2, $s2, 1
        	addi $s3, $s3, 1
        	j imprime_byte
    
    #epilogo
    carrega_dados_arquivo_fim:
    	lw $s4, 20($sp)
    	lw $s2, 12($sp) 
    	lw $s3, 16($sp)
    	lw $s1, 8($sp)
    	lw $s0, 0($sp)  
    	lw $ra, 4($sp)
    	addiu $sp, $sp, 24
    	jr $ra
