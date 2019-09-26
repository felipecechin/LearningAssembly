# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo do uso das operações lógicas and, or e xor para
#            resetar, setar e inverter bits
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
# carregamos a palavra variavel_teste
# registrador: $s0 <- Mem[variavel_teste]
            la    $t0, variavel_teste # carregamos o endereço base em $t0
            lw    $s0, 0($t0)   # $s0 <- Mem[registro_numeros + 0] $s0 <- 0xAABBCCDD
# resetamos os bits 31 a 24 e 7 a 0 - usamos a operação lógica and
            li    $t1, 0x00FFFF00 # carregamos a máscara em $t1 0- zera bit 
            and   $s0, $s0, $t1   # $s0 <- 0x00BBCC00
# setamos os bits 31 e 0
            li    $t1  0x80000001 # carregamos uma máscara em $t1 1 - seta bit
            or    $s0, $s0, $t1   # $s0 <- 0x80BBCC01
# invertemos os bits 31 e 0
            li    $t1, 0x80000001 # carrgamos a máscara em $t1 1 - inverte bit
            xor   $s0, $s0, $t1 # $s0 <- 0x00BBCC00
# termina o programa
            li    $a0, 0        # $a0 <- 0. retorna 0 para o programa chamador
            li    $v0, 17       # serviço 17: termina a execução do programa    
            syscall             # faz a chamada ao serviço do sistema
    
.data
variavel_teste:   .word 0xAABBCCDD # uma palavra para testar as operações lógicas

    

