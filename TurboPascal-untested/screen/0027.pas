{
DAVID DRZYZGA

> I want to know how to get and set the screen colors Without using the
> Crt Unit or ansi codes.  Any help is appreciated.

This will do what you ask. There is no checking of the vidseg since it is
assumed that if you want to Write in color that you are using a color monitor:
}

Procedure WriteColorAt(X, Y : Byte; St : String; Attr : Byte);
Var
  Count : Byte;
begin
  For Count := 1 to Length(St) do
  begin
    Mem[$B800 : 2 * (80 * (Y - 1) + X + Count - 2)] := Ord(St[Count]);
    Mem[$B800 : 2 * (80 * (Y - 1) + X + Count - 2) + 1] := Attr;
  end;
end;

begin
  WriteColorAt(34, 12, 'Hello World!', $4E);
end.
