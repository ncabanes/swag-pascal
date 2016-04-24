(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0055.PAS
  Description: Accessing Large Text Files
  Author: MARK OUELLET
  Date: 05-26-95  23:29
*)

{$A+,B-,D-,E+,F+,G+,I-,L-,N+,O+,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 16384,0,655360}
(*
 The problem is as follows:

  Q. How to randomly access Large text files, such as tagline files,
    in an efficient way.

  A. By using an index file which is just a structured file of which
    each record is a longint giving us the offset of that line.

    The structure can be simple: File of LongInt;
    Or a bit more:
     OneTagLine = record
     offset : longint;   {Offset where tag begins in text file}
     NumOfLines : byte;  {Number of lines in this particular tag}
     end;


    Ex:
     to get Line # 233
      Get Record #233 from the Index file.
      That value is the offset in the text file
      where line 233 begins

 To detect changes in the Text file I reserve the first record, record #0,
 to conatin the size of the text file at the time of creation of the index.

 By checking both the cration date/time of the text file and Record #0
 of the index, the program can then determine wether it needs to recreate
 the index or not.

*)
program TxtRandR; {Random access to text files}
uses dos;

 type
  IndexFile = file of longint;

 var
  Index : IndexFile;
  IndexName : string;
  N : namestr;
  E : extstr;
  D : dirstr;
  Tags  : text;
  Line   : string;
  LineNmbr : word;
  LineOfs : longint;

 function TextFileSize(var F):longint;

  var
   OldRecSize : word;
   OldMode : word;
   Temp : longint;

  begin
   with filerec(F) do begin
    OldMode := mode;
    mode := fminout;
    OldRecSize := recsize;
    recsize := 1;
   end;
   Temp := filesize(file(F));
   with filerec(F) do begin
    mode := OldMode;
    recsize := OldRecSize;
   end;
   TextFileSize := Temp;
  end;

 function TextFilePos(var F):longint;

  var
   OldRecSize : word;
   OldMode : word;
   Temp : longint;

  begin
   with filerec(F) do begin
    OldMode := mode;
    mode := fminout;
    OldRecSize := recsize;
    recsize := 1;
   end;
   Temp := filepos(file(F));
   with filerec(F) do begin
    mode := OldMode;
    recsize := OldRecSize;
   end;
   TextFilePos := Temp - OldRecSize + textrec(F).bufpos;
  end;

 procedure CheckIndex(var T:text; var F: IndexFile);

  var
   Temp : longint;

  begin
   Seek(F, 0);
   if FileSize(F)=0 then
    temp := 0
   else
    Read(F, Temp);
   if Temp <> TextFileSize(T) then begin
    {
     Stored Size is different than that of text file
     so rebuild the index file
    }
    Seek(F,0);
    Temp := TextFileSize(T);
    write(F, Temp);
    while not eof(T) do begin
     Temp := TextFilePos(T);
     write(F, Temp);
     while (not eof(T)) and (not eoln(T)) do
      read(T, Line);
     readln(T);
    end;
    Truncate(F);
   end;
  end;

 procedure SeekTextFile(var T; FPos:longint);

  var
   OldRecSize : word;
   OldMode : word;
   Temp : longint;
   TBuffer : pointer;
   BytesRead : word;

  begin
   with filerec(T) do begin
    OldMode := mode;
    mode := fminout;
    OldRecSize := recsize;
    recsize := 1;
   end;
   Seek(File(T), (FPos div OldRecSize) * OldRecSize);
   TBuffer := textrec(T).bufptr;
   blockread(File(T), TBuffer^, OldRecSize, BytesRead);
   with filerec(T) do begin
    mode := OldMode;
    recsize := OldRecSize;
   end;
   textrec(T).bufpos := FPos mod OldRecSize;
   textrec(T).bufend := BytesRead;
  end;

begin
 assign(Tags, paramstr(1));
 reset(Tags);
 fsplit(paramstr(1), D, N, E);
 IndexName := D + N + '.idx';
 assign(Index, IndexName);
 {$I-}
 reset(Index);
 {$I+}
 if ioresult<>0 then begin
  rewrite(Index);
  LineOfs := 0;
  write(Index, LineOfs);
 end;
 CheckIndex(Tags, Index);
 val(paramstr(2), LineNmbr, LineNmbr);
 Seek(Index, LineNmbr);
 Read(Index, LineOfs);
 SeekTextFile(Tags, LineOfs);
 while (not Eof(Tags)) and (not Eoln(Tags)) do begin
  read(Tags, Line);
  write(Line);
 end;
 readln(Tags);
 writeln;
 close(Tags);
 close(Index);
end.


