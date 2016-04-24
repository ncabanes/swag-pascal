(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0031.PAS
  Description: Verify ISBN Numbers
  Author: GREG VIGNEAULT
  Date: 10-28-93  11:32
*)

{===========================================================================
Date: 09-22-93 (20:14)
From: GREG VIGNEAULT
Subj: Pascal ISBN verification

 Here's a snippet of TP code for the free SWAG archives. It verifies
 ISBN numbers, via the embedded checksum ... }

(********************************************************************)
(* Turbo/Quick/StonyBrook Pascal source file: ISBN.PAS  v1.0 GSV    *)
(* Verify any International Standard Book Number (ISBN) ...         *)

PROGRAM checkISBN;

CONST TAB = #9;                       { ASCII horizontal tab         }
      LF  = #10;                      { ASCII line feed              }

VAR ISBNstr : STRING[16];
    loopc, ISBNlen, M, chksm : BYTE;

BEGIN {checkISBN}

  WriteLn (LF,TAB,'ISBN Check v1.0 Copyright 1993 Greg Vigneault',LF);

  IF ( ParamCount <> 1 ) THEN BEGIN   { we want just one input parm  }
    WriteLn ( TAB, 'Usage: ISBN <ISBN#>', LF );
    Halt(1);
  END; {IF}

  ISBNstr := ParamStr (1);            { get the ISBN number          }
  Write ( TAB, 'Checking ISBN# ', ISBNstr, ' ...' );
  { eliminate any non-digit characters from the ISBN string...       }
  ISBNlen := 0;
  FOR loopc := 1 TO ORD ( ISBNstr[0] ) DO
    IF ( ISBNstr[ loopc ] IN ['0'..'9'] ) THEN BEGIN
      INC ( ISBNlen );
      ISBNstr[ ISBNlen ] := ISBNstr[ loopc ];
  END; {IF & FOR}
  { an 'X' at the end of the ISBN affects the result...              }
  IF ( ISBNstr[ ORD ( ISBNstr[0] ) ] IN ['X','x'] ) THEN
    M := 10
  ELSE
    M := ORD ( ISBNstr[ ISBNlen ] ) - 48;
  ISBNstr[0] := CHR ( ISBNlen );          { new ISBN string length   }
  WriteLn ( 'reduced ISBN = ', ISBNstr );  WriteLn;
  chksm := 0;                             { initialize checksum      }
  FOR loopc := 1 TO ISBNlen-1 DO
    INC (chksm, ( ORD ( ISBNstr[ loopc ] ) - 48 ) * loopc );
  Write ( TAB, 'ISBN ' );
  IF ( ( chksm MOD 11 ) = M ) THEN
    WriteLn ( 'is okay.' )
  ELSE
    WriteLn ( 'error!',#7 );

END {checkISBN}.                      (* Not for commercial retail. *)

