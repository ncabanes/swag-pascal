(*
  Category: SWAG Title: INPUT AND FIELD ENTRY ROUTINES
  Original name: 0008.PAS
  Description: Masked Input
  Author: BERNIE PALLEK
  Date: 01-27-94  12:13
*)

{
>  The text on the screen would be something like:
>  What is your phone number? (   )   -
>                              ^^^ ^^^ ^^^^
>  But text could only be entered at the marked locations.  As soon as one
>  section is full it would move to the one beside it but read in a different
>  variable..

How about this: (it's tested, BTW)
}

USES Crt;

VAR
  ts : String;

PROCEDURE MaskedReadLn(VAR s : String; mask : String; fillCh : Char);
{ in 'mask', chars with A will only accept alpha input, and chars
  with 0 will only accept numeric input; spaces accept anything }
VAR ch : Char; sx, ox, oy : Byte;
BEGIN
  s := ''; ox := WhereX; oy := WhereY; sx := 0;
  REPEAT
    Inc(sx);
    IF (mask[sx] IN ['0', 'A']) THEN
      Write(fillCh)
    ELSE IF (mask[sx] = '_') THEN
      Write(' ')
    ELSE Write(mask[sx]);
  UNTIL (sx = Length(mask));
  sx := 0;
  WHILE (NOT (mask[sx + 1] IN [#32, '0', 'A']))
  AND (sx < Length(mask)) DO BEGIN
    Inc(sx);
    s := s + mask[sx];
  END;
  GotoXY(ox + sx, oy);
  REPEAT
    ch := ReadKey;
    IF (ch = #8) THEN BEGIN
      IF (Length(s) > sx) THEN BEGIN
        IF NOT (mask[Length(s)] IN [#32, '0', 'A']) THEN BEGIN
          REPEAT
            s[0] := Chr(Length(s) - 1);
            GotoXY(WhereX - 1, WhereY);
          UNTIL (Length(s) <= sx) OR (mask[Length(s)] IN [#32, '0', 'A']);
        END;
        s[0] := Chr(Length(s) - 1); GotoXY(WhereX - 1, WhereY);
        Write(fillCh); GotoXY(WhereX - 1, WhereY);
      END ELSE BEGIN
        Sound(440);
        Delay(50);
        NoSound;
      END;
    END ELSE IF (Length(s) < Length(mask)) THEN BEGIN
      CASE mask[Length(s) + 1] OF
        '0' : IF (ch IN ['0'..'9']) THEN BEGIN
                Write(ch);
                s := s + ch;
              END;
        'A' : IF (UpCase(ch) IN ['A'..'Z']) THEN BEGIN
                Write(ch);
                s := s + ch;
              END;
        #32 : BEGIN
                Write(ch);
                s := s + ch;
              END;
      END;
      WHILE (Length(s) < Length(mask))
      AND (NOT (mask[Length(s) + 1] IN [#32, '0', 'A'])) DO BEGIN
        IF (mask[Length(s) + 1] = '_') THEN s := s + ' ' ELSE
          s := s + mask[Length(s) + 1];
        GotoXY(WhereX + 1, WhereY);
      END;
    END;
  UNTIL (ch IN [#13, #27]);
END;

BEGIN
  ClrScr;
  Write('Enter phone number: ');
  MaskedReadLn(ts, '(000)_000-0000', '_');
  WriteLn;
  Write('Enter postal code: ');
  MaskedReadLn(ts, 'A0A_0A0', '_');
  WriteLn;
END.

{
It can be improved with colours and such stuff, but it may suit your
needs without enhancement.  If you have questions about how this works,
feel free to ask.
}

