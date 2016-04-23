UNIT STR_STF;
  {**------------------------------------------------**}
  {**    STRING Library OPERATIONS                   **}
  {**    Version 1.2                                 **}
  {**            Added Pos_Reverse                   **}
  {**    Version 1.1 (sped-ups)                      **}
  {**                (delete_duplicate_Chars_in_str) **}
  {**            Added Int_To_Str_Zero_Fill          **}
  {**------------------------------------------------**}

{$O-,F+}

INTERFACE
{**************************************************************}
{* Trim   removes leading/trailing blanks.                    *}
{*                                                            *}
{**************************************************************}
FUNCTION TRIM        (Str : string) : string;

FUNCTION TRIM_Leading_Only (Str : string) : string;
FUNCTION TRIM_Trailing_Only (Str : string) : string;
FUNCTION TRIM_Quotes (Str : string) : string;

{**************************************************************}
{* Right_Justify adds leading blanks.                         *}
{*    NOTE: does not handle cases when                        *}
{*                   Size_To_Be < ACTUAL NUMBER OF CHARACTERS *}
{**************************************************************}
FUNCTION Right_Justify (Str : string; Size_To_Be : integer) : string;

{***************************************************************}
{* Center_Str   centers the characters in the string based     *}
{*              upon the size/midpoint specified.              *}
{***************************************************************}
FUNCTION Center_Str (Str : string; Output_Size : integer) : string;

{**************************************************************}
{* Change_Case changes the case of the string to UPPER.       *}
{*                                                            *}
{**************************************************************}
FUNCTION CHANGE_CASE (Str : string) : string;
FUNCTION Lower_Case (Str : string) : string;

{**************************************************************}
{* Int_To_Str returns the number converted into ascii chars.  *}
{*                                                            *}
{**************************************************************}
FUNCTION Int_To_Str  (Num : LongInt) : string;
FUNCTION Int_To_Str_Zero_Fill  (Num : LongInt; Fill : byte) : string;
FUNCTION Int_Num_Digits (Num : LongInt) : integer;

{**************************************************************}
{* Pos_Reverse returns the last occurance of the string       *}
{*     just before the specified start pos!                   *}
{**************************************************************}
FUNCTION Pos_Reverse (Str        : string;
                      Delimiter  : string;
                      Start_At   : integer) : integer;

{**************************************************************}
{* Find_Char   returns the position of the char               *}
{*                                                            *}
{**************************************************************}
FUNCTION Find_Char   (Str      : string;
                      Char_Is  : char;
                      Start_At : integer) : INTEGER;

{**************************************************************}
{* Delete_The_Char   delete all occurances of the char        *}
{*                                                            *}
{**************************************************************}
FUNCTION Delete_The_Char
                     (Str      : string;
                      Char_Is  : char) : string;

{**************************************************************}
{* Replace_Str_Into  inserts the small string into the        *}
{*                   org_str at the position specified        *}
{**************************************************************}
FUNCTION Replace_Str_Into (Org_Str     : String;
                           Small_Str   : string;
                           Start, Stop : integer) : string;

{**************************************************************}
{* procedure Get_Word_Around_Position                         *}
{*     returns the word based AROUND the position specified   *}
{*     Searches for blanks around the start_pos               *}
{*        looking left then right.                            *}
{**************************************************************}
function Get_Word_Around_Position
                     (Str                    : string;
                      Start_Pos              : integer;
                      Leftmost_Char_Boundry  : integer;
                      Rightmost_Char_Boundry : integer;
                      VAR Found_Left_Pos     : integer;
                      VAR Found_Word_Size    : integer) : string;

{**************************************************************}
{* returns a string with duplicate chars deleted.             *}
{**************************************************************}
function Delete_Duplicate_Chars_In_Str (Str            : string;
                                        Limit_In_A_Row : byte): string;

{**************************************************************}
{* returns a string filled with the character specified       *}
{**************************************************************}
function Fill_String(Len : Byte; Ch : Char) : String;

{**************************************************************}
{* Truncates a string to a specified length                   *}
{**************************************************************}
function Trunc_Str(TString : String; Len : Byte) : String;

{**************************************************************}
{* Pads a string to a specified length with a specified character }
{**************************************************************}
function Pad_Char(PString : String; Ch : Char; Len : Byte) : String;


{**************************************************************}
{* Left-justify a string within a certain width               *}
{**************************************************************}
function Left_Justify_Str (S : String; Width : Byte) : String;


{**************************************************************}
{* Note that "Count" is the number of *WORDS* to fill.        *}
{* So e.g. you'd use                                          *}
{* "FillWord(My_Int_Array, SizeOf(My_Int_Array) DIV 2, 1);"   *}
{*      by Neil Rubenking                                     *}
{**************************************************************}
PROCEDURE FillWord (VAR Dest; Count, What : Word);


{**************************************************************}
{**************************************************************}
{**************************************************************}
IMPLEMENTATION

{**************************************************************************}
function Min(N1, N2 : Longint) : Longint;
{ Returns the smaller of two numbers }
begin
  if N1 <= N2 then
    Min := N1
  else
    Min := N2;
end; { Min }

(*
{**************************************************************************}
function Max(N1, N2 : Longint) : Longint;
{ Returns the larger of two numbers }
begin
  if N1 >= N2 then
    Max := N1
  else
    Max := N2;
end; { Max }
*)

{**************************************************************}
{* returns a string filled with the character specified       *}
{**************************************************************}
function Fill_String(Len : Byte; Ch : Char) : String;
var
  S : String;
begin
  IF (Len > 0) THEN
    BEGIN
      S[0] := Chr(Len);
      FillChar(S[1], Len, Ch);
      Fill_String := S;
    END
  ELSE Fill_String := '';
end; { FillString }

{**************************************************************}
{* Truncates a string to a specified length                   *}
{**************************************************************}
function Trunc_Str(TString : String; Len : Byte) : String;
begin
  if (Length(TString) > Len) then
    begin
      {Delete(TString, Succ(Len), Length(TString) - Len);}
      {Move(TString[Succ(Len)+(LENGTH(TString)-Len)], TString[Succ(Len)],
           Succ(Length(TString)) - Succ(Len) - Length(TString) - Len));}
      Move(TString[LENGTH(TString)+1], TString[Succ(Len)], 2*Len);
      Dec(TString[0], Length(TString) - Len);
    end;
  Str_Stf.Trunc_Str := TString;
end; { TruncStr }

{**************************************************************}
{* Pads a string to a specified length with a specified character }
{**************************************************************}
function Pad_Char(PString : String; Ch : Char; Len : Byte) : String;
var
  CurrLen : Byte;
begin
  CurrLen := Min(Length(PString), Len);
  PString[0] := Chr(Len);
  FillChar(PString[Succ(CurrLen)], Len - CurrLen, Ch);
  Pad_Char := PString;
end; { PadChar }

{**************************************************************}
{* Left-justify a string within a certain width               *}
{**************************************************************}
function Left_Justify_Str(S : String; Width : Byte) : String;
begin
  Left_Justify_Str := Str_Stf.Pad_Char(S, ' ', Width);
end; { Left_Justify_Str }

{**************************************************************}
{* Trim   removes leading/trailing blanks.                    *}
{*                                                            *}
{**************************************************************}
FUNCTION TRIM (Str : string) : string;
VAR
  i : integer;
BEGIN
  i := 1;
  WHILE ((i < LENGTH(Str)) and (Str[i] = ' '))
    DO INC(i);

  IF (i > 1) THEN
    BEGIN
      {Str := COPY (Str, i, Length(Str));}
      Move (Str[i], Str[1], Succ(LENGTH(Str))-i);
      DEC (Str[0], pred(i));
    END;

  WHILE (Str[LENGTH(str)] = ' ')
    DO DEC (Str[0]);

  Trim := Str;
END;  {trim}

{**************************************************************}
{* Trim_Lead   removes leading blanks.                        *}
{*                                                            *}
{**************************************************************}
FUNCTION TRIM_Leading_Only (Str : string) : string;
VAR
  i : integer;
BEGIN
  i := 1;
  WHILE ((i < LENGTH(Str)) and (Str[i] = ' '))
    DO INC(i);

  IF (i > 1) THEN
    BEGIN
      {Str := COPY (Str, i, Length(Str));}
      Move (Str[i], Str[1], Succ(LENGTH(Str))-i);
      DEC (Str[0], pred(i));
    END;

  Trim_Leading_Only := Str;
END;  {trim_leading_Only}

{***************************************************************}
FUNCTION TRIM_Trailing_Only (Str : string) : string;
BEGIN
  WHILE (Str[LENGTH(str)] = ' ')
    DO DEC (Str[0]);

  Trim_Trailing_Only := Str;
END;  {trim}

{***************************************************************}
{*------------------------------------------------------*}
{* Trim off any lead/trail quotes!                      *}
{*------------------------------------------------------*}
FUNCTION TRIM_Quotes (Str : string) : string;
begin
  IF ((LENGTH(Str) > 0) and (Str[1] = '"')) THEN
    BEGIN
      Move (Str[2], Str[1], pred(LENGTH(Str)));
      DEC (Str[0]);
      IF (Str[LENGTH(Str)] = '"')
        THEN DEC(Str[0]);
    END; {if}
Trim_Quotes := Str;
end; {Trim_Quotes}

{***************************************************************}
{* Right_Justify adds leading blanks.                          *}
{*    NOTE: does not handle cases when                         *}
{*                    Size_To_Be < ACTUAL NUMBER OF CHARACTERS *}
{***************************************************************}
FUNCTION Right_Justify (Str : string; Size_To_Be : integer) : string;
VAR
  Temp_Str  : string;
BEGIN
  Temp_Str := TRIM (Str);   {to assure proper length--and NON-BLANK}
  Right_Justify := Str_Stf.Left_Justify_Str
                               ('', Size_To_Be - Length(Str)) + Str;

{  WHILE ((LENGTH(Temp_Str) > 0) AND
         ( (Size_To_Be > LENGTH (Temp_Str)) OR
           (Temp_Str[Size_To_Be] = ' ') ) )
    DO Temp_Str := ' '+ COPY (Temp_Str, 1, Size_To_Be-1);
  Right_Justify := Temp_Str;}

END; {right_justify}

{***************************************************************}
{* Center_Str   centers the characters in the string based     *}
{*              upon the size/midpoint specified.              *}
{***************************************************************}
FUNCTION Center_Str (Str : string; Output_Size : integer) : string;
VAR
  Ret_Str : string;
  Size    : integer;
BEGIN
  { blank out returning string}
  Ret_Str := Str_Stf.Fill_String(Output_Size, ' ');
  {FillChar (Ret_Str, output_size, ' ');
   Ret_Str[0] := chr(Output_Size);}

  Str := TRIM (Str);
  Size := LENGTH (Str);
  IF (Output_Size <= Size)
    THEN Ret_Str := Str
  ELSE
    BEGIN
      Insert (Str, Ret_Str, (((Output_Size - Size) div 2)+1));
      Ret_Str := COPY (Ret_Str, 1, OutPut_Size);
    END;
  Center_Str := Ret_Str;
END; {center_str}

{**************************************************************}
{* Change_Case changes the case of the string to UPPER.       *}
{*                                                            *}
{**************************************************************}
FUNCTION Change_Case (Str : string) : string;
var
  i : integer;
BEGIN
  for i := 1 to LENGTH (Str)
    do Str[i] := UpCase(Str[i]);
  Change_Case := Str;
END;  {change_case}

{**************************************************************}
FUNCTION Lower_Case (Str : string) : string;
var
  i : integer;
BEGIN
  for i := 1 to LENGTH (Str)
    do IF ((ORD (Str[i]) >= 65) and (ORD(Str[i]) <= 90))
         THEN Str[i] := CHR(ORD(Str[i])+32);
  Lower_Case := Str;
END;  {lower_case}

{**************************************************************}
{* Int_To_Str returns the number converted into ascii chars.  *}
{*                                                            *}
{**************************************************************}
FUNCTION Int_To_Str  (Num : LongInt) : string;
var
  Temp_Str : string;
BEGIN
  STR(Num, Temp_Str);
  Int_To_Str := Temp_Str;
END; {int_to_str}

FUNCTION Int_To_Str_Zero_Fill  (Num : LongInt; Fill : byte) : string;
var
  Temp_Str : string;
  Len : byte;
BEGIN
  STR(Num, Temp_Str);
  Len := LENGTH(Temp_Str);
  IF (Len < Fill)
    THEN Temp_Str := Fill_String(Fill-Len, '0')+Temp_Str;
  Int_To_Str_Zero_Fill := Temp_Str;
END; {int_to_str_zero_fill}

FUNCTION Int_Num_Digits (Num : LongInt) : integer;
var
 Tens, Digits : Integer;
BEGIN
  IF (Num = 0)
    THEN Int_Num_Digits := 1
  ELSE
    BEGIN
      Tens := 1;
      Digits := 1;
      WHILE ((Num DIV Tens) <> 0) DO
      BEGIN
        INC (Digits);
        Tens := Tens * 10;
      END; {while}

      IF (Digits > 1)
        THEN DEC (Digits);
      Int_Num_Digits := Digits;
    END; {if}

END; {int_num_digits}

{**************************************************************}
{* Pos_Reverse returns the last occurance of the string       *}
{*     just before the specified start pos!                   *}
{**************************************************************}
FUNCTION Pos_Reverse (Str        : string;
                      Delimiter  : string;
                      Start_At   : integer) : integer;
VAR
  Temp_Str : string;
  Found_Pos, Found_Pos_0 : integer;
BEGIN
  Temp_Str := COPY(Str, 1, Start_At);  {dont use move since ?start_at <length?}
  Found_Pos_0 := 0;
  REPEAT
    Found_Pos := POS (Delimiter, Temp_Str);
    IF (Found_Pos <> 0) THEN
      BEGIN
        Found_Pos_0 := Found_Pos_0+Found_Pos;
        {Temp_Str := COPY(Temp_Str, Found_Pos+1, LENGTH(Temp_Str));}
        Move (Temp_Str[Found_Pos+1], Temp_Str[1], LENGTH(Str)-Found_Pos+2);
        DEC (Temp_Str[0], Found_Pos);
      END;
  UNTIL (Found_Pos = 0);
  Pos_Reverse := Found_Pos_0;
END; {pos_reverse}

{**************************************************************}
{* Find_Char   returns the position of the char               *}
{*                                                            *}
{**************************************************************}
FUNCTION Find_Char (Str      : string;
                    Char_Is  : char;
                    Start_At : integer) : INTEGER;
VAR
  Loc : integer;
BEGIN
  Loc := POS (Char_Is, COPY(Str, Start_At, LENGTH(STR)));
  IF (Loc <> 0)
    THEN Loc := Loc + Start_At -1;
  Find_Char := Loc;
END; {function Find_Char}

{**************************************************************}
{* Delete_The_Char   delete all occurances of the char        *}
{*                                                            *}
{**************************************************************}
FUNCTION Delete_The_Char (Str      : string;
                          Char_Is  : char) : string;
VAR
  Loc : integer;
BEGIN
  Loc := 0;
  REPEAT
    Loc := POS (Char_Is, Str);
    IF (Loc <> 0) THEN
      BEGIN
        {DELETE (Str, Loc, 1);}
        Move(Str[Succ(Loc)], Str[Loc], Length(Str)-Loc);
        Dec(Str[0]);
      END;
  UNTIL (Loc = 0);

  Delete_The_Char := STR;
END; {function Delete_The_Char}

{**************************************************************}
{* Replace_Str_Into  inserts the small string into the        *}
{*                   org_str at the position specified        *}
{**************************************************************}
FUNCTION Replace_Str_Into (Org_Str     : String;
                           Small_Str   : string;
                           Start, Stop : integer) : string;
var
  Temp_Small_Str : string;
begin
  IF (Start = 0)
    THEN Start := 1;

  IF (LENGTH(Small_Str) >= (Stop-Start+1))
    THEN Temp_Small_Str := Small_Str
  ELSE Temp_Small_Str := Small_Str +
                       Fill_String ( (Stop-Start+1-LENGTH(Small_Str)), ' ');
  IF (Start > 1)
    THEN Replace_Str_Into := Copy (Org_Str, 1, (Start -1)) +
                             Copy (Temp_Small_Str, 1, (Stop-Start+1))+
                             Copy (Org_Str, (Stop+1) , LENGTH(Org_Str))
    ELSE Replace_Str_Into := Copy (Temp_Small_Str, 1, (Stop-Start+1)) +
                             Copy (Org_Str, Stop+1, LENGTH(Org_Str));
end; {Replace_Str_into}

{**************************************************************}
{* procedure Get_Word_Around_Position                         *}
{*     returns the word based AROUND the position specified   *}
{*     Searches for blanks around the start_pos               *}
{*        looking left then right.                            *}
{**************************************************************}
function Get_Word_Around_Position
                               (Str                    : string;
                                Start_Pos              : integer;
                                Leftmost_Char_Boundry  : integer;
                                Rightmost_Char_Boundry : integer;
                                VAR Found_Left_Pos     : integer;
                                VAR Found_Word_Size    : integer) : string;
var
  adjust         : integer;

begin
  IF ((Start_Pos <= LENGTH(Str))) THEN
    BEGIN
      Get_Word_Around_Position := Str[Start_Pos];
      Found_Left_Pos := Start_Pos;
      Found_Word_Size := 1;
    END

  ELSE        {* Bad Params! *}
    BEGIN
      Get_Word_Around_Position := ' ';
      Found_Left_Pos           := 0;
      Found_Word_Size          := 0;
      Exit;
    END;

  if (Str[Start_Pos] <> ' ') then
    begin
      {************************************************}
      {*  FIRST: find left-most position              *}
      {************************************************}
      adjust := Start_Pos -1;
      while ((adjust >= leftmost_char_boundry) and
             (Str[adjust] <> ' '))
        do adjust := adjust - 1;
      if ((adjust = leftmost_char_boundry) and (Str[adjust] <> ' '))
        then Found_Left_Pos := adjust
        else Found_Left_Pos := adjust +1;

      {************************************************}
      {*  find right-most position                    *}
      {************************************************}
      adjust := Start_Pos +1;
      while ((adjust <= Rightmost_Char_Boundry) and
              (Str[adjust] <> ' '))
        do adjust := adjust + 1;

      if ((adjust = Rightmost_char_boundry) and (Str[adjust] <> ' '))
        then Found_Word_Size := adjust - Found_Left_Pos +1
        else Found_Word_Size := adjust - Found_Left_Pos;

      Get_Word_Around_Position := Copy (Str, Found_Left_Pos, Found_Word_Size);

    end; {if}

end; {get_word_around_position}

{**************************************************************}
{* returns a string with duplicate chars deleted.             *}
{**************************************************************}
function Delete_Duplicate_Chars_In_Str (Str            : string;
                                        Limit_In_A_Row : byte) : string;
var
  Curr_Pos       : integer;
  i              : integer;
  Same_Chars     : boolean;
begin

  IF (Limit_In_A_Row = 1) THEN       {* must catch or infinite loop *}
    BEGIN
      Delete_Duplicate_Chars_In_Str := '';
      exit;
    END;

  Curr_Pos        := 1;
  WHILE ((Curr_Pos+Limit_In_A_Row-1) <= LENGTH(Str)) DO
    BEGIN

      {*---------------------------------------*}
      {* Quickly look for at least 2 in a row! *}
      {*---------------------------------------*}
      WHILE (((Curr_Pos+Limit_In_A_Row-1) <= LENGTH(Str)) AND
             (Str[Curr_Pos] <> Str[Succ(Curr_Pos)]))
        DO INC(Curr_Pos);

      IF ((Curr_Pos+Limit_In_A_Row-1) <= LENGTH(Str)) THEN
        BEGIN
          i := Curr_Pos+1;
          Same_Chars := TRUE;
          WHILE ((Same_Chars) and (i <= (Curr_Pos+Limit_In_A_Row-1)))
            DO IF (Str[Curr_Pos] <> Str[i])
                 THEN Same_Chars := FALSE
                 ELSE INC(i);

          IF (Same_Chars) THEN
            BEGIN
              Move(Str[Curr_Pos+Limit_In_A_Row-1], Str[Curr_Pos],
                                Length(Str)-(Curr_Pos+Limit_In_A_Row-2));
              Dec(Str[0],Pred(Limit_In_A_Row));
            END
          ELSE Inc(Curr_Pos);
        END; {if}
    END; {while}

  Delete_Duplicate_Chars_In_Str := Str;
end; {delete_duplicate_chars_in_str}

{*
       Note that "Count" is the number of *WORDS* to fill.  So e.g. you'd
use "FillWord(My_Int_Array, SizeOf(My_Int_Array) DIV 2, 1);"
      by Neil Rubenking *}
{**************************************************************}
PROCEDURE FillWord(VAR Dest; Count, What : Word); Assembler;
  ASM
    LES DI, Dest    {ES:DI points to destination}
    MOV CX, Count   {count in CX}
    MOV AX, What    {word to fill with in AX}
    CLD             {forward direction}
    REP STOSW       {perform the fill}
  END; {fillWord}

END. {unit str_stf}