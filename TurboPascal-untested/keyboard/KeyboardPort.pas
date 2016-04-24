(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0062.PAS
  Description: Keyboard Port
  Author: DROR LEON
  Date: 01-27-94  12:20
*)

{
> Hello all, I am looking for a scancode for the tab key. I am desperate!
> Please, Any code would be apreciated! Help! Netmail if you wish (1:241/99)

I saw Richard Brown wrote you a reply as a testing program, but it works for
ASCII codes not SCAN codes so :
 }
Var
  old : Byte;
Begin
  WriteLn ('Press any key to begin and ESCAPE to exit.');
  ReadLn;
  old:=$FF;
  While Port[$60]<>1+$80 Do {Until ESCAPE is released, 1 is ESC scan-code}
  Begin
    If (old<>Port[$60]) And (Port[$60]<$80) Then
    Begin
      old:=Port[$60];
      Writeln('Scan code ',old,' pressed - release code is ',old+$80);
    End;
  End;
End.


