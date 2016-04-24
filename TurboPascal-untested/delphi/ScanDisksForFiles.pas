(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0181.PAS
  Description: Scan disks for files
  Author: DAVE ROWLANDS
  Date: 11-29-96  08:17
*)

{-------------------------------------------------------------------------}
{                                                                         }
{  Delphi Object Pascal Unit.                                             }
{                                                                         }
{  File handling routines for windows, compiled from "WINFILE.TPW" and    }
{  other pascal libraries.                                                }
{                                                                         }
{  Includes the following classes :                                       }
{                                                                         }
{  TDiskFileScaner  :  Used to scan disks for files.                      }
{  TFileDropControl :  Placed on a control or form to make it accept      }
{                      files from "File Manager"                          }
{                                                                         }
{  Most functions moved from "FILE_IO" to add to DLL, some functions are  }
{  still being updated.                                                   }
{                                                                         }
{  Some parts Copyright Boralnd International.                            }
{  Copyright ⌐ UK. Dave Rowlands 1993 - 1995.                             }
{                  All Rights Reserved.                                   }
{                                                                         }
{-------------------------------------------------------------------------}

Unit FileFind;
  Interface
    Uses
      WinDOS, Classes, SysUtils;

Function GetFileList(Const FileSpec : String; List : TStrings) : LongInt;

{--- GetFileList(FileSpec, List) -----------------------------------------}
{                                                                         }
{ This funtion fills the "List" with files that match "FileSpec".  If the }
{ "FileSpec" contains a directory then that directoy is searched,         }
{ otherwise the current directory is searched.  Returns the number of     }
{ files found                                                             }
{-------------------------------------------------------------------------}

Function HasAttr(Const FileName : String; Attr : Word) : Boolean;  

{--- HasAttr(Filename, Attr) ---------------------------------------------}
{                                                                         }
{ Returns "True" if "Filename" has the file attribute "Attr".             }
{-------------------------------------------------------------------------}

Function ValidDIR(Const DirName : String) : String;  

{--- ValidDIR(DIRname) ---------------------------------------------------}
{                                                                         }
{ Returns a string representing a valid path, created from "DirName" with }
{ the "\" character added if it is not already there.                     }
{-------------------------------------------------------------------------}

Implementation

Function GetFileList(Const FileSpec : String; List : TStrings) : LongInt;
Var
  sRec  : TSearchRec;  { Required by "FindFirst" and "FindNext" }
  spec  : String;      { For holding search specification       }
  sDir  : String;      { Holds full path                        }
  fName : String;      { For filename                           }
begin
  List.Clear;          { Clear the list, to add to existing list comment out }
  spec := '';
  sDir := '';
  If (FileSpec <> '') then
   begin
     spec := ExtractFilename(FileSpec);
     sdir := ExtractFilePath(FileSpec);
   end
   else spec := '*.*'; { Default to ALL files }

  { Check to see if we have a valid directory in the "FileSpec" }
  { If we don't we use the current directory.                   }

  If (sDir = '') then GetDir(0, sDir);

  { Check and convert }

  If (Length(sdir) > 0) then sDir := LowerCase(ValidDIR(sDir));

  { Look for the first file matching the file specification, "FindFirst" }
  { returns a non zero value if file not found.                          }

  Result := FindFirst(sDir + spec, faAnyFile - faDirectory, sRec);

  { While we have a filename, build it up to a fully quallified filename }

  While (Result = 0) do
   begin

     { First, check to see if it's a directory }
      
     If (sRec.Name[1] <> '.') then { It's not }
      begin

        { Create full pathname }

        fName := sDir + LowerCase(sRec.Name);

        { Add it to the string list }

        List.Add(fName);

     end;

     { Now look for the next match }

     Result := FindNext(sRec);                 
  end;
  FindClose(sRec);      { We have finished, so tell system }
  Result := List.Count; { Return the number of items in the string list }
end;

Function ValidDIR(Const DirName : String) : String;
 begin
   Result := Dirname;
   If (Result[Length(Result)] = '\') then Exit;
   If FileExists(Dirname) then Result := ExtractFilePath(Dirname);
   If HasAttr(Result, faDirectory) then AppendStr(Result, '\');
end;

Function HasAttr(Const FileName : String; Attr : Word) : Boolean;
begin
  Result := (FileGetAttr(FileName) and Attr) = Attr;
end;

end.

