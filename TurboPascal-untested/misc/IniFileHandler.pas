(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0158.PAS
  Description: INI File Handler
  Author: KIM GREVE
  Date: 09-04-95  10:51
*)

(*
   unit INIF

   Unit that handles .INI files in almost the same way as the functions
   with the same name used under windows.
   ---------------------------------------------------------------------

   GetProfileString(AppName, Section, EntryName, EntryValue, Default);

   The GetProfileString function retrieves a character string from a
   specified [section] and a specified EntryName in the. INI file
   specified in AppName.

   parameter  | description
   -----------+---------------------------------------------------------
   AppName    | The name of the .INI file.
              | You do not need to type .INI after the path:\filename.
              |
   Section    | The [Section] where you want to search for the EntryName
              | don't put [ ] around the section name.
              |
   EntryName  | String containing the entry whose associated string is
              | to be retrieved. For more see the following Comment
              | section.
              |
   EntryValue | The returned string for the actual EntryName.
              |
   Default    | String that specifies the default value(string) for the
              | given entry if the entry cannot be found in the INI file
   ---------------------------------------------------------------------
   Returns:
   GetProfileString returns the length of retrieved string (EntryValue).

   Comment:
   The function searches the file for an entry that matches the name
   specified by the 'EntryName' parameter under the section heading
   specified by the 'Section' parameter. If the entry is found,
   EntryValue is altered to the string in EntryName. If the entry does
   not exist, the default value specified by the Default parameter is
   used instead. A string entry must have the following form:

   [Section]
   EntryName=EntryValue
     .
     .
   The Section, EntryName and EntryValue is not case-dependent. With
   every compare all the strings is in uppercase.

   ---------------------------------------------------------------------

   WriteProfileString(AppName, Section, EntryName, EntryValue);

   The WriteProfileString function copies a character string into the
   specified [section] and a specified EntryName in the .INI file
   specified in AppName.

   parameter  | description
   -----------+---------------------------------------------------------
   AppName    | The name of the .INI file.
              | You do not need to type .INI after the path:\filename.
   Section    | The [Section] to witch the string will by copied. If the
              | section does not exist, it is created. The name of the
              | section is not case-dependent; the string may be any
              | combination of uppercase and lowercase letters.
              | (don't put [ ] around the section name.)
   EntryName  | String containing the entry whose to be associated with
              | the string. If the entry does not exist in the specified
              | section, it is created.
   EntryValue | The string whose to be associated with EntryName.
   ---------------------------------------------------------------------
   Returns:
   WriteProfileString returns zero if write was successful otherwise -1.

   Comment:
   Sections in the .ini file have the following form:

   [Section]
   EntryName=EntryValue
     .
     .
   The Section, EntryName and EntryValue is not case-dependent. With
   every compare all the strings is converted into uppercase.
   ---------------------------------------------------------------------
   GetProfileInt and WriteProfileInt works in the same way, the only
   difference is that EntryValue must be an integer type instead of a
   string type.
   ---------------------------------------------------------------------
   procedure DisposeINICollection;

     The procedure disposes the collection from memory.

   you can call this procedure if you want to dispose the collection,
   the procedure is called before an .ini file is loaded and in the
   unit's exitprocedure, to make sure that the memory used by the
   collection is released before the program terminates.
   ---------------------------------------------------------------------
   to flush the collection in memory call WriteProfileString, with the
   [Section] AND [EntryName] AND EntryValue set to 'NILL' (NILL is NOT
   a type error) see Flush collection.

   Flush Collection:
   -----------------

     WriteProfileString(AppName, 'NILL', 'NILL', 'NILL');

   if you for don't want the collection to be flushed to disk when the
   program terminates, you must call the DisposeINICollection procedure
   that releases the memory used by the collection and sets INIColl to
   NIL or set INIF_FlushOnExit to FALSE.

   Delete ENTRY:
   -------------

     WriteProfileString(AppName, Section, EntryName, 'NILL');

   Delete SECTION:
   ---------------

     WriteProfileString(AppName, Section, 'NILL', 'NILL');

   ---------------------------------------------------------------------

   Performance:
   To improve performance a copy of the ini file is kept in a collection
   and to flush the collection to a file, you have to call the procedure
   WriteProfileString with 3 NILL parameters.

   ---------------------------------------------------------------------
    (c) 1994 by Kim Greve.
    This is given to the public domain,  so if you want to make changes
    feel free to do it, my only demand/request is that you don't remove
    my name.
    If you have any questions, suggestions or have found any bugs,
    please contact me.
   
    DISCLAIMER:
    This source is given as is, you can not hold me responsibly for any
    errors in the source (if any <g>).
   +-------------------------------+-----------------------------------+
   + Last changed: December, 27-1994                                   +
   +-------------------------------+-----------------------------------+
   + Kim Greve                     + Internet:                         +
   + Krebsens kvt 9F               + 1. kim.greve@dkb.dk               +
   + 2620 Albertslund.             +                                   +
   + Denmark.                      + 2. kimgreve@inet.uni-c.dk         +
   +-------------------------------+-----------------------------------+
*)

(*
Eks.

program INIFTest;
uses INIF;
var
  S: String;
begin
  {
  Get Teststring1 form the file "TEST.INI", in section [Test Section],
  the file "TEST.INI" don't exist, so then default string 'ThisIsATest'
  is returned in S. GetProfileString returns the length of the returned
  string.
  }
  GetProfileString('Test', 'Test Section', 'Number', S, 'ThisIsATest');
  {
  Write TestString1 to the file "TEST.INI", Section "Test Section" and
  store the contens of TestString1 in AString (EntryName).
  }
  WriteProfileString('Test', 'Test Section', 'AString', TestString1);
  {
  Until now is all the writing have been to a collection in memory,
  and to make the .ini file the collection have to be Flushed.
  }
  WriteProfileString('Test', 'NILL', 'NILL', 'NILL');
  { You actualy don't have to do this, the collection is flushed when }
  { you terminate the program - UNLESS you have set INIF_FlushOnExit  }
  { = FALSE, the default is INIF_FlushOnExit = TRUE.                  }
end.
*)

unit INIF;

interface

uses
  Dos;

const
  INIF_FlushOnExit: Boolean = True;{ flush collection when terminating }
  INIF_ReadError: Boolean = False;      { true if an readerror acurred }
  INIF_WriteError: Boolean = False;    { true if an writeerror acurred }


function GetProfileString(AppName: PathStr; Section, EntryName: String;
                          var EntryValue: String;
                          Default: String): Integer;
function WriteProfileString(AppName: PathStr; Section,
                            EntryName, EntryValue: String): Integer;
function GetProfileInt(AppName: PathStr; Section, EntryName: String;
                       var EntryValue: Integer;
                       Default: Integer): Integer;
function WriteProfileInt(AppName: PathStr; Section, EntryName: String;
                         EntryValue: Integer): Integer;


procedure DisposeINICollection;

implementation

uses Objects;

const
  CommentChar: Char = ';';          { character leading a comment line }
                                    { used i SplitEntry                }

var
  INIFile: PathStr;                                 { default filename }
  BakINIFile: PathStr;                       { default backup filename }
  TempINIFile: PathStr;                        { default temp filename }
  OrgINIExitProc: Pointer;
  INIColl: PStringCollection;         { copy of the INI file in memory }
  SectionIndexStart: Integer;         { start of section in collection }
  SectionIndexend: Integer;             { end of section in collection }

{ Convert a string to uppercase, handles danish chars to }
function UpcaseStr(var AString): String;
var
  I: Integer;
  S: String;
begin
  S := String(AString);
  for I := 1 to Length(S) do
  begin
    S[I] := Upcase(S[I]);
    if  S[I] = 'æ' then S[I] := 'Æ'
    else if  S[I] = '¢' then S[I] := '¥'
    else if  S[I] = 'å' then S[I] := 'Å';
  end;
 UpcaseStr := S;
end;

{ returns true if file is exist }
function FileExist(FName: PathStr): Boolean;
var
  SR: SearchRec;
begin
  FindFirst(FName, Archive, SR);
  FileExist := True = (DosError = 0);
end;

{ read a line from the file }
function ReadLine(var F: Text): String;
var
  Ch: Char;
  Line: String;
begin
  Line := '';
  Ch := #13;
  While (Ch <> #10) and not Eof(F) do
  begin
    if Ch <> #13 then Line := Line + Ch;
    Read(F, Ch);
  end;
  { add Ch to Line if last entry not folowed by #13/#10 }
  if (Eof(F)) and ((Ch <> #10) and (Ch <> #13)) then Line := Line + Ch;
  ReadLine := Line;
end;

function ReadINIFile: Boolean;
var
  F: Text;
  Line: String;
begin
  ReadINIFile := True;
  DisposeINICollection;  { make sure to release memory before new read }
  INIColl := New(PStringCollection, Init(1, 1));
  if INIColl = nil then
  begin
    ReadINIFile := False;
    Exit;
  end;
  INIColl^.Duplicates := True;      { duplicates allowed in collection }
  if not FileExist(INIFile) then Exit;
  {$I-}
  Assign(F, INIFile);
  Reset(F);
  INIF_ReadError := True = (IOResult <> 0);          { check for error }
  if not INIF_ReadError then
  begin
    While (not Eof(F)) and not INIF_ReadError do
    begin
      Line := ReadLine(F);
      if (Line <> '') then
        INIColl^.AtInsert(INIColl^.Count, NewStr(Line));
    end;
  end;
  {$I+}
  ReadINIFile := INIF_ReadError;
end;

function SaveINIFile: Boolean;
var
  I: Integer;
  OrgF, BakF, TempF: Text;
  IOError: Boolean;
  Line: String;
begin
  {$I-}
  Assign(OrgF, INIFile);
  Assign(BakF, BakINIFile);
  Assign(TempF, TempINIFile);
  ReWrite(TempF);                                   { create .TMP file }
  for I := 0 to INIColl^.Count-1 do
  begin
    Line := PString(INIColl^.At(I))^;
    { if next line is a new section then make a linefeed }
    if (Line[1] = '[') and (I > 0) then WriteLn(TempF);
    WriteLn(TempF, Line);
    INIF_WriteError := True = (IOResult <> 0);
  end;
  Close(TempF);                                           { close file }
  IOError := True = (IOResult <> 0);                 { check for error }
  { if a .bak file exist, erase it }
  if FileExist(BakINIFile) and not IOError then Erase(BakF);
  IOError := True = (IOResult <> 0);                 { check for error }
  { if a .ini file exist, rename it to .bak }
  if FileExist(INIFile) and not IOError then
  begin
    Rename(OrgF, BakINIFile);
    IOError := True = (IOResult <> 0);               { check for error }
  end;
  { rename .tmp file to .ini }
  if FileExist(TempINIFile) and not IOError then
  begin
    Rename(TempF, INIFile);
    IOError := True = (IOResult <> 0);               { check for error }
  end;
  {$I+}
  if INIF_WriteError or IOError then SaveINIFile := False else
    SaveINIFile := True;
end;

{ returns True if section exist. The 2 global var's: SectionIndexStart }
{ & SectionIndexEnd is effected by this function                       }
function FindSection(Section: String): Boolean;
var
  Ch: Char;
  S, Line: String;
  StartFound, EndFound: Boolean;
begin
  FindSection := False;
  StartFound := False;
  EndFound := False;
  S := '['+Section;
  Section := S+']';
  Section := UpcaseStr(Section);

  { find start of Section }
  SectionIndexStart := 0;
  While (not StartFound) and (INIColl^.Count > 0) and
    (SectionIndexStart < INIColl^.Count) do
  begin
    Line := PString(INIColl^.At(SectionIndexStart))^;
    if Line[1] = '[' then
    begin
      Line := UpcaseStr(Line);
      Line[0] := Chr(Pos(']', Line));
      if Line = Section then StartFound := True;
    end;
    if (not StartFound) and (SectionIndexStart < INIColl^.Count) then
      Inc(SectionIndexStart);
  end;

  { find end of Section if start of section is found }
  SectionIndexEnd := SectionIndexStart;
  if StartFound then
  begin
    While (not EndFound) and (SectionIndexEnd < INIColl^.Count-1) do
    begin
      if SectionIndexEnd < INIColl^.Count-1 then Inc(SectionIndexEnd);
      Line := PString(INIColl^.At(SectionIndexEnd))^;
      if Line[1] = '[' then EndFound := True;
    end;
  end;
  if StartFound then FindSection := True;
end;

{ returns EntryName. Value is returned in EntryValue }
function SplitEntry(EntryName: String; var EntryValue: String): String;
var
  Entry: String;
begin
  if EntryName[1] <> CommentChar then
  begin
    Entry := Copy(EntryName, 1, Pos('=', EntryName)-1);
    EntryValue := Copy(EntryName,
      Pos('=', EntryName)+1, Length(EntryName));
  end
  else Entry := CommentChar;
  SplitEntry := Entry;
end;

{ returns Index of Entry if it exist, -1 if not, -2 if section don't   }
{ exist.                                                               }
function FindEntry(Section, Entry: String;
                   var EntryValue: String): Integer;
var
  Ch: Char;
  S, Line, TempLine, TempEntryValue: String;
  SectionIndex: Integer;
  EntryFound: Boolean;
begin
  FindEntry := -1;                    { exspect that entry don't exist }
  if FindSection(Section) then
  begin
    EntryFound := False;
    SectionIndex := SectionIndexStart;
    Entry := UpcaseStr(Entry);
    While (not EntryFound) and (SectionIndex <= SectionIndexEnd) do
    begin
      Line := PString(INIColl^.At(SectionIndex))^;
      TempLine := Line;              { work on a copy of original line }
      TempLine := UpcaseStr(TempLine);
      if SplitEntry(TempLine, TempEntryValue) = Entry then
      begin
        { return EntryValue not converted to UpCase }
        SplitEntry(Line, EntryValue);
        EntryFound := True;
      end;
      if not EntryFound then Inc(SectionIndex);
    end;
    if EntryFound then FindEntry := SectionIndex;
  end
  else FindEntry := -2;   { return -2 to tell that section don't exist }
end;

procedure SetINIFileName(FName: PathStr);
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
begin
  FName := UpcaseStr(FName);
  FSplit(FName, D, N, E);
  INIFile := N+'.INI';
  BakINIFile := N+'.BAK';
  TempINIFile := N+'.TMP';
end;


{- functions / procedures in interface section ------------------------}

function GetProfileString(AppName: PathStr; Section, EntryName: String;
                          var EntryValue: String;
                          Default: String): Integer;
var
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  ON, NN: NameStr;
begin
  FSplit(INIFile, D, N, E);
  ON := N;
  FSplit(AppName, D, N, E);
  NN := N;
  ON := UpcaseStr(ON);
  NN := UpcaseStr(NN);
  { make sure that INIColl = nil, if OldName <> NewName }
  { (= another .ini file)                            }
  if ON <> NN then DisposeINICollection;
  SetINIFileName(AppName);
  EntryValue := Default;
  if (INIColl = nil) then ReadINIFile;
  if INIColl <> nil then FindEntry(Section, EntryName, EntryValue);
  GetProfileString := Length(EntryValue);
end;

function WriteProfileString(AppName: PathStr; Section,
                            EntryName, EntryValue: String): Integer;
var
  i, EntryIndex: Integer;
  OrgF: Text;
  Line, Dummy: String;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  ON, NN: NameStr;
begin
  WriteProfileString := -1;
  SetINIFileName(AppName);
  FSplit(INIFile, D, N, E);
  ON := N;
  FSplit(AppName, D, N, E);
  NN := N;
  ON := UpcaseStr(ON);
  NN := UpcaseStr(NN);
  { make sure that INIColl = nil if OldName <> NewName }
  { (= another .ini file)                              }
  if ON <> NN then DisposeINICollection;
  if (INIColl = nil) then ReadINIFile;

  if INIColl <> nil then
  begin
    { flush collection to .INI file ? }
    if (INIColl <> nil) and
       ((UpcaseStr(Section) = 'NILL') and
        (UpcaseStr(EntryName) = 'NILL') and
        (UpcaseStr(EntryValue) = 'NILL')) then
    begin
      if SaveINIFile then WriteProfileString := 0;
      Exit;
    end
    { delete Section ? }
    else
    if (EntryName = 'NILL') and (EntryValue = 'NILL') and
      FindSection(Section) then
    begin
      { adjust SectionIndexEnd if the section is the last section }
      { in the .ini file                                          }
      if SectionIndexEnd = INIColl^.Count-1 then Inc(SectionIndexEnd);

      While (SectionIndexStart < SectionIndexEnd) and
            (SectionIndexEnd <= INIColl^.Count) do
      begin
        INIColl^.AtFree(SectionIndexStart);
        Dec(SectionIndexEnd);
      end;
    end
    else
    { delete Entry ? }
    if (EntryValue = 'NILL') then
    begin
      EntryIndex := FindEntry(Section, EntryName, Dummy);
      if EntryIndex > 0 then
        INIColl^.AtFree(EntryIndex);                  { dispose string }
    end
    else
    begin
      EntryIndex := FindEntry(Section, EntryName, Dummy);
      { if EntryName is found, then replace the old string with the    }
      { new string.                                                    }
      if EntryIndex > 0 then
      begin
        DisposeStr(INIColl^.At(EntryIndex));  { dispose the old string }
        INIColl^.AtPut(EntryIndex, NewStr(EntryName+'='+EntryValue));
      end
      else
      { if FindEntry returns -1 then the entry does not exist. So      }
      { insert the new entry at index returned by FindEntry.           }
      { if EntryValue = NILL, don't do anyting.                        }
      if (EntryValue <> 'NILL') and (EntryIndex = -1) then
      begin
        for I := 0 to INIColl^.Count-1 do
          Line := PString(INIColl^.At(I))^;
        if SectionIndexEnd < INIColl^.Count-1 then
          INIColl^.AtInsert(SectionIndexEnd,
            NewStr(EntryName+'='+EntryValue))
        else
          INIColl^.AtInsert(INIColl^.Count,
            NewStr(EntryName+'='+EntryValue));
        for I := 0 to INIColl^.Count-1 do
          Line := PString(INIColl^.At(I))^;
      end
      else
      { if FindEntry returns -2 then the section does not exist. So    }
      { insert the new section and entry at the end.                   }
      if EntryIndex = -2 then
      begin
        INIColl^.AtInsert(INIColl^.Count, NewStr('['+Section+']'));
        INIColl^.AtInsert(INIColl^.Count,
          NewStr(EntryName+'='+EntryValue));
      end;
    end;
  end;
end;

function GetProfileInt(AppName: PathStr; Section, EntryName: String;
                       var EntryValue: Integer;
                       Default: Integer): Integer;
var
  Def, S: String;
  E, R, L: Integer;
begin
  Str(Default, Def);
  L := GetProfileString(AppName, Section, EntryName, S, Def);
  Val(S, R, E);
  if (E = 0) then EntryValue := R else EntryValue := Default;
  GetProfileInt := L;
end;

function WriteProfileInt(AppName: PathStr; Section, EntryName: String;
                         EntryValue: Integer): Integer;
var
  S: String;
  L: Integer;
begin
  Str(EntryValue, S);
  L := WriteProfileString(AppName, Section, EntryName, S);
  WriteProfileInt := L;
end;

{ if a copy of the .ini file is in memory then release the memory used }
procedure DisposeINICollection;
begin
  if INIColl <> nil then Dispose(INIColl, Done);
  INIColl := nil;
  INIF_ReadError := False;
  INIF_WriteError := False;
end;

{--- unit init & exit preb. -------------------------------------------}

procedure INIFExitProc; far;
begin
  ExitProc := OrgINIExitProc;
  { flush the collection }
  if INIF_FlushOnExit and (INIColl <> nil) then
    WriteProfileString(INIFile, 'NILL', 'NILL', 'NILL');
  DisposeINICollection;
end;

begin
  INIColl := nil;
  OrgINIExitProc := ExitProc;
  ExitProc := @INIFExitProc;
end.

