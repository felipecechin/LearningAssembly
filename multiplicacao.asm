.data
	Numero1: .asciiz "Informe o primeiro numero: "
	Numero2: .asciiz "Informe o segundo numero: "
	Resultado: .asciiz "O resultado da multiplicacao e: "
	
.text
	li $v0, 4
	la $a0, Numero1
	syscall
	
	li $v0, 5
	syscall
	
	move $t0, $v0
	
	li $v0, 4
	la $a0, Numero2
	syscall
	
	li $v0, 5
	syscall
	
	move $t1, $v0
	
	mult $t0,$t1
	
	mflo $s3
	
	li $v0, 4
	la $a0, Resultado
	syscall
	
	li $v0, 1
	move $a0, $s3
	syscall