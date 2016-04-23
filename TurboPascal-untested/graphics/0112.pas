{
 TW> I'll need an algorithm to make a graphic smaller.

 TW> I will read a 640x480x256 and want to make it a smaller size.
 TW> For example 80x60x256 or 160x120x256 or something else.
 TW> Maybe someone could send me an algorithm or a sample.

   If you simply want a smaller version of the original image, then
   it's easy.

  ie, for 640x480 to 160x120 ( 1/4 original size)
}

  FOR Y := 0 TO 119 { 160x120 Y axis }
    BEGIN
      NewY := (Y * 4);  { corresponding point on 640x480 Y axis }
      FOR X := 0 TO 159 DO  { 160x120 X axis }
        BEGIN
          NewX := (X * 4); { corresponding point on 640x480 X axis }
          Image160x120[Y, X] := Image640x480[NewY, NewX];
        END;
    END;

  See, simply multiply each point in 160x120 by 4 to get corresponding
  point in 640x480.  This of course skips all pixels in between...
  Also, the in the example above, note that you cannot have
  an array of [0..479, 0..639] of Byte!  I just put that in there
  to show how it is done.

  Eric Miller
  mysticm@ephsa.sat.tx.us
