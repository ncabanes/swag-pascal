{**********************************************************************
 *  3D Engine - Like Wolfenstien 3D
 *  This version was converted from BASIC code to Pascal by William Yu
 *  100% Public Domain - All Rights Relinquished.
 *
 *  Original BASIC Code by Peter Cooper
 *
 *  Graphics Routines courtesy of Sune Marcher (I think)
 *  Joystick Routines courtesy of Michael Genesis
 *
 *  Email: William Yu <voxel@freenet.edmonton.ab.ca>
 *  HPage: http://www.freenet.edmonton.ab.ca/~voxel/
 *
 *  Instructions:  <SPACE> or Button 1 on joystick to open door.
 *                 Door is identified by the colour yellow.
 **********************************************************************}
uses crt;

Const
  vidseg:word=$a000;
      Gameport=$201;
      Timer0=$40;
      TControl=$43;
      MaxLoops=5000;
      Button1=$10; Button2=$20; Button3=$40; Button5=$80;
      Xaxis1=$01; Yaxis1=$02; Xaxis2=$04; Yaxis2=$08;
  Page : Byte = 0;
  Grid : Array [1..24,1..24] of byte =
  ((9, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72,73, 74, 74,  1,  9,  1,  9,  1,  9,  1,  9,  1),
   (1,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0, 75,  2,  0,  0, 11,  3,  0,  0,  0,  9),
   (9,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0, 76, 10,  0,  0,  3, 11,  0, 12,  0,  1),
   (1,  0,  0, 31, 30, 29, 28, 27, 26, 25, 24, 23,22, 14, 27,  2,  0,  0,  0,  0,  0,  4,  0,  9),
   (9,  0,  0, 20,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0, 28, 10,  0,  0,  0,  0,  0, 12,  0,  1),
   (1,  0, 21, 20,  0,  0,  0,  0,  0,  0,  0,  0, 0,  0, 29,  2,  0,  0,  0, 25,  0,  4,  0,  9),
   (9,  0, 22, 21, 22, 23, 24, 25, 26, 27, 28, 28,30, 14, 30, 10,  0,  0,  0, 26,  0, 12,  0,  1),
   (1,  0, 23,  0,  0,  0,  0,  0,  0,  0,  0,  9, 1,  0, 10,  2,  0,  0,  0, 27,  0,  4,  0,  9),
   (9,  0, 24,  0,  0,  0,  0,  0,  0,  0,  0,  1, 9,  0,  2, 10,  0, 43,  0, 28,  0, 12,  0,  1),
   (1,  0, 25,  0, 31, 30, 29, 28, 27, 26,  0,  9, 1,  0, 10,  2,  0, 39,  0, 29,  0,  4,  0,  9),
   (9,  0, 26,  0, 30,  0,  0,  0,  0, 25,  0,  1, 9,  0,  2, 10,  0, 43,  0, 30,  0, 12,  0,  1),
   (1,  0,  0,  0, 29,  0,  0,  0,  0, 24,  0,  0, 0,  0,  0,  0,  0,  0,  0, 31,  0,  0,  0,  9),
   (9,  0,  0,  0, 28,  0, 23,  0,  0, 23,  0, 10, 2,  0,  3, 11,  0,  0,  0, 30,  0,  0,  0,  1),
   (1,  9,  1,  0, 27,  0, 22,  0,  0, 22,  0,  2,10,  0, 11,  3,  0,  0,  0, 29,  0, 55,  0,  9),
   (9,  1,  9,  0, 26,  0, 21,  0,  0, 21, 10, 10, 2,  0,  3, 11,  0,  0,  0, 28,  0, 54,  0,  1),
   (1,  0,  0,  0,  0,  0, 22,  0,  0, 22,  0,  0, 0,  0, 11,  3,  0,  0,  0, 27,  0, 53,  0,  9),
   (9,  0,  0,  0,  0,  0, 23,  0,  0, 23,  0,  0, 0,  0,  0,  0,  0,  0,  0, 26,  0, 52,  0,  1),
   (1,  9,  1,  9,  1,  9, 24,  0,  0, 24,  0,  0, 2,  0,  0,  0,  0,  0,  0, 25,  0, 51,  0,  9),
   (9,  0,  0,  0,  0,  0,  0,  0,  0, 25,  0,  0,10,  0,  0,  4, 12,  4, 12, 24,  0, 50,  0,  1),
   (1,  0,  0,  0,  0,  0, 26,  0,  0, 26,  0,  0, 2,  0,  0, 12,  4, 12,  4, 23,  0, 49,  0,  9),
   (9,  0,  2, 10,  0,  0, 27,  0,  0, 27,  0,  0,11,  0,  0,  4, 12,  4, 12, 22,  0, 48,  0,  1),
   (1,  0,  0,  0,  5,  0, 28,  0,  0,  0,  0,  0, 3,  0,  0,  0,  0,  0,  0,  0,  0, 47,  0,  9),
   (9,  0,  0,  0, 13,  0, 29,  0,  0,  0,  0,  0,11,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1),
   (1,  9,  1,  9,  1,  9,  1,  9,  1,  9,  1,  9, 1,  9,  1,  9,  1,  9,  1,  9,  1,  9,  1,  9));

Var
  vseg:word;
  virt:pointer;
  I,J,X,Y : Word;
  color : byte;
  STable : Array [-31..392] of Real;
  CTable : Array [-31..392] of Real;
  Factor,Angle,NewPX,PX,NewPY,PY,StepX,StepY,XX,YY : Real;
  A,Heading,Rand,Stride,Turn,X1,L,K,DT,H,DD,WY,WYY : Integer;
  Moved,Joy,Stop,RandSeed : Boolean;

var ky:char; done:boolean; MaxX,Minx,MaxY,MinY:word;
    MX,MY:byte;     {percent-adjusted centered joystick values}
    CX,CY,Dely:byte;   {Cursor positions and loop Delay}

Function JoyExist:boolean;
var
   temp:byte;
begin
   asm
      mov ah,84h
      mov dx,00h
      int 15h
      mov temp,al
   end;
   if temp=0 then JoyExist:=false
   else JoyExist:=true;
end;

Procedure GetJoy; assembler;
label loop1,loop2,axis1,loop3,axdone;
 
asm
    cli               {disable interrupts}
    mov  dx,Gameport;  {set port adress}
    mov  cx,MaxLoops;
    mov  al,0;
    out  TControl,al;  {latch count in timer0}
    in   al,Timer0;     {low byte of timer count}
    mov  ah,al;
    in   al,Timer0;     {high byte of timer count}
    xchg al,ah;
    mov  bx,ax;        {start count in BX}
    out  dx,al;        {trigger game port}
    in   al,dx
loop1:
    in   al,dx;        {Read Gameport}
    mov  ah,al;
    and  ax,$0201;      {X axis in al; Y axis in ah}
    test al,Xaxis1;      {is X axis done?}
    jz   axis1;
    test ah,Yaxis1;      {is Y axis done?}
    loopnz loop1;
                       {Y axis done first!}
    out  TControl,al;
    in   al,Timer0;     {low byte of Y axis count}
    mov  ah,al;
    in   al,Timer0;     {high byte of Y axis count}
    xchg al,ah
    push ax            {store Y axis count on the stack}
loop2:
    in   al,dx;
    and  al,Xaxis1;
    test al,Xaxis1;      {Test X axis}
    loopnz loop2;
                       {X axis done(after Y)}
    out  TControl,al;
    in   al,Timer0;
    mov  ah,al;
    in   al,Timer0;
    xchg al,ah         {X axis count}
    sub  ax,bx;        {find difference}
    neg  ax
    mov  X,ax;         {Save X axis time}
    pop  ax;           {Get Y axis count}
    sub  ax,bx
    neg  ax
    mov  Y,ax;         {Save Y axis time}
    jmp  axdone        {We're done.}
 
axis1:                 {X axis done first}
    out  TControl,al;
    in   al,Timer0
    mov  ah,al
    in   al,Timer0
    xchg al,ah
    push ax            {Store X axis count on the stack}
loop3:
    in   al,dx
    and  al,Yaxis1;
    test al,Yaxis1;
    loopnz loop3;
                        {Y is done}
    out  TControl,al;
    in   al,Timer0;
    mov  ah,al
    in   al,Timer0
    xchg al,ah
    sub  ax,bx
    neg  ax
    mov  Y,ax           {Save Y axis Time}
    pop  ax             {Get X axis count}
    sub  ax,bx
    neg  ax
    mov  X,ax           {Save X axis count}
axdone:
    sti
end;

var b1,b2,b3,b4:byte;
Procedure Getbutton; assembler;
label bt2,bt3,bt4,done;

asm
    mov b1,0
    mov b2,0
    mov b3,0
    mov b4,0
    mov dx,Gameport;
    in al,dx;
    test al,$10;
    jnz bt2             {there must be a better way to do this}
    mov b1,1
bt2:
    test al,$20;
    jnz bt3
    mov b2,1
bt3:
    test al,$40;
    jnz bt4;
    mov b3,1;
bt4:
    test al,$80;
    jnz done;
    mov b4,1
done:
end;

procedure setmode(const mode:word);assembler;
asm
  mov ax,mode
  int 10h
end;

procedure flip386(const a,b:word); assembler;
asm
  push ds
  mov ds,a
  mov es,b
  xor si,si
  xor di,di
  mov cx,16000
  db 66h; rep movsw
  pop ds
end;

procedure clear386(const where:word;const c:byte); assembler;
asm
  mov es,where
  xor ax,ax
  xor di,di
  mov al,[c]
  mov ah,al
  db 66h; shr ax,16
  mov al,[c]
  mov ah,al
  mov cx,16000
  db 66h; rep stosw
end;

procedure vline2(const x,y1,y2,where:word;const c:byte);assembler;
asm
  mov ax,where
  mov es,ax
  mov ax,[y1]
  mov bx,ax
  shl ax,8
  shl bx,6
  add ax,bx
  mov di,ax
  mov ax,[y2]
  mov bx,ax
  shl ax,8
  shl bx,6
  add bx,ax
  mov al,[c]
  mov cx,[x]
  add di,cx
  add bx,cx

  @@loop1:
    mov es:[di],al
    add di,320
    cmp di,bx
    jne @@loop1
end;

FUNCTION GetKey: CHAR;
INLINE($b4/$10/$cd/$16/$88/$e0);

Procedure ComputeView;
Begin
  X1 := 0;
  FOR A := (Heading + 32) Downto (Heading - 31) do
  Begin
    StepX := STable[A]; StepY := CTable[A];
    XX := PX; YY := PY;
    L := 0;
    Repeat
      XX := XX - StepX; YY := YY - StepY;
      L := L + 1;
      K := Grid[Round(XX), Round(YY)];
    Until K<>0;
    DD := 900 div L;
    H := DD + DD;
    DT := 100 - DD;
    For I:=0 to 4 do
    Begin
      WY:=DT+H;
      WYY:=DT;
      If WY>199 then WY:=199;
      If WYY<0 then WYY:=0;
      vLINE2 (X1+I, WYY-Rand, WY-Rand, Vseg, K);
    End;
    X1 := X1 + 5;
  End;
End;

Procedure UpdateScreen;
Begin
 clear386(vseg,0);
 ComputeView;
 flip386(vseg,vidseg);
End;

Procedure MoveRight;
Begin
  Heading := (Heading + Turn) MOD 360;
End;

Procedure MoveLeft;
Begin
  Heading := (Heading + (360 - Turn)) MOD 360;
End;

Procedure MoveUp;
Begin
  NewPX := PX - (STable[Heading] * Stride);
  NewPY := PY - (CTable[Heading] * Stride);
  IF Grid[Round(NewPX), Round(NewPY)] = 0 THEN
  Begin
    PX := NewPX; PY := NewPY;
    If RandSeed Then
       Rand:=Rand+1
    else
       Rand:=Rand-1;
    If (Rand = 3) or (Rand=0) then RandSeed:=NOT RandSeed;
  End
  ELSE {'tried to walk through a wall}
  Begin
    Sound(80);Delay(10);
  End;
End;

Procedure MoveDown;
Begin
  NewPX := PX + (STable[Heading] * Stride);
  NewPY := PY + (CTable[Heading] * Stride);
  IF Grid[Round(NewPX), Round(NewPY)] = 0 THEN
  Begin
    PX := NewPX; PY := NewPY;
    If RandSeed Then
       Rand:=Rand+1
    else
       Rand:=Rand-1;
    If (Rand = 3) or (Rand=0) then RandSeed:=NOT RandSeed;
  End
  ELSE {'tried to walk through a wall}
  Begin
    Sound(80);Delay(10);
  End;
End;

begin
 Joy:=False;
 If JoyExist Then Begin
   ClrScr;
   Write('Use joystick [Y/N]? ');
   Readln(ky);
   If Upcase(ky)='Y' Then Begin
     Joy:=True;
     done:=false;
     GetJoy;
     MaxX:=X; MinX:=X; MaxY:=Y; MinY:=Y;    {initial values}
     Writeln('Whip that joystick around until the 4 leftmost numbers stop changing,');
     writeln('then center the joystick and press button 1 or any key.');
     if KeyPressed then ky:=ReadKey;   {Clear KeyBuffer}
     while not done do begin
       GetJoy;
       if X>=MaxX then MaxX:=X;      {find the range of the joystick}
       if X<=MinX then MinX:=X;
       if Y>=MaxY then MaxY:=Y;
       if Y<=MinY then MinY:=Y;
       gotoxy(1,5);
       Writeln(MinX,'    ',MaxX,'    ',X,'      ');
       Writeln(MinY,'    ',MaxY,'    ',Y,'      ');
       GetButton;
       if B1=1 then Done:=true;
       if KeyPressed then Done:=true;
     end;
     if KeyPressed then ky:=ReadKey;
     X:=round(((X-MinX)/MaxX)*100);  {Percent-adjust:  this scales }
     Y:=round(((Y-MInY)/MaxY)*100);  { the number to between 1 and 100.}
     MX:=X; MY:=Y;
 End
 Else
   Joy:=False;
 End; {Joystick Exist check }

 SetMode($13);
 getmem(virt,64000);
 vseg:=seg(virt^);
 Factor := (ArcTan(1) * 8) / 360;
 FOR A := 0 TO 359 Do
 Begin
   Angle := A * Factor;
   STable[A] := Sin(Angle) * 0.1;
   CTable[A] := Cos(Angle) * 0.1;
 End;
 FOR A := -31 to -1 Do
 Begin
   STable[A] := STable[A + 360];
   CTable[A] := CTable[A + 360];
 End;
 FOR A := 360 to 392 Do
 Begin
   STable[A] := STable[A - 360];
   CTable[A] := CTable[A - 360];
 End;

 PX := 5; PY := 5;   { 'the starting coordinates of the player's location }
 Stride := 3;        { 'the distance covered in one "step" by the player  }
                     { '   by pressing the up or down arrow keys          }
 Heading := 180;     { 'the heading of the player (in degrees)            }
 Turn := 5;          { 'number of degrees of rotation produced by         }
                     { '   pressing the right or left arrow keys          }
 UpdateScreen;
 RandSeed := True;

Repeat
 If Joy Then Begin
  Dely:=1;         { Use this to slow joystick down }
  Done:=False;
  while not done do begin;
    GetJoy;
    X:=round(((X-MinX)/MaxX)*100);
    Y:=round(((Y-MInY)/MaxY)*100);
    Moved:=False;
    if X>MX+10 then Begin
      Moved:=True;
      MoveLeft;
      If Y<MY-10 then MoveUp;
      If Y>MY+10 then MoveDown;
      UpdateScreen;
    End;
    if X<MX-10 then Begin
      Moved:=True;
      MoveRight;
      If Y<MY-10 then MoveUp;
      If Y>MY+10 then MoveDown;
      UpdateScreen;
    End;
    if (Y>MY+10) AND (NOT Moved) then Begin
      MoveDown;
      If X<MX-10 then MoveRight;
      If X>MX+10 then MoveLeft;
      UpdateScreen;
    End;
    if (Y<MY-10) AND (NOT Moved) then Begin
      MoveUp;
      If X>MX+10 then MoveLeft;
      If X<MX-10 then MoveRight;
      UpdateScreen;
    End;
    GetButton;
    if b1=1 then
    Begin
       If K=14 Then Begin Grid[Round(XX), Round(YY)]:=0;UpdateScreen End;
    End;
    If b3=1 then Dely:=(Dely+1)mod 250;
    if b4=1 then Dely:=(Dely-1)mod 250;
    if Keypressed then done:=true;
    delay(Dely);
  end;
 End; { Joystick }
     Case GetKey of
         #71 : Begin MoveRight;MoveUp;UpdateScreen; End;  {PgUp}
         #72 : Begin MoveUp;UpdateScreen; End;            {Up}
         #73 : Begin MoveLeft;MoveUp;UpdateScreen; End;   {Home}
         #75 : Begin MoveRight;UpdateScreen; End;         {Right}
         #77 : Begin MoveLeft;UpdateScreen; End;          {Left}
         #79 : Begin MoveLeft;MoveDown;UpdateScreen; End; {End}
         #80 : Begin MoveDown;UpdateScreen; End;          {Down}
         #81 : Begin MoveRight;MoveDown;UpdateScreen; End;{PgDn}
         #57 : Begin
                 If K=14 Then Begin Grid[Round(XX), Round(YY)]:=0;UpdateScreen End;
               End;
         #01 : Stop := True;
     End;
Until Stop;
SetMode($03);
nOsOUND;
end.
