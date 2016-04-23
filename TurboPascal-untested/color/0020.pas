
PROGRAM Change_Color;
USES Crt;
VAR Tel, Tel2 : Byte;

(**********************************************************************)
(*   Copyright for this procedure by Steven Debruyn 1994              *)
(*   Hereby donated to Public Domain                                  *)
(*   Feel free to put this in the SWAG if you think it's any good     *)
(**********************************************************************)
PROCEDURE Say(Zin : String);
VAR Kleur : Byte;
     Code : Integer;
     Zin1 : String;
     Zin2 : String;
  TempZin : String;
   Gedaan : Boolean;
BEGIN
  WHILE Pos('\\',Zin) <> 0 DO BEGIN
    Zin1 := Copy(Zin, Pos('\\',Zin)+2, Pos('\\',Zin)+Pos(' ',Zin)-4);
    Val(Zin1,Kleur,Code);
    TextAttr:= Kleur;
    Zin2 := Copy(Zin, Pos('\\',Zin)+Length(Zin1)+2,Length(Zin));
    TempZin := Copy(Zin2, Pos(' ',Zin2), Pos('\\',Zin2)-1);
    Write(TempZin);
    Zin := Copy(Zin2, Pos(TempZin,Zin2)+Length(TempZin), Length(Zin2));
  END;
  WriteLn;
END;

BEGIN
  TextAttr:=0;
  ClrScr;
  Say('\\5 Hello\\9 World out there,\\79 this is a test\\154 !\\');
  Say('\\14 I can change color\\23 and \\220 background.\\138 and'+
      ' BLINK at the same time.\\');
  Say('\\15 Press\\11 [\\14 ENTER\\11 ]\\');
  ReadLn;
  ClrScr;
  Tel2:=1;
  FOR Tel := 1 TO 255 DO
  BEGIN
    TextAttr := Tel;
    WriteLn('This is Color : ',Tel);
    Inc(Tel2);
    IF Tel2 = 24 THEN
    BEGIN
      ReadLn;
      TextAttr:=0;
      ClrScr;
      Tel2 := 1;
    END;
  END
END.
