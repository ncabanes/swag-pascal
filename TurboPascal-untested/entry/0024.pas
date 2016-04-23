
UNIT Editform;


 (*  DESCRIPTION :
    Edit form for print and display

      INPUT
        supported types :
          -   byte, integer, longint, real
          -   boolean, char, string
          -   pointer
          -   double, extended
          -   date , time      from OPDATE
          -   timestamp        from NLCS
          -   currency         from BUSINESS

      OUTPUT  string

    CF masque.txt : help file in french for more explanations

     RELEASE     :  1.0
     DATE        :  30/09/94
     AUTHOR      :  Fernand LEMOINE
                    rue du Collège 34
                    B-6200 CHATELET
                    BELGIQUE
     All code granted to the public domain
     Questions and comments are welcome
     REQUIREMENT : *  Turbo Pascal 5.0 or later
                   *  Opdate, Opstring, Opabsfld, OPpInline , Opdos
                      from Object Professional
                   *  Business and nlcs units
  *)


INTERFACE
USES nlcs, business,
    opstring , opdate;
CONST

  Blank = ' ';
  PadChar : Char = '-';
  HexaChar : Char = 'h';
TYPE
  TCountryInfo = (dos3, iso);
VAR
  SymbolStr : String[5];
  TrueUserStr : String[10];
  FalseUserStr : String[10];


FUNCTION BooleanForm(mask : String; value : Boolean) : String;
FUNCTION CharForm(mask : String; value : Char) : String;
FUNCTION PointerForm(mask : String; value : Pointer) : String;
FUNCTION TimeStampForm(mask : String; value : TimeStamp) : String;
FUNCTION StringForm(mask : String; value : String) : String;
FUNCTION IntegerForm(mask : String; value : Integer) : String;
FUNCTION ByteForm(mask : String; value : Byte) : String;
FUNCTION WordForm(mask : String; value : Word) : String;
FUNCTION LongintForm(mask : String; value : LongInt) : String;
FUNCTION RealForm(mask : String; value : Real) : String;
FUNCTION DateForm(mask : String; value : date) : String;
FUNCTION TimeForm(mask : String; value : time) : String;
FUNCTION HelpDate(pays : str3) : String;
FUNCTION HelpTime(pays : str3) : String;

 {$IFOPT N+}

  function  DoubleForm   (mask:string;value: double): string;
  function  ExtendedForm (mask:string;value: extended): string;
  function  CurrencyForm (mask:string;valeur: currency): string;
  function  HelpCurrency (value        : byte ;
                          pays         : str3 ;
                          info         : tcountryinfo ) : string;
  procedure ChangeDecCommaChar (DC,CC : char);
{$ENDIF}

IMPLEMENTATION
USES opabsfld, opinline, opdos;

CONST

  Delimitor : CharSet = ['/'];

  (* --------------------------------------------------------------- *)
  FUNCTION BooleanForm(mask : String; value : Boolean) : String;
  BEGIN
    IF mask = 'B' THEN
      IF value = True THEN BooleanForm := TrueChar
      ELSE BooleanForm := FalseChar
    ELSE IF mask = 'Y' THEN
      IF value = True THEN BooleanForm := YesChar
      ELSE BooleanForm := NoChar
    ELSE IF mask = 'O' THEN
      IF value = True THEN BooleanForm := 'On'
      ELSE BooleanForm := 'Off'
    ELSE IF mask = 'U' THEN
      IF value = True THEN BooleanForm := TrueUserStr
      ELSE BooleanForm := FalseUserStr
    ELSE
      BooleanForm := '';
  END;

  (* --------------------------------------------------------------- *)
  FUNCTION CharForm(mask : String; value : Char) : String;
  CONST
    table_char : ARRAY[0..32] OF String[3] =
    ('NUL', 'SOH', 'STX', 'ETX', 'EOT', 'ENQ', 'ACK', 'BEL', 'BS ', 'HT ', 'LF ', 'VT ',
     'FF ', 'CR ', 'SO ', 'SI ', 'DLE', 'DC1', 'DC2', 'DC3', 'DC4', 'NAK', 'SYN', 'ETB',
     'CAN', 'EM ', 'SUB', 'ESC', 'FS ', 'GS ', 'RS ', 'US ', 'SP ');

  BEGIN
    CASE mask[1] OF
      'X' : CharForm := value;
      '!' : CharForm := Upcase(value);
      'L' : CharForm := Locase(value);
      'D' : CharForm := '#' + LongintForm('@@@', Ord(value));
      'K' : CharForm := '#h' + HexB(Byte(value));
      '^' :
        CASE Ord(value) OF
          0..32 : CharForm := table_char[Ord(value)];
          127 : CharForm := 'DEL';
          255 : CharForm := 'END'
        ELSE
          CharForm := value;
        END;
    END;
  END;
  (* --------------------------------------------------------------- *)

  FUNCTION PointerForm(mask : String; value : Pointer) : String;
  BEGIN
    IF mask = 'Ps' THEN
      PointerForm := HexPtr(value)
    ELSE
      IF mask = 'Pn' THEN
        PointerForm := HexPtr(Normalized(value))
    ELSE
      IF mask = 'Pl' THEN
        PointerForm := Long2Str(PtrToLong(value))
    ELSE
      PointerForm := '*****';
  END;
  (* --------------------------------------------------------------- *)

  FUNCTION IntegerForm(mask : String; value : Integer) : String;
  VAR wrk : String;
  BEGIN
    CASE mask[1] OF
      '(' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            wrk := '(' + opstring.LongintForm(mask, value) + ')';
            IF Pos('#', mask) <> 0 THEN
              Delete(wrk, 2, 1);
            IntegerForm := wrk;
          END
          ELSE
            IntegerForm := opstring.LongintForm(mask, value);
        END;
      'D' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            wrk := opstring.LongintForm(mask, value) + 'DB';
            IF Pos('#', mask) <> 0 THEN
              Delete(wrk, 1, 1);
            IntegerForm := wrk;
          END
          ELSE
            IntegerForm := opstring.LongintForm(mask, value);
        END;
      'R' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            wrk := opstring.LongintForm(mask, value) + 'CR';
            IF Pos('#', mask) <> 0 THEN
              Delete(wrk, 1, 1);
            IntegerForm := wrk;
          END
          ELSE
            IntegerForm := opstring.LongintForm(mask, value);
        END;
    ELSE
      IntegerForm := opstring.LongintForm(mask, value);
    END;
  END;

  FUNCTION RomanDate(n : Word) : String;
  CONST
    Mille = 'M';
    CinqCent = 'D';
    Cent = 'C';
    Cinquante = 'L';
    Dix = 'X';
    Cinq = 'V';
    Un = 'I';
  VAR
    Res : String;
  BEGIN
    Res := '';
    IF (n = 0) OR (n > 9999) THEN
    BEGIN
      RomanDate := '***';
      Exit;
    END;

    WHILE n >= 1000 DO
    BEGIN
      n := n - 1000;
      Res := Res + Mille;
    END;

    IF n >= 900 THEN
    BEGIN
      n := n - 900;
      Res := Res + 'XM';
    END;

    WHILE n >= 500 DO
    BEGIN
      n := n - 500;
      Res := Res + CinqCent;
    END;

    IF n >= 400 THEN
    BEGIN
      n := n - 400;
      Res := Res + 'CD';
    END;


    WHILE n >= 100 DO
    BEGIN
      n := n - 100;
      Res := Res + Cent;
    END;

    IF n >= 90 THEN
    BEGIN
      n := n - 90;
      Res := Res + 'XC';
    END;

    IF n >= 50 THEN
    BEGIN
      n := n - 50;
      Res := Res + Cinquante;
    END;

    IF n >= 40 THEN
    BEGIN
      n := n - 40;
      Res := Res + 'XL';
    END;

    WHILE n >= 10 DO
    BEGIN
      n := n - 10;
      Res := Res + Dix;
    END;

    IF n = 9 THEN
    BEGIN
      n := n - 9;
      Res := Res + 'IX';
    END;

    IF n >= 5 THEN
    BEGIN
      n := n - 5;
      Res := Res + Cinq;
    END;

    IF n = 4 THEN
    BEGIN
      n := n - 4;
      Res := Res + 'IV';
    END;

    WHILE n >= 1 DO
    BEGIN
      n := n - 1;
      Res := Res + Un;
    END;
    RomanDate := Res;
  END;

  (* --------------------------------------------------------------- *)
  FUNCTION DateForm(mask : String; value : date) : String;
  VAR
    S : String;
    D, M, Y : Integer;
    DateOk : Boolean;
  BEGIN
    IF Upcase(mask[1]) = 'J' THEN
    BEGIN
      S := DateToDateString(InternationalDate(True, True), value);
      DateOk := DateStringToDMY(InternationalDate(True, True), S, D, M, Y);
      IF DateOk THEN
        DateForm := Long2Str(Y) + Long2Str(DayOfYear(value))
      ELSE
        DateForm := '0000000';
    END
    ELSE
      IF Upcase(mask[1]) = 'R' THEN
        DateForm := RomanDate(value)
    ELSE
      DateForm := DateToDateString(mask, value);
  END;
  (* --------------------------------------------------------------- *)

  FUNCTION TimeForm(mask : String; value : time) : String;
  BEGIN
    TimeForm := TimeToTimeString(mask, value);
  END;


  (* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
  FUNCTION HelpDate(pays : str3) : String;
  VAR
    S : String[20];
    contri : str3;

  BEGIN

    contri := pays;
    IF contri <> currentcountry THEN
    BEGIN
      SetCountry(contri);
    END;
    S := InternationalDate(True, True);
    HelpDate := Substitute(S, '/', SlashChar);
    IF contri <> currentcountry THEN
      SetCountry(currentcountry);

  END;
  (* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
  FUNCTION HelpTime(pays : str3) : String;
  VAR
    S : String[20];
    contri : str3;

  BEGIN
    contri := pays;
    IF contri <> currentcountry THEN
      SetCountry(contri);

    S := InternationalTime(True, True, True, True);
    HelpTime := Substitute(S, ':', ColonChar);

    IF contri <> currentcountry THEN
      SetCountry(currentcountry);

  END;

  (* --------------------------------------------------------------- *)

  FUNCTION TimeStampForm(mask : String; value : TimeStamp) : String;
  VAR
    wrk : String;

  BEGIN
    wrk := '';
    IF Pos('W', mask) > 0 THEN
      wrk := wrk + DayString[value.WDay] + Blank;
    IF Pos('D', mask) > 0 THEN
      wrk := wrk + DateForm('yyyy/mm/dd', value.D) + Blank;
    IF Pos('T', mask) > 0 THEN
      wrk := wrk + TimeForm('hh:mm:ss', value.T) + Blank;
    IF Pos('Z', mask) > 0 THEN
      wrk := wrk + value.Indic + Blank;
    IF Pos('S', mask) > 0 THEN
      wrk := wrk + BooleanForm('Y', value.IsDst) + Blank;
    TimeStampForm := wrk;
  END;

  (* --------------------------------------------------------------- *)

  FUNCTION inspect(C : Char; S : String) : Byte;
  VAR
    i, j : Byte;
  BEGIN
    j := 0;
    FOR i := 1 TO Length(S) DO
      IF S[i] = C THEN Inc(j);
    inspect := j;

  END;
  (* --------------------------------------------------------------- *)

 {$IFOPT N+}
  Function DoubleForm (mask:string; value: double) : string;
  var S : string;
  begin
     if mask[1] = 'E' then
     begin
      Str ( Value: length(mask ),S);
      DoubleForm := S;
     end
    else
     DoubleForm := '**********';
  end;

    Function ExtendedForm (mask:string; value: extended) : string;
  var S : string;
  begin
     if mask[1] = 'E' then
     begin
      Str ( Value: length(mask ),S);
      ExtendedForm := S;
     end
    else
     ExtendedForm := '**********';
  end;

 (* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
   procedure ChangeDecCommaChar (DC,CC : char);
   begin
      ChangeDecimalChar(DC);
      CommaChar := CC;
   end;
 (* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

   function HelpCurrency    (value        : byte ;
                             pays         : str3 ;
                             info         : tcountryinfo ) : string ;
var
   S : string[20];
    contri     : str3;

  begin
      contri := pays;
      If contri <> currentcountry then
       SetCountry (Contri);

     if info = dos3 then
       begin
         S := InternationalCurrency('#',value,false,true);
         if length(CurrencyLtStr) = 1 then
          S := Substitute(S,'c','$');
         HelpCurrency := S;
     end
   else
     begin
         S := InternationalCurrency('#',value,false,true);
         CurrencyIso(pays);
         S := Filter (S,['c','C']);
         S :=  S + ' CCC';
         HelpCurrency := S;
     end;

   If contri <> currentcountry  then
     SetCountry (Currentcountry);

 end;


function NextPos (objet,target :string;
                  last_pos : integer;
                  ignore_case : boolean): integer;
{ scan the string TARGET to find the next occurence of the OBJECT within
  the TARGET }

     var
      npos,i,j : integer;
      same_so_far: boolean;

   begin
     if ignore_case then
       begin
         target:= StUpCase (Target);
         objet:= StUpCase (objet);
       end;
      npos := -1;
      i := last_pos + 1;

      while npos < 0 do
         if i > (length (target) - length (objet) + 1) then
           npos := 0
         else
           begin
             j:= 1;
             same_so_far := true;
             while same_so_far and (j <= length (objet)) do
              if target [i+j-1] = objet[j] then
                j := j + 1
              else
                same_so_far := false;

             if same_so_far then npos := i
             else                i := i + 1;
           end;
      nextpos := npos;
    end;

procedure ReplaceFirst ( var Target : string;
                         oldsubstr,newsubstr : string;
                         ignore_case : boolean;
                         var oldsubstr_found : boolean);
   var
     npos : integer;

   begin
     npos := NextPos (oldsubstr, target, 0, ignore_case);
     if npos > 0 then
         begin
            delete (target,npos,length(oldsubstr));
            insert (newsubstr,target,npos);
            oldsubstr_found := true;
         end
     else
        oldsubstr_found := false;
   end;


procedure ReplaceAll   ( var Target : string;
                         oldsubstr,newsubstr : string;
                         ignore_case : boolean;
                         var num_substitutions : integer);
   var
     npos : integer;

   begin
     num_substitutions := 0;
     npos := 0;
     repeat
         npos := nextpos (oldsubstr,target,npos,ignore_case);
         if npos > 0 then
           begin
             delete (target,npos,length(oldsubstr));
             insert (newsubstr,target,npos);
             npos := npos + length(newsubstr);
             num_substitutions := num_substitutions + 1;
           end;
     until npos = 0;
   end;


 (* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
  function CurrencyForm (mask:string;valeur: currency): string;
      var S,mask2 : string;
          value: currency;
          N1,N2,N3 : byte;
          inter : string[5];
          found : boolean;
          nbr   : integer;

  begin
     value := valeur / scale_currency;
     case  mask[1] of
     '(':
     begin
        delete(mask,1,1);

        if value < 0 then
          begin
           S := '(' + Form(Mask,value)+')';
           if pos('#',Mask) <> 0 then
           delete(S,2,1);
          end
        else
           S := Form(Mask,value);
     end ;
     'D':
     begin
        delete(mask,1,1);
        if value < 0 then
        begin
           S :=  Form(Mask,value)+'DB';
           if pos('#',Mask) <> 0 then
           delete(S,1,1);
          end
        else
           S := Form(Mask,value);
     end ;
     'R':
     begin
        delete(mask,1,1);
        if value < 0 then
        begin
           S :=  Form(Mask,value)+'CR';
           if pos('#',Mask) <> 0 then
           delete(S,1,1);
          end
        else
          S := Form(Mask,value);
     end ;
     'B' :
     begin
        delete(mask,1,1);
        if value = 0 then
           S :=''
        else
           S := Form(Mask,value);
      end
     else
           S := Form(Mask,value);
    end;

    N3 := 0;
    N3 := inspect(DecimalPt,mask);
    if N3 > 0 then
      begin
       N1 := pos(DecimalPt,S);
       N2 := pos(comma,S);
       S[N2] := CommaChar;
       S[N1] := DecimalChar;
      end
      else
         begin
           N3 := pos (' ',S);
           insert(DecimalPt,Mask,N3);
           N3 := pos (DecimalPt,mask);
           S:= Form(Mask,value);
           ReplaceAll(S ,comma,CommaChar,false,nbr);
           delete(S,N3,1);
         end;

    N1 := pos('$',S);
    if N1 > 0 then
        begin
            delete(S,N1,1);
            S:= TrimLead (S);
            S := MoneySign + S;
        end;

    N1 := inspect(CurrencyLt,S);
    If N1 > 0 then
      begin
        Inter := CharStr(CurrencyLt,N1);
        ReplaceFirst(S ,Inter,CurrencyLtStr,false,found);
      end;

    N2 := inspect(CurrencyRt,S);
    If N2 > 0 then
      begin
        Inter := CharStr(CurrencyRt,N2);
        ReplaceFirst(S ,Inter,CurrencyRtStr,false,found);
      end;
    CurrencyForm := S;
  end;

 {$ENDIF}
  (* --------------------------------------------------------------- *)
  FUNCTION RealForm(mask : String; value : Real) : String;
  VAR S : String;
  BEGIN
    CASE mask[1] OF
      'E' :
        BEGIN
          Str(value:Length(mask), S);
          RealForm := S;
        END;
      '%' :
        BEGIN
          Delete(mask, 1, 1);
          RealForm := form(mask, value * 100) + '%';
        END;
      '(' :
        BEGIN
          Delete(mask, 1, 1);

          IF value < 0 THEN
          BEGIN
            S := '(' + form(mask, value) + ')';
            IF Pos('#', mask) <> 0 THEN
              Delete(S, 2, 1);
            RealForm := S;
          END
          ELSE
            RealForm := form(mask, value);
        END;
      'D' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            S := form(mask, value) + 'DB';
            IF Pos('#', mask) <> 0 THEN
              Delete(S, 1, 1);
            RealForm := S;
          END
          ELSE
            RealForm := form(mask, value);
        END;
      'R' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            S := form(mask, value) + 'CR';
            IF Pos('#', mask) <> 0 THEN
              Delete(S, 1, 1);
            RealForm := S;
          END
          ELSE
            RealForm := form(mask, value);
        END;
      'B' :
        BEGIN
          Delete(mask, 1, 1);
          IF value = 0 THEN
            RealForm := ''
          ELSE
            RealForm := form(mask, value);
        END;
      'S' :
        BEGIN
          Delete(mask, 1, 1);
          RealForm := SymbolStr + Blank + form(mask, value);
        END;
      's' :
        BEGIN
          Delete(mask, 1, 1);
          RealForm := SymbolStr + form(mask, value);
        END
    ELSE
      RealForm := form(mask, value);
    END;

    IF Copy(mask, Length(mask), 1) = 'S' THEN
    BEGIN
      Delete(mask, Length(mask), 1);
      RealForm := form(mask, value) + Blank + SymbolStr;
    END;

    IF Copy(mask, Length(mask), 1) = 's' THEN
    BEGIN
      Delete(mask, Length(mask), 1);
      RealForm := form(mask, value) + SymbolStr;
    END;
  END;
  (* --------------------------------------------------------------- *)
  FUNCTION LongintForm(mask : String; value : LongInt) : String;

  VAR wrk : String;
  BEGIN
    CASE mask[1] OF
      'K' :
        BEGIN
          wrk := HexL(value);
          IF Length(mask) < 8 THEN
            Delete(wrk, 1, 8 - Length(mask));
          LongintForm := HexaChar + wrk;
        END;
      'b' :
        LongintForm := BinaryL(value);
      '(' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            wrk := '(' + opstring.LongintForm(mask, value) + ')';
            
            IF Pos('#', mask) <> 0 THEN
              Delete(wrk, 2, 1);
            LongintForm := wrk;
          END
          ELSE
            LongintForm := opstring.LongintForm(mask, value);
        END;
      'D' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            wrk := '(' + opstring.LongintForm(mask, value) + 'DB';
            IF Pos('#', mask) <> 0 THEN
              Delete(wrk, 2, 1);
            LongintForm := wrk;
          END
          ELSE
            LongintForm := opstring.LongintForm(mask, value);
        END;
      'R' :
        BEGIN
          Delete(mask, 1, 1);
          IF value < 0 THEN
          BEGIN
            wrk := '(' + opstring.LongintForm(mask, value) + 'CR';
            IF Pos('#', mask) <> 0 THEN
              Delete(wrk, 2, 1);
            LongintForm := wrk;
          END
          ELSE
            LongintForm := opstring.LongintForm(mask, value);
        END;
    ELSE
      LongintForm := opstring.LongintForm(mask, value);
    END;
  END;
  (* --------------------------------------------------------------- *)
  FUNCTION ByteForm(mask : String; value : Byte) : String;
  VAR wrk : String;
  BEGIN
    IF mask[1] = 'K' THEN
    BEGIN
      wrk := HexB(value);
      IF Length(mask) < 2 THEN
        Delete(wrk, 1, 2 - Length(mask));
      ByteForm := HexaChar + wrk;
    END
    ELSE
      IF mask[1] = 'b' THEN
        ByteForm := BinaryB(value)
    ELSE
      ByteForm := opstring.LongintForm(mask, value);
  END;
  (* --------------------------------------------------------------- *)
  FUNCTION WordForm(mask : String; value : Word) : String;
  VAR wrk : String;
  BEGIN
    IF mask[1] = 'K' THEN
    BEGIN
      wrk := HexW(value);
      IF Length(mask) < 4 THEN
        Delete(wrk, 1, 4 - Length(mask));
      WordForm := HexaChar + wrk;
    END
    ELSE
      IF mask[1] = 'b' THEN
        WordForm := BinaryW(value)
    ELSE
      WordForm := opstring.LongintForm(mask, value);
  END;
  (* --------------------------------------------------------------- *)
  FUNCTION Proper(objet : String) : String;
  CONST
    WordDelim : CharSet = [' ', '-'];
    n : Word = 0;
  VAR
    wrk : String;
    i : Byte;
  BEGIN
    wrk := StLoCase(objet);
    wrk[1] := Upcase(wrk[1]);
    n := WordCount(objet, WordDelim);
    IF n > 0 THEN
    BEGIN
      FOR i := 1 TO n DO
        wrk[WordPosition(i, wrk, WordDelim)] :=
        Upcase(wrk[WordPosition(i, wrk, WordDelim)]);
    END;
    Proper := wrk;
  END;

  (* --------------------------------------------------------------- *)
  FUNCTION StringForm(mask : String; value : String) : String;

  VAR
    i, len, nbre : Byte;
    Str, mask1, mask2 : String;

  BEGIN
    Str := ''; i := 1;
    nbre := WordCount(mask, Delimitor);
    IF nbre = 2 THEN
    BEGIN
      mask1 := Copy(mask, 1, (WordPosition(2, mask, Delimitor) - 2));
      mask2 := Copy(mask, (WordPosition(2, mask, Delimitor)), Length(mask));
    END
    ELSE
      mask2 := mask;


    IF (Length(value) < Length(mask2)) AND (Pos('&', mask2) = 0) THEN
      len := Length(value)
    ELSE len := Length(mask2);

    nbre := 1;

    IF mask2[1] = 'x' THEN Str := Proper(Copy(value, 1, len))
    ELSE
    BEGIN
      WHILE nbre <= len DO
      BEGIN
        CASE mask2[nbre] OF
          'X' : Str := Str + value[i];
          '!' : Str := Str + Upcase(value[i]);
          'L' : Str := Str + Locase(value[i]);
          '&' : Str := Str + PadChar;
          'a' : IF value[i] IN AlphaOnlySet THEN Str := Str + value[i]
                ELSE Str := Str + Blank;
          'A' : IF value[i] IN AlphaOnlySet THEN Str := Str + Upcase(value[i])
                ELSE Str := Str + Blank;
          'l' : IF value[i] IN AlphaOnlySet THEN Str := Str + Locase(value[i])
                ELSE Str := Str + Blank;
        ELSE
          Str := Str + mask2[i];
        END;

        Inc(nbre);
        IF mask2[nbre] <> '&' THEN Inc(i);
      END;
    END;

    IF mask1 = 'C' THEN Str := Center(Str, Length(mask2));
    IF mask1 = 'CC' THEN Str := CenterCh(Str, PadChar, Length(mask2));
    IF mask1 = 'AR' THEN Str := LeftPad(Str, Length(mask2));
    IF mask1 = 'ARC' THEN Str := LeftPadCh(Str, PadChar, Length(mask2));
    IF mask1 = 'AL' THEN Str := Pad(Str, Length(mask2));
    IF mask1 = 'ALC' THEN Str := PadCh(Str, PadChar, Length(mask2));
    IF mask1 = 'T' THEN Str := Trim(Str);
    IF mask1 = 'TL' THEN Str := TrimLead(Str);
    IF mask1 = 'TT' THEN Str := TrimTrail(Str);
    IF mask1 = 'TS' THEN Str := TrimSpaces(Str);
    
    StringForm := Str;

  END;


END.
{ -----------------------  DEMO PROGRAM ------------------ }

program demoform;
{$N+,E+}
uses crt,
     nlcs,editform,
     opstring,business,opdate;

var
I1,I2 : integer;
R1,R2 : real;
C1,C2 : currency;
S1,S2 : string[10];
H1,H2 : char;
B1    : boolean;
P ,P2 : pointer;
DT    : daytype;
D     : date;
w     : longint;
Wch   :  char;

begin
clrscr;
 SymbolStr := 'Kgm';
I1 := -1234; R1 := -1234.56;
C1 := ToCurrency(I1);
B1 := false;
H1 := 'c'; H2 := #10;
P := @SymbolStr;
FalseUserStr := 'Nul';
TrueUserStr  := 'Rempli';
DT := sunday;
S1 := 'Santé';

Writeln ('DEMO EDITFORM ');
Writeln ('I1 = -1234  R1 = -1234.56');
Writeln;

writeln(IntegerForm('#####',I1));
writeln(IntegerForm('+#####',I1));
writeln(IntegerForm('#####+',I1));
writeln(IntegerForm('(#####',I1));
writeln(RealForm('#####.##',R1));
writeln(RealForm('+#####',R1));
writeln(RealForm('#####.##+',R1));
writeln(RealForm('(#####.##',R1));
writeln(RealForm('D#####,##',R1));
writeln(RealForm('S#####.##',R1));
writeln(RealForm('s#####.##',R1));
writeln(RealForm('#####.##S',R1));
writeln(RealForm('#####.##s',R1));
writeln(RealForm('##.###,##s',R1));

writeln;
writeln('Appuyez sur une touche');
    WCh := Readkey;
clrscr;

Writeln(' HelpDate et HelpTime ');
writeln;
Writeln (HelpDate(currentcountry));

Writeln ('49 ',HelpTime('49'));
Writeln ('01 ',HelpTime('US'));
Writeln ('02 ',HelpTime('2'));
Writeln ('03 ',HelpTime('3'));
Writeln ('dk ',HelpDate('DK'));
Writeln ('2 ',HelpDate('2'));
Writeln ('46 ',HelpDate('46'));

Writeln ('FR ',HelpDate('FR'));

writeln;
writeln('Appuyez sur une touche');
WCh := Readkey;
clrscr;

writeln('Devise locale   : ' ,CurrencyForm('cc##,###.##+',C1),
                         '   ',CurrencyForm('##,###.## CC',C1));
Writeln;

Writeln ( '  Convention  DOS  3');writeln;

writeln( 'US: ',CurrencyForm(Helpcurrency(8,'1',dos3),C1));
writeln('IT: ',CurrencyForm(Helpcurrency(8,'39',dos3),C1));
writeln('FR: ',CurrencyForm(Helpcurrency(6,'33',dos3),C1));
writeln('DE: ',CurrencyForm(Helpcurrency(6,'DE',dos3),C1));
writeln('081: ',CurrencyForm(Helpcurrency(6,'81',dos3),C1));

Writeln;
MoneySign := 'F';
writeln('Symbole monétaire flottant: ',CurrencyForm('$##,###.##+',C1));
Writeln;

Writeln ( 'Convention internationale ');writeln;
writeln(CurrencyForm(Helpcurrency(5,'PT',iso),C1));
writeln(CurrencyForm(Helpcurrency(5,'US',iso),C1));
writeln(CurrencyForm(Helpcurrency(5,'IT',iso),C1));
writeln(CurrencyForm(Helpcurrency(5,'DE',iso),C1));
writeln(CurrencyForm(Helpcurrency(5,'FR',iso),C1));

writeln;
writeln('Appuyez sur une touche');
WCh := Readkey;
clrscr;

writeln('PointerForm et BooleanForm');
writeln(' SymbolStr = "Kgm" ; B1 = false; P := @SymbolStr');
writeln;

writeln(PointerForm('Ps',P));
writeln(PointerForm('Pn',P));
writeln(PointerForm('Pl',P));

writeln('B1 ',BooleanForm('B',B1));
writeln('B1 ',BooleanForm('Y',B1));
writeln('B1 ',BooleanForm('O',B1));
writeln('B1 ',BooleanForm('U',B1));


writeln('Appuyez sur une touche');
WCh := Readkey;
clrscr;

writeln('CharForm et StringForm H1 = "c" ; H2 = #10; S1 := "Santé"');
writeln;
writeln('H1 ',CharForm('!',H1));
writeln('H1 ',CharForm('D',H1));
writeln('H1 ',CharForm('K ',H1));
writeln('H1 ',CharForm('^',H1));
writeln;
writeln('H2 ',CharForm('^',H2));
writeln('H2 ',CharForm('X',H2));
writeln('H2 ',CharForm('D',H2));

writeln;
writeln(StringForm('!!!!!!',S1));
writeln(StringForm('XXXXXX',S1));
writeln(StringForm('X&X&X&X&X&',S1));

writeln;
writeln('Appuyez sur une touche');
WCh := Readkey;
end.
