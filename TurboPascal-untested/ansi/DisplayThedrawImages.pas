(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0010.PAS
  Description: Display THEDRAW Images
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
> if you save as Pascal, and follow the instructions in the manual For
> TheDraw everything will work fine. It is also much more efficient then
> using normal ANSI-Files, since TheDraw-Pascal Files can be Compressed...
}
Var
  VideoSeg : Word;

Procedure VisTheDrawImage(x, y, Depth, Width: Byte; Var Picture);
Var
  c       : Byte;
  scrpos  : Word;
begin
  Dec(y);
  Dec(x);
  ScrPos := y * (ScrCol Shl 1) + x * 2;
  For c := 0 to Depth-1 Do
    Move(Mem[Seg(Picture) : ofs(Picture) + c * (Width Shl 1)],
         Mem[VideoSeg : c * (ScrCol Shl 1) + ScrPos], Width Shl 1);
end;

{
if you picture is not crunched you can use this routine to show them With
VideoSeg has to be $B000 or $B800, then use the Vars from the generated
picture and insert when you call that procedure.
}
