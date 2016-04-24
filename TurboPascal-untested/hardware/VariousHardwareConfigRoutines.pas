(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0046.PAS
  Description: Various Hardware Config Routines
  Author: WILLIAM ARTHUR BARATH
  Date: 05-26-95  23:08
*)

Unit Hardware;

{$o+}

{ This source is Copyright 1994 by William Arthur Barath
 Permission to use parts of this program is freely granted
 for NON-COMMERCIAL programs, however, if you want to use
 any of this in a commercial program, you are required to
 either give me visible credit in your program's startup,
 or send me $10.}


{**************************************************************************
**}

Interface

{**************************************************************************
**}

Type
 Tpointer= Record
  pOfs,pSeg:Word;
  end;
Var
 Timer    : Word Absolute $0000:$046c;

Procedure Wait(t:Word);
  {waits for a specified number of ticks to pass.  18/second}
Procedure VideoMode(M:Word);
  {set the current video display adapter display mode}
Procedure GetRGB(reg:Word;Var R;Var G;Var B);
Procedure SetRGB(register:Word;Red,Green,Blue:Byte);
 {set the color of the specified DAC register; RGB in 0..63}
Procedure WaitHBL;
 {Wait for _start_ of horizontal blanking interval}
Procedure WaitVBL;
 {Wait for _start_ of vertical blanking interval}
Procedure WaitBeamPos(Line:Word);
  {wait for the CRT to display the given raster line}
Function Readkey:Char;
 {similar to CRT unit}
Function Keypressed:Boolean;
 {similar to CRT unit}
procedure beep(n,d:Byte);
 {Like Sound in CRT unit}
Procedure OutTextXYB(Var s:String;x,y,c:Byte);
 {Place string at Text cursor positions on Graphics screen}
 {Uses the BIOS; big numbers, slow, on Text column and row.}

{**************************************************************************
**}

Implementation

{**************************************************************************
**}

Procedure Wait(t:Word);
Var LastTick:Word;
Begin
  LastTick:=Timer;
  Repeat UNTIL (Timer-LastTick)>T;
end;

Procedure VideoMode(M:Word);Assembler;
asm
 mov   ax,m
  Xor   ah,ah
 int   10h
end;
Procedure GetRGB(reg:Word;Var R;Var G;Var B);assembler;
asm
  Mov ax,1015h     {Function 10; palette functions}
  Mov bx,reg       {         15; read color register}
  Int 10h          {Video BIOS services}
  Les di,r
  Mov es:[di],dh   {write red value}
  Les di,g
  Mov es:[di],ch   {green value}
  Les di,b
  Mov es:[di],cl   {blue value}
end;
procedure SetRGB(Register:Word;red,green,blue : byte); assembler;
asm
  Mov dx,03c8h
  Mov al,Byte PTR Register
  Out dx,al
  Inc dx
  Mov al,red
  Out dx,al
  Mov al,green
  Out dx,al
  Mov al,blue
  Out dx,al
end;

Procedure WaitHBL;assembler;
asm
 Mov dx,03dah  {offset to input port 1}
@1:
 In  al,dx
 test al,01h   {to make sure we get the most H. retrace,}
 Jz @1         {we wait 'til we're displaying raster}
@2:
 In  al,dx
 test al,01h   {then exit when H. retrace is starting}
 Jnz  @2
end;


Procedure WaitVBL;assembler;
asm
  Mov dx,03dah  {offset to input port 1}
@1:
 In  al,dx
  test al,08h    {to make sure we get the most V. retrace,}
  Jnz @1        {we wait 'til we're displaying raster}
@2:
  In  al,dx
 test al,08h    {then exit when V. retrace is starting}
  Jz  @2
end;

Procedure WaitBeamPos(Line:Word);assembler;
asm
  Call WaitVBL;
  Mov cx,Line
@l:
  Call WaitHBL;
  Loop @l
end;


Function Readkey:Char;Assembler;
asm
 Xor ax,ax
 Int 16h
 Cmp al,00h
 Jnz @1
 Mov al,ah
  Or  al,$80
@1:
end;

Function KeyWaiting:Word;Assembler;
asm
 Mov ax,0100h
 int 16h
end;

Function Keypressed:Boolean;Assembler;
asm
  Mov ax,0100h;
  int 16h;
  Mov al,False;
  jz @1;
  Inc al;
@1:
end;

procedure beep(n,d:Byte);
Var t:Word;

Begin
 t:=timer;While t=timer do;
asm
 mov   al,0B6h
 out   43h,al
 in    al,61h
 or    al,3
 out   61h,al
 mov   dx,42h
 mov   al,d
 out   dx,al
 mov   al,n
 out   dx,al
end;
 t:=timer;While t=timer do;
asm
 in    al,61h
 and   al,0FCh
 out   61h,al
end;
end;

Procedure OutTextXYB(Var s:String;x,y,c:Byte);Assembler;
asm
 Push bp
 Mov ah,13h {BIOS write string at cursor}
 Xor bh,bh  {set display page 0}
 Mov bl,c  {attribute to write with; color of foreground}
 Mov al,01h {write mode: update cursor, use set attribute}
 Mov dl,x  {set up position}
 Mov dh,y
 Les bp,s   {set up pointer to string}
 Mov cl,es:[bp] {set up length of string for write}
 Xor ch,ch
 Inc bp   {adjust pointer to first character of string}
 Int 10h    {call the function}
 Pop bp
end;

end.

