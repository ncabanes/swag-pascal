{
SEAN PALMER

> I don't know if you'd be interested, but here's my version of a
> direct-video writer: QWRITE.

I've optimized it a little, if you're interested... 8)

This is WITHOUT using inline ASM... I have routines that would put this
optimized version to shame, in assembler....

This runs 2290 times in the time it took yours to run 1754 times in a
test I ran.

I suggest removing the f and b parameters, and using the crt.textAttr
variable so the user can set textcolor() and textbackground() before
calling the routine and it'll come out ok, since you depend on crt
anyway for the lastmode var... actually why not use wherex() and
wherey() instead of passing THOSE as parameters too... hmm...
}

procedure qwrite(x, y : byte; s : string; f, b : byte);

{ Does a direct video write -- extremely fast.  <----hehehe
  X, Y = screen location of first byte;
  S = string to display;
  F = foreground color;
  B = background color. }

var
  cnter  : word;
  vidPtr : ^word;
  attrib : word;

begin
  attrib := swap((b shl 4) + f);
  vidptr := ptr($B800, 2 * (80 * pred(y) + pred(x)));
  if lastmode = 7 then
    dec(longint(vidptr), $08000000);
  for cnter := 1 to length(s) do
  begin
    vidptr^ := attrib or byte (s[cnter]);
    inc(vidptr);
  end;
end;
