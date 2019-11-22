#*******************************************************************************
# exercicio071.s               Copyright (C) 2018 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Exemplo de procedimento que chama outros procedimentos
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    30.09.2019     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #






.data 

#  int a;             // variável global a
variavel_a: .word 0

.text
.globl      main


#  int main(void)
################################################################################            
main:
# Este é o procedimento principal do programa. Este procedimento chama o procedimento
# p1 com o argumento a = 2. O procedimento p1 chama o procedimento p2 que chama o procedimento
# p3. O procedimento p1 tem como retorno o argumento mais seis.
#
# Argumentos do procedimento:
# não há
#
# Mapa da pilha
# $sp + 0: variável local b
#
# Mapa dos registradores
# $a0: variavel_a ou 0
# $v0: variavel_a ou 17
# $t0: endereço de variavel_a
#
# Retorno do procedimento
# 
################################################################################
#  {
# prólogo do procedimento
#      int b;         // variável local b
            # ajustamos a pilha
            addiu   $sp, $sp, -4        # ajustamos a pilha para receber 1 item
# corpo do procedimento
#      a = 2;         // inicializamos a variável a com 2
            li      $a0, 2              # $a0 <- 2
            la      $t0, variavel_a + 0 # $t1 <- endereço da variavel_a
            sw      $a0, 0($t0)         # a = 2;
#      a = p1(a);     // chamamos o procedimento p1 com uma cópia da variável a, o valor 2
            # $a0 armazena uma cópia do valor da variavel_a
            jal     p1                  # chamamos o procedimento p1
            la      $t0, variavel_a + 0 # armazenamos o resultado do procedimento em variavel_a
            sw      $v0, 0($t0)         # a = p1(a)
#      b = a;         // atribuímos a variável local b o valor de a
            sw      $v0, 0($sp)         # b = a
#      // printf("b=%d\n", b);
# epílogo do procedimento
#      return 0;
            # vamos encerrar o programa. Em um programa compilado em C existem outros procedimentos
            # que são exercutados antes do programa ser terminado.
            li      $v0, 17             # serviço 17 - exit2 - termina o programa
            li      $a0, 0              # valor de retorno igual a 0: programa executado com sucesso
            syscall                     # chamada ao sistema, terminando a execução do programa
#  }

#  int p3(int* a)     // o argumento é um ponteiro para a (*a = 5)
################################################################################            
p3:
# Este procedimento soma três ao valor da variavel_a. A variavel_a é modificada.
#
# Argumentos do procedimento:
# $a0: o endereço para uma variável inteira a
#
# Mapa da pilha
# não usamos a pilha neste procedimento
#
# Mapa dos registradores
# $t0: variavel_a*
#
# Retorno do procedimento
# $v0: o valor da variavel_a + 3
################################################################################
#  {   
# prólogo do procedimento
# Este é um procedimento folha. Não é necessário armazenar o valor do endereço de
# retorno. Neste procedimento são precisamos guardar o valor de registradores e
# não existem variáveis locais. Neste caso, o quadro para este procedimento será
# vazio. Não é necessário utilizar a pilha
# corpo do procedimento
#      *a = *a + 3;   // somamos 3 ao valor de a (a = 8)
            # carregamos o valor de a
            lw      $t0, 0($a0)     # $t0 <- valor da variavel_a <- endereço de variavel_a
            # realizamos a operação com o valor de a
            addi    $v0, $t0, 3     # $v0 <- *a + 3
            # atualizamos o valor da variável a
            sw      $v0, 0($a0)     # armazenamos $t0 no endereço da variavel_a
# epílogo do procedimento
#      return *a;     // retornamos o valor 8 
            jr      $ra             # retornamos ao procedimento chamador, com *a + 3 em $v0
#  }
#-------------------------------------------------------------------------------




#  int p2(int a)      // a = 3
################################################################################            
p2:
# Este procedimento soma 2 ao argumento e chama o procedimento p3 com este valor.
# Este código pode ser otimizado. Por exemplo, a variável tmp poderia ser mantida
# somente em um registrador.
#
# Argumentos do procedimento:
# $a0: um valor inteiro a
#
# Mapa da pilha
# $sp + 8: endereço de retorno $ra 
# $sp + 4: registrador $s0
# $sp + 0: variável local tmp
#
# Mapa dos registradores
# $s0: tmp*
#
# Retorno do procedimento
# $v0: retornamos a + 2 + p3(a) = a + 5
################################################################################
#  {
#      int tmp;       // variável local tmp
# prólogo do procedimento
            # criamos o quadro do procedimento
            # ajustamos a pilha e salvamos os valores dos registradores e variáveis locais
            addiu   $sp, $sp, -12   # ajustamos a pilha para receber 3 itens
            sw      $ra, 8($sp)     # armazenamos na pilha (memória) o endereço de retorno
            sw      $s0, 4($sp)     # armazenamos na pilha o conteúdo do registrador $s0
            # a variável tmp está no endereço $sp + 0. Ela não é inicializada com um valor
# corpo do procedimento
#      tmp = a + 2;   // tmp = 5
            addi    $s0, $a0, 2     # $s0 (tmp*) <- a + 2
            sw      $s0, 0($sp)     # atualizamos a variável tmp
#      p3(&tmp);      // chamamos p3 com o endereço de tmp (ponteiro para tmp)
            la      $a0, 0($sp)     # carregamos em $a0 o endereço de tmp: $sp + 0
            jal     p3              # chamamos o procedimento p3           
# epílogo do procedimento             
#      return tmp                   # 
            # após o retorno do procedimento p3, o registrador $s0 continua com uma cópia de tmp,
            # no entanto, o valor de tmp foi alterado por p3. Mesmo que este registrador não tenha
            # sido modificado por p3, neste caso, não podemos usar o valor de $s0 como valor de 
            # retorno. Temos que fazer novamente uma leitura na memória da variável local tmp.
            lw      $v0, 0($sp)     # $v0 <- tmp, retornamos com o valor de tmp
            # restauramos os valores originais dos registradores salvos
            lw      $s0, 4($sp)     # restauramos $s0
            lw      $ra, 8($sp)     # restauramos o endereço de retorno $ra
            # destruímos o quadro deste procedimento
            addiu   $sp, $sp, 12    # restauramos a pilha com o valor original. 
            jr      $ra             # retornamos ao procedimento chamador
#  }
#------------------------------------------------------------------------------- 
 
 
#  int p1(int a)      // a = 2
################################################################################            
p1:
# Este procedimento soma um ao argumento e chama um procedimento p2 com este valor.
# Este código pode ser otimizado. Por exemplo, a variável tmp poderia ser mantida
# somente em um registrador.
#
# Argumentos do procedimento:
# $a0: um valor inteiro a
#
# Mapa da pilha
# $sp + 4: endereço de retorno $ra 
# $sp + 0: variável local tmp
#
# Mapa dos registradores
# $t0: tmp*
#
# Retorno do procedimento
# $v0: retornamos a + 2 + p2(a) = a + 6
################################################################################
#  {
# prólogo do procedimento
#      int tmp;       // variável local tmp
            # ajustamos a pilha
            addiu   $sp, $sp, -8    # ajustamos a pilha para 2 itens
            sw      $ra, 4($sp)     # armazenamos na pilha o endereço de retorno
            # em $sp + 0 temos 4 bytes para o inteiro tmp. Esta variável não é inicializada.
# corpo do procedimento 
#      tmp = a + 1;   // tmp = 3
            addiu   $t0, $a0, 1     # $t0 (tmp*) <- a + 1
            sw      $t0, 0($sp)     # atualizamos a variável tmp
#      tmp = p2(tmp); // chamamos p2 com uma cópia de tmp (tmp=3)
            move    $a0, $t0        # $a0 <- valor de tmp
            jal     p2              # chamamos o procedimento p2
            sw      $v0, 0($sp)     # tmp <- p2(tmp)
# epílogo do procedimento            
#      return tmp;
            # $v0 já possui uma cópia atualizada de tmp. Não é necessário fazer 
            # uma leitura da memória
            # restauramos a pilha
            lw      $ra, 4($sp)     # restauramos o endereço de retorno
            addiu   $sp, $sp, 8     # restauramos a pilha
            jr      $ra             # retornamos ao procedimento chamador
#  }
#-------------------------------------------------------------------------------





