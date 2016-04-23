
{Hi Dudes...

Dunno if you can do anything with this code; It sure is crappy!
Anywayzz, this kinda looks nice on my computer but I'm not sure
on how the timing will be on other systems... Might cause a
helluvalot of flicker...

Well, what can I say? Have Phun 8-)}

Program LooksLikeSomeTextModeEffectsToMe_YeahIGuessSo;

{$X+,E-,N-,I-,S-,R-,O-}

Type BigChar=Array[1..3,1..3] of Byte;
     MoveRecord = Record
                   XPos,YPos : Integer;
                   XSpeed,YSpeed : Integer;
                   Counter : Word;
                  End;

Const BigFont : Array[1..40] of BigChar = (
      ((192,196,182),(195,196,191),(188,032,188)), {A}
      ((192,196,182),(195,196,191),(193,196,183)), {B}
      ((192,196,190),(187,032,032),(193,196,190)), {C}
      ((192,190,187),(187,032,187),(193,196,183)), {D}
      ((192,196,190),(195,190,032),(193,196,190)), {E}
      ((192,196,190),(195,190,032),(188,032,032)), {F}
      ((192,196,190),(187,194,182),(193,196,183)), {G}
      ((189,032,189),(195,196,191),(188,032,188)), {H}
      ((194,196,190),(032,187,032),(194,196,190)), {I}
      ((192,196,182),(195,196,191),(188,032,198)), {J}
      ((192,196,182),(195,196,191),(188,032,198)), {K}
      ((189,032,032),(187,032,032),(193,196,190)), {L}
      ((192,196,182),(187,189,187),(188,188,188)), {M}
      ((192,196,182),(187,032,187),(188,032,188)), {N}
      ((192,196,182),(187,032,187),(193,196,183)), {O}
      ((192,196,182),(187,032,187),(187,194,183)), {P}
      ((192,196,182),(195,196,191),(188,032,198)), {Q}
      ((192,196,182),(195,196,198),(188,032,197)), {R}
      ((192,196,190),(193,196,182),(194,196,183)), {S}
      ((194,196,190),(032,187,032),(032,188,032)), {T}
      ((189,032,189),(187,032,187),(193,196,183)), {U}
      ((189,032,187),(188,032,187),(194,196,183)), {V}
      ((189,189,189),(187,188,187),(193,196,183)), {W}
      ((189,032,189),(192,196,183),(188,032,187)), {X}
      ((189,032,189),(193,196,183),(032,188,032)), {Y}
      ((192,196,182),(195,196,191),(188,032,198)), {Z}
      ((032,032,032),(032,032,032),(185,185,185)), {...}
      ((032,187,032),(032,188,032),(032,185,032)), {!}
      ((192,196,182),(187,186,187),(193,196,183)), {0}
      ((194,182,032),(032,187,032),(194,196,190)), {1}
      ((194,196,182),(192,196,183),(193,196,190)), {2}
      ((194,196,182),(032,194,191),(194,196,183)), {3}
      ((189,032,189),(193,196,191),(032,032,188)), {4}
      ((192,196,190),(193,196,182),(194,196,183)), {5}
      ((192,196,190),(195,196,182),(193,196,183)), {6}
      ((194,196,182),(032,032,187),(032,032,188)), {7}
      ((192,196,182),(195,196,191),(193,196,183)), {8}
      ((192,196,182),(193,196,191),(194,196,183)), {9}
      ((032,032,032),(194,196,190),(032,032,032)), {-}
      ((032,032,032),(032,032,032),(032,032,032)));{ }

      ScrWidth : Word = 160;
      StartDat : Array[0..15] of Byte = (8,0,1,2,3,4,5,6,7,6,5,4,3,2,1,0);
      BarRes   = 270;
      BarRad   = 260 Div 2;
      Mes      : String = '';

      ScrollMessage : String = 'Hi there possoms! howst hanging. How about some simple TextMode Scroller.    ';
      ScrollOfs     : Byte = 9;
      ScrollPos     : Byte = 0;
      CharOfs       : Byte = 2;


Var BarCols  : Array[0..399] of Byte;
    Bars     : Array[1..4] of Record
                               StartCol : Byte;
                               YPos     : Integer;
                              End;
    BarPos   : Array[1..BarRes] of Integer;
    MyPal    : Array[0..767] of Byte;
    MoveMes,MoveSplit : MoveRecord;

Procedure CharMap; Assembler;
Asm
  db      0,0,0,0,0,0,192,240,248,252,252,60,60,60,60,60           {┐}
  db      60,60,60,60,60,252,252,248,240,192,0,0,0,0,0,0           {┘}
  db      24,60,60,60, 60,60,60,60, 60,60,60,24, 0,0,0,0
  db      0,0,0,0, 60,126,255,255, 255,255,126,60, 0,0,0,0
  db      96,240,240,248, 248,120,124,60, 60,62,30,31, 31,15,15,6
  db      60,60,60,60,60,60,60,60,60,60,60,60,60,60,60,60
  db      60,60,60,60,60,60,60,60,60,60,60, 24, 0,0,0,0
  db      0,0,0,0, 24,60,60,60,60,60,60,60,60,60,60,60
  db      0,0,0,0,0,0,254,255,255,254,0,0,0,0,0,0           {->}
  db      60,60,60,60,60,124,252,252,252,252,124,60,60,60,60,60
  db      0,0,0,0,0,0,3,15,31,63,62,62,60,60,60,60          {┌}
  db      60,60,60,60,62,62,63,31,15,3,0,0,0,0,0,0          {└}
  db      0,0,0,0,0,0,127,255,255,127,0,0,0,0,0,0           {<-}
  db      60,60,60,60,60,62,63,63, 63,63,62,60, 60,60,60,60 {├}
  db      0,0,0,0,0,0,255,255,255,255,0,0,0,0,0,0           {─}
  db      240,120,120,120,120,120,60,60, 60,60,60,24, 0,0,0,0   {\}
  db      60,60,60,60,60,252,252,248,240,224,224,240,240,240,240,240
End;

Procedure SetCharset; Assembler;
Asm
 Push Bp
 mov ax,cs                       { Set character set for logo }
 mov es,ax
 mov bp,cs:offset charmap
 mov ax,1100h
 mov bx,1000h
 mov cx,17
 mov dx,182
 int 10h
 Pop Bp
End;

Procedure Standard_Palette; Assembler;  { DP ][ Ext. Compatible }
Asm
db 0,0,0,0,0,42,0,42,0,0,42,42,42,0,0,42,0,42,42,21,0,42,42
db 42,21,21,21,21,21,63,21,63,21,21,63,63,63,21,21,63,21,63,63,63,21,63
db 63,63,59,59,59,55,55,55,52,52,52,48,48,48,45,45,45,42,42,42,38,38,38
db 35,35,35,31,31,31,28,28,28,25,25,25,21,21,21,18,18,18,14,14,14,11,11
db 11,8,8,8,63,0,0,59,0,0,56,0,0,53,0,0,50,0,0,47,0,0,44
db 0,0,41,0,0,38,0,0,34,0,0,31,0,0,28,0,0,25,0,0,22,0,0
db 19,0,0,16,0,0,63,54,54,63,46,46,63,39,39,63,31,31,63,23,23,63,16
db 16,63,8,8,63,0,0,63,42,23,63,38,16,63,34,8,63,30,0,57,27,0,51
db 24,0,45,21,0,39,19,0,63,63,54,63,63,46,63,63,39,63,63,31,63,62,23
db 63,61,16,63,61,8,63,61,0,57,54,0,51,49,0,45,43,0,39,39,0,33,33
db 0,28,27,0,22,21,0,16,16,0,52,63,23,49,63,16,45,63,8,40,63,0,36
db 57,0,32,51,0,29,45,0,24,39,0,54,63,54,47,63,46,39,63,39,32,63,31
db 24,63,23,16,63,16,8,63,8,0,63,0,0,63,0,0,59,0,0,56,0,0,53
db 0,1,50,0,1,47,0,1,44,0,1,41,0,1,38,0,1,34,0,1,31,0,1
db 28,0,1,25,0,1,22,0,1,19,0,1,16,0,54,63,63,46,63,63,39,63,63
db 31,63,62,23,63,63,16,63,63,8,63,63,0,63,63,0,57,57,0,51,51,0,45
db 45,0,39,39,0,33,33,0,28,28,0,22,22,0,16,16,23,47,63,16,44,63,8
db 42,63,0,39,63,0,35,57,0,31,51,0,27,45,0,23,39,54,54,63,46,47,63
db 39,39,63,31,32,63,23,24,63,16,16,63,8,9,63,0,1,63,0,0,63,0,0
db 59,0,0,56,0,0,53,0,0,50,0,0,47,0,0,44,0,0,41,0,0,38,0
db 0,34,0,0,31,0,0,28,0,0,25,0,0,22,0,0,19,0,0,16,60,54,63
db 57,46,63,54,39,63,52,31,63,50,23,63,47,16,63,45,8,63,42,0,63,38,0
db 57,32,0,51,29,0,45,24,0,39,20,0,33,17,0,28,13,0,22,10,0,16,63
db 54,63,63,46,63,63,39,63,63,31,63,63,23,63,63,16,63,63,8,63,63,0,63
db 56,0,57,50,0,51,45,0,45,39,0,39,33,0,33,27,0,28,22,0,22,16,0
db 16,63,58,55,63,56,52,63,54,49,63,53,47,63,51,44,63,49,41,63,47,39,63
db 46,36,63,44,32,63,41,28,63,39,24,60,37,23,58,35,22,55,34,21,52,32,20
db 50,31,19,47,30,18,45,28,17,42,26,16,40,25,15,39,24,14,36,23,13,34,22
db 12,32,20,11,29,19,10,27,18,9,23,16,8,21,15,7,18,14,6,16,12,6,14
db 11,5,10,8,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,49,10,10,49,19,10,49,29,10,49,39,10,49,49,10,39,49
db 10,29,49,10,19,49,10,10,49,12,10,49,23,10,49,34,10,49,45,10,42,49,10
db 31,49,10,20,49,11,10,49,22,10,49,33,10,49,44,10,49,49,10,43,49,10,32
db 49,10,21,49,10,10,63,63,63
End;

Function KeyPressed : Boolean; Assembler;
Asm
 Mov Ah,0Bh
 Int 21h
End;

Procedure WriteBigMessage(X,Y,Color:Byte; Message:String);
Var B,D    : Byte;
    ScrOfs : Word;

Const TransTab : Array[0..255] of Byte =
      (32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32, {15}
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32, {31}
       40,28,32,32,32,32,32,32,32,32,32,32,32,39,27,32, {47}
       29,30,31,32,33,34,35,36,37,38,32,32,32,32,32,32, {63}
       32, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15, {79}
       16,17,18,19,20,21,22,23,24,25,26,32,32,32,32,32, {95}
       32, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15, {111}
       16,17,18,19,20,21,22,23,24,25,26,32,32,32,32,32, {127}
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,
       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32);

Begin
 Mes:=Message;
 D:=Length(Mes);
 If D=0 then Exit;
 ScrOfs:=(Y-1)*ScrWidth+2*X+2;

  Asm
    Mov Ax,$B800              { Set starting address on screen }
    Mov Es,Ax
    Mov Di,ScrOfs

    Mov B,1                   { Start with first character ;-) }
   @StringLoop:
    Xor Bh,Bh
    Mov Bl,B
    Mov Al,Ds:[Offset Mes+Bx] { Get Next Character from String }
    Mov Bx,Offset TransTab
    XLat                      { And translate into real value }

    Dec Al
    Mov Bl,9
    Mul Bl
    Mov Si,Offset BigFont     { Character offset in Font-Table }
    Add Si,Ax

    Mov Ah,Color
    Mov Dx,3
   @FontColumn:               { Loop three Rows... }
    Mov Cx,3
   @FontRow:                  { and three columns }
    LodsB
    StosW
    Loop @FontRow
    Add Di,ScrWidth
    Sub Di,6
    Dec Dx
    Jnz @FontColumn

    Mov Ax,3                  { prepare screen address for next character }
    Mul ScrWidth
    Sub Di,Ax
    Add Di,8

    Inc B
    Mov Al,D
    Cmp B,Al
    Jng @StringLoop
   End;
End;

Procedure WriteCenteredBig(Y,Color:Byte; Message:String);
Begin
 WriteBigMessage(((ScrWidth Div 4)+2)-(Length(Message)*2),Y,Color,Message);
End;

Procedure MakePal;
Var A:Word;
Begin
 For A:=0 to 255 do
  Begin
   Mypal[A]:=Mem[Seg(Standard_Palette):Ofs(Standard_Palette)+A*3];
   Mypal[A+256]:=Mem[Seg(Standard_Palette):Ofs(Standard_Palette)+A*3+1];
   Mypal[A+512]:=Mem[Seg(Standard_Palette):Ofs(Standard_Palette)+A*3+2];
  End;
End;

Procedure SetupBars;
Var V : Integer;
Begin
  For V:=1 To BarRes Do
   BarPos[V]:=Round(BarRad*Sin((2*Pi/BarRes)*V))+BarRad+1;
 For V:=1 to 4 do
  With Bars[V] do
   Begin
    StartCol:=V*16;
    if v=3 then startcol:=96;
    if v=4 then startcol:=144;
    if v=5 then startcol:=160;
    YPos:=14*V;
   End;
 For V:=304 to 319 do Barcols[V]:=(15-(V mod 16))+160;
 For V:=320 to 335 do Barcols[V]:=V mod 16+160;
End;

Procedure UpdateBars;
Var V,U,Y : Integer;
Begin
  For V:=1 To 4 do
   For U:=0 to 31 do BarCols[barpos[Bars[V].YPos]+U]:=0;
 For V:=1 To 4 do
  Begin
   Inc(Bars[V].YPos);
    If Bars[V].YPos>BarRes then Bars[V].YPos:=1;
   Y:=BarPos[Bars[V].YPos];
   For U:=0 to 15 do BarCols[Y+U]:=Bars[V].StartCol+15-U;
   For U:=16 to 31 do BarCols[Y+U]:=Bars[V].StartCol+U-16;
  End;
End;

Procedure ColorBars; Assembler;
Asm
  MOV DX,$03DA
  In AL,DX
  MOV DX,$03C0   { assume color nr 0 = default Text background.. }
  MOV AL,$20+0   { set color nr 0 .. }
  OUT DX,AL
  MOV AL,0       { .. to DAC color 0 }
  OUT DX,AL

  Xor SI,SI
  CLI
  MOV DX,$03DA
  MOV AH,8
@Wau: in AL,DX
  TEST AL,AH
  JNZ @Wau       { wait Until out of retrace }
@Wai: in AL,DX
  TEST AL,AH
  JZ @Wai        { wait Until inside retrace }
@Doline:
  STI
  Mov Bl,[Offset BarCols+Si]
  Mov Di,Offset MyPal
  Add Di,Bx

  MOV DX,$03C8  { point to DAC[0] }
  MOV AL,0
  OUT DX,AL

  CLI
  MOV DX,$03DA
@Whu: in AL,DX
  RCR AL,1
  JC @Whu       { wait Until out of horizontal retrace }
@Whi: in AL,DX
  RCR AL,1
  JNC @Whi      { wait Until inside retrace }

  Inc Si        { line counter }
                { prepare For color effect }

  MOV DX,$03C9
  Mov Al,[Di]
  OUT DX,Al   { Dynamic Red }
  Mov Al,[Di+256]
  OUT DX,AL   { Dynamic Green }
  mov Al,[Di+512]
  OUT DX,AL   { Dynamic Blue }

  CMP SI,296  { Paint just about 3/4 screen }
  JBE  @doline
  STI
End;

PROCEDURE Split(Row:Integer);
BEGIN
     ASM
        mov dx,$3d4
        mov ax,row
        mov bh,ah
        mov bl,ah
        and bx,201h
        mov cl,4
        shl bx,cl
        mov ah,al
        mov al,18h
        out dx,ax
        mov al,7
        cli
        out dx,al
        inc dx
        in al,dx
        sti
        dec dx
        mov ah,al
        and ah,0efh
        or ah,bl
        mov al,7
        out dx,ax
        mov al,9
        cli
        out dx,al
        inc dx
        in al,dx
        sti
        dec dx
        mov ah,al
        and ah,0bfh
        shl bh,1
        shl bh,1
        or ah,bh
        mov al,9
        out dx,ax
     END;
END;

Procedure FastWrite(Col,Row,Attrib:Byte; Str:String);
Var MemPos : Word;
    A      : Byte;
Begin
 MemPos:=(Col*2)+(Row*ScrWidth)-ScrWidth-2;
 A:=Length(Str);
  For A:=1 to Length(Str) do
   Begin
    MemW[$B800:MemPos]:=Ord(Str[A])+Attrib*256;
    MemPos:=MemPos+2;
   End;
End;

Procedure CenterWrite(Y,Color:Byte;Mes:String);
Begin
 FastWrite(41-((Length(Mes)-1) Div 2),Y,Color,Mes);
End;

Procedure CursorOff; Assembler;
Asm
  Mov Ax,0100h
  Mov Cx,2000h
  Int 10h
End;

Procedure CursorOn; Assembler;
Asm
  Mov Ax,0100h
  Mov Cx,0607h
  Int 10h
End;

Procedure ScrollText(Nr:Word); Assembler;
Asm
  mov ax,nr
  mov cx,$40
  mov es,cx
  mov cl,es:[$85]
  div cl
  mov cx,ax
  mov dx,es:[$63]
  push dx
  mov al,$13
  cli
  out dx,al
  inc dx
  in al,dx
  sti
  mul cl
  shl ax,1
  mov es:[$4e],ax
  pop dx
  mov cl,al
  mov al,$c
  out dx,ax
  mov al,$d
  mov ah,cl
  out dx,ax
  mov ah,ch
  mov al,8
  out dx,ax
End;


Function ReadKey : Char; Assembler;
Asm
 Mov Ah,07h
 Int 21h
End;

Procedure SetHorizOfs(Count:Byte);
Var I : Byte;
Begin
 I:=Port[$3DA];
 Port[$3C0]:=$33;
 Port[$3C0]:=StartDat[Count Mod 16];
End;

Procedure Sync; Assembler;
Asm
  Mov Dx,3DAh
@LoopIt:
  In Al,Dx
  Test Al,8
  Jz @LoopIt
End;

Procedure DoubleWidth; Assembler;
Asm
 Mov Dx,3D4h
 Mov Ax,5013h
 Out Dx,Ax
 Mov ScrWidth,320
End;

Procedure SetPELReset; Assembler;
Asm
 Mov Dx,3DAh
 In Al,Dx
 Mov Dx,3C0h
 Mov Al,30h
 Out Dx,Al
 Mov Al,2Ch
 Out Dx,Al
End;

Procedure SetView(X,Y:Word);
Var PelPos:Byte;
Begin
 PelPos:=StartDat[X Mod 9];
 X:=(X Div 9)+(Y Div 16)*160;
  Asm
    Mov Dx,3D4h    { Set Screen offset in bytes:}
    Mov Bx,X
    Mov Ah,Bh
    Mov Al,0Ch
    Out Dx,Ax
    Mov Ah,Bl
    Inc Al
    Out Dx,Ax

    Mov Al,8       { Set Y-Offset within Character-Row: }
    Mov Bx,Y
    And Bl,15
    Mov Ah,Bl
    Out Dx,Ax

    Mov Dx,3C0h    { Set X-Offset within Character-Column: }
    Mov Al,33h
    Out Dx,Al
    Mov Al,PelPos
    Out Dx,Al
 End;
End;

Procedure UpDateScroller;
Begin
 If ScrollOfs=9 then
  Begin
   ScrollOfs:=0;

   Move(Mem[$B800:14*320+2],Mem[$B800:14*320],3*320-2);
   Inc(CharOfs);
   If CharOfs=4 then
    Begin
     Inc(ScrollPos);
     WriteBigMessage(84-CharOfs,15,14,ScrollMessage[ScrollPos]);
     If ScrollPos=Length(ScrollMessage) Then ScrollPos:=0;
     CharOfs:=0;
    End;
  End
 else
  Inc(ScrollOfs,9);
 SetHorizOfs(ScrollOfs);
End;



Begin
 CursorOff;
 FillChar(Mem[$B800:0000],4000,0);

  With MoveMes do
   Begin
    YPos:=110;
    YSpeed:=2;
    XPos:=40*8;
    XSpeed:=3;
    Counter:=0;
   End;

  With MoveSplit Do
   Begin
    YPos:=295;
    YSpeed:=2;
   End;

 DoubleWidth;
 SetPelReset;
 ScrollText(MoveMes.YPos);
 Split(MoveSplit.YPos);
 Setupbars;
 MakePal;
 SetCharSet;
 Sync;
 CenterWrite(1,14,#194'─────────────────────────────────────────────────────────────────────────────'#190);
 WriteBigMessage(1,2,4,'GAME - Gotta Get it!');
 CenterWrite(5,14,#194'─────────────────────────────────────────────────────────────────────────────'#190);

  Repeat
    With MoveMes do
     Begin
       If (YPos>80) and (YPos<200) then
        Inc(YPos,YSpeed)
       else
        Begin
         YSpeed:=-YSpeed;
         YPos:=YPos+YSpeed;
        End;
      Counter:=1-Counter;
       If Odd(Counter) then
        Begin
         If (XPos<40*8) or (XPos>40*8+150) then XSpeed:=-XSpeed;
         Inc(XPos,XSpeed);
        End;
     End;

    With MoveSplit do
     Begin
       If (YPos>290) and (YPos<325) then
        Inc(YPos,YSpeed)
       else
        Begin
         YSpeed:=-YSpeed;
         YPos:=YPos+YSpeed;
        End;
     End;

   UpdateBars;
   ScrollText(MoveMes.YPos);
   UpDateScroller;
   Split(MoveSplit.YPos);
   ColorBars;
  Until KeyPressed;

  While KeyPressed do Readkey;
 Split(400);
 SetView(0,0);
 ScrollText(0);
  Asm
   Mov Ax,3
   Int 10h
  End;
 FastWrite(1,1,15,'Bye from World of Wonders!');
 Writeln;
 CursorOn;
End.
