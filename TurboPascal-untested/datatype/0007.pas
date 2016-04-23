{
>I have a question about Typed Constants.  By this I mean the
>following declaration:
>
>  Const
>    Example : Byte = 1;
>
>What are the advantages to this?

  ...One of the advantages to using "Typed Constants", is that it
  allows you to initalize Variables at CompILE-TIME (ie: When you
  Compile your source-code into an .EXE), instead of RUN-TIME.
  (ie: When your Program is actually running.)

  ...Another advantage is that "Typed Constants" within Functions/
  Procedures keep their data between calls.
}

Procedure SaveData({input} Var DataBuffer : byar_Data);
Const
  bo_FileOpen : Boolean = False;
begin
  if (bo_FileOpen = False) then
    begin
      assign(fi_Data, st_DataName);
      {$I-}
      reset(fi_Data, 1);
      {$I+}
      Check_For_IO_Error;
      bo_FileOpen := True
    end;
  blockWrite(fi_Data, DataBuffer, sizeof(DataBuffer));
  Check_For_IO_Error
end;

{
  ...The Procedure above would only open the data-File once,
  and all Repeat calls to this Procedure would just Write
  there data to the File. (ie: The Boolean "Typed-Constant"
  bo_FileOpen would only be False the first time this routine
  executed. The next time this routine executed bo_FileOpen
  would be equal to True.)
}

