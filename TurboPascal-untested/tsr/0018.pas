{
>Does anybody know how to write to disk inside a TSR using
>turbo pascal?  I know all about how to write a simple TSR,
>cannot call Dos functions from within a hardware interrupt.

Here is parts of a tsr to write to disk when a hotkey is pressed
(Leftshift,left alt,right alt)
}

uses dos,crt;
const
 hotkey : byte = 5;
 writekey : byte = 10; {write to disk when this combo comes up }
var
  dat : file of word;  {keep file definition on globals}

procedure diskit;
var
    x,y : word;
begin
  if not cracking then
  begin
    cracking := true;  {disable checking for hotkey while writing}
    assign(dat,'a:\dump.scr');
    rewrite(Dat);
    display;
    for y := 0 to 24 do
      for x := 0 to 79 do
      write(dat,wind[X,y]);
    close(dat);
    current := 1;        {Reset current to 0}
    cracking := false;
  end;
end;
{------------------------------------------------------------}
procedure calloldint(sub:pointer);
begin {calloldint}
inline($9C/$FF/$5E/$06);   {Assembly to pop pointer off stack and call it}
end; {calloldint}
{-------------------------------------------------------------}

procedure tick(flags,cs,ip,ax,bx,cx,dx,si,di,ds,es,bp:word); interrupt;
var regs:registers;
begin
calloldint(oldvec);
   regs.ah := $12;
   intr($16, regs);
   statflags := (regs.al and  regs.ah) and hotkey;
   regflags := (regs.al and  regs.ah) and writekey;
if (statflags = hotkey) and (cnt =0) then
  begin
  cnt := 1;
  display;
  cnt := 0;
  end
else if (regflags = writekey) and (cnt = 0) then
  begin
   cnt := 1;
   diskit;     {write to disk if hotkey}
   cnt := 0;
  end
else inline($FB);
end; {tick}
{-----------------------------------------------------}

begin {MAIN}
writeln('Saving screens function activated');
current := 1;
getintvec($08,oldvec);
setintvec($08,@tick);
getintvec($09,oldkbdvec);
setintvec($09,@keyboard);
cnt := 0;
Cracking := false;
keep(0);
end. {MAIN}

{
This will work for writing to disk as long as no other disk activity is being
performed.
}