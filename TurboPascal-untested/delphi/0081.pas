
The following example shows how to write and read data to
and from a file.  It is intended merely as a starting
point for those that are struggling to get started with
file related IO.  Please read the documentation on each
object for more information.  Some very minimal exception
handling is thrown in and by no means constitutes a
robust solution.

Best regards,
Michael Vincze
mav@asd470.dseg.ti.com

----------

In order to setup the program, place a TMemo component on
a form with a Write captioned and a Read captioned button.
Run the program, place some lines in the "memo", then
press on Write.  Clear the "memo", and press on Read.

  procedure TForm1.BtnWriteClick(Sender: TObject);
  { by:  Michael Vincze
  }
  var
    FileStream: TFileStream;
    Writer    : TWriter;
    I         : Integer;
  begin
  FileStream := TFileStream.Create ('c:\delphi\projects\delta40\fileio\stream.txt',
    fmCreate or fmOpenWrite or fmShareDenyNone);
  Writer := TWriter.Create (FileStream, $ff);
  Writer.WriteListBegin;
  for I := 0 to Memo1.Lines.Count - 1 do Writer.WriteString (Memo1.Lines[I]);
  Writer.WriteListEnd;
  Writer.Destroy;
  FileStream.Destroy;
  end;

  procedure TForm1.BtnReadClick(Sender: TObject);
  { by:  Michael Vincze
  }
  var
    FileStream: TFileStream;
    Reader    : TReader;
  begin
  { try opening a non existent file
  }
  try
    FileStream := TFileStream.Create ('c:\delphi\projects\delta40\fileio\bogus.txt',
      fmOpenRead);
  except
    ; { no need to Destroy since the Create failed  }
    end;

  FileStream := TFileStream.Create ('c:\delphi\projects\delta40\fileio\stream.txt',
    fmOpenRead);
  Reader := TReader.Create (FileStream, $ff);
  Reader.ReadListBegin;
  Memo1.Lines.Clear;
  while not Reader.EndOfList do Memo1.Lines.Add (Reader.ReadString);
  Reader.ReadListEnd;
  Reader.Destroy;
  FileStream.Destroy;
  end;



