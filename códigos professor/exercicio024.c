/*******************************************************************************
# exercicio024.c               Copyright (C) 2019 Giovani Baratto
# This program is free software under GNU GPL V3 or later version
# see http://www.gnu.org/licences
#
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# versão: 0.1
# Descrição: Programa que zera os elementos de dois vetores de inteiros. O 
#            procedimento clear1 usa índices e o procedimento clear2 ponteiros.
# Documentação:
# Compilador: gcc
# Revisões:
# Rev #  Data           Nome   Comentários
# 0.1    30.05.2019     GBTO   versão inicial 
#******************************************************************************/
#include <stdio.h>
#include <stdlib.h>


int vetor1[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
int vetor2[] = {-1, -2, -3, -4, -5, -6, -7, -8, -9, -10};

void clear1 (int array[ ], int size);
void clear2 (int * array, int size);

/******************************************************************************/
int main(void)
/******************************************************************************/
{
    clear1(vetor1, 10);
    clear2(vetor2, 10);
    return 0;
}

/******************************************************************************/
void clear1 (int array[ ], int size){
/******************************************************************************/    
    int i;
    for(i=0; i<size; i=i+1) array[i] = 0;
}

/******************************************************************************/
void clear2 (int * array, int size){
/******************************************************************************/    
    int *p;
    for(p=&array[0]; p<&array[size]; p=p+1) *p = 0;
}
