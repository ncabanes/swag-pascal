Well, everyone is asking how to integrate a picture from The Draw into your
Pascal Program, so here is how to do it.

First start up The Draw, and either Draw, or load your picture(pretty
simple).

then select Save.
When asked For a save Format, select (ObJect).
For Save Mode, select (Normal).
For Memory Model, select (Turbo Pascal v4+).
For Reference identifier to use, Type in the name that you wish to have the
picture Procedure named, this will be explained later.
then, For the Filename, of course enter the Filename you wish to save it
under.

Next, is the method to place The .OBJ image into your Program.
Somewhere up in the declairations area (after the Var statements, and
beFore your begin) place the following:

{$L C:\PATH\PICTURE.OBJ}
Procedure ProcName; external;  {Change ProcName to the Reference Identifier
                                That you used when saving the picture}

then, to call that picture, there is 1 of 2 ways. First of all, you can
make another Procedure immediatly after this one that goes as such:

Procedure DrawANSIScreen;
begin
  Move(Pointer(@ProcName)^,prt($B800,0)^,4000);
end;

then all you have to do is call the Procedure DrawANSIScreen to draw your
picture. or you can copy that line beginning With Move into your source
code directly. Make sure to again replace the ProcName With your specified
Referecne Identifier. Make sure to give each picture a different
Identifier, I do not know what the outcome would be if you used the same
one. Probally wouldn't even Compile. Also, I have not tried this With
Animation. Considering that this Writes directly to screen, it probally
won't work, or will be too fast For the human eye to follow. On top of
this, I migh point out that since this IS a direct video access, the cursor
WILL not move For it's last position when the screen is printed, so you can
fill the Complete screen, and it will not scroll.

Hope that this has been helpful. It's very easy, and I pulled it direct
from The Draw docs. This is supposed to work With Pascal 6.0 and up only.
to work With earlier Pascal versions, please read the docs. They entail the
process Completely (but not very understandibly <G>).

