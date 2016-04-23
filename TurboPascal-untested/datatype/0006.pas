{
>Is is Possible to have a File of Two different Record Types?
>How would one do this? I have seen it done..

First, don't Declare the Type of the File, just use a Type or File.

Declare Pointer Variables For each Type that the Record can be.   if you want
the Record to hold a Value that says what the Record Type is, then device an
ID scheme, and make sure the ID Variables are physically located at the same
Position in both Records.


Read that data into a buffer Record With BlockRead.  Assign the Typed
Pointers to that buffer, and process away....
}

Type
  onerec = Record  { Record size is 98 Bytes }
    id : Byte;   { We will set ID = 1 For onerec }
    Username : String[80];
    Phone : String[15];
  end;
  anotherrec = Record  { Length is 163 Bytes }
    id : Byte; {We will set ID = 2 For anotherrec }
    ADDRESS1 : String[80];
    ADDRESS2 : String[80];
  end;

Var
  ONE : ^ONEREC;
  AnotHER : ^AnotHERREC;
  Buffer : Array[1..163] of Char;   { The size of the largest Record }
  F : File;
  NumRead : Word;
  ID : Byte Absolute Buffer;   { ID points to the first Char begin}
begin
  Assign(F,'FileNAME');
  Reset(F,SizeOf(Buffer));
  One := @BUFFER;
  AnotHER := @BUFFER;
  BlockRead(F,BUFFER,SIZEof(BUFFER),NUMRead);
  While NumRead > 0 Do
  begin
    Case ID of
      1 :
        begin
          WriteLn('Record is of Type ONE');
          WriteLn('USERNAME: ',ONE^.USERNAME);
          WriteLn('Phone: ',ONE^.Phone);
        end;
      2 :
        begin
          WriteLn('Record is of Type AnotHER');
          WriteLn('Address Line 1 = ',AnotHER^.ADDRESS1);
          WriteLn('Address Line 2 = ',AnotHER^.ADDRESS2);
        end;
      else
        WriteLn('Unidentified Record Type');
    end; { of Case }
    BlockRead(F,BUFFER,SIZEof(BUFFER),NUMRead);
  end;
  Close(F);
end.

