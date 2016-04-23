{
well.. if you don't mind it not being in assembly, i can help..
BTW: your 19?? Byte Array wouldn't store the whole screen.. barely half of
it. the color Text screen is 4000 Bytes. 2000 Characters + 2000 attributes
of those Characters.
}
Type
  screen = Array[1..4000] of Byte;
Var
  scr : screen Absolute $b800:0000; (* or $B000:0000 For Mono *)
  scrf : File of screen;
begin
  assign(scrf,paramstr(1)); (* or Whatever Filename *)
  reWrite(scrf);
  Write(scrf,scr);
  close(scrf);
end.

