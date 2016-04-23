{
DAVID DRZYZGA

> Is there any way to create or use your own fonts in
> regular Text mode With Pascal?

Here's a demo of a routine originally posted by Bernie P and revised by me:
}

Program UpsideDown;
{-upsidedown and backwards Text aka redefining the Text mode font}
Var
  newCharset,
  oldCharset : Array[0..255,1..16] of Byte;

Procedure getoldCharset;
Var
  b : Byte;
  w : Word;
begin
  For b := 0 to 255 do
  begin
    w := b * 32;
    Inline($FA);
    PortW[$3C4] := $0402;
    PortW[$3C4] := $0704;
    PortW[$3CE] := $0204;
    PortW[$3CE] := $0005;
    PortW[$3CE] := $0006;
    Move(Ptr($A000, w)^, oldCharset[b, 1], 16);
    PortW[$3C4] := $0302;
    PortW[$3C4] := $0304;
    PortW[$3CE] := $0004;
    PortW[$3CE] := $1005;
    PortW[$3CE] := $0E06;
    Inline($FB);
  end;
end;

Procedure restoreoldCharset;
Var
  b : Byte;
  w : Word;
begin
  For b := 0 to 255 do
  begin
    w := b * 32;
    Inline($FA);
    PortW[$3C4] := $0402;
    PortW[$3C4] := $0704;
    PortW[$3CE] := $0204;
    PortW[$3CE] := $0005;
    PortW[$3CE] := $0006;
    Move(oldCharset[b, 1], Ptr($A000, w)^, 16);
    PortW[$3C4] := $0302;
    PortW[$3C4] := $0304;
    PortW[$3CE] := $0004;
    PortW[$3CE] := $1005;
    PortW[$3CE] := $0E06;
    Inline($FB);
  end;
end;

Procedure setasciiChar(Charnum : Byte; Var data);
Var
  offset : Word;
begin
  offset := CharNum * 32;
  Inline($FA);
  PortW[$3C4] := $0402;
  PortW[$3C4] := $0704;
  PortW[$3CE] := $0204;
  PortW[$3CE] := $0005;
  PortW[$3CE] := $0006;
  Move(data, Ptr($A000, offset)^, 16);
  PortW[$3C4] := $0302;
  PortW[$3C4] := $0304;
  PortW[$3CE] := $0004;
  PortW[$3CE] := $1005;
  PortW[$3CE] := $0E06;
  Inline($FB);
end;

Procedure newWriteln(s : String);
 {- Reverses order of Characters written}
Var
  b : Byte;
begin
  For b := length(s) downto 1 do
    Write(s[b]);
  Writeln;
end;

Var
  b, c : Byte;

begin
  getoldCharset;
  For b := 0 to 255 do
    For c := 1 to 16 do
      newCharset[b, c] := oldCharset[b, (17 - c)];
  For b := 0 to 255 do
    setasciiChar(b, newCharset[b, 1]);
  newWriteln('Hello World!');
  readln;
  restoreoldCharset;
end.
