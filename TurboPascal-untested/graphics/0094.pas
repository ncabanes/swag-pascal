{
  For the people who requested a faster sprite drawing program, here it is.
This program is just Bas van Gaalen's sprite program with a few modifications
to make it run quicker.  I am currently working on this program, so that it
will be able to handle more sprites than one..

------------------- CUT HERE ----------------------
}

PROGRAM Game_sprites;
{ By Bas van Gaalen, Holland, PD }
{$G+}

USES crt;

CONST w=16; h=16; sega000= $0A000;

TYPE
  SPRBUF = Array[1..256] of Byte;

VAR
  Bckbuf,Sprite : SPRBUF;
  px,py : Word;
  CCOS,CSIN : Array [0..360] of WORD;

CONST
  SegS : Word = SEG(Sprite);
  OfsS : Word = OFS(Sprite);
  SegB : Word = SEG(BckBuf);
  OfsB : Word = OFS(BckBuf);


PROCEDURE setpal(col,r,g,b : byte); assembler;
ASM
  mov dx,03c8h
  mov al,col
  out dx,al
  inc dx
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
END;

PROCEDURE retrace; assembler;
ASM
  mov  dx,03dah
@l2:
  in   al,dx
  test al,8
  jz   @l2
END;

PROCEDURE putsprite(x,y:word);
BEGIN
  ASM
    CLI
    PUSH DS
    MOV  AX,0A000h
    MOV  ES,AX
    MOV  DS,SegB
    MOV  AX,PY
    SHL  AX,6
    MOV  DI,AX
    SHL  AX,2
    ADD  DI,AX
    ADD  DI,PX
    MOV  DX,1010h
    MOV  AX,OfsB
    MOV  SI,AX
    XOR  AX,AX
@1:
    MOV  AL,[DS:SI]     { Display the sprite buffer over the old sprite }
    MOV  [ES:DI],AL
    INC  DI
    INC  SI
    DEC  DL
    JNZ  @1
    ADD  DI,304
    MOV  DL,16
    DEC  DH
    JNZ  @1
    MOV  AX,Y
    SHL  AX,6
    MOV  DI,AX
    SHL  AX,2
    ADD  DI,AX
    ADD  DI,X
    MOV  DX,1010h
    MOV  AX,OfsB
    MOV  SI,AX
    XOR  AX,AX
@2:                           { Store the background into the Sprite Buffer }
    MOV  AL,[ES:DI]
    MOV  [DS:SI],AL
    INC  DI
    INC  SI
    DEC  DL
    JNZ  @2
    ADD  DI,304
    MOV  DL,16
    DEC  DH
    JNZ  @2
    MOV  AX,Y
    SHL  AX,6
    MOV  DI,AX
    SHL  AX,2
    ADD  DI,AX
    ADD  DI,X
    MOV  DX,1010h
    MOV  AX,OfsS
    MOV  SI,AX
    XOR  AX,AX
@3:
    CMP  [DS:SI],AH      { Display the Sprite at it's new location }
    JZ   @4
    MOV  AL,[DS:SI]
    MOV  [ES:DI],AL
@4:
    INC  DI
    INC  SI
    DEC  DL
    JNZ  @3
    ADD  DI,304
    MOV  DL,16
    DEC  DH
    JNZ  @3
    POP  DS
    STI
  END;
  px:=x; py:=y;
END;

(* This procedure I added to speed up the rotation used when displaying the
sprite.  This is not nessary, but usefull *)

PROCEDURE Calc_Cos_Sin;
VAR I : word;
BEGIN
  FOR I := 0 to 360 DO
  BEGIN
    CCOS[I] := ROUND(COS(PI*I/180)*150);
    CSIN[I] := ROUND(SIN(PI*I/180)*75);
  END;
END;

var i,j:word;

BEGIN
  ASM
    mov ax,13h
    int 10h
  END;
  Calc_Cos_Sin;
  for i:=1 to 255 do setpal(i,255-i div 6,255-i div 4,20);
  fillchar(bckbuf,sizeof(bckbuf),0);
  { create background }
  for i:=0 to 319 do
    for j:=0 to 199 do
      mem[sega000:j*320+i]:=round(5+0.4*i+0.4*j)+random(10);
  { create random sprite }
  randomize;
  for i:=1 to 256 do
    sprite[i]:=random(255);
  { clear middle part }
  for i:=6 to 10 do
    for j:=6 to 10 do
      sprite[j*w+i]:=0;
  i:=0;
  { save first old backup screen }
  px:=0; py:=0;

(*  The following assembly code is required to save the sprites background when
it is first displayed.  I am still trying to figure how to incorperate this
into the main assembly code for displaying the sprite *)

  ASM
    CLI
    PUSH BP
    PUSH DS

    MOV  AX,SegA000
    MOV  ES,AX
    MOV  DS,SegB

    MOV  AX,0
    SHL  AX,6
    MOV  DI,AX
    SHL  AX,2
    ADD  DI,AX
    ADD  DI,0

    MOV  DX,1010h
    MOV  AX,OfsB
    MOV  BP,AX
    XOR  AX,AX
@2:
    MOV  AL,[ES:DI]
    MOV  [DS:BP],AL
    INC  DI
    INC  BP
    DEC  DL
    JNZ  @2
    ADD  DI,304
    MOV  DL,16
    DEC  DH
    JNZ  @2

    POP  DS
    POP  BP
    STI
  END;
  { move sprite over background }
  repeat
    retrace;
    putsprite(150+CCOS[I],100+CSIN[I]);
    i:=1+i mod 360;
  until keypressed;
  ASM
    mov ax,3h
    int 10h
  END;
END.

