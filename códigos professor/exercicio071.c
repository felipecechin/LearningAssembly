//*******************************************************************************
// exercicio071.c                 Copyright (C) 2018 Giovani Baratto
// This program is free software under GNU GPL V3 or later version
// see http://www.gnu.org/licences
//
// Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
// e-mail: giovani.baratto@ufsm.br
// versão: 0.1
// Descrição: Exemplo de procedimentos que chamam outros procedimentos. Para
// compilar este código, descomente as linhas 21 e 57 (#include e printf). 
// Executando este programa você deverá ver uma mensagem b=8.
// Documentação:
// Assembler: MARS
// Revisões:
// Rev #  Data           Nome   Comentários
// 0.1    12.04.2017     GBTO   versão inicial 
//*******************************************************************************
//       1         2         3         4         5         6         7         8
//345678901234567890123456789012345678901234567890123456789012345678901234567890 
 
// #include <stdio.h>
 
 int a;             // variável global a
 
 
 int p3(int* a)     // o argumento é um ponteiro para a (*a = 5)
 {     
     *a = *a + 3;   // somamos 3 ao valor de a (a = 8)
     return *a;     // retornamos o valor 8 
 }
 
 int p2(int a)      // a = 3
 {
     int tmp;       // variável local tmp
     
     tmp = a + 2;   // tmp = 5
     p3(&tmp);      // chamamos p3 com o endereço de tmp (ponteiro para tmp)
     return tmp;
 }
 
 int p1(int a)      // a = 2
 {
     int tmp;       // variável local tmp
     
     tmp = a + 1;   // tmp = 3
     tmp = p2(tmp); // chamamos p2 com uma cópia de tmp (tmp=3)
     return tmp;
 }
 
 int main(void)
 {
     int b;         // variável local b
     
     a = 2;         // inicializamos a variável a com 2
     a = p1(a);     // chamamos o procedimento p1 com uma cópia da variável a, o valor 2
     b = a;         // atribuímos a variável local b o valor de a
     // printf("b=%d\n", b);
     return 0;
 }
