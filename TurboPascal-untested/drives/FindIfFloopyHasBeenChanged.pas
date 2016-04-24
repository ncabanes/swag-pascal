(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0084.PAS
  Description: Find if Floopy has been changed
  Author: MAYNARD PHILBROOK
  Date: 11-26-94  04:56
*)

{
> Anybody have a quick function that can tell if a diskette has been
> changed? I was just writing a volume label to it then reading that back
> until it changed, but my boss whined about all those disk accesses
> being hard on the drive.
}

function diskchange(drive:byte;):boolean;Assembler;
 asm
  Mov AH,16h;
  mov DL, Byte Ptr Drive;
  Int 13h;
  Mov AL, AH;
 End;

{ Drive byte is in the range of 0 - 1 for A:- B: ect././. }

