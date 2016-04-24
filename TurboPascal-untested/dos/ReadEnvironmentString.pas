(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0006.PAS
  Description: Read Environment String
  Author: GAYLE DAVIS
  Date: 05-29-93  22:24
*)

{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
  {Allow overlays}
  {$F+,O-,X+,A-}
{$ENDIF}

UNIT Self;

INTERFACE

FUNCTION GetSelf : STRING;
FUNCTION GetSelfPath : STRING;

IMPLEMENTATION

FUNCTION GetSelf : STRING;

  VAR
    Temp      : STRING;
    I, EnvSeg  : WORD;
  BEGIN
    I      := 0;
    Temp   := '';
    EnvSeg := memw [prefixseg : $2C];  { have to set this up like any variable! }
    WHILE memw [EnvSeg : I] <> 0 DO   { read through environment strings }
      INC (I);
    INC (I, 4);                      { jump around 2 null bytes & word count }
    WHILE mem [EnvSeg : I] <> 0 DO    { skim off path & filename }
      BEGIN
        Temp := Temp + UPCASE (CHR (mem [EnvSeg : I]) );
        INC (I);
      END;
    GetSelf := Temp;
END; { function GetSelf }


FUNCTION GetSelfPath : STRING;

  VAR
    Temp      : STRING;
    I, EnvSeg  : WORD;
    Place     : INTEGER;
  BEGIN
    I   := 0;
    Temp := '';
    EnvSeg := memw [prefixseg : $2C];  { have to set this up like any variable! }
    WHILE memw [EnvSeg : I] <> 0 DO   { read through environment strings }
      INC (I);
    INC (I, 4);                      { jump around 2 null bytes & word count }
    WHILE mem [EnvSeg : I] <> 0 DO    { skim off path & filename }
      BEGIN
        Temp := Temp + UPCASE (CHR (mem [EnvSeg : I]) );
        INC (I);
      END;
    Place := LENGTH (Temp);
    WHILE (Place > 0) AND NOT (Temp [Place] IN [':', '\']) DO
    Place := PRED (Place);
    IF Place > 0 THEN Temp [0] := CHR (Place);
    GetSelfPath := Temp;
END; { function SelfPath }

END.

