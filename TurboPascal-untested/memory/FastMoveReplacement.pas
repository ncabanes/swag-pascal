(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0015.PAS
  Description: Fast MOVE Replacement
  Author: GAYLE DAVIS
  Date: 05-29-93  22:20
*)

{$S-,R-,V-,I-,N-,B-,F-}

{$IFNDEF Ver40}
  {Allow overlays}
  {$F+,O-,X+,A-}
{$ENDIF}

UNIT FastMove;

INTERFACE

(* This routine will move a block of data from a source to a destination.  It
   replaces Turbo Pascal's Move routine.                                     *)

PROCEDURE FastMover (VAR source;
                    VAR dest;
                    numToMove : WORD);


IMPLEMENTATION

PROCEDURE FastMover (VAR source;
                    VAR dest;
                    numToMove : WORD);

    BEGIN
    INLINE ($8C / $DA / $C5 / $B6 / > SOURCE / $C4 / $BE / > DEST / $8B / $8E / > NUMTOMOVE);
    INLINE ($39 / $FE / $72 / $08 / $FC / $D1 / $E9 / $73 / $11 / $A4 / $EB / $0E / $FD / $01 / $CE);
    INLINE ($4E / $01 / $CF / $4F / $D1 / $E9 / $73 / $01 / $A4 / $4E / $4F / $F2 / $A5 / $8E / $DA);
    END;

END.

