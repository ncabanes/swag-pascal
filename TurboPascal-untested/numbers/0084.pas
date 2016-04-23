{

   Swap a byte: the bit 0 will become the bit 7 of the new byte
                        1 will become the bit 6 of the new byte
                        and so on.

        For example 00010010b will be converted to 01001000b
                    10000100b                      00100001b


               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

}

Function SwapBin (Chiffre : Byte) : Byte;

{ Usefull when you must mirror a matrix }

Var I, Temp : Byte;
    Tempo   : Byte;

Begin

   Tempo := 0;

   For I := 7 Downto 0 do Begin
       Temp  := (Chiffre and (1 shl Abs(I-7)));
       If Temp = 0 then Tempo := (Tempo shl 1)
       Else Tempo := (Tempo shl 1) + 1;
   End;

   SwapBin := Tempo;

End;
