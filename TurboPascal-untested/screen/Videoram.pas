(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0017.PAS
  Description: VIDEORAM.PAS
  Author: BERNIE PALLEK
  Date: 05-28-93  13:56
*)

{
Author : BERNIE PALLEK

> Thanks to those of you who have been answering my question about
> writing to the last position on the far right bottom of the screen.
> As you will recall, the trouble I had was that when you Write to that
> position (position 80, line 25) using a Write (not a Writeln) statement

Another solution would be to create a Procedure that directly Writes to the
video ram, like this:
}

Const
  vidSeg = $B800;  { $B000 For monochrome monitors }

Procedure WriteAt(x1, y1 : Byte; msg : String);
Var
  i : Integer;
begin
  For i := 1 to Length(msg) do
    Mem[vidSeg : (x1 + i - 1) * 2 + (y1 - 1) * 160] := msg[i];
end;

{
This will change the Text on any place on the screen, disregarding the cursor
position.  Be careful, though!  if you Write a message With, say, 20
Characters, and start it at 80, 25, only the first letter will be visible, and
the rest of the String will over-Write other areas of ram, which could cause
mayhem!  Use With caution!
}
