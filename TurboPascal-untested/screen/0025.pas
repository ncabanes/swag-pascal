===========================================================================
 BBS: Canada Remote Systems
Date: 08-18-93 (08:32)             Number: 34760
From: WILLIAM SCHROEDER            Refer#: NONE
  To: CHRIS PORTMAN                 Recvd: NO  
Subj: RE: DIRECT VIDEO WRITES        Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
 -=> Quoting Chris Portman to All <=-

 CP> Can anyone write me a procedure that will write a character on the
 CP> screen without moving the cursor (ie - DirWrite (80, 25, '!');). I
 CP> just need this to write to the space at 80x25 without scrolling the
 CP> screen.

function GetChar(x, y: integer): char;  (* $B000 for mono *)
var screen: array[1..25, 1..80] of word absolute $B800:0000;
begin
  GetChar := char(screen[x][y] and $FF);
end;

function GetTextColor(x, y: integer): integer;  (* $B000 for mono *)
var screen: array[1..25, 1..80] of word absolute $B800:0001;
begin
  GetTextColor := integer(screen[x][y] and $FF);
end;

  This is not the answer to your problem, but I'm sure it will help. All you
have to do (I *think*) is write back to the screen variable (BIOS). Keep in
mind that X and Y are in DOS format. For some reason, DOS's X-Axis is
vertical and Y-Axis is horizontal; CRT.GotoXY reverses that.
  Sorry I couldn't help further...

... Only reasonable people agree with me.
--- GEcho 1.00
 * Origin: Not Ready For Prime Time * Victoria, Texas (1:3802/221.0)
