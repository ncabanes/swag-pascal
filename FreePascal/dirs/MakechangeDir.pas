(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0012.PAS
  Description: Make/Change DIR
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:37
*)

Program MakeChangeDir;

{ Purpose:      - Make directories where they don't exist               }
{                                                                       }
{ Useful for:   - Installation Type Programs                            }
{                                                                       }
{ Useful notes: - seems to handles even directories With extentions     }
{                 (i.e. DIRDIR.YYY)                                     }
{               - there are some defaults that have been set up :-      }
{                 change if needed                                      }
{               - doesn't check to see how legal the required directory }
{                 is (i.e. spaces, colon in the wrong place, etc.)      }
{                                                                       }
{ Legal junk:   - this has been released to the public as public domain }
{               - if you use it, give me some credit!                   }
{                                                                       }

Var
  Slash : Array[1..20] of Integer;

Procedure MkDirCDir(Target : String);
Var
  i,
  count   : Integer;
  dir,
  home,
  tempdir : String;

begin
  { sample directory below to make }
  Dir := Target;
  { add slash at end if not given }
  if Dir[Length(Dir)] <> '\' then
    Dir := Dir + '\';
  { if colon where normally is change to that drive }
  if Dir[2] = ':' then
    ChDir(Copy(Dir, 1, 2))
  else
  { assume current drive (and directory) }
  begin
    GetDir(0, Home);
    if Dir[1] <> '\' then
      Dir := Home + '\' + Dir
    else
      Dir := Home + Dir;
  end;

  Count := 0;
  { search directory For slashed and Record them }
  For i := 1 to Length(Dir) do
  begin
    if Dir[i] = '\' then
    begin
      Inc(Count);
      Slash[Count] := i;
    end;
  end;
  { For each step of the way, change to the directory }
  { if get error, assume it doesn't exist - make it }
  { then change to it }
  For i := 2 to Count do
  begin
    TempDir := Copy(Dir, 1, Slash[i] - 1);
    {$I-}
    ChDir(TempDir);
    if IOResult <> 0 then
    begin
      MkDir(TempDir);
      ChDir(TempDir);
    end;
  end;
end;

begin
  MkDirCDir('D:\HI.ZZZ\GEEKS\2JKD98');
end.
