(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0028.PAS
  Description: Finding the end of EXE
  Author: ROB PERELMAN
  Date: 11-26-94  05:02
*)

{ could be used to append data to the end of an EXE file }

Unit ExeEnd;

Interface

Uses Dos;

Var EndOfExe, SizeOfData: LongInt;
    Data: Boolean;

  Function GetExeInfo(Const Name: PathStr; var Data: Boolean; var EndOfExe,
    SizeOfData: LongInt): Boolean;

Implementation

Function GetExeInfo(Const Name: PathStr; var Data: Boolean; var EndOfExe,
  SizeOfData: LongInt): Boolean;
Const CorrectExe=$5A4D; {'MZ'}
Var Header: Array[1..3] of Word; {ID, ByteMod, Pages}
    F: File;
    ReadIn: Word;
Begin
  Data:=False;
  EndOfExe:=0;
  SizeOfData:=0;
  If Name='.' then Exit;
  Assign(F, Name);
  {$I-} Reset(F, 1); {$I+}
  If IOResult=0 then Begin
    BlockRead(F, Header, SizeOf(Header), ReadIn);
    If (ReadIn=SizeOf(Header)) and (Header[1]=CorrectExe) then
      EndOfExe:=LongInt(Header[3]-1)*512+Header[2];
    SizeOfData:=FileSize(F)-EndOfExe;
    Close(F);
    Data:=SizeOfData>0;
    GetExeInfo:=True;
  End Else GetExeInfo:=False;
End;

Begin
  If Lo(DosVersion)>=3 then GetExeInfo(ParamStr(0), Data, EndOfExe,
    SizeOfData) Else GetExeInfo('.', Data, EndOfExe, SizeOfData);
End.

