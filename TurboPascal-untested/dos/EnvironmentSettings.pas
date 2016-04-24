(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0040.PAS
  Description: Environment Settings
  Author: RUUD UPHOFF
  Date: 01-27-94  11:59
*)

{
> Who has PTENV.PAS

Here is how it works:
}
UNIT SetEnvir;

INTERFACE


USES
  DOS;


TYPE
  EnvSize = 0..16383;


PROCEDURE SetEnv(EnvVar, Value : STRING);

{-----------------------------------------------------------------------
 This procedure may be used to setup or change environment variables
 in the environment of the resident copy of COMMAND.COM or 4DOS.COM

 Note that this will be the ACTIVE copy of the command interpreter, NOT
 the primary copy!

 This unit is not tested under DR-DOS.

 Any call of SetEnv must be followed by checking ioresult. The procedure
 may return error 8 (out of memory) on too less space in te environment.
-----------------------------------------------------------------------}

IMPLEMENTATION

PROCEDURE SetEnv(EnvVar, Value : STRING);
VAR
  Link,
  PrevLink,
  EnvirP   : word;
  Size,
  Scan,
  Where,
  Dif      : integer;
  NewVar,
  OldVar,
  Test     : STRING;

  FUNCTION CheckSpace(Wanted : integer) : boolean;
  BEGIN
    IF wanted + Scan > Size THEN
      inoutres := 8;
    CheckSpace := inoutres = 0;
  END;

BEGIN
  IF inoutres >0 THEN
    Exit;
  FOR Scan := 1 TO Length(EnvVar) DO
    EnvVar[Scan] := UpCase(EnvVar[Scan]);
  EnvVar := EnvVar + '=';
  NewVar := EnvVar + Value + #0;
  link   := PrefixSeg;

  REPEAT
    PrevLink := Link;
    Link := memw [link : $16];
  UNTIL Link = prevlink;

  EnvirP := memw [Link : $2C];
  Size   := memw [Envirp - 1 : $03] * 16;
  Scan   := 0;
  Where  := -1;
  WHILE mem[EnvirP : Scan] <> 0 DO
  BEGIN
    move(mem[EnvirP : scan], Test[1], 255);
    Test[0] := #255;
    Test[0] := chr(pos(#0, Test));
    IF pos(EnvVar, Test) = 1 THEN
    BEGIN
      Where  := Scan;
      OldVar := Test;
    END;
    Scan := Scan + Length(Test);
  END;

  IF Where = -1 THEN
  BEGIN
    Where  := Scan;
    NewVar := NewVar + #0#0#0;
    IF NOT CheckSpace(Length(NewVar)) THEN
      Exit;
  END
  ELSE
  BEGIN
    Dif := Length(NewVar) - Length(OldVar);
    IF Dif > 0 THEN
    BEGIN
      IF NOT CheckSpace(Dif) THEN
        Exit;
      move(mem[EnvirP : Where], mem[EnvirP : Where + Dif], Scan - Where + 3);
    END
    ELSE
    IF Dif < 0 THEN
      move(mem[EnvirP : Where - Dif], mem[EnvirP : Where], Size - Where + Dif);
  END;

  move(NewVar[1], mem[EnvirP : Where], Length(NewVar));
END;

END.


