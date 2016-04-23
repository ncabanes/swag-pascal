{You won't get that sort of compression from my routines, but here
they are anyway.  When testing, you'll get best compression if you
use English and longish Strings.
}
Unit Compress;

Interface

Const
  CompressedStringArraySize = 500;  { err on the side of generosity }

Type
  tCompressedStringArray = Array[1..CompressedStringArraySize] of Byte;

Function GetCompressedString(Arr : tCompressedStringArray) : String;

Procedure CompressString(st : String; Var Arr : tCompressedStringArray;
                         Var len : Integer);
  { converts st into a tCompressedStringArray of length len }

Implementation

Const
  FreqChar : Array[4..14] of Char = 'etaonirshdl';
  { can't be in [0..3] because two empty bits signify a space }


Function GetCompressedString(Arr : tCompressedStringArray) : String;
Var
  Shift : Byte;
  i : Integer;
  ch : Char;
  st : String;
  b : Byte;

  Function GetHalfNibble : Byte;
  begin
    GetHalfNibble := (Arr[i] shr Shift) and 3;
    if Shift = 0 then begin
      Shift := 6;
      inc(i);
    end else dec(Shift,2);
  end;

begin
  st := '';
  i := 1;
  Shift := 6;
  Repeat
    b := GetHalfNibble;
    if b = 0 then
      ch := ' '
    else begin
      b := (b shl 2) or GetHalfNibble;
      if b = $F then begin
        b := GetHalfNibble shl 6;
        b := b or GetHalfNibble shl 4;
        b := b or GetHalfNibble shl 2;
        b := b or GetHalfNibble;
        ch := Char(b);
      end else
        ch := FreqChar[b];
    end;
    if ch <> #0 then st := st + ch;
  Until ch = #0;
  GetCompressedString := st;
end;

Procedure CompressString(st : String; Var Arr : tCompressedStringArray;
                         Var len : Integer);
{ converts st into a tCompressedStringArray of length len }
Var
  i : Integer;
  Shift : Byte;

  Procedure OutHalfNibble(b : Byte);
  begin
    Arr[len] := Arr[len] or (b shl Shift);
    if Shift = 0 then begin
      Shift := 6;
      inc(len);
    end else dec(Shift,2);
  end;

  Procedure OutChar(ch : Char);
  Var
    i : Byte;
    bych : Byte Absolute ch;
  begin
    if ch = ' ' then
      OutHalfNibble(0)
    else begin
      i := 4;
      While (i<15) and (FreqChar[i]<>ch) do inc(i);
      OutHalfNibble(i shr 2);
      OutHalfNibble(i and 3);
      if i = $F then begin
        OutHalfNibble(bych shr 6);
        OutHalfNibble((bych shr 4) and 3);
        OutHalfNibble((bych shr 2) and 3);
        OutHalfNibble(bych and 3);
      end;
    end;
  end;

begin
  len := 1;
  Shift := 6;
  fillChar(Arr,sizeof(Arr),0);
  For i := 1 to length(st) do OutChar(st[i]);
  OutChar(#0);  { end of compressed String signaled by #0 }
  if Shift = 6
    then dec(len);
end;

end.
