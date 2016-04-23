Unit Fcopy;

Interface

{copy file: return TRUE is successful or FALSE if something
 went wrong}
 Function COPYFILE(Source, Target : String) : Boolean;


Implementation
uses
wintypes, winprocs, windos;


{--- buffer for file copy -------}
Type
CopyBuf = Array[1..32768] of Byte;  {32kb buffer!}

Var
Buffers : CopyBuf;                 {pointer for buffer}


{------------------ Print an Error Message -------------}
Procedure ErrorMessage(Title,Msg : PChar);
Begin
  MessageBox(GetFocus,Msg,Title,mb_IconExclamation+mb_OK);
End;


{--------- copy from Source to Target ---------}
Function COPYFILE(Source, Target : String) : Boolean;

Var
SourceFile,TargetFile   : File;
BytesRead,
BytesWritten  : Integer;

TotalRead,      {bytes from source file}
TotalWritten,   {bytes from target file}

OldTime       : LongInt;


Begin {CopyFile}

   CopyFile  := False;

   If Source = Target then
   begin
     ErrorMessage(' ERROR ',' Same Source and Target files! ');
     exit;
   end;


   Assign(SourceFile,Source);

   {$I-}
   Reset(SourceFile,1);
   {$I+}

   if IORESULT <> 0 then
   begin
     ErrorMessage(' ERROR ',' I am unable to open the source file');
     exit;
   end;


    Assign(TargetFile,Target);

    {$I-}
      Rewrite(TargetFile,1);
    {I+}

     if ioresult <> 0 then
      begin
        ErrorMessage(' ERROR ',' I am unable to create the target file ');
        Close(SourceFile);
        EXIT;
      end;


      GetFTime(SourceFile,OldTime);  {* get the old time & date stamp *}

      New(Buffers);
      TotalRead    := 0;
      TotalWritten := 0;


     {$I-}
      While not Eof(SourceFile) do
      begin
         BlockRead(SourceFile,  Buffers, Sizeof(Buffers), BytesRead);
         BlockWrite(TargetFile, Buffers, BytesRead, BytesWritten);

         Inc(TotalRead,    BytesRead);    {monitor the total size}
         Inc(TotalWritten, BytesWritten); {of bytes being copied}
      end;
     {$I+}

     if ioresult <> 0 then
      begin
        ErrorMessage(' ERROR ',' Error encountered during file copy ');
        Dispose(Buffers);

        {$I-}
        Close(SourceFile);
        Close(TargetFile);
        {$I+} If IoResult <> 0 Then {leave anyway};

        EXIT;
      end;


      {$I-}
        Close(SourceFile);
        SetFTime(TargetFile, OldTime);  {* reset the date and time *}
        Close(TargetFile);
      {$I+} If IoResult <> 0 Then {};


     Dispose(Buffers);

     If TotalRead <> TotalWritten
     Then {mismtach in bytes read and copied}
     begin
       ErrorMessage('ERROR',
       ' Discrepancies exist in the source and target file sizes!');

       Exit;
     end;


     {if we get here, all went well}

     CopyFile := True;

End; {copyfile}

End.

