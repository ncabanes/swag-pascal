(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0178.PAS
  Description: 3D Graphics Algorithms
  Author: ALEX CHALFIN
  Date: 05-26-95  23:19
*)

{
Here is a little something I cooked up as a reference. It is complete
3 dimentional rotation formulas. Hopefully they will help you get a good
start. They are a little different then some of the VLA's (or whoever)
formulas because I derived them myself for my own purposes :) They do work,
as I use them myself. Hopefully they will give you a little insight on
how to begin.

            -= Conventions =-

sx = Sin(XAngle)       cx = Cos(XAngle)
sy = Sin(YAngle)       cy = Cos(YAngle)
sz = Sin(ZAngle)       cz = Cos(ZAngle)

           -= Matrix Rotations =-

  X-Rotation Matrix
+            +
| 1   0   0  |
| 0   cx  sx |
| 0  -sx  cx |
+            +

  Y-Rotation Matrix
+            +
| cy  0  -sy |
| 0   1   0  |
| sy  0   cy |
+            +

  Z-Rotation Matrix
+            +
|  cz  sz  0 |
| -sz  cz  0 |
|  0   0   1 |
+            +

  Total rotation matrix

   [0,0]                                       [0,2]
+                                                    +
|  (cz*cy)+(sz*sx*sy)   (cy*-sz)+(cz*sx*sy)  (cx*sy) |
|                                                    |
|  (sz*cx)              (cz*cx)              (-sx)   |
|                                                    |
|  (-sy*cz)+(sz*sx*cy)  (sz*sy)+(cz*sx*cy)   (cx*cy) |
+                                                    +
   [2,0]                                       [2,2]

   Rotation Order:  Z,X,Y ( Rotated on Z axis first, then X, then Y )


     -= Coordinate Transformations =-

FinalCoord.x = InitialCoord.x * Matrix[0,0] +
                InitialCoord.y * Matrix[1,0] +
                InitialCoord.z * Matrix[2,0]
FinalCoord.y = InitialCoord.x * Matrix[0,1] +
                InitialCoord.y * Matrix[1,1] +
                InitialCoord.z * Matrix[2,1]
FinalCoord.z = InitialCoord.x * Matrix[0,2] +
                InitialCoord.y * Matrix[1,2] +
                InitialCoord.z * Matrix[2,2]

     -= Non-Matrix Rotations =-

 X - Rotations:
   x = x
   y = (y * cx) - (z * sx)
   z = (y * sx) + (z * cx)

 Y - Rotations:
   x = (x * cy) + (z * sx)
   y = y
   z = (z * cy) - (x * sy)

 Z - Rotations
   x = (x * cz) - (y * sz)
   y = (x * sz) + (y * cz)
   z = z

 -= EOF =-


