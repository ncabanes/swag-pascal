
UNIT vector;

  (*  DESCRIPTION :
     Set of 22 functions and procedures for vector ,i.e array of real
     Manipulation de vecteur: 22 fonctions et procédures

     RELEASE     :  1.0
     DATE        :  25/04/94
     AUTHOR      :  Fernand LEMOINE
                    rue du Collège 34
                    B-6200 CHATELET
                    BELGIQUE
     All code granted to the public domain
     Questions and comments are welcome
     REQUIREMENT :  Turbo Pascal 7.0 or later
                       *  open-string parameter
                       *  constant parameter
     Compatible with Borland Pascal protected mode
     Compatible with Borland Pascal for Windows (Wincrt)
     OPTIONS
        * accept zero for computation or not accept ( default)
           exceptions : VStd, VVar

        * lim = all : perform computation for all the values of the vector
          otherwise lim = number of values to compute
  *)

INTERFACE

CONST
  all = 0;
  accept_zero : Boolean = False;

  (* Clear all values - remise à zéro                                      *)
PROCEDURE VClear(VAR A : ARRAY OF Real; lim : Word);
  (* Display  of a vector  - Affichage d'un vecteur                        *)
PROCEDURE VDisplay(CONST A : ARRAY OF Real; l, m : Byte);
  (* Linear index generator - Génération d 'index                          *)
PROCEDURE VIndex(VAR A : ARRAY OF Real; lim : Word);
  (* Random generator - Générateur aléatoire                               *)
PROCEDURE VRnd(VAR A : ARRAY OF Real; lim : Word);
  (* Sum   of a vector  - Somme d'un vecteur                               *)
FUNCTION VSum(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* Product  of a vector  - Produit d'un  vecteur                         *)
FUNCTION VProd(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* Minimum  of a vector  - Miniimum d'un vecteur                         *)
FUNCTION VMin(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* Average of a vector  - Moyenne d'un vecteur                           *)
FUNCTION VAvg(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* Maximum   of a vector  - Maximum d'un vecteur                         *)
FUNCTION VMax(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* First value of a vector  - Première valeur d'un vecteur               *)
FUNCTION VFirst(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* Last  value of a vector  - Dernière valeur d'un vecteur               *)
FUNCTION VLast(CONST A : ARRAY OF Real; lim : Word) : Real;
  (* Number of values of a vector - Nombre de valeurs d'un vecteur         *)
FUNCTION VSize(CONST A : ARRAY OF Real; lim : Word) : Word;

  (* Standard deviation of a vector - Ecart-type d'un vecteur              *)
(* Opt = 'P' : Population
         'S' : Sample     - Echantillon                                    *)

FUNCTION VStd(CONST A : ARRAY OF Real; opt : Char; lim : Word) : Real;
  (* Variance of a vector  - Variance d'un vecteur                         *)
(* Opt = 'P' : Population
         'S' : Sample     - Echantillon                                    *)
FUNCTION VVar(CONST A : ARRAY OF Real; opt : Char; lim : Word) : Real;

  (* Position of maximum     -  Position du maximum d'un vecteur           *)
FUNCTION VOrdMax(CONST A : ARRAY OF Real; lim : Word) : Word;
  (* Position of minimum    -  Position du minimum d'un vecteur            *)
FUNCTION VOrdMin(CONST A : ARRAY OF Real; lim : Word) : Word;
  (*  Subtract minimum from maximum of a vector
   Différence entre maximum et minimum d'un vecteur                        *)
FUNCTION VRange(CONST A : ARRAY OF Real; lim : Word) : Real;
 (*  Mean between maximum and minimum of a vector
   Moyenne du maximum et et du minimum d'un vecteur                        *)
FUNCTION VMidRange(CONST A : ARRAY OF Real; lim : Word) : Real;
 (* Median of a vector    - Médiane d'un vecteur
    If not in ascending order , VMedian returns zero
    Doit être trié en ordre ascendant  sinon valeur zéro
  *)
FUNCTION VMedian(CONST A : ARRAY OF Real; lim : Word) : Real;

  (* Reverse order   of a vector -  Retournement   d'un vecteur             *)
PROCEDURE VReverse(VAR A : ARRAY OF Real; lim : Word);
  (* Ascending sort of a vector -  Tri ascendant d'un vecteur               *)
PROCEDURE VAscSort(VAR A : ARRAY OF Real; lim : Word);
  (* Descending sort of a vector -  Tri descendant d'un vecteur              *)
PROCEDURE VDescSort(VAR A : ARRAY OF Real; lim : Word);


IMPLEMENTATION
USES crt;

  FUNCTION Ascending_Order(CONST A : ARRAY OF Real; lim : Word) : Boolean;
  VAR
    i, limit : Word;
    correct_order : Boolean;
  BEGIN
    correct_order := True;
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    FOR i := 0 TO limit - 1 DO
      IF A[i] > A[i + 1] THEN
        correct_order := False;
    Ascending_Order := correct_order;
  END;
    (* --------------------------------------------------------------*)
  PROCEDURE VClear(VAR A : ARRAY OF Real; lim : Word);
  VAR
    i, limit : Word;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    FOR i := 0 TO limit DO
      A[i] := 0;
  END;
    (* --------------------------------------------------------------*)
  PROCEDURE VDisplay(CONST A : ARRAY OF Real; l, m : Byte);
  VAR
    i : Word;
    total : Byte;
  BEGIN
    IF m > 0 THEN total := l + m + 1
    ELSE total := l;

    FOR i := 0 TO high(A) DO
    BEGIN
      IF wherey >= (80 - total) THEN WriteLn;
      Write(A[i]:l:m, ' ');
    END;
    WriteLn;
  END;

    (* --------------------------------------------------------------*)
  PROCEDURE VIndex(VAR A : ARRAY OF Real; lim : Word);
  VAR
    i, limit : Word;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    FOR i := 0 TO limit DO
      A[i] := i + 1;
  END;
    (* --------------------------------------------------------------*)
  PROCEDURE VRnd(VAR A : ARRAY OF Real; lim : Word);
  VAR
    i, limit : Word;
  BEGIN
    Randomize;
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    FOR i := 0 TO limit DO
      A[i] := Random(i);
  END;
    (* --------------------------------------------------------------*)
  FUNCTION VSize(CONST A : ARRAY OF Real; lim : Word) : Word;
  VAR
    i, j, limit : Word;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    j := 0;
    FOR i := 0 TO limit DO
      IF (NOT accept_zero) AND (A[i] = 0) THEN continue
      ELSE
        Inc(j);
    VSize := j;
  END;
    (* --------------------------------------------------------------*)
  FUNCTION VSum(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    i, limit : Word;
    S : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    S := 0;
    FOR i := 0 TO limit DO
      S := S + A[i];
    VSum := S;
  END;

    (* --------------------------------------------------------------*)
  FUNCTION VProd(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    i, limit : Word;
    S : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    S := 1;
    FOR i := 0 TO limit DO
      IF (NOT accept_zero) AND (A[i] = 0) THEN continue
      ELSE
        S := S * A[i];
    VProd := S;
  END;
    (* --------------------------------------------------------------*)
  FUNCTION VMin(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    i, limit : Word;
    S : Real;
  BEGIN
    S := 1E+38;
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    FOR i := 0 TO limit DO
      IF (NOT accept_zero) AND (A[i] = 0) THEN continue
      ELSE
        IF A[i] < S THEN S := A[i];
    VMin := S;
  END;
    (* --------------------------------------------------------------*)
  FUNCTION VMax(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    i, limit : Word;
    S : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    S := A[low(A)];
    FOR i := 0 TO limit DO
      IF A[i] > S THEN S := A[i];
    VMax := S;
  END;

    (* --------------------------------------------------------------*)
  FUNCTION VAvg(CONST A : ARRAY OF Real; lim : Word) : Real;
  BEGIN
    VAvg := VSum(A, lim) / (VSize(A, lim));
  END;
    (* --------------------------------------------------------------*)

  FUNCTION VFirst(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    i, limit : Word;
  BEGIN
    IF accept_zero THEN
      VFirst := A[low(A)]
    ELSE
    BEGIN
      IF lim = all THEN limit := high(A)
      ELSE limit := lim - 1;
      FOR i := 0 TO limit DO
        IF A[i] <> 0 THEN
        BEGIN
          VFirst := A[i];
          break;
        END;
    END;
  END;
    (* --------------------------------------------------------------*)

  FUNCTION VLast(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    i, limit : Word;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    IF accept_zero THEN
      VLast := A[limit]
    ELSE
    BEGIN
      FOR i := limit DOWNTO 0 DO
        IF A[i] <> 0 THEN
        BEGIN
          VLast := A[i];
          break;
        END;
    END;
  END;

    (* --------------------------------------------------------------*)
  FUNCTION VOrdMax(CONST A : ARRAY OF Real; lim : Word) : Word;
  VAR
    i, limit : Word;
    S : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    S := A[low(A)]; VOrdMax := 1;
    FOR i := 0 TO limit DO
      IF A[i] > S THEN
      BEGIN
        S := A[i];
        VOrdMax := i + 1;
      END;
  END;
   (* --------------------------------------------------------------*)

  FUNCTION VOrdMin(CONST A : ARRAY OF Real; lim : Word) : Word;
  VAR
    i, limit : Word;
    S : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    S := 1E+38; VOrdMin := 1;

    FOR i := 0 TO limit DO
      IF (NOT accept_zero) AND (A[i] = 0) THEN continue
      ELSE
        IF A[i] < S THEN
        BEGIN
          S := A[i];
          VOrdMin := i + 1;
        END;
  END;

    (* --------------------------------------------------------------*)
  FUNCTION VRange(CONST A : ARRAY OF Real; lim : Word) : Real;
  BEGIN
    VRange := VMax(A, all) - VMin(A, all);
  END;

    (* --------------------------------------------------------------*)
  FUNCTION VMidRange(CONST A : ARRAY OF Real; lim : Word) : Real;
  BEGIN
    VMidRange := (VMax(A, all) + VMin(A, all)) / 2;
  END;
    (* --------------------------------------------------------------*)
  FUNCTION VMedian(CONST A : ARRAY OF Real; lim : Word) : Real;
  VAR
    j, num : Word;
  BEGIN
    IF lim = all THEN num := high(A) + 1
    ELSE num := lim;
    IF NOT Ascending_Order(A, lim) THEN
    BEGIN
      VMedian := 0;
      Exit;
    END;

    IF Odd(num) THEN
      VMedian := A[(num DIV 2)]
    ELSE
      VMedian := (A[(num DIV 2) - 1] + A[(num DIV 2)]) / 2.0
  END;
    (* --------------------------------------------------------------*)
  PROCEDURE VReverse(VAR A : ARRAY OF Real; lim : Word);
  VAR
    i, j, limit, middle : Word;
    work : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    IF Odd(limit) THEN middle := (limit DIV 2) + 1
    ELSE middle := limit DIV 2;
    FOR i := 0 TO middle DO
    BEGIN
      work := A[i];
      A[i] := A[limit];
      A[limit] := work;
      Dec(limit);
    END;
  END;
  (* --------------------------------------------------------------*)

  PROCEDURE VAscSort(VAR A : ARRAY OF Real; lim : Word);
  VAR
    i, gap, limit : Word;
    exchange : Boolean;
    temp : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    gap := limit DIV 2;
    REPEAT
      REPEAT
        exchange := False;
        FOR i := 0 TO limit - gap DO
          IF A[i] > A[i + gap] THEN
          BEGIN
            temp := A[i];
            A[i] := A[i + gap];
            A[i + gap] := temp;
            exchange := True;
          END;
      UNTIL NOT exchange;
      gap := gap DIV 2;
    UNTIL gap = 0;
  END;
  (* --------------------------------------------------------------*)

  PROCEDURE VDescSort(VAR A : ARRAY OF Real; lim : Word);
  VAR
    i, gap, limit : Word;
    exchange : Boolean;
    temp : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    gap := limit DIV 2;
    REPEAT
      REPEAT
        exchange := False;
        FOR i := 0 TO limit - gap DO
          IF A[i] < A[i + gap] THEN
          BEGIN
            temp := A[i];
            A[i] := A[i + gap];
            A[i + gap] := temp;
            exchange := True;
          END;
      UNTIL NOT exchange;
      gap := gap DIV 2;
    UNTIL gap = 0;
  END;
  (* --------------------------------------------------------------*)
  FUNCTION VVar(CONST A : ARRAY OF Real; opt : Char; lim : Word) : Real;
  VAR
    i, limit, numobs : Word;
    S, vari : Real;
  BEGIN
    IF lim = all THEN limit := high(A)
    ELSE limit := lim - 1;
    numobs := limit + 1;

    S := 0.0; vari := 0.0;
    FOR i := 0 TO limit DO
    BEGIN
      S := S + A[i];
      vari := vari + Sqr(A[i]);
    END;

    IF Upcase(opt) = 'S' THEN
      VVar := (vari - Sqr(S) / numobs) / (numobs - 1)
    ELSE
      VVar := (vari - Sqr(S) / numobs) / numobs;
  END;
  (* --------------------------------------------------------------*)

  FUNCTION VStd(CONST A : ARRAY OF Real; opt : Char; lim : Word) : Real;
  BEGIN
    VStd := Sqrt(VVar(A, opt, lim));
  END;
  (* --------------------------------------------------------------*)
END.

{ ----------------   DEMO PROGRAM   ------------------ }

program demovect;
uses crt,vector;

const
 A : array[1..6] of real = (45,26,184,2,0,86);
var
 B : array[1..5] of real;

 begin
   clrscr;Writeln('Demo vector unit');
   VDisplay(A,3,0);

   VAscSort(A,all);
   VDisplay (A,3,0);
   VDescSort(A,all);
   VDisplay (A,3,0);

   VIndex(B,all);
   VDisplay (B,3,0);
   VReverse(B,all);
   VDisplay (B,3,0);
   VClear(B,all);
   VRnd(B,all);

(*   accept_zero := true;  *)    {   <----------- can be modified }

   writeln('Size         ',VSize(A,all):3);
   writeln('Product      ',VProd(A,all):5:0);
   writeln('Sum          ',VSum (A,all):5:0);
   writeln('Average      ',VAvg (A,all):5:2);
   writeln('Maximum      ',VMax (A,all):5:0);
   writeln('Maximum    4 ',VMax (A,4):5:0);
   writeln('Minimum      ',VMin (A,all):5:0);
   writeln('First value  ',VFirst(A,all):5:0);
   writeln('Last  value  ',VLast(A,all):5:0);
   writeln('Last value 4 ',VLast(A,4):5:0);

   writeln('Ord  max     ',VOrdMax(A,all):3);
   writeln('Ord  min     ',VOrdMin(A,all):3);
   writeln('Range        ',VRange (A,all):3:2);
   writeln('Midrange     ',VMidRange(A,all):3:2);
   VAscSort(A,all);
   writeln('Median all   ',VMedian(A,all):5:2);
   writeln('Median 4     ',VMedian(A,4):5:2);
   writeln('Variance     ',VVar(A,'S',all):5:2);
   writeln('St deviation ',VStd(A,'S',all):5:2);
   delay(3500);

  end.