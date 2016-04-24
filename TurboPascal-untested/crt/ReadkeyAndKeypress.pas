(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0008.PAS
  Description: Readkey and KEYPRESS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

{
Crt Unit, but I don't want to use the Crt.  Could some one show
me a routine For Pause, or Delay With a Time Factor?

  ...I can supply you With KeyPressed and ReadKey routines For
  TP6 or TP7, which could be used to create a Pause routine.
  The Delay is a bit harder, I've got a routine I wrote last
  year For this, but I'm still not happy With it's accuracy.
}

{ Read a key-press. }
Function ReadKeyChar : {output} Char; Assembler;
Asm
  mov ah, 00h
  int 16h
end; { ReadKeyChar. }

{ Function to indicate if a key is in the keyboard buffer. }
Function KeyPressed : {output} Boolean; Assembler;
Asm
  mov ah, 01h
  int 16h
  mov ax, 00h
  jz #1
  inc ax
  @1:
end; { KeyPressed. }

