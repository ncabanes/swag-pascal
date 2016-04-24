(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0106.PAS
  Description: Linked in BGI files
  Author: WIM VAN DER VEGT
  Date: 05-25-94  09:25
*)

{
Here's the recipe to get rid of missing BGI drivers!


To get EGAVGA.OBJ use the BINOBJ utility supplied with Turbo Pascal


BINOBJ EGAVGA.BGI EGAVGA EGAVGA


To use this unit just add it to your uses statement once and forget
all about path's in Initgraph (use ''). The unit can be extended to
support additional drivers, like CGA.BGI. Read the GRAPH.DOC file
on the TP disks.

-----------------------<cut here

{---------------------------------------------------------}
{  Project : Turbo EGAVGA Driver                          }
{  Auteur  : G.W. van der Vegt                            }
{---------------------------------------------------------}
{  Datum .tijd  Revisie                                   }
{  920301.1300  Creatie.                                  }
{---------------------------------------------------------}

UNIT Bgi_01;

INTERFACE

USES
  Graph;

IMPLEMENTATION

{------------------------------------------------}
{----EGAVGA.BGI Driver                           }
{------------------------------------------------}

PROCEDURE Egavga; External;

{$L Egavga.obj}

BEGIN
  IF RegisterBGIDriver(@Egavga)<0
     THEN
       BEGIN
         Writeln('Error registering driver: ',
                  GraphErrorMsg(GraphResult));
         Halt(1);
       END;
END.

