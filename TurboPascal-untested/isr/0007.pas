{
> How do you have a Procedure running Constantly While others things are
> happening??

Well, to have them run at the exact same time isn't possible. You can swap
back and forth pretty quick though. The basic idea is that when the
computer is idle (waiting For a key, displaying a Text File, etc) you have
it jump to your routine.
}
Program Test1;
(* This will wait For a key and display the time *)
Uses
  Dos, Crt;

Procedure WriteTime;
Var
  CurX,
  CurY,
  CurA  : Byte;
  H, M,
  S, MS : Word;
begin
  CurX := WhereX;
  CurY := WhereY;
  CurA := TextAttr;
  TextColor(7);
  GotoXy(60, 1);
  GetTime(H, M, S, MS);
  Write(H, ':', M, ':', S, '.', MS);
  TextAttr := CurA;
  GotoXy(CurX, CurY);
end;

{ Uncomment this For Keyboard IDLE Demo }
Var Ch : Char;
    Done : Boolean;
begin
  Repeat
    Repeat
      WriteTime
    Until KeyPressed;
    Ch := ReadKey;
    Done := (Ch = #27);
  Until Done;
end.

{ Uncomment this For TextFile IDLE Demo }
{
Var T : Text;
    Ts : String;
begin
  Assign(T,'BBS.NFO');
  Reset(T);
  While Not Eof(T) Do begin
    ReadLn(T,Ts);
    WriteTime;
    WriteLn(Ts);
  end;
  Close(T);
end.
}