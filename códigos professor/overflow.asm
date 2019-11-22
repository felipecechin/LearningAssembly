.text

# verificacao de overflow para numeros com sinal
    addu $t0, $t1, $t2
    xor $t3, $t1, $t2
    slt $t3, $t3, $zero
    bne $t3, $zero, no_overflow1
    xor $t3, $t0, $t1
    slt $t3, $t3, $zero
    bne $t3, $zero, overflow1

no_overflow1:

overflow1:





# verificacao de overflow para numeros sem sinal
    addu $t0, $t1, $t2
    nor $t3, $t1, $zero
    sltu $t3, $t3, $t2
    bne $t3, $zero, overflow2

no_overflow2:

overflow2: