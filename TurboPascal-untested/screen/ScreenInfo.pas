(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0050.PAS
  Description: Screen Info
  Author: SEAN PALMER
  Date: 01-27-94  11:59
*)

{
> This would be a simple way to check for the screen size.
> Clr The screen
> Set the colors to Back on Background and Forground so that no one sees
> what is happening.
> Make a For L := 1 to 50;
> Do a WriteLN(L);
> then after the top line shgould have the letter "2" if it's a 50 lines
> down else it would have 9 there.
> to get the image just use the IF PORT[$B800:000] =$32 Then { 50 lines
}

var
 mode:byte absolute $40:$49;       {cur video mode}
 columns:byte absolute $40:$4A;
 dispSize:word absolute $40:$4C;   {cur page size in bytes}
 dispOfs:word absolute $40:$4E;    {cur page offset}
 cursor:array[0..7]of record x,y:byte;end absolute $40:$50;
 cursorMode:word absolute $40:$60; {scan lines start/end?}
 numPages:byte absolute $40:$62;   {video pages avail} {or activePage??}
 crtcPort:word absolute $40:$63;   {CRTC port addr}
 modeSave:byte absolute $40:$65;   {crtModeSet}
 colorSave:byte absolute $40:$66;  {crtPalette}

 ticker:longint absolute $40:$6C;  {18.2x/sec} {timer}

 lastRow:byte absolute $40:$84;    {newer bios only:rows on screen-1}
 points:byte absolute $40:$85;     {newer bios only:scan lines per char}

{
These last two are the interesting ones. LastRow is set to rows-1 on newer
bios's and by up-to-date programs that tweak the CRTC. Otherwise it will
contain 0, meaning 25 lines, for older Bios's

There's a wealth of information up there, man.

And I think this:
}
function ScrnLines:word;begin
 if lastRow=0 then lastRow:=24;   {set in case BIOS doesn't}
 scrnLines:=lastRow+1;
 end;


{Untested but should work.}

