(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0029.PAS
  Description: Valid Directories
  Author: LARRY HADLEY
  Date: 01-27-94  11:58
*)

{
   For you TV programmers out there, here is a neat little
   TValidator object for you - it verifies that the DIRECTORY
   entered in a TInputLine is valid and currently exists.
}

Unit DirValid;

INTERFACE

Uses
  Objects,
  Validate;

Type
  PDirValidator = ^TDirValidator;
  TDirValidator = OBJECT(TValidator)
    constructor Init;

    procedure Error; virtual;
    function IsValid(const S : string) : boolean; virtual;
  end;

IMPLEMENTATION

Uses
  Dos,
  MsgBox;

Function ExistDir(d : string) : boolean;
VAR
  S : SearchRec;
BEGIN
  {$I-}
  FindFirst(d, Directory, S);
  {$I+}
  if DOSError = 0 then
  BEGIN
    if Directory = (S.attr and Directory) then
      ExistDir := TRUE
    ELSE
      ExistDir := FALSE;
    END
  ELSE
    ExistDir := FALSE;
  END;

constructor TDirValidator.Init;
begin
  inherited Init;
end;

procedure   TDirValidator.Error;
begin
  MessageBox('Directory does not exist!', nil, mfError + mfOKButton);
end;

function    TDirValidator.IsValid(const S : string) : boolean;
var
  d : string;
begin
  if s='' then  {always return TRUE when entry string is empty}
  begin
    IsValid := TRUE;
    EXIT;
  end;
  d := s;
  if s[Length(d)] = '\' then
    Delete(d, Length(d), 1); {allows flexibility - TV & TP expect
                               paths to NOT terminate in a \ }
  if ExistDir(d) then
    IsValid := TRUE   {directory exists}
  else
    IsValid := FALSE; {directory does not exist}
end;

end.
