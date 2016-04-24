(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0073.PAS
  Description: Seek and FilePos for file of type Text
  Author: AITOR GONZALEX
  Date: 02-21-96  21:04
*)


{Aitor Gonzalez was kind enough to post a chunk of code which included the following
fragment which I reworked.  Someone out there might just be looking of the Text
equivalents of Seek and FilePos; here they are
}
program TestSeekAndFilePos(input,output);
uses
   DOS;

   procedure TextFileSeek(
  var F                        : Text;
      L                        : LongInt
      );
   { Seek byte L in text file F:
   The following code is from    Arne de Bruijn,       1994;
   with modifications by         Aitor Gomez Gonzalez, Feb 19, 1996;
   and reformatting by           F. Li,                Feb 20, 1996.
   } begin
      FileRec((@F)^).Mode:=fmInOut;         { Set to binary mode
                                              The (@F)^ part is to let TP 'forget' the type of the structure, so
                                              you can type-caste it to everything (note that with and without (@X)^
                                              can give a different value, longint(bytevar) gives the same value as
                                              bytevar, while longint((@bytevar)^) gives the same as longint
                                              absolute Bytevar (i.e. all 4 bytes in a longint are readed from
                                              memory instead of 3 filled with zeros)) }
      FileRec((@F)^).RecSize:=1;            { Set record size to 1 (byte size record)
                                              L:=(FilePos(File((@F)^))-TextRec(F).BufEnd)+TextRec(F).BufPos;
                                              Get the fileposition, subtract the already read buffer, and add the
                                              position in that buffer }
      TextRec(F).Mode:=fmInput;             { Set back to text mode }
      TextRec(F).BufSize:=SizeOf(TextBuf);  { BufSize overwritten by RecSize }
                                            { Doesn't work with SetTextBuf! }
      FileRec((@F)^).Mode:=fmInOut;         { Set to binary mode }
      FileRec((@F)^).RecSize:=1;            { Set record size to 1 (a byte)}
      Seek(File((@F)^),L);                  { Do the seek }
      TextRec(F).Mode:=fmInput;             { Set back to text mode }
      TextRec(F).BufSize:=SizeOf(TextBuf);  { Doesn't work with SetTextBuf! }
      TextRec(F).BufPos:=0;                 { Reset buffer counters }
      TextRec(F).BufEnd:=0;
       end { TextFileSeek };

   function TextFilePos(
  var F                        : Text
       )                       : LongInt;
   var
      P                        : longint;
   { Pretend that F is not a text file and return FilePos(F):
   The above code was "b..." by  F. Li,                Feb 20, 1996
   to create the following code:
   N.B. The modifier denies any knowledge of how the code works! -
        hence ...code was "b..." (butchered? buggered?...)
   } begin
      FileRec((@F)^).Mode:=fmInOut;         { Set to binary mode
                                              The (@F)^ part is to let TP 'forget' the type of the structure, so
                                              you can type-caste it to everything (note that with and without (@X)^
                                              can give a different value, longint(bytevar) gives the same value as
                                              bytevar, while longint((@bytevar)^) gives the same as longint
                                              absolute Bytevar (i.e. all 4 bytes in a longint are readed from
                                              memory instead of 3 filled with zeros)) }
      FileRec((@F)^).RecSize:=1;            { Set record size to 1 (byte size record)
                                              L:=(FilePos(File((@F)^))-TextRec(F).BufEnd)+TextRec(F).BufPos;
                                              Get the fileposition, subtract the already read buffer, and add the
                                              position in that buffer }
      TextRec(F).Mode:=fmInput;             { Set back to text mode }
      TextRec(F).BufSize:=SizeOf(TextBuf);  { BufSize overwritten by RecSize }
                                            { Doesn't work with SetTextBuf! }
      FileRec((@F)^).Mode:=fmInOut;         { Set to binary mode }
      FileRec((@F)^).RecSize:=1;            { Set record size to 1 (a byte)}
      P:=FilePos(File((@F)^));
      TextFilePos:=P-TextRec(F).BufEnd+TextRec(F).BufPos;
                                            { Do the FilePos }
      TextRec(F).Mode:=fmInput;             { Set back to text mode }
      TextRec(F).BufSize:=SizeOf(TextBuf);  { Doesn't work with SetTextBuf! }
       end { TextFilePos };

var
   i                           : integer;
   Line                        : string;
   LineNumber                  : integer;
   MyFile                      : text;
   Position                    : array [1..99] of longint;
{ Test Seek and Pos for TextFile } begin
   Assign(MyFile,'SeekPos.Pas');
   Reset(MyFile);
   LineNumber:=0;
   while not EOF(MyFile) do begin
      Inc(LineNumber);
      Position[LineNumber]:=TextFilePos(MyFile);
      ReadLn(MyFile,Line);
       end;
   i:=1;
   while i <= LineNumber do begin
      TextFileSeek(MyFile,Position[i]);
      ReadLn(MyFile,Line);
      WriteLn(Output,Line);
      Inc(i); Inc(i);
       end;
   Close(MyFile);
    end { TestSeekAndFilePos }.


