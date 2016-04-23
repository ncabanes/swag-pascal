
function DoesDriveExist(DriveLetter: char): string;
var i: integer;
begin
  if DriveLetter in ['A'..'Z'] then {Make it lower case.}
    DriveLetter := chr(ord(DriveLetter) or $20);
  i := GetDriveType(ord(DriveLetter) - ord('a'));
  case i of
    DRIVE_REMOVABLE: result := 'floppy';
    DRIVE_FIXED: result := 'hard disk';
    DRIVE_REMOTE: result := 'network drive';
    else result := 'does not exist';
  end;
end;

function DoesDriveExist(DriveLetter: char): boolean;

var
  drives: TDriveComboBox;
  i: integer;
begin
  result := false;
  drives := TDriveComboBox.create(application);
  drives.parent := form1;
  form1.listbox1.items := drives.items;
  for i := drives.items.count - 1 downto 0 do {Note: this is case sensitive: lower case.}
    if drives.items.strings[i][1] = DriveLetter then result := true;
  drives.free; {...so that the combobox doesn't show.}
end;

Also, DiskFree() will return -1 if the drive does not exist.

Neil Rubenking wrote this code --

function DirExists(const S : String): Boolean;
VAR
  OldMode : Word;
  OldDir  : String;

BEGIN
  Result := True;
  GetDir(0, OldDir); {save old dir for return}
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS); {if drive empty, except}
  try try
    ChDir(S);
  except
    ON EInOutError DO Result := False;
  end;
  finally
    ChDir(OldDir); {return to old dir}
    SetErrorMode(OldMode); {restore old error mode}
  end;
END;
