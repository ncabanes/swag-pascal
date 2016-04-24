(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0085.PAS
  Description: Purge the COMM Port
  Author: JOHN STEPHENSON
  Date: 05-26-95  23:25
*)

{
> Hi i am trying to make a thing to use an EMSI handshake.. i
> have almost got it working, but i need a routine to purge all the input
> from the com port. can anyone help me out there?  i know i had one but
> can't find anything that  will really work anymore ... thanks.
}

Procedure FlushOutput; assembler;
{ Wait for all buffer output to be output :) }
asm
  mov AH, $08
  mov DX, fosport
  Int $14
End;

Procedure PurgeInput; assembler;
{ Purges the input buffer -- Empties it into obilivion! }
asm
  mov AH, $0A
  mov DX, fosport
  Int $14
End;


