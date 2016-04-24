(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0081.PAS
  Description: Getting Big Pi!
  Author: DAVID ADAMSON
  Date: 11-26-94  05:00
*)

(*                          PROGRAM PI5.PAS
                           By  David Adamson
                           October  23, 1994

This it the third version of a program for computing Pi up to 2150
places.

The first version was written in Turbo Pascal 3. The second was also
in Turbo Pascal, but with all the math procedures converted to inline
for maximum program executing speed.

This version is rewritten to allow compilation with Turbo Pascal 5 and
up.

The inline code was scrapped for version 3. The sacrifice in speed is
not a problem, because it improvement in today's computers overshadows
the processing efficiency loss.

Here are my results using a 33MHz 386.

Pi v2                               Pi v3
100  places =  0.1 sec              100  places =   0.3 sec
1000 places = 11   sec              1000 places =  32   sec
2135 places = 48   sec              2135 places = 150   sec


----------------------------------------------------------------------
THIS IS THE ORIGINAL HEADER:

                            PROGRAM PI1.PAS
                              TANDY 2000
                           BY CINO  HILLIARD
                            APRIL 6 , 1986
       ( AN IMPROVED VERSION OF MY ORIGIONAL PI.PAS IN THE  DL)

THIS PROGRAM COMPUTES THE DIGITS OF PI USING THE ARCTANGENT FORMULA

                (  TERM 1  )   (  TERM 2  )
    (1)  PI/4 = 4 ARCTAN 1/5 - ARCTAN 1/239

                                   IN CONJUNCTION WITH THE GREGORY SERIES
                     N
    (2)  ARCTAN X = SUM [ (-1)^M*(2M + 1)^-1*X^(2M+1) ]  (APPROXIMATELY)
                    M=0

SUBSTITUTING INTO (1) AND (2) THE FIRST FEW VALUES OF N, REARRANGING,
SIMPLYIFING, AND NESTING  WE HAVE,

PI= 3.2 + 1/25[-3.2/3 + 1/25[3.2/5 + 1/25[-3.2/7 + ...].].]       ( TERM 1 )
    -1/239[4 +1/239^2[-4/3 +1/239^2[4/5 +1/239^2[-4/7 +...].].]   ( TERM 2 )

USING THE LONG DIVISION ALGORITHM AND SOME TRICKS I DISCOVERED, THIS (
NESTED ) INFINITE SERIES CAN BE USED TO CALCULATE PI TO A LARGE NUMBER
OF DECIMAL PLACES IN A REASONABLE AMOUNT OF TIME.  A TIME FUNCTION IS
INCLUDED TO SHOW HOW SLOW THINGS GET WHEN N IS LARGE.

IMPROVEMENTS CAN BE MADE BY INCREASING THE NUMBER OF DIGITS EACH ARRAY
ELEMENT HOLDS AND BY CHANGING THE DATA TYPE FROM INTEGER TO REAL FOR
SELECTED VARIABLES. OF COURSE THE ADDED NUMBER OF DIGITS THESE CHANGES
PRODUCE WILL COST MUCH MUCH MORE TIME. AH INDEED, 'TIS NO FREE LUNCH!
HOWEVER, SINCE TERM 1 AND TERM 2 ARE COMPUTED SEPERATELY AND SINCE THE
ARRAYS ARE STEP BY STEP UPDATED, THE  PROGRAM DOES LEND ITSELF TO
PARALLEL OR NON VON ( WHAT A COINCIDENCE - SEE BELOW )  PROCESSING.

FOR EXAMPLE, LET COMPUTER 1 PERFORM TERM 1 AND COMPUTER 2 PERFORM
TERM 2. MOREOVER, LET SEVERAL COMPUTERS SHARE IN THE CALCULATION OF
EACH OF THE INDIVIDUAL TERMS. HOWEVER, TO KEEP EACH COMPUTER EQUALLY
BUSY, A LOGARITHMIC TYPE OF ADJUSTMENT MUST BE MADE TO DECIDE ON THE
NUMBER OF TERMS TO BE ASSIGNED TO EACH COMPUTER. SINCE THE HIGHER
POWER TERMS REQUIRE MUCH LONGER TO COMPUTE, THE COMPUTERS ASSIGNED TO
HIGHER POWERS MUST BE GIVEN  FEWER TERMS TO DO.

A LITTLE HISTORY
----------------
IN AUGUST, 1949, PROFESSOR JOHN VON NEUMANN USED FORMULAS  (1) AND (2)
TO CALCULATE PI TO 2035 DECIMAL PLACES ON THE  ENIAC  COMPUTER. THE
EFFORT WAS MADE TO DETERMINE IF THE DIGITS CONFORMED TO SOME TYPE OF
PATTERN OR IF THEY WERE RANDOMLY DISTRIBUTED. THE CALCULATION WAS
COMPLETED OVER THE LABOR DAY WEEKEND WITH THE COMBINED EFFORTS OF FOUR
ENIAC STAFF MEMBERS WORKING IN EIGHT-HOUR SHIFTS TO ENSURE CONTINUOUS
OPERATION OF THE ENIAC. THE CALCULATION (INCLUDING CARD HANDLING TIME)
TOOK APPROXIMATELY 70 HOUR.

THE CONCLUSION WAS AS SUSPECTED - THE DIGITS APPEARED TO BE RANDOM!

SOME YEARS AGO I REQUESTED INFORMATION ON PI FROM THE ENCYCLOPEDIA
BRITANNICA RESEARCH SERVICE. I RECEIVED A REPORT GIVING THE ABOVE
HISTORICAL ACCOUNT PLUS A LISTING OF THE 2035 DIGITS.

A LITTLE COMMENT
----------------
USING MY T2K, PI1.PAS COMPUTES PI TO 2035 PLACES IN  15 MIN  31.97
SEC.

GEE WHIZ!  WHAT EARTHLY USE CAN BE MADE OF THIS?  I PLAN TO MAKE
DESIGNS AND COLOR PATTERNS USING THE DIGIT VALUES AS THE BASIS. MAYBE
SOMETHING LIKE FRACTALS WOULD BE A GOOD START. THIS IS WHY COMPUTATION
AND SPEED ARE IMPORTANT AS I DO NOT WISH (NOR TRUST) TO KEY IN ENTRIES
FROM A PUBLISHED LIST.

                             CINO HILLIARD
                              [72756,672]

---------------------------------------------------------------------------
MODIFICATIONS MADE FOR VERSION 2:

ADDED INLINE CODE TO IMPROVE THE SPEED. USING THE ORIGINAL SOURCE ON
MY TANDY-1000  ( WITH A V20 CPU ) , COMPUTING PI TO 2035 PLACES RAN IN
39 MIN 44.92 SEC.. AFTER ADDING THE INLINE CODE IT RAN IN 10 MIN 25.16
SEC..

ADDED A TIME FUNCTION FROM 'TECH JOURNAL FEB 85'. THIS USES A MSDOS
INTERUPT, SO IT SHOULD RUN ON ANY MSDOS COMPATIBLE COMPUTER.

                              CHUCK WHITE
                             [75006,3677]
*)

PROGRAM PI5;
Uses DOS, CRT;

Type
  TimeString = string[12];
VAR K,I,I2,J,M,N,Q,V,R,D,Z : INTEGER;
    A,P,T : ARRAY[0..5000] OF integer;
    TI,T2 : STRING[20];


function Time: TimeString;

var
   Hour, Minute, Second, Sec100 : word;
   Hr, Min, Sec, Hun            : string[2];

begin
   gettime(Hour, Minute, Second, Sec100);
   str(Hour:2, Hr);
   str(Minute:2, Min);
   str(Second:2, Sec);
   str(Sec100:2, Hun);
   if Hr[1]  = ' ' then Hr[1]  := '0';
   if Min[1] = ' ' then Min[1] := '0';
   if Sec[1] = ' ' then Sec[1] := '0';
   if Hun[1] = ' ' then Hun[1] := '0';
   time := Hr+ ':'+ Min+ ':'+ Sec+ '.'+ Hun
end;

PROCEDURE DIV32IA;       { DIVIDE 3.2 BY I AND STORE IN ARRAY A }
 BEGIN
Q:=3 DIV I;
R:=3 MOD I;
A[0]:=Q;
V:=R*10+2;
Q:=V DIV I;
R:=V MOD I;
A[1]:=Q;
FOR J:=2 TO M DO
      BEGIN
      V:=R*10;
      Q:=V DIV I;
      R:=V MOD I;
      A[J]:=Q;
    END;
 END;

PROCEDURE DIVA(D:INTEGER); { DIVIDE A BY SPECIFIED INTEGER FROM }
 BEGIN                     { PROCEDURE COMPUTE; }
    R:=0;
    FOR J:=0 TO M DO
     BEGIN
     V:= R*10+A[J];
     Q:= V DIV D;
     R:= V MOD D;
     A[J]:=Q;
     END;
 END;

PROCEDURE DIV4IA;         { DIVIDE 4 BY I AND STORE IN A }
 BEGIN
Q:=4 DIV I;
R:=4 MOD I;
A[0]:=Q;
FOR J:=1 TO M DO
     BEGIN
     V:= R*10;
     Q:= V DIV I;
     R:= V MOD I;
     A[J]:=Q;
     END;
 END;


PROCEDURE DIV32IP;        { DIVIDE 3.2 BY I AND STORE IN P }
 BEGIN
Q:=3 DIV I;
R:=3 MOD I;
P[0]:=Q;
V:=R*10+2;
Q:=V DIV I;
R:=V MOD I;
P[1]:=Q;
   FOR J:=2 TO M DO
     BEGIN
     V:= R*10;
     Q:= V DIV I;
     R:= V MOD I;
     P[J]:=Q;
     END;
 END;


PROCEDURE DIV4IP;       { DIVIDE 4 BY I AND STORE IN P }
 BEGIN
Q:=4 DIV I;
R:=4 MOD I;
P[0]:=Q;
    FOR J:=1 TO M DO
     BEGIN
     V:= R*10;
     Q:= V DIV I;
     R:= V MOD I;
     P[J]:=Q;
     END;
 END;

PROCEDURE SUBA;         { SUBTRACT A FROM P  AND STORE IN A }
 BEGIN
   FOR J:=0 TO M DO
   A[J]:=P[J]-A[J];
END;

PROCEDURE SUB32A;        { SUBTRACT A FROM 3.2 AND STORE IN T }
 BEGIN
   T[0]:=3;
   T[1]:=1;
   FOR J:=2 TO M DO
   T[J]:=9-A[J];
 END;

PROCEDURE SUB4A;        { SUBTRACT A FROM 4 AND STORE IN A }
 BEGIN
   A[0]:=3;
   FOR J:=1 TO M DO
    A[J]:=9-A[J];
 END;

PROCEDURE SUBT;         { SUBTRACT TERM2 FROM TERM 1 AND STORE IN A }
 BEGIN
   FOR J:=M DOWNTO 1 DO
   BEGIN
    A[J]:=T[J]-A[J];
    WHILE A[J]<0 DO
     BEGIN
      A[J]:=A[J]+10;      { ADJUST FOR NEGATIVE }
      A[J-1]:=A[J-1]+1;
     END;
      WHILE A[J]>9 DO    { ADJUST A FOR EXCESS CARRY }
       BEGIN
        A[J]:=A[J]-10;
        A[J-1]:=A[J-1]-1;
       END;
   END;
 END;


PROCEDURE COMPUTE;      { COMPUTE THE NESTED  SERIES  FOR I2 ITERATIONS }
BEGIN
 I:=I2;                  { COMPUTE TERM 1 TO I2 PLACES }
  DIV32IA;
  DIVA(25);
   WHILE I>3 DO
    BEGIN
      I:=I-2;
      DIV32IP;
      SUBA;
      DIVA(25);
    END;
   SUB32A;
   I:=I2;                { COMPUTE TERM 2 TO I2 PLACES }
   DIV4IA;
   DIVA(239);
   DIVA(239);
    WHILE I>3 DO
     BEGIN
       I:=I-2;
       DIV4IP;
       SUBA;
       DIVA(239);
       DIVA(239);
     END;
       SUB4A;
       DIVA(239);
       SUBT;           { SUBTRACT TERM 2 FROM TERM 1 AND STORE IN A }
       T2:=TIME;        { SET END OF COMPUTATION TIME }
END;

PROCEDURE STORE;       { SAVE PI AND TIME TO  DISK FILES }
VAR BUFF  : FILE OF INTEGER;
        F : TEXT;
BEGIN
ASSIGN(BUFF,'PI.DTA');
ASSIGN(F,'TIME.DTA');
REWRITE(BUFF);
REWRITE(F);
FOR J:=0 TO M-2 DO
WRITE(BUFF,A[J]);

WRITE(F,TI);           {Note, does not produce an ascii readable}
WRITE(F,T2);           {output. It is for use by PILIST - code  }
                       {for PILIST is at the end after PI5}
CLOSE(BUFF);
CLOSE(F);
END;

procedure compute_time;
var
  h1,h2,m1,m2,s1,s2,hun1,hun2,code,x: integer;
  s,temp: string[11];
begin
  val(copy(ti,1,2),h1,code);
  val(copy(t2,1,2),h2,code);
  val(copy(ti,4,2),m1,code);
  val(copy(t2,4,2),m2,code);
  val(copy(ti,7,2),s1,code);
  val(copy(t2,7,2),s2,code);
  val(copy(ti,10,2),hun1,code);
  val(copy(t2,10,2),hun2,code);
  if hun2<hun1 then begin
     hun2:= hun2+100; s2:= s2-1; end;
  if s2<s1 then begin
     s2:= s2+60; m2:= m2-1; end;
  if m2<m1 then begin
     m2:= m2+60; h2:= h2-1; end;
  if h2<h1 then begin
     h2:= h2+24; end;
  str(h2-h1:2,temp);
  s:= temp+':';
  str(m2-m1:2,temp);
  s:= s+temp+':';
  str(s2-s1:2,temp);
  s:= s+temp+'.';
  str(hun2-hun1:2,temp);
  s:= s+temp;
  for x:= 1 to length(s) do
    if (s[x]=' ')and (s[x+1]='0') then begin
      s[x+1]:= ' '; s[x+2]:= ' ' end;
  writeln(s)
{  writeln(h2-h1:2,':',m2-m1:2,':',s2-s1:2,'.',hun2-hun1:2); }
end;

PROCEDURE PRINTPI;    { PRINT THE  FORMATED DIGITS OF PI }
BEGIN
   WRITE('PI=3.');
   FOR J:=1 TO N   DO
   BEGIN
WRITE(A[J]);
   IF J MOD 5 = 0 THEN WRITE(' ');
   IF J MOD 50 = 0 THEN WRITE('  ',J:4,'  PL          ');
   END;
   WRITELN;WRITELN;

   WRITELN('ENDING   TIME = ',T2);
   WRITELN('STARTING TIME = ',TI);
   write  ('TOTAL TIME    = '); compute_time;
   WRITELN;
END;


PROCEDURE HEADER;
   BEGIN
    WRITELN('                         THE COMPUTATION OF ',#227);
    WRITELN('                  Press Control-Break to exit program. ');
    WRITELN('                  ------------------------------------ ');
    WRITELN;
   END;

PROCEDURE START;               { PROMPT FOR INPUT AND INITIALIZE }
   BEGIN
     WRITELN('Input number of decimal places (Number < 2150)');
      READLN(N);
      TI:=TIME;
      M:=N+2;
      I2:=2*(3*M DIV 4)-4*TRUNC(LN(M))+5;
   END;


{MAIN PROGRAM}
LABEL 20;
BEGIN
CLRSCR;
HEADER;
20:START;
COMPUTE;
PRINTPI;
{STORE;}                { REMOVE BRACKETS TO SAVE PI TO DISK }
GOTO 20;                { DO AGAIN - PRESS BREAK TO EXIT PROGRAM }
END.

{ PROGRAM PILIST.PAS
BLOCK WRITE TO PILIST.PAS AND DELETE FROM HERE WHEN YOU ARE SURE IT WORKS
BE SURE TO TURN ON PRINTER.}

Uses Printer;

VAR
   SIZE, J,K:INTEGER;
   BUFF     :FILE OF INTEGER;
   TBUFF    :TEXT;
   T1, T2   :STRING[11];
BEGIN
      ASSIGN(BUFF,'PI.DTA');
      ASSIGN(TBUFF,'TIME.DTA');
RESET(BUFF);
RESET(TBUFF);
SIZE:=FILESIZE(BUFF)-1;
WRITE('                 THE COMPUTATION OF PI TO ',SIZE,' PLACES');
WRITELN;WRITELN;
WRITE('PI=3.');
WRITE(LST,'                 THE COMPUTATION OF PI TO ',SIZE,' PLACES');
WRITELN(LST);WRITELN(LST);
WRITE(LST,'PI=3.');
READ(BUFF,J);
K:=1;
WHILE  NOT  EOF(BUFF)  DO
BEGIN
READ(BUFF,J);
WRITE(J);
WRITE(LST,J);
   IF K MOD 5 = 0 THEN
    BEGIN
    WRITE(' ');
    WRITE(LST,' ');
    END;
   IF K MOD 50 = 0 THEN
   BEGIN
    WRITE('  ',K:4,'  PL          ');
    WRITE(LST,'  ',K:4,'  PL   ');
    WRITELN(LST);
    WRITE(LST,'     ');
   END;
K:=K+1;
END;
   WRITELN(LST);WRITELN(LST);
   WRITELN;WRITELN;

READ(TBUFF,T1);
READ(TBUFF,T2);

   WRITELN('ENDING   TIME = ',T2);
   WRITELN('STARTING TIME = ',T1);
   WRITELN(LST,'ENDING   TIME = ',T2);
   WRITELN(LST,'STARTING TIME = ',T1);

END.

