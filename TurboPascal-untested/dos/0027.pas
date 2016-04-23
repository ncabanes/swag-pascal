{
> I need a way to find the  volume Label of a drive.  Any  suggestions or
> source code?
}
{$S-,R-,V-,I-,N-,B-,F-}

Unit Volume;

Interface

Uses
  Dos;

Type

  Drive       = Byte;
  VolumeName  = String [11];

  VolFCB      = Record
    FCB_Flag : Byte;
    Reserved : Array [1..5] of Byte;
    FileAttr : Byte;
    Drive_ID : Byte;
    FileName : Array [1..8] of Byte;
    File_Ext : Array [1..3] of Byte;
    Unused_A : Array [1..5] of Byte;
    File_New : Array [1..8] of Byte;
    fExt_New : Array [1..3] of Byte;
    Unused_B : Array [1..9] of Byte
  end;

Function DelVol (D : Byte) : Boolean;
Function AddVol (D : Byte; V : VolumeName) : Boolean;
Function ChgVol (D : Byte; V : VolumeName) : Boolean;
Function GetVol (D : Byte) : VolumeName;

Implementation

Procedure Pad_Name (Var V : VolumeName);
begin
  While LENGTH (V) <> 11 DO
    V := V + ' '
end;

Function Fix_Ext_Sym (Var V : VolumeName) : Byte;
Var
  I : Byte;
begin
  I := POS ('.', V);
  if I > 0 then
    DELETE (V, I, 1);
  Fix_Ext_Sym := I
end;

Function Extract_Name (S : SearchRec) : VolumeName;
Var
  H, I : Byte;
begin
  I := Fix_Ext_Sym (S.Name);
  if (I > 0) and (I < 9) then
    For H := 1 to (9 - I) DO
      INSERT (' ', S.Name, I);
  Extract_Name := S.Name
end;

Procedure Fix_Name (Var V : VolumeName);
Var
  I : Byte;
begin
  Pad_Name (V);
  For I := 1 to 11
    do V [I] := UPCASE (V [I])
end;

Function Valid_Drive_Num (D : Byte) : Boolean;
begin
  Valid_Drive_Num := (D >= 1) and (D <= 26)
end;

Function Find_Vol (D : Byte; Var S : SearchRec) : Boolean;
begin
  FINDFIRST (CHR (D + 64) + ':\*.*', VolumeID, S);
  Find_Vol := DosError = 0
end;

Procedure Fix_FCB_NewFile (V : VolumeName; Var FCB : VolFCB);
Var
  I : Byte;
begin
  For I := 1 to 8 DO
    FCB.File_New [I] := ORD (V [I]);
  For I := 1 to 3 DO
    FCB.fExt_New [I] := ORD (V [I + 8])
end;

Procedure Fix_FCB_FileName (V : VolumeName; Var FCB : VolFCB);
Var
   I : Byte;
begin
  For I := 1 to 8 DO
    FCB.FileName [I] := ORD (V [I]);
  For I := 1 to 3 DO
    FCB.File_Ext [I] := ORD (V [I + 8])
end;

Function Vol_Int21 (Fnxn : Word; D : Drive; Var FCB : VolFCB) : Boolean;
Var
  Regs : Registers;
begin
  FCB.Drive_ID := D;
  FCB.FCB_Flag := $FF;
  FCB.FileAttr := $08;
  Regs.DS     := SEG (FCB);
  Regs.DX     := OFS (FCB);
  Regs.AX     := Fnxn;
  MSDos (Regs);
  Vol_Int21 := Regs.AL = 0
end;

Function DelVol (D : Byte) : Boolean;
Var
   sRec : SearchRec;
   FCB  : VolFCB;
   V    : VolumeName;
begin
  DelVol := False;
  if Valid_Drive_Num (D) then
  begin
    if Find_Vol (D, sRec) then
    begin
      V := Extract_Name (sRec);
      Pad_Name (V);
      Fix_FCB_FileName (V, FCB);
      DelVol := Vol_Int21 ($1300, D, FCB)
    end
  end
end;

Function AddVol (D : Byte; V : VolumeName) : Boolean;
Var
  sRec : SearchRec;
  FCB  : VolFCB;
begin
  AddVol := False;
  if Valid_Drive_Num (D) then
  begin
    if not Find_Vol (D, sRec) then
    begin
      Fix_Name (V);
      Fix_FCB_FileName (V, FCB);
      AddVol := Vol_Int21 ($1600, D, FCB)
    end
  end
end;

Function ChgVol (D : Byte; V : VolumeName) : Boolean;
Var
   sRec : SearchRec;
   FCB  : VolFCB;
   x    : Byte;
begin
  ChgVol := False;
  if Valid_Drive_Num (D) then
  begin
    if Find_Vol (D, sRec) then
    begin
      x := Fix_Ext_Sym (V);
      Fix_Name (V);
      Fix_FCB_NewFile (V, FCB);
      V := Extract_Name (sRec);
      Pad_Name (V);
      Fix_FCB_FileName (V, FCB);
      ChgVol := Vol_Int21 ($1700, D, FCB)
    end
  end
end;

Function GetVol (D : Byte) : VolumeName;
Var
  sRec : SearchRec;
begin
  GetVol := '';
  if Valid_Drive_Num (D) then
    if Find_Vol (D, sRec) then
      GetVol := Extract_Name (sRec)
end;

end.
