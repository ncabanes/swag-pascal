{
> Can anyone tell me (or give me the source code) how I can grab
> a screen in textmode and put it later back on the screen.

If you want your software to be compatible, use the following procedures,
functions and structs:
}

const
  MaxScr=25;

type
  ScrRec=record Ptr:pointer; Size:word; end;
  ScrType=array[1..MaxScr] of ScrRec;            { Pointers to saved screens }

var
  Screen:ScrType;
  ScrCtr:byte;                                       { Index to saved screen }
  v_vidseg:word;                               { Segmentaddress of video-RAM }
  v_pageinmem:boolean;                          { screenpage saved in memory }

{ current number of rows }
function rows:byte;
var tmp:byte;
begin
  tmp:=mem[$40:$84]+1;
  if tmp<25 then rows:=25 else rows:=tmp;
end;

{ current number of columns }
function cols:byte;
var tmp:byte;
begin
  tmp:=mem[$40:$4a];
  if tmp<80 then cols:=80 else cols:=tmp;
end;

{ save screen }
procedure setscr;
begin
  Screen[ScrCtr].Size:=Rows*Cols*2;
  getmem(Screen[ScrCtr].Ptr,Screen[ScrCtr].Size);
  move(mem[v_vidseg:0],Screen[ScrCtr].Ptr^,Screen[ScrCtr].Size);
  inc(ScrCtr);
  v_pageinmem:=true;
end;

{ restore last screen }
procedure getscr;
begin
  if ScrCtr>1 then begin
    dec(ScrCtr);
    move(Screen[ScrCtr].Ptr^,mem[v_vidSeg:0],Screen[ScrCtr].Size);
    freemem(Screen[ScrCtr].Ptr,Screen[ScrCtr].Size);
  end else v_pageinmem:=false;
end;

{ determine video-segment: }
begin
  Regs.ah:=15;                                    { Define actual video-mode }
  intr($10,Regs);                                { Call BIOS video-interrupt }
  if Regs.al=7 then v_vidseg:=$b000                       { Monochrome mode? }
  else v_vidseg:=$b800;                                      { No, Colormode }
  v_pageinmem:=false;
end.

{
If you want to create louzy software, which is not compatible at all, use an
array like:
vidmem:array[1..25,1..80] of record ch:char; attr:byte; end; absolute
$b800:0000;
This array will _ONLY_ work in color-mode on a 25x80 screen. The above
procedures work in _EVERY_ (!) text-mode.
If you've setup everything correctly (just do the determine-stuff), then you
can save a screen by using 'setscr', and restore the screen by 'getscr'. Those
two must be in balance. If you placed some windows on the screen (and saved all
the screens), and an error accurs, you can clear the memory by something like:
while v_pageinmem do getscr;
MaxScr is not the number of lines (25), but the maximum number of screens which
can be saved. If you need more or less, set it to something appropriate, but
use some slack: the structs hardly cost memory (especialy if you compare it
with the array-type). _    _
}
