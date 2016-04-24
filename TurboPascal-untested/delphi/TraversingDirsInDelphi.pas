(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0100.PAS
  Description: Traversing DIRS in DELPHI
  Author: JAMES ALLISON
  Date: 02-21-96  21:04
*)

{=============================================}
{                                             }
{ James L. Allison                            }
{ 1703 Neptune Lane                           }
{ Houston, Texas  77062                       }
{ INTERNET:71565.303@compuserve.com           }
{                                             }
{ Released to public domain.                  }
{ Nov 6, 1994                                 }
{                                             }
{=============================================}


unit Traverse;
interface

uses
  SysUtils;
  {+F}

type
  Action = (Finished, FindMore);
  Process_File = function (Path: string; Info: tSearchRec): Action;
{
  Process_File is a user written procedure that does something
  to a file.  It then returns either Finished, telling Walk_Tree
  to quit, or CONTINUE, telling Walk_Tree to keep going.
}


{
  In the following, start is the path name of the directory where
  traversal is to start.  IT DOES NOT HAVE A TRAILING \ OR A
  FILE PATTERN.
}

procedure Walk_Tree(Start: string;
                    Attr: word;          {see FindFirst}
                    Recursive: boolean;  {walk into subtrees}
                    DoIt: Process_File); {called for each hit}

(*----------------------------------------------------------------------------*)
implementation

(*----------------------------------------------------------------------------*)
procedure Walk_Tree(Start: string;
                    Attr: word;
                    Recursive: boolean;
                    DoIt: Process_File);

  const
    FilePattern = '\*.*';

  var
    SR: tSearchRec;
    Temp: string;
    Status:integer;
  begin
    if Start[Length(Start)] = '\' then dec(Start[0]); {just in case}

    Temp := Start + FilePattern;
    Status:=FindFirst(Temp, Attr, SR);

    while Status = 0 do
      begin
        if DoIt(Start, SR) = Finished then EXIT;

        if ((SR.Attr and faDirectory) <> 0)
           and (SR.name <> '.')
           and (SR.name <> '..')
           and Recursive
           then Walk_Tree(Start + '\' + SR.name, Attr, Recursive, DoIt);

        Status:=FindNext(SR);
      end;

  end;

end.

