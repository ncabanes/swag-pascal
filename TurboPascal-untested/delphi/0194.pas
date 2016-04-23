unit ExtrIcon;

interface
uses ShellAPI, Graphics, WinTypes, SysUtils;

function ExtractIconFromFile(FileName: string; Index: integer): HIcon;

implementation

function ExtractIconFromFile(FileName: string; Index: integer): HIcon;
var
  Buff: array [0..255] of char;
  iNumberOfIcons: integer;
begin
  { If we have a valid file. }
  if FileExists(FileName) then
     begin
     { Find out how many icons are in the file }
     iNumberOfIcons := ExtractIcon(hInstance, StrPCopy(Buff, FileName), Cardinal(-1));
     if (Index > 0) and (Index < iNumberOfIcons) and (iNumberOfIcons > 0) then
     Result:= ExtractIcon(hInstance, Buff, Index);
     end;

end;

end.
