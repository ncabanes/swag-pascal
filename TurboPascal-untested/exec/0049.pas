{

   The purpose of this program is to extract show how we can put a constant
   into our program and then, when the program is running, modify this
   constant in the EXE file.  So, on the next run, the constant will be
   modified.

   WARNING: A PROGRAM LIKE THAT CAN'T BE NEVER COMPRESSED BY PKLITE, LZEXE,
            DIET OR ANY OTHER  EXE COMPRESSOR.  THIS  PROGRAM CAN'T ALSO BE
            ENCRYPTED BY A PROGRAM!!!   SO BE CAREFULL!!!

   Try to  run  this program  severall times  from  the DOS prompt and NEVER
   FROM THE PASCAL IDE.



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

Const Tour       : Integer = 0;
      Taille_Psp : Integer = 256;

Var   Fich       : File;
      Taille_Hdr : Word;

Begin

       Assign (Fich,ParamStr(0));
       Reset (Fich,1);
       Seek (Fich, 8);
       BlockRead (Fich, Taille_Hdr, 1);
       Tour := Tour+1;
       Writeln ('You have used this program ',tour,' times');
       Seek (Fich, LongInt(Taille_Hdr) Shl 4
           +(Dseg-PrefixSeg) shl 4-Taille_Psp+Ofs(Tour));
       BlockWrite (Fich, Tour, 1);

       If (Tour = 5) then
          Begin
             Writeln ('You have already used this program five times.  '+
                      'Is it cool?');

          End;
End.