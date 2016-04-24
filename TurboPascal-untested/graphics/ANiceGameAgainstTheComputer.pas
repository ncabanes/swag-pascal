(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0272.PAS
  Description: A nice game against the computer
  Author: BOSTJAN GABROVSEK
  Date: 08-30-97  10:08
*)

{If you have any questions please send me mail at OleRom@hotmail.com}
Program Worm;
Const GetMaxX = 320;
      GetMaxY = 200;
      Levo  = 1;
      Desno = 2;
      Gor   = 3;
      Dol   = 4;
      KeyPort = $60;
      PortESCAPE = 01;
      PortLeft   = 75;
      PortRight  = 77;
      PortUp     = 72;
      PortDown   = 80;
      X : Word = 107;
      Y : Word = 100;
      Smer : Byte = Levo;
      UserX : Word = 213;
      UserY : Word = 100;
      UserSmer : Byte = Gor;
      Counter : Word = 0;
      Back = 5;
Type ScreenType = Array[1..200,1..320] of Byte;
Var Screen : ScreenType absolute $A000:$0000;
    ScrBuff: Array[1..65535] of Byte absolute Screen;
    Fo : Word;
Procedure SetPal(Color,R,G,B:Byte); assembler;
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
end;
Procedure Delay(ms:word); assembler;
asm
  mov ax,1000
  mul ms
  mov cx,dx
  mov dx,ax
  mov ah,86h
  int 15h
end;
Procedure WormExit;
Begin
 Halt;
End;
Procedure UserGameOver;
Begin
 SetPal(0,60,30,30);
 ReadLn;
 Halt;
End;
Procedure GameOver;
Begin
 SetPal(0,30,30,60);
 ReadLn;
 Halt;
End;
Function KeyPressed:boolean; assembler;
asm
  mov bx,40h
  mov es,bx
  mov ax,word ptr es:[001Ch]
  sub ax,word ptr es:[001Ah]
end;
Procedure EmptyKeyBuffer;
Begin
 While KeyPressed do
  asm
   xor ah,ah
   int 16h
  end;
End;
Function LevoDesno : Byte;
Var L, D : Word;
Begin
 L := 1;
 D := 1;
 While Screen[Y,X-L] = Back do Inc(L);
 While Screen[Y,X+D] = Back do Inc(D);
 If D > L then LevoDesno := Desno else LevoDesno := Levo;
End;
Function GorDol : Byte;
Var G, D : Word;
Begin
 G := 1;
 D := 1;
 While Screen[Y-G,X] = Back do Inc(G);
 While Screen[Y+D,X] = Back do Inc(D);
 If D > G then GorDol := Dol else GorDol := Gor;
End;
 Function TestLevoDesno : Byte; {Levo = True}
 Label Konec;
 Var AllCounter : Word;
     LeftCounter, RightCounter : Word;
     Xc, Yc : Word;
     Bc : Boolean;
 Begin
  TestLevoDesno := Gor;
  AllCounter   := 0;
  LeftCounter  := 0;
  RightCounter := 0;
  For Xc := 0 to 65535 do If ScrBuff[Xc] = Back then Inc(AllCounter);
  If (Screen[Y,X-1] <> Back) and (Screen[Y,X+1] = Back) then Begin TestLevoDesno := Desno; Goto Konec; End;
  If (Screen[Y,X-1] = Back) and (Screen[Y,X+1] <> Back) then Begin TestLevoDesno := Levo ; Goto Konec; End;
  If (Screen[Y,X-1] <> Back) and (Screen[Y,X+1] <> Back) and
     (Screen[Y-1,X] <> Back) and (Screen[Y+1,X] = Back) then Begin TestLevoDesno := Dol; Goto Konec; End;
  If (Screen[Y,X-1] <> Back) and (Screen[Y,X+1] <> Back) and
     (Screen[Y-1,X] = Back) and (Screen[Y+1,X] <> Back) then Begin TestLevoDesno := Gor; Goto Konec; End;
  If (Screen[Y,X-1] = Back) and (Screen[Y,X+1] = Back) then
   Begin
    {Test Levo...}
     Screen[Y,X-1] := 9;
     Inc(LeftCounter);
     Bc := True;
     While Bc do
     For Yc := 2 to 199 do
      For Xc := 2 to 319 do
       If Screen[Yc,Xc] = 9 then
        Begin
         If Screen[Yc-1,Xc] = Back then
          Begin
           Inc(LeftCounter);
           Bc := True;
          End;
        End;
   End;
  Konec:
 End;
Begin
Randomize;
 asm
  mov ax,0013h
  int 10h
 end;
SetPal(0,30,40,15); {Svetlo zelena - konec}
SetPal(5,20,30,5);  {Temno zelena  - plac }
SetPal(9,10,20,0);  {Temo Temno zelena  - plac pri farbanju}
SetPal(6,10,0,0);   {Crna          - rob  }
SetPal(7,40,50,40); {Bela          - rob  }
SetPal(3,60,10,15); {Rdeca         - user }
SetPal(4,50,0,5);   {Rdeca         - user }
SetPal(1,15,10,60); {Modra         - worm }
SetPal(2,5,0,50);   {Modra         - worm }
FillChar(Screen,64000,5);
For Fo := 1 to GetMaxX do Screen[1,Fo] := 6;
For Fo := 1 to GetMaxX do Screen[GetMaxY,Fo] := 7;
For Fo := 1 to GetMaxY do Screen[Fo,1] := 6;
For Fo := 1 to GetMaxY do Screen[Fo,GetMaxX] := 7;
Screen[UserY,UserX] := 4;
Screen[Y,X] := 2;
Repeat Until KeyPressed;
EmptyKeyBuffer;
Repeat
 Case Port[KeyPort] of
  PortESCAPE : WormExit;
  PortLeft   : UserSmer := Levo;
  PortRight  : UserSmer := Desno;
  PortUp     : UserSmer := Gor;
  PortDown   : UserSmer := Dol;
 end;
 Case UserSmer of
  Desno : Inc(UserX);
  Levo  : Dec(UserX);
  Gor   : Dec(UserY);
  Dol   : Inc(UserY);
 end;
{+++++++++++++++++++++++++++++++++++}
{++            Worm IQ            ++}
{+++++++++++++++++++++++++++++++++++}
 Case Smer of
  Levo  : Begin
           Fo := 1;
           While Screen[Y,X-Fo] = Back do Inc(Fo);
           If Fo < Random(9)+8 then Smer := GorDol;
          End;
  Desno : Begin
           Fo := 1;
           While Screen[Y,X+Fo] = Back do Inc(Fo);
           If Fo < Random(9)+8 then Smer := GorDol;
          End;
  Gor   : Begin
           Fo := 1;
           While Screen[Y-Fo,X] = Back do Inc(Fo);
           If Fo < Random(9)+8 then Smer := LevoDesno
          End;
  Dol   : Begin
           Fo := 1;
           While Screen[Y+Fo,X] = Back do Inc(Fo);
           If Fo < Random(9)+8 then Smer := LevoDesno
          End;

 end;

{-----------------------------------}
{--            Worm IQ            --}
{-----------------------------------}
Case Smer of
 Levo: Begin
        If Screen[Y,X-1] <> Back then
         Begin
          If Screen[Y,X+1] = Back then Smer := Desno;
          If Screen[Y-1,X] = Back then Smer := Gor;
          If Screen[Y+1,X] = Back then Smer := Dol;
         End;
       End;
 Desno: Begin
        If Screen[Y,X+1] <> Back then
         Begin
          If Screen[Y,X-1] = Back then Smer := Levo;
          If Screen[Y-1,X] = Back then Smer := Gor;
          If Screen[Y+1,X] = Back then Smer := Dol;
         End;
       End;
 Gor: Begin
        If Screen[Y-1,X] <> Back then
         Begin
          If Screen[Y,X-1] = Back then Smer := Levo;
          If Screen[Y,X+1] = Back then Smer := Desno;
          If Screen[Y+1,X] = Back then Smer := Dol;
         End;
       End;
 Dol: Begin
        If Screen[Y+1,X] <> Back then
         Begin
          If Screen[Y,X-1] = Back then Smer := Levo;
          If Screen[Y,X+1] = Back then Smer := Desno;
          If Screen[Y-1,X] = Back then Smer := Gor;
         End;
       End;
end;
 Case Smer of
  Levo  : Dec(X);
  Desno : Inc(X);
  Gor   : Dec(Y);
  Dol   : Inc(Y);
 end;
 Inc(Counter);
 If Screen[UserY,UserX] <> Back then UserGameOver;
 If Screen[Y,X] <> Back then GameOver;
 If Odd(Counter) then Screen[UserY,UserX] := 3 else Screen[UserY,UserX] := 4;
 If Odd(Counter) then Screen[Y,X] := 1 else Screen[Y,X] := 2;
 EmptyKeyBuffer;
 Delay(25);
Until False;
End.
