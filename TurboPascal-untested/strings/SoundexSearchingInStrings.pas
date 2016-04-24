(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0100.PAS
  Description: Soundex Searching in Strings
  Author: KLAUS WIEGAND
  Date: 11-26-94  05:04
*)

{
[marcus is looking for an algorithm, which handles finding strings like
german names, which sometimes are written with "umlauts" and sometimes
not]

the solution for your problem is the soundex-algo.:

if, for example you have to index a database on strings, you normally
would get an alphanumeric sequence by asciicode. instead the soundex will
sort your records on a more phonetic way:
}

(* procedure : soundex.pro
   purpose   : search for similar sounding strings
   compiler  : => tp 4.0
   date      : 14.07.91
 *)


Type
   Lstring = String[255];
Var
   CK_Name1,CK_Name2 : Lstring;


{
convert str to uppercase, careful, doesn't work with umlauts
this function from swag does:
Function UpCaseStr(St : string) : String;
var
  regs : registers;
begin
  Regs.DS := Seg(st[1]);
  Regs.DX := Ofs(st[1]);
  Regs.CX := Length(st);
  Regs.AX := $6521;
  MsDos(Regs);
  UpCaseStr := St;
end;
}


Procedure To_upper (Var str : Lstring);
Var
   I : Integer;

Begin
   For I := 1 to Length (str) do
      str [I] := upcase (str[I]);

End  {  To_Upper  };

{ remove all occurances of double letters like wie oo,tt,ee, etc. }

Procedure eliminate_doubles (Var str : lstring);
Var
   I,J : Integer;
Begin
   For I := 1 to Length (str) do
      Begin
      If str [I] = str [I + 1] then
         Begin
         For J := I + 1 to Length (str)-1 do
            str [J] := str [J + 1];
         End
      End
End  {  eliminate_doubles  };

{ Code 'Code' for soundex comparison }

Procedure Sound_Ex (var Code : Lstring);
Var
   I : Integer;
   Sndex : Lstring;

Begin
   Sndex := '';
   Sndex := Sndex + Code [1];
   For I := 2 to Length (Code) do
      Begin
      Case Code [I] of
         'B','F','P','V'                 : Sndex := Sndex +  '1';
         'C','G','J','K','Q','S','S','Z' : Sndex := Sndex +  '2';
         'D','T'                         : Sndex := Sndex +  '3';
         'L'                             : Sndex := Sndex +  '4';
         'M','N'                         : Sndex := Sndex +  '5';
         'R'                             : Sndex := Sndex +  '6';
      End { case };
      End { For };
   If Length (Sndex) > 4 then Sndex := Copy (Sndex,1,4);
   If Length (Sndex) < 4 then
      For I := Length (Sndex) to 3 do Sndex := Sndex + '0';
   Code := Sndex;

End  {  Sound_Ex  };

{**************************************************
 * returns TRUE, if Name1 in Soundexcode          *
 * ressembles to Name2, returns falsch, if not    *
 **************************************************}

Function Sounds_Like (Name1,Name2 : Lstring) : Boolean;
Var
   Tnam1,Tnam2 : Lstring;

Begin
   Tnam1 := Name1;
   Tnam2 := Name2;
   To_Upper (Tnam1);
   To_Upper (Tnam2);
   eliminate_doubles (Tnam1);
   eliminate_doubles (Tnam2);
   Sound_Ex (Tnam1);
   Sound_Ex (Tnam2);
Writeln;
Writeln ('> ',Tnam1,' <> ',tnam2,' <');
   If Tnam1 = Tnam2 then
      Sounds_Like := TRUE
   Else
      Sounds_Like := FALSE;

End  {  Sounds_Like  };



{
*******************
*    DEMO         *
*******************
}


Begin
   Write ('1. Name please: ');Readln (CK_Name1);
   Write ('2. Name please: ');Readln (CK_Name2);
   Writeln;Writeln;
   Writeln (CK_Name1,' and ',CK_Name2);
   If Sounds_Like (CK_Name1,CK_Name2) Then
      Writeln (' sound ALIKE !')
   Else
      Writeln (' do not sound alike at all !');

End.                          

{
the used chars are languagedependant and should be used according to the
distribution of their occurances in the used language. you have to trick
around a bit with them, until you'll get the best result. those above
should work fine for the english language (which again is spoken in this
echo ;-) ).
}



