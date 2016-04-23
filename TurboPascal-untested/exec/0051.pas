{

   Returns the size of the executable: not the size of the file but
   the size of the EXE by consulting the header of the executable


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

Function  ExeSize (sFile : String) : LongInt;

Var ImageInfo : Record
        ExeID     : Array[ 0..1 ] of Char;
        Remainder : Word;
        Size      : Word
     end;
     FichS    : File;

Begin

  Assign (FichS, sFile);
  FileMode := 0;
  Reset (FichS, 1);

  If Ioresult <> 0 Then
     ExeSize := 0
  Else
     Begin

        { Get the EXE header }

        BlockRead (FichS, ImageInfo, Sizeof (ImageInfo));

        { Check the two first bytes: should be MZ for a DOS executable. }

        If ImageInfo.ExeID <> 'MZ' Then
           ExeSize := 0
        Else
           ExeSize := LongInt (ImageInfo.size-1) Shl 9 + ImageInfo.Remainder;
     End;

End;
