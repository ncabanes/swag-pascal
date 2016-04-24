(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0097.PAS
  Description: Image to File
  Author: PAUL BROMAN
  Date: 05-26-94  06:18
*)

{
S> Hi all.. I need some help.. I'm using GetImage to grab a portion
AS> of the graphics screen - so I can use PutImaget to "Paste" it on
AS> the screen later.  My question is : Can this GetImage be saved to
AS> a file & loaded later.. If so how do I save and load it?  I would
AS> appreciate any help you can give me ... Angel Sanchez.

It sure can.  Take a look at this code:

To Save: }

program SaveImage;

var
  upx, lefty, downx, righty: word;
  ScreenCapSize : longint;
  ScreenLoc : pointer;
  CapFile : file;

ScreenCapSize := ImageSize(upx, lefty, downx, righty);
GetMem(ScreenLoc, ScreenCapSize);
GetImage(upx, lefty, downX, rightY, ScreenLoc^);
Assign(CapFile, 'FILENAME.FIL');
Rewrite(CapFile, ImageSize(0,0,60,60));
BlockWrite(CapFile, ScreenLoc^, ScreenCapSize);
Close(CapFile);
end.

program LoadImage;

var
  X, Y: word;
  ScreenCapSize : longint;
  ScreenLoc : pointer;
  CapFile : file;

begin
ScreenCapSize := {Original Size of capture pic}
GetMem(ScreenLoc, ScreenCapSize);
Assign(CapFile, 'FILENAME.FIL');
Reset(CapFile, ScreenCapSize);
Seek(CapFile, 1 {Or whichever image to read});
BlockRead(CapFile, ScreenLoc^, ScreenCapSize);
Close(CapFile);
PutImage(X, Y, ScreenLoc^);
end.


