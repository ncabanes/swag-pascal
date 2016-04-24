(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0014.PAS
  Description: Which BIOS
  Author: KAI ROHRBACHER
  Date: 11-02-93  04:59
*)

{
KAI ROHRBACHER

> What bios are you using?
It's  an AMI-BIOS, dated 03-06-1992; but I ran the same code on an old
Tandon-AT (with BIOS from 1987) w/o problems, too!

> Do you have any other timing code?
Not  at  hand;  one  could reProgram the trigger rate of timer 0 to be
faster  than  1/18.2  sec,  but in my experience, this results in even
more incompatibilities when interfacing the Unit to others.
}

Function BIOScompatible : Boolean;
Var
  Flag : Byte;
  p    : Pointer;
begin
  Flag := 0;
  p    := @Flag;
  if AT then
  Asm
    STI
    xor CX, CX
    MOV DX, 1
    LES BX, p
    MOV AX, 8300h  {trigger 1 microsecond}
    INT 15h
   @L11:
  end;
  Delay(1); {wait 1 ms:}
  BIOScompatible := Flag = $80; {has flag been set?}
end;

{
  ...results  in  False  For you, I can't do much! However, I'll add the
  above  routine to disable the timing mechanism in that Case to prevent
  the endless loop, at least.
}

