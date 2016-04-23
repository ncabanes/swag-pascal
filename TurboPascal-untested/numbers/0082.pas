{

   Two functions: the first convert a Word value in its equivalent in hexa
   and put the  result into  a string.  The  second is  for a  Byte value.



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

Const
   Hexa : Array [0..15] of Char =
       ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

Var
   Ch1 , Ch2 : Byte;
   Ch3 , Ch4 : Byte;

Function Word2Hex(Number: Word) : String;
Begin

  Ch1 := (Number SHR 8) SHR 4;
  Ch2 := (Number SHR 8) - (Ch1 SHL 4);
  Ch3 := (Number AND $FF) SHR 4;
  Ch4 := (Number AND $FF) - (Ch3 SHL 4);

  Word2Hex := Hexa[Ch1]+Hexa[Ch2]+Hexa[Ch3]+Hexa[Ch4];

End;

Function Byte2Hex(Number: Byte) : String;
Begin

    Ch1 := Number SHR 4;
    Ch2 := Number - (Ch1 SHL 4);

    Byte2Hex := Hexa[Ch1]+Hexa[Ch2];

End;