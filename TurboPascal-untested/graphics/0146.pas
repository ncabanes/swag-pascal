(* Just one of the (dozens) of possible ways of doing the old Tron game in *)
(* Pascal... Have fun!                                                     *)
(* Two players only. Cursor keys, and O, P, Q, R                           *)
(* Freeware - 1994 - Luis Evaristo Beda Netto Marques da Fonseca           *)
(* Thunderball Software Inc.                                               *)

Program Tron;

Uses Graph,Crt;

Var Cpos1,Lpos1,Cpos2,Lpos2,Npos1,Npos2,Winner,Vel,Ngames:Integer;
    Conta,Bluep,Yellowp:Integer;
    Out:Boolean;
    Exitgame:Char;

Procedure Initg;                      {initialize graphics}
var gd,gm:integer;
Begin
    Gd:=detect;
    Initgraph(Gd,Gm,'C:\TP\BGI');
End;

Procedure InitVar(Var Cpos1,Lpos1,Cpos2,Lpos2,Npos1,Npos2:Integer;Var out:Boolean);
Begin                                   {initilize game variables}
    Npos1:=3;
    Npos2:=1;
    Lpos1:=240;
    Lpos2:=240;
    Cpos1:=370;
    Cpos2:=270;
    out:=False;
End;

Procedure PressKey(Var Npos1,Npos2:Integer);
Var Ch:Char;
    Num:Integer;
Begin
If Keypressed then                              {get the key pressed and}
    Ch:=ReadKey;                                 {change course accordingly}
    if Ch=#0 then
    begin
        Ch:=ReadKey;
        Num:=Ord(Ch);
        Case Num of
            75:If Npos1<>3 then Npos1:=1;
            72:If Npos1<>4 then Npos1:=2;
            77:If Npos1<>1 then Npos1:=3;
            80:If Npos1<>2 then Npos1:=4;
        End;
    End
    Else
    Begin
        Num:=Ord(Ch);
        Case Num of
            111:If Npos2<>3 then Npos2:=1;
            113:If Npos2<>4 then Npos2:=2;
            112:If Npos2<>1 then Npos2:=3;
             97:If Npos2<>2 then Npos2:=4;
        End;
    end;
End;

Procedure ScrnOutput(Npos1,Npos2:integer;Var Lpos1,Lpos2,Cpos1,Cpos2,Winner,Vel:Integer; Var out:Boolean);
Var Color:Word;
Begin
     Case Npos1 of                              {write output at screen and}
          1:Cpos1:=Cpos1-1;                     {actualize position variables}
          2:Lpos1:=Lpos1-1;
          3:Cpos1:=Cpos1+1;
          4:Lpos1:=Lpos1+1;
     End;
     Color:=GetPixel(Cpos1,Lpos1);
     If Color<>0 then
     Begin
        out:=true;
        winner:=2;
     End;
     Color:=Cyan;
     PutPixel(Cpos1,Lpos1,Color);
     Case Npos2 of
          1:Cpos2:=Cpos2-1;
          2:Lpos2:=Lpos2-1;
          3:Cpos2:=Cpos2+1;
          4:Lpos2:=Lpos2+1;
     End;
     Color:=GetPixel(Cpos2,Lpos2);
     If Color<>0 then
     Begin
        out:=true;
        winner:=1;
     End;
     Color:=Yellow;
     PutPixel(Cpos2,Lpos2,Color);
     Delay(Vel);
End;

Begin
exitgame:='Y';
While Upcase(exitgame)='Y' do
Begin
     yellowp:=0;
     bluep:=0;
     Clrscr;
     Writeln('Choose speed (1-very fast to 100-really slow):');
     Readln(Vel);
     Writeln('Choose number of games:');
     Readln(ngames);
     if not odd(ngames) then
     begin
         writeln('Only odd numbers are accepted. Adding one.');
         inc(ngames);
         readln;
     end;
     For Conta:=1 to ngames do
     Begin
          Initg;
          InitVar(Cpos1,Lpos1,Cpos2,Lpos2,Npos1,Npos2,out);
          SetColor(Blue);
          Rectangle(0,0,639,479);
          While out=False do
          Begin
               Presskey(Npos1,Npos2);
               ScrnOutput(Npos1,Npos2,Lpos1,Lpos2,Cpos1,Cpos2,winner,Vel,out);
          End;
          Clrscr;
          If winner=1 then
              bluep:=bluep+1
          else
              yellowp:=yellowp+1;
     Closegraph;
     End;
     Write('And the winner is the ');
     if bluep>yellowp then
         Write('blue')
     else
         Write('yellow');
     writeln(' player!');
     Write('New game? (Y/N): ');
     Readln(exitgame);
End;
End.