(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0218.PAS
  Description: Drawing Objects in Mode 13h
  Author: DIRK WESSELS
  Date: 05-26-95  23:22
*)

{
I see so many messages of people wanting help on drawing in Mode 13H
So mayB we can start a thread here for people that know as little as myself.

Following is a complete program to place you in Mode 13H and to draw an
object 100 times.

My knowledge of ASM is very limited so mayB you would like to make some
suggestions on how to do this faster & also how I should keep the object
in memory in stead of using an array.
BUT, for the beginners this should be a good start - I hope ??
}

Var
   X,Y,I    : Integer;
   Object1  : array[1..40000] of Byte;
   CH       : Char;

Procedure SetMode13H;
  Begin
    ASM
      mov   ah,0
      mov   al,13H
      int   10h
    END
  End;

Procedure DrwObj(X,Y,Width : Integer;Size : Word);
  Var
     ROWS : Byte;

  Begin
     ROWS := SIZE DIV WIDTH;
    ASM
      push    ds
      mov     ax,y         {  place X,Y in DI for startpos }
      mov     bx,320       {  " }
      mul     bx           {  " }
      add     ax,x         {  " }
      mov     di,ax        {  " }
      mov     ax,0A000H    { Mode 13h Screen Address }
      mov     es,ax        { into es }

      mov     AX, SEG object1;     { Let DS:SI point to Object 2 B drawn }
      MOV     DS,AX                {  " }
      MOV     AX, OFFSET OBJECT1   { " }
      MOV     SI,AX                { " }
     @DRAWROW:
      MOV     CX,WIDTH
      REP     MOVSB
      ADD     DI,320
      SUB     DI,WIDTH
      DEC     ROWS
      CMP     ROWS,1
      JNZ     @DRAWROW
      pop     ds
    END;
  End;

BEGIN
  SetMode13H;
  For y := 1 to 100 do
    Begin
      For x := 1 to 20000 do
        Begin
          Object1[x] := x*Y;
          Object1[x+20000] := x*y+x;
        End;
        DrwObj(1,1,300,39900);
    End;
  Readln;
END.

