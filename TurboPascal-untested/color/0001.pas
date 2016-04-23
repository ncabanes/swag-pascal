{
>Hello, I am writing an application that is some what color
>coordinated. I would like to have the background changed (usually
>black) to one of the background colors without affecting the
>foreground (so I do not have to reWrite the foreground screen).  So
}

Uses
  Dos;

Procedure ChangeBG(Color : Byte);
Var i : Word;
begin
  For i := 0 to 3999 do
    If Odd(i) then
      Mem[$b800:i] := (Mem[$b800:i] and 15) or ((Color and 7) shl 4)
end;

Var
  ColChar : String;
begin
  ColChar := ParamStr(1);
  ChangeBg(Ord(ColChar[1]));
end.