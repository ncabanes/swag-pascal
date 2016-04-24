(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0040.PAS
  Description: Simple Phone Dialer
  Author: WIN VAN DER VEGT
  Date: 01-27-94  17:36
*)

{
From: WIM VAN DER VEGT
Subj: Accessing the phone
---------------------------------------------------------------------------
Thanks, works great and is quite simple. Have modified it a litte so it
attaches the ATDT command and waits for the user to pick up the phone.
After that it hangs-up the modem. I forgot how easy it is to send
SOME characters to the serial port.
}

Uses
  Crt;

PROCEDURE PhoneDialler (Number : String; Port : Byte);

var
   SerialPort  : text;   { Yes, a text file! }

begin
   Case Port of
      1 : Assign (SerialPort, 'COM1');
      2 : Assign (SerialPort, 'COM2');
      3 : Assign (SerialPort, 'COM3');
      4 : Assign (SerialPort, 'COM4');
   end; { CASE }
   Rewrite (SerialPort);

   Writeln('Tone dialing ',Number,'.');
   Writeln (SerialPort, 'ATDT'+Number);

 {----Should be large enough to dial the longest number}
   Delay(6*1000);

   Write('Pick up the phone, then press space ');
   WHILE NOT(Keypressed AND (Readkey=#32)) DO
     Begin
       Write('.');
       Delay(1000);
     End;
   Writeln;

   Writeln('Shuting down modem.');
   Writeln (SerialPort,'ATH0');
   Close (SerialPort)
end; { of PROCEDURE 'Phone Dialler' }

Begin
  PhoneDialler('045-762288',2);
End.

