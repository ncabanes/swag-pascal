{
>How do I compile a Graphic Program With the Graph included.

I think what you'd like to be included in your EXE File are the BGI drivers ;
here is a sample code to include the EGAVGA.BGI driver in your EXE :
}

Unit EgaVga;

Interface

Uses
  Graph;

Implementation

{$L EgaVga}
Procedure DriverEgaVga; External;

begin
  If RegisterBGIDriver(@DriverEgaVga)<0 Then
    Halt(1);
end.

{
What you need to do is just include the Unit in your 'Uses' statement.
Well, prior to do this, you'll need to enter the following command at
the Dos prompt :

BinObj EGAVGA.BGI EGAVGA.Obj DriverEgaVga

You cand do the same For the other .BGI Files, and even For the .CHR (font)
Files -just replacing RegisterBGIDriver With RegisterBGIFont, I think.
}