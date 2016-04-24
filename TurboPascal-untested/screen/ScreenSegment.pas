(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0054.PAS
  Description: Screen Segment
  Author: MAYNARD PHILBROOK
  Date: 01-27-94  12:04
*)

{
> I have always addressed $B800 as the screen segment for direct video
> writes in text.... Err, umm, does anyone have the code to detect
> whether it is $B000 or $B800 (for Herc.'s and the like)...

 call the Bios INt $10 Function $0f to get video mode.
}

Function GetVideoSegment:Word;
 Begin
  Asm
       Mov     AH,$0f;
       INT    $10;
       Cmp     AL, $07;        { Monochrome? }
       Jne     @No;
       Mov     @Result, $B000;
       Jmp     @Done;
@No:   Mov     @Result, $B800;
@Done:
  End;
End;

begin
 Write( GetVideoSegment);
End.

