(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0059.PAS
  Description: HD Test
  Author: STUART KIRSCHENBAUM
  Date: 01-27-94  12:08
*)

{
>  function GetDriveID(drive: char):byte;
>  begin
>    with regs do
>      begin
>        AH := $1C;
>        DL := ord(Upcase(drive))-64;
>        Intr($21,regs);
>        GetDriveID := Mem[ds:bx];
>      end;
>  end;

>This interrupt (01Ch) is supposed to return 0F8h in case of a harddisk, and
>some other value if it is a floppy. However, running OS/2, this function
>returns 0F0h :(( My old Apricot (it's a computer!), running DOS 3.2, also
>reports 0F0h...

  0F0H is also the code for an unknown device for Service $1C.  I
  haven't tried it but have you looked at Service $44, function $08?  My
  sources tell me that this function (DOS 3.0 up) will return 0 in AX if
  the device is removable, 1 if a fixed disk, and $0F if invalid drive.

  Hang on... I'm trying it now.  It seemed to work here.  Below is the
  sample code I used (in TP 5.5).
}

PROGRAM HDTest;
{Stuart Kirschenbaum 93/12/11 Donated to the Public Domain if
  the Public actually wants it :-)  }

USES
   DOS;

VAR
  Is_Hard_Drive : boolean;

FUNCTION TestHD(DriveNum : byte):boolean;
VAR
   Regs: Registers;
BEGIN
   With Regs DO BEGIN
      AH := $44;
      AL := $08;
      BL := DriveNum;
      Intr($21, Regs);
      IF AX = 0 THEN TestHD := false
      ELSE IF AX = 0 THEN TestHD := true;  {Note we really should test
                                            for invalid drive but this
                                            is just an example <g> }
   END;

END;

BEGIN {Main for testing program}

   Is_Hard_Drive := TestHD(3); {3 = Drive C a Hard Drive on my system}
   IF Is_Hard_Drive THEN
      writeln('Well that seemed to work fine... Let''s try a floppy')
   ELSE
      writeln('That didn''t work right... Damn.');
   Is_Hard_Drive := TestHD(1); {1 = Drive A, a floppy drive}
   IF Is_Hard_Drive THEN
      writeln('You should never see this message')
   ELSE
      writeln('Success');
END.

