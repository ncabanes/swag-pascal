(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0014.PAS
  Description: Set File Time (TOUCH)
  Author: GAYLE DAVIS
  Date: 05-29-93  22:21
*)

(* FT.PAS *)
(* Set file to a specific date *)

USES TPCrt, Dos, Misc, TimeDate;
VAR
  f : TEXT;
  h, m, s, hund : WORD; { For GetTime}
  ftime : LONGINT; { For Get/SetFTime}
  dt : DateTime; { For Pack/UnpackTime}
  DateS : DateStr;
  FName : STRING;

PROCEDURE Syntax;
BEGIN
        ResetAttr (7);
        CLRSCR;
        GOTOXY (1, 24);
        WRITELN ('FT.EXE    GDSOFT (c) 1992');
        WRITELN ('Usage   : FT filename date', #07);
        HALT (1);
END;

FUNCTION UpperCase (InpStr : STRING) : STRING;

VAR i : INTEGER;

BEGIN
   FOR i := 1 TO LENGTH (InpStr) DO
       UpperCase [i] := UPCASE (InpStr [i]);
   UpperCase [0] := InpStr [0]
END;

FUNCTION LeadingZero (w : WORD) : STRING;
VAR
  s : STRING;
BEGIN
  STR (w : 0, s);
  IF LENGTH (s) = 1 THEN
    s := '0' + s;
  LeadingZero := s;
END;

BEGIN
  ResetAttr (7);
  CLRSCR;
  IF (PARAMCOUNT < 1) OR NOT Exist (PARAMSTR (1) ) THEN Syntax;
  FName := UpperCase (PARAMSTR (1) );
  IF NOT ValidDate (PARAMSTR (2) ) THEN DateS := PlainDate ELSE DateS := PARAMSTR (2);
  ASSIGN (f, FName);
  RESET (f);
  GETFTIME (f, ftime); { Get creation time }
  UNPACKTIME (ftime, dt);
  WRITELN ('File ', FName, ' created at ', LeadingZero (dt.hour),
          ':', LeadingZero (dt.min), ':',
          LeadingZero (dt.sec), ' on ', dt.Month, '/', dt.day, '/', dt.year);
  WITH dt DO
    BEGIN
      FTime := PackDateTime (DateS, PlainTime);
      WRITELN ('Setting file datestamp to ', MakeSlashDate (DateS) );
      SETFTIME (f, ftime);
    END;
  CLOSE (f);   { Close file }
END.




