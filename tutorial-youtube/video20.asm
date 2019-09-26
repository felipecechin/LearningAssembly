.data
	message: .asciiz "Digite o valor de PI: "
.text
	
	li $v0, 4
	la $a0, message
	syscall
	
	li $v0, 6
	syscall
	
	li $v0, 2
	add.s $f12, $f0, $f4
	syscall
	
	
