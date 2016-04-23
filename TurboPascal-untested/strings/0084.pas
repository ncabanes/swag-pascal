{
 > says how big the file is it says it like 34443 and I was
 > wondering
 > is there a command or something I can add in TP6 to make it read
 > 34,443 where it detects where to add a commas. I know there is
}
Program Comma;

Uses Crt;

Var x : longint;
    Y : string;

Function CommaNum ( I : LongInt ) : String;
Var
    TmpString : String;
    Counter, Tester : Byte;
Begin
  TmpString := '';
  Counter   := 0;
  Tester    := 0;
  Str (i, TmpString);
  For Counter := Length (TmpString) Downto 1 Do
  Begin
    Inc (Tester);
    If Tester = 3 Then
    Begin
      Tester := 0;
      Dec (Counter);
      TmpString := Copy (TmpString, 1, Counter) + ','
                 + Copy (TmpString, Counter + 1, Length (TmpString) );
      Inc (Counter);
    End;
  End;
  If TmpString[1] = ',' THEN DELETE(TmpString,1,1);
  CommaNum := TmpString;
End;

Begin
ClrScr;
Write('Enter a number ---> ');
Readln(x);
Y := COMMANUM(X);
Write('Here it is with COMMAS! ---> ');
Write(y);
Readln;
End.
