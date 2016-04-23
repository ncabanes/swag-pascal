
{The following code is off the top of my head so use with caution as it
has NO error checking in it and I have never used to for the purposes
you are describing.  You will need to reverse the code to put the files
back together when they are done.  Try this (Good Luck):

You could use DOS copy with the /b to put it back together

 copy /b file1 file2 file3 output.fil

}

procedure TForm1.BitBtn1Click(Sender: TObject);
var
   inFile,outFile: FILE;
   CopyBuffer : POINTER; { buffer for copying }

   iRecsOK, iRecsWr, iX: Integer;
   sFileName: String;

CONST
  ChunkSize : LONGINT = 1424000; { copy in 1.44 meg chunks }

begin

  GETMEM (CopyBuffer, ChunkSize); { allocate the buffer }

  sFileName := 'd:\demo\winsave';
  Assignfile(inFile,sFileName + '.ZIP');
  Reset(inFile,1);

 iX := 1;
   repeat
      AssignFile(outFile,sFileName + IntToStr(iX) + '.ZIP');

      Rewrite(outFile,1);
      inc(iX);
      BlockRead(InFile, CopyBuffer^, Chunksize, iRecsOK);
      BlockWrite(OutFile, CopyBuffer^, iRecsOK, iRecsWr);
      CloseFile(outFile);
   until (iRecsOK < Chunksize);

CloseFile(inFile);
FREEMEM (CopyBuffer, ChunkSize); { free the buffer }
END;

