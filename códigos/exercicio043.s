# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo do uso das operações lógicas and e andi e da operação
#            de deslocamento srl. Neste programa vamos carregar a palavra
#            registro_numeros, isolar cada um dos números N0 a N3 e guardar 
#            nas variáveis var_N0 a var_N3 
#            Formato do registro numeros
#            bit   |31    24|23    16|15    8|7     0|
#            campo |   N0   |   N1   |   N2  |   N3  |
#            N0 a N3 números de 0 a 255
#            N0 = 0x12 N1 = 0x34 N2 = 0x56 e N3 = 0x67
# 
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data       Nome   Comentários
# 0.1    24/08/16   GBTO   versão inicial 
# 0.1.1  31/08/16   GBTO   formatação do código e inclusão de comentários
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #

.text
            .globl main
main:
# carregamos o registro registro_numeros em um
# registrador: $s0 <- Mem[registro_numeros]
            la    $t0, registro_numeros # carregamos o endereço base em $t0
            lw    $s0, 0($t0)   # $s0 <- Mem[registro_numeros + 0]
# isolamos N0 de registro_numeros e guardamos este valor em var_N0
            li    $t1, 0xFF000000 # carregamos em $t1 uma máscara
            and   $t1, $s0, $t1 # isolamos o byte mais significativo
            srl   $t1, $t1, 24  # deslocamos este byte para o byte menos significativo
            la    $t0, var_N0   # carregamos o endereço base de var_N0
            sw    $t1, 0($t0)   # Mem[var_N0] <- N0
# isolamos N1 de registro_numeros e guardamos este valor em var_N1
            li    $t1, 0x00FF0000 # carregamos em $t1 a máscara
            and   $t1, $s0, $t1 # isolamos o byte N1
            srl   $t1, $t1, 16  # deslocamos para o byte menos significativo da palavra
            la    $t0, var_N1   # carregamos o endereço base de var_N1
            sw    $t1, 0($t0)   # guardamos N1 em var_N1
# isolamos N2 de registro_numeros e guardamos este valor em var_N2
            andi  $t1, $s0, 0xFF00 # isolamos o byte N2 de registro_numeros
            srl   $t1, $t1, 8   # deslocamos N2 para o byte menos significativo do registrador
            la    $t0, var_N2   # carregamos o endereço base de var_N2
            sw    $t1, 0($t0)   # guardamos N2 em var_N2
# isolamos N3 de registro_numeros e guardamos este valor em var_N3
            andi  $t1, $s0, 0x00FF # isolamos o byte N1 de registro_numeros
            la    $t0, var_N3   # carregamos o endereço base de var_N3
            sw    $t1, 0($t0)   # guardamos em var_N3 o valor de N3
# termina o programa
            li    $a0, 0        # $a0 <- 0. retorna 0 para o programa chamador
            li    $v0, 17       # serviço 17: termina a execução do programa    
            syscall             # faz a chamada ao serviço do sistema
    
.data
registro_numeros: .word 0x12345678
var_N0:     .space 4
var_N1:     .space 4
var_N2:     .space 4
var_N3:     .space 4
    
    

