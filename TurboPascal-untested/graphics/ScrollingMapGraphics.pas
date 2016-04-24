(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0254.PAS
  Description: Scrolling Map: Graphics
  Author: WESLEY BURNS
  Date: 03-04-97  13:18
*)


{If any one is interested, a scrolling demo like the one's uses in RPG games}

{Subject: Scrolling Demo}
{Written by: Wesley Burns}
{EMAIL: microcon@iafrica.com}

{Email: me if you have ANY questions about                                   }
{ : 64k DMA Sound Blaster Programming using XMS                              }
{ : Fast Memory Management                                                   }
{ : PCX using XMS                                                            }
{ : XMS Units                                                                }
{ : Pascal in general                                                        }
{ : Or if you have some fast procedures that you don't mind parting with.    }

Var TerrainData:array[1..10000] of byte;
const xsize = 16; {x size of each pixture block}
      ysize = 16; {y size of each pixture block}
      screenxsize = 320;
      screenysize = 200;

{You must add a range checking proc, so that you cant scroll off of the "MAP"}
{                        | | Top left hand co-ords of where to start drawing 
the "map"}
Procedure DrawScreenFill(x,y:integer);
var xx,yy,xpos,ypos,PicToUse:integer;
Begin
 Ypos :=0; XPos := 0;
 for yy := y to y + (screenysize div ysize) do
  begin
   for xx := x to x + (screenxsize div ysize) do
    begin
     PicToUse := TerrainData[100*yy+xx];{Work out matrix for pic to use}

     MaskPic(XPos,YPos, PicToUse, 255, VScreen^);
     {YOU CAN FIND THIS ABOVER PROCEDURE IN THE GRAPHICS SECTION OF SWAG}

     inc(xpos,xsize);
    end;
  inc(Ypos,ysize);
  XPos := 0;
  end;
End;

Begin
End.

