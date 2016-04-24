(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0040.PAS
  Description: Huge 3-D Arrays
  Author: PER-OLOV JERNBERG
  Date: 11-25-95  09:26
*)


uses
  dos,crt,dwc_3d <- dont care... (my 3D-unit)
const
  step  = 1.0;
  mn    = -16;
  mx    = 16;
var
  world                 : array[mn..mx,mn..mx,mn..mx] of byte;
  x,y,z                 : real;
  rx,ry,rz              : byte;

---------( Cut from program )---------

  The largest array i can use is:
    array[-16..16,-16..16,-16..16] of byte;
  but i would like to make it atleast:
    array[-255..255,-255..255,-255..255] of byte;

  i can use dpmi, so memory isn't a problem...

  i have swag but i cant see any example of this in swag :(
  only for 1d arrays (Array[0..1000] of something)

  all kind of help would be helpfull...

 -=> Yours sincerely, Per-Olov Jernberg <=-


