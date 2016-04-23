{
============================================================

PROGRAM : CLOSECOL.PAS

AUTHOR  : SCOTT TUNSTALL B.Sc

PURPOSE : Get the colour which has specified RGB values from
          the VGA palette.
          If no colour with specified values exists, return
          the nearest colour.


NOTES   :

I seem to recall AGES ago that someone wanted a routine
that would find the colour CLOSEST to a specified RGB
value.

This might help, although I've not tested it extensively.
Tests seem to show it works OK tho'.


Oh yeah. It needs KOJAKVGA (preferably V3) to work as is,
but it won't be too difficult for smart cookies to work out
whats going on, if they want to convert the code to their
units.




DISCLAIMER:

The standard stuff follows:

Unless you're a proud CGA/EGA card user ;), this unit
shouldn't break your PC. 

However, the rule is: use this code AT YOUR OWN RISK.

If you use this code in any programs, please mention my name
in the credits. An ad for KOJAKVGA 3.3 would be nice too ;)

Have fun folks!
------------------------------------------------------------
}


program CloseCol;

uses kojakvga, crt;





{
As the function name implies, this gets the palette entry which
contains RGB values closest to those specified.
(C) 1997 Crap explanations ;)


Expects: R,G,B component values to look for;
         Red component must be in range 0-63
         Same applies for Green and Blue.

         Values above 63 are reset to (Value MOD 64) !
         This is due to the limitations of the VGA DAC I'm afraid.


Returns: index (0-255) of closest or matching colour.
}


function GetClosestVGAColour(SearchRed,SearchGreen,SearchBlue:byte) : byte;
var bestindex, currRed, currGreen, currBlue, colourcount: byte;
    distred, distgreen, distblue,
    bestdistred, bestdistgreen, bestdistblue: integer;
    RGBTotal, BestRGBTotal: word;

begin
     bestindex:=0;
     distred:=255;              { Distance of red from SearchRed value }
     distgreen:=255;
     distblue:=255;

     bestdistred:=255;
     bestdistgreen:=255;
     bestdistblue:=255;
     BestRGBTotal:=255+255+255; { R,G,B summed }


     { Iterate (love that word!) through all palette entries }

     for colourcount:=0 to 255 do
         begin
         { Read colour from VGA adaptor directly. }

         GetRGB(colourcount,currRed,currGreen,currBlue);


         { Compute Red/Green and Blue distances }

         distred:=abs(CurrRed-SearchRed);
         distgreen:=abs(CurrGreen-SearchGreen);
         distblue:=abs(CurrBlue-SearchBlue);

         { The lower the sum of RGB distances, the closer
           the colour is to what was required }

         RGBTotal:=distred+distgreen+distblue;
         If RGBTotal <= BestRGBTotal Then
         Begin
            BestIndex:=ColourCount;

            { If we've got a perfect match, i.e. the
              total colour distance is 0, then
              break the loop }

            If RGBTotal = 0 Then
               break
            else
                BestRGBTotal:=RGBTotal;


         End;
     end;


     { And return the closest colour's palette index }

     getClosestVGAColour:=BestIndex;
end;








{ Support function to display red, green, blue values at X,Y in
  colour printcolour }

procedure PrintRGB(x:word; y, printcolour, r,g,b: byte);
var NumStr: string[3];
    Builtstr:string[30];
begin
    str(r, BuiltStr);
    str(g, NumStr);
    BuiltStr:=BuiltStr+','+NumStr;
    str(b, NumStr);
    BuiltStr:=BuiltStr+','+NumStr;
    UseColour(printcolour);
    PrintAt(x,y,BuiltStr);
end;










{ Test. You input your required RGB values and the system shows
  two blocks which should be nearly - or even better,
  ** exactly ** - the same colour shade.
}



var MyRed, MyGreen, MyBlue,             { RGB of colour to look for }
    FoundRed, FoundGreen, FoundBlue,    { RGB of closest colour }
    OurColour, FillColour: byte;        { Indexes for drawing }


begin
     Writeln('What [VGA] R,G,B values are you looking for ? ');
     Write('Red   (0-63) '); Readln(MyRed);
     Write('Green (0-63) '); Readln(MyGreen);
     Write('Blue  (0-63) '); Readln(MyBlue);


     InitVGAMode;
     OurColour:=GetClosestVGAColour(MyRed, MyGreen, MyBlue);


     If OurColour = 0 Then
        FillColour:= 1
     Else
         FillColour:= OurColour -1;

     SetRGB(FillColour,MyRed,MyGreen,MyBlue);

     { Display colour looked for }

     PrintRGB(0,0,FillColour, MyRed, MyGreen, MyBlue);
     FillArea(0,16,158,199, FillColour);

     { Display closest colour }

     GetRGB(OurColour, FoundRed, FoundGreen, FoundBlue);
     PrintRGB(160,0, OurColour, FoundRed, FoundGreen, FoundBlue);
     FillArea(161,16,319,199,OurColour);


     { And do I have to explain what this does? }

     repeat until keypressed;
End.


