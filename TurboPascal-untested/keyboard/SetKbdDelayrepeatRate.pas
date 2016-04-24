(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0032.PAS
  Description: Set KBD delay/repeat rate
  Author: SWAG SUPPORT TEAM
  Date: 08-17-93  08:45
*)

{***********************************************
* KBSETUP - set the desired delay/repeat rate  *
* for the keyboard.                            *
***********************************************}

USES
    Dos;

PROCEDURE Usage;
  BEGIN
    WriteLn;
    WriteLn('KBSETUP Command format:');
    WriteLn;
    WriteLn('KBSETUP  n {A | B | C | D} ');
    WriteLn;
    Write  ('n            A number from 0 to 31');
    WriteLn(' to set the keyboard repeat rate.');
    Write  ('             0 is the fastest and');
    WriteLn(' 31 is the slowest.');
    WriteLn;
    Write  ('A,B,C or D   Sets the keyboard');
    WriteLn(' delay before repeating');
    Write  ('             to 1/4, 1/2, 3/4 and');
    WriteLn(' 1 second.');
    Halt(1);
  END;

VAR
  KBDelay, KBRepeat, I : byte;
  Code                 : integer;
  Regs                 : Registers;
  KeyString            : string[1];

BEGIN

  KBDelay := 0;
  KBRepeat := 0;

  IF ParamCount = 0 THEN
    Usage
  ELSE
    BEGIN
      FOR I := 1 TO ParamCount DO
        BEGIN
          KeyString := ParamStr(I);
        IF UpCase(KeyString[1]) in ['A'..'D'] THEN
          KBDelay := Ord(UpCase(KeyString[1]))
                       - Ord('A')
        ELSE
          BEGIN
             {$R-}
            Val(ParamStr(I),KBRepeat,Code);
             {$R+}
            IF (Code <> 0) or (KBRepeat < 0) or
               (KBRepeat > 31) THEN
              BEGIN
                Write('-- Invalid Letter or');
                Write(' Number Entered --> ');
                WriteLn(ParamStr(I));
                Usage
              END
          END
        END;

        { Set the keyboard delay/repeat rate }

      WITH Regs DO
        BEGIN
          AX := $0305;
          BH := KBDelay;
          BL := KBRepeat;
          Intr($16,Regs)
        END
    END {of the IF/THEN/ELSE instruction}
END.

