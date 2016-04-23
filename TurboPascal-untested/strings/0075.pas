{ Here is another set of routines to convert Decimal to Hex and vice versa}

CONST
  HexString : array [0..15] of char = '0123456789ABCDEF';

FUNCTION Dec2Hex (Num : word) : string;
{ Returns decimal value as hex string }
VAR
  Loop  : Byte;
  S     : string [10];

BEGIN
  S := '';                                 { empty string }   
  for Loop := 1 to 4 do begin              { do 4 chars }
    S := HexString [Lo (Num) and $F] + S;  { use 4 lowest bits } 
    Num := Num shr 4;                      { shift bits right 4 } 
    end;
  Dec2Hex := '$' + S;                      { return string } 
END;

FUNCTION Hex2Dec (S : string) : longint;
{ returns hexadecimal string as decimal value }
VAR
  Len   : byte absolute S;
  Loop  : byte;
  Li    : longint;
  Num   : longint;

BEGIN
  if S [1] = '$' then delete (S, 1, 1);
  if upcase (S [Len]) = 'H' then dec (S [0]);
  Num := 0;
  for Loop := 1 to Len do begin
    Li := 0;
    while
      (HexString [Li] <> S [Loop])         { compare letter }
        and
      (Li < 16)
    do
      inc (Li);                            { inc counter }
    if Li = 16 then begin
      Num := -1;                           { -1 if invalid }
      exit;
      end;
    Num := Num + Li shl ((Len - Loop) * 4);   { add to Num }
    end;
  Hex2Dec := Num;                          { return value }
END;

