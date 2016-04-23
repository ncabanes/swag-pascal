Unit Execute;

Interface

Procedure Exec(Path,CmdLine : String);

Implementation

Uses
  Dos;

Function ExtractFileName(Var Line : String;Index : Integer) : String;

Var
  Temp : String;

begin
  Delete(Line,Index,1);
  While (Index <= Length(Line)) and (Line[Index] = ' ')
    Do Delete(Line,Index,1);
  Temp := '';
  While (Index <= Length(Line)) and (Line[Index] <> ' ') Do
  begin
    Temp := Temp + Line[Index];
    Delete(Line,Index,1);
  end;
  ExtractFileName := Temp;
end;

Procedure CloseHandle(Handle : Word);

Var
  Regs : Registers;

begin
  With Regs Do
  begin
    AH := $3E;
    BX := Handle;
    MsDos(Regs);
  end;
end;

Procedure Duplicate(SourceHandle : Word;Var TargetHandle : Word);

Var
  Regs : Registers;

begin
  With Regs Do
  begin
    AH := $45;
    BX := SourceHandle;
    MsDos(Regs);
    TargetHandle := AX;
  end;
end;

Procedure ForceDuplicate(SourceHandle : Word;Var TargetHandle : Word);

Var
  Regs : Registers;

begin
  With Regs Do
  begin
    AH := $46;
    BX := SourceHandle;
    CX := TargetHandle;
    MsDos(Regs);
    TargetHandle := AX;
  end;
end;

Procedure Exec(Path,CmdLine : String);

Var
  StdIn   : Word;
  Stdout  : Word;
  Index   : Integer;
  FName   : String[80];
  InFile  : Text;
  OutFile : Text;

  InHandle  : Word;
  OutHandle : Word;
         { ===============>>>> }   { change below For STDERR }
begin
  StdIn := 0;
  StdOut := 1;                    { change to 2 For StdErr       }
  Duplicate(StdIn,InHandle);      { duplicate standard input     }
  Duplicate(StdOut,OutHandle);    { duplicate standard output    }
  Index := Pos('>',CmdLine);
  If Index > 0 Then               { check For output redirection }
  begin
    FName := ExtractFileName(CmdLine,Index);  { get output File name  }
    Assign(OutFile,FName);                    { open a Text File      }
    ReWrite(OutFile);                         { .. For output         }
    ForceDuplicate(TextRec(OutFile).Handle,StdOut);{ make output same }
  end;
  Index := Pos('<',CmdLine);
  If Index > 0 Then               { check For input redirection }
  begin
    FName := ExtractFileName(CmdLine,Index);  { get input File name  }
    Assign(InFile,FName);                     { open a Text File     }
    Reset(InFile);                            { For input            }
    ForceDuplicate(TextRec(InFile).Handle,StdIn);  { make input same }
  end;
  Dos.Exec(Path,CmdLine);           { run EXEC }
  ForceDuplicate(InHandle,StdIn);   { put standard input back to keyboard }
  ForceDuplicate(OutHandle,StdOut); { put standard output back to screen  }
  CloseHandle(InHandle);            { Close the redirected input File     }
  CloseHandle(OutHandle);           { Close the redirected output File    }
end;

end.

{===============================================================}
{
Use it exactly as you would the normal EXEC Procedure:

  Exec('MAsm.EXE','mystuff.Asm');

To activate redirection simply add the redirection symbols, etc:

  Exec('MAsm.EXE','mystuff.Asm >err.lst');

One note of caution.  This routine temporarily Uses extra handles. It's
either two or four more.  The Various books I have are not clear as to
whether duplicated handles 'count' or not. My guess is yes.  If you don't
plan on redirecting STDIN then reMove all the code For duplicating it to
cut your handle overhead in half.
}

