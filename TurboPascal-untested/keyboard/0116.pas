{

   Flush the keyboard: removes all characters present in the buffer


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

Procedure FlushKeyboard;

Begin

   Inline ($Fa);
   MemW[$40:$1A] := MemW [$40:$1C];
   Inline ($Fb);

End;

{ Another solution is  While KeyPressed Do ReadKey; }
