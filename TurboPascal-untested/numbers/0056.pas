Unit Num2Word;
{* Program by: Richard Weber - 08/02/94 - 4 hours work *}
{* 70614,2411 *}
Interface

{* BY: Richard Weber                                                     *}
{* CrazyWare  -  08/02/94                                                *}
{* CompuServe ID: 70614,2411                                             *}

{* This program was written in 4 hours.                                  *}

{* Program is self Explainatory.  There is only one available function.  *}
{* Function Number2Name(L : LongInt) : String;                           *}

{*    If you call Number2Name(20) it will return the word equalivent     *}
{*    as a string.  It function will process up to 2 billion and will    *}
{*    not process numbers less than zero or fractions of one.            *}

{* I hope the unit comes in handy and will prevent you from working      *}
{* one out form scratch.                                                 *}

{* Feel free to modify and expand it as will.  Please leave me a message *}
{* for any questions or comments.                                        *}


  Function Number2Name(L : LongInt) : String;
  { Function converts Long Integer supplied to a Word String }

Implementation

CONST
  N_Ones : Array[0..9] of String[5] =
    ('',
     'One',
     'Two'  ,
     'Three',
     'Four',
     'Five',
     'Six',
     'Seven',
     'Eight',
     'Nine');
  N_OnesX : Array[0..9] of String[9] =
    ('Ten',
     'Eleven',
     'Twelve',
     'Thirteen',
     'Fourteen',
     'Fifteen',
     'Sixteen',
     'Seventeen',
     'Eightteen',
     'Nineteen');
  N_Tens : Array[2..10] of String[7] =
    ('Twenty',
     'Thirty',
     'Forty',
     'Fifty',
     'Sixty',
     'Seventy',
     'Eighty',
     'Ninety',
     'Hundred');
  N_Extra : Array[1..3] of String[8] =
     ('Thousand',
     'Million',
     'Billion');

  Hundred = 10;  {* N_Tens[10] *}

  Function LongVal(S : String) : LongInt;
  Var
    TmpVal : LongInt;
    Count  : Integer;
    Begin
      Val(S, TmpVal, Count);
      LongVal := TmpVal;
    End;

  Function Long2Str(L : LongInt) : String;
  Var
    S : String;
  Begin
    Str(L,S);
    Long2Str := S;
  End;

  Function Number2Name(L : LongInt) : String;
  Var
    NameString   : String;
    NumberString : String;
    Finished     : Boolean;
    Place        : Integer;
    StopPlace    : Integer;
    BeginPlace   : Integer;
    CountPlace   : Integer;

  Function Denom(I : Integer) : String;
  Var
    TestPlace : Integer;

    Begin
     TestPlace := I Div 3;
     If I Mod 3 <> 0 then Inc(TestPlace);

     If TestPlace > 1 then
       Denom := N_Extra[TestPlace-1]
      Else
       Denom := '';
    End;

  Function TensConvert(S : String) : String;
  Var TmpStr : String;
   Begin
     If Length(S) > 2 then S := Copy(S,2,2);
     TensConvert := '';

     If LongVal(S) <= 19 then
       Begin
         If LongVal(S) >=10 then
           TensConvert := N_OnesX[LongVal(S)-10]
          Else
           TensConvert := N_Ones[LongVal(S)];
       End
      Else
       Begin
         TmpStr := N_Tens[LongVal(S) Div 10];
         If LongVal(S) Mod 10 <> 0 then
           TmpStr := TmpStr + '-' + N_Ones[LongVal(S) Mod 10];
         TensConvert := TmpStr;
       End;
   End;

  Function HundredConvert(S : String; Place : BYTE) : String;
  Var
    TmpString  : String;

    Begin
    TmpString := '';
    If LongVal(S) > 0 then
      Begin

      If (Length(S) = 3) and (LongVal(S[1]) > 0) then
            TmpString := TmpString + ' ' + N_Ones[LongVal(S[1])]+
            ' ' + N_Tens[Hundred];

        TmpString := TmpString + ' ' + TensConvert(S);

        TmpString := TmpString + ' ' + Denom(Place);

      End;
      HundredConvert := TmpString;
    End;

  Begin
   If L > 0 then 
   Begin
    StopPlace := 0;
    Place := 3;
    NameString   := '';
    NumberString := Long2Str(L);

    Finished := False;
    Repeat
      If Place > Length(NumberString) then
       Begin
        Place := Length(NumberString);
        Finished := True;
       End;

      IF Place <> StopPlace then
       Begin
        BeginPlace := Length(NumberString)-Place+1;
        CountPlace := Place-StopPlace;
        NameString := HundredConvert(Copy(NumberString,BeginPlace,CountPlace),Place ) + NameString;
       End;

      StopPlace := Place;
      Inc(Place,3);
    Until Finished;

    Number2Name := NameString;
   End
   Else
    Number2Name := ' Zero';
 End;

Begin
End.

{ ---------------   demo ------------------------- }

Program TestNum;
Uses Num2Word;

Var
 Lop : Integer;
 Tmp : LongInt;

Begin
 Writeln;
 Randomize;
 For Lop := 1 to 10 do
  Begin
    Tmp := Random(65534);
    Writeln(Tmp, Number2Name(Tmp));
  End;

 Readln;


 For Lop := 0 to 20 do
  Begin
    Writeln(Lop, Number2Name(Lop));
  End;

 Readln;


 For Lop := 10 to 100 do
  Begin
    Writeln(Lop*10, Number2Name(Lop*10));
  End;

End.