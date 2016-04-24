(*
  Category: SWAG Title: COMMAND LINE ROUTINES
  Original name: 0014.PAS
  Description: Command Line Parsing
  Author: RANDALL WOODMAN
  Date: 08-25-94  09:05
*)

{
   CMDPARSE.PAS
   Command line parameter parsing
   If unit is included, command line is automatically parsed.

}
unit CmdParse;
interface

uses
  Strings;

type

  CmdPtr = ^CmdRec;
  CmdRec = Record
    CmdParam : String[64];  { 64 char to allow for maximum path length }
    Next     : CmdPtr;
  end;

var
  FirstCmd   : CmdPtr;  { Ptr to first CmdRec or Nil }
  CurrentCmd : CmdPtr;  { Ptr to current CmdRec or Nil }
  CmdCnt     : Byte;    { Total of all entered parameters }

function FirstCmdStr : String;
  { Returns the first parameter entered, or the null ('') string. }

function NextCmdStr : String;
  { Returns the next parameter entered, or the null ('') string. }

function ValidCmdStr(ChkStr : String; CaseCheck : Boolean) : Boolean;
  { Checks all input parameters to see if CmdStr has been input.  CaseCheck
    determines if the the search of parameters should be case sensitive. }

procedure ClearCmd;
  { Disposes of all command line pointers except FirstCmd & CurrentCmd
    which are set to Nil }

implementation
{---------------------------------------------------------------------------}
var
  Cmd_I : Byte;

  function FirstCmdStr : String;
    { Returns the first parameter entered, or the null ('') string. }
  begin
    if FirstCmd <> Nil then begin
      FirstCmdStr := FirstCmd^.CmdParam;
      CurrentCmd := FirstCmd^.Next;
    end else
      FirstCmdStr := '';
  end;

  function NextCmdStr : String;
    { Returns the next parameter entered, or the null ('') string. }
  begin
    if CurrentCmd <> Nil then begin
      NextCmdStr := CurrentCmd^.CmdParam;
      CurrentCmd := CurrentCmd^.Next;
    end else
      NextCmdStr := '';
  end;

  function ValidCmdStr(ChkStr : String; CaseCheck : Boolean) : Boolean;
    { Checks all input parameters to see if CmdStr has been input.  CaseCheck
      determines if the the search of parameters should be case sensitive. }
  var
    CmdStr : String;
    FoundCmd : Boolean;
  begin
    CmdStr := FirstCmdStr;
    FoundCmd := False;
    repeat
      if CaseCheck then
      begin
        if CmdStr = ChkStr then
          FoundCmd := True
      end
      else
        if (StUpCase(CmdStr) = StUpCase(ChkStr)) then
          FoundCmd := True;
      CmdStr := NextCmdStr;
    until CmdStr = '';
    ValidCmdStr := FoundCmd;
  end;

  procedure ClearCmd;
    { Disposes of all command line pointers except FirstCmd & CurrentCmd
      which are set to Nil }
  begin
    if FirstCmd <> Nil then
      repeat
        CurrentCmd := FirstCmd^.Next;
        Dispose(FirstCmd);
        FirstCmd := CurrentCmd;
      until FirstCmd = Nil;
  end;

  procedure CmdAdd(CmdStr : String);
    { Add a new CmdRec to the list }
  var
    TempCmdPtr : CmdPtr;
  begin
    New(TempCmdPtr);
    if FirstCmd = Nil then
      FirstCmd := TempCmdPtr
    else
      CurrentCmd^.Next := TempCmdPtr;
    TempCmdPtr^.Next := Nil;  { Initialize new Next pointer }
    TempCmdPtr^.CmdParam := CmdStr;
    CurrentCmd := TempCmdPtr;
    Inc(CmdCnt);
  end;

  procedure ParsePStr(PStr : String);
    { Parse out a ParamStr() into multiple CmdRecs }
  var
    WorkStr   : String;
    TempStr   : String;
    SpPos: Byte;
    I,L : Byte;
  begin

    { translate first - to / }
    if PStr[1] = '-' then
      PStr[1] := '/';

    SpPos := Pos('/',Copy(PStr,2,Length(PStr)-1));
    if SpPos > 0 then
      repeat
        CmdAdd(Copy(PStr,1,SpPos));
        PStr := Copy(PStr,SpPos+1,Length(PStr)-SpPos);
        SpPos := Pos('/',Copy(PStr,2,Length(PStr)-1));
      until SpPos = 0;
    CmdAdd(PStr);
  end;

begin
  FirstCmd := Nil;
  CurrentCmd := Nil;
  CmdCnt := 0;

  for Cmd_I := 1 to ParamCount do
    ParsePStr(ParamStr(Cmd_I));
  CurrentCmd := FirstCmd;
end.

