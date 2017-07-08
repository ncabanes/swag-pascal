(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0050.PAS
  Description: Nice Expression Parser
  Author: LARS FOSDAL
  Date: 11-26-93  17:05
*)

PROGRAM Expr;

{
  Simple recursive expression parser based on the TCALC example of TP3.
  Written by Lars Fosdal 1987
  Released to the public domain 1993
}

PROCEDURE Eval(Formula : String;    { Expression to be evaluated}
               VAR Value   : Real;      { Return value }
               VAR ErrPos  : Integer);  { error position }
  CONST
    Digit: Set of Char = ['0'..'9'];
  VAR
    Posn  : Integer;   { Current position in Formula}
    CurrChar   : Char;      { character at Posn in Formula }


PROCEDURE ParseNext; { returnerer neste tegn i Formulaen  }
BEGIN
  REPEAT
    Posn:=Posn+1;
    IF Posn<=Length(Formula) THEN CurrChar:=Formula[Posn]
     ELSE CurrChar:=^M;
  UNTIL CurrChar<>' ';
END  { ParseNext };


FUNCTION add_subt: Real;
  VAR
    E   : Real;
    Opr : Char;

  FUNCTION mult_DIV: Real;
    VAR
      S   : Real;
      Opr : Char;

    FUNCTION Power: Real;
      VAR
        T : Real;

      FUNCTION SignedOp: Real;

        FUNCTION UnsignedOp: Real;
          TYPE
            StdFunc = (fabs,    fsqrt, fsqr, fsin, fcos,
                       farctan, fln,   flog, fexp, ffact);
            StdFuncList = ARRAY[StdFunc] of String[6];

          CONST
            StdFuncName: StdFuncList =
            ('ABS','SQRT','SQR','SIN','COS',
            'ARCTAN','LN','LOG','EXP','FACT');
          VAR
            E, L, Start    : Integer;
            Funnet         : Boolean;
            F              : Real;
            Sf             : StdFunc;

              FUNCTION Fact(I: Integer): Real;
              BEGIN
                IF I > 0 THEN BEGIN Fact:=I*Fact(I-1); END
                ELSE Fact:=1;
              END  { Fact };

          BEGIN { FUNCTION UnsignedOp }
            IF CurrChar in Digit THEN
            BEGIN
              Start:=Posn;
              REPEAT ParseNext UNTIL not (CurrChar in Digit);
              IF CurrChar='.' THEN REPEAT ParseNext UNTIL not (CurrChar in Digit);
              IF CurrChar='E' THEN
              BEGIN
                ParseNext;
                REPEAT ParseNext UNTIL not (CurrChar in Digit);
              END;
              Val(Copy(Formula,Start,Posn-Start),F,ErrPos);
            END ELSE
            IF CurrChar='(' THEN
            BEGIN
              ParseNext;
              F:=add_subt;
              IF CurrChar=')' THEN ParseNext ELSE ErrPos:=Posn;
            END ELSE
            BEGIN
              Funnet:=False;
              FOR sf:=fabs TO ffact DO
              IF not Funnet THEN
              BEGIN
                l:=Length(StdFuncName[sf]);
                IF Copy(Formula,Posn,l)=StdFuncName[sf] THEN
                BEGIN
                  Posn:=Posn+l-1; ParseNext;
                  f:=UnsignedOp;
                  CASE sf of
                    fabs:     f:=abs(f);
                    fsqrt:    f:=SqrT(f);
                    fsqr:     f:=Sqr(f);
                    fsin:     f:=Sin(f);
                    fcos:     f:=Cos(f);
                    farctan:  f:=ArcTan(f);
                    fln :     f:=LN(f);
                    flog:     f:=LN(f)/LN(10);
                    fexp:     f:=EXP(f);
                    ffact:    f:=fact(Trunc(f));
                  END;
                  Funnet:=True;
                END;
              END;
              IF not Funnet THEN
              BEGIN
                ErrPos:=Posn;
                f:=0;
              END;
            END;
            UnsignedOp:=F;
          END { UnsignedOp};

        BEGIN { SignedOp }
          IF CurrChar='-' THEN
          BEGIN
            ParseNext; SignedOp:=-UnsignedOp;
          END ELSE SignedOp:=UnsignedOp;
        END { SignedOp };

      BEGIN { Power }
        T:=SignedOp;
        WHILE CurrChar='^' DO
        BEGIN
          ParseNext;
          IF t<>0 THEN t:=EXP(LN(abs(t))*SignedOp) ELSE t:=0;
        END;
        Power:=t;
      END { Power };


    BEGIN { mult_DIV }
      s:=Power;
      WHILE CurrChar in ['*','/'] DO
      BEGIN
        Opr:=CurrChar; ParseNext;
        CASE Opr of
          '*': s:=s*Power;
          '/': s:=s/Power;
        END;
      END;
      mult_DIV:=s;
    END { mult_DIV };

  BEGIN { add_subt }
    E:=mult_DIV;
    WHILE CurrChar in ['+','-'] DO
    BEGIN
      Opr:=CurrChar; ParseNext;
      CASE Opr of
        '+': e:=e+mult_DIV;
        '-': e:=e-mult_DIV;
      END;
    END;
    add_subt:=E;
  END { add_subt };

BEGIN {PROC Eval}
  IF Formula[1]='.'
  THEN Formula:='0'+Formula;
  IF Formula[1]='+'
  THEN Delete(Formula,1,1);
  FOR Posn:=1 TO Length(Formula)
  DO Formula[Posn] := Upcase(Formula[Posn]);
  Posn:=0;
  ParseNext;
  Value:=add_subt;
  IF CurrChar=^M THEN ErrPos:=0 ELSE ErrPos:=Posn;
END {PROC Eval};

VAR
  Formula : String;
  Value   : Real;
  i, Err  : Integer;
BEGIN
  REPEAT
    Writeln;
    Write('Enter formula (empty exits): '); Readln(Formula);
    IF Formula='' THEN Exit;
    Eval(Formula, Value, Err);
    Write(Formula);
    IF Err=0
    THEN Writeln(' = ',Value:0:5)
    ELSE BEGIN
      Writeln;
      FOR i:=1 TO Err-1 DO Write(' ');
      Writeln('^-- Error in formula');
    END;
  UNTIL False;
END.
