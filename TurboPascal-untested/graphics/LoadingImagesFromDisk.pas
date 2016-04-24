(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0038.PAS
  Description: Loading Images from Disk
  Author: STEFAN XENOS
  Date: 11-02-93  05:55
*)

{
STEFAN XENOS

> I am able to load an image into a buffer and display it with PutImage ect.,
> but I would like to load the image from disk instead of with getimage.

Name: ImageStuff.Pas
Purpose: ImageStuff is a unit for storing bitmaps in dynamic variables and
         writing them to disk.
Progger: Stefan Xenos

This unit is public domain.}

Unit ImageStuff;

interface

Uses
 Graph;

Type
  Image = Record
    BitMap : Pointer;
    Size   : Word;
 end;

Procedure Get(X1, Y1, X2, Y2 : Word; Var aImage : Image);
Procedure Put(X, Y : Word; aImage : Image; BitBlt : Word);
Procedure Kill(Var aImage : Image);
Procedure Save(Var F : File; aImage : Image);
Procedure Load(Var F : File; Var aImage : Image);

implementation

Procedure Get(X1, Y1, X2, Y2 : Word; Var aImage : Image);
{Clips an image from the screen and store it in a dynamic variable}
Begin
  aImage.bitmap := nil;
  aImage.size   := ImageSize(X1, Y1, X2, Y2);
  GetMem(aImage.BitMap,aImage.Size);    {Ask for some memory}
  GetImage(X1, Y1, X2, Y2, aImage.BitMap^); {Copy the image}
End;

Procedure Put(X, Y : Word; aImage : Image; BitBlt : Word);
Begin
  PutImage(X, Y, aImage.BitMap^, BitBlt);   {Display image}
End;

Procedure Kill(Var aImage : Image);
{Frees up the memory used by an unwanted image}
Begin
  FreeMem (aImage.BitMap, aImage.Size); {Free up memory used by image}
  aImage.Size   := 0;
  aImage.BitMap := Nil;
End;

Procedure Save(Var F : File; aImage : Image);
{Saves an image to disk. File MUST already be opened for write}
Begin
  BlockWrite(F, aImage.Size, 2);             {Store the image's size so that
                                            it may be correctly loaded later}
  BlockWrite(F, aImage.BitMap^, aImage.Size); {Write image itself to disk}
End;

Procedure Load (Var F : File; Var aImage : Image);
{Loads an image off disk and stores it in a dynamic variable}
Begin
 BlockRead(F, aImage.Size, 2);              {Find out how big the image is}
 GetMem(aImage.BitMap, aImage.Size);        {Allocate memory for it}
 BlockRead(F, aImage.BitMap^, aImage.Size)  {Load the image}
End;

Begin
End.

{
Here's some source which should help you figure out how to use the unit I
just sent.
}

{By Stefan Xenos}
Program ImageTest;

Uses
  Graph,
  ImageStuff;

Var
  Pic      : Image;
  LineNum  : Byte;
  DataFile : File;
  GrDriver,
  GrMode   : Integer;

Const
 FileName = 'IMAGE.DAT';
 MaxLines = 200;

Begin
 {Initialise}
 DetectGraph(GrDriver, GrMode);
 InitGraph(GrDriver, GrMode, '');
 Randomize;

 {Draw some lines}
 For LineNum := 1 to MaxLines do
 begin
   setColor(random (maxcolors));
   line(random(getmaxx), random(getmaxy), random(getmaxx), random(getmaxy));
 end;

 {Copy image from screen}
 Get(100, 100, 150, 150, Pic);

 readLn;

 {Clear screen}
 ClearDevice;

 {Display image}
 Put(100, 100, Pic, NormalPut);

 readLn;

 {Clear screen}
 ClearDevice;

 {Save image to disk}
 Assign(DataFile, FileName);
 Rewrite(DataFile, 1);
 Save(DataFile, Pic);
 Close(DataFile);

 {Kill image}
 Kill(pic);

 {Load image from disk}
 Assign(DataFile, FileName);
 Reset(DataFile, 1);
 Load(DataFile, pic);
 Close(DataFile);

 {Display image}
 Put(200, 200, Pic, NormalPut);

 readLn;

 CloseGraph;
 WriteLn(Pic.size);
End.

