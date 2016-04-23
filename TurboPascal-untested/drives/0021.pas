{
Could somebody help me out here? I'm trying to Write a
Program that reads the File names and their attributes from
disk/drive.

Unit volLabel;

  Type String11 = String[11];
  Function  GetCurrentVolumeLabel : String11;
  Procedure DelVolumeLabel(CurrentVolumeLabel:String11);
  Procedure WriteVolumeLabel(CurrentVolumeLabel:String11);
  ( to change a volume Label: delete old, then Write new )
}

(* Implementation *)

Uses
  Dos;

Var
  oldir : String; { only For test Program }

Type
  ExtendedFCBType = Record
                      ExtendedFCBflag : Byte;
                      Reserved1       : Array[1..5] of Byte;
                      Attr            : Byte;
                      DriveID         : Byte;
                      FileName        : Array[1..8] of Char;
                      FileExt         : Array[1..3] of Char;
                      CurrentBlockNum : Word;
                      RecordSize      : Word;
                      FileSize        : LongInt;
                      PackedDate      : Word;
                      PackedTime      : Word;
                      Reserved2       : Array[1..8] of Byte;
                      CurrentRecNum   : Byte;
                      RandomRecNum    : LongInt;
                    end;

Type String11 = String[11];
Function GetCurrentVolumeLabel : String11;
Var
  CurrentDrive: String;
  VolumeLabel : SearchRec;  { defined in the Dos Unit }
  i : Word;
begin                    { 12345678901 }
  GetCurrentVolumeLabel:= 'no Label   ';
  getdir(0,CurrentDrive); {in Dos Unit }
  CurrentDrive:= copy(CurrentDrive,1,3) + '*.*';
  {get Volume Label in A: drive}
  findfirst(CurrentDrive,VolumeID,VolumeLabel);
  if Doserror=0 then
    With VolumeLabel do
      begin
        {remove period}
        delete(VolumeLabel.name,pos('.',VolumeLabel.name),1);
        { pad to 11 Chars }
        For i:= length(name) to 11 do name:= name + ' ';
        GetCurrentVolumeLabel:= name;
      end; { With VolumeLabel}
end; {of GetCurrentVolumeLabel }

Procedure DelVolumeLabel(CurrentVolumeLabel:String11);
{delete volume Label from disk in current drive}
Var
  regs : Registers;
  FCB  : ExtendedFCBType;
begin
  fillChar(FCB,sizeof(FCB),#0);  {initialize FCB With nulls }
  With FCB do
    begin
      ExtendedFCBflag:= $ff;      { always }
      Attr           := VolumeID; {defined in the Dos Unit}
      DriveID        := 0;        {default drive}
      move(CurrentVolumeLabel[1],FileName,8); {you have to put these in}
     move(CurrentVolumeLabel[9],FileExt ,3); {For some silly reason   }
    end; { With FCB do }

  { set up regs For Dos call }
  fillChar(regs,sizeof(regs),#0); {initialize regs With nulls}
  regs.ah:= $13; {Dos 1.0 delete File Function}
  regs.ds:= seg(FCB);
  regs.dx:= ofs(FCB);
  MsDos(regs); {call Dos to delete the volume Label }
  if regs.al=0 then Writeln('Success -- volume Label deleted.')
  else Writeln('Failure -- volume Label not deleted.');
end; { of DelVolumeLabel }

Procedure WriteVolumeLabel(CurrentVolumeLabel:String11);
{create volume Label from disk in current drive}
Var
  regs : Registers;
  FCB  : ExtendedFCBType;
begin
  fillChar(FCB,sizeof(FCB),#0);  {initialize FCB With nulls }
  With FCB do
    begin
      ExtendedFCBflag:= $ff;      { always }
      Attr           := VolumeID; {defined in the Dos Unit}
      DriveID        := 0;        {default drive}
      move(CurrentVolumeLabel[1],FileName,8);
      move(CurrentVolumeLabel[9],FileExt ,3);
    end; { With FCB do }

  { set up regs For Dos call }
  fillChar(regs,sizeof(regs),#0); {initialize regs With nulls}
  regs.ah:= $16; {Dos 1.0 create File Function}
  regs.ds:= seg(FCB);
  regs.dx:= ofs(FCB);
  MsDos(regs); {call Dos to delete the volume Label }
  if regs.al=0 then Writeln('Success -- volume Label written.')
  else Writeln('Failure -- volume Label not written.');
end; { of WriteVolumeLabel }

begin { test Program }
  getdir(0,oldir); { save current directory }
  chdir('a:');     { play With diskette in A: }
  Writeln('Old volume Label: ',GetCurrentVolumeLabel);
  DelVolumeLabel(GetCurrentVolumeLabel);
  WriteVolumeLabel('10987654321');
  Writeln('New volume Label: ',GetCurrentVolumeLabel);
  chdir(oldir); { go back to original directory }
end. { test program }
