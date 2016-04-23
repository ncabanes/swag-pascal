{
>I only have one credit card, a visa, and the code works right for it.
>So I'm sending this to the list for two purposes, to share this with
>everyone and to get anybody else who finds it useful to take a look at
>it and see if it's running right for other card types (and to catch any
>dumb mistakes I've committed).

Your code is probably working fine, I didn't look at it, but I thought
I'd post you some code I've used in applications since Turbo Pascal
3.0 and it's worked like a champ... although a little dated in structure.
It also returns the card type--Visa, MC, Amex or Discover.
}

FUNCTION VALIDCCARD(A:STRING):BOOLEAN;
VAR C:CHAR;
    T:WORD;
    X,M,N:BYTE;
  BEGIN
    VALIDCCARD:=FALSE;
    A:=NUMBERS(A);
    IF A[0]<#4 THEN EXIT;
    C:=A[LENGTH(A)];
    DEC(A[0]);
    M:=2;
    T:=0;
    FOR X:=LENGTH(A) DOWNTO 1 DO
      BEGIN
        N:=(BYTE(A[X])-48);
        N:=N*M;
        IF N>9
          THEN BEGIN
                 N:=N-10;
                 INC(T);
               END;
        T:=T+N;
        M:=3-M;
      END;
    T:=(TRUNC((T+9)/10)*10)-T;
    IF T=(BYTE(C)-48) THEN VALIDCCARD:=TRUE;
  END;

FUNCTION  NUMBERS(C:STRING):STRING;
VAR A:STRING;
    X:INTEGER;
  BEGIN {strips out all non-numeric digits from a string}
    A:='';
    IF LENGTH(C)>0 THEN FOR X:=1 TO LENGTH(C) DO
      IF C[X] IN ['0'..'9'] THEN A:=A+C[X];
    NUMBERS:=A;
  END;

FUNCTION VALOF(CONST A:STRING):LONGINT;
VAR I:INTEGER;
    L:COMP;
  BEGIN {guarantee no crash VAL function}
    VAL(A,L,I);
    IF I<>0 THEN L:=0;
    IF L>HIGH(LONGINT) THEN L:=HIGH(LONGINT);
    IF L<LOW(LONGINT) THEN L:=LOW(LONGINT);
    VALOF:=TRUNC(L);
  END;

FUNCTION CCARDTYPE(A:STRING):BYTE;
{returns
  0:invalid credit card type
  1:VISA
  2:MC
  3:American Express
  4:Discover
  5:Unknown type}
VAR W:LONGINT;
  BEGIN
    A:=NUMBERS(A);
    IF VALIDCCARD(A)
      THEN BEGIN
             W:=VALOF(COPY(A,1,6));
             IF (W>=510000) AND (W<=559999) AND (BYTE(A[0])=16)
               THEN CCARDTYPE:=2 {Mastercard}
               ELSE
             IF (W>=400000) AND (W<=499999) AND (BYTE(A[0])=13)
               THEN CCARDTYPE:=1 {VISA}
               ELSE
             IF (W>=400000) AND (W<=499999) AND (BYTE(A[0])=16)
               THEN CCARDTYPE:=1 {VISA}
               ELSE
             IF (W>=340000) AND (W<=349999) AND (BYTE(A[0])=15)
               THEN CCARDTYPE:=3 {American Express}
               ELSE
             IF (W>=370000) AND (W<=379999) AND (BYTE(A[0])=15)
               THEN CCARDTYPE:=3 {American Express}
               ELSE
             IF (W>=601100) AND (W<=601199) AND (BYTE(A[0])=16)
               THEN CCARDTYPE:=4 {Discover}
               ELSE CCARDTYPE:=5;{Unknown type}
           END
      ELSE CCARDTYPE:=0;
  END;

