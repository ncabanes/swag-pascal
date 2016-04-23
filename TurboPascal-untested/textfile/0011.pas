{
│I would like to be able to read a standard ASCII Text File from disk into
│a section of memory so I would be able to call up the screen later.  How
│would I accomplish this?  I'm assuming that once I have it in memory I could
│copy the information into $B800 and so have it display on the screen.  This
│would actually be useful For an instruction screen so I could scroll one
│screenful at a time With PgDn.

Sample code For viewing Text File. Feel free to experiment With it. If you
have any questions, just ask.
}

Uses
  Crt, Dos;


Procedure ViewTextFile(fname: String);
{ fname - name of Text File to display }

Const
  Bad   = #255;
  Null  = #0;
  ESC   = #27;
  Home  = #71;
  PgUp  = #73;
  PgDn  = #81;
  Done     : Boolean = False;
  PageIndex: Word    = 1;         { index to our screen/page        }

Var
  InFile : File;                  { unTyped File                    }
  PFile  : Pointer;               { Pointer to our heap area        }
  Size,                           { size of File                    }
  Result,                         { return code For BlockRead       }
  FileSeg,                        { Segment address of File in heap }
  off: Word;                      { use as offset to our heap       }
  Pages: Array[1..2000] of Word;  { define screen as Array of Words }
  ch: Char;                       { For reading commands            }

begin
  Assign(InFile, fname);
  {$I-} Reset(InFile, 1); {$I+}
  if IOResult <> 0 then
    begin
      Writeln('File not found: ',fname);
      Halt(1)         { stop Program & return to Dos }
    end;
  Size := FileSize(InFile);        { get size of File               }
  GetMem(PFile, Size);             { allocate space in heap         }
  FileSeg := Seg(PFile^);          { get Segment address of File in heap }

  BlockRead(InFile, PFile^, Size, Result); { use BlockRead For fast File I/O }
  FillChar(Pages, SizeOf(Pages), 0);       { fill page With zeroes--ie:blank }
  Repeat
    ClrScr;
    off := Pages[PageIndex];
    Repeat                                 { display screenfull at a time }
      Write(Chr(Mem[FileSeg:off]));
      inc(off);
    Until (off = Size) or (WhereY = 25);
    Repeat                                 { inner event loop }
      ch := ReadKey;
      if ch = ESC then
        Done := True         { user escaped }
      else
        if ch = Null then
          Case ReadKey of
            Home:  PageIndex := 1;       { go to first page }
            PgUp:  if PageIndex > 1 then
                     Dec(PageIndex);
            PgDn:  if off < Size then
                     begin
                       Inc(PageIndex);
                       Pages[PageIndex] := off;
                     end
            else
              ch := Bad
          end;
    Until (ch = Null) or Done;
  Until Done;
  Close(InFile)        { don't forget to close the File }
end; { DisplayTextFile }


begin
  if ParamCount > 0 then
    ViewTextFile(ParamStr(1))
  else
    Writeln('Error: Missing File parameter.')
end. { program }

