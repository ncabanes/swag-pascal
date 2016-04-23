{
> 2: And with a string I want to read a specific string and
> get the first to letter of the 1st and last names.
> So for example: Mike Enos ==> ME-DATA.DAT.
>
> Function GetDatName : String;
[deleted]

 To get the first letter of a surname, it might be better to scan
 from the end of the string -- in case the person also uses their
 middle name or initial...
}

PROGRAM Monogram;

VAR
  PersonName  : STRING[64];             (* person's name(s)   *)
  FileName    : STRING[12];             (* file name          *)
  Index       : WORD;                   (* character pointer  *)

BEGIN
  FileName := '??-DATA.DAT';                (* common file name   *)

  PersonName := 'Jack B. Nimble';           (* example name       *)

  (* the person's name MUST contain at least one space...         *)

  IF (Length(PersonName)=0) OR (Pos(' ',PersonName)=0) THEN BEGIN
    WriteLn; WriteLn ('First AND Last names, please...');
    Halt(1);
  END;

  (* assume there's no leading white spaces...                    *)

  FileName[1] := UpCase (PersonName[1]);    (* pick up 1st char   *)

  (* scan from the end of PersonName, looking for white space...  *)

  Index := Length (PersonName);
  WHILE (Index > 0) AND (PersonName[Index] > ' ') DO DEC (Index);

  INC (Index);    (* ... 'cause we went one too many              *)

  FileName[2] := PersonName[Index];   (* get 1st char of surname  *)

  WriteLn;
  WriteLn ('File name for "',PersonName,'" is ',FileName);
  WriteLn;

END.
