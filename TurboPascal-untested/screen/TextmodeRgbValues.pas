(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0090.PAS
  Description: TextMode RGB Values
  Author: JUSTIN KING
  Date: 05-26-95  23:30
*)

{
> I have a program (demo) that was created in turbo
> pascal assembler, and it has
> a ascii picture, with 3 colors of vga light bars in
> the background, does
> anyone know how this person did it?


   I wrote part of the following program .......
}

Uses Crt;

Type
  PalType = Array [1..3] Of Byte;
  Ground  = (Fore,Back);

Const
                      {R,G,B}
  LtBlue  : PalType = (0,0,63);
  Purple  : PalType = (20,5,52);     { You can create your own colors   }
  DkBlue  : PalType = (0,0,15);      { by experimenting with the values }
  DkGray  : PalType = (21,21,21);
  LtGreen : PalType = (0,63,0);
  LtRed   : PalType = (63,0,0);
  Pink    : PalType = (40,8,13);
  Orange  : PalType = (55,5,5);



Procedure VGAColor (ColorName : PalType ; ColorToAlter : Byte ; Grnd : Ground);

  Procedure SetPalColor (PalReg : Word ; T : PalType);
    Var
      R,G,B : Byte;
    Begin
      R := T[1];
      G := T[2];
      B := T[3];
      Asm
        mov ax,1010h
        mov bx,[PalReg]
        mov ch,[G]
        mov cl,[B]
        mov dh,[R]
        int 10h
      End;
    End;

  Procedure GetPalColor (PalReg : Word); Assembler;
    Asm
      mov ax,1015h
      mov bx,[PalReg]
      int 10h
      mov [Green],ch
      mov [Blue],cl
      mov [Red],dh
    End;

  Function RegNo (Cnt : Integer) : Integer;
    Begin
     If (Cnt In [0..5,7]) Then
       RegNo := Cnt
     Else Begin
       If Cnt = 6 Then
         RegNo:= 20
       Else
         RegNo:= Cnt + 48;
     End;
   End;

  Var
    PalReg : Word;

  Begin
    PalReg:= RegNo(ColorToAlter);
    SetPalColor(PalReg,ColorName);
    If Grnd = Fore Then
      TextColor(ColorToAlter)
    Else
      TextBackGround(ColorToAlter);
  End;

Procedure RestoreColors;
  Begin
    TextMode(Co80);
  End;


Var
  S : String;
Begin
  TextBackGround(0);
  ClrScr;
  S := 'THIS IS A TEST OF THE VGA TEXT COLORS';
  VGAColor(DKBlue,1,Back);
  WriteLn(S);
  VGAColor(Pink,2,Fore);
  WriteLn(S);
  VGAColor(Purple,12,Fore);
  WriteLn(S);
  VGAColor(LtRed,9,Fore);
  WriteLn(S);
  ReadKey;
  RestoreColors;      { <- Take this line out and watch what happens! :) }
End.

