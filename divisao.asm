.data
	PrimeiroNumero: .asciiz "Informe o primeiro n�mero: "
	SegundoNumero: .asciiz "Informe o segundo n�mero: "
	ResultadoDivisao: .asciiz "O resultado da divis�o �: "
.text
	li $v0,4
	la $a0,PrimeiroNumero
	syscall
	
	li $v0, 5
	syscall
	
	move $t0,$v0
	
	li $v0,4
	la $a0, SegundoNumero
	syscall
	
	li $v0, 5
	syscall
	
	move $t1, $v0
	
	div $t0, $t1
	
	mflo $s3
	
	li $v0, 4
	la $a0, ResultadoDivisao
	syscall
	
	li $v0, 1
	la $a0, 0($s3)
	syscall