(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0014.PAS
  Description: Display THEDRAW BIN File
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
Here are the relevant pieces from a Program I wrote to convert TheDraw
.Bin Files to .ANS Files.  Why?  TheDraw's .ANSI Files are incredibly
wasteful!  The display speed of the menus of the BBS I wrote this For
now redraw at 300% the speed they used to!

if you (or anyone) wants the full Program, give me a yell.
}

Program Bin2Ansi;

Uses
  Crt,Dos;

Var
  Filenum   :Byte; {Points to the command line parameter now being looked at}
  fName     :String;  {File from cmd line - possibly With wildcards}
  Filesdone :Word;

  Procedure ParseFile (Var cmdFName:String);

  Var
    Details:SearchRec;
    fDir, fName, fExt:String;
    Dummy:String;
    {The parts of the name of the source .Bin File}

  begin
    {Default extension}
    if pos ('.',cmdFName) = 0 then cmdFName := cmdFName + '.Bin';
    FSplit(cmdFName, fDir, dummy, dummy); {Get the directory name}
    {Check to see if we have any matches For this Filespec}
    FindFirst (cmdFName,AnyFile,Details);
    if DosError <> 0 then begin
      Writeln ('Filespec: ',cmdfname);
      error (7,warning);
    end else begin
      While DosError = 0 do begin
        FSplit(fdir+details.name, dummy, fName, fExt); {Get the directory name}
        assign (BinFile,fdir+details.name);
        Write ('Opening File: ',details.name,#13);
        {$i-}
        reset (BinFile);
        {$i+}
        end else begin
          Writeln (details.name,' --> ',fname,'.ANS  ');
          process (BinFile,fdir+fname+'.ANS');
          close (BinFile);
        end;
        FindNext (Details);
      end;
    end;
  end;

begin
  directvideo := False;
  Filesdone := 0;
  header;
  if paramcount < 1 then error (1,fatal);
  FileNum := 0;
  Repeat
    fname := paramstr (Filenum + 1);
    ParseFile (fname);
    inc (FileNum);
  Until paramstr (FileNum + 1) = '';
  Writeln; Write (' ■ Done, With ',Filesdone,' File');
  if Filesdone <> 1 then Write ('s');
  Writeln (' processed.');
end.

