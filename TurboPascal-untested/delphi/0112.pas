{
When dealing with multiple drives, it is helpful to know
whether a drive is associated with a  is attached to a letter
(A, B, C, etc), and what its type is.  This code uses the API
GetDriveType function to do that. }

function ShowDriveType(DriveLetter: char): string;
var
  i: word;
begin
  if DriveLetter in ['A'..'Z'] then {Make it lower case.}
    DriveLetter := chr(ord(DriveLetter) + $20);
  i := GetDriveType(ord(DriveLetter) - ord('a'));
  case i of
    DRIVE_REMOVABLE: result := 'floppy';
    DRIVE_FIXED: result := 'hard disk';
    DRIVE_REMOTE: result := 'network drive';
    else result := 'does not exist';
  end;
end;
