Program Frac3d;

{
	See Frac3D1.pas for info.

   Programmed by Ryan Jones (Dios@Rworld.Com)
}

Uses
	CRT;

Const
	ZInc = 25;
   ZOfs = 256;
   ZScale = 256;
   Sc = 0.7;

Type
	Triangle =
   	Record
      	X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3 : Real;
      End;

Var
	Segment, Ofset : Word;
	Tris : Array[0..100] Of Triangle;
   Trin,
	l, n, hn : Word;
   db : Pointer;
   Ch : Char;

Procedure SetScreenPtr(Var Ptr);
	Begin
   	Segment := Seg(Ptr);
      Ofset := Ofs(Ptr);
   End;

Procedure SetVideoMode( N : Byte ); Assembler;
   Asm
      MOV AH, 0
      MOV AL, N
      INT $10
   End;

Procedure Credit;
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

Procedure _Line(X1, Y1, X2, Y2, C : Integer); Assembler;
{ It's more efficient than it looks}
   Asm
      CLI

      MOV AX, X2
      CMP AX, X1
      JNE @Sk
      MOV AX, Y2
      CMP AX, Y1
      JE @NoLine
      @Sk:

      MOV AX, X2
      CMP AX, X1
      JG @Skip
      MOV BX, X1
      MOV X2, BX
      MOV X1, AX
      MOV AX, Y2
      MOV BX, Y1
      MOV Y2, BX
      MOV Y1, AX
      @Skip:
      MOV DX, C      { Set DX To _GetColor }
      MOV AX, Segment
      MOV ES, AX     { Set ES To $A000 }
      MOV BX, Y1
      XCHG BH, BL
      MOV AX, BX
      SHR BX, 1
      SHR BX, 1
      ADD BX, AX
      ADD BX, X1   { Set BX == X + (Y*320) }
      ADD BX, Ofset

      MOV SI, X2
      MOV DI, Y2
      SUB SI, X1
      SUB DI, Y1

      @ABCD:
      CMP DI, $8888
      JB @CD
      @AB:
      NEG DI
      CMP SI, DI
      JB @A
      @B:
      MOV CX, SI
      MOV AX, SI
      SHR AX, 1
      @Loopa:
      MOV ES:[BX], DL
      INC BX
      ADD AX, DI
      CMP AX, SI
      JLE @Skipa
      SUB BX, 320
      SUB AX, SI
      @Skipa:
      LOOP @Loopa
      JMP @Exit
      @A:
      MOV CX, DI
      MOV AX, DI
      SHR AX, 1
      @Loopb:
      MOV ES:[BX], DL
      SUB BX, 320
      ADD AX, SI
      CMP AX, DI
      JLE @Skipb
      ADD BX, 1
      SUB AX, DI
      @Skipb:
      LOOP @Loopb
      JMP @Exit
      @CD:
      CMP SI, DI
      JB @D
      @C:
      MOV CX, SI
      MOV AX, SI
      SHR AX, 1
      @Loopc:
      MOV ES:[BX], DL
      INC BX
      ADD AX, DI
      CMP AX, SI
      JLE @Skipc
      ADD BX, 320
      SUB AX, SI
      @Skipc:
      LOOP @Loopc
      JMP @Exit
      @D:
      MOV CX, DI
      MOV AX, DI
      SHR AX, 1
      @Loopd:
      MOV ES:[BX], DL
      ADD BX, 320
      ADD AX, SI 
      CMP AX, DI
      JLE @Skipd
      ADD BX, 1
      SUB AX, DI
      @Skipd:
      LOOP @Loopd
      JMP @Exit
      @NoLine:
      MOV AX, X2
      MOV BX, Y2
      MOV DX, C
      MOV BX, Y1
      XCHG BH, BL
      MOV AX, BX
      SHR BX, 1
      SHR BX, 1
      ADD BX, AX
      ADD BX, X1
      MOV AX, Segment
      MOV ES, AX

      @Exit:
      MOV ES:[BX], DL
      STI
   End;

Procedure FillDW(Var A; L : Word; Dw : LongInt); Assembler;
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

Procedure ClipLine(x1, y1, x2, y2, c : Word);
	Begin
   	If (x1 > 0) and (x1 < 320) and
      	(y1 > 0) and (y1 < 200) and
         (x2 > 0) and (x2 < 320) and
         (y2 > 0) and (y2 < 200) then _Line(x1, y1, x2, y2, c);
   End;

Procedure AddTris(n : Word);
	Var OX1, OY1, OZ1, OX2, OY2, OZ2, OX3, OY3, OZ3 : Real;
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
         	End;
         ClipLine(160+SX1, 100+SY1, 160+SX2, 100+SY2, 15);
         ClipLine(160+SX2, 100+SY2, 160+SX3, 100+SY3, 15);
         ClipLine(160+SX3, 100+SY3, 160+SX1, 100+SY1, 15);
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

Begin
	SetVideoMode($13);
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
   Repeat
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
   SetVideoMode($03);
   Credit;
End.