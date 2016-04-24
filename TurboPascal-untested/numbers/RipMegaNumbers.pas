(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0048.PAS
  Description: RIP Mega Numbers
  Author: JASON KING
  Date: 05-25-94  08:21
*)


{
You're right about that... The only thin why I found it difficult, is
because TP (or any other language) doesn't support the MenaNum itself..
Some other thing is that when you're creating a file, you need to use
two windows, and constantly convert the numbers... But for the source,
thanks, I'll look it over... Is it Ok with you when I place it in the
download of my BBS..? I havn't seen any DEC<>MEGA program yet...

Try this...
}

Function MegaToDec(Num: String) : LongInt; {Converts String MEGA to Dec}
Const MegaNum : Set of Char = ['0'..'9','A'..'Z']; {assume UC}

Var HoldNum,
    TempVal : LongInt;
    CharPos : Byte; {Position of Character}

    Function ToThirtySix(Ex: Byte) : Longint; {Raises to power of 36}
    Var Times: Byte;
        HoldPower: LongInt;

    Begin
        HoldPower:=0;
        If Ex=0 then begin
           ToThirtySix:=1;
           End;
        For Times:=1 to Ex do HoldPower:=HoldPower*36;
        ToThirtySix:=HoldPower;
    End;

   Function ConvertVal(Ch: Char) : Byte;
   Var Temp : Char;
   Begin
        Temp:=Ch;
        Upcase(Temp);
        If Ord(Ch)>47 and Ord(Ch)<58 then ConvertVal:=Ord(Ch)-48;
                {Converts if 0..9}
        If Ord(Ch)>64 and Ord(Ch)<91 then ConvertVal:=Ord(Ch)-55;
   End;

   Begin
        HoldNum:=0;
        For CharPos:=Length(Num) downto 1 do
            HoldNum:=HoldNum+ConverVal(Num[CharPos])*
                ToThirtysix(CharPos-1);
        MegaToDec:=HoldNum;
   End;

Note: this is untested, but it should work... try values of 10 Mega 
(should by 36 dec) or 2Z (should be 107 dec I think)... Tell me how it
works...

