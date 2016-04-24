(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0055.PAS
  Description: ROMAN numbers
  Author: VARIOUS AUTHORS
  Date: 11-02-93  18:41
*)

}
From: BRIAN PAPE
Subj: YEAR ( ROMAN )
This is from last semester's computer bowl.  Only problem is that it
converts from Roman to Arabic.  :)

  LCCC Programming Team

 East Central College Computer Bowl

 03-21-93

 "Computer Killers"
 Brian Pape
 Brian Grammer
 Mike Lazar
 Christy Reed
 Matt Hayes
 Coach Steve Banjavcic

 Program #2-3
 Time to Completion: 3:47
}

program roman;
USES PRINTER;
const
  num = 'IVXLCDM';
  value : array[1..7] of integer = (1,5,10,50,100,500,1000);
var
  i : byte;
  s : string;
  sum : integer;
begin
  assign(lst,'');rewrite(lst);
  writeln('Enter the Roman Numerals: ');
  readln(s);
  i := length(s);
  while (i>=1) do
    begin
      if i > 1 then
        begin
          if pos(s[i],num) <= (pos(s[i-1],num)) then
            begin
              sum := sum + value[pos(s[i],num)];
              dec(i);
            end
          else
            begin
              sum := sum + value[pos(s[i],num)] - value[pos(s[i-1],num)];
              dec(i,2);
            end;  { else }
        end
      else
        begin
          sum := sum + value[pos(s[1],num)];
          dec(i);
        end;  { else }
    end;  { while }
  WRITELN(LST);
  writeln(LST,'Roman numeral: ',s);
  writeln(LST,'Arabic value: ',sum);
end. {  }

{*
 *
 *        ROMAN.C  -  Converts integers to Roman numerals
 *
 *             Written by:  Jim Walsh
 *
 *             Compiler  :  Microsoft QuickC v2.5
 *
 *        This Program Is Released To The Public Domain
 *
 *        Additional Comments:
 *
 *        Ported to TP v6.0 by Daniel Prosser.
 *}

VAR
  Value, DValue, Error : INTEGER;
  Roman : STRING[80];

BEGIN
  Roman := '';

  IF ParamCount = 2 THEN
    VAL(ParamStr(1), Value, Error)
  ELSE
    BEGIN
      Write ('Enter an integer value: ');
      ReadLn (Value);
    END; { ELSE }

  DValue := Value;

  WHILE Value >= 1000 DO
    BEGIN
      Roman := Roman + 'M';
      Value := Value - 1000;
    END; { WHILE }

  IF Value >= 900 THEN
    BEGIN
      Roman := Roman + 'CM';
      Value := Value - 900;
    END; { IF }

  WHILE Value >= 500 DO
    BEGIN
      Roman := Roman + 'D';
      Value := Value - 500;
    END; { WHILE }

  IF Value >= 400 THEN
    BEGIN
      Roman := Roman + 'CD';
      Value := Value - 400;
    END; { IF }

  WHILE Value >= 100 DO
    BEGIN
      Roman := Roman + 'C';
      Value := Value - 100;
    END; { WHILE }

  IF Value >= 90 THEN
    BEGIN
      Roman := Roman + 'XC';
      Value := Value - 90;
    END; { IF }

  WHILE Value >= 50 DO
    BEGIN
      Roman := Roman + 'L';
      Value := Value - 50;
    END; { WHILE }

  IF Value >= 40 THEN
    BEGIN
      Roman := Roman + 'XL';
      Value := Value - 40;
    END; { WHILE }

  WHILE Value >= 10 DO
    BEGIN
      Roman := Roman + 'X';
      Value := Value - 10;
    END; { WHILE }

  IF Value >= 9 THEN
    BEGIN
      Roman := Roman + 'IX';
      Value := Value - 9;
    END; { IF }

  WHILE Value >= 5 DO
    BEGIN
      Roman := Roman + 'V';
      Value := Value - 5;
    END; { WHILE }

  IF Value >= 4 THEN
    BEGIN
      Roman := Roman + 'IV';
      Value := Value - 4;
    END; { IF }


  WHILE Value > 0 DO
    BEGIN
      Roman := Roman + 'I';
      DEC (Value);
    END; { WHILE }

  WriteLn (DValue,' = ', Roman);
END.

{--------------------- Begin of function -----------------------------}


Function Roman (Number: Integer): String;
{ Converts Number to the Roman format.
  If (Number < 1) Or (Number > 3999), the returned string will be empty!
}
Var
  TempStr : String;   { Temporary storage for the result string }
Begin
  TempStr := '';
  If (Number > 0) And (Number < 4000) Then
  Begin
    { One 'M' for every 1000 }
    TempStr := Copy ('MMM', 1, Number Div 1000);
    Number := Number MOD 1000;
    If Number >= 900 Then
    { Number >= 900, so append 'CM' }
    Begin
      TempStr := TempStr + 'CM';
      Number := Number - 900;
    End
    Else
    { Number < 900 }
    Begin
      If Number >= 500 Then
      { Number >= 500, so append 'D' }
      Begin
        TempStr := TempStr + 'D';
        Number := Number - 500;
      End
      Else
        If Number >= 400 Then
        { 400 <= Number < 500, so append 'CD' }
        Begin
          TempStr := TempStr + 'CD';
          Number := Number - 400;
        End;
      { Now Number < 400!!! One 'C' for every 100 }
      TempStr := TempStr + Copy ('CCC', 1, Number Div 100);
      Number := Number Mod 100;
    End;
    If Number >= 90 Then
    { Number >= 90, so append 'XC' }
    Begin
      TempStr := TempStr + 'XC';
      Number := Number - 90;
    End
    Else
    { Number < 90 }
    Begin
      If Number >= 50 Then
      { Number >= 50, so append 'L'}
      Begin
        TempStr := TempStr + 'L';
        Number := Number - 50;
      End
      Else
        If Number >= 40 Then
        { 40 <= Number < 50, so append 'XL' }
        Begin
          TempStr := TempStr + 'XL';
          Number := Number - 40;
        End;
      { Now Number < 40!!! One 'X' for every 10 }
      TempStr := TempStr + Copy ('XXX', 1, Number Div 10);
      Number := Number Mod 10;
    End;
    If Number = 9 Then
    { Number = 9, so append 'IX' }
    Begin
      TempStr := TempStr + 'IX';
    End
    Else
    { Number < 9 }
    Begin
      If Number >= 5 Then
      { Number >= 5, so append 'V' }
      Begin
        TempStr := TempStr + 'V';
        Number := Number - 5;
      End
      Else
        If Number = 4 Then
        { Number = 4, so append 'IV' }
        Begin
          TempStr := TempStr + 'IV';
          Number := Number - 4;
        End;
      { Now Number < 4!!! One 'I' for every 1 }
      TempStr := TempStr + Copy ('III', 1, Number);
    End;
  End;
  Roman := TempStr;
End;


