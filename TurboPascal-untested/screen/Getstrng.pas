(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0007.PAS
  Description: GETSTRNG.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

Unit scn_io;

Interface

Procedure GetScreenStr(x, y, l: Integer; Var s: String);

Implementation

Procedure GetChar(x, y: Integer; Var ch: Char);
(*** gets the Character from screen position x, y;
     x is horizontal co-ord, y is vertical;
     top left corner is 0,0 ***)
Const
  base = $b800;            (* $b000 For mono *)
Var
  screen_Byte: Byte;
  offs: Integer;
begin
  offs := ( (y*80) + x ) * 2;
  screen_Byte := mem[base: offs];
  ch := chr(screen_Byte);
end{proc..};

Procedure PutChar(x, y: Integer; ch: Char);
(*** pits the Character ch to screen position x, y; ***)
Const
  base = $b800;            (* $b000 For mono *)
Var
  screen_Byte: Byte;
  offs: Integer;
begin
  offs := ( (y*80) + x ) * 2;
  screen_Byte := ord(ch);
  mem[base: offs] := screen_Byte;
end{proc..};

Procedure GetScreenStr(x, y, l: Integer; Var s: String);
(*** gets the String from screen position x,y of length l ***)
Var
  i: Integer;
  ch: Char;
begin
  s := '';
  For i := 1 to l do
  begin
    GetChar(x, y, ch);
    s := s + ch;
    inc(x);
    if x > 79 then
    begin
      inc(y); x:= 0;
    end{if x >..};
  end{For i..}
end{proc..};

end{Unit..}.

