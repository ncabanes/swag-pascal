(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0071.PAS
  Description: Pushing Chars into buffer
  Author: MAYNARD PHILBROOK
  Date: 02-03-94  16:08
*)

{
From: MAYNARD PHILBROOK
Subj: Re: keyboard buffer
---------------------------------------------------------------------------
 TH> How do you write TO the keyboard buffer.
 TH> I need a routine that will put a string into the keyboard buffer then
 TH> exit to the calling program leaving the key buffer full.
 TH> This is to simulate a macro function for a menu program.
}
 function PushIntoKeyBoard( c:char; ScanCode:Byte):boolean;
  Begin
   asm
       Mov Ah, 05h
       Mov Ch, ScanCode;
       Int $16;
       Mov  @result, Al;       { Results }
   End;
  Result := Not(Result);
  End;

{returns true if Buffer took it other wise it mite be full or Not Supported}

