# UFSM - CT - GMICRO
# Autor: Giovani Baratto (giovani.baratto@ufsm.br)
# Data: 05/07/2019
# Descrição: Este programa faz a leitura de um número e calcula
#            a sua raiz quadrada usando o método de Newton-Raphson
#            Para encontrarmos a raiz quadrada de um número Q, usamos o seguinte 
#            algoritmo, nas iterações n=0,1,2,3, ...
#            (a) fazemos x(n), com n=0, uma estimativa da raiz quadrada: x(0) = valor estimado
#            (b) para n = 0, 1, 2, ... realizamos as seguintes iterações
#                (b.1) x(n+1) = ( x(n) + Q/x(n) ) * 1/2
#                (b.2) verificamos se abs( x(n+1) - x(n) ) é menor ou igual a um erro
#                (b.3) se a condição b.2 é verdadeira, o valor da raiz quadrada é
#                      igual a x(n+1), com uma tolerância dada pelo valor de erro.
#                      Se a condição b.2 é falsa, fazemos n = n + 1 e repetimos uma
#                      nova iteração.
#   exemplo: Q = 10. Escolhemos um valor para x(0) = 5 e erro = 1e-10
#            x(1) = (x(0)+Q/x(0)) * 1/2 = (5 + 10/5) * 0,5 = 3,5
#            abs( 3,5 - 5) = 1,5. Como este valor é maior que o erro fazemos 
#            n=1 e repetimos.
#            x(2) = (x(1) + Q/x(1)) = (3,5+10/3,5) * 0,5 = 3,178571429
#            abs( 3,178571429-3,5) = 0,3214285714. Como este valor é maior que 
#            o erro fazemos n=1 e repetimos ...
#            O processo termina quando abs( x(n+1)-x(n) ) <= erro.
#            

.text

# diretiva que substitui a string printStringService pelo identificador 4
.eqv printStringService 4

# definição de uma macro
.macro imprimeString(%endString)
    la $a0, %endString
    li $v0, printStringService
    syscall
.end_macro

###############################################################################
# Neste procedimento, entramos pelo console com um número em ponto flutuante e
# calculamos pelo método de Newton-Rapson a sua raiz quadrada. Esta raiz é 
# apresentada no terminal

main:
#---------------------------------------------------------------
    jal     introducao          # explica resumidamente este programa
    jal     leiaNumeroPF        # Lê um número em ponto flutuante
    mov.d   $f12, $f0           # $f12 é o primeiro argumento para a função
                                # que calcula a raiz quadrada
    jal     calculaRaizQuadrada # Calcula o valor da raiz quadrada
    mov.d   $f12, $f0           # $f12 é o primeiro argumento de apresentaResultado
    jal     apresentaResultado  # Apresenta o valor da raiz quadrada
    j       terminaPrograma     # Termina a execução do programa
###############################################################################
    
###############################################################################
# imprime uma mensagem explicando a função do programa
introducao:
#---------------------------------------------------------------
    imprimeString(msg_introducao)
    jr         $ra
###############################################################################

###############################################################################
# imprime uma mensagem, pedindo a entrada de um número
# leia um numero em ponto flutuante no formato duplo
leiaNumeroPF:
#---------------------------------------------------------------
    imprimeString(msg_entreNumero)
    li      $v0, 7             # serviço para ler um número em ponto flutuante
    syscall                    # faz uma chamada ao sistema
    jr      $ra                # retorna em $f0 número em ponto flutuante, precisão dupla
###############################################################################
    
    
###############################################################################
# Calcula a raiz quadrada de um número
#
# entrada:  $f12:$f13 - número em precisão dupla Q. O procedimento encontrará a raiz quadrada
#                       deste número
# saída:    $f0:$f1   - raiz quadrada do número em $f12:$f13
# 
calculaRaizQuadrada:
#---------------------------------------------------------------
prologo:
corpo_procedimento:
    mov.d   $f0, $f12           # $f0 = x0 = Q
    la      $t0, const2         # $t0 <- endereço da constante 2.0
    ldc1    $f8, 0($t0)         # $f8 = constante 2.0
    # ou    l.d     $f8, const2     
    la      $t0, erro           # $t0 <- endereço da variável erro
    ldc1    $f10, 0($t0)        # $f10 = erro máximo entre iterações do método
    # ou l.d     $f10, erro           
loop:                           #
    mov.d   $f14, $f0           # $f14 = x_n
    div.d   $f6, $f12, $f0      # $f6 = Q/x_n
    add.d   $f0, $f6, $f0       # $f0 = x_n + Q/x_n
    div.d   $f0, $f0, $f8       # $f0 = (x_n+Q/x_n)/2 = x_n+1 
    sub.d   $f14, $f0, $f14     # $f14 = x_n+1 - x_n
    abs.d   $f14, $f14          # $f14 = |x_n+1 - x_n |
    c.le.d  $f14, $f10          # |x_n+1 - x_n |<= erro?
    bc1f    loop                # se falso, nova iteração
epilogo:                        #
    jr      $ra                 # retorna ao procedimento chamador
###############################################################################



###############################################################################    
# imprime o resultado
apresentaResultado:
#------------------------------------------------------------------------------
    imprimeString(msg)
    li      $v0,3               # serviço para imprimir o número em ponto flutuante em $f12:$f13
    syscall                     # chamada ao sistema
    jr      $ra                 # retorna ao procedimento chamador
###############################################################################



###############################################################################
# sai do programa
terminaPrograma:
#------------------------------------------------------------------------------
    li     $v0, 10              # serviço exit
    syscall                     # chamada ao sistema
###############################################################################
    
.data
const2:             .double 2.0  # constante 2.0, em ponto flutuante
erro:               .double 1e-9 # máximo erro da raiz entre duas iterações do algoritmo 
msg_introducao:     .ascii  "Este programa calcula a raiz quadrada de um número,\n"
                    .asciiz "usando o método de Newton-Raphson\n\n"
msg_entreNumero:    .asciiz "Entre com um número: "                    
msg:                .asciiz "Sua raiz quadrada é: "
    
    
