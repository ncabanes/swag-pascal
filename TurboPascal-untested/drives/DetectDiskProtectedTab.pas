(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0088.PAS
  Description: Detect Disk Protected Tab
  Author: MAYNARD PHILBROOK
  Date: 11-26-94  04:56
*)

{
> Didn't work. It only checks if the file is there(???) not if the flo
> write-protected. Did I mis understand your suggestion?

 Yes i think we must have got our wires crossed, i thunk i was
replying to a request to see if a file exist,  i would have
no reason for telling use the GetFattr to check for a Write
protected disk, that has to be done by getting the Device Statues.
}
Function DiskProtected:Boolean;
 Begin
  ASm
   Mov AH,01;
   mov dl, 0; { 0= A:, 1= B: ect }
   int $13;
   cmp AL, 03;
   Jne @No;
   Mov AL, True;
   Je @done;
@No:
   Xor AL,AL;
@Done:
  Endl
End;

{ Example: }

if Diskprotected Then Write(' Write protect was used on last operation');

