    LJMP START
    ORG 100H
START:
    LCALL LCD_CLR
    ;piersza liczba 
    LCALL LICZBA12
    PUSH 00
    ; zapisz znak na stosie i wyswietl operacje
    LCALL WAIT_KEY
    PUSH ACC 
    ;wybieranie operacji i wyswietlenie znaku operacji
    CJNE A,#10,SUB
    MOV A,#'+'
    SJMP SIGN
SUB:
    CJNE A,#11,MUL
    MOV A,#'-'
    SJMP SIGN
MUL:
    CJNE A,#12,DIV
    MOV A,#'*'
    SJMP SIGN
DIV:
    MOV A,#'/'
SIGN: 
    ;zapis na ekranie wybranego znaku operacji 
    LCALL WRITE_DATA
    ;druga liczba 
    LCALL LICZBA12
    PUSH 00
    ;wyswietlenie znaku '='
    MOV A,#'='
    LCALL WRITE_DATA
    ;zamiana stosu- aby A bylo na gorze a B na dole (np:A+B)
    POP B
    POP ACC ; do akumulaotr rodzaj obliczen
    PUSH B
    ;obliczenie wyniku, ACC=A+,B-,C*,D/
    CJNE A,#10,SUB_ARTM
    POP B
    POP ACC
    ADD A,B
    SJMP RESULT
SUB_ARTM:
    CJNE A,#11,MUL_ARTM
    POP B
    POP ACC
    CLR C
    SUBB A,B
    JC MINUS_NUMBER
    SJMP RESULT
MINUS_NUMBER: 
    ;wyswietlenie znaku '-'
    PUSH ACC
    MOV A,#'-'
    LCALL WRITE_DATA
    ;zamiana z U2 na wartość bezwzgledną
    POP ACC
    CPL A
    MOV B,#1
    ADD A,B
    SJMP RESULT
MUL_ARTM:
    CJNE A,#12,DIV_ARTM
    POP B
    POP ACC
    MUL AB

    SJMP RESULT
DIV_ARTM:
    POP ACC
    CJNE A,#0,NO_ZERO_DIV
    LCALL ZERO_DIV
    SJMP $
NO_ZERO_DIV:
    POP ACC
    DIV AB
    PUSH B
    LCALL BCD
    ;wyświetlenie reszty z dzielenia
    MOV A,#'r'
    LCALL WRITE_DATA
    POP ACC
RESULT: ;wyświetlenie wyniku w BCD
    LCALL BCD
    SJMP $


    
;**********************************Funkcje dodatkowe**********************************
LICZBA12:
    LCALL WAIT_KEY
    MOV B,#10
    MUL AB
    MOV R0,A
    LCALL WAIT_KEY
    ADD A,R0
    MOV R0,A
    LCALL BCD
    RET



BCD:    ;funkcja bcd
    ; ACC-liczba do zamiany np: 93 albo 255
    MOV R1,A
    MOV B,#100
    CLR C
    SUBB A,B
    JC SKIPP
    MOV A,R1
    MOV B,#100
    DIV AB
    PUSH ACC
    LCALL WRITE_HEX
    POP ACC
    MOV B,#100
    MUL AB
    MOV B,A
    MOV A,R1
    CLR C
    SUBB A,B
    MOV R1,A
SKIPP: ;liczba 2 cyfrowa
    MOV A,R1
    MOV B,#10
    DIV AB
    SWAP A
    ADD A,B
    LCALL WRITE_HEX
    RET



ZERO_DIV:
    MOV A,#'E'
    LCALL WRITE_DATA
    MOV A,#'R'
    LCALL WRITE_DATA
    MOV A,#'R'
    LCALL WRITE_DATA
    MOV A,#'O'
    LCALL WRITE_DATA
    MOV A,#'R'
    LCALL WRITE_DATA
    RET
    NOP