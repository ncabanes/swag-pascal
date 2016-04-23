{---------------------------------------------------------}
{  Project : Text Formula Parser                          }
{  Auteur  : G.W. van der Vegt                            }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  900530.1900  Creatie (function call/exits removed).    }
{  900531.1900  Revisie (Boolean expressions).            }
{  900104.2100  Revisie (HEAP Function Storage).          }
{  910327.1345  External Real string vars (tfp_realstr)   }
{               are corrected the same way as the parser  }
{               corrects them before using TURBO's VAL.   }
{  910829.1200  Support added for recursion with string   }
{               variables so they may contain formula's   }
{               now.                                      }
{  940411.1300  Hyperbolic, reciproke & inverse           }
{               goniometric functions added,              }
{               Type of tfp_lnr changed to Byte.          }
{               Bug fixed in tfp_check (tfp_lnr not always}
{               initialized to 0)                         }
{---------------------------------------------------------}

UNIT Tfp_02;

INTERFACE

CONST
  tfp_true      = 1.0;                   {----REAL value for BOOLEAN TRUE     }
  tfp_false     = 0.0;                   {----REAL value for BOOLEAN FALSE    }
  tfp_maxparm   = 16;                    {----Maximum number of parameters    }
  tfp_funclen   = 12;                    {----Maximum function name length    }

TYPE
  tfp_fname     = STRING[tfp_funclen];   {----Function Name or Alias          }
  tfp_ftype     = (tfp_noparm,           {----Function or Function()          }
                   tfp_1real,                  {----Function(VAR r)                 }
                   tfp_2real,                  {----Function(VAR r1,r2)             }
                   tfp_nreal,                  {----Function(VAR r;n  INTEGER)      }
                   tfp_realvar,            {----Real VAR                        }
                   tfp_intvar,           {----Integer VAR                     }
                   tfp_boolvar,                 {----Boolean VAR                     }
                   tfp_strvar);                 {----String VAR (Formula)            }

  tfp_rarray    = ARRAY[0..tfp_maxparm-1] OF REAL;

FUNCTION Tfp_parse2real(s : STRING): REAL;

FUNCTION Tfp_parse2str(s : STRING;m,n : INTEGER) : STRING;

{---------------------------------------------------------}
{----Interface to error functions for external addons     }
{---------------------------------------------------------}

VAR
  tfp_erpos,
  tfp_ernr      : BYTE;

PROCEDURE Tfp_seternr(ernr : INTEGER);

FUNCTION  Tfp_errormsg(nr : INTEGER) : STRING;

{---------------------------------------------------------}
{----Initialize & Expand internal parser datastructure    }
{---------------------------------------------------------}

PROCEDURE Tfp_init  (no : WORD);

PROCEDURE Tfp_expand(no : WORD);

{---------------------------------------------------------}
{----Keep first no function+vars of parser                }
{---------------------------------------------------------}

PROCEDURE Tfp_keep  (no : WORD);

{---------------------------------------------------------}
{----Number of functions+vars added to parser             }
{---------------------------------------------------------}

FUNCTION  Tfp_noobj : WORD;

{---------------------------------------------------------}
{----Adds own FUNCTION or VAR to the parser               }
{    All FUNCTIONS & VARS must be compiled                }
{    with the FAR switch on                               }
{---------------------------------------------------------}

PROCEDURE Tfp_addobj(adres : POINTER;
                     name  : tfp_fname;
                     ftype : tfp_ftype);

{---------------------------------------------------------}
{----Add Internal Function Packs                          }
{---------------------------------------------------------}

PROCEDURE Tfp_addgonio;
PROCEDURE Tfp_addlogic;
PROCEDURE Tfp_addmath;
PROCEDURE Tfp_addmisc;
PROCEDURE Tfp_addall;

{---------------------------------------------------------}

IMPLEMENTATION

TYPE
  tfp_parse_state = RECORD
                      tfp_line     : STRING; {----Copy of string to Parse   }
                      tfp_lp       : BYTE;   {----Parsing Pointer into Line }
                      tfp_nextchar : CHAR;   {----Character at Lp Postion   }
                     END;

  tfp_state_ptr   = ^tfp_parse_state;

CONST
  tfp_maxreal     = +9.99999999e37;          {----Internal maxreal                }
  tfp_maxlongint  = maxlongint-1;       {----Internal longint                }

VAR
  maxfie      : INTEGER;                    {----max no of functions & vars      }
  fiesiz      : INTEGER;                    {----current no of functions & vars  }
  p           : tfp_state_ptr;          {----Top level formula               }

TYPE
  tfp_fie_typ = RECORD
                  tfp_fname : tfp_fname;{----Name of function or var       }
                  tfp_faddr : POINTER;  {----FAR POINTER to function or var}
                  tfp_ftype : tfp_ftype;{----Type of entry                 }
                END;

  tfp_fieptr  = ARRAY[1..1] OF tfp_fie_typ; {----Open Array Construction   }

VAR
  fiearr      : ^tfp_fieptr;                  {----Array of functions & vars     }

{---------------------------------------------------------}
{----Tricky stuff to call FUNCTIONS                       }
{    Idea from Borland's DataBase ToolKit                 }
{---------------------------------------------------------}

{$F+}

VAR
  glueptr : POINTER;

FUNCTION Tfp_call_noparm : REAL;

 INLINE($ff/$1e/glueptr);  {CALL DWORD PTR GluePtr}

FUNCTION Tfp_call_1real(VAR lu_r) : REAL;

 INLINE($ff/$1e/glueptr);  {CALL DWORD PTR GluePtr}

FUNCTION Tfp_call_2real(VAR lu_r1,lu_r2) : REAL;

 INLINE($ff/$1e/glueptr);  {CALL DWORD PTR GluePtr}

FUNCTION Tfp_call_nreal(VAR lu_r,lu_n) : REAL;

 INLINE($ff/$1e/glueptr);  {CALL DWORD PTR GluePtr}

{$F-}

{---------------------------------------------------------}
{----TP round function not useable                        }
{---------------------------------------------------------}

FUNCTION Tfp_round(VAR r : REAL) : LONGINT;

BEGIN
  IF (r<0)
    THEN Tfp_round:= Trunc(r - 0.5)
    ELSE Tfp_round:= Trunc(r + 0.5);
END; {of Tfp_round}

{---------------------------------------------------------}
{----This routine set the tfp_ernr if not set already     }
{---------------------------------------------------------}

PROCEDURE Tfp_seternr(ernr : INTEGER);

BEGIN
  IF (tfp_ernr=0)
    THEN
      BEGIN
        tfp_erpos:=p^.tfp_lp;
        tfp_ernr :=ernr;
      END;
END; {of Tfp_Seternr}

{---------------------------------------------------------}
{----This routine skips one character                     }
{---------------------------------------------------------}

PROCEDURE Tfp_newchar(p : tfp_state_ptr);

BEGIN
  WITH p^ DO
    BEGIN
      IF (tfp_lp<Length(tfp_line))
        THEN Inc(tfp_lp);
      tfp_nextchar:=Upcase(tfp_line[tfp_lp]);
    END;
END; {of Tfp_Newchar}

{---------------------------------------------------------}
{----This routine skips one character and                 }
{    all folowing spaces from an expression               }
{---------------------------------------------------------}

PROCEDURE Tfp_skip(p : tfp_state_ptr);

BEGIN
  WITH p^ DO
    REPEAT
      Tfp_newchar(p);
    UNTIL (tfp_nextchar<>' ');
END; {of Tfp_Skip}

{---------------------------------------------------------}
{----This Routine does some trivial check &               }
{    Inits Tfp_State_Ptr^                                   }
{---------------------------------------------------------}

PROCEDURE Tfp_check(s : STRING;p : tfp_state_ptr);

VAR
  i,j        : INTEGER;

BEGIN
  WITH p^ DO
    BEGIN
       tfp_lp:=0;

    {----Test for match on numbers of ( and ) }
      j:=0;
      FOR i:=1 TO Length(s) DO
        CASE s[i] OF
          '(' : Inc(j);
          ')' : Dec(j);
        END;

      IF (j=0)
        THEN
        {----Continue init}
          BEGIN
          {----Add a CHR(0) as an EOLN marker}
            tfp_line:=s+#00;
            Tfp_skip(p);

          {----Try parsing if any characters left}
            IF (tfp_line[tfp_lp]=#00) THEN Tfp_seternr(6);
          END
      ELSE Tfp_seternr(3);
    END;
END; {of Tfp_Check}

{---------------------------------------------------------}
{  Number     = Real    (Bv 23.4E-5)                      }
{               Integer (Bv -45)                          }
{---------------------------------------------------------}

FUNCTION Tfp_eval_number(p : tfp_state_ptr) : REAL;

VAR
  temp  : STRING;
  err   : INTEGER;
  value : REAL;

BEGIN
  WITH p^ DO
    BEGIN
    {----Correct .xx to 0.xx}
      IF (tfp_nextchar='.')
        THEN temp:='0'+tfp_nextchar
        ELSE temp:=tfp_nextchar;

      Tfp_newchar(p);

    {----Correct ±.xx to ±0.xx}
      IF (Length(temp)=1) AND
         (temp[1] IN ['+','-']) AND
         (tfp_nextchar='.')
        THEN temp:=temp+'0';

      WHILE tfp_nextchar IN ['0'..'9','.','E'] DO
        BEGIN
          temp:=temp+tfp_nextchar;
          IF (tfp_nextchar='E')
            THEN
              BEGIN
              {----Correct ±xxx.E to ±xxx.0E}
                IF (temp[Length(temp)-1]='.')
                  THEN Insert('0',temp,Length(temp));
                Tfp_newchar(p);
                IF (tfp_nextchar IN ['+','-'])
                  THEN
                    BEGIN
                      temp:=temp+tfp_nextchar;
                      Tfp_newchar(p);
                    END;
              END
            ELSE Tfp_newchar(p);
        END;

    {----Skip trailing spaces}
      IF (tfp_nextchar=' ')
        THEN Tfp_skip(p);

    {----Correct ±xx. to ±xx.0 but NOT ±xxE±yy.}
      IF (temp[Length(temp)]='.') AND
         (Pos('E',temp)=0)
        THEN temp:=temp+'0';

      Val(temp,value,err);

      IF (err<>0) THEN Tfp_seternr(1);
    END;

  IF (tfp_ernr=0)
    THEN Tfp_eval_number:=value
    ELSE Tfp_eval_number:=0;

END; {of Tfp_Eval_Number}

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

FUNCTION Tfp_eval_b_expr(p : tfp_state_ptr) : REAL; forward;

FUNCTION Tfp_eval_factor(p : tfp_state_ptr) : REAL;

VAR
  ferr     : BOOLEAN;
  param    : INTEGER;
  dummy    : tfp_rarray;
  value,
  dummy1,
  dummy2   : REAL;
  temp     : tfp_fname;
  e,
  i,
  index    : INTEGER;
  temps    : STRING;
  tmpstate : tfp_state_ptr;

BEGIN
  WITH p^ DO
    CASE tfp_nextchar OF
      '+' : BEGIN
              Tfp_newchar(p);
              value:=+Tfp_eval_factor(p);
            END;

      '-' : BEGIN
              Tfp_newchar(p);
              value:=-Tfp_eval_factor(p);
            END;

      '0'..
      '9',
      '.' : value:=Tfp_eval_number(p);

      'A'..
      'Z' : BEGIN
              ferr:=true;
              temp:=tfp_nextchar;
              Tfp_skip(p);
              WHILE tfp_nextchar IN ['0'..'9','_','A'..'Z'] DO
                BEGIN
                  temp:=temp+tfp_nextchar;
                  Tfp_skip(p);
                END;

            {----Seek function and CALL it}
              {$R-}
              FOR index:=1 TO fiesiz DO
                WITH fiearr^[index] DO
                  IF (tfp_fname=temp) THEN
                    BEGIN
                      ferr:=false;

                      CASE tfp_ftype OF

                      {----Function or Function()}
                        tfp_noparm : IF (tfp_nextchar='(')
                                       THEN
                                         BEGIN
                                           Tfp_skip(p);

                                           IF (tfp_nextchar<>')')
                                             THEN Tfp_seternr(14);

                                           Tfp_skip(p);
                                         END;

                      {----Function(r)}
                        tfp_1real  : IF (tfp_nextchar='(')
                                       THEN
                                         BEGIN
                                           Tfp_skip(p);

                                           dummy1:=Tfp_eval_b_expr(p);

                                           IF (tfp_ernr=0) AND
                                              (tfp_nextchar<>')')
                                             THEN Tfp_seternr(14);

                                           Tfp_skip(p); {----Dump the ')'}
                                         END
                                       ELSE Tfp_seternr(14);

                      {----Function(r1,r2)}
                        tfp_2real  : IF (tfp_nextchar='(')
                                       THEN
                                         BEGIN
                                           Tfp_skip(p);

                                           dummy1:=Tfp_eval_b_expr(p);

                                           IF (tfp_ernr=0) AND
                                              (tfp_nextchar<>',')
                                             THEN Tfp_seternr(14);

                                           Tfp_skip(p); {----Dump the ','}
                                           dummy2:=Tfp_eval_b_expr(p);

                                            IF (tfp_ernr=0) AND
                                               (tfp_nextchar<>')')
                                              THEN Tfp_seternr(14);

                                            Tfp_skip(p); {----Dump the ')'}
                                          END
                                        ELSE Tfp_seternr(14);

                      {----Function(r,n)}
                        tfp_nreal : IF (tfp_nextchar='(')
                                      THEN
                                        BEGIN
                                          param:=0;

                                          Tfp_skip(p);
                                          dummy[param]:=Tfp_eval_b_expr(p);

                                          IF (tfp_ernr=0) AND
                                             (tfp_nextchar<>',')
                                            THEN Tfp_seternr(14)
                                            ELSE
                                              WHILE (tfp_ernr=0) AND
                                                    (tfp_nextchar=',') AND
                                                    (param<tfp_maxparm-1) DO
                                                BEGIN
                                                  Tfp_skip(p); {----Dump the ','}
                                                  Inc(param);
                                                  dummy[param]:=Tfp_eval_b_expr(p);
                                                END;

                                          IF (tfp_ernr=0) AND
                                             (tfp_nextchar<>')')
                                            THEN Tfp_seternr(14);

                                          Tfp_skip(p); {----Dump the ')'}
                                        END
                                      ELSE Tfp_seternr(14);

                      {----Real Var}
                        tfp_realvar : dummy1:=REAL(tfp_faddr^);

                      {----Integer Var}
                        tfp_intvar  : dummy1:=1.0*INTEGER(tfp_faddr^);

                      {----Boolean Var}
                        tfp_boolvar : dummy1:=1.0*Ord(BOOLEAN(tfp_faddr^));

                      {----Real string Var}
                        tfp_strvar  : BEGIN
                                        temps:=STRING(tfp_faddr^);
                                        IF (Maxavail>=Sizeof(tfp_parse_state))
                                          THEN
                                            BEGIN
                                              New(tmpstate);
                                              Tfp_check(temps,tmpstate);
                                              dummy1:=Tfp_eval_b_expr(tmpstate);
                                              Dispose(tmpstate);
                                            END
                                          ELSE Tfp_seternr(15);
                                      END;
                      END;

                      IF (tfp_ernr=0)
                        THEN
                          BEGIN
                            glueptr:=tfp_faddr;

                            CASE tfp_ftype OF
                              tfp_noparm  : value:=Tfp_call_noparm;
                              tfp_1real   : value:=Tfp_call_1real(dummy1);
                              tfp_2real   : value:=Tfp_call_2real(dummy1,dummy2);
                              tfp_nreal   : value:=Tfp_call_nreal(dummy,param);
                              tfp_realvar,
                              tfp_intvar,
                              tfp_boolvar,
                              tfp_strvar  : value:=dummy1;
                            END;
                          END;
                    END;
              {$R+}

              IF (ferr=true)
                THEN Tfp_seternr(2);
            END;

      '(' : BEGIN
              Tfp_skip(p);

              value:=Tfp_eval_b_expr(p);

              IF (tfp_ernr=0) AND
                 (tfp_nextchar<>')')
                THEN Tfp_seternr(3);

              Tfp_skip(p); {----Dump the ')'}
            END;

    ELSE Tfp_seternr(2);
    END;

  IF (tfp_ernr=0)
    THEN Tfp_eval_factor:=value
    ELSE Tfp_eval_factor:=0;

END; {of Tfp_Eval_factor}

{---------------------------------------------------------}
{  Term       = Factor ^ Factor                           }
{---------------------------------------------------------}

FUNCTION Tfp_eval_term(p : tfp_state_ptr) : REAL;

VAR
  value,
  exponent,
  dummy,
  base      : REAL;

BEGIN
  WITH p^ DO
    BEGIN
      value:=Tfp_eval_factor(p);

      WHILE (tfp_ernr=0) AND (tfp_nextchar='^') DO
        BEGIN
          Tfp_skip(p);

          exponent:=Tfp_eval_factor(p);

          base:=value;
          IF (tfp_ernr=0) AND (base=0)
            THEN value:=0
            ELSE
              BEGIN

              {----Over/Underflow Protected}
                dummy:=exponent*Ln(Abs(base));
                IF (dummy<=Ln(tfp_maxreal))
                   THEN value:=Exp(dummy)
                   ELSE Tfp_seternr(11);
              END;

          IF (tfp_ernr=0) AND (base<0)
            THEN
              BEGIN
              {----Allow only whole number exponents,
                   others will result in complex numbers}
                IF (Int(exponent)<>exponent)
                  THEN Tfp_seternr(4);

                IF (tfp_ernr=0) AND Odd(Tfp_round(exponent))
                  THEN value:=-value;
              END;
        END;
    END;

  IF (tfp_ernr=0)
    THEN Tfp_eval_term:=value
    ELSE Tfp_eval_term:=0;

END; {of Tfp_Eval_term}

{---------------------------------------------------------}
{----Subterm  = Term * Term                               }
{               Term / Term                               }
{---------------------------------------------------------}

FUNCTION Tfp_eval_subterm(p : tfp_state_ptr) : REAL;

VAR
  value,
  dummy  : REAL;

BEGIN
  WITH p^ DO
    BEGIN
      value:=Tfp_eval_term(p);

      WHILE (tfp_ernr=0) AND (tfp_nextchar IN ['*','/']) DO
        CASE tfp_nextchar OF

        {----Over/Underflow Protected}
          '*' : BEGIN
                  Tfp_skip(p);

                  dummy:=Tfp_eval_term(p);

                  IF (tfp_ernr<>0) OR
                     (value=0)     OR
                     (dummy=0)
                    THEN value:=0
                    ELSE
                      IF (Abs( Ln(Abs(value)) +
                          Ln(Abs(dummy)) ) < Ln(tfp_maxreal))
                        THEN value:= value * dummy
                        ELSE Tfp_seternr(11);
                END;

        {----Over/Underflow Protected}
          '/' : BEGIN
                  Tfp_skip(p);

                  dummy:=Tfp_eval_term(p);

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
                                  BEGIN
                                    IF (Abs( Ln(Abs(value)) -
                                        Ln(Abs(dummy)) ) < Ln(tfp_maxreal))
                                      THEN value:=value/dummy
                                      ELSE Tfp_seternr(11)
                                  END
                                ELSE value:=0;
                            END
                          ELSE Tfp_seternr(9);
                      END;
                END;
        END;
    END;

  IF (tfp_ernr=0)
    THEN Tfp_eval_subterm:=value
    ELSE Tfp_eval_subterm:=0;
END;{of Tfp_Eval_subterm}

{---------------------------------------------------------}
{  Real Expr  = Subterm + Subterm                         }
{               Subterm - Subterm                         }
{---------------------------------------------------------}

FUNCTION Tfp_eval_r_expr(p : tfp_state_ptr) : REAL;

VAR
  dummy,
  dummy2,
  value : REAL;

BEGIN
  WITH p^ DO
    BEGIN
      value:=Tfp_eval_subterm(p);

      WHILE (tfp_ernr=0) AND (tfp_nextchar IN ['+','-']) DO
        CASE tfp_nextchar OF

          '+' : BEGIN
                  Tfp_skip(p);

                  dummy:=Tfp_eval_subterm(p);

                  IF (tfp_ernr=0)
                    THEN
                      BEGIN

                      {----Overflow Protected}
                        IF (Abs( (value/10) + (dummy/10) ) < (tfp_maxreal/10))
                          THEN value:=value+dummy
                          ELSE Tfp_seternr(11);
                      END;
                END;

          '-' : BEGIN
                  Tfp_skip(p);
                  dummy2:=value;

                  dummy:=Tfp_eval_subterm(p);

                  IF (tfp_ernr=0)
                    THEN
                      BEGIN

                      {----Overflow Protected}
                        IF (Abs( (value/10) - (dummy/10) )<(tfp_maxreal/10))
                          THEN value:=value-dummy
                          ELSE Tfp_seternr(11);

                      {----Underflow Protected}
                        IF (value=0) AND (dummy<>dummy2)
                          THEN Tfp_seternr(11);
                      END;
                END;
        END;

    {----at this point the current char must be }
    {       1. the eoln marker or               }
    {       2. a right bracket                  }
    {       3. start of a boolean operator      }

      IF NOT (tfp_nextchar IN [#00,')','>','<','=',','])
        THEN Tfp_seternr(2);
    END;

  IF (tfp_ernr=0)
    THEN Tfp_eval_r_expr:=value
    ELSE Tfp_eval_r_expr:=0;
END; {of Tfp_Eval_R_Expr}

{---------------------------------------------------------}
{  Boolean Expr  = R_Expr <  R_Expr                       }
{                  R_Expr <= R_Expr                       }
{                  R_Expr <> R_Expr                       }
{                  R_Expr =  R_Expr                       }
{                  R_Expr >= R_Expr                       }
{                  R_Expr >  R_Expr                       }
{---------------------------------------------------------}

FUNCTION Tfp_eval_b_expr(p : tfp_state_ptr) : REAL;

VAR
  value : REAL;

BEGIN
  WITH p^ DO
    BEGIN
      value:=Tfp_eval_r_expr(p);

      IF (tfp_ernr=0) AND (tfp_nextchar IN ['<','>','=']) THEN
        CASE tfp_nextchar OF

          '<' : BEGIN
                  Tfp_skip(p);
                  IF (tfp_nextchar IN ['>','='])
                    THEN
                      CASE tfp_nextchar OF
                        '>' : BEGIN
                                Tfp_skip(p);
                                IF (value<>Tfp_eval_r_expr(p))
                                  THEN value:=tfp_true
                                  ELSE value:=tfp_false;
                              END;

                        '=' : BEGIN
                                Tfp_skip(p);
                                IF (value<=Tfp_eval_r_expr(p))
                                  THEN value:=tfp_true
                                  ELSE value:=tfp_false;
                              END;
                      END
                      ELSE
                        BEGIN
                          IF (value<Tfp_eval_r_expr(p))
                            THEN value:=tfp_true
                            ELSE value:=tfp_false;
                        END;
                END;

          '>' : BEGIN
                  Tfp_skip(p);
                  IF (tfp_nextchar='=')
                    THEN
                      BEGIN
                        Tfp_skip(p);
                        IF (value>=Tfp_eval_r_expr(p))
                          THEN value:=tfp_true
                          ELSE value:=tfp_false;
                      END
                    ELSE
                      BEGIN
                        IF (value>Tfp_eval_r_expr(p))
                          THEN value:=tfp_true
                          ELSE value:=tfp_false;
                      END;
                END;

          '=' : BEGIN
                  Tfp_skip(p);
                  IF (value=Tfp_eval_r_expr(p))
                    THEN value:=tfp_true
                    ELSE value:=tfp_false;
                END;
        END;
    END;

  IF (tfp_ernr=0)
    THEN Tfp_eval_b_expr:=value
    ELSE Tfp_eval_b_expr:=0.0;
END; {of Tfp_Eval_B_Expr}

{---------------------------------------------------------}

FUNCTION Tfp_parse2real(s : STRING): REAL;

VAR
  value   : REAL;

BEGIN
  tfp_erpos:=0;
  tfp_ernr :=0;

  IF Maxavail>=Sizeof(tfp_parse_state)
    THEN
      BEGIN
        New(p);
        Tfp_check(s,p);

        IF (tfp_ernr=0)
          THEN value:=Tfp_eval_b_expr(p);

        Dispose(p);
      END
    ELSE Tfp_seternr(15);

  IF (tfp_ernr<>0)
    THEN Tfp_parse2real:=0.0
    ELSE Tfp_parse2real:=value;

END; {of Tfp_Parse2Real}

{---------------------------------------------------------}

FUNCTION Tfp_parse2str(s : STRING;m,n : INTEGER) : STRING;

VAR
  r   : REAL;
  tmp : STRING;

BEGIN
  r:=Tfp_parse2real(s);
  IF (tfp_ernr=0)
    THEN Str(r:m:n,tmp)
    ELSE tmp:='';
  Tfp_parse2str:=tmp;
END; {of Tfp_Parse2str}

{---------------------------------------------------------}

FUNCTION Tfp_errormsg(nr : INTEGER) : STRING;

BEGIN
  CASE nr OF
    0 : Tfp_errormsg:='Result ok';                                  {Error 0 }
    1 : Tfp_errormsg:='Invalid format of a number';                 {Error 1 }
    2 : Tfp_errormsg:='Unkown function';                            {Error 2 }
    3 : Tfp_errormsg:='( ) mismatch';                               {Error 3 }
    4 : Tfp_errormsg:='Real exponent -> complex number';            {Error 4 }
    5 : Tfp_errormsg:='TAN( (2n+1)*PI/2 ) not defined';             {Error 5 }
    6 : Tfp_errormsg:='Empty string';                               {Error 6 }
    7 : Tfp_errormsg:='LN(x) or LOG(x) for x<=0 -> complex number'; {Error 7 }
    8 : Tfp_errormsg:='SQRT(x) for x<0 -> complex number';          {Error 8 }
    9 : Tfp_errormsg:='Divide by zero';                             {Error 9 }
   10 : Tfp_errormsg:='To many function or constants';              {Error 10}
   11 : Tfp_errormsg:='Intermediate result out of range';           {Error 11}
   12 : Tfp_errormsg:='Illegal characters in functionname';         {Error 12}
   13 : Tfp_errormsg:='Not a boolean expression';                   {Error 13}
   14 : Tfp_errormsg:='Wrong number of parameters';                 {Error 14}
   15 : Tfp_errormsg:='Memory problems';                            {Error 15}
   16 : Tfp_errormsg:='Not enough functions or constants';          {Error 16}
   17 : Tfp_errormsg:='Csc( n*PI ) not defined';                    {Error 17}
   18 : Tfp_errormsg:='Sec( (2n+1)*PI/2 ) not defined';             {Error 18}
   19 : Tfp_errormsg:='Cot( n*PI ) not defined';                    {Error 19}
   20 : Tfp_errormsg:='Parameter to large';                         {Error 20}
   21 : Tfp_errormsg:='Csch(0) not defined';                        {Error 21}
   22 : Tfp_errormsg:='Coth(0) not defined';                        {Error 22}
   23 : Tfp_errormsg:='ArcCosh(x) not defined for x<1';             {Error 23}
   24 : Tfp_errormsg:='ArcTanh(x) not defined for Abs(x)=>1';       {Error 24}
   25 : Tfp_errormsg:='Arccsch(0) not defined';                     {Error 25}
   26 : Tfp_errormsg:='Arcsech(x) not defined for x<=0 or x>1';     {Error 26}
   27 : Tfp_errormsg:='Arccoth(x) not defined for Abs(x)<=1';       {Error 27}
  ELSE  Tfp_errormsg:='Unkown error';                               {Error xx}
  END;
END; {of Tfp_ermsg}

{---------------------------------------------------------}

PROCEDURE Tfp_init(no : WORD);

BEGIN
  IF (maxfie>0)
    THEN Freemem(fiearr,maxfie*Sizeof(tfp_fie_typ));

  maxfie:=0;
  fiesiz:=0;

  IF (Maxavail>=(no*Sizeof(tfp_fie_typ))) AND (no>0)
    THEN
      BEGIN
        getmem(fiearr,no*Sizeof(tfp_fie_typ));
        maxfie:=no;
      END
    ELSE Tfp_seternr(15);
END; {of Tfp_Init}

{---------------------------------------------------------}

PROCEDURE Tfp_expand(no : WORD);

VAR
  temp : ^tfp_fieptr;

BEGIN
  IF (maxfie>0) AND (no>0)
    THEN
      BEGIN
        IF (Maxavail>=(maxfie+no)*Sizeof(tfp_fie_typ))
          THEN
            BEGIN
              getmem(temp,(maxfie+no)*Sizeof(tfp_fie_typ));
              Move(fiearr^,temp^,maxfie*Sizeof(tfp_fie_typ));
              Freemem(fiearr,maxfie*Sizeof(tfp_fie_typ));
              fiearr:=POINTER(temp);
              maxfie:=maxfie+no;
              fiesiz:=fiesiz;
            END
          ELSE Tfp_seternr(15)
      END
    ELSE Tfp_init(no);
END; {of Tfp_Expand}

{---------------------------------------------------------}

PROCEDURE Tfp_keep(no : WORD);

BEGIN
  IF (maxfie<no)
    THEN Tfp_seternr(16)
    ELSE maxfie:=no;
END; {of Tfp_Keep}

{---------------------------------------------------------}

FUNCTION Tfp_noobj : WORD;

BEGIN
  Tfp_noobj:=maxfie;
END; {of Tfp_Noobj}

{---------------------------------------------------------}

PROCEDURE Tfp_addobj(adres : POINTER;name : tfp_fname;ftype : tfp_ftype);

VAR
  i : INTEGER;

BEGIN
{$R-}
  IF (fiesiz<maxfie)
    THEN
      BEGIN
        Inc(fiesiz);
        WITH fiearr^[fiesiz] DO
          BEGIN
            tfp_faddr:=adres;
            tfp_fname:=name;
            FOR i:=1 TO Length(tfp_fname) DO
              IF (Upcase(tfp_fname[i]) IN ['0'..'9','_','A'..'Z'])
                THEN tfp_fname[i]:=Upcase(tfp_fname[i])
                ELSE Tfp_seternr(12);

            IF (Length(tfp_fname)>0) AND
               NOT (tfp_fname[1] IN ['A'..'Z'])
              THEN Tfp_seternr(12);

            tfp_ftype:=ftype;
          END
      END
    ELSE Tfp_seternr(10);
{$R+}
END; {of Tfp_Addobject}

{---------------------------------------------------------}
{----Internal Functions                                   }
{---------------------------------------------------------}

{$F+}

FUNCTION Xabs(VAR r : REAL) : REAL;

BEGIN
  Xabs:=Abs(r);
END; {of xABS}

{---------------------------------------------------------}

FUNCTION Xand(VAR lu_r;VAR n : INTEGER) : REAL;

VAR
  r  : REAL;
  i  : INTEGER;

BEGIN
  FOR i:=0 TO n DO
    IF (tfp_rarray(lu_r)[i]<>tfp_false) AND
       (tfp_rarray(lu_r)[i]<>tfp_true)
      THEN
        BEGIN
          IF (tfp_ernr=0)
            THEN Tfp_seternr(13);
        END;

  IF (tfp_ernr=0) AND (n>0)
    THEN
      BEGIN
        r:=tfp_true*Ord(tfp_rarray(lu_r)[0]=tfp_true);
        FOR i:=1 TO n DO
          r:=tfp_true*Ord( (r=tfp_true) AND (tfp_rarray(lu_r)[i]=tfp_true))
      END
    ELSE Tfp_seternr(14);

  IF tfp_ernr=0
    THEN Xand:=r
    ELSE Xand:=0.0;
END; {of xAND}

{---------------------------------------------------------}

FUNCTION Xarctan(VAR r : REAL) : REAL;

BEGIN
  Xarctan:=Arctan(r);
END; {of xArctan}

{---------------------------------------------------------}

FUNCTION Xcos(VAR r : REAL) : REAL;

BEGIN
  Xcos:=Cos(r);
END; {of xCos}

{---------------------------------------------------------}

FUNCTION Xdeg(VAR r : REAL) : REAL;

BEGIN
  Xdeg:=(r/pi)*180;
END; {of xDEG}

{---------------------------------------------------------}

FUNCTION Xe : REAL;

BEGIN
  Xe:=Exp(1);
END; {of xE}

{---------------------------------------------------------}

FUNCTION Xexp(VAR r : REAL) : REAL;

BEGIN
  Xexp:=0;
  IF (Abs(r)<Ln(tfp_maxreal))
    THEN Xexp:=Exp(r)
    ELSE Tfp_seternr(11);
END; {of xExp}

{---------------------------------------------------------}

FUNCTION Xfalse : REAL;

BEGIN
  Xfalse:=tfp_false;
END; {of xFalse}

{---------------------------------------------------------}

FUNCTION Xfrac(VAR r : REAL) : REAL;

BEGIN
  Xfrac:=Frac(r);
END; {of xFrac}

{---------------------------------------------------------}

FUNCTION Xint(VAR r : REAL) : REAL;

BEGIN
  Xint:=Int(r);
END; {of xInt}

{---------------------------------------------------------}

FUNCTION Xln(VAR r : REAL) : REAL;

BEGIN
  Xln:=0;
  IF (r>0)
    THEN Xln:=Ln(r)
    ELSE Tfp_seternr(7);
END; {of xLn}

{---------------------------------------------------------}

FUNCTION Xlog(VAR r : REAL) : REAL;

BEGIN
  Xlog:=0;
  IF (r>0)
    THEN Xlog:=Ln(r)/ln(10)
    ELSE Tfp_seternr(7);
END; {of xLog}

{---------------------------------------------------------}

FUNCTION Xmax(VAR lu_r;VAR n : INTEGER) : REAL;

VAR
  max   : REAL;
  i        : INTEGER;

BEGIN
  max:=tfp_rarray(lu_r)[0];
  FOR i:=1 TO n DO
    IF (tfp_rarray(lu_r)[i]>max)
      THEN max:=tfp_rarray(lu_r)[i];
  Xmax:=max;
END; {of xMax}

{---------------------------------------------------------}

FUNCTION Xmin(VAR lu_r;VAR n : INTEGER) : REAL;

VAR
  min   : REAL;
  i     : INTEGER;

BEGIN
  min:=tfp_rarray(lu_r)[0];
  FOR i:=1 TO n DO
    IF (tfp_rarray(lu_r)[i]<min)
      THEN min:=tfp_rarray(lu_r)[i];
  Xmin:=min;
END; {of xMin}

{---------------------------------------------------------}

FUNCTION Xior(VAR lu_r;VAR n : INTEGER) : REAL;

VAR
  r : REAL;
  i : INTEGER;

BEGIN
  FOR i:=0 TO n DO
    IF (tfp_rarray(lu_r)[i]<>tfp_false) AND
       (tfp_rarray(lu_r)[i]<>tfp_true)
      THEN
        BEGIN
          IF (tfp_ernr=0)
            THEN Tfp_seternr(13);
        END;

  IF (tfp_ernr=0) AND
     (n>0)
    THEN
      BEGIN
        r:=tfp_true*Ord(tfp_rarray(lu_r)[0]=tfp_true);
        FOR i:=1 TO n DO
          r:=tfp_true*Ord((r=tfp_true) OR (tfp_rarray(lu_r)[i]=tfp_true))
      END
    ELSE Tfp_seternr(14);

  IF tfp_ernr=0
    THEN Xior:=r
    ELSE Xior:=Tfp_false;
END; {of xIor}

{---------------------------------------------------------}

FUNCTION Xpi : REAL;

BEGIN
  Xpi:=Pi;
END; {of xPi}

{---------------------------------------------------------}

FUNCTION Xrad(VAR r : REAL) : REAL;

BEGIN
  Xrad:=(r/180)*Pi;
END; {of xRad}

{---------------------------------------------------------}

FUNCTION Xround(VAR r : REAL) : REAL;

BEGIN
  IF (Abs(r)<tfp_maxlongint)
    THEN Xround:=Tfp_round(r)
    ELSE Xround:=r;
END; {of xRound}

{---------------------------------------------------------}

FUNCTION Xsgn(VAR r : REAL) : REAL;

BEGIN
  IF (r>=0)
    THEN Xsgn:=+1
    ELSE Xsgn:=-1;
END; {of xSgn}

{---------------------------------------------------------}

FUNCTION Xsin(VAR r : REAL) : REAL;

BEGIN
  Xsin:=Sin(r);
END; {of xSin}

{---------------------------------------------------------}

FUNCTION Xsqr(VAR r : REAL) : REAL;

BEGIN
  Xsqr:=0;
  IF (Abs(r)>0)
    THEN
      BEGIN
        IF ( Abs(2*Ln(Abs(r))) )<Ln(tfp_maxreal)
          THEN Xsqr:=Exp( 2*Ln(Abs(r)) )
          ELSE Tfp_seternr(11);
      END;
END; {of xSqr}

{---------------------------------------------------------}

FUNCTION Xsqrt(VAR r : REAL) : REAL;

BEGIN
  Xsqrt:=0;
  IF (r>=0)
    THEN Xsqrt:=Sqrt(r)
    ELSE Tfp_seternr(8);
END; {of xSqrt}

{---------------------------------------------------------}

FUNCTION Xtan(VAR r : REAL) : REAL;

BEGIN
  Xtan:=0;
  IF (Cos(r)=0)
    THEN Tfp_seternr(5)
    ELSE Xtan:=Sin(r)/cos(r);
END; {of xTan}

{---------------------------------------------------------}

FUNCTION Xtrue : REAL;

BEGIN
  Xtrue:=tfp_true;
END; {of xTrue}

{---------------------------------------------------------}

FUNCTION Xxor(VAR r1,r2 : REAL) : REAL;

BEGIN
 Xxor:=tfp_false;
 IF ((r1<>tfp_false) AND (r1<>tfp_true)) OR
    ((r2<>tfp_false) AND (r2<>tfp_true))
   THEN
     BEGIN
       IF (tfp_ernr=0)
         THEN Tfp_seternr(13);
     END
   ELSE Xxor:=tfp_true*Ord((r1=tfp_true) XOR (r2=tfp_true));
END; {of xXOR}

{---------------------------------------------------------}
{----Hyperbolic, reciproce and inverse goniometric        }
{    functions                                            }
{---------------------------------------------------------}

Function xCsc(VAR r: Real): Real;

Begin;
  xCsc:=0;
  IF (Sin(r)=0)
    THEN Tfp_seternr(17)
    ELSE xCsc:=1/Sin(r);
End; {xCsc}

{---------------------------------------------------------}

Function xSec(VAR r: Real): Real;

Begin;
  xSec:=0;
  IF (Cos(r)=0)
    THEN Tfp_seternr(18)
    ELSE xSec:=1/Cos(r);
End; {xSec}

{---------------------------------------------------------}

Function xCot(VAR r : Real): Real;

Begin;
  xCot:=0;
  IF (Sin(r)=0)
    THEN Tfp_seternr(19)
    ELSE xCot:=Cos(r)/Sin(r);
End; {xCot}

{---------------------------------------------------------}

FUNCTION xCosh(VAR r : REAL) : REAL;

BEGIN
  xCosh:=0;
  IF (Abs(r)>Ln(tfp_maxreal))
    THEN Tfp_seternr(20)
    ELSE xCosh:=(Exp(r)+Exp(-r))/2;
END; {of xCosh}

{---------------------------------------------------------}

FUNCTION xSinh(VAR r : REAL) : REAL;

BEGIN
  xSinh:=0;
  IF (Abs(r)>Ln(tfp_maxreal))
    THEN Tfp_seternr(20)
    ELSE xSinh:=(Exp(r)-Exp(-r))/2;
END;  {of xSinh}

{---------------------------------------------------------}

FUNCTION xTanh(VAR r : REAL) : REAL;

BEGIN
  xTanh:=0;
  IF (Abs(r)>Ln(tfp_maxreal))
    THEN Tfp_seternr(20)
    ELSE xTanh:=(Exp(r)-Exp(-r))/(Exp(r)+Exp(-r));
END; {of xTanh}

{---------------------------------------------------------}

FUNCTION xCsch(VAR r : REAL) : REAL;

BEGIN
  xCsch:=0;
  IF (Abs(r)>Ln(tfp_maxreal))
    THEN Tfp_seternr(20)
    ELSE
      BEGIN
        IF (r=0)
          THEN Tfp_seternr(21)
          ELSE xCsch:=2/(Exp(r)-Exp(-r))
      END;
END; {of xCsch}

{---------------------------------------------------------}

FUNCTION xSech(VAR r : REAL) : REAL;

BEGIN
  xSech:=0;
  IF (Abs(r)>Ln(tfp_maxreal))
    THEN Tfp_seternr(20)
    ELSE xSech:=2/(Exp(r)+Exp(-r));
END; {of xSech}

{---------------------------------------------------------}

FUNCTION xCoth(VAR r : REAL) : REAL;

BEGIN
  xCoth:=0;
  IF (Abs(r)>Ln(tfp_maxreal))
    THEN Tfp_seternr(20)
    ELSE
      BEGIN
        IF (r=0)
          THEN Tfp_seternr(22)
          ELSE xCoth:=(Exp(r)+Exp(-r))/(Exp(r)-Exp(-r))
      END;
END; {of xCoth}

{---------------------------------------------------------}

FUNCTION xArcsinh(VAR r : REAL) : REAL;

BEGIN
  xArcsinh:=0;
  IF (Abs(r)<SQRT(tfp_maxreal))
    THEN xArcsinh:=Ln(r+Sqrt(Sqr(r)+1))
    ELSE Tfp_seternr(20)
END; {of xArcsinh}

{---------------------------------------------------------}

FUNCTION xArccosh(VAR r : REAL) : REAL;

BEGIN
  xArccosh:=0;
  IF (Abs(r)<SQRT(tfp_maxreal))
    THEN
      BEGIN
        IF (r>=1)
          THEN xArccosh:=ln(r+Sqrt(Sqr(r)-1))
          ELSE Tfp_seternr(23);
      END
    ELSE Tfp_seternr(20)
END; {of xArccosh}

{---------------------------------------------------------}

FUNCTION xArctanh(VAR r : REAL) : REAL;

BEGIN
  xArctanh:=0;
  IF (Abs(r)<1)
    THEN xArctanh:=ln( (1+r)/(1-r) )/2
    ELSE Tfp_seternr(24)
END; {of xArctanh}

{---------------------------------------------------------}

FUNCTION xArccsch(VAR r : REAL) : REAL;

BEGIN
  xArccsch:=0;
  IF (r<SQRT(Tfp_maxreal))
    THEN
      BEGIN
        IF (r<>0)
          THEN xArccsch:=Ln( (1/r) + SQRT( (1/SQR(r))+1))
          ELSE Tfp_seternr(25)
      END
    ELSE Tfp_seternr(20);
END; {of xArccsch}

{---------------------------------------------------------}

FUNCTION xArcsech(VAR r : REAL) : REAL;

BEGIN
  xArcsech:=0;
  IF (r<SQRT(Tfp_maxreal))
    THEN
      BEGIN
        IF (r>0) AND (r<=1)
          THEN xArcsech:=Ln( (1/r) + SQRT( (1/SQR(r))-1))
          ELSE Tfp_seternr(26)
      END
    ELSE Tfp_seternr(20)
END; {of xArcsech}

{---------------------------------------------------------}

FUNCTION xArccoth(VAR r : REAL) : REAL;

BEGIN
  xArccoth:=0;
  IF (Abs(r)>1)
    THEN xArccoth:=Ln( (r+1)/(r-1) )/2
    ELSE Tfp_seternr(27)
END; {of xArccoth}

{$F-}

{---------------------------------------------------------}

PROCEDURE Tfp_addgonio;

BEGIN
  Tfp_expand(7);
  Tfp_addobj(@xarctan,'ARCTAN',tfp_1real);
  Tfp_addobj(@xcos   ,'COS'   ,tfp_1real);
  Tfp_addobj(@xdeg   ,'DEG'   ,tfp_1real);
  Tfp_addobj(@xpi    ,'PI'    ,tfp_noparm);
  Tfp_addobj(@xrad   ,'RAD'   ,tfp_1real);
  Tfp_addobj(@xsin   ,'SIN'   ,tfp_1real);
  Tfp_addobj(@xtan   ,'TAN'   ,tfp_1real);
END; {of Tfp_Addgonio}

{---------------------------------------------------------}

PROCEDURE Tfp_addlogic;

BEGIN
  Tfp_expand(5);
  Tfp_addobj(@xand      ,'AND'   ,tfp_nreal);
  Tfp_addobj(@xfalse    ,'FALSE' ,tfp_noparm);
  Tfp_addobj(@xior      ,'OR'    ,tfp_nreal);
  Tfp_addobj(@xtrue     ,'TRUE'  ,tfp_noparm);
  Tfp_addobj(@xxor      ,'XOR'   ,tfp_2real);
END; {of Tfp_Addlogic}

{---------------------------------------------------------}

PROCEDURE Tfp_addmath;

BEGIN
  Tfp_expand(7);
  Tfp_addobj(@xabs   ,'ABS'   ,tfp_1real);
  Tfp_addobj(@xexp   ,'EXP'   ,tfp_1real);
  Tfp_addobj(@xe     ,'E'     ,tfp_noparm);
  Tfp_addobj(@xln    ,'LN'    ,tfp_1real);
  Tfp_addobj(@xlog   ,'LOG'   ,tfp_1real);
  Tfp_addobj(@xsqr   ,'SQR'   ,tfp_1real);
  Tfp_addobj(@xsqrt  ,'SQRT'  ,tfp_1real);
END; {of Tfp_Addmath}

{---------------------------------------------------------}

PROCEDURE Tfp_addmisc;

BEGIN
  Tfp_expand(6);
  Tfp_addobj(@xfrac  ,'FRAC'  ,tfp_1real);
  Tfp_addobj(@xint   ,'INT'   ,tfp_1real);
  Tfp_addobj(@xmax   ,'MAX'   ,tfp_nreal);
  Tfp_addobj(@xmin   ,'MIN'   ,tfp_nreal);
  Tfp_addobj(@xround ,'ROUND' ,tfp_1real);
  Tfp_addobj(@xsgn   ,'SGN'   ,tfp_1real);
END; {of Tfp_Addmisc}

{---------------------------------------------------------}

PROCEDURE Tfp_addinvarchyper;

BEGIN
  Tfp_expand(15);
  Tfp_addobj(@xcsc    ,'CSC'    ,tfp_1real);
  Tfp_addobj(@xsec    ,'SEC'    ,tfp_1real);
  Tfp_addobj(@xcot    ,'COT'    ,tfp_1real);

  Tfp_addobj(@xsinh   ,'SINH'   ,tfp_1real);
  Tfp_addobj(@xcosh   ,'COSH'   ,tfp_1real);
  Tfp_addobj(@xtanh   ,'TANH'   ,tfp_1real);

  Tfp_addobj(@xcsch   ,'CSCH'   ,tfp_1real);
  Tfp_addobj(@xsech   ,'SECH'   ,tfp_1real);
  Tfp_addobj(@xcoth   ,'COTH'   ,tfp_1real);

  Tfp_addobj(@xarcsinh,'ARCSINH',tfp_1real);
  Tfp_addobj(@xarccosh,'ARCCOSH',tfp_1real);
  Tfp_addobj(@xarctanh,'ARCTANH',tfp_1real);

  Tfp_addobj(@xarccsch,'ARCCSCH',tfp_1real);
  Tfp_addobj(@xarcsech,'ARCSECH',tfp_1real);
  Tfp_addobj(@xarccoth,'ARCCOTH',tfp_1real);
End; {of Add_invandhyper}

{---------------------------------------------------------}

PROCEDURE Tfp_addall;

BEGIN
  Tfp_addgonio;
  Tfp_addlogic;
  Tfp_addmath;
  Tfp_addmisc;
  Tfp_addinvarchyper;
END; {of Tfp_addall}

{---------------------------------------------------------}

BEGIN
{----Module Init}
  tfp_erpos :=0;
  tfp_ernr  :=0;
  fiesiz:=0;
  maxfie:=0;
  fiearr:=NIL;
END.
