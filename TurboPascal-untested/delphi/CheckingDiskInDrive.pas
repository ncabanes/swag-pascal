(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0212.PAS
  Description: Checking Disk in Drive
  Author: AHTO TANNER
  Date: 03-04-97  13:18
*)


{With my last project if a disk is not in say one of the Floppy drives
or my CDRom drive it will crash so i used this function that borland
suggest
}

function DiskInDrive(Drive: Char): Boolean;
var
  ErrorMode: word;

ok it stops the program from crashing but it shows
I/O 32 error message the question is how do i show them another message
telling the user that thay need to pop in a disk.
And pop the Drive Combo box back to the Hard Drive.
<<<<<<<<<<<<<<<<<<

I'm using the following snippet in cmbDrive.OnChange event. Be sure NOT
to connect lstDir through DirList property of cmbDrive. It's a bit like a
batch file, but it works for me OK in Delphi 2 :)

procedure TfrmMain.cmbDriveChange(Sender: TObject);
var
   OldDrive: char;

label
   Retry;

   function SetDrive(const NewDrive: char): boolean;
   begin
      try
         lstDir.Drive := NewDrive;
         Result := true;
      except
         Result := false;
      end;
   end;

begin

Retry:
   OldDrive := lstDir.Drive;

   if not SetDrive(cmbDrive.Drive) then begin
      beep;
      if MessageBox(Handle, PChar(UpperCase(cmbDrive.Drive) + ':\ is not accessible.'#13#13'Drive not ready.'),
         'Error', mb_RetryCancel or mb_IconStop or mb_DefButton1) =
IDRETRY then
            goto Retry
      else
         begin
            lstDir.Drive := OldDrive;
            cmbDrive.Drive := lstDir.Drive;
         end;
   end;

end;

