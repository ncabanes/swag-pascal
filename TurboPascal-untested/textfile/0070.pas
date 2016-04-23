
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