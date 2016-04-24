(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0116.PAS
  Description: Remove all chars in keyboard buffer
  Author: AVONTURE CHRISTOPHE
  Date: 03-04-97  13:18
*)

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
