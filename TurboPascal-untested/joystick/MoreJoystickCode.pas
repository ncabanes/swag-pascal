(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0014.PAS
  Description: More Joystick code
  Author: MICHAEL GENESIS
  Date: 02-28-95  10:01
*)

Program Joystick;
uses CRT;
 
const Gameport=$201;
      Timer0=$40;
      TControl=$43;
      MaxLoops=5000;
      Button1=$10; Button2=$20; Button3=$40; Button5=$80;
      Xaxis1=$01; Yaxis1=$02; Xaxis2=$04; Yaxis2=$08;
 
var X,Y:word;
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
 
var k:char; done:boolean; MaxX,Minx,MaxY,MinY:word;
    MX,MY:byte;     {percent-adjusted centered joystick values}
    CX,CY,D:byte;   {Cursor positions and loop Delay}
 
Begin
  ClrScr;
  done:=false;
  GetJoy;
  MaxX:=X; MinX:=X; MaxY:=Y; MinY:=Y;    {initial values}
  Writeln('Whip that joystick around until the 4 leftmost numbers stop changing,');
  writeln('then center the joystick and press button 1 or any key.');
  if KeyPressed then k:=ReadKey;   {Clear KeyBuffer}
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
  if KeyPressed then k:=ReadKey;
  X:=round(((X-MinX)/MaxX)*100);  {Percent-adjust:  this scales }
  Y:=round(((Y-MInY)/MaxY)*100);  { the number to between 1 and 100.}
  MX:=X; MY:=Y;
  done:=false;
  gotoxy(1,8);
  Write('Press any key.');
  if KeyPressed then k:=Readkey;
  while not done do begin
    GetJoy;
    X:=round(((X-MinX)/MaxX)*100);
    Y:=round(((Y-MInY)/MaxY)*100);
    gotoxy(1,9);
    GetButton;
    Write(X,'    ',Y,'    ',B1,B2,B3,B4,'      ');
    if keypressed then Done:=true;
  end;
  k:=Readkey;
  CX:=40; CY:=10;  {Initial cursor position}
  D:=100;
  Done:=False;
  ClrScr;
  Writeln('Use the joystick to change cursor positions.');
  Writeln('buttons 1 and 2 write smiley faces,');
  Writeln('buttons 3 and 4 change joystick speed.');
  writeln('Press any key to exit.');
  while not done do begin;
    GetJoy;
    X:=round(((X-MinX)/MaxX)*100);
    Y:=round(((Y-MInY)/MaxY)*100);
    if X>MX+10 then CX:=CX+1;  {change cursor position?}
    if X<MX-10 then CX:=CX-1;
    if Y>MY+10 then CY:=CY+1;
    if Y<MY-10 then CY:=CY-1;
    if CX>80 then CX:=1;  {there is probably a faster way }
    if CX<1 then CX:=80;  {to do this using mod. }
    if CY>23 then CY:=1;
    if CY<1 then CY:=23;
    gotoxy(1,24);
    write(D,'   ');
    gotoxy(CX,CY);
    GetButton;
    if b1=1 then write(chr(1));
    if b2=1 then write(chr(2));
    if b3=1 then D:=(D+1)mod 250;
    if b4=1 then D:=(D-1)mod 250;
    if Keypressed then done:=true;
    delay(D);
  end;
  k:=Readkey;
end.  
         And before I did this, I couldn't progam more than 2 lines of Asm.

--- Renegade v10-05 Exp
 * Origin: The Digital Domain - (716) 791-4849 (1:260/149)
SEEN-BY: 270/101 280/1 396/1 3615/50 51
PATH: 260/149 10 1 270/101 396/1 3615/50
                                                                      
