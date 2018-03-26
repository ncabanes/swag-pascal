(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0083.PAS
  Description: Convert Byte to Binary
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

{

   Convert a byte into his binary representation


               +----------------------------------------+
               |                                        |H
               |          AVONTURE CHRISTOPHE           |H
               |              AVC SOFTWARE              |H
               |     BOULEVARD EDMOND MACHTENS 157/53   |H
               |           B-1080 BRUXELLES             |H
               |              BELGIQUE                  |H
               |                                        |H
               +----------------------------------------+H
                HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH

}

Function Byte2Bin (Chiffre : Byte) : String;

Var I, Temp : Byte;
    St      : String;

Begin

   St := '';

   For I := 7 Downto 0 do Begin
       Temp := (Chiffre and (1 shl I));
       If (Temp = 0) then St := St + '0' Else St := St + '1';
   End;

   Byte2Bin := St;

End;

begin
    WriteLn( Byte2Bin(197) );
end.
