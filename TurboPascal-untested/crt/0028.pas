
rogram DirectW;
{
  This program shows how to write directly to video memory.
  It will not work in protected mode. There is no reason
  to believe that this runs any faster than the CRT's
  Write procedure, but we're putting it out on the BBS in
  case you are interested.

  As always, this program comes with no guarrantees and even
  less support.
}

var
  VS: Word;

function VidSeg : Word;
begin
  If Mem[$0000:$0449] = 7 Then VidSeg := $B000
  Else VidSeg := $B800;
end;

function MakeWord(H, L: Byte): Word; assembler;
asm
  mov ah, h
  mov al, L
end;

procedure WriteStr(x, y: Integer; var WriteStr: String; Attr: Integer);
var
  i: Integer;
  Loc: Integer;
begin
  dec(y);
  dec(x);
  Loc := (80 * y + x) * 2;
  for i := 1 to Length(WriteStr) do begin
    MemW[VS:Loc] := MakeWord(Attr, Ord(WriteStr[i]));
    inc(Loc, 2);
  end;
end;

var
  S : String;
begin
  S := 'Sambo';
  VS := VidSeg;
  WriteStr(10,10, S, 14 + 1 * 16);
  ReadLn;
end.
