(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0001.PAS
  Description: Verify ISBN Numbers
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{
 For you Programming librarians: the following Turbo Pascal Program
 will verify any ISBN (International Standard Book Number).
}
(*******************************************************************)
 Program VerifyISBN;    { Verify any ISBN number. Turbo Pascal      }
                        { 1992, 1993 Greg Vigneault                 }

 Var    ISBNstr                     : String[16];
        loopc, ISBNlen, M, chksm    : Byte;
 begin
    WriteLn; WriteLn( 'ISBN Verification v0.1, Greg Vigneault',#10);

    if ( ParamCount <> 1 ) then begin   { we want just 1 input parm }
        WriteLn( 'Syntax: ISBN <ISBN#>',#7 );
        Halt(1);
    end;
    ISBNstr := ParamStr(1);                     { get ISBN# String  }
    Write( 'Checking ISBN# ', ISBNstr );
    { eliminate any non-digit Characters from the ISBN String...    }
    ISBNlen := 0;
    For loopc := 1 to orD( ISBNstr[0] ) do
        if ( ISBNstr[ loopc ] in ['0'..'9'] ) then begin
            inC( ISBNlen );
            ISBNstr[ ISBNlen ] := ISBNstr[ loopc ];
        end;
    { an 'X' at the end of the ISBN affects the result              }
    if ( ISBNstr[ orD( ISBNstr[0] ) ] in ['X','x'] )
        then M := 10
        else M := orD( ISBNstr[ ISBNlen ] ) - 48;
    ISBNstr[0] := CHR( ISBNlen );           { new ISBN str length   }
    chksm := 0;
    For loopc := 1 to ISBNlen-1 do
        inC( chksm, ( orD( ISBNstr[ loopc ] ) - 48 ) * loopc );
    Write( ' <--- ' );
    if ( ( chksm MOD 11 ) = M )
        then WriteLn( 'Okay' )
        else WriteLn( 'ERRor!',#7 );
 end {VerifyISBN}.
(********************************************************************)

