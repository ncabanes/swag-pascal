(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0021.PAS
  Description: Format Number Strings
  Author: GAYLE DAVIS
  Date: 07-16-93  06:09
*)


Uses DOS, Crt;

{VAR S : String;}

function CommaString (number : longint) : string;
  var
    TempStr : string;
    OrgLen : byte;
  begin
    Str (number, tempstr);
    OrgLen := Length (tempstr);
    if OrgLen > 3 then
      begin
        if OrgLen < 7 then
          Insert (',', tempstr, Length (tempstr) - 2);
        if OrgLen >= 7 then
          begin
            Insert (',', tempstr, length (tempstr) - 5);
            Insert (',', tempstr, length (tempstr) - 2);
          end;
      end;
    CommaString := tempstr;
  end;

FUNCTION FmtStr (STR, Fmt : STRING) : STRING;
VAR
TempStr : STRING;
I, J : BYTE;
BEGIN
TempStr := '';

    IF (POS (',', Fmt) > 0) THEN
    BEGIN
    FmtStr := STR;
    IF LENGTH (STR) <= 3 THEN EXIT;
    J := 0;
    FOR I := LENGTH (STR) DOWNTO 1 DO
        BEGIN
        TempStr := STR [i] + TempStr;
        INC (j);
        IF (J MOD 3 = 0) AND (TempStr[1] <> '.') THEN TempStr := ',' + TempStr;
        END;

    WHILE TempStr [1] = ',' DO
          TempStr := COPY (TempStr, 2, LENGTH (TempStr) );
    END ELSE
        BEGIN
        J := 0;
        FOR I := 1 TO LENGTH (Fmt) DO
        BEGIN
            IF NOT (Fmt [I] IN ['#', '!', '@', '*']) THEN
            BEGIN
                TempStr [I] := Fmt [I] ;  {force any none format charcters into string}
                 J := SUCC (J);
            END
            ELSE    {format character}
            BEGIN
                IF I - J <= LENGTH (STR) THEN
                   TempStr [I] := STR [I - J]
                ELSE
                   TempStr [I] := ' ';    {pad with underlines}
            END;
        END;

        TempStr [0] := CHAR (LENGTH (Fmt) );  {set initial byte to string length}
        END;

    FmtStr := Tempstr;

END;  {Func FmtStr}

FUNCTION FmtReal(Num : REAL; FMT : STRING) : STRING;
VAR Tmp : STRING;
BEGIN
  STR (Num : 12 : 2, Tmp);
  WHILE (NOT (Tmp[1] in ['0'..'9','.'])) AND (Tmp > '') DO DELETE(Tmp,1,1);
  FmtReal := FmtStr(Tmp, FMT);
END;

(*

Hi boys,

These routines are fairly simple to understand and should work for you in
in just about any situation.  I've used them for years, and I've found
them to be the answer to all my needs.

If you need more help with these, just call !!

Gayle
*)



BEGIN
ClrScr;
WriteLn(CommaString(123456789));   { Format any type of INTEGER }
WriteLn(FmtReal(1234567.89,'##,###,###,###.##'));  { Format Type REAL with decimals }
WriteLn(FmtStr('2198758811','(###) ###-####')); { Format a Phone number }
WriteLn(FmtStr('062593','##/##/##')); { Format a date number }
Readkey;
END.
