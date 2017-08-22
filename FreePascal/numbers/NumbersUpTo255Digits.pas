(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0089.PAS
  Description: Numbers up to 255 digits
  Author: ALEKSANDAR DLABAC
  Date: 01-02-98  07:35
*)

{ Unit LongNum;}
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██     Numbers with up to 255 digits    ██▐███▒▒
             ███▌██   -- New functions and bug fixes --  ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1997. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
{
  This program enables use of a very long signed integer numbers - up to
  255 digits. Numbers are in fact strings, so they can be easily writed on
  screen/file/printer.
}

uses crt;

   { Interface }

   Function LongNumError : Boolean; forward;
   { Returns the status of last operations performed. If there was an error
     in calculations (overflow, for example), since LongNumError previous
     call, True will be returned. }

   Function MakeLong (Number:longint) : string; forward;
   { Converts longint number to string. }

   Function MakeInt (Number:string) : longint; forward;
   { Converts long number to longint, if possible. }

   Function FormatLongNumber (Number:string;Digits:byte) : string; forward;
   { Formats long number so it will have given number of digits. If number of
     digits is zero the number will be represented with as less as possible
     digits. Otherwise, if number of digits is smaller than number size,
     LongNumError will return True. }

   Function Neg (A:string) : string; forward;
   { Returns -A. }

   Function Sgn (A:string) : shortint; forward;
   { Returns Signum (A): 1 if A>0, 0 if A=0, -1 if A<0. }

   Function Add (A,B:string) : string; forward;
   { Returns A+B. }

   Function Subtract (A,B:string) : string; forward;
   { Returns A-B. }

   Function Multiple (A,B:string) : string; forward;
   { Returns A*B. }

   Function Divide (A,B:string;var Remainder:string) : string; forward;
   { Returns A/B. Remainder is division remaider. }

   Function Power (A:string;B:byte) : string; forward;
   { Returns A^B. }

   Function Square (A:string) : string; forward;
   { Returns A^2. }

   Function SquareRoot (A:string) : string; forward;
   { Returns Sqrt (A). If negative value is given, square root of absolute
     value will be returned, and LongNumError will return True. }

   Function LongToHex (A:string) : string; forward;
   { Returns hexadecimal value of A. }

   Function HexToLong (A:string) : string; forward;
   { Returns decimal value of A, where A is hexadecimal value. }

   Function Equal (A,B:string) : Boolean; forward;
   { Returns True if A=B. }

   Function Greater (A,B:string) : Boolean; forward;
   { Returns True if A>B. }

   Function GreaterOrEqual (A,B:string) : Boolean; forward;
   { Returns True if A>=B. }

{   Implementation }

   Var LongNumErrorFlag : Boolean;

   Function LongNumError : Boolean;
     Var Temp : Boolean;
     Begin
       Temp:=LongNumErrorFlag;
       LongNumErrorFlag:=False;
       LongnumError:=Temp
     End;

   Function Dgt (C:char) : byte;
     Var Temp : byte;
       Begin
         Temp:=0;
         If C in ['1'..'9'] then
           Temp:=Ord (C)-48;
         If not (C in ['-',' ','0'..'9']) then
           LongNumErrorFlag:=True;
         Dgt:=Temp
       End;

   Function MakeLong (Number:longint) : string;
     Var Temp : string;
       Begin
         Str (Number,Temp);
         MakeLong:=Temp
       End;

   Function MakeInt (Number:string) : longint;
     Var Temp : longint;
         I    : byte;
         Flag : Boolean;
       Begin
         Flag:=(Sgn (Subtract (MakeLong (2147483647),Number))=-1) or
               (Sgn (Subtract (Number,MakeLong (-2147483647)))=-1) or (Number='');
         Temp:=0;
         If Flag then
           LongNumErrorFlag:=True
                 else
           Begin
             For I:=1 to Length (Number) do
               Temp:=Temp*10+Dgt (Number [I]);
             Temp:=Temp*Sgn (Number);
           End;
         MakeInt:=Temp
       End;

   Function FormatLongNumber (Number:string;Digits:byte) : string;
     Var I          : byte;
         Sign, Temp : string;
       Begin
         Temp:=Number;
         I:=1;
         Sign:='';
           Repeat
             While (I<Length (Temp)) and (Temp [I]=' ') do
               Inc (I);
             While (I<Length (Temp)) and (Temp [I]='0') do
               Begin
                 Temp [I]:=' ';
                 Inc (I)
               End;
             If (I<Length (Temp)) and (Temp [I]='-') then
               Begin
                 Sign:='-';
                 Temp [I]:=' '
               End;
           Until (I>=Length (Temp)) or (Temp [I] in ['1'..'9','A'..'F']);
         While (Length (Temp)>0) and (Temp [1]=' ') do
           Temp:=Copy (Temp,2,Length (Temp)-1);
         If Temp='' then
           Temp:='0';
         If Temp<>'0' then
           Temp:=Sign+Temp;
         If Digits>0 then
           Begin
             While Length (Temp)<Digits do
               Temp:=' '+Temp;
             If (Digits<Length (Temp)) and (Temp [Length (Temp)-Digits]<>' ') then
               LongNumErrorFlag:=True;
             Temp:=Copy (Temp,Length (Temp)-Digits+1,Digits)
           End;
         FormatLongNumber:=Temp
       End;

   Function Neg (A:string) : string;
     Var Temp : string;
       Begin
         Temp:=FormatLongNumber (A,0);
         If Temp [1]='-' then
           Temp:=Copy (Temp,2,Length (Temp)-1)
                         else
           If Length (Temp)<255 then
             Temp:='-'+Temp
                                else
             LongNumErrorFlag:=True;
         Neg:=Temp
       End;

   Function Sgn (A:string) : shortint;
     Var I    : byte;
         Temp : shortint;
         S    : string;
       Begin
         S:=FormatLongNumber (A,0);
           Case S [1] of
             '-' : Temp:=-1;
             '0' : Temp:=0;
             else  Temp:=1
           End;
         Sgn:=Temp
       End;

   Function Add (A,B:string) : string;
     Var Sign, Factor, SgnA, SgnB, N : shortint;
         Transf, Sub, I              : byte;
         N1, N2, Temp                : string;
       Begin
         SgnA:=Sgn (A);
         SgnB:=Sgn (B);
         If SgnA*SgnB=0 then
           Begin
             If Sgn (A)=0 then
               Temp:=B
                          else
               Temp:=A
           End
                              else
           Begin
             If SgnA=-1 then
               N1:=Neg (A)
                        else
               N1:=A;
             If SgnB=-1 then
               N2:=Neg (B)
                        else
               N2:=B;
             While Length (N1)<Length (N2) do
               N1:=' '+N1;
             While Length (N2)<Length (N1) do
               N2:=' '+N2;
             If SgnA*SgnB>0 then
               Begin
                 Sign:=SgnA;
                 Factor:=1;
               End
                                   else
               Begin
                 If N1=N2 then
                   Sign:=1
                        else
                   Begin
                     If N1>N2 then
                       Sign:=SgnA
                            else
                       Begin
                         Sign:=SgnB;
                         Temp:=N1;
                         N1:=N2;
                         N2:=Temp
                       End
                   End;
                 Factor:=-1
               End;
             Temp:='';
             Transf:=0;
             Sub:=0;
             For I:=Length (N1) downto 1 do
               Begin
                 N:=Transf+(10+Dgt (N1 [I])-Sub) mod 10+Factor*Dgt (N2 [I]);
                 Transf:=0;
                 If Dgt (N1 [I])-Sub<0 then
                   Sub:=1
                                       else
                   Sub:=0;
                 If N<0 then
                   Begin
                     Sub:=1;
                     Inc (N,10)
                   End
                        else
                   If N>=10 then
                     Begin
                       Transf:=1;
                       Dec (N,10)
                     End;
                 Temp:=Chr (N+48)+Temp;
               End;
             If ((Length (Temp)=255) and (Transf>0)) or (Sub>0) then
               LongNumErrorFlag:=True
                                                                else
               Begin
                 If Transf>0 then
                   Temp:=Chr (Transf+48)+Temp;
                 If Sign=-1 then
                   Temp:=Neg (Temp)
               End
           End;
         Temp:=FormatLongNumber (Temp,0);
         Add:=Temp
       End;

   Function Subtract (A,B:string) : string;
     Var Temp : string;
       Begin
         Subtract:=Add (A,Neg (B))
       End;

   Function Multiple (A,B:string) : string;
     Var Sign, SgnA, SgnB, N : shortint;
         I, J, D, Transf     : byte;
         N1, N2, Temp, S     : string;
       Begin
         SgnA:=Sgn (A);
         SgnB:=Sgn (B);
         Sign:=SgnA*SgnB;
         If SgnA=-1 then
           N1:=Neg (A)
                    else
           N1:=A;
         If SgnB=-1 then
           N2:=Neg (B)
                    else
           N2:=B;
         If Sign=0 then
           Temp:='0'
                   else
           Begin
             N1:=FormatLongNumber (N1,0);
             N2:=FormatLongNumber (N2,0);
             Temp:='0';
             For J:=Length (N2) downto 1 do
               Begin
                 D:=Dgt (N2 [J]);
                 Transf:=0;
                 S:='';
                 For I:=1 to Length (N2)-J do
                   S:=S+'0';
                 For I:=Length (N1) downto 1 do
                   Begin
                     N:=Transf+D*Dgt (N1 [I]);
                     If Length (S)=255 then
                       LongNumErrorFlag:=True;
                     S:=Chr (N mod 10+48)+S;
                     Transf:=N div 10
                   End;
                 If Transf>0 then
                   If Length (S)=255 then
                     LongNumErrorFlag:=True
                                     else
                     S:=Chr (Transf+48)+S;
                 Temp:=Add (Temp,S)
               End
           End;
         If Sign=-1 then
           Temp:=Neg (Temp);
         Temp:=FormatLongNumber (Temp,0);
         Multiple:=Temp
       End;

   Function Divide (A,B:string;var Remainder:string) : string;
     Var Sign, SgnA, SgnB     : shortint;
         I, J                 : byte;
         N1, N2, Temp, S1, S2 : string;
       Begin
         SgnA:=Sgn (A);
         SgnB:=Sgn (B);
         Sign:=SgnA*SgnB;
         If SgnA=-1 then
           N1:=Neg (A)
                    else
           N1:=A;
         If SgnB=-1 then
           N2:=Neg (B)
                    else
           N2:=B;
         N1:=FormatLongNumber (N1,0);
         N2:=FormatLongNumber (N2,0);
         If not GreaterOrEqual (N1,N2) then
           Begin
             Temp:='0';
             If SgnA=-1 then
               Remainder:=Neg (N1)
                        else
               Remainder:=N1
           End
                                    else
           Begin
             Temp:='';
             S1:=N1;
             For I:=1 to Length (N1)-Length (N2)+1 do
               Begin
                 S2:=Copy (S1,1,I+Length (N2)-1);
                 J:=9;
                 While Greater (Multiple (N2,Chr (J+48)),S2) do
                   Dec (J);
                 Temp:=Temp+Chr (J+48);
                 S1:=Subtract (S2,Multiple (N2,Chr (J+48)))+Copy (S1,I+Length (N2),Length (S1)-I-Length (N2)+1);
                 While Length (S1)<Length (N1) do
                   S1:=' '+S1
               End;
             If SgnA=-1 then
               Remainder:=Neg (Subtract (N1,Multiple (N2,Temp)))
                         else
               Remainder:=Subtract (N1,Multiple (N2,Temp));
           End;
         If Sign=-1 then
           Temp:=Neg (Temp);
         Temp:=FormatLongNumber (Temp,0);
         Divide:=Temp
       End;

   Function Power (A:string;B:byte) : string;
     Var I     : byte;
         Temp  : string;
         Error : Boolean;
       Begin
         Error:=False;
         Temp:='1';
         For I:=1 to B do
           Temp:=Multiple (Temp,A);
         Temp:=FormatLongNumber (Temp,0);
         Power:=Temp
       End;

   Function Square (A:string) : string;
     Begin
       Square:=Multiple (A,A)
     End;

   Function SquareRoot (A:string) : string;
     Var I                          : byte;
         J                          : char;
         N, Temp, S1, S2, Remainder : string;
       Begin
         N:=FormatLongNumber (A,0);
         If Sgn (N)=-1 then
           Begin
             LongNumErrorFlag:=True;
             N:=Neg (A)
           End;
         If Length (N) mod 2=1 then
           Begin
             S1:=' '+N [1];
             I:=2
           End
                               else
           Begin
             S1:=N [1]+N [2];
             I:=3
           End;
         Temp:=Chr (Trunc (Sqrt (MakeInt (S1)))+48);
         Remainder:=Subtract (S1,Square (Temp));
         While I<Length (N) do
           Begin
             S1:=Remainder+N [I]+N [I+1];
             J:='9';
             S2:=Multiple (Temp,'2');
             While Greater (Multiple (S2+J,J),S1) do
               Dec (J);
             Temp:=Temp+J;
             Remainder:=Subtract (S1,Multiple (S2+J,J));
             Inc (I,2)
           End;
         SquareRoot:=Temp
       End;

   Function LongToHex (A:string) : string;
     Const HexDigit : array [0..15] of char =
         ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
     Var SgnA               : shortint;
         Temp, N, Remainder : string;
       Begin
         Temp:='';
         SgnA:=Sgn (A);
         If SgnA=-1 then
           N:=Neg (A)
                    else
           N:=FormatLongNumber (A,0);
           Repeat
             N:=Divide (N,'16',Remainder);
             Temp:=HexDigit [MakeInt (Remainder)]+Temp;
           Until N='0';
         If SgnA=-1 then
           Temp:='-'+Temp;
         LongtoHex:=Temp
       End;

   Function HexToLong (A:string) : string;
     Var SgnA            : shortint;
         I               : byte;
         N, Temp, S1, S2 : string;
       Begin
         Temp:='';
         S1:='1';
         SgnA:=Sgn (A);
         If SgnA=-1 then
           N:=Neg (A)
                    else
           N:=FormatLongNumber (A,0);
         For I:=Length (N) downto 1 do
          Begin
            If N [I] in ['0'..'9'] then
              S2:=N [I]
                                   else
              If UpCase (N [I]) in ['A'..'F'] then
                S2:='1'+Chr (Ord (N [I])-17)
                                              else
                LongNumErrorFlag:=True;
            Temp:=Add (Temp,Multiple (S1,S2));
            S1:=Multiple (S1,'16')
          End;
         If SgnA=-1 then
           Temp:='-'+Temp;
         HexToLong:=Temp
       End;

   Function Equal (A,B:string) : Boolean;
     Begin
       Equal:=Sgn (Subtract (A,B))=0
     End;

   Function Greater (A,B:string) : Boolean;
     Begin
       Greater:=Sgn (Subtract (A,B))>0
     End;

   Function GreaterOrEqual (A,B:string) : Boolean;
     Begin
       GreaterOrEqual:=Sgn (Subtract (A,B))>=0
     End;

{
   Begin
     LongNumErrorFlag:=False
   End.
}

{ ---------------------- Demo program ---------------------- }

{Program LongTest;}

  {Uses Crt, LongNum;}

  Var L                 : longint;
      S1, S2, Remainder : string;

  Begin
    ClrScr;
    S1:=MakeLong (-198371298);
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Write (S1);
    L:=MakeInt (S1);
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln (' = ',L);
    Writeln;
    S1:=Add ('1234567890','987654321');
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('1234567890 + 987654321 = ',S1);
    Writeln;
    S1:=Multiple ('-123','456');
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('-123 * 456 = ',S1);
    Writeln;
    S1:=Divide ('12345','-456',Remainder);
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('12345 / (-456) = ',S1,' [',Remainder,']');
    Writeln;
    S1:=Power ('-1234567890',5);
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('-1234567890^5 = ',S1);
    Writeln;
    S1:=Square ('-1234567890');
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('-1234567890^2 = ',S1);
    Writeln;
    S2:=S1;
    S1:=SquareRoot (S1);
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('Sqrt (',S2,') = ',S1);
    Writeln;
    S1:=LongToHex ('1234567890987654321');
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln ('1234567890987654321 = ',S1,'H');
    Writeln;
    S2:=S1;
    S1:=HexToLong (S1);
    If LongNumError then
      Writeln ('Error in calculations.')
                    else
      Writeln (S2,'H = ',S1)
  End.
