#*******************************************************************************
# exercicio024.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Programa que zera os elementos de dois vetores de inteiros. O 
#            procedimento clear1 usa índices e o procedimento clear2 ponteiros.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    30.05.2019     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #

################################################################################
.text
.globl      main
################################################################################




################################################################################
#
# int main(void)
# /******************************************************************************/
# {
#     clear1(vetor1, 10);
#     clear2(vetor2, 10);
#     return 0;
# }
#
# Este procedimento zera os vetores vetor1 e vetor2.
################################################################################
main:                          
# prólogo
# corpo do programa
            # clear1(vetor1, 10);
            la    $a0, vector1  # $a0 <- endereço de vetor1
            li    $a1, 10       # $a1 <- número de elementos do vetor1
            jal   clear1        # chamamos o procedimento clear1, para zerar todos os elementos de vetor1
            # clear2(vetor2, 10);
            la    $a0, vector2  # $a0 <- endereço de vetor2
            li    $a1, 10       # $a1 <- número de elementos do vetor2
            jal   clear2        # chamamos o procedimento clear2, zerando todos os elementos de vetor2
# epílogo
            # return 0;
            li     $a0, 0       # código  de retorno igual a 0
            li     $v0, 17      # chamada a exit2
            syscall             # faz uma chamada ao sistema, terminando o programa
################################################################################




################################################################################
#void clear1 (int array[ ], int size){
#    int i;
#    for(i=0; i<size; i=i+1) array[i] = 0;
#}
# Este procedimento zera os elementos de um vetor de inteiros.
# Argumentos
#   $a0 : endereço base do vetor
#   $a1 : número de elementos do vetor
################################################################################
clear1:                         # procedimento clear1
# prólogo
            # Obs.: Neste procedimento a variável local foi mantida no registrador
            # $t0. Não utilizamos a pilha para armazenar esta variável.
# corpo do programa
            move  $t0, $zero    # i= 0
loop1:
            sll   $t1, $t0, 2   # t1 <- 4 * i
            add   $t2, $a0, $t1 # t1 <- &array[i]
            sw    $zero, 0($t2) # array[i] = 0
            addi  $t0, $t0, 1   # i = i + 1
            slt   $t3, $t0, $a1 # t3 <- (i<size)?
            bne   $t3, $zero, loop1 # se t3=1 então vá para loop1
fimClear1:  
# epílogo
            jr    $ra           # volta ao procedimento chamador
################################################################################
    
    
    

################################################################################
#void clear2 (int * array, int size){
#    int *p;
#    for(p=&array[0]; p<&array[size]; p=p+1) *p = 0;
#}
# Este procedimento zera os elementos de um vetor de inteiros.
# Argumentos
#   $a0 : endereço base do vetor
#   $a1 : número de elementos do vetor
################################################################################
clear2:                         # procedimento clear2
# prólogo
            # Obs.: Neste procedimento a variável local foi mantida no registrador
            # $t0. Não utilizamos a pilha para armazenar esta variável.
# corpo do programa
            move  $t0, $a0      # p = &array[0]
            sll   $t1, $a1, 2   # t1 <- size * 4
            add   $t2, $a0, $t1 # t2 <- &array[size]
loop2:
            sw    $zero, 0($t0) # memoria[p] = 0
            addi  $t0, $t0, 4   # p = p + 4
            slt   $t3, $t0, $t2 # t3 <-  (p<&array[size])?
            bne   $t3, $zero, loop2 # se t3=1 vá para loop2
fimClear2:
# epílogo
            jr    $ra           # retorna ao procedimento chamador
################################################################################




################################################################################
# Segmento de dados do programa. As variáveis vector1 e vector2 são variáveis 
# globais
################################################################################
.data
# int vetor1[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
# int vetor2[] = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10};
vector1:    .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
vector2:    .word -1, -2, -3, -4, -5, -6, -7, -8, -9, -10
################################################################################    
