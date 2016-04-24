(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0113.PAS
  Description: BASIC String Functions
  Author: JOSEPH COUSINS
  Date: 05-27-95  10:34
*)


{  File:  Basics.Pas }
{+------------------------------------------------------------------+}
{: Unit  : Basics   ( BASIC functions in Turbo Pascal )             :}
{+------------------------------------------------------------------+}
{: Author : Joseph L. Cousins                                       :}
{:                                                                  :}
{:    for : Sierra Consultants                                      :}
{:          3500 Hawthorne Road                                     :}
{:          Fredericksburg, Virginia 22407-6819                     :}
{:          (703) 785-9472, (703) 786-2316                          :}
{:          CompuServe ID = [70245,374]                             :}
{:          Internet      = jcousins@ix.netcom.com                  :}
{:                                                                  :}
{: Copyright (c) 1992-95 by Sierra Consultants  All Rights Reserved :}
{:                                                                  :}
{+------------------------------------------------------------------+}
Unit Basics;

Interface

Uses
    Dos,
    CRT,
    Printer;
{.pa}
{+------------------------------------------------------------------+}
{: The following are the descriptions of the Functions and Procedures}
{+------------------------------------------------------------------+}
Function Left(inString : String; numChars : Byte) : String;
Function Right(inString : String; numChars : Byte) : String;
Function Len(inString : String) : Byte;
Function LTrim(inString : String) : String;
Function RTrim(inString : String) : String;
Function Trim(inString : String) : String;
Function Empty(inString : String) : Boolean;
Function SubStr(inString : String; numChars, strSize : Byte) : String;
Function PutStr(inString,putString: String; where: Byte) : String;
Function Stuff(putString, inString: String; where: Integer) : String;
Function Lower(inString : String) : String;
Function Upper(inString : String) : String;
Function Instr(Temp_Item: String; From, Size: Byte): String;
Function NoTrailZeros(tempStr : String) : String;
Function MkStr(I,W:Integer) : String;
Function Spaces(i:Byte):String;
Function LeadZeros(inString :String) : String;
Function Str2Bin(inString :String) : Real;
Function IfStr( Text, Pattern : String) : Integer;
Function PrnOk : Boolean;
Procedure LPrint(PrnString : String);
Procedure Eject;
Procedure Beep;
Function Time : String;
Function Date : String;
Function Month : String;
Function WeekDay : String;
Function DayOfWeek( Day : Integer ): String;
Function DateStr : String;
Function Fix(x : Real): Real;
Function Int(x : Real): Real;
Function OCT( Value : Longint ): String;
Function Hex( Value : Longint ): String;
Function ASC( inString : String ): Byte;
Function RAD( Degrees : Real ): Real;
Function DEG( Radians : Real ): Real;
Function LOG( x : Real ): Real;
Function SGN( x : Integer ): Integer;
Procedure DefSeg( SegValue : Integer );
Function Peek( Offset : Word ): Byte;
Function PeekW( Offset : Word ): Word;
Function PeekL( Offset : Word ): Longint;
Procedure Poke( Offset: Word; Value : Byte );
Function TAN( x : Real ): Real;  { input must be in radians }
Function Input( prompt : String): String;
Function InputS( prompt : String): String;
Function InputI( prompt : String): Integer;
Function InputR( prompt : String): Real;
Procedure PrintAT(Row, Col : Word; Tex : string);
Procedure Print(Tex : String);
Procedure CursorOn;
Procedure CursorOff;
{.pa}
const

  WeekDays : Array[1..7] of String =
                         ('Sunday','Monday','Tuesday','Wednesday',
                          'Thursday','Friday','Saturday');

  Months   : Array[1..12] of String =
                          ('January','February','March','April','May',
                           'June','July','August','September','October',
                           'November','December');
  CR = Chr(13);
  LF = Chr(10);
  FF = Chr(12);
  ESC = Chr(27);
  BS = Chr(08);
  Space = ' ';
  Yes = True;
  No = False;

Var
   Segment  : Word;         { Preset to zero }
   GMT      : Boolean;
   Suppress : Boolean;

Implementation

{+-------------------------------------------------------+}
{: Function :  PrnOk ( checks status of printer )        :}
{+-------------------------------------------------------+}
{:    Syntax : PrnOk                                     :}
{:                                                       :}
{:    Action : Test printer status through MSDOS and     :}
{:             returns TRUE if printer is available.     :}
{:                                                       :}
{: Result Type :  Boolean                                :}
{+-------------------------------------------------------+}
Function PrnOk: Boolean;
Var
  Rg : Registers;
Begin
  Rg.AH    := $02;  { Get Status }
  Rg.DX    := $0000; { Use printer 0 }
  Intr($17,Rg);  { MsDos Service request    }
  PrnOk := True;
  If Rg.AH <> $90 then
    PrnOk := False
End;
{.pa}

{+-------------------------------------------------------+}
{: Procedure : LPrint ( Print string to printer )        :}
{+-------------------------------------------------------+}
{:    Syntax : LPrint ( <expS1> )                        :}
{:                                                       :}
{:     Where : <expS1> = String expression               :}
{:                                                       :}
{:    Action : Sends the string expression to the printer:}
{:             using the MSDOS interrupt 17h.            :}
{:                                                       :}
{+-------------------------------------------------------+}
Procedure LPrint(PrnString : String);
Var
  Pi,Pj : Integer;
  Rg : Registers;
Begin
  If PrnOk then
    Begin
      PrnString := PrnString+CR+LF;
      Pj := Ord(PrnString[0]);
      For Pi := 1 To Pj Do
        Begin
          Rg.AL := Ord(PrnString[Pi]);
          Rg.AH := $00;
          Rg.DX := $0000;
          Intr($17,Rg);
        End;
    End;
End;
{.pa}

Procedure Eject;
Begin
  LPrint(FF);   { do an eject on printer}
End;

Procedure Beep;
Begin
  Write(Chr(07));
End;
{.pa}
{+---------------------------------------------------------------------+}
{: Function FIX   -    Truncates x to an integer                       :}
{+---------------------------------------------------------------------+}
{: format :    v = FIX(x)                                              :}
{:                         FIX strips all  digits to the right of the  :}
{:                         decimal point and returns the value of the  :}
{:                         digits to the left of the decimal point.    :}
{:                                                                     :}
{:  The difference between FIX and INT is that FIX does not return the :}
{:  next lower number when x is negative.                              :}
{+---------------------------------------------------------------------+}
FUNCTION Fix(x : Real): Real;
Begin
  Fix := x - Frac(x);
End;

{+---------------------------------------------------------------------+}
{: Function INT   -    Truncates x to an integer                       :}
{+---------------------------------------------------------------------+}
{: format :    v = INT(x)                                              :}
{:                         INT strips all  digits to the right of the  :}
{:                         decimal point and returns the value of the  :}
{:                         digits to the left of the decimal point.    :}
{:                                                                     :}
{:  The difference between FIX and INT is that FIX does not return the :}
{:  next lower number when x is negative.                              :}
{+---------------------------------------------------------------------+}
FUNCTION Int(x : Real): Real;
Begin
  If x < 0 Then
    If Frac(x) >= 0.5 Then
      Int := (x+1) - Frac(x)
    Else
      Int := Fix(x)
  Else
    Int := Fix(x)
End;
{.pa}
{+-----------------------------------------------------------+}
{: Procedure:    T i m e  ( convert system time to string )  :}
{+-----------------------------------------------------------+}
{:   This Procedure Builds the current time of day by getting:}
{: the time from DOS and converting it To ascii.             :}
{+-----------------------------------------------------------+}
Function Time: String;
Var
   AmPm : Char;
   Hr, Mn, Sc, Sc100 : Word;
   t1, t2, t3 : String;
Begin
  GetTime(Hr,Mn,Sc,Sc100);
  AmPm := 'a';
  If Hr >= 12 Then
    Begin
      AmPm := 'p';
      If GMT = False then
        Begin
          If Hr > 12 Then
            Hr := Hr - 12;
        End;
    End;
  Str(Hr:2,t1);
  If GMT then
    If Hr < 10 Then
      t1[1] := Chr(48);
  Str(Mn:2,t2);
  If Mn < 10 Then
    t2[1] := Chr(48);
  Str(Sc:2,t3);
  If Sc < 10 Then
    t3[1] := Chr(48);
  If GMT Then
    AmPm := ' ';
  Time := t1+':'+t2+':'+t3+AmPm;
End;
{.pa}
{+-----------------------------------------------------------+}
{: Procedure:    D a t e   ( convert system date to ascii )  :}
{+-----------------------------------------------------------+}
{:   This Procedure Builds the current Date by getting the   :}
{: date from DOS and converting it To an ascii string.       :}
{+-----------------------------------------------------------+}
Function Date : String;
Var
   Y,M,D,Week  : Word;
   t1, t2, t3 : String;
Begin
  GetDate(Y,M,D,Week);
  Str(M:2,t1);
  If M < 10  Then
    t1[1] := '0';
  Str(D:2,t2);
  If D < 10 Then
    t2[1] := '0';
  Str(Y:4,t3);
  Date := t1+'/'+t2+'/'+t3;
End;
{.pa}

{+-------------------------------------------------------+}
{: Function :  Month   ( get name of month )             :}
{+-------------------------------------------------------+}
{:    Syntax : Month                                     :}
{:                                                       :}
{:    Action : Obtains date from MSDOS and returns the   :}
{:             ASCII string containing the Name of the   :}
{:             current Month.                            :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Month : String;
Var
   Y,M,D,Week  : Word;
Begin
  GetDate(Y,M,D,Week);
  Month := Months[M];
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  WeekDay ( get day of week )               :}
{+-------------------------------------------------------+}
{:    Syntax : WeekDay                                   :}
{:                                                       :}
{:    Action : Obtains date from MSDOS and returns the   :}
{:             ASCII string containing the Name of the   :}
{:             current Day of the Week.                  :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function WeekDay : String;
Var
   Y,M,D,Week  : Word;
Begin
  GetDate(Y,M,D,Week);
  WeekDay := WeekDays[Week+1];
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  DayOfWeek  ( Get Day of the Week )        :}
{+-------------------------------------------------------+}
{:    Syntax : DayOfWeek ( <expN1> )                     :}
{:                                                       :}
{:    Action : Uses Day input value to obtain Weekday    :}
{:             ASCII string from constant array.         :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function DayOfWeek( Day : Integer ): String;
Begin
  DayOfWeek := WeekDays[Day+1];
End;

{+-------------------------------------------------------+}
{: Function :  DateStr  ( return date string )           :}
{+-------------------------------------------------------+}
{:    Syntax : DateStr                                   :}
{:                                                       :}
{:    Action : Obtains date from MSDOS and returns the   :}
{:             ASCII string containing the Month, the    :}
{:             Day, the Year and the Day-of-Week         :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function DateStr : String;
Var
   Y,M,D,Week  : Word;
   t1, t2, t3 : String;
Begin
  GetDate(Y,M,D,Week);
  Str(M:2,t1);
  If M < 10  Then
    t1[1] := '0';
  Str(D:2,t2);
  If D < 10 Then
    t2[1] := '0';
  Str(Y:4,t3);
  DateStr := Months[M]+' '+t2+', '+t3+' - '+WeekDay;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  LEFT                                      :}
{+-------------------------------------------------------+}
{:    Syntax : LEFT ( <expC> , <expN> )                  :}
{:                                                       :}
{:     where : <expC> = character string                 :}
{:             <expN> = number of characters to return   :}
{:                      Integer value                    :}
{:                                                       :}
{:    Action : Returns a specified number of characters  :}
{:             in the character string <expC>, starting  :}
{:             from the leftmost character.              :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Left;
Begin
  Left := Copy(inString,1,numChars)
End;

{+-------------------------------------------------------+}
{: Function :  RIGHT                                     :}
{+-------------------------------------------------------+}
{:    Syntax : RIGHT ( <expC> , <expN> )                 :}
{:                                                       :}
{:     where : <expC> = character string                 :}
{:             <expN> = number of characters to return   :}
{:                      Integer value                    :}
{:                                                       :}
{:    Action : Returns the rightmost <expN> portion of a :}
{:             character string <expC>                   :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Right;
Var
  index : Byte;
Begin
  If numChars >= Length(inString) Then
    Right := inString
  Else
    Begin
      index := Length(inString) - numChars+1;
      Right := Copy(inString,index,numChars)
    End
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  LEN                                       :}
{+-------------------------------------------------------+}
{:    Syntax : LEN ( <expC> )                            :}
{:                                                       :}
{:     where : <expC> = character string                 :}
{:                                                       :}
{:    Action : Returns the dynamic length of character   :}
{:             string <expC>.  Nonprinting characters    :}
{:             and blanks are counted.                   :}
{:                                                       :}
{: Result Type :  Integer                                :}
{+-------------------------------------------------------+}
Function Len;
Begin
  Len :=  Ord(inString[0]);
End;

{+-------------------------------------------------------+}
{: Function :  LTRIM                                     :}
{+-------------------------------------------------------+}
{:    Syntax : LTRIM ( <expC1> )                         :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Returns <expC1> with all leading SPACES   :}
{:             (blanks) removed.                         :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function LTrim;
Var
  p : Integer;
Begin
  p := 1;
  While (inString[p] = '') and (p <= Length(inString)) Do
    inc( p );
  If p > 1 Then
    Begin
      Move( inString[p], inString[1], Succ(Length(inString)) - p);
      dec(inString[0], pred(p));
    End;
   LTrim := inString;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  RTRIM                                     :}
{+-------------------------------------------------------+}
{:    Syntax : RTRIM ( <expC1> )                         :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Returns <expC1> with all trailing SPACES  :}
{:             (blanks) removed.                         :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function RTrim;
Begin
  While inString[Length(inString)] = ' ' Do
    dec( inString[0] );
  RTrim := inString;
End;

{+-------------------------------------------------------+}
{: Function :  Trim                                      :}
{+-------------------------------------------------------+}
{:    Syntax :  Trim ( <expC1> )                         :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Returns <expC1> with all trailing SPACES  :}
{:             (blanks) removed.                         :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Trim( inString : String ): String;
Begin
  Trim := RTrim( inString );
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  EMPTY                                     :}
{+-------------------------------------------------------+}
{:    Syntax : EMPTY ( <expC1> )                         :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Returns TRUE if <expC1> contains only     :}
{:             SPACES (blanks).                          :}
{:                                                       :}
{: Result Type :  Boolean                                :}
{+-------------------------------------------------------+}
Function Empty;
Var
  index : Byte;
Begin
  index := 1;
  Empty := True;
  While (index <= Length(inString))and (index <> 0) do
    Begin
      If inString[index] = ' ' Then
	inc(index)
      Else
	Begin
	  Empty := False;
	  index := 0
	End;
    End;
End;

{.pa}
{+-------------------------------------------------------+}
{: Function :  SUBSTR                                    :}
{+-------------------------------------------------------+}
{:    Syntax : SUBSTR ( <expC>, <expN1>[, <expN2>] )     :}
{:                                                       :}
{:     where : <expC> = character string                 :}
{:             <expN1>,<expN2> = numeric value (Byte)    :}
{:                                                       :}
{:    Action : Returns a string of length <expN2> from   :}
{:             <expC>, beginning with the <expN1>th      :}
{:             character.  The <expN1> and <expN2> must  :}
{:             be in the range 1 to 255.  If <expN2> is  :}
{:             omitted or if there is fewer than <expN2> :}
{:             characters to the right of the <expN1>th  :}
{:             character, all rightmost characters       :}
{:             beginning with the <expN1>th character are:}
{:             returned.  If <expN1> is greater than the :}
{:             number of characters in <expC>, SUBSTR    :}
{:             returns a null string.                    :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function SubStr;
Begin
  SubStr := Copy(inString, numChars, StrSize );
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  PUTSTR                                    :}
{+-------------------------------------------------------+}
{:    Syntax : PUTSTR ( <expC1>, <expC2>, <expN1> )      :}
{:                                                       :}
{:     where : <expC1>,<expC2> = character string        :}
{:             <expN1> = numeric value (Byte)            :}
{:                                                       :}
{:    Action : Replaces a portion of one string <expC1>  :}
{:             with another string <expC2>.  The         :}
{:             characters in <expC1> beginning at        :}
{:             position <expN1> are replaced by the      :}
{:             characters in <expC2>.  The number of     :}
{:             characters replaced is equal to the length:}
{:             of string <expC2>.  However, the          :}
{:             replacement of characters never goes      :}
{:             beyond the original length of <expC1>.    :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function PutStr;
Var
  index, j : Byte;
Begin
  index := Ord(putString[0]);    { get size of input string}
  For j := where to where + (index-1) do
    inString[j] := putString[(j+1)-where];
  PutStr := inString;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  Stuff                                     :}
{+-------------------------------------------------------+}
{:    Syntax : Stuff  ( <expC1>, <expC2>, <expN1> )      :}
{:                                                       :}
{:     where : <expC1>,<expC2> = character string        :}
{:             <expN1> = numeric value (Byte)            :}
{:                                                       :}
{:    Action : Replaces a portion of one string <expC2>  :}
{:             with another string <expC1>.  The         :}
{:             characters in <expC2> beginning at        :}
{:             position <expN1> are replaced by the      :}
{:             characters in <expC1>.  The number of     :}
{:             characters replaced is equal to the length:}
{:             of string <expC1>.  However, the          :}
{:             replacement of characters never goes      :}
{:             beyond the original length of <expC2>.    :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Stuff;
Begin
  Insert(putString, inString, where);
  Stuff := inString;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  LOWER                                     :}
{+-------------------------------------------------------+}
{:    Syntax : LOWER ( <expC1> )                         :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Returns the specified character           :}
{:             expression <expC1> in lowercase.          :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Lower;
Var
  index : Byte;  tempString : String;
Const
    Upset = ['A'..'Z'];
    LowSet = ['a'..'z'];
Begin
  For index := 1 to Length(inString) do
    Begin
      If inString[index] in UpSet Then
	tempString[index] := Chr(Ord(inString[index])+32)
      Else
	TempString[index] := inString[index];
    End;
  Lower := tempString;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  UPPER                                     :}
{+-------------------------------------------------------+}
{:    Syntax : UPPER ( <expC1> )                         :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Returns the specified character           :}
{:             expression <expC1> in uppercase.          :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Upper;
Var
  index : Byte;
  tempString : String;
Begin
  For index := 1 to Length(inString) do
     tempString[index] := UpCase(inString[index]);
  tempString[0] := inString[0];
  Upper := tempString;
End;

{+-----------------------------------------------------------+}
{: Function:    I n s t r  ( Instring )                      :}
{+-----------------------------------------------------------+}
{:   This function extracts a string beginning at pointer    :}
{: From in string Temp_Item for Size chars and returns Value.:}
{+-----------------------------------------------------------+}
Function Instr;
Begin
  Instr := Copy(Temp_Item, From, Size);
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  NoTrailZeros                              :}
{+-------------------------------------------------------+}
{:    Syntax : NoTrailZeros ( <expC1> )                  :}
{:                                                       :}
{:     where : <expC1> = character string                :}
{:                                                       :}
{:    Action : Removes trailing Zeros from the specified :}
{:             expression <expC1>.                       :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function NoTrailZeros;
Var
  index : Integer;
  tempString : String;
Begin
  While tempStr[Length(tempStr)] = '0' Do
    tempStr[0] := Chr(Length(tempStr)-1);
  NoTrailZeros := tempStr;
End;


{+-------------------------------------------------------+}
{: Function :  MkStr        ( Make String )              :}
{+-------------------------------------------------------+}
{:    Syntax : MkStr ( <expN1>, <expN2> )                :}
{:                                                       :}
{:     where : <expN1>,<expN2> = numeric values (integer):}
{:                                                       :}
{:    Action : Makes a string of length <expN2> from     :}
{:             Integer expression <expN1>.               :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function MkStr;
Var
  temp1 : String;
Begin
  Str(I:W,temp1);
  MKStr := temp1;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  Spaces                                    :}
{+-------------------------------------------------------+}
{:    Syntax : Spaces ( <expN1> )                        :}
{:                                                       :}
{:     where : <expN1> = numeric value ( Byte )          :}
{:                                                       :}
{:    Action : Makes a string of length <expN1> which    :}
{:             contains Space characters.                :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Spaces;
Var
  zip : String[255];
Begin
  FillChar(zip,i+1,' ');
  zip[0] := Chr(i);
  Spaces := Zip;
End;

{+-------------------------------------------------------+}
{: Function :  LeadZeros                                 :}
{+-------------------------------------------------------+}
{:    Syntax : LeadZeros ( <expC1> )                     :}
{:                                                       :}
{:     where : <expC1> = character string input          :}
{:                                                       :}
{:    Action : replace the leading spaces in a string    :}
{:             with ASCII Zeros.                         :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function LeadZeros;
Var i : Integer;
Begin
  i := 1;
  While inString[i] = ' ' do
    Begin
      inString[i] := Chr(48);
      inc(i);
    End;
  LeadZeros := inString;
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  Str2Bin ( String to Binary )              :}
{+-------------------------------------------------------+}
{:    Syntax : Str2Bin ( <expC1> )                       :}
{:                                                       :}
{:     where : <expC1> = Character string                :}
{:                                                       :}
{:    Action : converts a string containing an ASCII     :}
{:             numeric value to an number.               :}
{:                                                       :}
{: Result Type :  Real                                   :}
{+-------------------------------------------------------+}
Function Str2Bin;
Var
  i : Real;
  k : Integer;
Begin
  Val(inString,i,k);
  Str2Bin := i;
End;


{+-------------------------------------------------------+}
{: Function :  IfStr ( If StringB in StringA )           :}
{+-------------------------------------------------------+}
{:    Syntax : IfStr (<expC1>,<expC2>)                   :}
{:                                                       :}
{:     where : <expC1> = Character string                :}
{:             <expC2> = Character string                :}
{:                                                       :}
{:    Action : Determines if <expC2> exists within       :}
{:             <expC1>.                                  :}
{:                                                       :}
{: Result Type :  Integer                                :}
{: Result Values :  0 = char not in stringA              :}
{:                  1-n = position of <expC2> within     :}
{:                        <expC1>                        :}
{:                                                       :}
{+-------------------------------------------------------+}
Function IfStr( Text, Pattern  : String) : Integer;
Begin
  IfStr := Pos( Pattern, Text );
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  Oct   Binary to Octal                     :}
{+-------------------------------------------------------+}
{:    Syntax : Oct ( <expN1> )                           :}
{:                                                       :}
{:     where : <expN1> = Binary number of type Longint   :}
{:                                                       :}
{:    Action : Converts a binary number of type Longint  :}
{:             to a String containing 11 octal Digits.   :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function OCT( Value : Longint ) : String;
Var
  i : Integer;
  j : Word;
  t1   : String;
  f : Boolean;
Begin
  If Value < 0 Then
    Begin
      Value := Value - $80000000;
      F := True;
    End
  Else
    F := False;
  For i := 11 DownTo 2 Do
    Begin
      j := Value Mod 8;
      Value := Value Div 8;
      t1[i] := Chr( j+48 );
    End;
  If f Then
    Value := Value + $2;
  j := Value Mod 8;
  t1[1] := Chr( j+48 );
  t1[0] := Chr(11);
  i := 1;
  If Suppress Then
    While t1[i] = '0' Do
      Begin
        t1[i] := ' ';
        inc( i );
      End;
  OCT := LTrim( t1 );
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  Hex   Binary to Hex                       :}
{+-------------------------------------------------------+}
{:    Syntax : Hex ( <expN1> )                           :}
{:                                                       :}
{:     where : <expN1> = Binary number of type Longint   :}
{:                                                       :}
{:    Action : Converts a binary number of type Longint  :}
{:             to a String containing 8 Hex Digits.      :}
{:                                                       :}
{: Result Type :  String                                 :}
{+-------------------------------------------------------+}
Function Hex( Value : Longint ):String;
Var
   t1 : String;
   i : Integer;
   j : Word;
   f : Boolean;

  Function HexChr( HexNibble : Byte ): Char;
  Begin
    If HexNibble < 10 then
      HexChr := Chr(HexNibble+48)
    Else
      HexChr := Chr(HexNibble+55);
  End;
begin
  If Value < 0 Then
    Begin
      Value := Value - $80000000;
      F := True;
    End
  Else
    F := False;
  For i := 8 DownTo 2 Do
    Begin
      j := Value Mod 16;
      Value := Value Div 16;
      t1[i] := HexChr( j );
    End;
  If f Then
    Value := Value + $8;
  j := Value Mod 16;
  t1[1] := HexChr( j );
  t1[0] := Chr(8);
  i := 1;
  If Suppress Then
    While t1[i] = '0' Do
      Begin
        t1[i] := ' ';
        inc( i );
      End;
  HEX := LTrim( t1 );
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  ASC   Get ASCII code from String          :}
{+-------------------------------------------------------+}
{:    Syntax : ASC ( <expS1> )                           :}
{:                                                       :}
{:     where : <expS1> = ASCII String                    :}
{:                                                       :}
{:    Action : Returns the numeric value of the first    :}
{:             character of the String expression.       :}
{:                                                       :}
{: Result Type :  Byte                                   :}
{+-------------------------------------------------------+}
Function ASC( inString : String ) : Byte;
Begin
  If Length( inString ) > 0 Then
    ASC := Ord( inString[1] )
  Else
    ASC := 0;
End;

{+-------------------------------------------------------+}
{: Function :  RAD   Convert from Degrees to Radians     :}
{+-------------------------------------------------------+}
{:    Syntax : RAD ( <expR1> )                           :}
{:                                                       :}
{:     where : <expR1> = Degrees of type Real            :}
{:                                                       :}
{:    Action : Converts a number (REAL) containing       :}
{:             Degrees to one expressed as Radians.      :}
{:                                                       :}
{: Result Type :  Real                                   :}
{+-------------------------------------------------------+}
Function RAD( Degrees : Real ) : Real;
Begin
  RAD := Degrees * ( Pi / 180 );
End;

{+-------------------------------------------------------+}
{: Function :  DEG   Convert from Radians to Degrees     :}
{+-------------------------------------------------------+}
{:    Syntax : DEG ( <expR1> )                           :}
{:                                                       :}
{:     where : <expR1> = Radians of type Real            :}
{:                                                       :}
{:    Action : Converts a number (REAL) containing       :}
{:             Radians to one expressed as Degrees.      :}
{:                                                       :}
{: Result Type :  Real                                   :}
{+-------------------------------------------------------+}
Function DEG( Radians : Real ) : Real;
Begin
  DEG := Radians * ( 180 / Pi );
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  LOG   Returns the Log                     :}
{+-------------------------------------------------------+}
{:    Syntax : DEG ( <expR1> )                           :}
{:                                                       :}
{:     where : <expR1> = number to obtain Log of         :}
{:                                                       :}
{:    Action : Returns the natural Logarithm of the      :}
{:             argument.                                 :}
{:                                                       :}
{: Result Type :  Real                                   :}
{+-------------------------------------------------------+}
Function LOG( x : Real ) : Real;
Begin
  LOG := LN( x );
End;

{+-------------------------------------------------------+}
{: Function :  SGN   Returns the Sign of argument        :}
{+-------------------------------------------------------+}
{:    Syntax : DEG ( <expI1> )                           :}
{:                                                       :}
{:     where : <expI1> = number to obtain Sign of        :}
{:                                                       :}
{:    Action : If <expI1> is positive SGN returns 1      :}
{:             If <expI1> is zero     SGN returns 0      :}
{:             If <expI1> is negative SGN returns -1     :}
{:                                                       :}
{: Result Type :  Integer                                :}
{+-------------------------------------------------------+}
Function SGN( x : Integer ): Integer;
Begin
  If x = 0 Then
    SGN := 0
  Else
    If x < 0 Then
      SGN := -1
    Else
      SGN := 1;
End;
{.pa}
{+-------------------------------------------------------+}
{:Procedure :  DEFSEG  (assign current segment register) :}
{+-------------------------------------------------------+}
{:    Syntax : DEFSEG ( <expI1> )                        :}
{:                                                       :}
{:     where : <expI1> = Integer value of Segment Reg    :}
{:                       Segment = Global Variable       :}
{:    Action : Assigns <expI1> to the Segment Register   :}
{+-------------------------------------------------------+}
Procedure DefSeg( SegValue : Integer);
Begin
  Segment := SegValue;
End;

{+-------------------------------------------------------+}
{: Function :  Peek  Get contents of memory address      :}
{+-------------------------------------------------------+}
{:    Syntax : Peek ( <expW1> )                          :}
{:                                                       :}
{:     where : <expW1> = Offset of memory address of     :}
{:                       type Word                       :}
{:                                                       :}
{:    Action : Gets contents of memory address as        :}
{:             Segment:Offset.                           :}
{:                                                       :}
{: Result Type :  Byte                                   :}
{+-------------------------------------------------------+}
Function Peek( Offset : Word ): Byte;
Begin
  Peek := Mem[Segment:Offset];
End;

{+-------------------------------------------------------+}
{: Function :  PeekW  Get contents of memory address     :}
{+-------------------------------------------------------+}
{:    Syntax : PeekW  ( <expW1> )                        :}
{:                                                       :}
{:     where : <expW1> = Offset of memory address of     :}
{:                       type Word                       :}
{:                                                       :}
{:    Action : Gets contents of memory address as        :}
{:             Segment:Offset.                           :}
{:                                                       :}
{: Result Type :  Word                                   :}
{+-------------------------------------------------------+}
Function PeekW( Offset : Word ): Word;
Begin
  PeekW := MemW[Segment:Offset];
End;
{.pa}
{+-------------------------------------------------------+}
{: Function :  PeekL  Get contents of memory address     :}
{+-------------------------------------------------------+}
{:    Syntax : PeekL ( <expW1> )                         :}
{:                                                       :}
{:     where : <expW1> = Offset of memory address of     :}
{:                       type Word                       :}
{:                                                       :}
{:    Action : Gets contents of memory address as        :}
{:             Segment:Offset.                           :}
{:                                                       :}
{: Result Type :  Longint                                :}
{+-------------------------------------------------------+}
Function PeekL( Offset : Word ): Longint;
Begin
  PeekL := MemL[Segment:Offset];
End;

{+-------------------------------------------------------+}
{: Procedure : Poke  Put contents of memory address      :}
{+-------------------------------------------------------+}
{:    Syntax : Poke ( <expW1>, <expB1> )                 :}
{:                                                       :}
{:     where : <expW1> = Offset of memory address of     :}
{:                       type Word                       :}
{:                                                       :}
{:             <expB1> = Byte of data to poke            :}
{:                                                       :}
{:    Action : Pokes contents of memory address.         :}
{:                                                       :}
{+-------------------------------------------------------+}
Procedure Poke( Offset: Word; Value : Byte );
Begin
  Mem[Segment:Offset] := Value;
End;

{+-------------------------------------------------------+}
{: Function :  TAN   Computes Tangent of Angle           :}
{+-------------------------------------------------------+}
{:    Syntax : TAN ( <expR1> )                           :}
{:                                                       :}
{:     where : <expR1> = number to obtain TAN of         :}
{:                                                       :}
{:    Action : Returns the Tangent of angle in radians   :}
{:                                                       :}
{: Result Type :  Real                                   :}
{+-------------------------------------------------------+}
Function TAN( x : Real ) : Real;  { input must be in radians }
Begin
  TAN := Sin(x)*(1/Cos(x));
End;
{.pa}
Function Input( prompt : String): String;
Var
  t1 : String;
Begin
  Write(prompt);
  ReadLn(t1);
  Input := t1;
End;

Function InputS( prompt : String): String;
Var
  t1 : String;
Begin
  Write(prompt);
  ReadLn(t1);
  InputS := t1;
End;

Function InputI( prompt : String): Integer;
Var
  t1 : String;
Begin
  Write(Prompt);
  ReadLn(t1);
  InputI := Trunc( Str2Bin( t1 ) );
End;

Function InputR( prompt : String): Real;
Var
  t1 : String;
Begin
  Write(Prompt);
  ReadLn(t1);
  InputR := Str2Bin( t1 );
End;

Procedure PrintAT(Row, Col : word; Tex : String);
Begin
  GotoXY(Row,col);
  Write(Tex);
End;

Procedure Print(Tex : String);
Begin
  WriteLn(Tex);
End;

{.pa}
Procedure CursorOn;
Var
  Rg : Registers;
Begin
  Rg.AH := 1;
  Rg.CH := 1;
  Rg.CL := 7;
  Intr($10,Rg);
End;

Procedure CursorOff;
Var
  Rg : Registers;
Begin
  Rg.AH := 1;
  Rg.CH := $20;
  Intr($10,Rg);
End;

Begin
  Segment := 0;
  GMT := False;
  Suppress := False;
End.

