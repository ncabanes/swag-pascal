
{Here is the code I promised to sent you. It works nice. You can read
any part of the real-mode low memory with it.}

function allocRealModePointer(var P: pointer; Size: longInt): boolean;
var
  Selector,
  base : word;
  LinearBase : longint;
begin
  result := false;
  LinearBase := MakeLong(0,hiword(longint(p)) shr 12) +
                  hiword(longint(P)) shl 4 + loword(longint(P));
                  {converts 20-bit address into a 32-bit one}
                  {i.e. $ffff:0006 into $000ffff6}
  Selector := AllocSelector(DSeg); {Copies DSeg Selector properties }
  base := SetSelectorBase(Selector, LinearBase);
  SetSelectorLimit(Selector, Size);
  if (Selector <> 0) and (base<>0) then  begin
    P := Ptr(Selector, 0);
    result := true;
  end;
end;

function freeRealModePointer(var p: pointer): boolean;
var
  fr : Word;
begin
  fr := FreeSelector(hiword(longint(p)));
  {seletor is at hiword(p)}
  if (fr=0) then begin {ok}
    p := nil;
    result := true;
  end else begin	{fail}
    result := false;
  end;
end;

{ code Test:    The Rom-Bios' date is allways at $ffff:0005 (real-mode)}

var
  P: pChar;
begin
  P := Ptr($FFFF, $0005);   {FFFF5 -> data da Rom-Bios}
  if AllocRealModePointer(Pointer(p), 8) then {8 chars to RomBios' date}
  begin
    { Use p to read ROM Bios' date here}
    FreeRealModePointer(Pointer(p));   {dispose p}
  end;
end.
