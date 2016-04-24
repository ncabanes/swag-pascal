(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0030.PAS
  Description: Window Shadows
  Author: LOU DUCHEZ
  Date: 08-27-93  21:54
*)

{
LOU DUCHEZ

> When I open the window, I want to give it a shadow, in C what you
>would do is switch the 2nd bit of each character.

Shadowing here.  You'll need "Crt" for this to work:
}

procedure atshadow(x1, y1, x2, y2 : byte);
{ Makes a "shadow" to the right of and below a screen region, by setting the
  foreground there to low intensity and the background to black. }
type
  videolocation = record
    videodata      : char;
    videoattribute : byte;
  end;
var
  xbegin, xend,
  ybegin, yend,
  xcnt, ycnt   : byte;
  videosegment : word;
  monosystem   : boolean;
  vidptr       : ^videolocation;

begin
  { Determine location of video memory. }
  monosystem := (lastmode in [0, 2, 7]);
  if monosystem then
    videosegment := $b000
  else
    videosegment := $b800;
  { Determine the x coordinates where the shadowing begins and ends on the
    lower edge.  (Basically two spaces to the right of the box.) }

  xbegin := x1 + 2;
  xend   := x2 + 2;

  { Determine the y coordinates where the shadowing begins and ends on the
    right.  (Basically one row below the box.) }

  ybegin := y1 + 1;
  yend   := y2 + 1;
  ycnt   := ybegin;
  while (ycnt <= yend) and (ycnt <= 25) do
  begin
  { This loop goes through each row, putting in the shadows on the right and
    bottom.  First thing to check on each pass: if we're not below the region
    to shadow, shade only to the right.  Otherwise, start at the left. }
    if ycnt > y2 then
      xcnt := xbegin
    else
      xcnt := x2 + 1;
    vidptr := ptr(videosegment, 2 * (80 * (ycnt - 1) + (xcnt - 1)));
    while (xcnt <= xend) and (xcnt <= 80) do
    begin
    { This loop does the appropriate shadowing for this row. }
      vidptr^.videoattribute := vidptr^.videoattribute and $07; { SHADOW! }
      xcnt := xcnt + 1;
      inc(vidptr);
    end;
    ycnt := ycnt + 1;
  end;
end;


