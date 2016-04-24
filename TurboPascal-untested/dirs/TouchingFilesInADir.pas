(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0056.PAS
  Description: Touching Files in a DIR
  Author: MICHAEL RUSSELL
  Date: 02-21-96  21:04
*)


Program TouchDir;

Uses Dos;

Var S:SearchRec;
     F:Text;
     H,M,S,Hund:Word;
     DOW,Year,Month,Day:Word;
     FTime:LongInt;
     DT:DateTime;
     Dir:String;

Begin
 If ParamCount = 0 Then
 Begin
  Writeln('Usage: TOUCHDIR <dirname>');
  Halt;
 End;
 FindFirst(Dir,Directory,S);
 If DosError = 0 Then
 Begin
  Assign(F,Dir);
  GetTime(H,M,S,Hund);
  GetDate(Year,Month,Day,DOW);
  DT.Hour:=H;
  DT.Min:=M;
  DT.Sec:=S;
  DT.Year:=Year;  
  DT.Month:=Month;
  DT.Day:=Day;
  PackTime(DT,FTime);
  SetFTime(F,FTime);
  Writeln('Touched the ',Dir,' directory.');
 End
End.


