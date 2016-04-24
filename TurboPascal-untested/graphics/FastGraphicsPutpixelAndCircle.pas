(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0249.PAS
  Description: Fast graphics - PutPixel and Circle
  Author: RYAN JONES
  Date: 03-04-97  13:18
*)

{
Hello,
	I just recently downloaded the entire SWAG library; and, as I was
looking through the graphics library for things to learn, I noticed that
people were/are looking for a fast Circle command, but all the Circle
commands I saw were written in High-Level language. Not only that, but
they used REAL arithmetic(slow). So I thought I'd send you a much faster
Circle command, and the fastest PutPixel command possible. The Circle
command could use a bit of optimization, but I'm sure it's faster that
any of the one's you already have. Sorry for the run-on sentences.
		Thank You
		-Ryan Jones
}

Program FastCircle;

{
   Here's a small demo of a fast Putpixel statement
   and a very fast Circle statement.

   I believe the PutPixel command is the fastest possible.

   The Circle command is very fast, but could use some of
   optimization. (It should be fast enough for anyone's uses)

   Programmed by Ryan Jones
}

Uses
	CRT;

Const
	_Hollow = 0;	_Filled = 1;

Var
	Segment : Word;
   Ch : Char;

Procedure SetVideoMode(n : Byte); Assembler;
   Asm
      MOV AH, 0
      MOV AL, n
      INT $10
   End;

Procedure _PutPixel(X, Y, C : Word); Assembler;
   Asm
		MOV AX, Segment
	   MOV ES, AX

      MOV AX, Y
      MOV BX, X
      XCHG AH, AL
      ADD BX, AX
      SHR AX, 1
      SHR AX, 1
      ADD BX, AX

	   MOV AX, C
	   MOV ES:[BX], AL
   End;

Procedure Circle(Control, X, Y, Radius, Color : Word); Assembler;
	Asm
   	MOV AX, Segment
      MOV ES, AX
      MOV SI, Radius     	{ XI := R }
      MOV DI, 0      { YI := 0 }
      MOV CX, Radius
      SHR CX, 1      { N := XI Div 2 }
      MOV AX, Control
      CMP AX, 1
      JE @Filled

@Hollow:

      @Loope:
			{putpix}
		   MOV BX, 320
		   MOV AX, Y
         SUB AX, DI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         SUB BX, SI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         SUB AX, SI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         SUB BX, DI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         SUB AX, DI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         ADD BX, SI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         SUB AX, SI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         ADD BX, DI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         ADD AX, DI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         SUB BX, SI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         ADD AX, SI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         SUB BX, DI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         ADD AX, DI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         ADD BX, SI
         MOV DX, Color
         MOV ES:[BX], DL
		   MOV BX, 320
		   MOV AX, Y
         ADD AX, SI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         ADD BX, DI
         MOV DX, Color
         MOV ES:[BX], DL
			{putpix}
         ADD CX, DI  { N := N + YI }
         CMP CX, SI  { If N > XI Then }
         JNG @Skip   { Do This }
           DEC SI    	{ XI := XI - 1 }
           SUB CX, SI	{ N := N - XI }
         @Skip:
         INC DI      { YI := YI + 1 }
      CMP DI, SI
      JNG @Loope
      JMP @End

@Filled:

      @Loopeb:
			{putpix}
		   MOV BX, 320
		   MOV AX, Y
         SUB AX, DI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         SUB BX, SI
         MOV DX, CX           { Part 2 }
         XCHG BX, DI
         MOV AX, Color
         MOV CX, SI
			SHL CX, 1
         inc cx
			REP STOSB
         MOV DI, BX
         MOV CX, DX

		   MOV BX, 320
		   MOV AX, Y
         ADD AX, DI
		   MUL BX
		   MOV BX, AX
		   ADD BX, X
         SUB BX, SI
         MOV DX, CX           { Part 3 }
         XCHG BX, DI
         MOV AX, Color
         MOV CX, SI
			SHL CX, 1
         inc cx
			REP STOSB
         MOV DI, BX
         MOV CX, DX
			{putpix}
         ADD CX, DI  { N := N + YI }
         CMP CX, SI  { If N > XI Then }
         JNG @Skipb   { Do This }
           DEC SI    	{ XI := XI - 1 }
           SUB CX, SI	{ N := N - XI }
				{putpix}
			   MOV BX, 320
			   MOV AX, Y
	         SUB AX, SI
            dec ax
			   MUL BX
			   MOV BX, AX
			   ADD BX, X
   	      SUB BX, DI
	         MOV DX, CX        { Part 1 }
	         MOV AX, Color
	         MOV CX, DI
				SHL CX, 1
            inc cx
	         XCHG BX, DI
				REP STOSB
	         MOV DI, BX
	         MOV CX, DX

			   MOV BX, 320
			   MOV AX, Y
	         ADD AX, SI
            inc ax
			   MUL BX
			   MOV BX, AX
			   ADD BX, X
   	      SUB BX, DI
	         MOV DX, CX
	         MOV AX, Color         { Part 4 }
	         MOV CX, DI
				SHL CX, 1
            inc cx
	         XCHG BX, DI
				REP STOSB
	         MOV DI, BX
	         MOV CX, DX
				{putpix}
         @Skipb:
         INC DI      { YI := YI + 1 }
      CMP DI, SI
      JNG @Loopeb

      @End:
   End;

Begin
	Randomize;
	SetVideoMode($13);
   Segment := $A000;
   Ch := #0;
   Repeat
   	If Ch <> #0 Then Ch := ReadKey;
   	_PutPixel(Random(320), Random(200), Random(256));
   	If KeyPressed Then Ch := ReadKey Else Ch := #0;
   Until Ch = #27;
   Ch := #0;
   Repeat
   	If Ch <> #0 Then Ch := ReadKey;
   	Circle(_Hollow, Random(280)+20, Random(160)+20, Random(20), Random(256));
   	If KeyPressed Then Ch := ReadKey Else Ch := #0;
   Until Ch = #27;
   Ch := #0;
   Repeat
   	If Ch <> #0 Then Ch := ReadKey;
   	Circle(_Filled, Random(280)+20, Random(160)+20, Random(20), Random(256));
   	If KeyPressed Then Ch := ReadKey Else Ch := #0;
   Until Ch = #27;
   SetVideoMode($03);
   WriteLn('Programmed by Ryan Jones');
End.


