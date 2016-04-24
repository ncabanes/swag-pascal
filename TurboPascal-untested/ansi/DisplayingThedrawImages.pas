(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0013.PAS
  Description: Displaying THEDRAW Images
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{▐ Oh, about the thedraw screens, here's
▐ a bit of code in which you can load up a File saved as O)bject, P)ascal.
▐ Oh this is saved as Uncrunched not Crunched.
▐
▐ {$L,TESTFile.OBJ}  {This is the File you saved in thedraw as a Object}
                    {It is linked directly into the code at Compile time}

 Procedure ImageData; external;   {The imagedata Procedure you can}
                                  {define the name of this Procedure}
                                  {when you save the File in TheDraw}
 begin
     Move (Pointer(@ImageData)^,ptr($B800,0)^,5000);
     Readln;
 end.

{By using the Move instruction, the placement of the image
is restricted to full screens or essentially 80 Character lines.
}

