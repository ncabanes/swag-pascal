
{This way uses a File stream.}
Procedure FileCopy( Const sourcefilename, targetfilename: String );
Var
  S, T: TFileStream;
Begin
  S := TFileStream.Create( sourcefilename, fmOpenRead );
  try
    T := TFileStream.Create( targetfilename,
                             fmOpenWrite or fmCreate );
    try
      T.CopyFrom(S, S.Size ) ;
    finally
      T.Free;
    end;
  finally
    S.Free;
  end;
End;


{This way uses memory blocks for read/write.}
procedure FileCopy(const FromFile, ToFile: string);
 var
  FromF, ToF: file;
  NumRead, NumWritten: Word;
  Buf: array[1..2048] of Char;
begin
  AssignFile(FromF, FromFile);
  Reset(FromF, 1);		{ Record size = 1 }
  AssignFile(ToF, ToFile);	{ Open output file }
  Rewrite(ToF, 1);		{ Record size = 1 }
  repeat
    BlockRead(FromF, Buf, SizeOf(Buf), NumRead);
    BlockWrite(ToF, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);

  CloseFile(FromF);
  CloseFile(ToF);
end;

{This one uses LZCopy, which USES LZExpand.}
procedure CopyFile(FromFileName, ToFileName: string);
var
  FromFile, ToFile: File;
begin
  AssignFile(FromFile, FromFileName); { Assign FromFile to FromFileName }
  AssignFile(ToFile, ToFileName);     { Assign ToFile to ToFileName }
  Reset(FromFile);                    { Open file for input }
  try
    Rewrite(ToFile);                  { Create file for output }
    try

      { copy the file an if a negative value is returned }
      { raise an exception }
      if LZCopy(TFileRec(FromFile).Handle, TFileRec(ToFile).Handle) < 0
        then
        raise EInOutError.Create('Error using LZCopy')
    finally
      CloseFile(ToFile);  { Close ToFile }
    end;
  finally
    CloseFile(FromFile);  { Close FromFile }
  end;
end;




