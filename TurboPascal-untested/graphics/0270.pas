{If you have any questions please send me mail at OleRom@hotmail.com}
{Falling Snow}
Program Snegec;
Label cool, skip;
Type ScreenType = Array[1..200,1..320] of Byte;
     TabelType = Array[1..200] of Word;
Var Screen : ScreenType absolute $A000:$0000;
    Fake : ^ScreenType;
    T,O : TabelType;
    Fo,X,Y : Word;
    Info : Array[185..192,81..167] of Byte;
    r,r2,r3 : ShortInt;
Function KeyPressed:boolean; assembler;
asm
  mov bx,40h
  mov es,bx
  mov ax,word ptr es:[001Ch]
  sub ax,word ptr es:[001Ah]
end;
Procedure Delay(ms:word);assembler;
asm
  mov ax,1000
  mul ms
  mov cx,dx
  mov dx,ax
  mov ah,86h
  int 15h
end; {Delay}
Procedure SetPal(Color,R,G,B:Byte);assembler;
asm
  mov dx,03C8h
  mov al,[Color]
  out dx,al
  inc dx
  mov al,[R]
  out dx,al
  mov al,[G]
  out dx,al
  mov al,[B]
  out dx,al
end; {SetPal}

Procedure OutText(X,Y,Color,BkColor:Byte;S:OpenString);{By OleRom}
Var Chr : Char;
    fo : Byte;
Begin
 For fo := 1 to Ord(S[0]) do
 Begin
  Chr := S[fo];
  asm
    mov ah,02h
    xor bh,bh
    mov dh,[y]
    mov dl,[x]
    int 10h
    mov ah,09h
    mov al,[Chr]
    mov bh,[BkColor]
    mov bl,[Color]
    mov cx,01h
    int 10h
    inc [x]
  end;
 End;
End; {OutText}

Begin
Randomize;
New(Fake);
 asm
   mov ax,0013h
   int 10h
 end;
 FAke^ := Screen;
 SetPal(0,20,30,63);
 SetPal(10,20,30,63);
 SetPal(50,63,63,63);
 SetPal(100,10,53,20);
 SetPal(101,20,33,20);
 SetPal(102,30,43,40);
For X := 1 to 10 do
 SetPal(199+X,0,X*7,X*7);
 OutText(10,23,14,0,'Cold Winter');
 For Y := 185 to 192 do
  For X := 81 to 167 do Info[Y,X] := Screen[Y,X];
 Screen := Fake^;
 For Y := 185 to 192 do
  For X := 81 to 167 do
  Begin
   If Info[Y,X] <> 0 then
   Begin
    Screen[Y*3-185,X*3-280] := 101;
    Screen[Y*3-186,X*3-281] := 101;
    Screen[Y*3-187,X*3-282] := 101;
   End;
  End;

 For Y := 155 to 195 do
  For X := 10 to 300 do
   If Screen[Y,X] = 101 then
   Begin
    Screen[Y,X]:=100;
    If Screen[Y,X+1]=0 then Screen[Y,X+1] := 100;
    If Screen[Y,X-1]=0 then Screen[Y,X-1] := 100;
    If Screen[Y+1,X]=0 then Screen[Y+1,X] := 100;
    If Screen[Y-1,X]=0 then Screen[Y-1,X] := 100;
    If Screen[Y+1,X+1]=0 then Screen[Y+1,X+1] := 100;
    If Screen[Y-1,X+1]=0 then Screen[Y-1,X+1] := 100;
    If Screen[Y-1,X-1]=0 then Screen[Y-1,X-1] := 100;
    If Screen[Y+1,X-1]=0 then Screen[Y+1,X-1] := 100;
   End;

 For Y := 155 to 195 do
  For X := 10 to 300 do
   If Screen[Y,X] = 0 then
   Begin
    If Screen[Y,X+1]=100 then Screen[Y,X+1] := 200;
    If Screen[Y+1,X-1]=100 then Screen[Y+1,X-1] := 200;
   End;
For fo := 1 to 8 do
 For Y := 155 to 195 do
  For X := 10 to 300 do
   If Screen[Y,X] = 199+fo then
   Begin
    If Screen[Y,X+1]=100 then Screen[Y,X+1] := 200+fo;
    If Screen[Y+1,X-1]=100 then Screen[Y+1,X-1] := 200+fo;
   End;
For X := 1 to 320 do
 Screen[200,X] := 10;

X := 160;
For Y := 1 to 200 do
Begin
 Screen[Y-1,X] := 0;
 Inc(X,Random(3)-1);
 Screen[Y,X] := 15;
 If Screen[Y+1,X] <> 0 then goto skip;
 Delay(15);
End;
skip:
While not Keypressed do
 Begin
 O := T;
  For Y := 199 downto 1 do
   T[Y+1] := T[Y];
  T[1] := Random(320)+1;
  For Y := 1 to 200 do
  Begin
   If Screen[Y,O[Y]] = 15 then Screen[Y,O[Y]] := 0;
   If T[Y] <> 0 then
   Begin

R := Random(3)-1;
T[Y] := T[Y]+r;


If (Screen[Y,T[Y]] <> 0) or (Screen[Y+1,T[Y]] >= 16) then
Begin
 If not ((Screen[Y,T[Y]+1] <> 0) or (Screen[Y+1,T[Y]+1] >= 16)) then
   Begin
    Inc(T[Y]);
    goto cool;
   End;
 If not ((Screen[Y,T[Y]-1] <> 0) or (Screen[Y+1,T[Y]-1] >= 16)) then
   Begin
    Dec(T[Y]);
    goto cool;
   End;
 Screen[Y,T[Y]] := 50;
 T[Y] := 0;
End;
Cool:
If Screen[Y,T[Y]] = 0 then Screen[Y,T[Y]] := 15;
   End;
  End;
 Delay(5);
 End;
 asm
   mov ax,0003h
   int 10h
 end;
End.