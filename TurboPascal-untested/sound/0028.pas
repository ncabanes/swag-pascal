{
BRIAN PAPE

Ok, here's about 45 minutes of sweating, trying to read some pitifull SB
reference.  This is about as far as I've gotten trying to make the SB
make some noise that is actually a note, not just a buzz...  If anyone
can do ANYTHING at ALL with this, please tell me.

This program is not Copyright (c)1993 by Brian Pape.
written 4/13/93
It is 100% my code with nothing taken from anyone else.  If you can use it in
anyway, great.  I should have the actual real version done later this summer
that is more readable.  The .MOD player is about half done, pending the
finishing of the code to actually play the notes (decoder is done).
My fido address is 1:2250/26
}
program sb;
uses
  crt;
const
  on     = true;
  off    = false;
  maxreg = $F5;
  maxch  = 10;

  note_table : array [0..12] of word =
    ($000,$16b,$181,$198,$1b0,$1ca,$1e5,$202,$220,$241,$263,$287,$2ae);
  key_table  : array [1..12] of char =
    'QWERTYUIOP[]';
  voicekey_table : array [1..11] of char =
    '0123456789';
type
  byteset = set of byte;

var
  ch        : char;
  channel   : byte;
  ch_active : byteset;
  lastnote  : array [0..maxch] of word;


procedure writeaddr(b : byte); assembler;
asm
  mov  al, b
  mov  dx, 388h
  out  dx, al
  mov  cx, 6

 @wait:
  in   al, dx
  loop @wait
end;

procedure writedata(b : byte); assembler;
asm
  mov  al, b
  mov  dx, 389h
  out  dx, al
  mov  cx, 35h
  dec  dx

 @wait:
  in   al, dx
  loop @wait
end;

procedure sb_reset;
var
  i : byte;
begin
  for i := 1 to maxreg do
  begin
    writeaddr(i);
    writedata(0);
  end;
end;

procedure sb_off;
begin
  writeaddr($b0);
  writedata($11);
end;

{ r=register,d=data }
procedure sb_out(r, d : byte);
begin
  writeaddr(r);
  writedata(d);
end;

procedure sb_setup;
begin
  sb_out($20, $01);
  sb_out($40, $10);
  sb_out($60, $F0);
  sb_out($80, $77);
  sb_out($A0, $98);
  sb_out($23, $01);
  sb_out($43, $00);
  sb_out($63, $F0);
  sb_out($83, $77);
  sb_out($B0, $31);
end;

procedure disphelp;
begin
  clrscr;
  writeln;
  writeln('Q:C#');
  writeln('W:D');
  writeln('E:D#');
  writeln('R:E');
  writeln('T:F');
  writeln('Y:F#');
  writeln('U:G');
  writeln('I:G#');
  writeln('O:A');
  writeln('P:A#');
  writeln('[:B');
  writeln(']:C');
  writeln('X:Quit');
  writeln;
end;

procedure sb_note(channel : byte; note : word; on : boolean);
begin
  sb_out($a0 + channel, lo(note));
  sb_out($b0 + channel, ($20 * byte(on)) or $10 or hi(note));
end;

procedure updatestatus;
var
  i : byte;
begin
  gotoxy(1,16);
  for i := 0 to maxch do
  begin
    if i in ch_active then
      textcolor(14)
    else
      textcolor(7);
    write(i : 3);
  end;
end;

begin
  sb_reset;
  sb_out(1, $10);
  sb_setup;
  disphelp;
  channel   := 0;
  ch_active := [0];
  repeat
    updatestatus;
    ch := upcase(readkey);
    if pos(ch, key_table) <> 0 then
    begin
      lastnote[channel] := note_table[pos(ch, key_table)];
      sb_note(channel, lastnote[channel], on);
    end
    else
    if pos(ch, voicekey_table) <> 0 then
    begin
      channel := pred(pos(ch,voicekey_table));
      if channel in ch_active then
        ch_active := ch_active - [channel]
      else
        ch_active := ch_active + [channel];
      if not (channel in ch_active) then
        sb_note(channel,lastnote[channel],off)
      else
        sb_note(channel,lastnote[channel],on);
    end;
  until ch = 'X';
  sb_off;
end.

