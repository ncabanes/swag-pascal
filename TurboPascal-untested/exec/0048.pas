{
                 =======================================

                       EXE-HEAD (c) AVC Software
                               Cardware

                  Display all  informations  containing
                  in the EXE DOS header.

                 =======================================

   Display all informations containing in the EXE DOS header.



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

Uses Crt;

Var Fich : File;
    Header : Array[0..27] of Byte;

Procedure Aide;

Begin

   Writeln ('');
   Writeln ('Please specify the name of executable file.');
   Writeln ('');
   Writeln ('For exemple :  EXE-HEAD.EXE  EXEMPLE.EXE');
   Writeln ('');

End;

Function Word2Hex(Number: Word) : String;

Const Hexa : Array [0..15] of Char = ('0','1','2','3','4','5','6','7','8',
                                      '9','A','B','C','D','E','F');

Var Ch1 , Ch2 : Byte;
    Ch3 , Ch4 : Byte;

Begin

  Ch1 := (Number Shr 8) shr (4);
  Ch2 := (Number Shr 8) - (Ch1 shl (4));
  Ch3 := (Number AND $FF) shr (4);
  Ch4 := (Number AND $FF)- (Ch3 shl (4));

  Word2Hex := Hexa[Ch1]+Hexa[Ch2]+Hexa[Ch3]+Hexa[Ch4];

End;



Begin

     If ((ParamCount = 0) or (ParamCount > 1)) then Aide
     Else Begin
          Assign (Fich, ParamStr(1));
          Reset (Fich, 1);
          BlockRead (Fich, Header, 28);
          Close (Fich);
          ClrScr;
          Writeln ('');
          Writeln ('■ AVC Software, Inc.                         (c) Octobre 1994');
          Writeln ('■ Exe-Head');
          WriteLn ('');
          If (Chr(Header[0]) = 'M') and (Chr(Header[1]) = 'Z') then Begin
            WriteLn ('Signature du fichier                        : ',Chr(Header[0]),Chr(Header[1]));
            WriteLn ('');
            WriteLn ('Taille de la dernière page                  : ' ,Word2Hex((Header[3] shl 8) + Header[2]),'h');
            WriteLn ('Nombres de pages                            : ' ,Word2Hex((Header[5] shl 8) + Header[4]),'h');
            WriteLn ('Entrées de la table de relocalisation       : ' ,Word2Hex((Header[7] shl 8) + Header[6]),'h');
            WriteLn ('Paragraphes de l''en-tête                    : ',Word2Hex((Header[9] shl 8) + Header[8]),'h');
            WriteLn ('MINALLOC                                    : ' ,Word2Hex((Header[11] shl 8) + Header[10]),'h');
            WriteLn ('MAXALLOC                                    : ' ,Word2Hex((Header[13] shl 8) + Header[12]),'h');
            WriteLn ('ss initial                                  : ' ,Word2Hex((Header[15] shl 8) + Header[14]),'h');
            WriteLn ('sp initial                                  : ' ,Word2Hex((Header[17] shl 8) + Header[16]),'h');
            WriteLn ('Total de contrôle                           : ' ,Word2Hex((Header[19] shl 8) + Header[18]),'h');
            WriteLn ('ip initial                                  : ' ,Word2Hex((Header[21] shl 8) + Header[20]),'h');
            WriteLn ('cs initial                                  : ' ,Word2Hex((Header[23] shl 8) + Header[22]),'h');
            WriteLn ('Offset de la table de relocalisation        : ' ,Word2Hex((Header[25] shl 8) + Header[24]),'h');
            WriteLn ('Nombre du segemnt de recouvrement           : ' ,Word2Hex((Header[27] shl 8) + Header[26]),'h');
          End
          Else WriteLn (ParamStr(1),' n''est pas un fichier de type .EXE');
          WriteLn ('');
     End;

End.