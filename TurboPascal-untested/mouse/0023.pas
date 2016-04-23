(* ************************************************************************
   Example of ANIVGA sprite mouse using the default TurboVision Drivers unit.
   Procedures in Drivers unit divide MouseInt coordinates (i.e. SAR 3) by 8 to
   convert into TPoint screen coordinates.  TPoint is an object containing a
   pair of Integers.  Consequently, the default mouse is pixel precise for X =
   0..79 and Y = 0..24 but should be scaled back up for a larger range.

   Changing the source code from the Drivers unit is best approach.  Make a
   clone unit that has the same keyboard/mouse constants and routines for the
   event-loop.  And ignore the rest.  Otherwise multiply TEvent.Where values
   by 8 repeatedly.  As shown, precision is reduced to 8 pixels as a result.
   ************************************************************************ *)
{$A+,B-,D+,L+,N-,E-,O-,R-,S-,V-,G-,F-,I-,X-}
{$M 16384,0,655360}
PROGRAM SpriteMouse;
{ Author: John Howard  jh
  Version 0.4
  Date: July 23, 1994
}
USES {original sinusoid code from Kai Rohrbacher}
     ANIVGA
    ,Drivers;            {TurboVision event-driven mouse & keyboard}

CONST LoadNumber=42;
      TileName='AEGYPTEN.COD';  {Path & name of any sprite tile to load}
      FirstTile=0;
      Tiles_per_Row=2;          {TileWidth}
      Tiles_per_Column=2;       {TileHeight}
      SpriteName='FLOWER.COD';  {Path & name of any sprite to load}
      CartoonName='HANTEL.LIB'; {Path & name of animated mouse cursor library}
      CartoonHandle=1;
      Cartoon=1;                {sprite number}
      MouseHandle=LoadNumber;   {Clone mouse cursor}
      Mouse=0;                  {sprite number}
      Surf=Mouse +15;           {just a sprite number above split index}
      OFF=0;                    {Switch sprite OFF}
VAR
    x : INTEGER;
    Event : TEvent;      {Drivers}
    MaxFrame : word;
    FrameCount : word;

CONST
{ CRT Foreground and background color constants }
  Black         = 0;
  Blue          = 1;
  Green         = 2;
  Cyan          = 3;
  Red           = 4;
  Magenta       = 5;
  Brown         = 6;
  LightGray     = 7;

{ CRT Foreground color constants }
  DarkGray      = 8;
  LightBlue     = 9;
  LightGreen    = 10;
  LightCyan     = 11;
  LightRed      = 12;
  LightMagenta  = 13;
  Yellow        = 14;
  White         = 15;

BEGIN
 IF loadSprite(SpriteName,LoadNumber)=0
  THEN BEGIN
        WRITELN('Couldn''t access file '+SpriteName+' : '+GetErrorMessage);
        halt(1)
       END;
 MaxFrame:=loadSprite(CartoonName,CartoonHandle);
{$IFDEF DEBUG}
    writeln(CartoonName+' contains : ', MaxFrame); halt(1);
{$ENDIF}
 IF Error<>Err_None
  THEN BEGIN
        WRITELN('Couldn''t access file '+CartoonName+' : '+GetErrorMessage);
        halt(1)
       END;
 InitEvents;             {Drivers}
 HideMouse;              {Drivers}

 InitGraph;
 IF loadTile(TileName, FirstTile)=0
  THEN BEGIN
        CloseRoutines;
        DoneEvents;      {Drivers}
        WRITELN('Couldn''t access file '+TileName+' : '+GetErrorMessage);
        halt(1)
       END;
 FillBackground(LightRed);               {Border}
 SetAnimateWindow(32,24, XMAX-32, YMAX-24);
 SetBackgroundMode(SCROLLING);           {Tiles}
 SetBackgroundScrollRange(0,0,XMAX,YMAX);  {Tiles}
 MakeTileArea(FirstTile,Tiles_per_Row,Tiles_per_Column);

 SetSplitIndex(Mouse + MaxFrame);
 SetCycleTime(30);                       {millisec between frames}
 SpriteN[Surf]:=LoadNumber;
 SpriteN[Mouse]:=MouseHandle;            {clone sprite for default mouse}

 FrameCount := 1;                        {min frame number}
 repeat
 FOR x:=0 TO XMAX DO                     {vary the horizontal}
  BEGIN
   SpriteX[Surf]:=x;                     {sinusoid}
   SpriteY[Surf]:=TRUNC( sin(2.0*pi*x/XMAX)*(YMAX SHR 1)+YMAX SHR 1 );

   Event.What := evNothing;              {ClearEvent}
   GetMouseEvent(Event); {Drivers}
   if (Event.What and evMouse) <> 0 then
     if (Event.What = evMouseAuto) then
     begin   {animate mouse when button held down.  Note: sporadic reporting}
        SpriteN[Cartoon]:= OFF;
        SpriteN[Mouse]:= OFF;
        if (FrameCount < MaxFrame) then  {min..max frame or restart}
          inc(FrameCount)  {min frame number}
        else
          FrameCount := 1;               {start}
        SpriteN[Cartoon]:= FrameCount;
        SpriteX[FrameCount]:= Event.Where.X shl 3;
        SpriteY[FrameCount]:= Event.Where.Y shl 3;
     end
     else
     begin   {default mouse cursor}
        SpriteN[Cartoon]:= OFF;
        SpriteN[Mouse]:= MouseHandle;
        SpriteX[Mouse]:= Event.Where.X shl 3;
        SpriteY[Mouse]:= Event.Where.Y shl 3;
     end; {if}
   {if "mouse (X,Y) within ClipRectangle" then}
   UpdateOuterArea := 2;                 {Required for non-dynamic background}
   Animate;
  END;

  GetKeyEvent(Event);    {Drivers}
 until (Event.What = evKeyDown);         {keypressed}

 CloseRoutines;
 DoneEvents;             {Drivers}
END.
