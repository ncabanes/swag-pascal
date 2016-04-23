{ INGO ROHLOFF

> I've got a problem I just CAN'T solve...
> In a PASCAL-program I want to execute a procedure every time the user
> presses a key... Fairly easy, right ? But here comes the problem : I want
> to repeat that procedure until he RELEASES that key...

The only way to do that is to hook up the int 9 (the Keyoard Int...).
}

Program KEY;

uses
  crt, dos;

var
  oldint  : pointer;
  keydown : byte;
  keys    : array [0..127] of boolean;
  scan,
  lastkey : byte;

procedure init;
var
  i : byte;
begin
  clrscr;
  for i := 0 to 127 do
    keys[i] := false;   {No keys pressed}
  keydown := 0;
end;

procedure INT9; interrupt;
begin
  scan := port[$60];     { Get Scancode }
  if scan > $7F then     { Key released ? }
  begin
    if keys[scan xor $80] then
      dec(keydown);
    keys[scan xor $80] := false;   {Yes !}
  end
  else
  begin
    if not keys[scan] then
      inc(keydown);
    keys[scan] := true;  {NO ! Key pressed }
    lastkey := scan;
  end;
  port[$20] := $20;  { Send EndOfInterrupt to Interruptcontroller }
end;

begin
  init;
  getintvec(9, oldint);
  setintvec(9, @INT9);
  repeat
    if (keydown > 0) and not keys[1] then
    begin
      repeat
        sound(lastkey * 30);
      until keydown = 0;
      nosound;
    end;
  until keys[1];        {*** Wait for ESC pressed ***}
  setintvec(9, oldint);
end.
