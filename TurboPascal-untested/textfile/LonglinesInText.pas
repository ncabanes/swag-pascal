(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0005.PAS
  Description: LONGLINES in Text
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:58
*)

Program longline;

Var
  LinePart: String;
  InFile, OutFile: Text;
  Index1, Index2: Word;
  Result: Byte;

begin { First create a test File With lines longer than     }
      { 255 caracters, this routine will generate lines in  }
      { exess of 600 caracters. The last "EOLN" at the end  }
      { is a visual aid to check that the Complete line has }
      { been copied to the output File.                     }

  Assign (OutFile, 'InFile.txt');
  ReWrite (OutFile);
  Randomize;
  For Index1 := 1 to 100 do begin
    For Index2 := 1 to (Random (5) + 1) do
      Write (OutFile, 'These are some very long Text Strings that'
        + ' are written to the File InFile.txt in order to test' +
        ' the capability of reading verylong Text lines. Lines' +
        ' that even exceed Turbo Pascal''s limit of 255' +
        ' caracters per String');
    Writeln (OutFile, 'EOLN');
  end;
  Close (OutFile);

      { Now re-open it and copy InFile.txt to OutFile.txt   }
  Assign (InFile, 'InFile.txt');
  Assign (OutFile, 'OutFile.txt');
  Reset (InFile);
  ReWrite (OutFile);

  While not Eof (InFile) do begin
    While not Eoln (InFile) do begin

      { While we are not at enf-of-line, read 255           }
      { caracters notice we use READ instead of READLN      }
      { because the latter would skip to the next line even }
      { if data was still left on this line.}

      Read (InFile, LinePart);
      Result := Ioresult;
      Writeln ('Result was ', Result);
      Write (OutFile, LinePart);
    end;

      { We have reached end-of-Line so do a readln to skip  }
      { to the start of the next line.}

    Readln (InFile);

      { Also Writeln to output File so it to, skips to the  }
      { next line.                                          }

    Writeln (OutFile);

  end;

      { Close both Files                                    }

  Close (OutFile);
  Close (InFile);
end.


