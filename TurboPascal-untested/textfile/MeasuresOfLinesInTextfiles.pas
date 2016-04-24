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
Until EOF(FileHandle);
Measure:=Counter;
End;

