Program Frac3d1;

{
	The only problem with this program is that i didn't optimize it, so
   you should have at least a pentium (or a fast 486) to run it; however,
   i did use 32-bit instructions, so it can't be run on 8086's or 8088's
	at all.

   Runs in 320x200x256

	Features:
		A double buffer
		32-Bit moves and fills
      Weak color layering and palette changing
      3D graphics (using slow Real numbers)
      3D fractal
      A pretty fast polygon statement

   Programmed by Ryan Jones (Dios@Rworld.com)
}

Uses
	CRT;

Const
	ZInc = 25;
   ZOfs = 256;
   ZScale = 256;
   Sc = 0.7;
	Red = 0;
	Green = 1;
	Blue = 2;

Type
	Palette = Array[0..255, Red..Blue] Of Byte;
	ABType = Record LSide, RSide : Integer; End;
	Triangle =
   	Record
      	X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3 : Real;
         Color : Byte;
      End;

Var
	Segment, Ofset : Word; { Double Buffer info }
	Tris : Array[0..100] Of Triangle; { Triangle info }
   Trin,                             { # of triangles }
	l, n, hn : Word;                  { fractal stuff }
   db : Pointer; { Double Buffer }
   Ch : Char;

Procedure SetScreenPtr(Var Ptr); { lets Poly know where to do its stuff }
	Begin
   	Segment := Seg(Ptr);
      Ofset := Ofs(Ptr);
   End;

Procedure SetVideoMode( N : Byte ); Assembler; { sets the video mode }
   Asm
      MOV AH, 0
      MOV AL, N
      INT $10
   End;

Procedure Credit; { lets you know who made it }
	Var
		St : String;
   	n : Word;
	Begin
   	SetVideoMode($03);
      Textcolor(15);
      Textbackground(0);
      St := 'Qsphsbnnfe!cz!Szbo!Kpoft/';
      n := 1;
      Repeat
      	St[n] := Chr(Ord(St[n]) - 1);
         n := n + 1;
      Until n > Length(St);
      Writeln(St);
      Textcolor(7);
      WriteLn;
   End;

Procedure DisplayPalette(P : Palette; First, Last : Word); Assembler; { updates palette }
	Asm
     	CLI
     	PUSH DS
     	PUSH SI
      LDS SI, P

      MOV CX, First
      ADD SI, CX
      ADD SI, CX
      ADD SI, CX

      MOV AX, Last
      SUB AX, First
      INC AX
      MOV CX, AX
      SHL CX, 1
      ADD CX, AX

      MOV AX, First
      MOV DX, $3C8
      OUT DX, AL
      INC DX
      REP OUTSB
      POP SI
      POP DS
      STI
   End;

Procedure Fill(Var A; L : Word; B : Byte); Assembler; { similar to FillChar }
	Asm
   	CLI
      CLD
      LES DI, A
      MOV CX, L
   	MOV AL, BYTE PTR B
      REP STOSB
      STI
   End;

Procedure FillDW(Var A; L : Word; Dw : LongInt); Assembler;
{ similar to FillChar, except uses Double Words }
	Asm
   	CLI
      CLD
      LES DI, A
      MOV CX, L
      DB $66; MOV AX, WORD PTR Dw
      DB $66; REP STOSW
      STI
   End;

Procedure MoveDW(Var A, B; L : Word); Assembler;
{ similar to Move, except uses Double Words }
	Asm
   	CLI
      CLD
      PUSH DS
      LDS SI, A
      LES DI, B
      MOV CX, L
      DB $66; REP MOVSW
      POP DS
      STI
   End;

Procedure Poly(x1, y1, x2, y2, x3, y3, x4, y4, c1 : Integer);
{ draws a Polygon or Triangle }
	Type
      ScrType = Array[0..199, 0..319] Of Byte;

	Var
		Xa : Array[0..199] Of ABType;
      x, y, dx : LongInt;
      L, R : Integer;
      Scr : ^ScrType;
      c : Byte;

   Procedure CalcSideX(x1, y1, x2, y2 : Integer);
   	Var t : Integer;
   	Begin
         If y1 = y2 Then
         	Begin
            	If (y1 >= 0) And (y1 <= 199) Then
               	Begin
			         	If (x1 < Xa[y1].LSide) Then Xa[y1].LSide := x1;
			         	If (x1 > Xa[y1].RSide) Then Xa[y1].RSide := x1;
			         	If (x2 < Xa[y1].LSide) Then Xa[y1].LSide := x2;
			         	If (x2 > Xa[y1].RSide) Then Xa[y1].RSide := x2;
                  End;
               Exit;
            End;
      	If y1 > y2 Then
				Begin
            	t := x1;
               x1 := x2;
               x2 := t;
            	t := y1;
               y1 := y2;
               y2 := t;
				End;
      	dx := LongInt(x2 - x1) SHL 16 DIV (y2-y1);
         y := y1;
         x := LongInt(x1) SHL 16;
         repeat
         	If (y >= 0) And (y <= 199) Then
					Begin
		         	If (Integer(x SHR 16) < Xa[y].LSide) Then Xa[y].LSide := x SHR 16;
		         	If (Integer(x SHR 16) > Xa[y].RSide) Then Xa[y].RSide := x SHR 16;
               End;
         	x := x + dx;
            y := y + 1;
         until y > y2;
      End;

	Begin
   	Scr := Ptr(Segment, Ofset);
   	FillDW(Xa[0], 200, $80007FFF);
      CalcSideX(x1, y1, x2, y2);
      CalcSideX(x2, y2, x3, y3);
      CalcSideX(x3, y3, x4, y4);
      CalcSideX(x4, y4, x1, y1);
      c := c1;
      y := 0;
      repeat
      	L := Xa[y].LSide;
         R := Xa[y].RSide;
         If L < 0 Then L := 0;
         If R > 319 Then R := 319;
{         If Not ((L > 319) Or (R < 0)) Then Fill(Scr^[y, L], (R-L)+1, c);}
			If Not ((L > 319) Or (R < 0)) Then
         	Asm
            	MOV AX, Segment
               MOV ES, AX
            	MOV AX, WORD PTR y
               XCHG AH, AL
               MOV BX, AX
               SHR AX, 1
               SHR AX, 1
               ADD BX, AX
               ADD BX, WORD PTR L
               ADD BX, Ofset
               MOV CX, WORD PTR R
               SUB CX, WORD PTR L
               INC CX
               MOV DX, c1
               @L1:
               	ADD ES:[BX], DL
                  INC BX
               LOOP @L1
            End;
         y := y + 1;
      until y > 199;
   End;

Procedure AddTris(n : Word);
	Var
		OX1, OY1, OZ1, OX2, OY2, OZ2, OX3, OY3, OZ3 : Real;
   	OC : Byte;
	Begin
   	With Tris[n] Do
      	Begin
         	OX1 := X1;
         	OY1 := Y1;
         	OZ1 := Z1;
         	OX2 := X2;
         	OY2 := Y2;
         	OZ2 := Z2;
         	OX3 := X3;
         	OY3 := Y3;
         	OZ3 := Z3;
            OC := Color + 24;
         End;
   	With Tris[Trin] Do
      	Begin
         	X1 := OX1;
            Y1 := OY1;
            Z1 := OZ1+ZInc;
         	X2 := OX1*2/3+OX2/3;
            Y2 := OY1*2/3+OY2/3;
            Z2 := OZ2+ZInc;
         	X3 := OX1*2/3+OX3/3;
            Y3 := OY1*2/3+OY3/3;
            Z3 := OZ3+ZInc;
            Color := OC;
         End;
   	With Tris[Trin+1] Do
      	Begin
         	X1 := OX2*2/3+OX1/3;
         	Y1 := OY2*2/3+OY1/3;
         	Z1 := OZ1+ZInc;
         	X2 := OX2;
         	Y2 := OY2;
         	Z2 := OZ2+ZInc;
         	X3 := OX2*2/3+OX3/3;
         	Y3 := OY2*2/3+OY3/3;
         	Z3 := OZ3+ZInc;
            Color := OC;
         End;
   	With Tris[Trin+2] Do
      	Begin
         	X1 := OX3*2/3+OX1/3;
         	Y1 := OY3*2/3+OY1/3;
         	Z1 := OZ1+ZInc;
         	X2 := OX3*2/3+OX2/3;
         	Y2 := OY3*2/3+OY2/3;
         	Z2 := OZ2+ZInc;
         	X3 := OX3;
         	Y3 := OY3;
         	Z3 := OZ3+ZInc;
            Color := OC;
         End;
      Trin := Trin + 3;
   End;

Procedure DrawTris;
	Var SX1, SY1, SX2, SY2, SX3, SY3, n : Word;
	Begin
   	SetScreenPtr(db^);
      FillDW(db^, 16000, $00000000);
   	n := 0;
   	Repeat
      	With Tris[n] Do
         	Begin
		      	SX1 := Round((ZScale*X1)/(Z1-ZOfs));
		      	SY1 := Round((ZScale*Y1)/(Z1-ZOfs));
		      	SX2 := Round((ZScale*X2)/(Z2-ZOfs));
		      	SY2 := Round((ZScale*Y2)/(Z2-ZOfs));
		      	SX3 := Round((ZScale*X3)/(Z3-ZOfs));
		      	SY3 := Round((ZScale*Y3)/(Z3-ZOfs));
		         Poly(160+SX1, 100+SY1, 160+SX2, 100+SY2, 160+SX3, 100+SY3, 160+SX1, 100+SY1, Color);
         	End;
         n := n + 1;
      Until n = Trin;
      MoveDW(db^, Ptr($A000, 0)^, 16000);
   End;

Procedure Rotate(Var X, Y, ang : Real);
	Var XX, YY : Real;
	Begin
   	XX := X*Cos(ang)+Y*Sin(ang);
      YY := Y*Cos(ang)-X*Sin(ang);
      X := XX;
      Y := YY;
   End;

Procedure RotateTris(ang : Real);
	Var n : Word;
	Begin
   	n := 0;
      Repeat
      	With Tris[n] Do
         	Begin
            	Rotate(X1, Z1, ang);
            	Rotate(X2, Z2, ang);
            	Rotate(X3, Z3, ang);
            End;
      	n := n + 1;
      Until n = Trin;
   End;

Procedure RotateTrisb(ang : Real);
	Var n : Word;
	Begin
   	n := 0;
      Repeat
      	With Tris[n] Do
         	Begin
            	Rotate(X1, Y1, ang);
            	Rotate(X2, Y2, ang);
            	Rotate(X3, Y3, ang);
            End;
      	n := n + 1;
      Until n = Trin;
   End;

Procedure RotateTrisc(ang : Real);
	Var n : Word;
	Begin
   	n := 0;
      Repeat
      	With Tris[n] Do
         	Begin
            	Rotate(Y1, Z1, ang);
            	Rotate(Y2, Z2, ang);
            	Rotate(Y3, Z3, ang);
            End;
      	n := n + 1;
      Until n = Trin;
   End;

Procedure ExpandTris;
	Const Scd = 0.95;
	Var n : Word;
	Begin
   	n := 0;
      Repeat
      	With Tris[n] Do
         	Begin
            	X1 := X1 * Scd;
            	Y1 := Y1 * Scd;
            	X2 := X2 * Scd;
            	Y2 := Y2 * Scd;
            	X3 := X3 * Scd;
            	Y3 := Y3 * Scd;
            End;
         n := n + 1;
      Until n = Trin;
   End;

Procedure Pal; { sets up my palette }
	Var P : Palette;
   	n : Word;
	Begin
   	n := 0;
      repeat
      	P[n, Red] := n div 4;
      	P[n, Green] := 0;
      	P[n, Blue] := n div 6+21;
         n := n + 1;
      until n = 256;
      DisplayPalette(P, 1, 255);
   End;

Begin
	SetVideoMode($13);
   Pal;
   GetMem(db, 64000);
   With Tris[0] Do
   	Begin
      	X1 := 0;
      	Y1 := 86;
      	Z1 := 0;
      	X2 := 100;
      	Y2 := -86;
      	Z2 := 0;
      	X3 := -100;
      	Y3 := -86;
      	Z3 := 0;
		   X1 := X1 * Sc;
		   Y1 := Y1 * Sc;
		   Z1 := Z1 * Sc;
		   X2 := X2 * Sc;
		   Y2 := Y2 * Sc;
		   Z2 := Z2 * Sc;
		   X3 := X3 * Sc;
		   Y3 := Y3 * Sc;
		   Z3 := Z3 * Sc;
	   	Color := 24;
      End;
   Trin := 1;
   l := 3;
   Repeat
   	n := hn;
      hn := Trin;
   	Repeat
      	AddTris(n);
      	n := n + 1;
      Until n = hn;
   	l := l - 1;
   Until l = 0;
   Tris[0].Color := 24;

   Repeat { main loop }
   	n := 0;
   	Repeat
	   	DrawTris;
	      RotateTris(Pi/72);
         n := n + 1;
      Until KeyPressed Or (n = 144);
   	n := 0;
   	Repeat
	   	DrawTris;
	      RotateTrisb(Pi/72);
         n := n + 1;
      Until KeyPressed Or (n = 144);
   	n := 0;
   	Repeat
	   	DrawTris;
	      RotateTrisc(Pi/72);
         n := n + 1;
      Until KeyPressed Or (n = 144);
   Until KeyPressed;

   Repeat Ch := ReadKey Until Not KeyPressed;
   n := 150;
   Repeat { outro }
   	DrawTris;
      ExpandTris;
      RotateTris(Pi/72);
      RotateTrisb(Pi/72);
      RotateTrisc(Pi/72);
      n := n - 1;
   Until (n = 0) Or KeyPressed;
   If KeyPressed Then Repeat Ch := ReadKey Until Not KeyPressed;
   SetVideoMode($03);
   Credit;
End.