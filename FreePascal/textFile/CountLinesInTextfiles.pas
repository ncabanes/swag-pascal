(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0070.PAS
  Description: Measures # of lines in textfiles
  Author: CHRIS AUSTIN
  Date: 11-22-95  15:49
*)


Function Measure(FileName : String) : LongInt;
 Var Counter   : LongInt;
     FileHandle: Text;
Begin
    Assign(FileHandle,FileName);
    Reset(FileHandle);
    Counter:=0;
    Repeat
        Inc(Counter);
        ReadLn(FileHandle); { This line was missing in the original snippet }
    Until EOF(FileHandle);
    Measure:=Counter;
End;

begin
    WriteLn(Measure('CountLinesInTextfiles.pas'));
end.

