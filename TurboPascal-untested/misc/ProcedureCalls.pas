(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0101.PAS
  Description: Procedure Calls
  Author: FRANK DIACHEYSN
  Date: 08-24-94  13:27
*)

{
  Coded By Frank Diacheysn Of Gemini Software

  PROCEDURE CALLFUNCTION

  Input......: UserRoutine = Pointer To The Routine To Call
             : NA          = String To Pass To <UserRoutine>
             :
             :
             :

  Output.....: None
             :
             :
             :
             :

  Example....: PROCEDURE CALLME(Str:STRING);
             : BEGIN
             :   WriteLn(Str);
             : END;
             :
             : MyPointer := @CallMe;
             : CallFunction(MyPointer,'Calling You!');

  Description: Used To Call A Function Or A Procedure, Mainly A
             : Procedure, Since Output Of The Function Can't Be
             : Returned.
             :
             :

}
PROCEDURE CALLFUNCTION(UserRoutine:POINTER; NA:STRING);
  PROCEDURE InsideCallFunction(NA:STRING);
  INLINE( $FF/$5E/<UserRoutine );
BEGIN
  InsideCallFunction(NA);
END;

