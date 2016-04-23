{BF-Find v1.1}
{(C) 1995 Brian Leiter}

PROGRAM BFFIND;

USES DOS,CRT;

Var
 DirInfo,Path   : SearchRec;
 S,S1,S2        : String;
 Count          : LongInt;
 L,I            : Integer;

Const ProgName  = 'BFFIND';
      Version   = 'v1.1';
      Compiled  = '12-23-95';
      CopyRight = '(C) 1995 Brian Leiter';

Procedure FindFile;
Begin
  FindFirst(S1, Archive, DirInfo);
  While DosError = 0 Do
  Begin
    Count:=Count+1;
    Writeln(S2,Path.Name,'\',DirInfo.Name);
    FindNext(DirInfo);
  End;
  Exit;
End;

Procedure FindDir;
Begin
  FindFirst('*.', Directory, Path);
  S2:=S2+'\';
  While DosError = 0 Do
  Begin
    ChDir(Path.Name);
    FindFile;
    ChDir('\');
    FindNext(Path);
  End;
  Exit;
End;

Procedure Start;
Begin
  Count:=0;
  Textcolor(15);TextBackGround(4);
  Writeln('╒═══════════════════════════════════╕');
  Writeln('│ BFFIND v1.1              12-23-95 │');
  Writeln('│                                   │');
  Writeln('│ A Search And Find Utility For DOS │');
  Writeln('│                                   │');
  Writeln('│ (C) 1995 Brian Leiter  *FREEWARE* │');
  Writeln('╘═══════════════════════════════════╛');
  Textcolor(7);TextBackGround(0);
  Writeln('');
  S1:=ParamStr(1);
  If ParamCount>0 Then
  Begin
    L:=Length(S1);
    For I:=1 To L Do S1[I]:=UpCase(S1[I]);
    Writeln('Searching For ',S1);
  End;
  GetDir(0,S);
  If ParamCount=0 Then
  Begin
    Write('BFFIND What: ');
    Readln(S1);
    L:=Length(S1);
    For I:=1 To L Do S1[I]:=UpCase(S1[I]);
    If L=0 Then Halt;
  End;
  ChDir('\');
  GetDir(0,S2);
  Delete(S2,3,1);
  Exit;
End;

Begin
  ClrScr;
  Start;
  Writeln('');
  FindFile;
  FindDir;
  Chdir(S);
  Writeln('');
  If Count>1 Then Writeln(S1,' was found ',Count,' times in the directories listed above.');
  If Count=1 Then Writeln(S1,' was found 1 time in the directory listed above.');
  If Count=0 Then Writeln(S1,' was not found on this drive.');
End.