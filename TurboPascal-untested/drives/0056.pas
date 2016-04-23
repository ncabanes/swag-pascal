UNIT VolFuncs;
(**) INTERFACE (**)
USES Dos;
TYPE
  VolString = String[12];

  FUNCTION GetLabel(driveNum : Byte;
                    VAR V : VolString) : Boolean;
  FUNCTION SetLabel(driveNum : Byte;
                    NuLabel : VolString) : Boolean;
  FUNCTION DelLabel(driveNum : Byte) : Boolean;

(**) IMPLEMENTATION (**)
TYPE
  ExFCB = RECORD
            FF        : Byte;              {must be 0FFh}
            Reserved0 : ARRAY[1..5] OF Byte; {must be 0s}
            Attribute : Byte;
            DriveID   : Byte;
            Filename  : ARRAY[1..8] OF Char;
            Extension : ARRAY[1..3] OF Char;
            CurBlock  : Word;
            RecSize   : Word;
            FileSize  : LongInt;
            Date      : Word;
            Time      : Word;
            Reserved  : ARRAY[1..8] OF Byte;
            CurRec    : Byte;
            Relative  : LongInt;
          END;

  FUNCTION GetLabel(driveNum : Byte;
                    VAR V : VolString) : Boolean;
  CONST
    Any : String[5] = ':\*.*';
  VAR
    SR   : SearchRec;
    Mask : PathStr;
    P    : Byte;
  BEGIN
    IF DriveNum > 0 THEN
      Mask[1] := Char(DriveNum + ord('@'))
    ELSE GetDir(0, Mask);
    Move(Any[1], Mask[2], 5);
    Mask[0] := #6;
    FindFirst(Mask, VolumeID, SR);
    WHILE (SR.Attr AND VolumeID = 0) AND
          (DosError = 0) DO
      FindNext(SR);
    IF DosError = 0 THEN
      BEGIN
        FillChar(V[1], 11, ' ');
        V[0] := #11;
        P := Pos('.', SR.Name);
        IF P = 0 THEN
          Move(SR.Name[1], V[1], length(SR.Name))
        ELSE
          BEGIN
            Move(SR.Name[1], V[1], pred(P));
            Move(SR.Name[P+1], V[9], length(SR.Name)-P);
          END;
        GetLabel := TRUE;
      END
    ELSE GetLabel := FALSE;
  END;

  FUNCTION SetLabel(driveNum : Byte;
                    NuLabel : VolString) : Boolean;
  VAR E  : ExFCB;
  BEGIN
    WITH E DO
      BEGIN
        FF        := $FF;
        FillChar(Reserved0, 5, 0);
        Attribute := VolumeID;
        DriveID   := DriveNum;
        FillChar(FileName, 8, ' ');
        FillChar(Extension, 3, ' ');
        Move(NuLabel[1], Filename, length(NuLabel));
      END;
    ASM
      PUSH DS
      MOV AX, SS
      MOV DS, AX
      LEA DX, E    {point DS:DX at Extended FCB}
      MOV AH, 16h  {create using FCB}
      INT 21h
      INC AL
      MOV @result, AL
      POP DS
    END;
  END;

  FUNCTION DelLabel(driveNum : Byte) : Boolean;
  VAR E   : ExFCB;
  BEGIN
    WITH E DO
      BEGIN
        FF        := $FF;
        FillChar(Reserved0, 5, 0);
        Attribute := VolumeID;
        DriveID   := DriveNum;
        FillChar(FileName, 8, '?');
        FillChar(Extension, 3, '?');
      END;
    ASM
      PUSH DS
      MOV AX, SS
      MOV DS, AX
      LEA DX, E    {point DS:DX at Extended FCB}
      MOV AH, 13h  {delete using FCB}
      INT 21h
      INC AL
      MOV @Result, AL
      POP DS
    END;
  END;
END.