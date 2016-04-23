{
From: MIGUEL MARTINEZ
Subj: Accessing the phone
---------------------------------------------------------------------------
 ▒ I am a novice programmer and I am writing an address book type program
 ▒ in TP 6.0. How can I send the phone a number to be dialed? Thanx.

Try this routines:
}

USES CRT;

Procedure DialNumber(Number:String);
Var ComPort:Text;
    ComName:String;
Begin
  ComName:='COM2';   (* Assuming your modem is located there *)
  Assign(ComPort,ComName);
  ReWrite(ComPort);
  Writeln(ComPort,'ATDT'+Number);
  Close(ComPort);
End;

Procedure Hangup;
Var ComPort:Text;
    ComName:String;
Begin
  ComName:='COM2';   (* Assuming your modem is located there *)
  Assign(ComPort,ComName);
  ReWrite(ComPort);
  Writeln(ComPort,'ATH0M1');
  Close(ComPort);
End;

{An example of how to use this routines, is this fragment of code:}
BEGIN
   DialNumber('345554323');
   Repeat Until Keypressed;
   Hangup;
END.

If you don't hang up, guess... You'll get a funny noise if you don't
connect. :)

