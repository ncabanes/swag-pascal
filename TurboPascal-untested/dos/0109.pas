PROGRAM SFTFilesCount (Input, Output);

{ AUTHOR : John Drabik, Draper, Utah

  Feel free to use this code as you wish.  I'd appreciate it if you'd mention
  me, and SWAG, however.  But if you don't, it's your karma...

There have been several snippets regarding how to increase the number of
available file handles in a program.  However, you may get into trouble
if you extend the handles beyond the value of the FILES=xxx in CONFIG.SYS.
This snippet will tell you the value of FILES=.  If the value is lower than
what your program needs (before creating extended handle space), you should
tell the user to edit their CONFIG.SYS, and then reboot.

The program walks from one "mini" SFT to the next.  This is because there can
be multiple SFTs under DOS, so you need to get the total for all SFTs.

The value of FILES= should be at least 5 more than your program requires (to
allow for stdin, stdout, NULL:, etc.).

If your program will use the stdin, stdout, or lst (printer) defaults, you must
copy the existing SFT into your (newly allocated) SFT - this will be the
subject of another snippet.  Otherwise, you won't be able to access defaults.

This snippet does not include the SFT fields which change from version to
version of DOS (this includes the filename and other useful pieces of data).
As a result, if you need to walk the true SFT to get such data, you'll need a
more complex SFT record (a variant), and a test for the DOS version.  This
code was derived in part from works by Andy Schulman and Neil Rubenking.  Get
one of their books if you need to access extended SFT info.

Finally, this snippet works under vanilla DOS, OS/2, QEMM (with extra files),
and should work with the various flavors of Windoze (though I don't use 'doze
anymore, and have not tested this "cleaned-up" version of the code there.)
}

TYPE MiniSFTPtr = ^MiniSFT;
     MiniSFT = RECORD           { System File Table "mini" pointer, which }
        Next : MiniSFTPtr;      { accesses only the pointer to the next SFT }
        Num  : WORD;            { entry, and the available handle count. }
     END;


FUNCTION FirstSFT : MiniSFTPtr; ASSEMBLER;
ASM
   MOV  AH, 52H
   INT  21H
   MOV  AX, ES:[BX+4]
   MOV  DX, ES:[BX+6]
END;


VAR SFT  : MiniSFTPtr;
    FTot : WORD;

BEGIN
   FTot := 0;
   SFT  := FirstSFT;
   REPEAT
      FTot := FTot + SFT^.Num;
      SFT  := SFT^.Next;
   UNTIL OFS(SFT^) = $FFFF;

   WRITELN ('FILES=', FTot, ' in CONFIG.SYS');
   READLN;
END.


