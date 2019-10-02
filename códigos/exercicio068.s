#*******************************************************************************
# exercicio068.s               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Este programa lê um arquivo e imprime os caracteres em um terminal. 
#            Reescrevemos o exemplo 67 usando processos e a diretiva eqv.
# Documentação:
# Assembler: MARS
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    06.05.2019     GBTO   versão inicial 
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O             #

################################################################################
# Constantes usadas no programa
################################################################################

.eqv        servico_imprime_string      4
.eqv        servico_imprime_caracter    11
.eqv        servico_abre_arquivo        13
.eqv        servico_leia_arquivo        14
.eqv        servico_fecha_arquivo       16
.eqv        servico_termina_programa    17

.eqv        sucesso                     0
.eqv        erro_abertura_arquivo       0x00000001
.eqv        erro_leitura_arquivo        0x00000002

################################################################################
# segmento de texto (programa)
.text
################################################################################


################################################################################
# O procedimento principal. Lemos um arquivo e imprimimos cada um de seus caracteres
# entre parênteses.
#-------------------------------------------------------------------------------
# Argumentos
#   Não existem argumentos de entrada
# valor de retorno
#   O programa irá retornar o valor 0 para indicar sucesso na execução ou um valor
#   diferente de 0, se houve algum erro na execução do programa
main:
################################################################################ 
# abrimos o arquivo para leitura
            # carregamos os argumentos do procedimento abre_arquivo_leitura
            la    $a0, nome_arquivo # $a0 <- nome do programa que será lido
            la    $a1, descritor_arquivo # $a1 <- endereço onde será armazenado o descritor do arquivo
            jal   abre_arquivo_leitura  # abre o arquivo para leitura    
# lemos o arquivo e imprimimos os caracteres entre parênteses            
leia_arquivo:
            # carregamos os argumentos do procedimento leia_caracteres_para_buffer
            la    $t0, descritor_arquivo # $t0 <- endereço do descritor do arquivo
            lw    $a0, 0($t0)   # $a0 <- o valor do descritor do arquivo
            la    $a1, buffer   # $a1 <- endereço do buffer que guarda os carcateres lidos
            li    $a2, 255      # $a2 <- número máximo de carcateres lidos
            jal   leia_bytes_para_buffer # leia bytes do arquivo para um buffer
            # se chegou ao final do arquivo de leitura, feche o arquivo e termine
            # o programa, senão, imprime o conteúdo do buffer
            beq   $v0, $zero, fim_leitura_arquivo # a leitura do arquivo terminou
            # Imprime os bytes do buffer
            move  $a0, $v0      # $a0 <- número de bytes do buffer
            la    $a1, buffer   # $a1 <- endereço do buffer
            jal   imprime_bytes_buffer_entre_parenteses # imprime os caracteres do buffer entre parênteses.
            j     leia_arquivo  # leia e imprima os próximos caracteres
fim_leitura_arquivo:
# Fechamos o arquivo
            # carregamos o argumento do procedimento fecha_arquivo
            la    $t0, descritor_arquivo # $t0 <- endereço da variável com o descritor do arquivo
            lw    $a0, 0($t0)   # carregamos em $a0 o valor do descritor do arquivo
            jal   fecha_arquivo # chamamos o procedimento fecha_arquivo
            # Carregamos o argumento do procedimento termina_programa
            li    $a0, sucesso  # carregamos em $a0 o valor 0 para indicar que o programa foi executado com sucesso
# Terminamos o programa            
            j     termina_programa # terminamos o programa
################################################################################
    
    
    
    
################################################################################
# Procedimento para fechar um arquivo
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 : Descritor do arquivo
# Retorno:
#         O procedimento não retorna valores
fecha_arquivo:
################################################################################
# prólogo
# corpo do programa
            li    $v0, servico_fecha_arquivo       # serviço 16: fecha um arquivo
            syscall             # fechamos o arquivo  
# epílogo
            jr    $ra           # retornamos ao procedimento chamador
################################################################################



    
################################################################################
# Procedimento para abrir um arquivo para leitura
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 : endereço da string com o nome do arquivo a ser aberto
#   $a1 : endereço da variável onde será armazenado o descritor do arquivo (4 bytes)
# Retorno:
#   $v0 : o descritor do arquivo. Um descritor negativo sinaliza que o arquivo 
#         não pode ser aberto.
#   Mapa da pilha:
#   $sp + 0 : $a1 <- endereço da variável que armazena o descritor do arquivo aberto
abre_arquivo_leitura:            
################################################################################ 
# prólogo
            addiu $sp, $sp, -4  # será adicionado um elemento na pilha
            sw    $a1, 0($sp)   # guardamos na pilha o endereço da variável descritor do arquivo
# corpo do procedimento
# abrimos o arquivo para a leitura
            li    $v0, servico_abre_arquivo # serviço 13: abre um arquivo
            la    $a0, nome_arquivo # $a0 <- endereço da string com o nome do arquivo
            li    $a1, 0        # $a1 <- 0: arquivo será aberto para leitura
            li    $a2, 0        # modo não é usado. Use o valor 0.
            syscall             # abre o arquivo
# guardamos o descritor do arquivo em descritor_arquivo
            lw    $a1, 0($sp)   # carregamos o endereço da variável com o descritor do arquivo
            sw    $v0, 0($a1)   # armazenamos o descritor do arquivo em descritor_arquivo
            slt   $t0, $v0, $zero # $t0 = 1 se $v0 < 0 ($v0 negativo)
            bne   $t0, $zero, arquivo_nao_pode_ser_aberto # se $v0 é negativo, o arquivo não pode ser aberto
            j     arquivo_aberto
arquivo_nao_pode_ser_aberto:
            li    $v0, servico_imprime_string        # serviço 4: imprime uma string
            la    $a0, str_arquivo_nao_pode_ser_aberto # $a0 armazena o endereço da string a ser apresentada
            syscall             # apresenta a string
            li    $a0, erro_abertura_arquivo # $a0 diferente de zero, indicando que o programa terminou com erros
            j     termina_programa # termina o programa
arquivo_aberto:
            li    $v0, servico_imprime_string       # serviço 4: imprime uma string
            la    $a0, str_arquivo_aberto           # $a0 possui o endereço da string a ser apresentada
            syscall             # apresenta a string
fim_abre_arquivo_leitura:
# epílogo
            addiu $sp, $sp, 4   # restauramos a pilha  
            jr    $ra           # retornamos ao procedimento chamador       
################################################################################            



################################################################################
# Faz a leitura do arquivo para um buffer na memória
# argumentos
#   $a0 : valor do descritor do arquivo
#   $a1 : endereço do buffer que armazena temporariamente os bytes lidos do arquivo
#   $a2 : número máximo de caracteres lidos
# retorno
#   $v0 : número de bytes lidos. O valor será 0 se chegou ao final do arquivo.
#         Se houve um erro de leitura, o valor será negativo e o programa abortado.
#   mapa da pilha
#   SP + 0 : $v0, o número de bytes lidos do arquivo
leia_bytes_para_buffer:
################################################################################
# prólogo
            addiu $sp, $sp, -4  # reservamos na pilha um espaço para um itens
# corpo do procedimento
# lemos o arquivo até preencher o buffer
leia_caracteres_arquivo:
            li    $v0, servico_leia_arquivo # serviço 14: leitura do arquivo
            syscall             # fazemos a leitura de caracteres do arquivo para o buffer
            sw    $v0, 0($sp)   # guardamos na pilha o número de caracteres lidos.
            # verificamos se houve um erro de leitura
            slt   $t0, $v0, $zero # $t0 = 1 se $v0 < 0 (erro de leitura)
            bne   $t0, $zero, erro_leitura # se $t0=1 desvie para erro de leitura
            # verificamos se chegamos ao final do arquivo
            beq   $v0, $zero, fim_arquivo # se $v0 = 0 chegamos ao final do arquivo
            j     fim_leia_bytes_buffer
            
            # imprime uma mensagem indicando que houve erro na leitura do arquivo e fecha o arquivo 
erro_leitura:
            li    $v0, servico_imprime_string # serviço 4: imprime uma string
            la    $a0, str_erro_leitura # $a0 guarda o endereço da string a ser apresentada
            syscall             # apresentamos a string no terminal
            li    $a0, erro_leitura_arquivo # $a0 diferente de zero, indicando que o programa terminou com erros
            j     termina_programa # termina o programa

            # imprime uma mensagem dizendo que foi encontrado o fim do arquivo.            
fim_arquivo:
            li    $v0, servico_imprime_string # serviço 4: imprime uma string
            la    $a0, str_fim_arquivo # $a0 armazena o endereço da string a ser apresentada
            syscall             # apresenta a string 
# epílogo   
fim_leia_bytes_buffer:
            lw    $v0, 0($sp)   # restauramos o número de caracteres lidos no arquivo
            addiu $sp, $sp, 4   # restauramos a pilha 
            jr    $ra           # retornamos ao procedimento chamador
################################################################################



################################################################################
# Imprime os bytes do buffer entre parênteses
#-------------------------------------------------------------------------------
# argumentos
#   $a0 : número de caracteres do buffer
#   $a1 : endereço do buffer
# retorno
#         não existem valores de retorno
# mapa da pilha
#   $sp + 0  : $a0, o número de caracteres lidos
imprime_bytes_buffer_entre_parenteses:
################################################################################
# prólogo
            addiu $sp, $sp, -4 # na pilha serão armazenados 3 itens
            sw    $a0, 0($sp)   # armazenamos $a0 em $sp + 0
# corpo do procedimento
imprime_buffer:
            # imprime parêntese da esquerda
            li    $v0, servico_imprime_caracter # serviço 11: imprime o caracter em $a0
            li    $a0, '('      # $a0 <- caractere parêtese da esquerda
            syscall             # imprime o caractere parêntese da esquerda
            # imprime caractere do buffer
            li    $v0, servico_imprime_caracter # serviço 11: imprime o caractere em $a0
            lbu   $a0, 0($a1)   # carregamos o caractere do buffer para $a0
            syscall             # imprimimos o caractere do buffer
            # imprime caractere da direita
            li    $v0, servico_imprime_caracter # serviço 11: imprime o caracter em $a0
            li    $a0, ')'      # $a0 <- caractere parêntese da direita
            syscall             # imprime o caractere parêntese da direita
            # decrementa o número de caracteres do buffer
            lw    $a0, 0($sp)   # Recuperamos da pilha o número de caracteres do buffer
            addi  $a0, $a0, -1  # decrementa o número de caracteres do buffer
            sw    $a0, 0($sp)   # atualizamos o número de caracteres do buffer na pilha
            addi  $a1, $a1, 1   # aponta para o próximo caracter do buffer
            bne   $a0, $zero, imprime_buffer # se restam caracteres no buffer, imprima
fim_impressao_caracteres:
# epílogo
            addiu $sp, $sp, 4  # restaura a pilha
            jr    $ra           # retorna ao procedimento chamador
            
################################################################################
  
  
  
################################################################################
# Imprime uma mensagem dizendo que o programa terminou e termina o programa
#-------------------------------------------------------------------------------
# argumento
#   $a0 : Código de retorno do procedimento: 0 se o programa foi executado com 
#         sucesso ou um valor diferente de 0, indicando que ocorreu erros na 
#         execução do programa
# retorno
#         Este programa não retorna valores
termina_programa:
################################################################################
# prólogo
# corpo do procedimento
            li    $v0,servico_imprime_string # serviço 4: imprime uma string
            la    $a0, str_fim_do_programa # $a0 <- endereço da string a ser apresentada
            syscall             # apresenta a string
# epílogo             
            li    $v0, servico_termina_programa # serviço 17: termina o programa
            syscall             # termina o programa
################################################################################    



################################################################################
# segmento de dados
.data
################################################################################

buffer:           .space 256    # criamos um buffer com 256 bytes. 
descritor_arquivo: .space 4     # descritor do arquivo
nome_arquivo:     .asciiz "exercicio067.s" # nome do arquivo a ser aberto

# strings usadas no programa
str_erro_leitura: .asciiz "\n=== O arquivo não pode ser lido ===\n"
str_fim_arquivo:  .asciiz "\n=== O final do arquivo foi encontrado ===\n"
str_arquivo_aberto: .asciiz "\n=== Arquivo aberto ===\n"
str_arquivo_nao_pode_ser_aberto: .asciiz "\n=== O arquivo não pode ser aberto ==\n"
str_fim_do_programa: .asciiz "\n=== Fim do programa ===\n"
################################################################################





