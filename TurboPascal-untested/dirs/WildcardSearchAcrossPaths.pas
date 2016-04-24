(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0048.PAS
  Description: Wildcard Search across paths
  Author: STEVE SNEED
  Date: 09-04-95  11:03
*)


unit WCSearch;  {wildcard search across specified path(s)}

{ DEMO AT BOTTOM !! }

{---------------------------------------------------------------------------->
  Unit to search a specified path for one or more files.  Multi-directory
  paths (using standard DOS semicolon-delimited path strings) and wildcards
  are allowed.  Uses FindFirst/FindNext-type syntax for flexibility, and
  uses the DOSError variable to return same error codes as FindFirst/Next.

  Requires either Object Professional or Turbo Professional from TurboPower
  Software.  UNDEFine the conditional directive "UseOPro" below if using
  Turbo Professional.

  Written by Steve Sneed, 26-May-90.  Released to TurboPower Software for
  their use or general release.  I wrote this to allow searching a provided
  path string for wildcards to ease batch downloads in the BBS package I'm
  updating; I hope you find it useful.
>----------------------------------------------------------------------------}

{$DEFINE UseOPro}

interface

uses
  DOS,
{$IFDEF UseOPro}
  OpString;
{$ELSE}
  TpString;
{$ENDIF}

procedure FindFirstWC(SFile,SPath : String;
                      Attribs : Byte;
                      var R : SearchRec;
                      var Path : PathStr);
  {-Search for first entry matching "SFile" on "SPath"}

procedure FindNextWC(var R : SearchRec; var Path : PathStr);
  {-Search for subsequent entries on SPath}


implementation

var
  SrchPath : String;
  SrchName : PathStr;
  SrchAttr : Byte;

  procedure FindFirstWC(SFile,SPath : String;
                        Attribs : Byte;
                        var R : SearchRec;
                        var Path : PathStr);
  var I : Integer;
      First : Boolean;
  begin
    First := True;
    SrchAttr := Attribs;
    SrchPath := SPath;
    SrchName := SFile;

    repeat
        {if first time thru the loop, allow for an empty SPath}
      if (SrchPath = '') and (NOT(First)) then begin
        DOSError := 18;
        exit;
      end;
      First := False;

        {retrieve the next path to search}
      I := Pos(';',SrchPath);
      if I > 0 then begin
        Path := AddBackSlash(Copy(SrchPath,1,Pred(I)));
        Delete(SrchPath,1,I);
      end
      else begin
        Path := AddBackSlash(SrchPath);
        SrchPath := '';
      end;

        {look for a matching entry}
      FindFirst(Path+SrchName,SrchAttr,R);
    until DOSError <> 18;
  end;

  procedure FindNextWC(var R : SearchRec; var Path : PathStr);
  var I : Integer;
  begin
      {see if any matching entries from last search}
    FindNext(R);
    if DOSError = 0 then exit;

    repeat
        {if the original search path is enpty, we're done}
      if SrchPath = '' then begin
        DOSError := 18;
        exit;
      end;

        {retrieve the next path to search}
      I := Pos(';',SrchPath);
      if I > 0 then begin
        Path := AddBackSlash(Copy(SrchPath,1,Pred(I)));
        Delete(SrchPath,1,I);
      end
      else begin
        Path := AddBackSlash(SrchPath);
        SrchPath := '';
      end;

        {look for a matching entry}
      FindFirst(Path+SrchName,SrchAttr,R);
    until DOSError <> 18;
  end;

end.

{ -----------------  DEMO -------------------------- }

program Search_Path; {demo program for WCSearch unit}

{Example program for the WCSearch unit}

uses
  DOS, WCSearch;

var
  S : String;
  R : SearchRec;
  I : Integer;

procedure EndIt(S : String);
begin
  WriteLn(S);
  Halt(1);
end;

begin
  if ParamCount < 1 then
    EndIt('Syntax: SRCHPATH [filespec] {path_to_search | *}');
  if ParamCount > 1 then begin
    S := ParamStr(2);
    if S[1] = '*' then S := GetEnv('PATH');
  end
  else
    S := '';

  I := 0;
  FindFirstWC(ParamStr(1),S,AnyFile,R,S);
  while DOSError = 0 do begin
    WriteLn(S+R.Name);
    inc(I);
    FindNextWC(R,S);
  end;

  if I = 0 then
    WriteLn('No matching files')
  else begin
    Write(I,' file');
    if I > 1 then Write('s');
    WriteLn(' found');
  end;
end.

