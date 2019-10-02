//*******************************************************************************
// exercicio073.c                 Copyright (C) 2018 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// versão: 0.1
// Descrição: lê palavras de uma string.
// Documentação:
// Assembler: MARS
// Revisões:
// Rev #  Data           Nome   Comentários
// 0.1    01.10.2019     GBTO   versão inicial 
//*******************************************************************************
//       1         2         3         4         5         6         7         8
//345678901234567890123456789012345678901234567890123456789012345678901234567890 
 
#include <stdio.h>


char caractere_eh_delimitador(char ch, char* delim)
{
    while(*delim && (*delim != ch)) delim++;
    return *delim;
}


/* retorna uma palavra em buffer, lida de str e um ponteiro para o primeiro
   caractere após a palavra lida*/
char* leia_palavra(char *str, char *buffer, char *delim)
{
    //verificamos se existe um delimitador antes da palavra.
    while(*str && (caractere_eh_delimitador(*str, delim))) str++;
    // lemos a palavra até um delimitador ou o fim da string
    while(*str && (!caractere_eh_delimitador(*str, delim))) *buffer++ = *str++;
    *buffer = 0; 
    return str;
}

    char str[] = "   \tteste1\tteste2 123.233\t\t\ta  122  r1\n01  fim x,y, z, \t w ";
    char delim[] = " \t\n,";
    char buffer[256];
    
int main(void)
{

    char *ptr;
    ptr = str;
    
    printf("String: [%s]\n", str);
    printf("Lendo as palavras da string\n");
    while(1){
        ptr = leia_palavra(ptr, buffer, delim);
        if(*buffer) printf("[%s]", buffer); else break;
    }
    printf("\n");
    return 0;
}
 
