(*
  Category: SWAG Title: TEXT EDITING ROUTINES
  Original name: 0003.PAS
  Description: Force Text Format
  Author: CHRIS BRATENE
  Date: 05-28-93  14:08
*)

{
> - How can I get TP to make what ever the user enters in to CAPS or     │
>   NONCAPS?  Example:                                                   │
>                     Enter Name -> ChRiS BrAtEnE                        │
>                     Your name is Chris Bratene? (Y/n)?                 │


I just wrote a routine that does this on the fly, so to speak, For
another user, and I haven't erased it yet, so here it is (slightly
modified, so that it Forces lowerCase, too):
}

Uses
  Crt;

Procedure Backspace;
begin
  Write(#8' '#8)
end;

Function LoCase(ch : Char) : Char;
begin
  if ch in ['A'..'Z'] then
    LoCase := Char(ord(ch)+32)
  else
    LoCase := ch;
end;

Procedure Dibble(Var st : String);
{ Forces upperCase For first letter in each Word,
  lowerCase For other letters. }
Var
  len : Byte Absolute st;
  ch : Char;

  Function ForceCap : Boolean;
  begin
    ForceCap := (len = 0) or (st[len] = ' ');
  end;

begin
  st := '';
  Repeat
    ch := ReadKey;
    if ForceCap then
      ch := upCase(ch)
    else
      ch := LoCase(ch);
    Case ch of
      #8  : if len > 0 then
            begin
              Backspace;
              dec(len);
            end;
      #27 : While len > 0 do
            begin
              BackSpace;
              dec(len);
            end;
      #0  : ch := ReadKey;

      else
        begin
          Write(ch);
          st := st + ch;
        end;

    end;
  Until ch in [#13,#27];

  Writeln;

end;


Var
  st : String;

begin { test }
  Writeln;
  Write('Enter String:  ');
  Dibble(st);
  Writeln(st);
end.

