{
> I want to be able to read a users Text Attrib and store them so i can
> restore them when my Program ends.  How can I do this?

It seems strange you would only want to save Text attribute and
not the Dos screen, but that is what you ask -- as I understand it.

You need to read the attribute of Character at or one column
beFore the current cursor position, directly from the screen. Something
like this should do:
}

Uses
  Crt;

Function UserAttr: Byte;
Var VSeg: Word;
begin
  if LastMode = 7 then
    VSeg := $B000          { Monochrome }
  else
    VSeg := $B800;         { Color }
  if (WhereX = 1) and (WhereY = 1) then
    UserAttr := Hi(MemW[VSeg:0])
  else
    UserAttr := Hi(MemW[VSeg:(WhereX -1) + (MemW[$40:$4A] * (WhereY -1)) -2]);
end;

(*
BeFore returning to Dos, Write one space With given attribute and
backspace over it (this will cause Dos to continue in the same color):

TextAttr := OldAttr;    { OldAttr initialized at Program startup }
Write(#20#8);
*)

