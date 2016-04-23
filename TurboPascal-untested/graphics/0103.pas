(*
  From: Christian Ramsvik
  Subj: bounce    v1.0
Origin: Hatlane Point #9 (2:211/10.9)

HI!  Got a bouncing procedure a while ago.  It bounces a ball, and you can
increase speed in X- and Y-axis by pressing the arrow keys.  I'm sure you can
extract what you need from this one:


  From: John Howard  jh
  Subj: bounce    v1.1
Origin: Synergy (1:280/66)
Upgraded to vary the ball size with / and *.  Compass directions use keypad in
numlock mode or UIOJKNM, keys.  The speed can be changed in each direction.
The gravity effect can vary with + and - keys.  Status report dialog box when
either space or 0 key pressed.  Press 0 again will stop all motion.  Press
keypad_5 will halt display and requires pressing ESCape key to continue.  A
period will reset the ball to default size.
*)

program Bounce;
uses Crt, Graph;
{-$DEFINE solid}
{-$DEFINE bubble}
{ jh
const
     MinBalls = 1;
     MaxBalls = 2;
}
type
    TImage = record
               XPos,                   {x}       {horizontal position}
               YPos    : Integer;      {y}       {vertical position}
               XSpeed,                 {dx}      {actually a velocity}
               YSpeed  : Integer;      {dy}      {actually a velocity}
               XAccel,                 {ddx}     {jh unused acceleration}
               YAccel  : Integer;      {ddy}     {jh unused acceleration}

               Radius  : Byte;         {Ball}
             end;

var
   Ch     : Char;
   Gd, Gm : Integer;
   Image  : {array [MinBalls..MaxBalls] of} TImage;   {jh}
   FullSpeed,                                         {jh}
   HalfSpeed : Integer;           { = FullSpeed div 2}
   {BallNumber : byte;}                               {jh}

{ ******************* DRAW IMAGE ********************* }
procedure DrawImage;
begin
   SetColor( White );
{$IFDEF solid}
   SetFillStyle( SolidFill, White );
{$ELSE}
   SetFillStyle( HatchFill, White );
{$ENDIF}

   with Image do
   begin
{$IFDEF bubble}
      Circle( XPos, YPos, Radius );              {jh Soap bubble}
{$ELSE}
      PieSlice( XPos, YPos, 0, 360, Radius );    {jh Pattern ball}
{$ENDIF}
   end;
end;

{ ******************* REMOVE IMAGE ******************** }
procedure RemoveImage;
begin
   SetColor( Black );
{$IFDEF solid}
   SetFillStyle( SolidFill, Black );
{$ELSE}
   SetFillStyle( HatchFill, Black );
{$ENDIF}

   with Image do
   begin
{$IFDEF bubble}
      Circle( XPos, YPos, Radius );              {jh Soap bubble}
{$ELSE}
      PieSlice( XPos, YPos, 0, 360, Radius );    {jh Pattern ball}
{$ENDIF}
   end;
end;

{ ******************* UPDATE SPEED ******************** }
procedure UpdateSpeed;

         function IntToStr(I: Longint): String;
         { convert any integer to a string }
         var  S: string[11];
         begin
           Str(I,S);
           IntToStr := S;
         end;
begin
   while KeyPressed do
   begin
     Ch := ReadKey;
     Ch := Upcase(Ch);
     case Ch of  { Change speed with keypad numbers }
{jh Note: Keypad_5 causes a halt until escape key pressed}

         '.': Image.Radius := 16;                   {Default}
         '/': Image.Radius := Image.Radius shr 1;   {Reduce}
         '*': Image.Radius := Image.Radius shl 1;   {Enlarge}
         '+': begin
                Inc(FullSpeed);
                HalfSpeed := FullSpeed div 2;
              end;
         '-': begin
                Dec(FullSpeed);
                HalfSpeed := FullSpeed div 2;
              end;
         '8','I': Dec( Image.YSpeed, FullSpeed );   {N upwards}
         '2','M': Inc( Image.YSpeed, FullSpeed );   {S downwards}
         '4','J': Dec( Image.XSpeed, FullSpeed );   {W leftwards}
         '6','K': Inc( Image.XSpeed, FullSpeed );   {E rightwards}
         '0',' ': begin                             {Report statistics}
                    SetColor( White );
                    SetFillStyle( SolidFill, White );
                    Rectangle(8,8,8+160,8+56);                      {box}
                    SetViewPort(8,8,8+160,8+56, ClipOff);           {dialog}
                    OutTextXY(2,2, '<ENTER> resumes');
                    OutTextXY(2,2+8,  'x = ' + IntToStr(Image.XPos));
                    OutTextXY(2,2+16, 'y = ' + IntToStr(Image.YPos));
                    OutTextXY(2,2+24, 'dx = '+ IntToStr(Image.XSpeed));
                    OutTextXY(2,2+32, 'dy = '+ IntToStr(Image.YSpeed));
                    OutTextXY(2,2+40, 'Full Speed = '+ IntToStr(FullSpeed));

                    Ch := ReadKey;                 {repeat until keypressed}
                    ClearViewPort;
                    SetViewPort(0,0,GetMaxX,GetMaxY, ClipOn);       {window}
                    Rectangle(0,0,GetMaxX,GetMaxY);                 {border}
                    if (Ch = '0') then              {Stop motion}
                     begin
                       Image.XSpeed := 0;
                       Image.YSpeed := 0;
                     end;
                  end;
         '7','U': begin                      {NW}
                    Dec(Image.XSpeed, HalfSpeed);
                    Dec(Image.YSpeed, HalfSpeed);
                  end;
         '9','O': begin                      {NE}
                    Inc(Image.XSpeed, HalfSpeed);
                    Dec(Image.YSpeed, HalfSpeed);
                  end;
         '1','N': begin                      {SW}
                    Dec(Image.XSpeed, HalfSpeed);
                    Inc(Image.YSpeed, HalfSpeed);
                  end;
         '3',',': begin                      {SE}
                    Inc(Image.XSpeed, HalfSpeed);
                    Inc(Image.YSpeed, HalfSpeed);
                  end;

     end;  {case}
   end;
   Inc( Image.YSpeed, HalfSpeed );  { Gravitation }  {jh Just so it can vary}
end;

{ ****************** UPDATE POSITIONS ****************** }
procedure UpdatePositions;
begin
   Inc( Image.XPos, Image.XSpeed );
   Inc( Image.YPos, Image.YSpeed );
end;

{ ****************** CHECK COLLISION ******************* }
procedure CheckCollision;
begin
   with Image do
   begin
      if ( XPos - Radius ) <= 0 then  { Hit left wall }
         begin
         XPos   := Radius +1;
         XSpeed := -Trunc( XSpeed *0.9 );
         end;

      if ( XPos + Radius ) >= GetMaxX then { Hit right wall }
         begin
         XPos   := GetMaxX -Radius -1;
         XSpeed := -Trunc( XSpeed *0.9 );
         end;

      if ( YPos -Radius ) <= 0 then  { Hit roof }
         begin
         YPos   := Radius +1;
         YSpeed := -Trunc( YSpeed *0.9 );
         end;

      if ( YPos +Radius ) >= GetMaxY then { Hit floor }
         begin
         YPos   := GetMaxY -Radius -1;
         YSpeed := -Trunc( YSpeed *0.9 );
         end;
   end;
end;

{ ********************* PROGRAM ************************ }

BEGIN
   FullSpeed := 10;
   HalfSpeed := FullSpeed div 2;
   with Image do
   begin
      XPos   := 30;
      YPos   := 30;
      XSpeed := FullSpeed;
      YSpeed :=  0;
      XAccel :=  0;             {jh unused}
      YAccel := 10;             {jh unused}

      Radius := 16;             {arbitrary}
   end;

   Gd := Detect;
   InitGraph( Gd, Gm, '');            {BGI drivers in Current Work Dir (CWD)}
   Gd := GraphResult;
   if (Gd <> grOK) then
     begin
       Gd := Detect;
       InitGraph( Gd, Gm, '\TURBO\TP\');     {BGI drivers in default directory}
     end;
   Rectangle( 0, 0, GetMaxX, GetMaxY );                 {border}
   SetViewPort( 0, 0, GetMaxX, GetMaxY, ClipOn );       {window}

   repeat
      DrawImage;
      Delay( 30 );    {milliseconds Frame delay}
      RemoveImage;

      UpdateSpeed;
      UpdatePositions;
      CheckCollision;
   until Ch = Chr( 27 );

   CloseGraph;
END.
