{
> Can someone please post some code on how to read a disk label/serial
> number from a disk. I plan to use it as a copy protection method (read
> the label/serial number on installation and only the program to install
> on a drive the same label/serial number) Thanks!

Do you realise that the serial number on a disk is changed when the disk is
formatted?  Therefore if someone crashes their system and has to format their
hard disk and restore your software from their backups your protection method
would be triggered!  Not a very good method to use for copy protection.
}
Program     MediaID;

Uses
  Dos;

Type
  Tmid = record
    midInfoLevel   : Word;                        { information level ? }
    midSerialNum   : LongInt;                           { serial number }
    midVolLabel    : packed array [1..11] of Char; { ASCII volume label }
    midFileSysType : packed array [1..8] of Char;   { ASCII file system }
  end;   { of Tmid }

Var
  MID : Tmid;
  DriveChar : Char;
  DriveNum : Word;
  DirInfo : SearchRec;
  Volume : String;

  Function    Hex4(w : Word) : String;
  const
    HexStr : packed array [$00..$0F] of Char = '0123456789ABCDEF';
  var
    s : String;
    ndx : Integer;
  begin  { of Hex4 }
    s := '';
    for ndx := 3 downto 0 do
      begin
        s := s + HexStr[(W shr (ndx*4)) and $0F];
      end;
    Hex4 := s;
  end;   { of Hex4 }

  Function    GetMediaID(Drive : Word) : Word;
  {---------------------------------------------------------------------}
  {    This routine reads the VolumeLabel, SerialNumber from the boot   }
  {  sector of the specified drive.  Requires MSDOS5 or above.          }
  {---------------------------------------------------------------------}
  begin  { of GetMediaID }
    asm
      mov   bx, Drive                       { 0=default, 1=A:, 2=B: etc }
      mov   ch, 08h                     { device category (must be 08h) }
      mov   cl, 66h                                      { Get Media ID }
      mov   dx, seg MID                { ds:dx pointer to MID structure }
      mov   ds, dx
      mov   dx, offset MID
      mov   ax, 440Dh                          { IOCTL for block device }
      int   21h
      jc    @1                      { carry is set if there is an error }
      mov   ax, 0000h                             { no error - clear ax }
    @1:
      mov   @result, ax                             { return error code }
    end;
  end;   { of GetMediaID }

  Function    VolumeLabel(Drive : Char; var VolLabel : String) : Word;
  {---------------------------------------------------------------------}
  {    This routine reads the VolumeLabel from the root directory of    }
  {  the specified drive.                                               }
  {---------------------------------------------------------------------}
  begin  { of VolLabel }
    FindFirst(Drive+':\*.*', VolumeID, DirInfo);
    VolumeLabel := DosError;
    VolLabel := DirInfo.Name;
    { delete a "." which would be the 9th character }
    if (Length(VolLabel) > 8) then
      Delete(VolLabel, 8, 1);
  end;   { of VolLabel }

begin  { of MediaID }

  DriveChar := 'C';
  DriveNum := ord(DriveChar) - 64;

  if (GetMediaID(DriveNum) = 0) then
    begin
      Writeln(output, 'InfoLevel = ', MID.midInfoLevel);
      Writeln(output, 'SerialNum = ',
        Hex4((MID.midSerialNum shr $10) and $FFFF), '-',
        Hex4(MID.midSerialNum and $FFFF));
      Writeln(output, 'VolLabel    = "', MID.midVolLabel, '"');
      Writeln(output, 'FileSysType = "', MID.midFileSysType, '"');
    end
  else
    begin
      { function not supported or error }
    end;

  Writeln(output);

  if (VolumeLabel(DriveChar, Volume) = 0) then
    Writeln(output, 'VolLabel    = "', Volume, '"')
  else
    begin
      { error }
    end;
end.   { of MediaID }
