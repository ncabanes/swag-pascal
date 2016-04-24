(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0059.PAS
  Description: Text Formula Parser
  Author: WIM VAN DER VEGT
  Date: 01-27-94  12:23
*)

{
│ I've written a pwoerfull formula evaluator which can be extended
│ during run-time by adding fuctions, vars and strings containing
│ Because its not very small post me a message if you want to receive it.

Here it goes. It's a unit and an example/demo of some features.

{---------------------------------------------------------}
{  Project : Text Formula Parser                          }
{  Auteur  : G.W. van der Vegt                            }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  900530.1900  Creatie (function call/exits removed)     }
{  900531.1900  Revisie (Boolean expressions)             }
{  900104.2100  Revisie (HEAP Function Storage)           }
{  910327.1345  External Real string vars (tfp_realstr)   }
{               are corrected the same way as the parser  }
{               corrects them before using TURBO's VAL    }
{---------------------------------------------------------}

UNIT Tfp_01;

INTERFACE

{---------------------------------------------------------}
{----Initializes function database                        }
{---------------------------------------------------------}

PROCEDURE Tfp_init(no : INTEGER);

{---------------------------------------------------------}
{----Parses s and returns REAL or STR(REAL:m:n)           }
{---------------------------------------------------------}

FUNCTION  Tfp_parse2real(s : STRING) : REAL;

FUNCTION  Tfp_parse2str(s : STRING;m,n : INTEGER) : STRING;

{---------------------------------------------------------}
{----Tfp_errormsg(tfp_ernr) returns errormessage          }
{---------------------------------------------------------}

VAR
  Tfp_ernr  : BYTE;                     {----Errorcode}

FUNCTION  Tfp_errormsg(nr : INTEGER) : STRING;


{---------------------------------------------------------}
{----Internal structure for functions/vars                }
{---------------------------------------------------------}

TYPE
  tfp_fname = STRING[12];               {----String name                     }

  tfp_ftype = (tfp_noparm,              {----Function or Function()          }
               tfp_1real,               {----Function(VAR r)                 }
               tfp_2real,               {----Function(VAR r1,r2)             }
               tfp_nreal,               {----Function(VAR r;n  INTEGER)      }
               tfp_realvar,             {----Real VAR                        }
               tfp_intvar,              {----Integer VAR                     }
               tfp_boolvar,             {----Boolean VAR                     }
               tfp_realstr);            {----Real String VAR                 }

CONST
  tfp_true  = 1.0;                      {----REAL value for BOOLEAN TRUE     }
  tfp_false = 0.0;                      {----REAL value for BOOLEAN FALSE    }

{---------------------------------------------------------}
{----Adds own FUNCTION or VAR to the parser               }
{    All FUNCTIONS & VARS must be compiled                }
{    with the FAR switch on                               }
{---------------------------------------------------------}

PROCEDURE Tfp_addobj(a : pointer;n : tfp_fname;t : tfp_ftype);


{---------------------------------------------------------}
{----Add Internal Function Packs                          }
{---------------------------------------------------------}

PROCEDURE Tfp_addgonio;

PROCEDURE Tfp_addlogic;

PROCEDURE Tfp_addmath;

PROCEDURE Tfp_addmisc;

{---------------------------------------------------------}

IMPLEMENTATION

CONST
  maxreal  = +9.99999999e37;            {----Internal maxreal                }
  maxparm  = 16;                        {----Maximum number of parameters    }

VAR
  maxfie   : INTEGER;                   {----max no of functions & vars      }
  fiesiz   : INTEGER;                   {----current no of functions & vars  }

TYPE
  fie      = RECORD
               fname : tfp_fname;       {----Name of function or var         }
               faddr : POINTER;         {----FAR POINTER to function or var  }
               ftype : tfp_ftype;       {----Type of entry                   }
             END;

  fieptr   = ARRAY[1..1] OF fie;        {----Will be used as [1..maxfie]     }

VAR
  fiearr   : ^fieptr;                   {----Array of functions & vars       }

{---------------------------------------------------------}

VAR
  Line     : STRING;                    {----Internal copy of string to Parse}
  Lp       : INTEGER;                   {----Parsing Pointer into Line       }
  Nextchar : CHAR;                      {----Character at Lp Postion         }

{---------------------------------------------------------}
{----Tricky stuff to call FUNCTIONS                       }
{---------------------------------------------------------}

{$F+}

VAR
  GluePtr : POINTER;

FUNCTION Call_noparm : REAL;

 INLINE($FF/$1E/GluePtr);  {CALL DWORD PTR GluePtr}

FUNCTION Call_1real(VAR r) : REAL;

 INLINE($FF/$1E/GluePtr);  {CALL DWORD PTR GluePtr}

FUNCTION Call_2real(VAR r1,r2) : REAL;

 INLINE($FF/$1E/GluePtr);  {CALL DWORD PTR GluePtr}

FUNCTION Call_nreal(VAR r,n) : REAL;
 INLINE($FF/$1E/GluePtr);  {CALL DWORD PTR GluePtr}

{$F-}

{---------------------------------------------------------}
{----This routine skips one character                     }
{---------------------------------------------------------}

PROCEDURE Newchar;

BEGIN
  IF (lp<LENGTH(Line))
    THEN INC(Lp);
  Nextchar:=UPCASE(Line[Lp]);
END;

{---------------------------------------------------------}
{----This routine skips one character and                 }
{    all folowing spaces from an expression               }
{---------------------------------------------------------}

PROCEDURE Skip;

BEGIN
  REPEAT
    Newchar;
  UNTIL (Nextchar<>' ');
END;

{---------------------------------------------------------}
{  Number     = Real    (Bv 23.4E-5)                      }
{               Integer (Bv -45)                          }
{---------------------------------------------------------}

FUNCTION Eval_number : REAL;

VAR
  Temp  : STRING;
  Err   : INTEGER;
  value : REAL;

BEGIN
{----Correct .xx to 0.xx}
  IF (Nextchar='.')
    THEN Temp:='0'+Nextchar
    ELSE Temp:=Nextchar;

  Newchar;

{----Correct ±.xx to ±0.xx}
  IF (LENGTH(temp)=1) AND (Temp[1] IN ['+','-']) AND (Nextchar='.')
    THEN Temp:=Temp+'0';

  WHILE Nextchar IN ['0'..'9','.','E'] DO
    BEGIN
      Temp:=Temp+Nextchar;
      IF (Nextchar='E')
        THEN
          BEGIN
          {----Correct ±xxx.E to ±xxx.0E}
            IF (Temp[LENGTH(Temp)-1]='.')
              THEN INSERT('0',Temp,LENGTH(Temp));
            Newchar;
            IF (Nextchar IN ['+','-'])
              THEN
                BEGIN
                  Temp:=Temp+Nextchar;
                  Newchar;
                END;
          END
        ELSE Newchar;
    END;

{----Skip trailing spaces}
  IF (line[lp]=' ')
    THEN WHILE (Line[lp]=' ') DO INC(lp);
  nextchar:=line[lp];

{----Correct ±xx. to ±xx.0 but NOT ±xxE±yy.}
  IF (temp[LENGTH(temp)]='.') AND
     (POS('E',temp)=0)
    THEN Temp:=Temp+'0';

  VAL(Temp,value,Err);

  IF (Err<>0) THEN tfp_ernr:=1;

  IF (tfp_ernr=0)
    THEN Eval_number:=value
    ELSE Eval_number:=0;
END;

{---------------------------------------------------------}

FUNCTION Eval_b_expr : REAL; FORWARD;

{---------------------------------------------------------}
{  Factor     = Number                                    }
{    (External) Function()                                }
{    (External) Function(Expr)                            }
{    (External) Function(Expr,Expr)                       }
{     External  Var Real                                  }
{     External  Var Integer                               }
{     External  Var Boolean                               }
{     External  Var realstring                            }
{               (R_Expr)                                  }
{---------------------------------------------------------}

FUNCTION Eval_factor : REAL;

VAR
  ferr    : BOOLEAN;
  param   : INTEGER;
  dummy   : ARRAY[0..maxparm] OF REAL;
  value,
  dummy1,
  dummy2  : REAL;
  temp    : tfp_fname;
  e,
  i,
  index   : INTEGER;
  temps   : STRING;

BEGIN
  CASE Nextchar OF
    '+'  : BEGIN
             Newchar;
             value:=+Eval_factor;
           END;
    '-'  : BEGIN
             Newchar;
             value:=-Eval_factor;
           END;

    '0'..'9',
    '.'  : value:=Eval_number;
    'A'..'Z'
         : BEGIN
             ferr:=TRUE;
             Temp:=Nextchar;
             Skip;
             WHILE Nextchar IN ['0'..'9','_','A'..'Z'] DO
               BEGIN
                 Temp:=Temp+Nextchar;
                 Skip;
               END;

           {----Seek function and CALL it}
             {$R-}
             FOR Index:=1 TO Fiesiz DO
               WITH fiearr^[index] DO
                 IF (fname=temp)
                   THEN
                     BEGIN
                       ferr:=FALSE;

                       CASE ftype OF

                       {----Function or Function()}
                         tfp_noparm  : IF (nextchar='(')
                                        THEN
                                          BEGIN
                                            Skip;

                                            IF (nextchar<>')')
                                              THEN tfp_ernr:=15;

                                            Skip;
                                          END;

                       {----Function(r)}
                         tfp_1real   : IF (nextchar='(')
                                         THEN
                                           BEGIN
                                             Skip;

                                             dummy1:=Eval_b_expr;

                                             IF (tfp_ernr=0) AND
                                                (nextchar<>')')
                                               THEN tfp_ernr:=15;

                                             Skip; {----Dump the ')'}
                                           END
                                         ELSE tfp_ernr:=15;

                       {----Function(r1,r2)}
                         tfp_2real   : IF (nextchar='(')
                                         THEN
                                           BEGIN
                                             Skip;

                                             dummy1:=Eval_b_expr;

                                             IF (tfp_ernr=0) AND
                                                (nextchar<>',')
                                               THEN tfp_ernr:=15;

                                             Skip; {----Dump the ','}
                                             dummy2:=Eval_b_expr;

                                              IF (tfp_ernr=0) AND
                                                 (nextchar<>')')
                                                THEN tfp_ernr:=15;

                                              Skip; {----Dump the ')'}
                                            END
                                          ELSE tfp_ernr:=15;

                       {----Function(r,n)}
                         tfp_nreal   : IF (nextchar='(')
                                         THEN
                                           BEGIN
                                             param:=0;

                                             Skip;
                                             dummy[param]:=Eval_b_expr;

                                             IF (tfp_ernr=0) AND
                                                (nextchar<>',')
                                               THEN tfp_ernr:=15
                                               ELSE
                                                 WHILE (tfp_ernr=0) AND
                                                       (nextchar=',') AND
                                                       (param<maxparm) DO
                                                   BEGIN
                                                     Skip; {----Dump the ','}
                                                     INC(param);
                                                     dummy[param]:=Eval_b_expr;
                                                   END;

                                             IF (tfp_ernr=0) AND
                                                (nextchar<>')')
                                               THEN tfp_ernr:=15;

                                             Skip; {----Dump the ')'}
                                           END
                                         ELSE tfp_ernr:=15;
                       {----Real Var}
                         tfp_realvar    : dummy1:=REAL(faddr^);

                       {----Integer Var}
                         tfp_intvar     : dummy1:=1.0*INTEGER(faddr^);

                       {----Boolean Var}
                         tfp_boolvar    : dummy1:=1.0*ORD(BOOLEAN(faddr^));

                       {----Real string Var}
                         tfp_realstr    : BEGIN
                                             temps:=STRING(faddr^);

                                           {----Delete Leading Spaces}
                                             WHILE (Length(temps)>0) AND
                                                   (temps[1]=' ') DO
                                               Delete(temps,1,1);

                                           {----Delete Trailing Spaces}
                                             WHILE (Length(temps)>0) AND
                                                   (temps[Length(temps)]=' ') Do
                                               Delete(temps,Length(temps),1);

                                          {----Correct .xx to 0.xx}
                                             IF (LENGTH(temps)>=1)  AND
                                                (LENGTH(temps)<255) AND
                                                (temps[1]='.')
                                               THEN Insert('0',temps,1);

                                           {----Correct ±.xx to ±0.xx}
                                             IF (LENGTH(temps)>=2) AND
                                                (LENGTH(temps)<255) AND
                                                (temps[1] IN ['+','-']) AND
                                                (temps[2]='.')
                                               THEN Insert('0',temps,2);

                                           {----Correct xx.Eyy to xx0.Exx}
                                             IF (Pos('.E',temps)>0) AND
                                                (Length(temps)<255)
                                               THEN Insert('0',temps,Pos('.E',temps));

                                           {----Correct xx.eyy to xx0.exx}
                                             IF (Pos('.e',temps)>0) AND
                                                (Length(temps)<255)
                                               THEN Insert('0',temps,Pos('.e',temps));
                                           {----Correct ±xx. to ±xx.0 but NOT ±}
                                             IF (temps[LENGTH(temps)]='.') AND
                                                (POS('E',temps)=0) AND
                                                (POS('e',temps)=0) AND
                                                (Length(temps)<255)
                                               THEN Temps:=Temps+'0';

                                             VAL(temps,dummy1,e);
                                             IF (e<>0)
                                               THEN tfp_ernr:=1;
                                           END;
                       END;

                       IF (tfp_ernr=0)
                         THEN
                           BEGIN
                             glueptr:=faddr;

                             CASE ftype OF
                               tfp_noparm   : value:=call_noparm;
                               tfp_1real    : value:=call_1real(dummy1);
                               tfp_2real    : value:=call_2real(dummy1,dummy2);
                               tfp_nreal    : value:=call_nreal(dummy,param);
                               tfp_realvar,
                               tfp_intvar,
                               tfp_boolvar,
                               tfp_realstr  : value:=dummy1;
                             END;
                           END;
                     END;
             IF (ferr=TRUE)
               THEN tfp_ernr:=2;

             {$R+}
           END;

    '('  : BEGIN
             Skip;

             value:=Eval_b_expr;

             IF (tfp_ernr=0) AND (nextchar<>')') THEN tfp_ernr:=3;

             Skip; {----Dump the ')'}
           END;

    ELSE tfp_ernr:=2;
  END;

  IF (tfp_ernr=0)
    THEN Eval_factor:=value
    ELSE Eval_factor:=0;

END;

{---------------------------------------------------------}
{  Term       = Factor ^ Factor                           }
{---------------------------------------------------------}

FUNCTION Eval_term : REAL;

VAR
  value,
  Exponent,
  dummy,
  Base      : REAL;

BEGIN
  value:=Eval_factor;

  WHILE (tfp_ernr=0) AND (Nextchar='^') DO
    BEGIN
      Skip;

      Exponent:=Eval_factor;

      Base:=value;
      IF (tfp_ernr=0) AND (Base=0)
        THEN value:=0
        ELSE
          BEGIN

          {----Over/Underflow Protected}
            dummy:=Exponent*LN(ABS(Base));
            IF (dummy<=LN(MAXREAL))
               THEN value:=EXP(dummy)
               ELSE tfp_ernr:=11;
          END;

      IF (tfp_ernr=0) AND (Base<0)
        THEN
          BEGIN
          {----allow only whole number exponents}
            IF (INT(Exponent)<>Exponent) THEN tfp_ernr:=4;

            IF (tfp_ernr=0) AND ODD(ROUND(exponent)) THEN value:=-value;
          END;
    END;

  IF (tfp_ernr=0)
    THEN Eval_term:=value
    ELSE Eval_term:=0;
END;

{---------------------------------------------------------}
{----Subterm  = Term * Term                               }
{               Term / Term                               }
{---------------------------------------------------------}

FUNCTION Eval_subterm : REAL;

VAR
  value,
  dummy  : REAL;

BEGIN
  value:=Eval_term;

  WHILE (tfp_ernr=0) AND (Nextchar IN ['*','/']) DO
    CASE Nextchar OF

    {----Over/Underflow Protected}
      '*' : BEGIN
              Skip;

              dummy:=Eval_term;

              IF (tfp_ernr<>0) OR (value=0) OR (dummy=0)
                THEN value:=0
                ELSE IF (ABS( LN(ABS(value)) + LN(ABS(dummy)) )<LN(Maxreal))
                  THEN value:= value * dummy
                  ELSE tfp_ernr:=11;
            END;

    {----Over/Underflow Protected}
      '/' : BEGIN
              Skip;

              dummy:=Eval_term;

              IF (tfp_ernr=0)
                THEN
                  BEGIN

                  {----Division by ZERO Protected}
                    IF (dummy<>0)
                      THEN
                        BEGIN
                        {----Underflow Protected}
                          IF (value<>0)
                            THEN
                              IF (ABS( LN(ABS(value))-LN(ABS(dummy)) )
                                 <LN(Maxreal))
                                THEN value:=value/dummy
                                ELSE tfp_ernr:=11
                        END
                      ELSE tfp_ernr:=9;
                  END;
            END;
    END;

  IF (tfp_ernr=0)
    THEN Eval_subterm:=value
    ELSE Eval_subterm:=0;
END;

{---------------------------------------------------------}
{  Real Expr  = Subterm + Subterm                         }
{               Subterm - Subterm                         }
{---------------------------------------------------------}

FUNCTION Eval_r_expr : REAL;

VAR
  dummy,
  dummy2,
  value : REAL;

BEGIN
  value:=Eval_subterm;

  WHILE (tfp_ernr=0) AND (Nextchar IN ['+','-']) DO
    CASE Nextchar OF

      '+' : BEGIN
              Skip;

              dummy:=Eval_subterm;

              IF (tfp_ernr=0)
                THEN
                  BEGIN

                  {----Overflow Protected}
                    IF (ABS( (value/10)+(dummy/10) )<(Maxreal/10))
                      THEN value:=value+dummy
                      ELSE tfp_ernr:=11;
                  END;
            END;

      '-' : BEGIN
              Skip;
              dummy2:=value;

              dummy:=Eval_subterm;

              IF (tfp_ernr=0)
                THEN
                  BEGIN

                  {----Overflow Protected}
                    IF (ABS( (value/10)-(dummy/10) )<(Maxreal/10))
                      THEN value:=value-dummy
                      ELSE tfp_ernr:=11;

                  {----Underflow Protected}
                    IF (value=0) AND (dummy<>dummy2)
                      THEN tfp_ernr:=11;
                  END;

            END;
    END;

{----At this point the current char must be
        1. the EOLN marker or
        2. a right bracket
        3. start of a boolean operator }

  IF NOT (Nextchar IN [#00,')','>','<','=',','])
    THEN tfp_ernr:=2;

  IF (tfp_ernr=0)
    THEN Eval_r_expr:=value
    ELSE Eval_r_expr:=0;
END;

{---------------------------------------------------------}
{  Boolean Expr  = R_Expr <  R_Expr                       }
{                  R_Expr <= R_Expr                       }
{                  R_Expr <> R_Expr                       }
{                  R_Expr =  R_Expr                       }
{                  R_Expr >= R_Expr                       }
{                  R_Expr >  R_Expr                       }
{---------------------------------------------------------}

FUNCTION Eval_b_expr : REAL;

VAR
  value : REAL;

BEGIN
  value:=Eval_r_expr;

  IF (tfp_ernr=0) AND (Nextchar IN ['<','>','='])
    THEN
      CASE Nextchar OF

        '<' : BEGIN
                Skip;
                IF (Nextchar IN ['>','='])
                  THEN
                    CASE Nextchar OF
                      '>' : BEGIN
                              Skip;
                              IF (value<>Eval_r_expr)
                                THEN value:=tfp_true
                                ELSE value:=tfp_false;
                            END;
                      '=' : BEGIN
                              Skip;
                              IF (value<=Eval_r_expr)
                                THEN value:=tfp_true
                                ELSE value:=tfp_false;
                            END;
                    END
                  ELSE
                    BEGIN
                      IF (value<Eval_r_expr)
                        THEN value:=tfp_true
                        ELSE value:=tfp_false;
                    END;
              END;

        '>' : BEGIN
                Skip;
                IF (Nextchar='=')
                  THEN
                    BEGIN
                      Skip;
                      IF (value>=Eval_r_expr)
                        THEN value:=tfp_true
                        ELSE value:=tfp_false;
                    END
                  ELSE
                    BEGIN
                      IF (value>Eval_r_expr)
                        THEN value:=tfp_true
                        ELSE value:=tfp_false;
                    END;
              END;
        '=' : BEGIN
                Skip;
                IF (value=Eval_r_expr)
                  THEN value:=tfp_true
                  ELSE value:=tfp_false;
              END;
      END;

  IF (tfp_ernr=0)
    THEN Eval_b_expr:=value
    ELSE Eval_b_expr:=0.0;
END;

{---------------------------------------------------------}

PROCEDURE Tfp_init(no : INTEGER);

BEGIN
  IF (maxfie>0)
    THEN FREEMEM(fiearr,maxfie*SIZEOF(fiearr^));

  GETMEM(fiearr,no*SIZEOF(fiearr^));

  maxfie:=no;
  fiesiz:=0;
END;

{---------------------------------------------------------}

FUNCTION Tfp_parse2real(s : string) : REAL;

VAR
  i,h     : INTEGER;
  value   : REAL;

BEGIN
  tfp_ernr:=0;

{----Test for match on numbers of ( and ) }
  h:=0;
  FOR i:=1 TO LENGTH(s) DO
    CASE s[i] OF
      '(' : INC(h);
      ')' : DEC(h);
    END;

  IF (h=0)
    THEN
      BEGIN

      {----Continue init}
        lp:=0;

      {----Add a CHR(0) as an EOLN marker}
        line:=S+#00;
        Skip;

      {----Try parsing if any characters left}
        IF (Line[Lp]<>#00)
          THEN value:=Eval_b_expr
          ELSE tfp_ernr:=6;
      END
    ELSE tfp_ernr:=3;

  IF (tfp_ernr<>0)
    THEN tfp_parse2real:=0.0
    ELSE tfp_parse2real:=value;
END;

{---------------------------------------------------------}

FUNCTION Tfp_parse2str(s : STRING;m,n : INTEGER) : STRING;

VAR
  r   : REAL;
  tmp : STRING;

BEGIN
  r:=Tfp_parse2real(s);
  IF (tfp_ernr=0)
    THEN STR(r:m:n,tmp)
    ELSE tmp:='';
  Tfp_parse2str:=tmp;
END;

{---------------------------------------------------------}

FUNCTION Tfp_errormsg;

BEGIN
  CASE nr OF
    0 : Tfp_errormsg:='Correct resultaat';                      {Error 0 }
    1 : Tfp_errormsg:='Ongeldig getal formaat';                 {Error 1 }
    2 : Tfp_errormsg:='Onbekende functie';                      {Error 2 }
    3 : Tfp_errormsg:='Een haakje mist';                        {Error 3 }
    4 : Tfp_errormsg:='Reele exponent geeft een complex getal'; {Error 4 }
    5 : Tfp_errormsg:='TAN( (2n+1)*PI/2 ) bestaat niet';        {Error 5 }
    6 : Tfp_errormsg:='Lege string';                            {Error 6 }
    7 : Tfp_errormsg:='LN(x) of LOG(x) met x<=0 bestaat niet';  {Error 7 }
    8 : Tfp_errormsg:='SQRT(x) met x<0 bestaat niet';           {Error 8 }
    9 : Tfp_errormsg:='Deling door nul';                        {Error 9 }
   10 : Tfp_errormsg:='Teveel functies & constanten';           {Error 10}
   11 : Tfp_errormsg:='Tussenresultaat buiten getalbereik';     {Error 11}
   12 : Tfp_errormsg:='Illegale tekens in functienaam';         {Error 12}
   13 : Tfp_errormsg:='Geen (on)gelijkheid / te complex';       {Error 13}
   14 : Tfp_errormsg:='Geen booleaanse expressie';              {Error 14}
   15 : Tfp_errormsg:='Verkeerd aantal parameters';             {Error 15}
  ELSE  Tfp_errormsg:='Onbekende fout';                         {Error xx}
  END;
END;

{---------------------------------------------------------}

PROCEDURE Tfp_addobj(a : pointer;n : tfp_fname;t : tfp_ftype);

VAR
  i : INTEGER;

BEGIN
  {$R-}
  IF (fiesiz<maxfie)
    THEN
      BEGIN
        INC(fiesiz);
        WITH fiearr^[fiesiz] DO
          BEGIN
            faddr:=a;
            fname:=n;
            FOR i:=1 TO LENGTH(fname) DO
              IF (UPCASE(fname[i]) IN ['0'..'9','_','A'..'Z'])
                THEN fname[i]:=UPCASE(fname[i])
                ELSE tfp_ernr:=12;
              IF (LENGTH(fname)>0) AND
                 NOT (fname[1] IN ['A'..'Z'])
                THEN tfp_ernr:=12;
              ftype:=t;
          END
      END
    ELSE tfp_ernr:=10
  {$R+}
END;

{---------------------------------------------------------}
{----Internal Functions                                   }
{---------------------------------------------------------}

{$F+}
FUNCTION xABS(VAR r : REAL) : REAL;

BEGIN
 xabs:=ABS(r);
END;

FUNCTION xAND(VAR r;VAR n : INTEGER) : REAL;

TYPE
  tmp   = ARRAY[0..0] OF REAL;

VAR
  x     : REAL;
  i     : INTEGER;

BEGIN
{$R-}
  FOR i:=0 TO n DO
    IF (tmp(r)[i]<>tfp_false) AND (tmp(r)[i]<>tfp_true)
      THEN
        BEGIN
          IF (tfp_ernr=0)
            THEN tfp_ernr:=14;
        END;
   IF (tfp_ernr=0) AND (n>0)
     THEN
       BEGIN
         x:=tfp_true*ORD(tmp(r)[0]=tfp_true);
         FOR i:=1 TO n DO
           x:=tfp_true*ORD((x=tfp_true) AND (tmp(r)[i]=tfp_true))
       END
     ELSE tfp_ernr:=15;
  IF tfp_ernr=0
    THEN xAND:=x
    ELSE xAND:=0.0;
{$R+}
END;

FUNCTION xARCTAN(VAR r : REAL) : REAL;

BEGIN
  xARCTAN:=ARCTAN(r);
END;

FUNCTION xCOS(VAR r : REAL) : REAL;

BEGIN
  xCOS:=COS(r);
END;

FUNCTION xDEG(VAR r : REAL) : REAL;

BEGIN
  xDEG:=(r/pi)*180;
END;

FUNCTION xE : REAL;

BEGIN
  xE:=EXP(1);
END;

FUNCTION xEXP(VAR r : REAL) : REAL;

BEGIN
  xEXP:=0;
  IF (ABS(r)<LN(MAXREAL))
    THEN xEXP:=EXP(r)
    ELSE tfp_ernr:=11;
END;

FUNCTION xFALSE : REAL;

BEGIN
  xFALSE:=tfp_false;
END;

FUNCTION xFRAC(VAR r : REAL) : REAL;

BEGIN
  xFRAC:=FRAC(r);
END;

FUNCTION xINT(VAR r : REAL) : REAL;

BEGIN
  xINT:=INT(r);
END;

FUNCTION xLN(VAR r : REAL) : REAL;

BEGIN
  xLN:=0;
  IF (r>0)
    THEN xLN:=LN(r)
    ELSE tfp_ernr:=7;
END;

FUNCTION xLOG(VAR r : REAL) : REAL;

BEGIN
  xLOG:=0;
  IF (r>0)
    THEN xLOG:=LN(r)/LN(10)
    ELSE tfp_ernr:=7;
END;

FUNCTION xMAX(VAR r;VAR n : INTEGER) : REAL;

TYPE
  tmp   = ARRAY[0..0] OF REAL;

VAR
  max   : REAL;
  i     : INTEGER;

BEGIN
{$R-}
  max:=tmp(r)[0];
  FOR i:=1 TO n DO
    IF (tmp(r)[i]>max)
      THEN max:=tmp(r)[i];
  xMAX:=max;
{$R+}
END;

FUNCTION xMIN(VAR r;VAR n : INTEGER) : REAL;

TYPE
  tmp   = ARRAY[0..0] OF REAL;

VAR
  min   : REAL;
  i     : INTEGER;

BEGIN
{$R-}
  min:=tmp(r)[0];
  FOR i:=1 TO n DO
    IF (tmp(r)[i]<min)
      THEN min:=tmp(r)[i];
  xMIN:=min;
{$R+}
END;
FUNCTION xIOR(VAR r;VAR n : INTEGER) : REAL;

TYPE
  tmp   = ARRAY[0..0] OF REAL;

VAR
  x     : REAL;
  i     : INTEGER;

BEGIN
{$R-}
  FOR i:=0 TO n DO
    IF (tmp(r)[i]<>tfp_false) AND (tmp(r)[i]<>tfp_true)
      THEN
        BEGIN
          IF (tfp_ernr=0)
            THEN tfp_ernr:=14;
        END;
   IF (tfp_ernr=0) AND (n>0)
     THEN
       BEGIN
         x:=tfp_true*ORD(tmp(r)[0]=tfp_true);
         FOR i:=1 TO n DO
           x:=tfp_true*ORD((x=tfp_true) OR (tmp(r)[i]=tfp_true))
       END
     ELSE tfp_ernr:=15;
  IF tfp_ernr=0
    THEN xIOR:=x
    ELSE xIOR:=0.0;
{$R+}
END;

FUNCTION xPI : REAL;

BEGIN
  xPI:=PI;
END;

FUNCTION xRAD(VAR r : REAL) : REAL;

BEGIN
  xRAD:=(r/180)*pi;
END;

FUNCTION xROUND(VAR r : REAL) : REAL;

BEGIN
  xROUND:=ROUND(r);
END;

FUNCTION xSGN(VAR r : REAL) : REAL;

BEGIN
  IF (r>=0)
    THEN xSgn:=+1
    ELSE xSgn:=-1;
END;

FUNCTION xSIN(VAR r : REAL) : REAL;

BEGIN
  xSIN:=SIN(r);
END;

FUNCTION xSQR(VAR r : REAL) : REAL;

BEGIN
  xSQR:=0;
  IF ( ABS(2*LN(ABS(r))) )<LN(MAXREAL)
    THEN xSQR:=EXP( 2*LN(ABS(r)) )
    ELSE tfp_ernr:=11;
END;

FUNCTION xSQRT(VAR r : REAL) : REAL;

BEGIN
  xSQRT:=0;
  IF (r>=0)
    THEN xSQRT:=SQRT(r)
    ELSE tfp_ernr:=8;
END;

FUNCTION xTAN(VAR r : REAL) : REAL;

BEGIN
  xTAN:=0;
  IF (COS(r)=0)
    THEN tfp_ernr:=5
    ELSE xTAN:=SIN(r)/COS(r);
END;

FUNCTION xTRUE : REAL;

BEGIN
  xTRUE:=tfp_true;
END;

FUNCTION xXOR(VAR r1,r2 : REAL) : REAL;

BEGIN
 IF ((r1<>tfp_false) AND (r1<>tfp_true)) OR
    ((r2<>tfp_false) AND (r2<>tfp_true))
   THEN
     BEGIN
       IF (tfp_ernr=0)
         THEN tfp_ernr:=14;
     END
   ELSE xxor:=tfp_true*ORD((r1=tfp_true) XOR (r2=tfp_true));
END;

{$F-}

{---------------------------------------------------------}

PROCEDURE Tfp_addgonio;

BEGIN
  Tfp_addobj(@xARCTAN,'ARCTAN',tfp_1real);
  Tfp_addobj(@xCOS   ,'COS'   ,tfp_1real);
  Tfp_addobj(@xDEG   ,'DEG'   ,tfp_1real);
  Tfp_addobj(@xPI    ,'PI'    ,tfp_noparm);
  Tfp_addobj(@xRAD   ,'RAD'   ,tfp_1real);
  Tfp_addobj(@xSIN   ,'SIN'   ,tfp_1real);
  Tfp_addobj(@xTAN   ,'TAN'   ,tfp_1real);
END;

{---------------------------------------------------------}

PROCEDURE Tfp_addlogic;

BEGIN
  Tfp_addobj(@xAND   ,'AND'   ,tfp_nreal);
  Tfp_addobj(@xFALSE ,'FALSE' ,tfp_noparm);
  Tfp_addobj(@xIOR   ,'OR'    ,tfp_nreal);
  Tfp_addobj(@xTRUE  ,'TRUE'  ,tfp_noparm);
  Tfp_addobj(@xXOR   ,'XOR'   ,tfp_2real);
END;

{---------------------------------------------------------}

PROCEDURE Tfp_addmath;
BEGIN
  Tfp_addobj(@xABS   ,'ABS'   ,tfp_1real);
  Tfp_addobj(@xEXP   ,'EXP'   ,tfp_1real);
  Tfp_addobj(@xE     ,'E'     ,tfp_noparm);
  Tfp_addobj(@xLN    ,'LN'    ,tfp_1real);
  Tfp_addobj(@xLOG   ,'LOG'   ,tfp_1real);
  Tfp_addobj(@xSQR   ,'SQR'   ,tfp_1real);
  Tfp_addobj(@xSQRT  ,'SQRT'  ,tfp_1real);
END;

{---------------------------------------------------------}

PROCEDURE Tfp_addmisc;

BEGIN
  Tfp_addobj(@xFRAC  ,'FRAC'  ,tfp_1real);
  Tfp_addobj(@xINT   ,'INT'   ,tfp_1real);
  Tfp_addobj(@xMAX   ,'MAX'   ,tfp_nreal);
  Tfp_addobj(@xMIN   ,'MIN'   ,tfp_nreal);
  Tfp_addobj(@xROUND ,'ROUND' ,tfp_1real);
  Tfp_addobj(@xSGN   ,'SGN'   ,tfp_1real);
END;

{---------------------------------------------------------}

BEGIN
{----Module Init}
  tfp_ernr:=0;
  fiesiz:=0;
  maxfie:=0;
  fiearr:=NIL;
END.

-------------------------------------------------------------<cut here

Program Tfptst;

Uses
  crt,
  tfp_01;

{$F+}  {----Important don't forget it !!!}

Var
  r : real;
  i : Integer;
  t,
  s : String;

FUNCTION xFUZZY(VAR r : REAL) : REAL;

BEGIN
  IF (r>0.5)
    THEN xFUZZY:=0.5
    ELSE xFUZZY:=0.4;
END; {of xFUZZY}

FUNCTION xAGE : REAL;

VAR
  s    : string;
  e    : Integer;
  r    : Real;

BEGIN
{----default value in case of error}
  xAGE:=0;

  Write('Enter your age : '); Readln(s);
  Val(s,r,e);

{----Setting tfp_ernr will flag an error.
     Can be a user defined value}

  IF e<>0
    THEN tfp_ernr:=1
    ELSE xAGE:=r;
END; {of xAge}
{$F-}

Begin
  Tfp_init(40);

{----Add internal function packs}
  Tfp_addgonio;
  Tfp_addlogic;
  Tfp_addmath;
  Tfp_addmisc;

{----Add external functions}
  Tfp_addobj(@r     ,'TEMP'   ,tfp_realvar);
  Tfp_addobj(@i     ,'COUNTER',tfp_intvar);
  Tfp_addobj(@t     ,'USER'   ,tfp_realstr);
  Tfp_addobj(@xfuzzy,'FUZZY'  ,tfp_1real);
  Tfp_addobj(@xage  ,'AGE'    ,tfp_noparm);

  i:=1;
  t:='1.25';
  s:='2*COUNTER';

  Clrscr;

{----Example #1 using FOR index in expression}
  Writeln(tfp_errormsg(tfp_ernr));
  FOR i:=1 TO 3 DO
    Writeln(s,' := ',Tfp_parse2real(s):0:2);
  Writeln(tfp_errormsg(tfp_ernr));

{----Example #2 using a real from the main program}
  r:=15;
  s:='TEMP';
  Writeln(r:0:2,' := ',Tfp_parse2real(s):0:2);

{----Example #3 using a function that does something strange}
  s:='AGE-1';
  Writeln('Last years AGE := ',Tfp_parse2real(s):0:2);

{----Example #4 using a number in a string
     This version doesn't allow recusive formula's yet
     Have a version that does!}
  s:='USER';
  Writeln('USER := ',Tfp_parse2real(s):0:2);

{----All of the above + Internal function PI, &
     Boolean expressions should return 1 because it can't be 1
     Booleans are reals with values of 1.0 and 0.0}
  s:='(SIN(COUNTER+TEMP*FUZZY(AGE)*PI)<>1)=TRUE';
  Writeln('? := ',Tfp_parse2real(s):0:6);

{----Your example goes here, try a readln(s)}

  Writeln(tfp_errormsg(tfp_ernr));
End.

