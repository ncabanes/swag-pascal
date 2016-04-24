(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0133.PAS
  Description: Rangen Unit
  Author: DR. W. GROSS
  Date: 01-02-98  07:35
*)


{$A-,B-,D+,E+,F-,I+,L+,N+,O-,R+,S+,V+}
UNIT Rangen;

{==============================================================================

MODULE:         RANDOMGENERATOR (RANGEN.PAS)

===============================================================================

VERSION:        V1.5            Turbo-Pascal 6.0, 7.0

COPYRIGHT:      (c) 1987-1993
                Dr. W. Gross, Keplerstrasse 51
                D-69120 Heidelberg, FRG
                gross@aecds.exchi.uni-heidelberg.de

CREATED:        10-NOV-87       Wolfgang Gross          on VAX/VMS, PASCAL-2

LAST UPDATE:    02-MAY-88       Wolfgang Gross          round off error in
                                                        NORRANDOM
                21-JUL-88       Wolfgang Gross          round off error in
                                                        UNIRANDOM
                15-MAR-89       Wolfgang Gross          NorRan, RanSphere

TESTED:         10-FEB-90       Wolfgang Gross

-------------------------------------------------------------------------------
TITLE:          RANDOM NUMBER GENERATES
-------------------------------------------------------------------------------

DESCRIPTION:    Random number generators for uniform, normal, exponential,
                lognormal, poisson and uniform sphere distribution.

                If the TURBO-PASCAL random generator RANDOM is used
                one must set the variable SYSTEM.RandSeed before calling
                RANDOM and save it after the call using the given
                seed variable. This allows independent streams of
                random numbers. See comment in UNIRANDOM.

                If TEST8086>2 we can use 386 instructions. UNIRANDOM
                will then use its own method to generate the next
                univariate pseudo random number as described below.
                The method is approved by many independent tests
                that have been published in the literature. It has
                good Bayer coefficents which means it can be used for
                generating multi-dimensional random vectors.
                One might also utilize a floating point processor
                or switch to IEEE reals (type single, double) etc.
                Everybody may elaborate on this him/herself.

                If someone needs to modify and recompile this unit
                and doesn't have TASM, the complete ASM code is
                provided for compilation by the internal assembler.
                Some special arrangements are necessary to cope
                with 386 instructions. Define HAVETASM if you want
                to link MD2P31.OBJ. If this symbol is not defined
                the inline assembler version is used.




                This unit has evolved from a similar module worked
                out under PASCAL-2 in a VAX/VMS environment (including
                VAX assembler for MD2P31). The module can be found
                with anon ftp on aecds.exchi.uni-heidelberg.de.


CALLED BY:      <module name>   <title>


EXPORTS:        UNIRANDOM       uniformly distributed random numbers

                NORRANDOM       normally distributed random numbers

                NORRANDOM2      normally distributed random numbers,
                                polar method

                NORRANDOM3      normally distributed random numbers,
                                other mean/std-dev values than (0,1)

                EXPRANDOM       exponentially distributed random numbers

                LOGNORRANDOM    logarithmic normal distribution

                POIRANDOM       Poisson distribution

                RanSphere       uniformly distri. random numbers on sphere

INPUT:          seed            random number seed

                mean            mean value for distribution

                std             standard deviation

OUTPUT:         function value = random number

}


{=============================================================================}

{ Exports: }
Interface


FUNCTION  UNIRANDOM  ( VAR seed : longint ) : real;

FUNCTION  NORRANDOM  ( VAR seed : longint ) : real;

FUNCTION  NORRANDOM2 ( VAR seed : longint;
                       VAR v2   : real )    : real;

FUNCTION  NORRANDOM3 ( mean, std: real;
                       VAR seed : longint ) : real;

FUNCTION  EXPRANDOM  ( mean     : real;
                       VAR seed : longint ) : real;

FUNCTION  LOGNORRANDOM ( mean, std : real;
                       VAR seed : longint ) : real;

FUNCTION  POIRANDOM  ( lambda   : real;
                       VAR seed : longint ) : longint;

PROCEDURE RanSphere  ( VAR seed : longint;
                       VAR x,y,z: real );


{===========================================================================}

Implementation


{DEFINE HAVETASM} {put a $ in front of DEFINE to link MD2P31.OBJ}

{$IFDEF HAVETASM}

   PROCEDURE MD2P31 (A,B : longint;
                     VAR Q,R : longint); far; external;


   {$L MD2P31.OBJ}

{$ELSE}

   PROCEDURE MD2P31 (A,B : longint;
                     VAR Q,R : longint); far; assembler;
     {rather tricky: we fake TP into generating 386 intructions
      Calculate product a*b, represent product as q*2^31+r, 0<=r<2^31}
     asm
       push  es
       push  di

       db    $66       { 386 prefix for dword operation}
       push  ax        { = push eax }

       db    $66
       push  bx        { = push ebx }

       db    $66
       push  dx        { = push edx }

       db    $66
       mov   ax,word ptr ss:[bp+18]  { mov   eax,a }

       db    $66
       mov   bx,word ptr ss:[bp+14]  { mov   ebx,b }

       db    $66
       imul  bx        { imul ebx   ; a*b in edx:eax  (= 8 bytes !) }

       db    $66
       mov   bx,ax     { mov ebx,eax }

       db    $66,$0f,$a4,$da,$01     { SHLD edx,ebx,1      ; edx contains q }

       db    $66,$25,$ff,$ff,$ff,$7f { and  eax,07fffffffh ; eax contains r }

       les   di,r
       db    $66
       stosw           { stosd   ; mov eax to r }

       db    $66
       mov   ax,dx     { mov eax,edx }

       les   di,q
       db    $66
       stosw           { stosd   ; mov eax to q }


       db   $66
       pop  dx         { = pop edx }

       db   $66
       pop  bx         { = pop ebx }

       db   $66
       pop  ax         { = pop eax }

       pop  es
       pop  di
     end;{ PROC MD2P31 }


{$ENDIF}


FUNCTION UNIRANDOM;
  { Cf. Payne,W.H., Rabung, J.R., Bogyo, T.P. :
        "Coding the Lehmer pseudo-random number generator.
	Comm. ACM 12, 85-86 (1969)                         }

  CONST MODULUS : longint = 2147483647;  { = 2^31-1 }
        FACTOR  : longint = 397204094;   { primitive root, e.g. used by SAS }

  VAR   Q,R,S : longint;

  BEGIN { UNIRANDOM }

    IF TEST8086>1 THEN
      BEGIN
        { Priniple
	     seed := ( seed*FACTOR )  MOD  MODULUS;
          but can not use it due to overflow }

        MD2P31 ( seed, factor, Q, R );
        S := modulus - R;
        IF S > Q
          THEN seed := Q + R
          ELSE seed := Q - S;

        { Single precision version. For more details on the division cf. to
          Fishman, G.S., Moore, L.R. :
          A statistical evaluation of multiplicative congruential random
          number generators with modulus 2^31-1 .
          Jour. Amer. Stat. Ass. 77, 129-136 *1982)                         }

        UNIRANDOM := seed/MODULUS;
      END
     ELSE
      {see comment at the beginning of unit, RandSeed from unit SYSTEM}
       BEGIN
         RandSeed := seed; Unirandom := random; seed := RandSeed;
       END;


  END; { FUNC UNIRANDOM }


            {--------------------------------------------}


FUNCTION  NORRANDOM  ( VAR seed : longint  )  : real;
  CONST TwoPi = 2*Pi;
  VAR     s, r1, r2, z1, z2 : real;
  BEGIN { NORRANDOM }
    REPEAT r1 := UniRandom ( seed ) UNTIL r1>0;
    r2 := UniRandom ( seed );
    s := -2*ln(r1);
    IF s<0 THEN s := 0;         { round off error could give negative value s }
    NORRANDOM := SQRT ( s ) * cos ( TwoPi*r2 );
  END; { FUNC NORRANDOM }

            {--------------------------------------------}

FUNCTION  NorRandom2 ( VAR seed : longint;
                       VAR v2   : real ) : real;
 { Polar method due to Box, Mueller and Marsaglia,
   cf. D.E. Knuth, The art of computer porgramming, vol 2, 117
   first call: v2 must be > 1000 }

  VAR     s, t, v1 : real;

  BEGIN { NORRANDOM2 }
    IF v2<1000
      THEN
        BEGIN
          NORRANDOM2 := v2; v2 := 2000
        END
      ELSE
        BEGIN
          REPEAT
            v1 := UniRandom ( seed ); v1 := v1+v1-1;
            v2 := UniRandom ( seed ); v2 := v2+v2-1;
            s := Sqr (v1) + sqr(v2);
          UNTIL (s<1) AND (s>0);
          T := Sqrt ( -2*Ln(s)/s );
          NORRANDOM2 := V1*T;
          V2 := V2*T;
        END;
  END; { FUNC NORRANDOM2 }


            {--------------------------------------------}

FUNCTION  NORRANDOM3 ( mean, std : real;
                       VAR seed : longint ) : real;
  BEGIN { NORRANDOM3 }
    NORRANDOM3 := std*NORRANDOM (seed) + mean;
  END; { FUNC NORRANDOM3 }

            {--------------------------------------------}

FUNCTION  EXPRANDOM  ( mean     : real;
                       VAR seed : longint ) : real;
  BEGIN { EXPRANDOM }
     EXPRANDOM := ( -ln(UNIRANDOM(seed))*mean );
  END; { FUNC EXPRANDOM }

            {--------------------------------------------}

FUNCTION  LOGNORRANDOM ( mean, std : real;
                         VAR seed  : longint ) : real;
  VAR     m2, s2, sum, mu, sigma : real;
  BEGIN { LOGNORRANDOM }
    m2 := SQR(mean); s2 := SQR(std); sum := m2+s2;
    mu := 0.5*ln(SQR(m2)/sum);
    sigma := SQRT (ln(sum/m2));
    LOGNORRANDOM := exp (sigma * NORRANDOM (seed) + mu);
  END; { FUNC LOGNORRANDOM }

            {--------------------------------------------}

FUNCTION  POIRANDOM  (  lambda   : real;
                        VAR seed : longint )  : longint;


  VAR     i : longint;
          p,q,r,z : real;

  BEGIN { POIRANDOM }
    { cf. H.E. Schaffer, Generator of random numbers satisfying the
          Poisson distribution, Comm. ACM 13, 49 (1970)
          G.S. Fishman, Sampling from the Poisson distribution on
          a computer, Computing 17, 147-156 (1976) }
    IF lambda<50
      THEN
        BEGIN
          z := exp ( -lambda ); p := 1; i := -1;
          REPEAT
            i := i+1;
            r := UNIRANDOM ( seed );
            p := p*r;
          UNTIL p<=z;
          POIRANDOM := i;
        END
      ELSE
        BEGIN
          i := Round ( NORRANDOM3 ( lambda, SQRT(lambda), seed ) );
          IF i<0 THEN i :=0;
          POIRANDOM := i;
        END;

  END; { PROC POIRANDOM }

            {--------------------------------------------}

PROCEDURE RanSphere ( VAR seed : longint;
                      VAR x,y,z : real );
 { R.E. Knop, Random Vectors Uniform in Solid Angle,
   CACM 13 (1970), 326 }

  VAR     s, t, v1, v2 : real;

  BEGIN { RanSphere }

    REPEAT
      v1 := UniRandom ( seed ); v1 := v1+v1-1;
      v2 := UniRandom ( seed ); v2 := v2+v2-1;
      s := Sqr (v1) + sqr(v2);
    UNTIL (s<1) AND (s>0);

    T := 2*Sqrt ( 1-S );
    x := T*V1; y := T*V2; z := S+S-1;

  END; { PROC RanSphere }


end. {UNIT RANGEN}

{---------------------   DEMO ---------------------- }
{ ----------- CUT ---------------- }

{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,655360}
program testrand;
  uses rangen;

  {generates two independent streams of uniform random numbers}

VAR r1, r2 : real;
    seed1, seed2 : longint;
    i : integer;

BEGIN

  write ('enter seed1, seed2 = ' ); readln ( seed1, seed2 );
  for i := 1 TO 20 DO
    BEGIN
      r1 := unirandom(seed1);
      r2 := unirandom(seed2);
      writeln ( seed1:12, r1:12:8, seed2:12, r2:12:8 );
    END;
  readln;

END.



{ ---------------------------------  ASM UNIT THAT CAN BE USED IN THIS UNIT ------------- }
{ ----------- CUT ---------------- }

; MD2P31.ASM, for Turbo Assembler

          .MODEL TPASCAL    ; 16-bit segments
          .386C             ; non-privileged 386 instructions

CODE      SEGMENT BYTE PUBLIC
          ASSUME cs:CODE,ds:NOTHING

; PASCAL declaration
;   PROCEDURE MD2P31 (A,B : longint;
;                     VAR Q,R : longint); far; external;

; calculate product a*b, represent product as q*2^31+r, 0<=r<2^31
; return q and r

; Parameters (+2 because of push bp)

R         EQU DWORD PTR ss:[bp+6]
Q         EQU DWORD PTR ss:[bp+10]
B         EQU DWORD PTR ss:[bp+14]
A         EQU DWORD PTR ss:[bp+18]


MD2P31    PROC FAR
          PUBLIC MD2P31

          push  bp
          mov   bp,sp          ;get pointer into stack
          push  es
          push  di             ;manual says we don't need to save
          push  eax            ;those registers, but safety first!
          push  ebx
          push  edx

          mov   eax,a
          mov   ebx,b
          imul  ebx            ; a*b in edx:eax

          mov   ebx,eax
          SHLD  edx,ebx,1      ; edx contains q

          and   eax,07fffffffh ; eax contains r
          les   di,r
          stosd

          mov   eax,edx
          les   di,q
          stosd

          pop   edx
          pop   ebx
          pop   eax
          pop   di
          pop   es
          pop   bp
          retf  16             ;parameters take 16 bytes
MD2P31    ENDP

CODE      ENDS

          END

