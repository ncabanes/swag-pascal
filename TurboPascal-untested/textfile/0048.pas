Program StrLenConv;
Uses
    Dos, Crt;
Type
    String_128  = String[128];
    String_127  = String[127];
Var
   X,Y,StrPos  : Byte;
   File128     : File of String_128;
   File127     : File of String_127;
   Str128      : String_128;
   Str127      : String_127;
   TempFile    : Text;
Function  FileExist(FileName: String): Boolean;
          Var
             Tmpfile     : Text;
             Attrib      : Word;
          Begin {Function FileExist}
                If FileName = '' then
                   Begin {If FileName = ''}
                         FileExist := False; Exit;
                   End;  {If FileName = ''}
                Assign(Tmpfile,FileName);
                GetFAttr(Tmpfile,Attrib);
                FileExist := (DosError = 0);
          End;  {Function FileExist}
Begin {Main}
      TextMode(c80);
      ClrScr;
      Writeln('Source file with 128 character strings:');
      Write(' ■ '); Readln(Str127);
      If not(FileExist(Str127)) then
         Begin {If not(FileExist(Str127))}
               Writeln;
               Writeln(' Error: ' + Str127 + ' does not exist.');
               Halt(0);
         End;  {If not(FileExist(Str127))}
      Assign(File128,Str127);
      Reset(File128);
      Writeln;
      Writeln('Destination file for 127 character strings:');
      Write(' ■ '); Readln(Str127);
      If FileExist(Str127) then
         Begin {If FileExist(Str127)}
               Writeln;
               Writeln(' Error: ' + Str127 + ' already exists.');
               Halt(0);
         End;  {If FileExist(Str127)}
      Assign(File127,Str127);
      ReWrite(File127);
      Assign(TempFile,'128TO127.TMP');
      ReWrite(TempFile);
      StrPos := 1;
      Writeln;
      Writeln('Reading Source File...');
      Repeat
            Read(File128,Str128);
            For X := 1 to 128 do Writeln(TempFile,Str128[X]);
      Until EOF(File128);
      Reset(TempFile);
      Close(File128);
      Writeln;
      Writeln('Writing Destination File...');
      Repeat
            For X := 1 to 127 do
                Begin {For X := 1 to 127}
                      Readln(TempFile,Str128);
                      Str127[X] := Str128[1];
                End;  {For X := 1 to 127}
            Write(File127,Str127);
      Until EOF(TempFile);
      Close(File127);
      Erase(TempFile);
      Close(TempFile);
End.  {Main}

Feel free to edit this however you like.  What it does (in a nutshell)
is read a file which has 128 character strings, saves each character to
a text file (one on a line), and then re-reads them into the 127
character strings, writing each one to a file.

I hope this is what you were looking for.

Michael J. Church
MC Squared Computing Technologies
---
 ■ RNet 1.08R:■ NANET ■ After Five' BBS ■ Elkhart, IN ■ (219) 262-1370
 