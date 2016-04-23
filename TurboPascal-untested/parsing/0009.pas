
UNIT match;

 (*  DESCRIPTION :
  * 12 tests of character sets
  * 8  new string operators
  * Pattern matching  and mask checking

     RELEASE     :  2.0
     DATE        :  09/08/93
     AUTHOR      :  Fernand LEMOINE
                    rue du Collège 34
                    B-6200 CHATELET
                    BELGIQUE
     All code granted to the public domain
     Questions and comments are welcome
     REQUIREMENT :  Turbo Pascal 4.0 or later
                    OPSTRING,OPABSFLD (Object Professional) from
                       Turbo Power Software
     Compatible with Borland Pascal protected mode
  *)


INTERFACE
CONST
  NullNumber = - MaxInt;      (* reserved for future use *)
  BlankChar      : SET OF Char = [#32];
  UpperOnlyset   : SET of Char = ['A'..'Z',#32,#128,#142..#144,
                                  #153,#154,#165];
  LowerOnlyset   : SET of Char = ['a'..'z',#32,#129..#141,#145,#147..#152,
                                 #160..#164];
  ForeignSet     : SET of Char = [#128..#154,#160..#167];
  CntrlSet       : SET of Char = [#0..#31,#127];
  PunctSet       : SET of Char = [#33,#39..#41,#44..#47,#58..#59,#63];
  GraphicSet     : SET of Char = [#176..#223];
  PrintOnlyset   : SET of Char = [#32..#126,#128..#254];
  SpecificSet :    SET OF Char = []; (* must be modified by user *)
  Delims :         SET OF Char = [' ', ',', '/'];
  ProperSet :      SET OF Char = [' ', '-'];

TYPE
  MatchOperator = (like, nsequal, between, not_between,
                   into, not_into, pattern, mask);

(* Does the string S contain ONLY Alphabetic characters ? *)
FUNCTION IsAlphabetic(S : String) : Boolean;
(* Does the string S contain ONLY upper case characters ? *)
FUNCTION IsUpperCase(S : String) : Boolean;
(* Does the string S contain ONLY lower case characters ? *)
FUNCTION IsLowerCase(S : String) : Boolean;
(* Are the first characters of a name or a first name into S
    a upper case  character,
    and the others  lower case  characters ? *)
FUNCTION IsMixedCase(S : String) : Boolean;
(* Does the string S contain ONLY a space    character  ? *)
FUNCTION IsSpace(S : String) : Boolean;
(* Does the string S contain ONLY a null character ('') ? *)
FUNCTION IsNullString(S : String) : Boolean;
(* Does the string S contain ONLY a null     number     ? *)
FUNCTION IsNullNumber(N : Real) : Boolean;
(* Does the string S contain ONLY a number ('0'.. '9'   ? *)
FUNCTION IsNumber(S : String) : Boolean;
(* Does the string S contain ONLY number
                                 space, minus and comma characters ? *)
FUNCTION IsDigit(S : String) : Boolean;
(* Does the string S contain ONLY number,space, minus and comma
                                 'E' or 'e'  characters  ? *)
FUNCTION IsScientific(S : String) : Boolean;
(* Does the string S contain ONLY number and 'A'..'F' characters ? *)
FUNCTION IsXdigit(S : String) : Boolean;
(* Does the string S contain ONLY characters in an user-defined set ? *)
FUNCTION IsSpecific(S : String) : Boolean;

(*      The string S is compared  with the string P  by a match operator :

    like        : phonetic comparison
    nsequal     : not strictly equal ---> no difference between upper and
                  lower case, neither trailing nor leading spaces
    between     : between lower and upper limit
    not_between : negation of BETWEEN
    into        : selection in a value list
    not_into    : negation of INTO
    pattern     : matching a pattern with wildcards
                  * : any single character
                  ? : any series of characters
                  ~ : NOT
    mask;       : enables selected position of a field to be checked for a
                  specific content
      '-' : position that is not to be checked
      'A' : check for alphabetic characters ( upper or lower case)
      'a' : check for upper case alphabetic characters
      'l' : check for lower case alphabetic characters
      'K' : check for hexadecimal content
      '@' : check for number;
      '#' : check for digit;
      'E' : check for number in exponential notation
      'B' : check for blank
      '%' : check for percent
      'f' : check for foreign characters
      'u' : check for punctuation ! ' ( ) , - . / : ; ?
      'g' : check for semi-graphic characters
      'o' : check for control characters
      'p' : check for any printing characters
      'B' : check for characters in BooleanSet
      'Y' : check for characters in YesNoSet
 *)

FUNCTION DMatch(S : String; op : MatchOperator; P : String) : Boolean;

IMPLEMENTATION
USES opstring, opabsfld;
VAR
  tmp : Boolean;
  errormask : Byte;

  (*-------------------------   String handling  ------------------------------------------------*)

  FUNCTION IsAlphabetic(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN AlphaOnlySet; Inc(i);
    END;
    IsAlphabetic := tmp;
  END;

  FUNCTION IsUpperCase(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN UpperOnlyset; Inc(i);
    END;
    IsUpperCase := tmp;
  END;

  FUNCTION IsLowerCase(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN LowerOnlyset; Inc(i);
    END;
    IsLowerCase := tmp;
  END;

  FUNCTION IsMixedCase(S : String) : Boolean;
  VAR
    noword, nopos1, nopos2, i : Byte;
    inter : String;
  BEGIN
    noword := WordCount(S, ProperSet);
    tmp := True; i := 1;
    WHILE (i <= noword) AND tmp DO
    BEGIN
      nopos1 := WordPosition(i, S, ProperSet);
      IF i < noword THEN
        nopos2 := (WordPosition(i + 1, S, ProperSet) - 2)
      ELSE
        nopos2 := Length(S);
      inter := Copy(S, nopos1, nopos2);
      tmp := IsUpperCase(inter[1]);
      IF tmp THEN
      BEGIN
        Delete(inter, 1, 1);
        tmp := IsLowerCase(inter);
      END;
      Inc(i, 1);
    END;
    IsMixedCase := tmp;
  END;

  FUNCTION IsSpace(S : String) : Boolean;
  BEGIN
    IF S <> '' THEN
      IsSpace := S = CharStr(' ', Length(S))
    ELSE
      IsSpace := False;
  END;

  FUNCTION IsNullString(S : String) : Boolean;
  BEGIN
    IsNullString := S = '';
  END;


  FUNCTION IsNullNumber(N : Real) : Boolean;
  BEGIN
    IsNullNumber := N = NullNumber;
  END;

  FUNCTION IsNumber(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN (NumberOnlySet - BlankChar); Inc(i);
    END;
    IsNumber := tmp;
  END;

  FUNCTION IsDigit(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN DigitOnlySet; Inc(i);
    END;
    IsDigit := tmp;
  END;

  FUNCTION IsScientific(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN ScientificSet; Inc(i);
    END;
    IsScientific := tmp;
  END;

  FUNCTION IsXdigit(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN HexOnlySet; Inc(i);
    END;
    IsXdigit := tmp;
  END;

  FUNCTION IsSpecific(S : String) : Boolean;
  VAR
    i : Byte;
  BEGIN
    tmp := True; i := 1;
    WHILE (i <= Length(S)) AND tmp DO
    BEGIN
      tmp := S[i] IN SpecificSet; Inc(i);
    END;
    IsSpecific := tmp;
  END;

  (*-------------------------   Pattern matching ------------------------------------------------*)

  FUNCTION DMatch(S : String; op : MatchOperator; P : String) : Boolean;
  VAR
    S1, S2, S3 : String;
    Compar : compareType;
    Ind, J, N, Nprime : Byte;
    except : Boolean;


    FUNCTION PtInterr(S, P : String) : Boolean;
    VAR
      tmp : Boolean;
      i : Byte;

    BEGIN
      tmp := True; i := 1;
      WHILE (i <= Length(S)) AND tmp DO
      BEGIN
        IF P[i] <> '?' THEN
        BEGIN
          tmp := S[i] = P[i];
        END;
        Inc(i);
      END;
      PtInterr := tmp;
    END;

    FUNCTION Aster(S, P : String) : Boolean;
    VAR N : Byte;
    BEGIN
      tmp := True;
      N := Pos('*', P);
      IF N = 1 THEN
      BEGIN
        Delete(P, 1, 1);
        tmp := PtInterr(Copy(S, Length(S) -
                             Length(P) + 1, Length(P)), P);
        Aster := tmp;
      END;

      IF N = Length(P) THEN
      BEGIN
        Delete(P, Length(P), 1);
        tmp := PtInterr(Copy(S, 1, Length(P)), P);
        Aster := tmp;
      END;
    END;


  BEGIN
    tmp := True;
    CASE op OF
      like : DMatch := Soundex(S) = Soundex(P);
      nsequal :
        BEGIN
          S1 := Trim(S); S2 := Trim(P);
          Compar := CompUCString(S1, S2);
          DMatch := Compar = equal;
        END;
      between :
        BEGIN
          N := WordPosition(2, P, Delims);
          DMatch := (Copy(P, 1, N - 2) < S)
          AND (S < Copy(P, N, (Length(P) - N + 1)));
        END;
      not_between :
        BEGIN
          N := WordPosition(2, P, Delims);
          DMatch := (S < Copy(P, 1, N - 2))
          OR (S > Copy(P, N, (Length(P) - N + 1)));
        END;

      into :
        BEGIN
          tmp := False; J := 1;
          Ind := WordCount(P, Delims);
          WHILE (J <= Ind) AND NOT tmp DO
          BEGIN
            N := WordPosition(J, P, Delims);
            IF J < Ind THEN
            BEGIN
              Nprime := WordPosition(J + 1, P, Delims);
              tmp := S = Copy(P, N, Nprime - N - 1);
            END
            ELSE
              tmp := S = Copy(P, N, (Length(P) - N + 1));
            Inc(J);
          END;
          DMatch := tmp;
        END;

      not_into :
        BEGIN
          tmp := True; J := 1;
          Ind := WordCount(P, Delims);
          WHILE (J <= Ind) AND tmp DO
          BEGIN
            N := WordPosition(J, P, Delims);
            IF J < Ind THEN
            BEGIN
              Nprime := WordPosition(J + 1, P, Delims);
              tmp := S <> Copy(P, N, Nprime - N - 1);
            END
            ELSE
              tmp := S <> Copy(P, N, (Length(P) - N + 1));
            Inc(J);
          END;
          DMatch := tmp;
        END;

      pattern :
        BEGIN

          except := Copy(P, 1, 1) = '~';
          IF except THEN Delete(P, 1, 1);
          N := Pos('*', P);
          Nprime := Pos('*', Copy(P, N + 1, Length(P) - N)) + N;
          IF Nprime > N THEN
            tmp := Pos(Copy(P, N + 1, Nprime - N - 1), S) <> 0
          ELSE
            IF Pos('*', P) <> 0 THEN
              tmp := Aster(S, P)
          ELSE
            IF Pos('?', P) <> 0 THEN
              tmp := PtInterr(S, P)
          ELSE
            tmp := S = P;
          IF except THEN DMatch := NOT tmp
          ELSE DMatch := tmp;
        END;

      mask :
        BEGIN
          tmp := True; J := 1; errormask := 0;
          WHILE (J <= Length(P)) AND tmp DO
          BEGIN
            CASE P[J] OF
              '-' : BEGIN END;
              'A' : tmp := S[J] IN AlphaOnlySet;
              'a' : tmp := S[J] IN UpperOnlyset;
              'l' : tmp := S[J] IN LowerOnlyset;
              'K' : tmp := S[J] IN HexOnlySet;
              '@' : tmp := S[J] IN NumberOnlySet - BlankChar;
              '#' : tmp := S[J] IN DigitOnlySet;
              'E' : tmp := S[J] IN ScientificSet;
              'B' : tmp := S[J] IN BlankChar;
              '%' : tmp := S[J] = '%';
              'f' : tmp := S[J] IN ForeignSet;
              'u' : tmp := S[J] IN PunctSet;
              'g' : tmp := S[J] IN GraphicSet;
              'o' : tmp := S[J] IN CntrlSet;
              'p' : tmp := S[J] IN PrintOnlyset;
              'B' : tmp := S[J] IN BooleanSet;
              'Y' : tmp := S[J] IN YesNoSet;
            END;
            IF tmp = False THEN errormask := J;
            Inc(J);
          END;
          DMatch := tmp;
        END;
    END;
  END;

END.

{  ----------------  DEMO PROGRAM ------------- }

program demmatch;
(* Demonstration program for use of match unit *)

uses crt,match;
var

  S,S1,S2  : string;
  OK : boolean;


begin
  clrscr;
  S := 'Jean Lemonier';
  Writeln('Demo match unit ');writeln;
  Writeln (' Jean Lemonier');
  Writeln ('Alphabetic ? ',IsAlphabetic (S));
  Writeln ('Upper case ? ',IsUpperCase  (S));
  Writeln ('Mixed case ? ',IsMixedcase  (S));

  Writeln;
  Writeln( '154.5');writeln;
  S2 :=  '154.5';
  Writeln ('Number ? ',IsNumber (S2));
  Writeln ('Digit  ? ',IsDigit  (S2));

  S1:= ' Jean LEMONIER  '; S2 := 'Je';
  Writeln;
  Writeln('Equivalent ',S, ' ',S1 ,'? ',Dmatch(S,nsequal,S1));
  Writeln('Je*,pattern,',s, '? ',Dmatch(S,pattern,'Je*'));
  Writeln('De*,pattern,',s, '? ',Dmatch(S,pattern,'De*'));
  Writeln('*er,pattern,',s, '? ',Dmatch(S,pattern,'*er'));
  Writeln('????? Lemonier,pattern,',s, '? ',
          Dmatch(S,pattern,'????? Lemonier'));
  Writeln('???? Lemonier,pattern,',s, '? ',
          Dmatch(S,pattern,'???? Lemonier'));
  Writeln('ll,mask ',s2, '? ',Dmatch(S2,mask,'ll'));
  Writeln('al,mask ',s2, '? ',Dmatch(S2,mask,'al'));
  delay(2500);
end.