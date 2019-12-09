#*******************************************************************************
#
# Autores: Bruno Frizzo e Felipe Cechin
# Para o keyboard, usamos os seguintes registradores
# RCR - receiver control register    | 0xFFFF0000
# RDR - receiver data register       | 0xFFFF0004
#
# Para o display temos os seguintes registradores
# TCR - transmitter control register | 0xFFFF0008
# TDR - transmitter data register    | 0xFFFF000C

# Documentacao:
# Assembler: MARS
#*******************************************************************************
#        1         2         3         4         5         6         7         8
#2345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M     O                 #


################################################################################
# Constantes usadas no programa
################################################################################
.eqv servico_abre_arquivo  13
.eqv servico_leia_arquivo  14
.eqv servico_fecha_arquivo 16

################################################################################
# segmento de dados
.data
    linha_comando: .space 80 #vetor criado para armazenar o comando digitado
    instrucoes: .space 400 #vetor criado para armazenar as instrucoes do arquivo text.bin
    dados: .space 400 #vetor criado para armazenar os dados do arquivo data.bin
    pilha: .space 800 #vetor criado para a pilha
    registradores: .space 128 #vetor criado para armazenar os registradores - 32 registradores
    instrucoes_pc: .space 4 #armazena o pc do simulador
    instrucoes_ir: .space 4 #armazena o ir do simulador
    buffer: .space 256 #espaco de memoria utilizado no procedimento palavra
    buffer_int_to_string: .space 256 #buffer para armazenar string convertida de um inteiro
    descritor_arquivo: .space 4 # descritor do arquivo
    campo_op: .space 4 #espaco para armezenar o campo op
    campo_rs: .space 4 #espaco para armezenar o campo rs
    campo_rt: .space 4 #espaco para armezenar o campo rt
    campo_rd: .space 4 #espaco para armezenar o campo rd
    campo_shamt: .space 4 #espaco para armezenar o campo shamt
    campo_funct: .space 4 #espaco para armezenar o campo funct
    campo_imm: .space 4 #espaco para armezenar o campo immediate
    campo_end_alvo: .space 4 #espaco para armezenar o campo endereco alvo
    fim_programa: .word 0 #palavra usada para indicar se todas as instrucoes carregadas foram executadas. Se 1, o programa executou todas as instrucoes

    #strings armazenadas para o programa
    str_comando_nao_encontrado: .asciiz "\n== Comando nao encontrado ==\n"
    str_arquivo_aberto: .asciiz "\n== Arquivo aberto ==\n"
    str_arquivo_lido: .asciiz "\n== Arquivo carregado para a memoria ==\n"
    str_arquivo_nao_pode_ser_aberto: .asciiz "\n== O arquivo nao pode ser aberto ==\n"
    str_erro_leitura: .asciiz "\n== O arquivo nao pode ser lido ==\n"
    str_explicacao_comando_m: .asciiz "\n== Erro no comando m ==\n== O comando m apresenta o conteudo da memoria. Possui dois parametros: ==\n== Parametro 1: endereco de memoria inicial em base hexadecimal ==\n== O endereco pode ter letras (A,B,C,D,E,F) somente em maiusculo ==\n== O parametro deve ter no maximo 10 caracteres, comecando com 0x ==\n== Parametro 2: numero de enderecos a partir do endereco inicial ==\n== Exemplo: m 0x100100A0 10 ==\n"
    str_faixa_endereco_comando_m1: .asciiz "\n== Digite um endereco multiplo de 4 entre "
    str_faixa_endereco_comando_m2: .asciiz " e "
    str_faixa_endereco_comando_m3: .asciiz " ==\n"
    str_faixa_endereco_comando_fim1: .asciiz "\n== Atingiu o fim dos enderecos disponiveis ==\n== Ultimo endereco disponivel: "
    str_faixa_endereco_comando_fim2: .asciiz " ==\n"
    str_comando_r_erro1: "\n== Carregue o arquivo de instrucoes com o comando lt ==\n"
    str_comando_r_erro2: "\n== Carregue o arquivo de dados com o comando ld ==\n"
    str_comando_r_msg1: "\n== "
    str_comando_r_msg2: " instrucao(oes) executada(s) ==\n"
    str_comando_r_msg_fim: "== Todas as instrucoes carregadas foram executadas ==\n"
    str_endereco_instrucoes1: "\n== A memoria de instrucoes inicia no endereco "
    str_endereco_instrucoes2: " e tem o tamanho de 100 palavras ==\n"
    str_endereco_dados1: "\n== A memoria de dados inicia no endereco "
    str_endereco_dados2: " e tem o tamanho de 100 palavras ==\n"
    str_endereco_pilha1: "\n== A pilha inicia no endereco "
    str_endereco_pilha2: " e tem o tamanho de 200 palavras ==\n"
    str_programa_finalizado: "\n== O simulador foi finalizado ==\n"
    str_pc: "PC: "
    str_ir: "IR: "
    delim: .asciiz " \t\n,"
    comando_lt: .asciiz "lt"
    comando_ld: .asciiz "ld"
    comando_r: .asciiz "r"
    comando_d: .asciiz "d"
    comando_m: .asciiz "m"
    str_enter: .asciiz "\n"

################################################################################
# segmento de texto (programa)
.globl main
.text

################################################################################
# O procedimento principal main
#-------------------------------------------------------------------------------
# Argumentos
#   Nao existem argumentos de entrada
# valor de retorno
#   O procedimento finaliza a execucao do programa, retornando em $v0 o valor 10
# Mapa da pilha:
#   $sp + 0: $s0
main:
    #prologo
    addiu $sp, $sp, -4
    sw $s0, 0($sp)

    #corpo
    #primeiro, armazenamos o valor do endereco de memoria de pilha+800 no registrador 29, que representa a pilha
    la $a0, registradores # $a0 <- endereco de registradores
    li $a1, 29 # $a1 <- 29
    la $a2, pilha+800 # $a2 <- endereco de pilha + 800, pois a pilha comeca no maior endereco
    jal escreve_registrador 
    
    
    jal imprime_informacoes_memoria #chama o procedimento para imprimir informacoes de memoria na tela
    main_loop: 
        la $a0, linha_comando # $a0 <- endereco de linha_comando
        li $a1, 80 # $a1 <- 80
        jal limpa_vetor #limpa o vetor colocando os valores como 0 caso tenha alguma letra
        la $a0, linha_comando # $a0 <- endereco de linha_comando
        jal leia_linha #le linha do terminal
        la $a0, linha_comando #a0 <- endereco de linha_comando
        jal imprime_linha #imprime linha no display
        li $a0, 10
        jal imprime_display
        la $a0, linha_comando #a0 <- endereco de linha_comando
        li $a1, 1 #$a1 contem o indice da palavra digitada no comando, se for 1 retorna primeira palavra do comando digitado
        jal palavra #armazena em $v1 a palavra
        beqz $v1, main_loop #se $v1 for 0, nao digitou nenhuma palavra, entao le novamente a linha
        add $a0, $v1, $zero #$a0 contem a primeira palavra do comando
        jal verifica_comando #verifica qual comando a primeira palavra representa
        beqz $v0, main_imprime_mensagem_erro #se nao for um comando, imprime a mensagem de erro
        j main_imprime_mensagem_erro_continua #e' um comando, entao continua 
        main_imprime_mensagem_erro:
            la $a0, str_comando_nao_encontrado #$a0 <- str_comando_nao_encontrado
            jal imprime_linha
            j main_loop
        main_imprime_mensagem_erro_continua:
            #$v0 e' um comando
            #$v0 = 1 comando lt
            #$v0 = 2 comando ld
            #$v0 = 3 comando r
            #$v0 = 4 comando d
            #$v0 = 5 comando m
            la $a0, linha_comando # $a0 <- endereco de linha_comando
            add $a1, $v0, $zero # $a1 <- comando armazenado em $v0
            jal executa_comando # executa o comando armazenado em $a1
            lw $s0, fim_programa # carrega o valor de fim_programa em $s0
            bnez $s0, main_fim # se nao for zero, entao finaliza o simulador
            j main_loop #le a proxima linha
    
    
    # epilogo  
    main_fim:
        la $a0, str_programa_finalizado # $a0 <- endereco da string
        jal imprime_linha # imprime string no display
        #ajusta a pilha
        lw $s0, 0($sp)
        addiu $sp, $sp, 4
        li $v0, 10 # servico 10 - exit
        syscall

################################################################################
# Procedimento para imprimir informacoes de memoria no display
# ------------------------------------------------------------------------------
# argumentos:
#   Sem argumentos
# Retorno:
#   O procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $ra <- endereco de memoria de uma instrucao para retorno
imprime_informacoes_memoria:
    #prologo
    addiu $sp, $sp, -4 #ajusta a pilha
    sw $ra, 0($sp) #salva o valor de $ra em $sp
    
    #corpo
    la $a0, str_endereco_instrucoes1 # $a0 <- endereco de str_endereco_instrucoes1
    jal imprime_linha #imprime "\n== A memoria de instrucoes inicia no endereco " no display
    la $a0, instrucoes # $a0 <- endereco de instrucoes
    jal imprime_hexadecimal #imprimir valor hexadecimal da variavel instrucoes no display
    la $a0, str_endereco_instrucoes2  # $a0 <- endereco de str_endereco_instrucoes2
    jal imprime_linha #imprime " e tem o tamanho de 100 palavras ==\n" no display
    
    la $a0, str_endereco_dados1 # $a0 <- endereco de str_endereco_dados1
    jal imprime_linha # imprime "\n== A memoria de dados inicia no endereco " no display
    la $a0, dados # $a0 <- endereco de dados
    jal imprime_hexadecimal  #imprimir valor hexadecimal da variavel dados no display
    la $a0, str_endereco_dados2 # $a0 <- endereco de str_endereco_dados2
    jal imprime_linha #imprime " e tem o tamanho de 100 palavras ==\n" no display
    
    la $a0, str_endereco_pilha1 #$a0 <- endereco de str_endereco_pilha1
    jal imprime_linha #imprime "\n== A pilha inicia no endereco " no display
    la $a0, pilha # $a0 <- endereco de pilha
    jal imprime_hexadecimal #imprimir valor hexadecimal da variavel pilha no display
    la $a0, str_endereco_pilha2  #$a0 <- endereco de str_endereco_pilha2
    jal imprime_linha #imprime " e tem o tamanho de 200 palavras ==\n" no display

    #epilogo
    lw $ra, 0($sp) #recupera o valor de $ra
    addiu $sp, $sp, 4 #ajusta a pilha
    jr $ra

################################################################################
# Procedimento para executar o comando digitado no keyboard
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
#   $a1 = numero inteiro que indica o tipo do comando digitado no keyboard
# Retorno:
#   O procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra <- endereco de memoria de uma instrucao para retorno 
executa_comando:
    #prologo
    addiu $sp, $sp, -16 #ajusta a pilha
    sw $s0, 0($sp) #salva o valor de $s0 em $sp
    sw $s1, 4($sp) #salva o valor de $s1 em $sp + 4
    sw $s2, 8($sp) #salva o valor de $s2 em $sp + 8
    sw $ra, 12($sp) #salva o valor de $ra em $sp + 12
    
    #corpo
    add $s0, $a0, $zero #$s0 contem a linha de comando
    add $s1, $a1, $zero #$s1 contem o tipo do comando
    
    #$s1 = 1 comando lt
    #$s1 = 2 comando ld
    #$s1 = 3 comando r
    #$s1 = 4 comando d
    #$s1 = 5 comando m
    beq $s1, 5, executa_comando_m #se $s1 = 5, executa comando m
    beq $s1, 4, executa_comando_d #se $s1 = 4, executa comando d
    beq $s1, 3, executa_comando_r #se $s1 = 3, executa comando r
    beq $s1, 2, executa_comando_ldlt #se $s1 = 2, executa comando ldlt
    beq $s1, 1, executa_comando_ldlt #se $s1 = 1, executa comando ldlt
    j executa_comando_fim #pula para o fim para ajustar a pilha
    executa_comando_d:
        add $a0, $s0, $zero # $a0 <- linha de comando
        jal verifica_parametros_comando_d #verifica se tem parametro no comando
        beqz $v0, executa_comando_erro #se $v0 = 0, retorna erro
        jal imprime_registradores #imprime todos registradores no display
        j executa_comando_fim #pula para ajustar a pilha
    executa_comando_r:
        add $a0, $s0, $zero # $a0 <- linha de comando
        jal verifica_parametros_comando_r # verifica parametros do comando r
        beqz $v0, executa_comando_erro # se $v0 for 0, erro
        add $a0, $s0, $zero # $a0 <- linha de comando
        jal executa_r # executa comando r
        j executa_comando_fim
    executa_comando_m:
        add $a0, $s0, $zero # $a0 <- linha de comando
        jal verifica_parametros_comando_m # verifica parametros do comando m
        beqz $v0, executa_comando_erro_mensagem_m # se $v0 for 0, erro
        add $a0, $s0, $zero # $a0 <- linha de comando
        jal executa_m # executa comando m
        j executa_comando_fim
    executa_comando_ldlt:
        add $a0, $s0, $zero # $a0 <- linha de comando
        jal verifica_parametros_comando_ldlt # verifica parametros do comando ld ou lt, pois sao comandos parecidos
        beqz $v0, executa_comando_erro # se $v0 for 0, erro
        beq $s1, 1, executa_comando_ldlt_lt # se $s1 for 1, comando lt
        beq $s1, 2, executa_comando_ldlt_ld # se $s1 for 2, comando ld
        j executa_comando_fim
        executa_comando_ldlt_lt:
            add $a0, $s0, $zero # $a0 <- linha de comando
            li $a1, 2 # $a1 <- busca a segunda palavra da string
            jal palavra #armazena em $v1 a segunda palavra
            add $a0, $v1, $zero # $a0 <- segunda palavra da linha de comando
            jal executa_lt # executa lt
            j executa_comando_fim
        executa_comando_ldlt_ld: 
            add $a0, $s0, $zero # $a0 <- linha de comando
            li $a1, 2 # $a1 <- busca a segunda palavra da string
            jal palavra #armazena em $v1 a segunda palavra
            add $a0, $v1, $zero # $a0 <- segunda palavra da linha de comando
            jal executa_ld # executa ld
            j executa_comando_fim
    executa_comando_erro_mensagem_m:
        la $a0, str_explicacao_comando_m # string de explicacao do comando m
        jal imprime_linha # imprime a string
        j executa_comando_fim
    executa_comando_erro:
        la $a0, str_comando_nao_encontrado
        jal imprime_linha
    
    #epilogo
    executa_comando_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $ra, 12($sp)
        addiu $sp, $sp, 16
        jr $ra

################################################################################
# Procedimento para verificar os parametros do comando d
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
# Retorno:
#   $v0 = 1 se parametros estao corretos e 0 se parametros estao incorretos
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $ra <- endereco de memoria de uma instrucao para retorno 
verifica_parametros_comando_d:
    #prologo
    addiu $sp, $sp, -8 # ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $ra, 4($sp) #salva $ra na pilha
    
    #corpo 
    add $s0, $a0, $zero # $s0 <- $a0
    add $a0, $s0, $zero # $a0 <- $s0
    li $a1, 2 # $a1 <- 2
    jal palavra #le segunda palavra
    bnez $v1, verifica_parametros_comando_d_erro #retorna 0 se for diferente de zero
    li $v0, 1 # $v0 <- 1
    j verifica_parametros_comando_d_fim #salta para ajustar a pilha
    verifica_parametros_comando_d_erro:
        li $v0, 0 # $v0 <- 0
        
    #epilogo
    verifica_parametros_comando_d_fim:
        lw $s0, 0($sp) #$s0 <- valor anterior de $s0
        lw $ra, 4($sp) #$ra <- valor anterior de $ra
        addiu $sp, $sp, 8 #ajusta a pilha novamente
        jr $ra #retorna onde o procedimento foi chamado

################################################################################
# Procedimento para executar o comando r
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
# Retorno:
#   O procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra <- endereco de memoria de uma instrucao para retorno 
executa_r:
    #prologo
    addiu $sp, $sp, -20 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $s1, 4($sp) #salva $s1 na pilha
    sw $s2, 8($sp) #salva $s2 na pilha
    sw $s3, 12($sp) #salva $s3 na pilha
    sw $ra, 16($sp) #salva $ra na pilha
    
    #corpo 
    add $s0, $a0, $zero #$s0 contem a linha de comando
    add $a0, $s0, $zero # $a0 <- $s0
    li $a1, 2 #$a1 <- 2
    jal palavra #armazena em $v1 a segunda palavra
    add $s0, $v1, $zero # $s0 <- segunda palavra
    add $a0, $s0, $zero # $a0 <- segunda palavra
    jal str_to_int_decimal # $converte $a0 para inteiro decimal
    add $s1, $v0, $zero # $s1 <- $v0
    lw $s2, instrucoes_pc # $s1 <- carrega o valor do PC do simulador
    beqz $s2, executa_r_erro1 #se PC = 0, imprime mensagem de erro
    lw $s2, dados # $s2 <- carrega o valor da variavel dados
    beqz $s2, executa_r_erro2 #se $s2 = 0, imprime mensagem de erro
    li $s2, 0 # $s2 <- 0
    executa_r_loop:
        lw $s3, fim_programa # $s3 <- valor de fim_programa
        bnez $s3, executa_r_mensagem # se $s3 for diferente de 0, imprime mensagem
        beq $s2, $s1, executa_r_mensagem # todas instrucoes foram executadas, imprime mensagem
        jal busca_instrucao
        jal decodifica_instrucao
        jal executa_instrucao
        addi $s2, $s2, 1
        j executa_r_loop
    
    
    executa_r_erro1:
        la $a0, str_comando_r_erro1 # $a0 <- endereco de str_comando_r_erro1
        jal imprime_linha #imprime "\n== Carregue o arquivo de instrucoes com o comando lt ==\n"
        j executa_r_fim #pula para ajustar a pilha
    executa_r_erro2:
        la $a0, str_comando_r_erro2 # $a0 <- endereco de str_comando_r_erro2
        jal imprime_linha #imprime "\n== Carregue o arquivo de dados com o comando ld ==\n"
        j executa_r_fim #pula para ajustar a pilha

    executa_r_mensagem:
        la $a0, str_comando_r_msg1 # $a0 <- endereco da string
        jal imprime_linha
        add $a0, $s2, $zero # $a0 <- $s2 = numero inteiro que contem o numero de instrucoes executadas
        la $a1, buffer_int_to_string # $a1 <- espaco de memoria usado para armazenar a string transformada do numero inteiro
        jal int_to_string #chama o procedimento para transformar um inteiro em string
        la $a0, buffer_int_to_string # $a0 <- endereco de memoria da string a ser impressa no display
        jal imprime_linha #chama o procedimento para imprimir uma string no display
        la $a0, str_comando_r_msg2 # $a0 <- endereco de memoria da string a ser impressa no display
        jal imprime_linha #chama o procedimento para imprimir uma string no display
        lw $s3, fim_programa # $s3 <- carrega o valor de fim_programa
        bnez $s3, executa_r_mensagem_fim_execucoes # se $s3 for diferente de 0, programa executou todas as instrucoes
        j executa_r_fim
        executa_r_mensagem_fim_execucoes:
            la $a0, str_comando_r_msg_fim # $a0 <- endereco de memoria da string a ser impressa no display
            jal imprime_linha #chama o procedimento para imprimir uma string no display

    #epilogo
    executa_r_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)  
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $ra, 16($sp)
        addiu $sp, $sp, 20
        jr $ra
        

################################################################################
# Procedimento para escrever uma palavra em um registrador do simulador
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco base de memoria do vetor registradores
#   $a1 = indice do registrador, podendo ser de 0 a 31
#   $a2 = conteudo a ser armazenado no registrador
# Retorno:
#   O procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
escreve_registrador:
    #prologo
    addiu $sp, $sp, -12 #$sp <- Valor de $sp - 12, para ajustar a pilha
    sw $s0, 0($sp) #$s0 <- $sp
    sw $s1, 4($sp) #$s0 <- $sp + 4
    sw $s2, 8($sp) #$s0 <- $sp + 8
    
    #corpo 
    add $s0, $a0, $zero #$s0 contem o endereco de memoria dos registradores
    add $s1, $a1, $zero #$s1 contem o indice do registrador
    add $s2, $a2, $zero #$s2 conteudo a ser armazenado
    sll $s1, $s1, 2 # $s1 <- $s1 * 4
    add $s0, $s0, $s1 # $s0 <- $s0 + $s1
    sw $s2, ($s0) # salva o valor de $s2 no endereco contido em $s0
        
    
    #epilogo
    lw $s0, 0($sp) # $sp <- $s0
    lw $s1, 4($sp) # $sp + 4 <- $s1
    lw $s2, 8($sp) # $sp + 8 <- $s2
    addiu $sp, $sp, 12 #ajusta a pilha
    jr $ra

################################################################################
# Procedimento para buscar a instrucao e guardar em IR do simulador, conforme o endereco em PC do simulador
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   O procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
busca_instrucao:
    #prologo
    addiu $sp, $sp, -4
    sw $s0, 0($sp)
    
    #corpo
    lw $s0, instrucoes_pc #carrega em $s0 o conteudo de PC
    lw $s0, ($s0) #carrega a instrucao do endereco de PC
    sw $s0, instrucoes_ir #instrucoes_ir <- codigo hexadecimal da instrucao
    
    #epilogo
    lw $s0, 0($sp)
    addiu $sp, $sp, 4
    jr $ra

################################################################################
# Procedimento para decodificar a instrucao que esta no IR do simulador, separando os campos
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao tem argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
decodifica_instrucao:
    #prologo
    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    #corpo         
    lw $s0, instrucoes_ir #$s0 contem o comando
    andi $s1, $s0, 0xFC000000 # aplica a mascara para campo opcode
    srl $s1, $s1, 26 #desloca 26 bits para a direita
    sw $s1, campo_op # campo_op <- valor do opcode
    andi $s1, $s0, 0x03E00000 # aplica a mascara para o campo rs
    srl $s1, $s1, 21 #desloca 21 bits para a direita
    sw $s1, campo_rs #campo_rs <- valor do campo rs
    andi $s1, $s0, 0x001F0000 # aplica a mascara para o campo rt
    srl $s1, $s1, 16 #desloca 16 bits para a direita
    sw $s1, campo_rt #campo_rt <- valor do campo rt
    andi $s1, $s0, 0x0000F800 # aplica a mascara para o campo rd
    srl $s1, $s1, 11 #desloca 11 bits para a direita
    sw $s1, campo_rd #campo_rd <- valor do campo rd
    andi $s1, $s0, 0x000007C0 # aplica a mascara para o campo shamt
    srl $s1, $s1, 6 #desloca 6 bits para a direita
    sw $s1, campo_shamt #campo_shamt <- valor do campo shamt
    andi $s1, $s0, 0x0000003F # aplica a mascara para o campo funct
    sw $s1, campo_funct #campo_funct <- valor do campo funct
    andi $s1, $s0, 0x0000FFFF # aplica a mascara para o campo imm
    sll $s1, $s1, 16 #desloca 16 bits para a esquerda
    sra $s1, $s1, 16 #desloca 16 bits para a direita
    #com os dois deslocamentos acima, o sinal do bit mais significativo e' extendido
    sw $s1, campo_imm #campo_imm <- valor do campo imediato
    andi $s1, $s0, 0x03FFFFFF # aplica a mascara para o campo de endereco alvo
    sw $s1, campo_end_alvo #campo_end_alvo <- valor do endereco alvo
    lw $s0, instrucoes_pc # $s0 <- valor do PC
    addi $s0, $s0, 4 # incrementa $s0 em 4
    sw $s0, instrucoes_pc # salva $s0 em PC

    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

################################################################################
# Procedimento para executar a instrucao armazenada no IR do simulador
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra 
executa_instrucao:
    #prologo
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    #corpo         
    lw $s0, instrucoes_ir # carrega em $s0 a instrucao a ser executada
    beq $s0, 0xc, executa_instrucao_syscall # se $s0 for syscall, executa instrucao de syscall
    lw $s0, campo_op # carrega em $s0 o campo de opcode
    beqz $s0, executa_instrucao_tipo_r # se $s0 for 0, entao instrucao do tipo R
    beq $s0, 9, executa_instrucao_addiu
    beq $s0, 5, executa_instrucao_bne
    beq $s0, 0xf, executa_instrucao_lui
    beq $s0, 0xd, executa_instrucao_ori
    beq $s0, 0x1c, executa_instrucao_mul
    beq $s0, 0x2b, executa_instrucao_sw
    beq $s0, 0x23, executa_instrucao_lw
    beq $s0, 0x08, executa_instrucao_addi
    beq $s0, 0x02, executa_instrucao_j
    beq $s0, 0x03, executa_instrucao_jal
    j executa_instrucao_fim
    executa_instrucao_syscall:
        jal executa_syscall
        j executa_instrucao_fim
    executa_instrucao_tipo_r:
        lw $s1, campo_funct # carrega em $s1 o campo funct
        beq $s1, 0x20, executa_instrucao_tipo_r_add
        beq $s1, 0x21, executa_instrucao_tipo_r_addu
        beq $s1, 8, executa_instrucao_tipo_r_jr 
        j executa_instrucao_fim
        executa_instrucao_tipo_r_add:
            jal executa_add
            j executa_instrucao_fim
        executa_instrucao_tipo_r_addu:
            jal executa_addu
            j executa_instrucao_fim
        executa_instrucao_tipo_r_jr:
            jal executa_jr
            j executa_instrucao_fim
    executa_instrucao_addiu:
        jal executa_addiu
        j executa_instrucao_fim
    executa_instrucao_bne:
        jal executa_bne
        j executa_instrucao_fim
    executa_instrucao_lui:
        jal executa_lui
        j executa_instrucao_fim
    executa_instrucao_ori:
        jal executa_ori
        j executa_instrucao_fim
    executa_instrucao_mul:
        jal executa_mul
        j executa_instrucao_fim
    executa_instrucao_sw:
        jal executa_sw
        j executa_instrucao_fim
    executa_instrucao_lw:
        jal executa_lw
        j executa_instrucao_fim
    executa_instrucao_addi:
        jal executa_addi
        j executa_instrucao_fim
    executa_instrucao_j:
        jal executa_j
        j executa_instrucao_fim
    executa_instrucao_jal:
        jal executa_jal
        j executa_instrucao_fim
    

    #epilogo
    executa_instrucao_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)  
        lw $s2, 8($sp)
        lw $ra, 12($sp)
        addiu $sp, $sp, 16
        jr $ra


################################################################################
# Procedimento para executar a instrucao de syscall
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $ra 
executa_syscall:
    #prologo
    addiu $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)

    #corpo
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    addi $a1, $zero, 2 # $a1 <- 2 = indice do $v0 do simulador
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s0, $v0, $zero # $s0 <- valor do registrador $v0 do simulador
    beq $s0, 4, executa_syscall_imprime_string # se $s0 for 4, entao imprime string no display
    beq $s0, 1, executa_syscall_imprime_inteiro # se $s0 for 1, entao imprime inteiro no display
    beq $s0, 11, executa_syscall_imprime_caracter # se $s0 for 11, entao imprime caracter no display 
    beq $s0, 10, executa_syscall_fim_programa # se $s0 for 10, entao finaliza o programa
    executa_syscall_imprime_string:
        la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
        addi $a1, $zero, 4 # $a1 <- 4 = indice do $a0 do simulador
        jal leia_registrador #chama o procedimento para ler o valor de um registrador
        add $s0, $v0, $zero # $s0 <- valor do registrador $a0 do simulador
        # $s0 vai conter o endereco de memoria do primeiro caracter da string
        # no Mars, o enderecamento de dados comeca em 0x10010000
        # assim, fazemos a diferenca do valor para encontrar o endereco equivalente na memoria de dados do simulador
        addi $s0, $s0, -0x10010000 # $s0 <- $s0 - 0x10010000
        la $s1, dados # $s1 <- endereco de inicio da memoria de dados
        add $s0, $s0, $s1 # $s0 <- endereco efetivo da memoria de dados do simulador
        add $a0, $zero, $s0 # $a0 <- $s0
        jal imprime_linha # imprime a string no display
        j executa_syscall_fim
    executa_syscall_imprime_inteiro:
        la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
        addi $a1, $zero, 4 # $a1 <- 4 = indice do $a0 do simulador
        jal leia_registrador #chama o procedimento para ler o valor de um registrador
        add $s0, $v0, $zero # $s0 <- valor do registrador $a0 do simulador
        add $a0, $zero, $s0 # $a0 <- $s0
        la $a1, buffer_int_to_string # $a1 <- espaco de memoria usado para armazenar a string transformada do numero inteiro
        jal int_to_string #chama o procedimento para transformar um inteiro em string
        la $a0, buffer_int_to_string # $a0 <- endereco de memoria da string a ser impressa no display
        jal imprime_linha #chama o procedimento para imprimir uma string no display
        j executa_syscall_fim
    executa_syscall_imprime_caracter:
        la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
        addi $a1, $zero, 4 # $a1 <- 4 = indice do $a0 do simulador
        jal leia_registrador #chama o procedimento para ler o valor de um registrador
        add $s0, $v0, $zero # $s0 <- valor do registrador $a0 do simulador
        add $a0, $zero, $s0 # $a0 <- $s0
        jal imprime_display #chama o procedimento para imprimir um caracter no display
        j executa_syscall_fim
    executa_syscall_fim_programa:
        addi $s0, $zero, 1 # $s0 <- 1
        sw $s0, fim_programa # salva $s0 em fim_programa
        j executa_syscall_fim
    
    #epilogo
    executa_syscall_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        lw $ra, 8($sp)
        addiu $sp, $sp, 12
        jr $ra

################################################################################
# Procedimento para executar a instrucao de add
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra 
executa_add:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    #corpo         
    # campo_rd, campo_rs e campo_rt contem os indices dos registradores (entre 0 e 31)
    lw $s0, campo_rd # $s0 <- campo_rd
    lw $s1, campo_rs # $s1 <- campo_rs
    lw $s2, campo_rt # $s2 <- campo_rt
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s1, $v0, $zero # $s1 <- valor do registrador do campo_rs
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s2, $zero # $a1 <- $s2
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s2, $v0, $zero # $s2 <- valor do registrador do campo_rt
    add $s3, $s1, $s2 # $s3 <- soma dos valores dos registradores
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    add $a2, $s3, $zero # $a1 <- $s3
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rd

    
    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de addu
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_addu:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    #corpo         
    # campo_rd, campo_rs e campo_rt contem os indices dos registradores (entre 0 e 31)
    lw $s0, campo_rd # $s0 <- campo_rd
    lw $s1, campo_rs # $s1 <- campo_rs
    lw $s2, campo_rt # $s2 <- campo_rt
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s1, $v0, $zero # $s1 <- valor do registrador do campo_rs
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s2, $zero # $a1 <- $s2
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s2, $v0, $zero # $s2 <- valor do registrador do campo_rt
    addu $s3, $s1, $s2 # $s3 <- soma sem sinal dos valores dos registradores
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    add $a2, $s3, $zero # $a2 <- $s3
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rd

    
    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de jr
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $ra
executa_jr:
    #prologo
    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    
    #corpo
    #campo_rs contem o indice do registrador (entre 0 e 31)
    lw $s0, campo_rs # $s0 <- campo_rs
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s0, $v0, $zero # $s0 <- valor do registrador do campo_rs
    sw $s0, instrucoes_pc # salva em PC o endereco alvo do jump
    
    #epilogo
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

################################################################################
# Procedimento para executar a instrucao de addiu
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_addiu:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    #corpo
    #campo_rs e campo_rt contem o indice dos registradores (entre 0 e 31)
    lw $s0, campo_rs # $s0 <- campo_rs
    lw $s1, campo_rt # $s1 <- campo_rt
    lw $s2, campo_imm # $s2 <- campo imediato
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s0, $v0, $zero # $s0 <- valor do registrador campo_rs
    addu $s3, $s0, $s2 # $s3 <- soma sem sinal dos valores dos registradores
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    add $a2, $s3, $zero # $a2 <- $s2
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rt


    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de bne
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_bne:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    #corpo
    #campo_rs e campo_rt contem o indice dos registradores (entre 0 e 31)
    lw $s0, campo_rs # $s0 <- campo_rs 
    lw $s1, campo_rt # $s1 <- campo_rt
    lw $s2, campo_imm # $s2 <- campo imediato
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s0, $v0, $zero # $s0 <- valor do registrador campo_rs
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s1, $v0, $zero # $s1 <- valor do registrador campo_rt
    bne $s1, $s0, executa_bne_ajusta_pc # se $s1 != $s0, entao segue a condicao
    j executa_bne_fim
    executa_bne_ajusta_pc:
        lw $s0, instrucoes_pc # $s0 <- PC
        sll $s2, $s2, 2 # $s2 <- $s2 * 4
        add $s0, $s0, $s2 # $s0 <- $s0 + $s2
        sw $s0, instrucoes_pc # guarda em PC o valor de $s0

    
    #epilogo
    executa_bne_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)  
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $ra, 16($sp)
        addiu $sp, $sp, 20
        jr $ra

################################################################################
# Procedimento para executar a instrucao de lui
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra
executa_lui:
    #prologo
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    #corpo         
    lw $s0, campo_imm # $s0 <- campo imediato
    # mascara para pegar os ultimos 16 bits
    andi $s1, $s0, 0x0000FFFF # $s1 <- ultimos 16 bits do campo imediato
    sll $s1, $s1, 16 # desloca 16 bits para a esquerda salvando em $s1
    #campo_rt contem o indice dos registradores (entre 0 e 31)
    lw $s2, campo_rt # $s2 <- campo_rt
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s2, $zero # $a1 <- $s2
    add $a2, $s1, $zero # $a2 <- $s1
    jal escreve_registrador # guarda o valor no registrador


    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra


################################################################################
# Procedimento para executar a instrucao de ori
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_ori:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    #corpo
    #campo_rs e campo_rt contem o indice dos registradores (entre 0 e 31)
    lw $s0, campo_imm # $s0 <- campo imediato
    lw $s1, campo_rs # $s1 <- campo_rs
    lw $s2, campo_rt # $s2 <- campo_rt
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s1, $v0, $zero # $s1 <- valor do registrador campo_rs
    or $s3, $s0, $s1 # $s3 <- operacao or entre $s0 e $s1
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s2, $zero # $a1 <- $s2
    add $a2, $s3, $zero # $a2 <- $s3
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rt


    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de multiplicacao
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_mul:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)

    #corpo
    #campo_rs, campo_rd e campo_rt contem o indice dos registradores (entre 0 e 31)
    lw $s0, campo_rd # $s0 <- campo_rd
    lw $s1, campo_rs # $s1 <- campo_rs
    lw $s2, campo_rt # $s2 <- campo_rt
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s1, $v0, $zero # $s1 <- valor do registrador campo_rs
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s2, $zero # $a1 <- $s2
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s2, $v0, $zero # $s2 <- valor do registrador campo_rt
    mul $s3, $s1, $s2 # $s3 <- resultado da multiplicacao entre $s1 e $s2
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    add $a2, $s3, $zero # $a2 <- $s3
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rd

    
    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de store word
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_sw:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    #corpo  
    #campo_rs e campo_rt contem o indice dos registradores (entre 0 e 31)       
    lw $s0, campo_rs # $s0 <- campo_rs
    lw $s1, campo_rt # $s1 <- campo_rt
    lw $s2, campo_imm # $s2 <- campo imediato
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s3, $v0, $s2 # $s3 <- valor do registrador campo_rs + campo imediato
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s1, $v0, $zero # $s1 <- valor do registrador campo_rt
    sw $s1, ($s3) #salva $s1 no endereco de memoria que esta em $s3 

    
    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de load word
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_lw:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    #corpo
    #campo_rs e campo_rt contem o indice dos registradores (entre 0 e 31)
    lw $s0, campo_rs # $s0 <- campo_rs
    lw $s1, campo_rt # $s1 <- campo_rt
    lw $s2, campo_imm # $s2 <- campo imediato
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s3, $v0, $s2 # $s3 <- valor do registrador campo_rs + campo imediato
    lw $s3, ($s3) # carrega em $s3 o valor do endereco de memoria dado por $s3
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    add $a2, $s3, $zero # $a2 <- $s3
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rt

    
    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra


################################################################################
# Procedimento para executar a instrucao de addi
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $ra
executa_addi:
    #prologo
    addiu $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $ra, 16($sp)
    
    #corpo
    #campo_rs e campo_rt contem o indice dos registradores (entre 0 e 31)        
    lw $s0, campo_rs # $s0 <- campo_rs
    lw $s1, campo_rt # $s1 <- campo_rt
    lw $s2, campo_imm # $s2 <- campo imediato
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s0, $zero # $a1 <- $s0
    jal leia_registrador #chama o procedimento para ler o valor de um registrador
    add $s0, $v0, $zero # $s0 <- valor do registrador campo_rs
    add $s3, $s0, $s2 # $s3 <- $s0 + $s2
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    add $a1, $s1, $zero # $a1 <- $s1
    add $a2, $s3, $zero # $a2 <- $s3
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador campo_rt


    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $ra, 16($sp)
    addiu $sp, $sp, 20
    jr $ra

################################################################################
# Procedimento para executar a instrucao de jump
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra
executa_j:
    #prologo
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    #corpo      
    lw $s0, campo_end_alvo # $s0 <- endereco alvo
    # o endereco de jump deve ter os 4 primeiros bits iguais do PC e os ultimos 2 bits sendo zero
    # no Mars, os enderecos de memoria que guardam as instrucoes iniciam em 0x00400000, sendo assim, os 4 primeiros bits sao zero
    sll $s0, $s0, 2 # desloca 2 bits para a esquerda (os ultimos 2 bits ficam com zero)
    addi $s0, $s0, -0x00400000 # $s0 <- $s0 - 0x00400000
    la $s1, instrucoes # carrega o endereco de memoria inicial que contem as instrucoes
    add $s1, $s1, $s0 # $s1 <- $s1 + $s0
    sw $s1, instrucoes_pc # guarda em PC o endereco de memoria da proxima instrucao
    

    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

################################################################################
# Procedimento para executar a instrucao de jump and link
# ------------------------------------------------------------------------------
# argumentos:
#   o procedimento nao possui argumentos
# Retorno:
#   o procedimento nao retorna valores
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra
executa_jal:
    #prologo
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    #corpo      
    lw $s0, campo_end_alvo # $s0 <- endereco alvo
    lw $s1, instrucoes_pc # $s1 <- PC
    la $a0, registradores #carrega em $a0 o endereco base do vetor de registradores do simulador
    li $a1, 31 # $a1 <- 31 = registrador $ra
    add $a2, $s1, $zero # $a2 <- $s1
    jal escreve_registrador #chama o procedimento para guardar o valor no registrador $ra
    # o endereco de jump deve ter os 4 primeiros bits iguais do PC e os ultimos 2 bits sendo zero
    # no Mars, os enderecos de memoria que guardam as instrucoes iniciam em 0x00400000, sendo assim, os 4 primeiros bits sao zero
    sll $s0, $s0, 2 # desloca 2 bits para a esquerda (os ultimos 2 bits ficam com zero)
    addi $s0, $s0, -0x00400000 # $s0 <- $s0 - 0x00400000
    la $s1, instrucoes # carrega o endereco de memoria inicial que contem as instrucoes
    add $s1, $s1, $s0 # $s1 <- $s1 + $s0
    sw $s1, instrucoes_pc # guarda em PC o endereco de memoria da proxima instrucao
    

    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

################################################################################
# Procedimento para ler um registrador do simulador
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 <- endereco inicial da memoria de registradores
#   $a1 <- indice do registrador a ser buscado
# Retorno:
#   $v0 <- valor do registrador
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
leia_registrador:
    #prologo
    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    #corpo 
    add $s0, $a0, $zero #$s0 contem o endereco de memoria dos registradores
    add $s1, $a1, $zero #$s1 contem o indice do registrador
    sll $s1, $s1, 2 # $s1 <- $s1 * 4
    add $s0, $s0, $s1 # $s0 <- $s0 + $s1
    lw $v0, ($s0) # carrega em $v0 o valor do registrador
        
    
    #epilogo
    lw $s0, 0($sp)
    lw $s1, 4($sp)  
    addiu $sp, $sp, 8
    jr $ra

################################################################################
# Procedimento para verificar os parametros do comando d
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
# Retorno:
#   $v0 = 1 se parametros estao corretos e 0 se parametros estao incorretos
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $ra <- endereco de memoria de uma instrucao para retorno 
verifica_parametros_comando_r:
    #prologo
    addiu $sp, $sp, -8 #ajusta a pilha
    sw $s0, 0($sp) #salva o valor de $s0
    sw $ra, 4($sp) #salva o valor de $ra
    
    #corpo
    add $s0, $a0, $zero # $s0 <- $a0
    
    add $a0, $s0, $zero #$a0 <- $s0 (linha de comando)
    li $a1, 3 # $a1 <- 3
    jal palavra #armazena em $v1 a terceira palavra
    bnez $v1, verifica_parametros_comando_r_erro  #erro se terceiro parametro for diferente de 0
    add $a0, $s0, $zero # $a0 <- $s0 (linha de comando)
    li $a1, 2 # $a1 <- 2
    jal palavra #armazena em $v1 a segunda palavra
    beqz $v1, verifica_parametros_comando_r_erro #erro se segundo parametro for 0
    add $a0, $v1, $zero # $a0 <- segundo parametro
    jal str_to_int_decimal #retorna em $v0 o parametro em inteiro decimal
    beq $v0, -1, verifica_parametros_comando_r_erro  #erro se $v0 = -1
    li $v0, 1 # $v0 <- 1
    j verifica_parametros_comando_r_fim #salta para ajustar a pilha
    verifica_parametros_comando_r_erro:
        li $v0, 0 # $v0 <- 0
    
    #epilogo
    verifica_parametros_comando_r_fim:
        lw $s0, 0($sp)  #restaura o valor de $s0
        lw $ra, 4($sp) #restaura o valor de $ra
        addiu $sp, $sp, 8 #ajusta a pilha
        jr $ra #retorna para onde o procedimento foi chamado


################################################################################
# Procedimento para verificar os parametros do comando m
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
# Retorno:
#   $v0 = 1 se parametros estao corretos e 0 se parametros estao incorretos
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $ra <- endereco de memoria de uma instrucao para retorno
verifica_parametros_comando_m:
    #prologo
    addiu $sp, $sp, -12 #ajusta a pilha
    sw $s0, 0($sp) #salva o valor de $s0
    sw $s1, 4($sp) #salva o valor de $s1
    sw $ra, 8($sp) #salva o valor de $ra
    
    #corpo
    add $s0, $a0, $zero # $s0 <- $a0
    add $a0, $s0, $zero # $a0 <- $s0
    li $a1, 4 #$a1 <- 4
    jal palavra #retorna em $v1 a quarta palavra
    bnez $v1, verifica_parametros_comando_m_erro #erro se quarto argumento for diferente de 0
    add $a0, $s0, $zero # $a0 <- linha de comando
    li $a1, 2 # $a1 <- 2
    jal palavra  # $retorna em $v1 a segunda palavra
    beqz $v1, verifica_parametros_comando_m_erro #erro se segundo argumento for 0
    add $s1, $v1, $zero # $s1 <- segundo argumento
    add $a0, $s1, $zero # $a0 <- segundo argumentos
    jal tamanho_string #retorna em $v0 o tamanho da string
    bgt $v0, 10, verifica_parametros_comando_m_erro #se for > 10, erro
    add $a0, $s1, $zero # $a0 <- segundo parametro
    jal str_to_int_hexa #converte string para hexadecimal
    beq $v0, -1, verifica_parametros_comando_m_erro #se $v0 = -1, erro
    add $a0, $s0, $zero # $a0 <- linha de comando 
    li $a1, 3 # a1 <- 3
    jal palavra # retorna em $v1 a terceira palavra
    beqz $v1, verifica_parametros_comando_m_erro #se terceiro argumento for = 0, erro
    add $a0, $v1, $zero # $a0 <- terceiro argumento
    jal str_to_int_decimal # $v0 -> terceiro argumento convertido para inteiro decimal
    beq $v0, -1, verifica_parametros_comando_m_erro # se $v0 = -1, erro
    li $v0, 1 # $v0 <- 1
    j verifica_parametros_comando_m_fim #pula para ajustar a pilha
    verifica_parametros_comando_m_erro:
        li $v0, 0 # $v0 <- 0
    
    #epilogo
    verifica_parametros_comando_m_fim:
        lw $s0, 0($sp) #restaura o valor de $s0
        lw $s1, 4($sp) #restaura o valor de $s1
        lw $ra, 8($sp) #restaura o valor de $ra
        addiu $sp, $sp, 12 #ajusta pilha
        jr $ra #retorna para onde o procedimento foi chamado

################################################################################
# Procedimento que retorna o numero de caracteres de uma string
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = uma string
# Retorno:
#   $v0 = numero de letras da string
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
tamanho_string:
    #prologo
    addiu $sp, $sp, -12 #ajusta a pilha
    sw $s0, 0($sp) #salva o conteudo de $s0
    sw $s1, 4($sp) #salva o conteudo de $s1
    sw $s2, 8($sp) #salva o conteudo de $s2
    
    #corpo
    add $s0, $a0, $zero # $s0 <- $a0
    li $s1, 0 # $s1 <- 0 (contador)
    tamanho_string_loop:
        lb $s2,0($s0) # $s2 <- byte de $s0
        beqz $s2, tamanho_string_fim #se $s2 = 0, pula para o fim
        addi $s0,$s0,1 # incrementa $s0 para ir para proximo byte
        addi $s1,$s1,1 #incrementa o contador
        j tamanho_string_loop #volta para inicio do loop
    tamanho_string_fim:
        add $v0, $s1, $zero # $v0 <- contador com o tamanho da string
        
        #epilogo
        lw $s0, 0($sp) #restaura o valor de $s0
        lw $s1, 4($sp) #restaura o valor de $s1
        lw $s2, 8($sp) #restaura o valor de $s2
        addiu $sp, $sp, 12 #ajusta a pilha
        jr $ra #retorna para onde o procedimento foi chamado


################################################################################
# Procedimento para verificar os parametros do comando ld ou comando lt
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
# Retorno:
#   $v0 = 1 se parametros estao corretos e 0 se parametros estao incorretos
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $ra <- endereco de memoria de uma instrucao para retorno
verifica_parametros_comando_ldlt:
    #prologo
    addiu $sp, $sp, -8 #ajusta a pilha
    sw $s0, 0($sp) #salva o valor de $s0
    sw $ra, 4($sp) #salvar o valor de $ra
    
    #corpo
    add $s0, $a0, $zero # $s0 <- $a0
    add $a0, $s0, $zero # $a0 <- $s0
    li $a1, 3 # $a1 <- 3
    jal palavra # retorna em $v1 a terceira palavra
    bnez $v1, verifica_parametros_comando_ldlt_erro #se terceiro argumento for diferente de 0, erro
    add $a0, $s0, $zero # $a0 <- linha de comando
    li $a1, 2 # $li <- 2
    jal palavra  # retorna em $v1 a segunda palavra
    beqz $v1, verifica_parametros_comando_ldlt_erro #se segundo argumento for = 0, erro
    li $v0, 1 # $v0 <- 1
    j verifica_parametros_comando_ldlt_fim #pula para ajustar a pilha
    verifica_parametros_comando_ldlt_erro:
        li $v0, 0 # $v0 <- 0
    
    #epilogo
    verifica_parametros_comando_ldlt_fim:
        lw $s0, 0($sp) #restaura o valor de $s0 
        lw $ra, 4($sp) #restaura o valor de $ra
        addiu $sp, $sp, 8 #ajusta a pilha
        jr $ra #retorna para onde o procedimento foi chamado
            
################################################################################
# Procedimento para executar o comando lt
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco da string com o nome do arquivo
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $ra <- endereco de memoria de uma instrucao para retorno            
executa_lt:
    #prologo
    addiu $sp, $sp, -12 #ajusta a pilha
    sw $s0, 0($sp) #salva o valor de $s0
    sw $s1, 4($sp) #salva o valor de $s1
    sw $ra, 8($sp) #salva o valor de $ra
    
    #corpo
    sw $zero, instrucoes_pc #coloca o valor zero em PC
    add $s0, $a0, $zero #$s0 contem o endereco com o nome do arquivo a ser aberto
    add $a0, $s0, $zero #$a0 <- $s0
    la $a1, descritor_arquivo # $a1 <- endereco de memoria com o descritor do arquivo
    jal abre_arquivo_leitura #abre o arquivo
    bltz $v0, executa_lt_fim
    #pega os caracteres do arquivo
    add $s1, $v0, $zero
    la $a0, instrucoes
    li $a1, 400
    jal limpa_vetor #limpa o vetor colocando os valores como 0 caso tenha algum valor
    add $a0, $s1, $zero
    la $a1, instrucoes
    li $a2, 400
    jal leia_bytes_para_buffer
    bltz $v0, executa_lt_fim
    la $a0, descritor_arquivo
    lw $a0, ($a0)
    jal fecha_arquivo
    la $s0, instrucoes #carrega o endereco inicial das instrucoes
    sw $s0, instrucoes_pc #guarda em PC o endereco inicial
    
    #epilogo
    executa_lt_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)  
        lw $ra, 8($sp)
        addiu $sp, $sp, 12
        jr $ra
    

################################################################################
# Procedimento para executar o comando ld
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco da string com o nome do arquivo
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $ra <- endereco de memoria de uma instrucao para retorno   
executa_ld:
    #prologo
    addiu $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $ra, 8($sp)
    
    #corpo 
    add $s0, $a0, $zero #$s0 contem o endereco com o nome do arquivo a ser aberto
    add $a0, $s0, $zero
    la $a1, descritor_arquivo
    jal abre_arquivo_leitura #abre o arquivo
    bltz $v0, executa_ld_fim
    #pega os caracteres do arquivo
    add $s1, $v0, $zero
    la $a0, dados
    li $a1, 400
    jal limpa_vetor #limpa o vetor colocando os valores como 0 caso tenha algum valor
    add $a0, $s1, $zero
    la $a1, dados
    li $a2, 400
    jal leia_bytes_para_buffer
    bltz $v0, executa_ld_fim
    la $a0, descritor_arquivo
    lw $a0, ($a0)
    jal fecha_arquivo
    
    #epilogo
    executa_ld_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)  
        lw $ra, 8($sp)
        addiu $sp, $sp, 12
        jr $ra

    
################################################################################
# Procedimento para abrir um arquivo para leitura
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 : endereco da string com o nome do arquivo a ser aberto
#   $a1 : endereco da variavel onde sera armazenado o descritor do arquivo (4 bytes)
# Retorno:
#   $v0 : o descritor do arquivo. Um descritor negativo sinaliza que o arquivo 
#         nao pode ser aberto.
#   Mapa da pilha:
#   $sp + 0 : $a1 <- endereco da variavel que armazena o descritor do arquivo aberto
abre_arquivo_leitura:            
################################################################################ 
# prologo
            addiu $sp, $sp, -8  # sera adicionado um elemento na pilha
            sw    $a1, 0($sp)   # guardamos na pilha o endereco da variavel descritor do arquivo
            sw $ra, 4($sp)
# corpo do procedimento
# abrimos o arquivo para a leitura
            li    $v0, servico_abre_arquivo # servico 13: abre um arquivo
            li    $a1, 0        # $a1 <- 0: arquivo sera aberto para leitura
            li    $a2, 0        # modo nao usado. Use o valor 0.
            syscall             # abre o arquivo
# guardamos o descritor do arquivo em descritor_arquivo
            lw    $a1, 0($sp)   # carregamos o endereco da variavel com o descritor do arquivo
            sw    $v0, 0($a1)   # armazenamos o descritor do arquivo em descritor_arquivo
            slt   $t0, $v0, $zero # $t0 = 1 se $v0 < 0 ($v0 negativo)
            bne   $t0, $zero, arquivo_nao_pode_ser_aberto # se $v0 e' negativo, o arquivo nao pode ser aberto
            j     arquivo_aberto
arquivo_nao_pode_ser_aberto:
            la $a0, str_arquivo_nao_pode_ser_aberto
            jal imprime_linha
            j fim_abre_arquivo_leitura # retorna
arquivo_aberto:
            la $a0, str_arquivo_aberto
            jal imprime_linha
fim_abre_arquivo_leitura:
# epilogo
            lw $ra, 4($sp)
            addiu $sp, $sp, 8   # restauramos a pilha  
            jr    $ra           # retornamos ao procedimento chamador       
################################################################################           

################################################################################
# Faz a leitura do arquivo para um buffer na memoria
# argumentos
#   $a0 : valor do descritor do arquivo
#   $a1 : endereco do buffer que armazena temporariamente os bytes lidos do arquivo
#   $a2 : numero minimo de caracteres lidos
# retorno
#   $v0 : numero de bytes lidos. O valor sera 0 se chegou ao final do arquivo.
#         Se houve um erro de leitura, o valor sera negativo e o programa abortado.
#   mapa da pilha
#   SP + 0 : $v0, o numero de bytes lidos do arquivo
leia_bytes_para_buffer:
################################################################################
# prologo
            addiu $sp, $sp, -8  # reservamos na pilha um espaco para um itens
            sw $ra, 4($sp)
# corpo do procedimento
# lemos o arquivo ate preencher o buffer
leia_caracteres_arquivo:
            li    $v0, servico_leia_arquivo # servico 14: leitura do arquivo
            syscall             # fazemos a leitura de caracteres do arquivo para o buffer
            sw    $v0, 0($sp)   # guardamos na pilha o numero de caracteres lidos.
            # verificamos se houve um erro de leitura
            slt   $t0, $v0, $zero # $t0 = 1 se $v0 < 0 (erro de leitura)
            bne   $t0, $zero, erro_leitura # se $t0=1 desvie para erro de leitura
            arquivo_lido:
                la $a0, str_arquivo_lido
                jal imprime_linha
                j fim_leia_bytes_buffer
            
            # imprime uma mensagem indicando que houve erro na leitura do arquivo e fecha o arquivo 
erro_leitura:
            la $a0, str_erro_leitura
            jal imprime_linha
# epilogo   
fim_leia_bytes_buffer:
            lw $ra, 4($sp)
            lw    $v0, 0($sp)   # restauramos o numero de caracteres lidos no arquivo
            addiu $sp, $sp, 8   # restauramos a pilha 
            jr    $ra           # retornamos ao procedimento chamador
################################################################################    

################################################################################
# Procedimento para fechar um arquivo
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 : Descritor do arquivo
# Retorno:
#   O procedimento nao retorna valores
fecha_arquivo:
################################################################################
# prologo
# corpo do programa
            li    $v0, servico_fecha_arquivo       # servico 16: fecha um arquivo
            syscall             # fechamos o arquivo  
# epilogo
            jr    $ra           # retornamos ao procedimento chamador
################################################################################

################################################################################
# Procedimento para executar o comando m
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria da string digitada no keyboard
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra <- endereco de memoria de uma instrucao para retorno       
executa_m:
    #prologo
    addiu $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    #corpo 
    add $s0, $a0, $zero # $s0 <- $a0
    add $a0, $s0, $zero # $a0 <- $s0
    li $a1, 2 # $a1 <- 2
    jal palavra #armazena em $v1 a segunda palavra
    add $s1, $v1, $zero # $s1 <- segunda palavra da linha de comando
    add $a0, $s1, $zero # $a0 <- $s1
    jal str_to_int_hexa # transforma a string em um numero hexadecimal e guarda no $v0
    add $s1, $v0, $zero #$s1 contem o endereco inicial
    add $a0, $s0, $zero # $a0 <- $s0
    li $a1, 3 # $a1 <- 3
    jal palavra #armazena em $v1 a terceira palavra 
    add $s2, $v1, $zero #$s2 <- terceira palavra
    add $a0, $s2, $zero # $a0 <- $s2
    jal str_to_int_decimal # transforma a string em um numero decimal e guarda no $v0
    add $s2, $v0, $zero #$s2 contem o numero de enderecos
    add $a0, $s1, $zero # $a0 <- $s1
    add $a1, $s2, $zero # $a1 <- $s2
    jal imprime_conteudo_memoria # imprime memoria
    
        
    #epilogo
    lw $s0, 0($sp)  
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    jr $ra

################################################################################
# Procedimento que imprime o conteudo da memoria
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco de memoria em hexadecimal que contem o endereco inicial dos enderecos a serem impressos
#   $a1 = numero de enderecos a partir do endereco inicial
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $s3
#   $sp + 16 : $s4
#   $sp + 20 : $s5
#   $sp + 24 : $ra <- endereco de memoria de uma instrucao para retorno 
imprime_conteudo_memoria:
    #prologo
    addiu $sp, $sp, -28
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $ra, 24($sp)
    
    #corpo 
    add $s0, $a0, $zero # $s0 <- $a0
    la $s1, instrucoes # $s1 <- endereco de instrucoes
    #verificamos se o endereco informado esta na faixa de enderecos validos do simulador
    blt $s0, $s1, imprime_conteudo_memoria_erro # se for menor que o primeiro endereco de memoria valido, erro
    la $s1, pilha # $s1 <- endereco da pilha
    addi $s1, $s1, 800 # $s1 <- endereco da pilha + 800. $s1 contem o endereco limite da memoria do simulador
    bge $s0, $s1, imprime_conteudo_memoria_erro # se for maior ou igual a endereco da pilha + 800 bytes
    li $s5, 4 # $s5 <- 4
    div $s0, $s5 # divide o endereco informado por 4
    mfhi $s5 # coloca o resto da divisao no registrador $s5
    bnez $s5, imprime_conteudo_memoria_erro # se $s5 nao for zero, entao nao e' multiplo de 4 e nao pode ser impresso
    add $s2, $a1, $zero # $s2 <- $a1
    li $s3, 0 # $s3 <- 0
    addi $a0, $zero, 10 #carrega o argumento do procedimento - ascii "\n" = 10
    jal imprime_display #imprime no display
    imprime_conteudo_memoria_loop:
        beq $s3, $s2, imprime_conteudo_memoria_fim # se o contador atingiu o numero de enderecos informado por parametro
        beq $s0, $s1, imprime_conteudo_memoria_fim_enderecos # se a memoria chegou ao ultimo endereco (pilha+800)
        add $a0, $s0, $zero # $a0 <- $s0
        jal imprime_hexadecimal
        addi $a0, $zero, 58 #carrega o argumento do procedimento - ascii ":" = 58
        jal imprime_display #imprime no display
        addi $a0, $zero, 32 #carrega o argumento do procedimento - ascii " " = 32
        jal imprime_display #imprime no display
        lw $s4, ($s0)
        add $a0, $s4, $zero
        jal imprime_hexadecimal
        addi $a0, $zero, 10 #carrega o argumento do procedimento - ascii "\n" = 10
        jal imprime_display #imprime no display
        addi $s0, $s0, 4
        addi $s3, $s3, 1
        j imprime_conteudo_memoria_loop

    #imprime um aviso sobre a faixa de enderecos suportada do comando m
    imprime_conteudo_memoria_erro:
        la $a0, str_faixa_endereco_comando_m1
        jal imprime_linha
        la $a0, instrucoes
        jal imprime_hexadecimal
        la $a0, str_faixa_endereco_comando_m2
        jal imprime_linha
        la $a0, pilha+796 # como a pilha tem tamanho de 800 bytes, a ultima palavra disponivel esta no endereco pilha+796
        jal imprime_hexadecimal
        la $a0, str_faixa_endereco_comando_m3
        jal imprime_linha
        j imprime_conteudo_memoria_fim

    #informa que atingiu o limite de enderecos disponiveis
    imprime_conteudo_memoria_fim_enderecos:
        la $a0, str_faixa_endereco_comando_fim1
        jal imprime_linha
        # $s1 tem o endereco de pilha+800
        addi $a0, $s1, -4 # $a0 <- pilha+796
        jal imprime_hexadecimal
        la $a0, str_faixa_endereco_comando_fim2
        jal imprime_linha
        
    #epilogo
    imprime_conteudo_memoria_fim:
        lw $s0, 0($sp)  
        lw $s1, 4($sp)
        lw $s2, 8($sp)
        lw $s3, 12($sp)
        lw $s4, 16($sp)
        lw $s5, 20($sp)
        lw $ra, 24($sp)
        addiu $sp, $sp, 28
        jr $ra

################################################################################
# Procedimento que converte uma string em um inteiro decimal
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = string a ser convertida
# Retorno:
#   $v0 = -1 se ocorreu erro na transformacao ou numero transformado se ocorreu corretamente
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
str_to_int_decimal: 
    #prologo
    addiu $sp, $sp, -8 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $s1, 4($sp) #salva $s1 na pilha
      
    #corpo
    li $v0, 0 # $v0 = 0 
    move $s0, $a0 # $s0 = ponteiro para string 
    lb $s1, ($s0) # $s1 = caracter 
    str_to_int_decimal_loop: 
        blt $s1, 48, str_to_int_decimal_erro # char < '0' 
        bgt $s1, 57, str_to_int_decimal_erro # char > '9'
        j str_to_int_decimal_loop_continua #continua loop
        str_to_int_decimal_erro: 
            li $v0, -1 # retorna -1 em $v0 
            j str_to_int_decimal_loop_fim #pula para ajustar pilha
        str_to_int_decimal_loop_continua:
            subu $s1, $s1, 48 # converte 
            mul $v0, $v0, 10 # multiplica por 10 
            add $v0, $v0, $s1 # $v0 = $v0 * 10 + digito 
            addiu $s0, $s0, 1 # ponteiro para proximo caracter 
            lb $s1, ($s0) # $s3 = proximo caracter 
            bne $s1, $zero, str_to_int_decimal_loop # se nao for fim da string
        
    #epilogo
    str_to_int_decimal_loop_fim:
        lw $s0, 0($sp) #restaura valor de $s0
        lw $s1, 4($sp) #restaura valor de $s1
        addiu $sp, $sp, 8 # ajusta a pilha
        jr $ra #retorna para onde o procedimento foi chamado

################################################################################
# Procedimento que converte uma string em um inteiro hexadecimal
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = string a ser convertida
# Retorno:
#   $v0 = -1 se ocorreu erro na transformacao ou numero transformado se ocorreu corretamente
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
str_to_int_hexa:
    #prologo
    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
      
    #corpo
    li $v0, 0 # $v0 = 0
    move $s0, $a0 # $s0 = ponteiro para string 
    lb $s1, ($s0) # $s1 = caracter
    bne $s1, 48, str_to_int_hexa_erro # se o primeiro caracter nao for '0', erro
    addiu $s0, $s0, 1 # aponta para o proximo caracter
    lb $s1, ($s0) # $s1 = caracter
    bne $s1, 120, str_to_int_hexa_erro # se o segundo caracter nao for 'x', erro
    addiu $s0, $s0, 1 # aponta para o proximo caracter
    lb $s1, ($s0) # $s1 = caracter
    str_to_int_hexa_loop: 
        blt $s1, 48, str_to_int_hexa_erro # se caracter < '0' 
        bgt $s1, 57, str_to_int_hexa_letra # se caracter > '9'
        # caracter e' um numero entre '0' e '9'
        subu $s1, $s1, 48 # $s1 <- $s1 - 48
        j str_to_int_hexa_loop_continua
        str_to_int_hexa_letra:
            blt $s1, 65, str_to_int_hexa_erro # se caracter < 'A' 
            bgt $s1, 70, str_to_int_hexa_erro # se caracter > 'F'
            # caracter esta entre 'A' e 'F'
            subu $s1, $s1, 55 # $s1 <- $s1 - 55
            j str_to_int_hexa_loop_continua
        str_to_int_hexa_erro: 
            li $v0, -1 # retorna -1 em $v0  
            j str_to_int_hexa_loop_fim 
        str_to_int_hexa_loop_continua:
            mul $v0, $v0, 16 # multiplica por 16 
            add $v0, $v0, $s1 # $v0 = $v0 * 16 + digito 
            addiu $s0, $s0, 1 # ponteiro para proximo caracter
            lb $s1, ($s0) # $s1 = proximo caracter 
            bne $s1, $0, str_to_int_hexa_loop # se nao for fim da string
        
    #epilogo
    str_to_int_hexa_loop_fim:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        addiu $sp, $sp, 8
        jr $ra

################################################################################
# Procedimento que verifica e retorna qual o comando que o usuario digitou
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = string a ser verificada
# Retorno:
#   $v0 = 0 se nao e' um comando; 1 se for comando lt; 2 se for comando ld; 3 se for comando r; 4 se for comando d; e 5 se for comando m 
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $ra
verifica_comando:
    #prologo
    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $ra, 4($sp)
    
    #corpo
    li $v0, 0 # $v0 <- 0, retorna isso caso nao seja um comando
    add $s0, $a0, $zero # $s0 <- $a0
    add $a0, $s0, $zero # $a0 <- $s0
    la $a1, comando_lt # $a1 <- "lt"
    jal cmp #compara as strings
    beq $v1, 1, verifica_comando_lt # se as strings sao iguais, entao e' o comando lt
    add $a0, $s0, $zero # $a0 <- $s0
    la $a1, comando_ld # $a1 <- "ld"
    jal cmp #compara as strings
    beq $v1, 1, verifica_comando_ld # se as strings sao iguais, entao e' o comando ld
    add $a0, $s0, $zero # $a0 <- $s0
    la $a1, comando_r # $a1 <- "r"
    jal cmp #compara as strings
    beq $v1, 1, verifica_comando_r # se as strings sao iguais, entao e' o comando r
    add $a0, $s0, $zero # $a0 <- $s0
    la $a1, comando_d # $a1 <- "d"
    jal cmp #compara as strings
    beq $v1, 1, verifica_comando_d # se as strings sao iguais, entao e' o comando d
    add $a0, $s0, $zero # $a0 <- $s0
    la $a1, comando_m # $a1 <- "m"
    jal cmp #compara as strings
    beq $v1, 1, verifica_comando_m # se as strings sao iguais, entao e' o comando m
    j verifica_comando_exit
    verifica_comando_m:
        li $v0, 5 # $v0 <- 5
        j verifica_comando_exit
    verifica_comando_d:
        li $v0, 4 # $v0 <- 4
        j verifica_comando_exit
    verifica_comando_r:
        li $v0, 3 # $v0 <- 3
        j verifica_comando_exit
    verifica_comando_ld:
        li $v0, 2 # $v0 <- 2
        j verifica_comando_exit
    verifica_comando_lt:
        li $v0, 1 # $v0 <- 1
        j verifica_comando_exit
        
    
    #epilogo
    verifica_comando_exit:
        lw $s0, 0($sp)  
        lw $ra, 4($sp)
        addiu $sp, $sp, 8
        jr $ra


################################################################################
# Procedimento que verifica se duas strings sao iguais
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = ponteiro para a primeira string
#   $a1 = ponteiro para a segunda string
# Retorno:
#   $v1 = 0 se as strings forem diferentes e 1 se forem iguais 
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
cmp:
    #prologo
    addiu $sp, $sp, -8
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    
    #corpo
    cmp_loop:
        li $v1, 0 # $v1 <- 0
        lb $s0, ($a0) # carrega o caracter da string 1
        lb $s1, ($a1) # carrega o caracter da string 2
        bne $s0, $s1, cmp_exit # se forem diferentes, finaliza
        beq $s0, $zero, cmp_ok # se chegou ao fim da string, entao sao iguais
        addi $a0, $a0, 1 # ponteiro para o proximo caracter da string 1
        addi $a1, $a1, 1 # ponteiro para o proximo caracter da string 2
        j cmp_loop
    cmp_ok:
        li $v1, 1 # $v1 <- 1
    
    #epilogo
    cmp_exit:
        lw $s0, 0($sp)
        lw $s1, 4($sp)
        addiu $sp, $sp, 8   
        jr $ra
        
######################################################################################################           
# Este procedimento lê as palavras de uma string e retorna a palavra de acordo com o argumento $a1
#
# Argumentos do procedimento:
#  $a0 <- endereco da string a ser analisada
#  $a1 <- indice da palavra a ser retornada da string, podendo ser de 1 ao infinito
# Mapa da pilha
# $sp + 0 : ptr
# $sp + 4 : $ra
# $sp + 8 : $s0
# $sp + 12 : $s1
#
#
# Retorno do procedimento
# $v1 = retorna 0 se a palavra buscada conforme o indice nao existe na string ou retorna o ponteiro para o endereco de memoria da palavra buscada se ela existir
# 
palavra:
# prologo do procedimento
            addiu $sp, $sp, -16
# corpo do procedimento
            add $t0, $zero, $a0  # $t0 <- endereco de str
            sw $t0, 0($sp)     # ptr = str
            sw $ra, 4($sp)
            sw $s0, 8($sp)
            sw $s1, 12($sp)
            
            add $s1, $a1, $zero # $s1 <- $a1, contem o indice
            li $v1, 0 # $v1 <- 0
            li $s0, 1 #$s0 <- contador de palavras
#     while(1){
palavra_while:
#         ptr = leia_palavra(ptr, buffer, delim);
            lw      $a0, 0($sp)     # $a0 <- ptr
            la      $a1, buffer     # $a1 <- buffer
            la      $a2, delim      # $a2 <- delim
            jal     leia_palavra    # chamamos o procedimento leia_palavra
            sw      $v0, 0($sp)     # ptr = leia_palavra(ptr, buffer, delim)
#         if(*buffer) printf("[%s]", buffer); else break;
            # se *buffer == 0 saimos deste laco while
            la      $t1, buffer     # $t1 <- endereco de buffer
            lbu     $t2, 0($t1)     # $t2 <- *buffer
            beqz    $t2, palavra_fim_while # se condicao falsa, saimos deste laco while
            beq $s0, $s1, salva_palavra # se o contador for igual ao indice, entao a palavra foi encontrada
            addi $s0, $s0, 1
            j   palavra_while          # se condicao verdadeira, continuamos no laco while
#     }
salva_palavra:
            add $v1, $t1, $zero #retorna endereco de memoria da palavra em $v1
palavra_fim_while:
# epilogo do procedimento
            lw $s1, 12($sp)
            lw $s0, 8($sp)
            lw $ra, 4($sp)
            addiu   $sp, $sp, 16     # restauramos a pilha
            jr $ra

################################################################################           
# Este procedimento verifica se um caractere e' um delimitador.
#
# Argumentos do procedimento:
# $a0: o caractere (ch) que sera verificado
# $a1: um ponteiro para a string (delim), com os caracteres delimitadores
#
# Mapa da pilha
# nao usamos a pilha neste procedimento
#
# Mapa dos registradores
# $t0: *delim
# $t1: valor diferente de 0 se *delim != ch
#
# Retorno do procedimento
# $v0: valor diferente de 0 se o caractere e' um delimitador ou 0 se o caractere
#      nao e' um caractere delimitador
################################################################################
# char caractere_eh_delimitador(char ch, char* delim)
caractere_eh_delimitador:
# prologo do procedimento
# corpo do procedimento
# {
#     while(*delim && (*delim != ch)) delim++;
caractere_eh_delimitador_while:
            lbu     $t0, 0($a1)     # $t0 <-*delim, 0 se chegamos no final da string com os caracteres delimitadores
            subu    $t1, $t0, $a0   # $t1 <- valor diferente de 0 se *delim != ch
            # se uma das condicoes for falsa, a operacao and e' falsa: saimos do laco while
            beqz    $t0, caractere_eh_delimitador_while_falsa
            beqz    $t1, caractere_eh_delimitador_while_falsa
            addiu   $a1, $a1, 1     # delim++
            j       caractere_eh_delimitador_while 
caractere_eh_delimitador_while_falsa:            
# epilogo do procedimento
#     return *delim;
            move    $v0, $t0        # $v0 <- *delim
# }
            jr      $ra             # retornamos ao procedimento chamador
#-------------------------------------------------------------------------------
         

################################################################################           
# Este procedimento coloca em um buffer uma palavra de uma string. Se buffer ="" = '\0'
# nao existem mais palavras na string. 
#
# Argumentos do procedimento:
# $a0: str, ponteiro para a string onde sera procurada as palavras
# $a1: buffer, ponteiro para um buffer, onde guardamos uma palavra da string
# $a2: delim, ponteiro para uma string com os caracteres delimitadores
#
# Mapa da pilha
# $sp + 12: $ra
# $sp + 8 : $s0
# $sp + 4 : $s1
# $sp + 0 : $s2
#
# Mapa dos registradores
# $s0: str, ponteiro para str, 
# $s1: buffer, ponteiro para buffer
# $s2: delim, ponteiro para delim
#
# Retorno do procedimento
# $v0: um ponteiro para o primeiro caractere apos a palavra encontrada ou o final
#      da string. 
################################################################################
# /* retorna uma palavra em buffer, lida de str e um ponteiro para o primeiro
#    caractere apos a palavra lida*/
# char* leia_palavra(char *str, char *buffer, char *delim)
leia_palavra:
# {
# prologo do procedimento
            addiu   $sp, $sp, -16
            sw      $ra, 12($sp)
            sw      $s0, 8($sp)
            sw      $s1, 4($sp)
            sw      $s2, 0($sp)

            move    $s0, $a0
            move    $s1, $a1
            move    $s2, $a2
# corpo do procedimento
#     //verificamos se existe um delimitador antes da palavra.
#     while(*str && (caractere_eh_delimitador(*str, delim))) str++;
leia_palavra_while_1:
            # executamos o procedimento caractere_eh_delimitador
            lbu     $a0, 0($s0)
            move    $a1, $s2
            jal     caractere_eh_delimitador # chamamos o procedimento caractere_eh_delimitador
            # se uma das condicoes da operacao and em while for zero, saimos deste laco while
            # retorno de (caractere_eh_delimitador(*str, delim) estao em $v0
            lbu     $t0, 0($s0)     # $t0 <- *str
            beqz    $v0, leia_palavra_while_1_falsa
            beqz    $t0, leia_palavra_while_1_falsa
            addiu   $s0, $s0, 1 
            j       leia_palavra_while_1
leia_palavra_while_1_falsa:
#     // lemos a palavra ate um delimitador ou o fim da string
#     while(*str && (!caractere_eh_delimitador(*str, delim))) *buffer++ = *str++;
leia_palavra_while_2:
            # executamos o procedimento caractere_eh_delimitador
            lbu     $a0, 0($s0)
            move    $a1, $s2
            jal     caractere_eh_delimitador # chamamos o procedimento caractere_eh_delimitador
            # se uma das condicoes da operacao and em while for zero, saimos deste laco while
            # retorno de (caractere_eh_delimitador(*str, delim) estao em $v0
            lbu     $t0, 0($s0)     # $t0 <- *str
            bnez    $v0, leia_palavra_while_2_falsa
            beqz    $t0, leia_palavra_while_2_falsa
            sb      $t0, 0($s1)     # *buffer = *str 
            addiu   $s0, $s0, 1     # str++
            addiu   $s1, $s1, 1     # buffer++
            j       leia_palavra_while_2
leia_palavra_while_2_falsa:
#     *buffer = 0; 
            sb      $zero, 0($s1)  
# epilogo do procedimento
#     return str;
            move    $v0, $s0        # $v0 <- str
            # restauramos os valores originais dos registradores
            lw      $s2, 0($sp)
            lw      $s1, 4($sp)
            lw      $s0, 8($sp)
            lw      $ra, 12($sp)
            addiu   $sp, $sp, 16    # restauramos a pilha            
# }
            jr      $ra             # retornamos ao procedimento chamador
#-------------------------------------------------------------------------------


################################################################################
# Procedimento que le uma linha do keyboard
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = ponteiro do endereco de memoria onde a linha digitada vai ser armazenada
# Retorno:
#   sem retorno 
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra
leia_linha:
    #prologo
    addiu $sp, $sp, -16 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $s1, 4($sp) #salva $s1 na pilha
    sw $s2, 8($sp) #salva $s2 na pilha
    sw $ra, 12($sp) #salva $ra na pilha
    
    #corpo
    li $s0, 0 #$s0 <- contador de caracteres da linha
    add $s1, $a0, $zero #$s1 <- endereco de memoria da linha a ser armazenada
    leia_linha_loop:
        jal leia_caracter #le um caracter do terminal
        beq $v0, 8, leia_linha_apaga_caractere #se usuario apertar backspace, apaga o caractere anterior que foi salvo
        beq $v0, 10, leia_linha_fim #se usuario apertar enter, imprime a linha armazenada
        add $s2, $s0, $s1 #$s2 <- end. efetivo de memoria da linha
        sb $v0, 0($s2) #salva a letra digitada no vetor
        addi $s0, $s0, 1 #incrementa o numero de bytes para armazenar a proxima letra
        j leia_linha_loop #salta para inicio do loop
        leia_linha_apaga_caractere: 
            beq $s0, 0, leia_linha_loop # salta para o inicio se $s0 = 0
            add $s0, $s0, -1 #decrementa o contador $s0
            add $s2, $s1, $s0 #$s1 <- endereco efetivo de memoria para colocar 0 no endereco
            sb $zero, 0($s2) #coloca 0 no endereco
            j leia_linha_loop #salta para inicio do loop
            

    #epilogo
    leia_linha_fim:
        lw $s0, 0($sp) #$s0 <- valor anterior de $s0
        lw $s1, 4($sp)  #$s1 <- valor anterior de $s1
        lw $s2, 8($sp)  #$s2 <- valor anterior de $s2
        lw $ra, 12($sp)  #$ra <- valor anterior de $ra
        addiu $sp, $sp, 16 #ajusta pilha novamente
        jr $ra #pula para instrucao armazenada em $ra


################################################################################
# Procedimento que le um caracter digitado do keyboard
# ------------------------------------------------------------------------------
# argumentos:
#   sem argumentos
# Retorno:
#   $v0 <- caracter digitado no keyboard
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
leia_caracter:
    #prologo
    addiu $sp, $sp, -8 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $s1, 4($sp) #salva $s1 na pilha
    
    #corpo
    leia_caracter_loop:
        lw $s0, 0xFFFF0000 #$s0 <- conteudo do RCR
        andi $s0, $s0, 0x0001 #isolamos o bit menos significativo
        beqz $s0, leia_caracter_loop #se for 0, volta ao laco1
        lw $s1, 0xFFFF0004 # $s1 <- caracter do terminal
        beqz $s1, leia_caracter_loop # se $s1 = 0, volta para o inicio do loop
        add $v0, $zero, $s1 # $v0 <- $s1
        
   
    #epilogo
    lw $s0, 0($sp) #$s0 <- valor anterior de $s0
    lw $s1, 4($sp) #$s1 <- valor anterior de $s1
    addiu $sp, $sp, 8 #ajusta pilha novamente
    jr $ra #pula para instrucao armazenada em $ra


################################################################################
# Procedimento que imprime uma string no display
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = ponteiro para o endereco de memoria da string a ser impressa
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s1
#   $sp + 4 : $s2
#   $sp + 8 : $s3
#   $sp + 12 : $ra
imprime_linha:
    #prologo
    addiu $sp, $sp, -16 #ajusta a pilha
    sw $s1, 0($sp) #salva $s1 na pilha
    sw $s2, 4($sp) #salva $s2 na pilha
    sw $s3, 8($sp) #salva $s3 na pilha
    sw $ra, 12($sp) #salva $ra na pilha
    
    
    #corpo
    add $s1, $a0, $zero #$s1 <- end. memoria da linha
    # escrevemos a linha digitada no display
    li $s2, 0 #$s2 <- contador
    imprime_linha_loop: 
        add $s3, $s1, $s2 #carrega o endereco efetivo de memoria para imprimir a letra desse endereco
        lb $s3, 0($s3) #carrega a letra para $s3
        beqz $s3, imprime_linha_loop_exit #finaliza o loop e a funcao se $s3=0
        add $a0, $s3, $zero #carrega $s3 como argumento para a funcao imprime_display
        jal imprime_display #imprime $a0 no display
        add $s2, $s2, 1 #incrementa para imprimir a proxima letra da linha
        j imprime_linha_loop #volta ao inicio do loop
        
        
    #epilogo
    imprime_linha_loop_exit:
        lw $s1, 0($sp) #$s1 <- valor anterior de $s1
        lw $s2, 4($sp) #$s2 <- valor anterior de $s2
        lw $s3, 8($sp) #$s3 <- valor anterior de $s3
        lw $ra, 12($sp) #$ra <- valor anterior de $ra
        addiu $sp, $sp, 16 #ajusta pilha novamente
        jr $ra #pula para instrucao armazenada em $ra   

################################################################################
# Procedimento que imprime um caracter no display
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = valor do caracter ascii
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
imprime_display:
    #prologo
    addiu $sp, $sp, -4 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
        
    #corpo
    imprime_display_loop:
        lw $s0, 0xFFFF0008 #$s0 <- endereco do TCR 
        andi $s0, $s0, 0x0001 #isolamos o bit menos significativo
        beqz $s0, imprime_display_loop
        sw $a0, 0xFFFF000C # carrega o argumento para o endereco do TDR
        
    #epilogo
    lw $s0, 0($sp) #$s0 <- valor anterior de $s0
    addiu $sp, $sp, 4 #ajusta pilha novamente
    jr $ra #pula para instrucao armazenada em $ra

################################################################################
# Procedimento que coloca zero em todas as posicoes de um vetor
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = endereco base de memoria do vetor
#   $a1 = inteiro contendo o numero de palavras do vetor
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
limpa_vetor:
    #prologo
    addiu $sp, $sp, -8 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $s1, 4($sp) #salva $s1 na pilha
    
    #corpo
    add $s0, $a0, $zero # $s0 <- $a0
    add $s1, $s0, $a1 # $s1 <- $s0 + $a1
    limpa_vetor_loop:
        beq $s0, $s1, limpa_vetor_loop_exit
        sw $zero, ($s0) #coloca 0 no endereco efetivo
        add $s0, $s0, 4 #incrementa para verificar o proximo espaco de memoria
        j limpa_vetor_loop
        
    #epilogo
    limpa_vetor_loop_exit:
        lw $s0, 0($sp) #$s0 <- valor anterior de $s0
        lw $s1, 4($sp) #$s1 <- valor anterior de $s1
        addiu $sp, $sp, 8 #ajusta pilha novamente
        jr $ra

################################################################################
# Procedimento que imprime no display o valor dos registradores do simulador
# ------------------------------------------------------------------------------
# argumentos:
#   sem argumentos
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $s0
#   $sp + 4 : $s1
#   $sp + 8 : $s2
#   $sp + 12 : $ra
imprime_registradores:
    #prologo
    addiu $sp, $sp, -16 #ajusta a pilha
    sw $s0, 0($sp) #salva $s0 na pilha
    sw $s1, 4($sp) #salva $s1 na pilha
    sw $s2, 8($sp) #salva $s2 na pilha
    sw $ra, 12($sp) #salva $ra na pilha
    
    #corpo
    li $a0, 10 # $a0 <- 10
    jal imprime_display # imprime no display uma quebra de linha
    li $s1, 0 #inicializa o contador
    imprime_registradores_loop: 
        beq $s1, 32, imprime_registradores_continua #fim do loop
        sll $s2, $s1, 2 #multiplica contador por 4
        la $s0, registradores #carrega o endereco base de memoria que contem os registradores
        add $s0, $s0, $s2 #carrega o endereco efetivo de memoria para imprimir o registrador
        lw $s0, 0($s0) #carrega o conteudo para $s0
        add $a0, $zero, $s1 #carrega o argumento do procedimento
        la $a1, buffer_int_to_string # $a1 <- endereco de buffer_int_to_string
        jal int_to_string # coloca no buffer o inteiro convertido em string
        la $a0, buffer_int_to_string # $a0 <- endereco de buffer_int_to_string
        jal imprime_linha #imprime o conteudo do buffer 
        addi $a0, $zero, 58 #carrega o argumento do procedimento - ascii ":" = 58
        jal imprime_display #imprime no display
        addi $a0, $zero, 32 #carrega o argumento do procedimento - ascii " " = 32
        jal imprime_display #imprime no display
        add $a0, $zero, $s0 #$a0 <- valor do registrador
        jal imprime_hexadecimal #chama o procedimento para imprimir o valor em hexadecimal do registrador 
        addi $a0, $zero, 10 #carrega o argumento do procedimento - ascii "\n" = 10
        jal imprime_display #imprime no display
        add $s1, $s1, 1 #incrementa para imprimir a proxima letra da linha
        j imprime_registradores_loop #volta para o inicio do loop
    
    imprime_registradores_continua:
        la $a0, str_pc # $a0 <- endereco de str_pc 
        jal imprime_linha #imprime "PC: "
        la $s0, instrucoes_pc # $s0 <- endereco de PC do simulador
        lw $s0, ($s0) # $s0 <- conteudo de PC do simulador
        add $a0, $zero, $s0  # $a0 <- $s0
        jal imprime_hexadecimal #imprime o PC do simulador
        addi $a0, $zero, 10 #carrega o argumento do procedimento - ascii "\n" = 10
        jal imprime_display #imprime no display
        la $a0, str_ir # $a0 <- endereco de str_ir
        jal imprime_linha #imprime "IR: "
        la $s0, instrucoes_ir  # $s0 <- endereco de IR do simulador
        lw $s0, ($s0) # $s0 <- conteudo de IR do simulador
        add $a0, $zero, $s0 # $a0 <- $s0
        jal imprime_hexadecimal #imprime o IR do simulador
        addi $a0, $zero, 10 #carrega o argumento do procedimento - ascii "\n" = 10
        jal imprime_display #imprime no display
        
    
    #epilogo
    imprime_registradores_loop_exit:
        lw $s0, 0($sp) #$s0 <- valor anterior de $s0
        lw $s1, 4($sp) #$s1 <- valor anterior de $s1
        lw $s2, 8($sp) #$s2 <- valor anterior de $s2
        lw $ra, 12($sp) #$ra <- valor anterior de $ra
        addiu $sp, $sp, 16 #ajusta pilha novamente
        jr $ra #retorna para onde o procedimento foi chamado
        
################################################################################
# Procedimento que imprime no display um valor em hexadecimal (uma palavra de 4 bytes)
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = valor hexadecimal (uma palavra de 4 bytes)
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $ra
#   $sp + 4 : $s0
#   $sp + 8 : $s1
#   $sp + 12 : $s2
#   $sp + 16 : $s3
imprime_hexadecimal:
    #prologo
    addiu $sp, $sp, -20 #ajusta a pilha
    sw $ra, 0($sp) #salva $ra na pilha
    sw $s0, 4($sp) #salva $s0 na pilha
    sw $s1, 8($sp) #salva $s1 na pilha
    sw $s2, 12($sp) #salva $s2 na pilha
    sw $s3, 16($sp) #salva $s3 na pilha

    #corpo
    add $s0, $a0, $zero #$s0 <- $a0
    li $s1, 0xF0000000 # s1 <- 0XF00000000
    li $s2, 1 # $s2 <- 1
    li $a0, 48 # $a0 <- 48
    jal imprime_display #chama funcao para imprimir no display "0"
    li $a0, 120 # $a0 <- 120
    jal imprime_display #chama funcao para imprimir no display "X"
    imprime_hexadecimal_loop:
        beqz $s1, imprime_hexadecimal_fim # se $s1 = 0, pula para o fim
        and $s3, $s0, $s1 # $s3 <- operacao AND para isolar bits do valor armazenado em $s0
        beq $s2, 1, desloca_28 # se $s2 = 1, pula para funcao para deslocar 28 bits 
        beq $s2, 2, desloca_24 # se $s2 = 2, pula para funcao para deslocar 24 bits 
        beq $s2, 3, desloca_20 # se $s2 = 3, pula para funcao para deslocar 20 bits 
        beq $s2, 4, desloca_16 # se $s2 = 4, pula para funcao para deslocar 16 bits 
        beq $s2, 5, desloca_12 # se $s2 = 5, pula para funcao para deslocar 12 bits 
        beq $s2, 6, desloca_8 # se $s2 = 6, pula para funcao para deslocar 8 bits 
        beq $s2, 7, desloca_4 # se $s2 = 7, pula para funcao para deslocar 4 bits 
        j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_28:
            srl $s3, $s3, 28 #desloca 28 bits de $s3 para direita 
            j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_24:
            srl $s3, $s3, 24 #desloca 24 bits de $s3 para direita 
            j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_20:
            srl $s3, $s3, 20 #desloca 20 bits de $s3 para direita 
            j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_16:
            srl $s3, $s3, 16 #desloca 15 bits de $s3 para direita 
            j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_12:
            srl $s3, $s3, 12 #desloca 12 bits de $s3 para direita 
            j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_8:
            srl $s3, $s3, 8 #desloca 8 bits de $s3 para direita 
            j imprime_hexadecimal_loop_continua # pula para a continuacao do loop
        desloca_4:
            srl $s3, $s3, 4  #desloca 4 bits de $s3 para direita 
        imprime_hexadecimal_loop_continua:
            add $a0, $s3, $zero # $a0 <- $s3 com os bits deslocados
            jal imprime_caracter_hexa # imprime caracter armazenado em $a0
            srl $s1, $s1, 4 # $s1 <- $s1 deslocando 4 bits para direita
            addi $s2, $s2, 1 # incrementa $s2 em 1
            j imprime_hexadecimal_loop #pula para o inicio do loop
        
        
    #epilogo
    imprime_hexadecimal_fim:
        lw $ra, 0($sp) #$ra <- valor anterior de $ra
        lw $s0, 4($sp) #$s0 <- valor anterior de $s0
        lw $s1, 8($sp) #$s1 <- valor anterior de $s1
        lw $s2, 12($sp) #$s2 <- valor anterior de $s2
        lw $s3, 16($sp) #$s3 <- valor anterior de $s3
        addiu $sp, $sp, 20 #ajusta a pilha novamente
        jr $ra #pula para instrucao armazenada em $ra
   
################################################################################
# Procedimento que imprime no display um caracter considerando um unico digito hexadecimal
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = unico digito hexadecimal
# Retorno:
#   sem retorno
# Mapa da pilha:
#   $sp + 0 : $ra
#   $sp + 4 : $s0
imprime_caracter_hexa:
    #prologo
    addiu $sp, $sp, -8 #ajusta a pilha
    sw $ra, 0($sp) #salva $ra na pilha
    sw $s0, 4($sp) #salva $s0 na pilha

    add $s0, $a0, $zero # $s0 <- $a0
    bge $s0, 0x0000000A, imprime_caracter_hexa_letra # se $s0 for maior ou igual a A, entao imprime uma letra hexadecimal no display
    j imprime_caracter_hexa_numero #pula para imprimir um numero no display
    imprime_caracter_hexa_letra:
        addi $a0, $s0, 55 # $a0 <- $s0 + 55, pois o codigo ascii de A e' 65 e de F e' 70
        jal imprime_display # imprime no display
        j imprime_caracter_hexa_fim
    imprime_caracter_hexa_numero:
        addi $a0, $s0, 48 # $a0 <- $s0 + 48, pois o codigo ascii de 0 e' 48
        jal imprime_display #imprime no display
    
    #epilogo
    imprime_caracter_hexa_fim:
        lw $ra, 0($sp) #$ra <- valor anterior de $ra
        lw $s0, 4($sp) #$s0 <- valor anterior de $s0
        addiu $sp, $sp, 8 #ajusta a pilha novamente
        jr $ra


################################################################################
# Procedimento que transforma um numero inteiro em string
#   este procedimento foi retirado e adaptado do site https://www.daniweb.com/programming/software-development/code/435631/integer-to-string-in-mips-assembly
# ------------------------------------------------------------------------------
# argumentos:
#   $a0 = inteiro a ser convertido
#   $a1 = ponteiro para o espaco de memoria que vai conter o inteiro convertido em string
# Retorno:
#   $v0 = numero de caracteres na string
int_to_string:
  bnez $a0, int_to_string.non_zero
  nop
  li   $t0, '0'
  sb   $t0, 0($a1)
  sb   $zero, 1($a1)
  li   $v0, 1
  jr   $ra
    int_to_string.non_zero:
      addi $t0, $zero, 10
      li $v0, 0
        
      bgtz $a0, int_to_string.recurse
      nop
      li   $t1, '-'
      sb   $t1, 0($a1)
      addi $v0, $v0, 1
      neg  $a0, $a0
    int_to_string.recurse:
      addi $sp, $sp, -24
      sw   $fp, 8($sp)
      addi $fp, $sp, 8
      sw   $a0, 4($fp)
      sw   $a1, 8($fp)
      sw   $ra, -4($fp)
      sw   $s0, -8($fp)
      sw   $s1, -12($fp)
       
      div  $a0, $t0       # $a0/10
      mflo $s0            # $s0 = quociente
      mfhi $s1            # $s1 = resto  
      beqz $s0, int_to_string.write
    int_to_string.continue:
      move $a0, $s0  
      jal int_to_string.recurse
      nop
    int_to_string.write:
      add  $t1, $a1, $v0
      addi $v0, $v0, 1    
      addi $t2, $s1, 0x30 # converte para ASCII
      sb   $t2, 0($t1)    # armazena no buffer
      sb   $zero, 1($t1)
      
    int_to_string.exit:
      lw   $a1, 8($fp)
      lw   $a0, 4($fp)
      lw   $ra, -4($fp)
      lw   $s0, -8($fp)
      lw   $s1, -12($fp)
      lw   $fp, 8($sp)    
      addi $sp, $sp, 24
      jr $ra
      nop
