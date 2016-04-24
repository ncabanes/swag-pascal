(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0046.PAS
  Description: Trapping Runtime Errors
  Author: JON JASIUNAS
  Date: 11-02-93  05:35
*)

{
JON JASIUNAS

I never use them. if a Program bombs because a disk is full, I just
> catch the run-time error in an Exit proc and report so (I/O-checking
> must be set on, of course).

>I am curious, How do you go about Catching the Run-Time Error. Doesn't it
>just say Runtime Error 103 ?????:?????

You can catch the run-time errors by linking into the Exit chain.
Here's a small example:
}

Unit ErrTrap;

Interface

Implementation

Var
  OldExit : Pointer;

Procedure NewExit; Far;  { MUST be far! }
begin
  if ErrorAddr <> nil then
  begin
    {-Display custom run-time error message }
    WriteLn('Fatal error #', ExitCode);
    WriteLn('Address = ', Seg(ErrorAddr^), ':', Ofs(ErrorAddr^));
    {-Cancel run-time error so you don't get the default message, too }
    ErrorAddr := nil;
    {-Zero the errorlevel }
    ExitCode  := 0;
  end;
  ExitProc := OldExit;
end;

begin
  OldExit  := ExitProc;
  ExitProc := @NewExit;
end.



