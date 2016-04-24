(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0135.PAS
  Description: Re: Convert numbers to letters
  Author: ROGER DONAIS
  Date: 11-29-96  08:17
*)

{
Thomas.Papiernik@Thalma.fr says...
 I try to find pascal source to convert numbers to letters like
 100 to one hundred

{ Copyright 1988, 1995 Roger E. Donais              <RDonais@gnn.com> }

{ =================================================================== }
{ Returns lowercase ordinal for values 1st, 2nd, 3rd, etc             }
{ =================================================================== }
FUNCTION OrdNum{ (No: Word): String };
CONST Suffix: Array[0..9] of Array [1..2] of Char =
     ('th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th');
BEGIN
    If (No > 10) and (No < 20) Then
       OrdNum := Ascii(No,1)+'th'
    Else
       OrdNum := Ascii(No,1)+Suffix[No Mod 10];
END;


{ =================================================================== }
{ Returns lowercase ordinal for values "first" to "ninety-ninth"      }
{ Returns OrnNum() (0th, 100th, 101st, etc) for out-of-range values.  }
{ =================================================================== }
FUNCTION Ordinal{ (No: Integer): String };

CONST Lo: Array[1..19] of String[11] =
   ( 'first',     'second',     'third',     'fourth',    'fifth',
     'sixth',     'seventh',    'eighth',    'ninth',     'tenth',
     'eleventh',  'twelfth',    'thirteenth','fourteenth','fifteenth',
     'sixteenth', 'seventeenth','eighteenth','nineteenth');

      Ten: Array[2..9] of String[5] =
          ( 'twen', 'thir',  'for',  'fif',
            'six',  'seven', 'eigh', 'nine');

BEGIN
    If (No < 1) or (No > 99) Then
       Ordinal := OrdNum(No)
    Else
    If No < 20 Then
       Ordinal := Lo[No]
    Else
    If No mod 10 = 0 Then
      Ordinal := Ten[No div 10] + 'tieth'
    Else Ordinal := Ten[No div No] + 'ty-' + Lo[No mod 10];
END;

{ =================================================================== }
{ Returns lowercase number for values 0..MAX_WORD, as "zero", "one",  }
{ two, ..., "sixty-five thousand five hundred sixty five.             }
{ =================================================================== }
FUNCTION Number(No: Word): String;

    Function Num(No: Word): String;
    { --------------------------------------------------------------- }
    CONST Lo: Array[1..19] of String[ 9] =
              ( 'one',     'two',      'three',   'four',    'five',
                'six',     'seven',    'eight',   'nine',    'ten',
                'eleven',  'twelve',   'thirteen','fourteen','fifteen',
                'sixteen', 'seventeen','eighteen','nineteen');

          Ten: Array[2..9] of String[5] =
              ( 'twen', 'thir',  'for',  'fif',
                'six',  'seven', 'eigh', 'nine');
    Begin
        If No < 20 Then Begin
          If No <> 0 Then
             Num := Lo[No]
        End Else
        If No mod 10 = 0 Then
          Num := Ten[No div 10] + 'ty'
        Else Num := Ten[No div 10] + 'ty-' + Lo[No mod 10];
    End;

VAR s: String;
BEGIN
    If No = 0 Then
       Number := 'zero'
    Else Begin
       s := '';
       If No >= 2000 Then Begin
          s := Num(No div 1000)+ ' thousand ';
          No := No mod 1000;
       End;
       If No >= 1000 Then Begin
          s := s + Num(No div 100) + ' hundred ';
          No := No mod 100;
       End;
       s := Ftrim(s + Num(No));
    End;
    Number := s;
END;

