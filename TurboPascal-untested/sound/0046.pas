{
 KP> HOW CAN I CHANGE THE OVERALL VOLUME OF SOUND BLASTER ? It must be a
 KP> single OUT , or something . . .

Actually I did a small program yesterday that maximizes the master, VOC and FM
volumes... Here it is:

[------------------------------ C u t -----------------------]
}

program MaxVol;

  begin
    Port[$224] := 4;     { register 04h - VOC volume }
    Port[$225] := $FF;
    Port[$224] := $22;   { register 22h - *** Master volume *** }
    Port[$225] := $FF;
    Port[$224] := $26;   { register 26h - FM volume }
    Port[$225] := $FF;
  end.

{

This works fine on the SB16 I'm using, and it should work as well with all the
other SB models.
The left volume is in one of the nibbles, and the right in the other (I can't
remember which one is in which nibble though...;).
The max volume for L/R is 15/15, and since 15 shl 4 or 15 = 255 (0FFh) that's
the value I use. I haven't tried but I guess that you can use the 225h port to
read the register contents as well as write it.

 // Christian Kullander
}
