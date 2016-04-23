Program SPOOLIT;

{ Example program to demonstrate the PRINT spooler interface }

{ Define the data structure we need for spooling files }

Uses DOS;

Type

  SpoolRecType = Record
    Priority : Byte;
    Filename : Pointer;
  end;

Var

  SpoolFile   : PathStr;
  SpoolBuffer : Array[1..70] of char;
  SpoolRec    : SpoolRecType;
  Regs        : Registers;
  SpooledOk   : Boolean;

Begin

  With Regs do begin
    AX := $100;
    Intr($2F,Regs);
    If AL = 0 then Begin
      WriteLn('PRINT is not loaded.');
      Halt
      end
    end;

  { Query user for the name of a file to spool }

  Write('Enter the filename to print: ');
  ReadLn(SpoolFile);

  If Length(SpoolFile) = 0 then Halt;  {Nothing to do, so quit}

  FillChar(SpoolBuffer,SizeOf(SpoolBuffer),0);

  Move(SpoolFile[1],SpoolBuffer,Length(SpoolFile));

  SpoolRec.Priority := 0;
  SpoolRec.Filename := Addr(SpoolBuffer);

  { Send the file on its way }

  With Regs do Begin
    AX := $101;
    DS := DSeg;
    DX := Ofs(SpoolRec);
    Intr($2F,Regs);

    { Isolate the status fo the spool operation }

    SpooledOK := Not ((Flags and 1) = 1);

    If SpooledOk then
      WriteLn('Your file has been placed in the queue.')
    else
      WriteLn('Could not spool your file, error code is ',AL)
    end

End.