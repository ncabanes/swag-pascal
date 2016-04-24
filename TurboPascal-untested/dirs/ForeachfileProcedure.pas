(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0001.PAS
  Description: ForEachFile Procedure
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

{
 Can any one tell me a way to make pascal (TP 6.0) search a
 complete drive, including all subdirectories, even ones
 that are not in the path, looking For a specific File
 extension?  I.E., having the Program search For *.DOC and
 saving that to a Text File?

 Here's part of a package I'm putting together.  You'd use it like this:

}

{File Test.Pas}

Uses
  Dos, Foreach;

Procedure PrintAllDocs;

  Procedure PrintFile(Var Dir: DirStr; Var S : SearchRec); Far;
  begin
    Writeln('Found File ',Dir,S.Name);
  end;

begin
  ForEachFile('c:\*.doc',  { Give the mask where you want to start looking }
              0, 0,        { Specify File attributes here; you'll just get
                             normal Files With 0 }
              True,        { Search recursively }
              @PrintFile); { Routine to call For each File }
end;

begin
  PrintAllDocs;
end.


{Unit ForEach}

Unit ForEach;

{ Unit With a few different "foreach" Functions. }
{ This extract contains only ForEachFile. }

Interface

Uses
  Dos;

Type
  FileStr = String[12];
  TFileAction = Procedure(Var Dir : DirStr;
                          Var S : SearchRec; ConText : Word);

Procedure ForEachFile(Mask : PathStr; { File wildcard mask, including path }
                      Attr : Byte; { File attributes }
                      Match : Byte; { File attributes which
                                             must match attr exactly }
                      Subdirs : Boolean; { Whether to search recursively }
                      Action : Pointer);
{ Calls the Far local Procedure Action^ For each File found.
  Action^ should be a local Procedure With declaration
    Procedure Action(Var Path : String; Var S : SearchRec); Far;
  or, if not a local Procedure,
    Procedure Action(Var Path : String; Var S : SearchRec; Dummy : Word); Far;
  Each time Action is called S will be filled in For a File matching
  the search criterion.
}

Implementation

Function CallerFrame : Word;
{ Returns the BP value of the caller's stack frame; used For passing
  local Procedures and Functions around. Taken from Borland's Outline
  Unit. }
  Inline(
    $8B/$46/$00                   { MOV   AX,[BP] }
    );


  { ******** File routines ********* }

Procedure ForEachFile(Mask    : PathStr; { File wildcard mask }
                      Attr    : Byte;    { File attributes }
                      Match   : Byte;    { Attributes which must match }
                      Subdirs : Boolean; { Whether to search recursively }
                      Action  : Pointer);{ Action; should point to
                                           a TFileAction local Far Procedure }
Var
  CurrentDir : DirStr;
  Doit       : TFileAction Absolute Action;
  Frame      : Word;

  Procedure DoDir;
  { Tests all Files in current directory.  Assumes currentdir has trailing
    backslash }
  Var
    S : SearchRec;
  begin
    FindFirst(CurrentDir + Mask, Attr, S);
    While DosError = 0 do
    begin
      if (S.Attr and Match) = (Attr and Match) then
        Doit(CurrentDir, S, Frame);
      FindNext(S);
    end;
  end;

  Function RealDir(Name : FileStr) : Boolean;
  begin
    RealDir := (Name <> '.') and (Name <> '..');
  end;

  Procedure AddBackslash;
  begin
    CurrentDir := CurrentDir + '\';
  end;

  Procedure DoAllDirs;
  Var
    S         : SearchRec;
    OldLength : Byte;

    Procedure AddSuffix(Suffix : FileStr); { Separate proc to save stack space }
    begin
      CurrentDir := Copy(CurrentDir, 1, OldLength) + Suffix;
    end;

  begin
    OldLength := Length(CurrentDir);
    DoDir;
    AddSuffix('*.*');
    FindFirst(CurrentDir, Directory, S);
    While DosError = 0 do
    begin
      if S.Attr = Directory then
      begin
        if RealDir(S.Name) then
        begin
          AddSuffix(S.Name);
          AddBackslash;
          DoAllDirs;            { do directory recursively }
        end;
      end;
      FindNext(S);
    end;
  end;

Var
  Name : NameStr;
  Ext  : ExtStr;

begin                           { ForEachFile }
  FSplit(Mask, CurrentDir, Name, Ext);
  Mask := Name+Ext;
  Frame := CallerFrame;
  if CurrentDir[Length(CurrentDir)] <> '\' then
    AddBackslash;
  if Subdirs then
    DoAllDirs
  else
    DoDir;
end;

end.

