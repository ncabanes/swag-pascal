(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0034.PAS
  Description: Mouse Positioning
  Author: UDO JUERSS
  Date: 02-21-96  21:04
*)


{Dear Gayle,
 you make a very good job with SWAG. Let it grow...it's wonderful!
 As a little contribution a small program for mouse-support is added.
 If interested in more, I have a lot of graphic stuff in my bag.

 Happy christmas and a bug-free new 1996!

 Shortdescription:
 Positioning under mouse-control needs calculation of relative mouse-movement.
 Here's a small object (MouseSnap) that does this. The function SnapMove
 returns True if mouse-position exceeds the snap value. the var parameter
 holds the values for DeltaX and DeltaY. With a snap value of 1 normal
 delta-movement is returned.

 Dec. 11, 1995, Udo Juerss, 57078 Siegen, Germany, CompuServe [101364,526]}

uses
  Graph;
{---------------------------------------------------------------------------}

type
  Point           = record
                      X : Integer;
                      Y : Integer;
                    end;

  TRect   = object                                           {Rechteckobjekt}
    A : Point;                  {Startpunkt (oben links) X- und Y-Koordinate}
    B : Point;                  {Endpunkt (unten rechts) X- und Y-Koordinate}
    procedure Init(X1,Y1,X2,Y2:Integer);               {Koordinatenzuweisung}
    procedure Move(Dx,Dy:Integer);                              {Verschieben}
    procedure Draw(Color:Byte);
  end;

  TMouseSnap = object
    Snap        : Integer;                        {Fangwert f|r X/Y-Position}
    DeltaX      : Integer;    {Differenz von aktueller zur letzen X-Position}
    DeltaY      : Integer;    {Differenz von aktueller zur letzen Y-Position}
    LastX       : Integer;              {Restbetrag von letzter X-Berechnung}
    LastY       : Integer;              {Restbetrag von letzter Y-Berechnung}
    Position    : Point;                              {Aktuelle Mausposition}
    OldPosition : Point;                                {Letzte Mausposition}
    procedure Init(ASnap:Integer);
    function  SnapMove(var Delta:Point):Boolean;
  end;
{---------------------------------------------------------------------------}

var
  Gd,Gm      : Integer;
  P          : Point;
  Rect       : TRect;
  MouseSnap  : TMouseSnap;
  IsSnap     : Boolean;
  Snap       : Integer;
{---------------------------------------------------------------------------}

procedure CursorOn; assembler;
asm
           mov   ax,1
           int   33h
end;
{---------------------------------------------------------------------------}

procedure CursorOff; assembler;
asm
           mov   ax,2
           int   33h
end;
{---------------------------------------------------------------------------}

function LeftButton:Boolean; assembler;
asm
           mov   ax,3
           int   33h
           mov   al,bl
           and   al,1
end;
{---------------------------------------------------------------------------}

function RightButton:Boolean; assembler;
asm
           mov   ax,3
           int   33h
           mov   al,bl
           and   al,2
end;
{---------------------------------------------------------------------------}

procedure GetMousePosition(var P:Point); assembler;
asm
           les   di,P
           mov   ax,3
           int   33h
           mov   ax,cx
           stosw
           mov   ax,dx
           stosw
end;
{---------------------------------------------------------------------------}

procedure TRect.Init(X1,Y1,X2,Y2:Integer);
begin
  A.X:=X1;
  A.Y:=Y1;
  B.X:=X2;
  B.Y:=Y2;
end;
{---------------------------------------------------------------------------}

procedure TRect.Move(Dx,Dy:Integer);
begin
  A.X:=A.X + Dx;
  A.Y:=A.Y + Dy;
  B.X:=B.X + Dx;
  B.Y:=B.Y + Dy;
end;
{---------------------------------------------------------------------------}

procedure TRect.Draw(Color:Byte);
begin
  SetColor(Color);
  CursorOff;
  Line(A.X,A.Y,B.X,A.Y);
  Line(A.X,B.Y,B.X,B.Y);
  Line(A.X,A.Y,A.X,B.Y);
  Line(B.X,A.Y,B.X,B.Y);
  CursorOn;
end;
{---------------------------------------------------------------------------}

procedure TMouseSnap.Init(ASnap:Integer);        {Initialisierung TMouseSnap}
begin
  Snap:=ASnap;                      {Parameter f|r X/Y-Fangraster |bernehmen}
  if Snap <= 0 then Snap:=1;                 {Division durch Null verhindern}
  DeltaX:=0;                                        {Variable initialisieren}
  DeltaY:=0;                                        {Variable initialisieren}
  LastX:=0;                                         {Variable initialisieren}
  LastY:=0;                                         {Variable initialisieren}
  GetMousePosition(Position); {Mausposition lesen, damit Position definieren}
  OldPosition:=Position;                             {OldPosition definieren}
end;
{---------------------------------------------------------------------------}

function TMouseSnap.SnapMove(var Delta:Point):Boolean;
begin
  SnapMove:=False;                           {Funtionsergebnis voreinstellen}
  GetMousePosition(Position);                   {Aktuelle Mausposition holen}
  if (Position.X <> OldPosition.X) or (Position.Y <> OldPosition.Y) then
  begin                {Wenn aktuelle Position ungleich der vorherigen, dann}
    DeltaX:=Position.X - OldPosition.X;      {Delta der X-Position berechnen}
    DeltaY:=Position.Y - OldPosition.Y;      {Delta der Y-Position berechnen}
    Inc(DeltaX,LastX);{Delta um den Restbetrag der letzen Berechnung erhvhen}
    Inc(DeltaY,LastY);{Delta um den Restbetrag der letzen Berechnung erhvhen}
    LastX:=DeltaX mod Snap;               {Neuen Restbetrag in LastX sichern}
    LastY:=DeltaY mod Snap;               {Neuen Restbetrag in LastY sichern}
    DeltaX:=DeltaX div Snap;                   {DeltaX durch Fangwert teilen}
    DeltaY:=DeltaY div Snap;                   {DeltaY durch Fangwert teilen}
    DeltaX:=DeltaX * Snap;     {DeltaX = 0/Fangwert/Vielfaches des Fangwerts}
    DeltaY:=DeltaY * Snap;     {DeltaY = 0/Fangwert/Vielfaches des Fangwerts}
    if (Word(DeltaX) >= Snap) or (Word(DeltaY) >= Snap) then
    begin {Wenn DeltaX oder DeltaY gleich oder grv_er als Fangwert ist, dann}
      Delta.X:=DeltaX;                      {R|ckgabewert X von Punkt setzen}
      Delta.Y:=DeltaY;                      {R|ckgabewert Y von Punkt setzen}
      SnapMove:=True;                              {Funktionsergebnis setzen}
    end;
  end;
  OldPosition:=Position;   {Aktuelle Position f|r ndchsten Vergleich sichern}
end;
{---------------------------------------------------------------------------}

begin
  Gd:=Detect;
  InitGraph(Gd,Gm,'c:\tp\system');           {Change to your BGI driver path}
  CursorOn;
  Rect.Init(0,0,50,50);
  IsSnap:=True;
  Snap:=25;                                {Change this value for other snap}
  MouseSnap.Init(Snap);
  Rect.Draw(White);
  repeat
    if LeftButton then                      {Press LeftButton to toggle snap}
    begin
      repeat until not LeftButton;
      IsSnap:=IsSnap xor True;
      if IsSnap then MouseSnap.Init(Snap) else MouseSnap.Init(1);
    end;
    if MouseSnap.SnapMove(P) then
    begin
      Rect.Draw(Black);
      Rect.Move(P.X,P.Y);
      Rect.Draw(White);
    end;
  until RightButton;                      {Press RightButton to quit program}
  CloseGraph;
end.

