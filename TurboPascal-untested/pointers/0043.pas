{

   Pointers functions: returns the segment and the offset in hexadecimal
   value (in a string variable)


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

Function Segment (Chiffre : Pointer)  : String;

Type TWordRec = Record
       Lo, Hi : Word;
    End;

Begin

     Segment := Word2Hex(TWordRec(Chiffre).Hi);

End;

Function Offset (Chiffre : Pointer)  : String;

Type TWordRec = Record
       Lo, Hi : Word;
    End;

Begin

     Offset := Word2Hex(TWordRec(Chiffre).Lo);

End;

Var
   p : Pointer;

Begin

   p := Ptr($B800:$0000);

   Writeln (Segment(p),":",Offset(p));

End.