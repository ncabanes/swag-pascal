(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0189.PAS
  Description: Space Lords 7 Video Game - Great Graphic
  Author: SCOTT TUNSTALL
  Date: 08-30-96  09:36
*)

{
SPACE LORDS 7 - VGA PC VERSION.
(C) 1995 Scott Tunstall & K. Sillett (BBC Maestro)

3 PLAYER ACTION !!!

Apologies for the swearing in some of my posts Gayle. To make up
for it, I've given ya a QUALITY video game. Seriously!
It certainly looks smart... don't ask me where I got the graphics
from tho' - some folk may complain! ;)

BEFORE YOU RUN THIS PLEASE USE THE XX3402 DECODER ON PART 2 OF
THE SPACE LORDS POST TO CREATE THE FILE IMAGES.ZIP. THEN UNZIP
THE IMAGES FILE INTO WHERE YOUR SPACE LORDS GAME EXECUTABLE FILE
(LORDS.EXE) WILL BE.

THEN, RUN THE EXE AND HAVE FUN! :)

New game requirements:
----------------------
500K of base memory
MCGA/VGA graphics adaptor supporting 320 x 200 x 256 mode
386 SX 25 processor (at worst) - will run VERY SLOWLY ON THIS MACHINE
(Ok on a 486 DX-2)

(Of course, if you are Dave "Stallion Man" Norrie you can use a
8Mb RAM Pentium f***ing 90 - lucky c***!! I'll put one over him
and buy an IBMRISC 400Mhz baby! (No games for it tho' - I'll change
that !)


Most importantly a 101 key keyboard is essential.


PLAYER #     UP      ROTATE LEFT    ROTATE RIGHT     FIRE
-----------------------------------------------------------------
1            '1'     'A'            'X'              'LEFT SHIFT'
2            'O'     ';'            '@'              '>'
3            'Home'  'Keypad 9'     'Keypad -'       'Keypad 3'
4            JOYSTICK 1      (Not implemented)
5            JOYSTICK 2      (Not implemented)

6..100 require to be LapLinked (Aye right then)

}




{$DEFINE FULLDISPLAY}   { <-- $UNDEF if using a slow 386 }
{$DEFINE BUMPING}       { <-- Player to player bumping }
{$DEFINE BONUSES}       { <-- Want Any bonuses on screen }
{$DEFINE MESSAGES}      { <-- This may be silly of you to $UNDEF. }


{$a+,b-,s-,e+,n+,r-,v-,g+}


Program SPACE_LORDS_7;   { 7 editions already - GULP! }

Uses Dos,NEWGRAPH, NwKBDInt, Crt;

     {NEWGRAPH is in JUNE 1996 EDITION OF THE SWAG }
     {AS IS NEWKBDINT - KEYBOARD HANDLER }



Const TopBoundary = -8;          { Top of window }
      BottomBoundary = 204;
      LeftBoundary = -4;
      RightBoundary = 323;


      MaxPlayers = 3;           { Max no of players on screen at once }

{$IFDEF BONUSES}
      MaxBonuses = 6;           { Max no of bonuses on screen at once }
{$ENDIF}

      MaxAliens = 10;           { Getting busy on the screen ! }
      MaxStars  = 20;           { Number of parallax stars }


      MaxExplodeWidth = 200;    { And how far the explosion circles go }
      ShipTurnAngle = 4;        { Degrees that ships turn in }
      PointsForBumping = 500;   { Guess what these are ? }
      PointsForShooting = 100;
      DeductionForShooting = 10;


      {
      BIT FLAGS - LEAVE ALONE
      }

      Dead = 0;                    { Playerstatus defines }
      ShootAble = 1;               { This MUST stay at 1 - V. Important }
      Warping = 2;                 { This MUST stay at 2 ! }
      Exploding = 4;               { This MUST stay at 4 ! }
      Spinning = 8;                { This MUST stay at 8 ! }
      Frozen = 16;

      {
      Player Speed stuff
      }

      MaxPlayerSpeed = 4;          { This is the MAXIMUM number of
                                   pixels that a player ship jumps
                                   in 1 pass. Pretty fast man }
      SlowestPlayerSpeed = 1;      { The least number of pixel
                                   jumps }









      {
      Laser stuff - Alter MaxLasers if you like, leave the rest
      }

      MaxLasers = (MaxPlayers * 10)+10;  { How many lasers allocated }
      MaxPlayerLasers = 10;              { How many each player has }
      MaxLaserPower = 5;

      NumLaserTypes = 3;           { The current # of laser types }
      LaserFree = 0;
      NormalLaser = 1;             { Lasers stop at edge of screen }
      LaserWraps = 2;              { Lasers can go off one side &
                                   reappear on the other }
      LaserRebound = 3;            { Makes lasers bounce off wall }

      PlayerLaserSize = 4;
      AlienLaserSize = 4;








      {
      Bonus stuff - don't change the values of the constants
      otherwise some strange effects will occur, OK? If you want
      to add some more stuff you'll have to update BonusString
      too..
      }

{$IFDEF BONUSES}

      NumberOfBonuses = 13;


{     BONUS NAME                POINTS FOR COLLECTING IT
      ----------                ------------------------
}

      SlowDownBonus = 1;        SlowDownBonusPointsValue = 100;
      EnergyBonus = 2;          EnergyBonusPointsValue = 200;
      FreezeBonus = 3;          FreezeBonusPointsValue = 300;
      ReverseBonus = 4;         ReverseBonusPointsValue = 400;
      DisableBonus = 5;         DisableBonusPointsValue = 500;
      InvulnerabilityBonus = 6; InvulnerabilityBonusPointsValue = 600;
      AssFiringBonus = 7;      AssFiringBonusPointsValue = 700;
      NormalBonus = 8;          NormalBonusPointsValue = 50;
      ToodysBonus = 9;          ToodysBonusPointsValue = 2000;
      LaserBonus = 10;          LaserBonusPointsValue = 200;
      WarpBonus =  11;          WarpBonusPointsValue = 1000;
      BounceLaserBonus = 12;    BounceLaserBonusPointsValue = 200;

      UnknownBonus = 13;


{$ENDIF}
      MaxInvulnerableTime = 200;

{$IFDEF BONUSES}
      MaxFrozenTime = 100;
      MaxFireHaltTime = 100;
      MaxKeyReverseTime = 200;
      MaxSlowedDownTime = 100;
      MaxBanzaiTime = 100;
      MaxDisableTime = 100;

{$ENDIF}

      EnergyIncrement = 5;
      SlowDownIncrement = 10;
      NormalMessageTime = 80;

      PacDelayConst = 4;


{
And now to define ALL aspects of a player's ship
}

Type PlayerStruct = Record

     PlayerStatus: byte;           { 0 = Dead, 1 = ShootAble, 2= Exploding,
                                   4 = Spinning, 8 = Frozen }
     FrozenTime: word;

     ExplodeWidth:byte;

     PlayerColour: byte;

     PlayerAngle: integer;
     SpinAngle: integer;

     SpinSpeed: byte;
     SpinCount: byte;


     PlayerX: integer;

     PlayerY: integer;

     PlayerWraps : boolean;

     PlayerMessage: String[38];
     MessageTime: byte;

     BanzaiTime: word;

     {
     Speed stuff
     }

     PlayerSpeed: byte;            { Exceed 3 and ship movement is
                                      quite jerky. }
     NormalPlayerSpeed: byte;
     SlowedDownTime: word;
     PlayerWait: byte;
     WaitCount: byte;
     MaxWaitCount: byte;

     Thrusting: boolean;


     PlayerEnergy: integer;
     MaxPlayerEnergy: integer;
     RechargeTime: byte;
     RechargeLatch: byte;
     RechargeDeduction: byte;

     KeyReverseTime: byte;

     AutoFire: boolean;

     DisableTime: byte;

     AssFiring : boolean;

     FireKeyReleased: boolean;
     FireDelay:byte;
     FireLatch:byte;


     LaserDeduction: byte;


     CurrentLaserType: byte;
     CurrentLaserPower: byte;
     CurrentLaserSpeed: byte;
     CurrentMaxLaserTravel: byte;

     LaserHurts: boolean;
     EnemyLaserHurts: boolean;
     Invulnerable: boolean;
     InvulnerableTime: word;

     PlayerScore: LongInt;

End;


Type Laser = Record
     LaserType: byte;
     FiredBy: byte;
     LaserAngle: integer;
     LaserX: integer;
     LaserY: integer;
     LaserColour: byte;
     LaserSize: byte;
     LaserSpeed: byte;

     LaserTravel: byte;
     MaxLaserTravel: byte;
     LaserPower: byte;
End;


{$IFDEF BONUSES}

{
Yeah! Some Pick - Ups for the players!
}


Type Bonus = Record
     BonusType: byte;
     BonusX: integer;                { Position on screen }
     BonusY: integer;
     BonusXIncrement: integer;
     BonusYIncrement: integer;
     End;



Type BonusArray = Array[1..MaxBonuses] of Bonus;
{$ENDIF}


Type PlayerArray = Array[1..MaxPlayers] of PlayerStruct;
Type LaserArray = Array[1..MaxLasers] of Laser;

Var

    PlayerRec: PlayerArray;
    LaserRec: LaserArray;
    TempLaser: Laser;

{$IFDEF BONUSES}
    BonusRec: BonusArray;
{$ENDIF}


    OldKbdInt: procedure;

    PlanetSeg,PlanetOfs: word;
    titleBitmapSeg,titleBitmapOfs: word;
    EmporerSeg,EmporerOfs: word;
    ScratchSeg,ScratchOfs: word;

    FontSegment, FontOffset: word;
    FontHeight: byte;

    PacPointer: Array[0..7] of Pointer;
    AlienPointer: Pointer;
    AlienShapeSize: word;

    DestroyerPalette: PaletteType;
    titleBitmapPalette: PaletteType;
    EmporerPalette: PaletteType;


    TempKey: char;

    ColourTable: array[1..MaxPlayers] of byte;
    QCos, QSin : array[0..359] of real;

    PlayersOn: byte;
    PlayersAlive: byte;                         { How many players are
                                                  left on the screen -
                                                  initially, PlayersAlive
                                                  equals PlayersOn but
                                                  as people are killed it
                                                  decrements }
    LasersFired: byte;
    LastLaserIndex: byte;
    AlienCount: byte;



{$IFDEF BONUSES}
    BonusesOnScreen: byte;
    BonusString: string[NumberOfBonuses];

{$ENDIF}

    Message: String[40];


Procedure Warp(PlayerNo:byte); Forward;


Procedure LoadGraphics;
Var Count: byte;
Begin
     TextMode(CO80);
     TextBackGround(Black);
     ClrScr;

     TextBackGround(Red);
     For Count:=0 to 79 do Write(Chr(32));

     TextColor(White);
     Gotoxy(1,1);
     Writeln('SPACE LORDS 7.1.2.3.5.2.9.½  (C) 1994,5 Scott Tunstall.  Lauder College Version');
     Writeln;
     Writeln;
     TextBackGround(Black);
     TextColor(LightGray);
     Writeln('Beginning LORDS_INIT Refresh daemon.. OK.');
     Writeln;
     For Count:=0 to 79 do write('=');
     Writeln('THIS VERSION IS PUBLIC DOMAIN AND MAY BE SWAPPED AND COPIED FREELY');
     Writeln('YOU MAY NOT DISASSEMBLE, REPLICATE OR ALTER THE PROGRAM CODE IN ANY');
     Writeln('WAY UNLESS YOU CONTACT THE AUTHOR.');
     For Count:=0 to 79 do write('=');

     Writeln('Please wait.. Loading in PCX files from hard disk..');
     Writeln;

     Bitmap(PlanetSeg, PlanetOfs);
     Bitmap(titleBitmapSeg, titleBitmapOfs);
     Bitmap(EmporerSeg, EmporerOfs);
     Bitmap(ScratchSeg, ScratchOfs);


     Write('DESTROYR.PCX .. ');

     SetSourceBitmapAddr(PlanetSeg, PlanetOfs);
     LoadPCX('DESTROYR.PCX',DestroyerPalette);

     Writeln('loaded.'); Write('BACK.PCX .. ');

     SetSourceBitmapAddr(titleBitmapSeg, titleBitmapOfs);
     LoadPCX('BACK.PCX',titleBitmapPalette);

     Writeln('loaded.'); Write('EMPORER.PCX .. ');

     SetSourceBitmapAddr(EmporerSeg, EmporerOfs);
     LoadPCX('EMPORER.PCX',EmporerPalette);

     Writeln('loaded.');


End;

{
Sorry I had to get rid of the Pascal but I was pissed off
with it's slothfulness !
}


Procedure BitMapCopy(TheSegment, TheOffset:word);
Begin
     Asm
     MOV AX,DS
     MOV ES,ScratchSeg
     MOV DI,ScratchOfs
     MOV SI,TheOffset
     MOV DS,TheSegment

     MOV CX,16000
     REPZ
     DB $66
     MOVSW
     MOV DS,AX
     End;
     SetSourceBitmapAddr(ScratchSeg,ScratchOfs);
     SetDestinationBitmapAddr($a000,0);
End;

{========================================================

This routine could possibly be slowing the system down
quite a lot as it calls the video interrupt which as most
codies know is as slow as a snail on mogadon. Hmm.

I will update this in 1998 when I've got me postgraduate
but right now you'll have to make do with this s**t OK?
}


Procedure SelectFont(FontNo: byte);
Var TempWidth: byte;
Begin
     UseFont(FontNo);
     GetCurrentFontAddr(FontSegment,FontOffset);
     GetCurrentFontSize(TempWidth,FontHeight);
End;


{====================

Display coloured text

}


Procedure TextXY(x,y:integer;txt:string);
Begin
     SetColour(254);
     OutTextXY(x+1,y+1,txt);
     SetColour(255);
     OutTextXY(x,y,txt);
End;


{===============================================================

This Bresenham circle routine isn't mine. I nicked it from the
SWAG (the rest of the stuff is 100% mine though) and to be quite
honest I couldn't be bothered converting it to assembler, so if
any gurus out there (like me!) want to then they can convert.

              *** You'd be sad tho' !! ***
}

Procedure Circle(X, Y : integer; Radius:byte);
Var
   Xs, Ys    : Integer;
   Da, Db, S : Integer;
   TX, TR    : word;
begin
     if (Radius = 0) then
          Exit;

     if (Radius = 1) then
     begin
          PutPixel(X, Y, GetColour);
          Exit;
     end;

     Xs := 0;
     Ys := Radius;

     Repeat
           TX:=Sqr(Xs+1);
           TR:=Sqr(Radius);
           Da := TX + Sqr(Ys) - TR;
           Db := TX + Sqr(Ys - 1) - TR;
           S  := Da + Db;

           Inc(Xs);
           if (S > 0) then
                Dec(Ys);

           PutPixel(X+Xs-1, Y-Ys+1, GetColour);
           PutPixel(X-Xs+1, Y-Ys+1, GetColour);
           PutPixel(X+Ys-1, Y-Xs+1, GetColour);
           PutPixel(X-Ys+1, Y-Xs+1, GetColour);
           PutPixel(X+Xs-1, Y+Ys-1, GetColour);
           PutPixel(X-Xs+1, Y+Ys-1, GetColour);
           PutPixel(X+Ys-1, Y+Xs-1, GetColour);
           PutPixel(X-Ys+1, Y+Xs-1, GetColour);
     Until (Xs >= Ys);
end;

Procedure InitPlayers;
Var count: byte;
Begin
     For count:= 1 to MaxPlayers do
         With PlayerRec[count] do
              Begin
              Warp(Count);

              PlayerMessage:='Player '+chr(48+Count)+' ready !';
              MessageTime:=NormalMessageTime;

              ExplodeWidth:=0;
              PlayerColour:=ColourTable[Count];

              PlayerWraps:=True;

              PlayerSpeed:=4;
              NormalPlayerSpeed:=PlayerSpeed;

              SlowedDownTime:=0;
              PlayerWait:=1;

              WaitCount:=15;
              MaxWaitCount:=WaitCount;

              Thrusting:=False;

              InvulnerableTime:=MaxInvulnerableTime; { So if you warp into Paccy you
                                                       can still get away }
              BanzaiTime:=0;

              PlayerEnergy:=20;
              MaxPlayerEnergy:=PlayerEnergy;
              RechargeTime:=40;
              RechargeLatch:=RechargeTime;
              RechargeDeduction:=10;

              KeyReverseTime:=0;

              AssFiring:=False;
              DisableTime:=0;

              AutoFire:=True;
              FireKeyReleased:=true;
              FireDelay:=3;
              FireLatch:=FireDelay;

              CurrentLaserType:=NormalLaser;
              CurrentLaserPower:=1;
              CurrentLaserSpeed:=8;
              CurrentMaxLaserTravel:=80;

              LaserDeduction:=1;

              LaserHurts:=False;
              EnemyLaserHurts:=True;

              PlayerScore:=0;
         End;
End;


{
Flush laser array
}

Procedure InitLasers;
Var Count: byte;
Begin
     LasersFired:=0;
     LastLaserIndex:=1;
     For Count:=1 to MaxLasers do
     With LaserRec[Count] do
         LaserType:=LaserFree;
End;

{$IFDEF BONUSES}
Procedure InitBonuses;
Var Count: byte;
Begin
     BonusesOnScreen:=0;
     BonusString:='SEFRDIANTLWB?';      { Not explaining what this is for }

     For Count:= 1 to MaxBonuses do
         With BonusRec[Count] do
         Begin
              BonusType:=0;
         End;
End;
{$ENDIF}

Procedure SetUpPlayers;
var Count: word;
    keyhit: char;
    PromptLatch: byte;
    PromptTime: byte;
    TextRefreshCount: byte;

Begin
     For Count:=0 to 359 do
         Begin
         QCos[Count]:=Cos(Count * (PI/180));
         QSin[Count]:=Sin(Count * (PI/180));
     end;

     { Assign player colours }

     For Count:=1 to MaxPlayers do
         ColourTable[Count]:=256-Count;

     Randomize;

     PlayersOn:=MaxPlayers;
     PlayersAlive:=PlayersOn;

     InitPlayers;
     InitLasers;
{$IFDEF BONUSES}
     InitBonuses;
{$ENDIF}


     {
     Now draw the title screen
     }

     PromptLatch:=50;
     PromptTime:=PromptLatch;
     TextRefreshCount:=0;

     SetPalette(254, 63,0,0);
     SetPalette(255, 63,63,0);

     Repeat
           BitMapCopy(titleBitmapSeg,titleBitmapOfs);

           SelectFont(6);

           TextXY(92,8,'SPACE LORDS 7½');

           SelectFont(1);
           TextXY(32,70, 'PROGRAMMING BY : Scott Tunstall');

           if (TextRefreshCount < 4) Then
              Begin
              TextXY(32,96,  'VECTOR GFX  BY  : Scott Tunstall');
              TextXY(32,112, 'PAC MAN     BY  : Namco (tm)');
              TextXY(32,128, 'DIRTY WOMEN AT  : MarketGait');
              end
           else
              Begin
              SelectFont(Font8x16);
              TextXY(48,96,  'SO RONNY NOW DO YOU BELIEVE');
              TextXY(48,114, 'THAT I WROTE THIS PROGRAM ?');
              SelectFont(Int43Font);
              End;


           Delay(1);
           Dec(PromptTime);
           If PromptTime=0 Then
              Begin
              PromptTime:=50;
              Inc(TextRefreshCount);
              Asm
              AND BYTE PTR TextRefreshCount, $7
              End;
           End;

           If (PromptTime > 25) Then
              Begin
              TextXY(32,162,'PRESS SPACE TO BEGIN THE GAME !');
           End;

           SelectFont(Font8x16);
           TextXY(32,180,'Program  (C) 1995 Scott Tunstall.');


           CopySourceBitmap ;

           if keypressed then
              keyhit:=readkey;

     Until keyhit = ' ';

End;

Procedure DrawPlayerStuff;
var PlayerCount: byte;
    OriginX: integer;
    OriginY: integer;
    Angle: integer;
    LineCount: byte;
    CircCount: byte;
    TempString: string[6];

Begin
     UseFont(1);
     For PlayerCount:=1 to PlayersOn do
         With PlayerRec[PlayerCount] do
              Begin

              Str(PlayerScore,TempString);
              SetColour(PlayerColour);
              OutTextXY(0,192- PlayerCount SHL 3,TempString);

              If MessageTime <>0 Then
                 Begin
                 Dec(MessageTime);

{$IFDEF FULLDISPLAY}
                 TextXY(56,192-PlayerCount SHL 3,PlayerMessage);
                 SetColour(PlayerColour);
{$ELSE}
                 OutTextXY(56,192-PlayerCount SHL 3,PlayerMessage);
{$ENDIF}

              End;

              {
              Time to draw the ship. I am quite pleased that this
              routine is fairly fast.
              }



              If (PlayerStatus And ShootAble)=ShootAble  Then
                 Begin
                 If (InvulnerableTime >10) Or
                    (InvulnerableTime MOD 2 = 1) Then
                    Circle(PlayerX,PlayerY,12);

                 If (BanzaiTime = 0) Or ((BanzaiTime MOD 8 )>3 ) Then
                    Begin
                    Angle:=PlayerAngle;

                    {
                    Nose of ship is 8 pixels away from
                    the start area at degree <Angle>
                    }

                    OriginX:=PlayerX+ Round(QCos[Angle] * 8);
                    OriginY:=PlayerY+ Round(QSin[Angle] * 8);

                    MoveTo(OriginX,OriginY);

                    Asm
                    MOV AX,Angle
                    ADD AX,135
                    CMP AX,360
                    JB @ThisAngleIsOK1
                    SUB AX,360
   @ThisAngleIsOK1:
                    MOV Angle,AX
                    End;

                    LineTo(PlayerX+ Round(QCos[Angle] * 8),
                    PlayerY+ Round(QSin[Angle] * 8));
                    ;

                    Asm
                    MOV AX,Angle
                    ADD AX,45
                    CMP AX,360
                    JB @ThisAngleIsOK2
                    SUB AX,360
   @ThisAngleIsOK2:
                    MOV Angle,AX
                    End;

                    LineTo(PlayerX+Round(QCos[Angle] * 2),
                    PlayerY+Round(QSin[Angle] * 2));

                    Asm
                    MOV AX,Angle
                    ADD AX,45
                    CMP AX,360
                    JB @ThisAngleIsOK3
                    SUB AX,360
   @ThisAngleIsOK3:
                    MOV Angle,AX
                    End;

                    LineTo(PlayerX+Round(QCos[Angle] * 8),
                    PlayerY+Round(QSin[Angle] * 8));

                    LineTo(OriginX,OriginY);




   {$IFDEF FULLDISPLAY}

                    If Thrusting And (Random(2)=1) Then
                       Begin
                       SetColour(Random(255));


                       Angle:=PlayerAngle;

                       Asm
                       MOV AX,Angle  { I've tried the other way ! }
                       ADD AX,150
                       CMP AX,360
                       JB @ThisAngleIsOK4
                       SUB AX,360
   @ThisAngleIsOK4:
                       MOV Angle,AX
                       End;


                       MoveTo(PlayerX+Round(QCos[Angle]*5),
                       PlayerY+Round(QSin[Angle]*5));

                       Asm
                       MOV AX,Angle
                       ADD AX,30
                       CMP AX,360
                       JB @ThisAngleIsOK5
                       SUB AX,360
   @ThisAngleIsOK5:
                       MOV Angle,AX
                       End;


                       LineTo(PlayerX+Round(QCos[Angle]*8),
                       PlayerY+Round(QSin[Angle]*8));

                       {Inc(Angle,30);

                       If Angle > 360 Then
                          Dec(Angle,360);}

                       Asm
                       MOV AX,Angle
                       ADD AX,30
                       CMP AX,360
                       JB @ThisAngleIsOK6
                       SUB AX,360
   @ThisAngleIsOK6:
                       MOV Angle,AX

                       End;

                       LineTo(PlayerX+Round(QCos[Angle]*5),PlayerY+Round(QSin[Angle]*5));

                    End;

   {$ENDIF}
                    SetColour(PlayerColour);

                    OriginX:=PlayerX-12;
                    OriginY:=PlayerY+12;

                    Line(OriginX,OriginY,OriginX + PlayerEnergy,OriginY);
                    End;
                 End
              Else
                  If (PlayerStatus = Exploding) Or (PlayerStatus = Warping) Then
                     Begin
                     For circcount:=0 to 40 do
                         PutPixel(PlayerX+Round(QCos[circcount SHL 3]*ExplodeWidth),
                         PlayerY+Round(QSin[circcount SHL 3]*ExplodeWidth),PlayerColour);

                  End;
         End;
End;

{
Put the lasers on the screen.
}


Procedure DrawLasers;
var LaserCount: byte;
Begin
     If LasersFired <>0 Then
     For LaserCount:=1 to MaxLasers do
         If LaserRec[LaserCount].LaserType <> LaserFree Then
         With LaserRec[LaserCount] do
         Begin
         SetColour(LaserColour);
         MoveTo(LaserX,LaserY);
         LineRel(Round(QCos[LaserAngle]*LaserSize),
         Round(QSin[LaserAngle]*LaserSize));
         End;

End;


{$IFDEF BONUSES}

Procedure DrawBonuses;
var BonusCount: byte;

Begin
     SetColour(255);
     If BonusesOnScreen <>0 Then
        For BonusCount:=1 to MaxBonuses do
            With BonusRec[BonusCount] do
            If BonusType <>0 Then
               Begin
               Circle(BonusX+4,BonusY+4,12);

{$IFDEF FULLDISPLAY}
               UseFont(Font8x14);
               TextXY(BonusX,BonusY,BonusString[BonusType]);
{$ELSE}
               OutTextXY(BonusX,BonusY,BonusString[BonusType]);
{$ENDIF}
               End;

End;

{$ENDIF}

Procedure CheckBounds(Var XPos,YPos:integer;
                          ObjectWraps: boolean;
                          Var DidWrap:boolean); Assembler;

Asm
   CMP ObjectWraps,1

   JNE @ObjectDoesNotWrap

   MOV SI,RightBoundary
   MOV DI,LeftBoundary
   MOV CX,BottomBoundary
   MOV DX,TopBoundary
   JMP @LetsDoThisshit


@ObjectDoesNotWrap:
   MOV SI,LeftBoundary
   MOV DI,RightBoundary
   MOV CX,TopBoundary
   MOV DX,BottomBoundary

@LetsDoThisshit:
     XOR AL,AL

     LES BX,XPos
     MOV BX,[ES:BX]

     CMP BX,LeftBoundary
     JG @XPosMoreThanLeft

     LES DI,XPos
     MOV [ES:DI],SI

     INC AL
     JMP @NowTestVertical


@XPosMoreThanLeft:
     CMP BX,RightBoundary
     JL @NowTestVertical

     LES SI,Xpos
     MOV [ES:SI],DI

     INC AL




@NowTestVertical:
     LES BX,Ypos
     MOV BX,[ES:BX]

     CMP BX,TopBoundary
     JG @YPosMoreThanTop

     LES DI,Ypos
     MOV [ES:DI],CX
     MOV AL,1
     JMP @Finito

@YPosMoreThanTop:
     CMP BX,BottomBoundary
     JL @Finito

     LES DI,YPos
     MOV [ES:DI],DX

     MOV AL,1

@Finito:
     LES DI,DidWrap
     MOV [ES:DI],AL
End;


Procedure AddLaser(LaserToAdd: Laser);
Var VacantLaserNumber: byte;
    LaserCount: byte;

Begin
     If LaserRec[LastLaserIndex].LaserType = LaserFree Then
        VacantLaserNumber:=LastLaserIndex
     Else
         Begin
         VacantLaserNumber:=$FF;
         For LaserCount:=1 to MaxLasers do
             Begin
             If LaserRec[LaserCount].LaserType = LaserFree Then
                Begin
                VacantLaserNumber:=LaserCount;
                LaserCount:=MaxLasers;
             End;
         End;
     End;

     If VacantLaserNumber <> $FF Then
        Begin
        Inc(LasersFired);
        LaserRec[VacantLaserNumber]:=LaserToAdd;
     End;
End;


Procedure DoFireRoutine(ShipNo:byte);
Var TAngle: word;
Begin
     If LasersFired <> MaxLasers Then
        With PlayerRec[ShipNo] do
        Begin
             TempLaser.LaserType:=CurrentLaserType;
             TempLaser.FiredBy:=ShipNo;
             If AssFiring Then
                Begin
                TempLaser.LaserX:=PlayerX-Round(QCos[PlayerAngle] * 6);
                TempLaser.LaserY:=PlayerY-Round(QSin[PlayerAngle] * 6);

                TAngle:=PlayerAngle+180;

                Asm
                MOV AX,TAngle
                CMP AX,360
                JB @NoReset
                SUB AX,360
@NoReset:
                MOV Tangle,AX
                End;

                TempLaser.LaserAngle:= TAngle;
                End
             Else
                 Begin
                 Templaser.LaserX:=PlayerX+Round(QCos[PlayerAngle] * 6);
                 Templaser.LaserY:=PlayerY+Round(QSin[PlayerAngle] * 6);
                 Templaser.LaserAngle:= PlayerAngle;
             End;

             { Make sure you know who fired the laser }

             TempLaser.LaserColour:=PlayerColour;

             TempLaser.LaserPower:=CurrentLaserPower;
             TempLaser.LaserSize:= PlayerLaserSize;
             TempLaser.LaserSpeed:=CurrentLaserSpeed;
             TempLaser.MaxLaserTravel:=CurrentMaxLaserTravel;

             AddLaser(TempLaser);

             Dec(PlayerScore,DeductionForShooting);
             If PlayerScore < 0 Then PlayerScore:=0;
        End;
End;


Procedure AlterShip(ShipNo:byte;UpKey,DownKey,LeftKey,RightKey,FireKey:boolean);
Var DiscardedVar: boolean;
    TempKey: boolean;

Begin
       With PlayerRec[ShipNo] do
            Begin

            If UpKey Then
               Begin
               Thrusting:=True;
               If WaitCount > 1 Then
                  Dec(WaitCount);
               End
            Else
                Begin
                Thrusting:=False;
                If WaitCount < MaxWaitCount Then
                   Inc(WaitCount)
                Else


                    Begin
                    Dec(RechargeTime);
                    If (RechargeTime = 0) And
                    (PlayerEnergy < MaxPlayerEnergy) And
                    (PlayerScore >= RechargeDeduction) Then

                       Begin
                       RechargeTime:=RechargeLatch;
                       Inc(PlayerEnergy);

                       Dec(PlayerScore, RechargeDeduction);
                       End;
                    End;
                End;


            If KeyReverseTime <>0 Then
               Begin
               TempKey:=LeftKey;
               LeftKey:=RightKey;
               RightKey:=TempKey;
            End;


            If LeftKey Then
            Begin
                 Dec(PlayerAngle,ShipTurnAngle);
                 If PlayerAngle <1 Then
                    Inc(PlayerAngle,360);
            End;


            If RightKey Then
            Begin
                 Inc(PlayerAngle,ShipTurnAngle);
                 If PlayerAngle > 359 Then
                    Dec(PlayerAngle,360);
            End;

            {
            Has the player held down the fire button.
            }

            If FireKey Then
               Begin
               If (DisableTime=0) Then
                  Begin
                  If AutoFire Then
                  Begin

                     If FireDelay = 0 Then
                        Begin
                        FireDelay:=FireLatch;
                        DoFireRoutine(ShipNo);
                        End
                     Else

                         Dec(FireDelay);
                  End
                  Else
                      If FireKeyReleased Then
                      Begin
                         FireKeyReleased:=False;
                         DoFireRoutine(ShipNo);
                      End;
               End;
            End
            Else

                FireKeyReleased:=True;



            If WaitCount <> MaxWaitCount Then
               Begin
               Inc(PlayerWait);
               If PlayerWait >= WaitCount Then
                  Begin
                  PlayerWait:=0;
                  Inc(PlayerX, Round(Qcos[PlayerAngle]*PlayerSpeed));
                  Inc(PlayerY, Round(QSin[PlayerAngle]*PlayerSpeed));


                  CheckBounds(PlayerX,PlayerY,PlayerWraps,DiscardedVar);
                  End;
            End;
       End;

End;

Procedure UpDatePlayersSpin(PlayerNo:byte);
Var DiscardedVar: boolean;
Begin
     With PlayerRec[PlayerNo] do
     Begin


     Inc(PlayerAngle,ShipTurnAngle SHL 3);
     If PlayerAngle > 359 Then Dec(PlayerAngle,360);


     Inc(PlayerX, Round(Qcos[SpinAngle]*SpinSpeed));
     Inc(PlayerY, Round(QSin[SpinAngle]*SpinSpeed));


     CheckBounds(PlayerX,PlayerY,PlayerWraps,DiscardedVar);
     End;
End;

{$IFNDEF BONUSES}
Procedure UpDateBonusTimer(PlayerNo:byte);
Begin
     { Shields }
     With PlayerRec[PlayerNo] do
     If InvulnerableTime <>0  Then
        Begin
        Dec(InvulnerableTime);
        If InvulnerableTime = 0 Then
           Begin
           PlayerMessage:='SHIELDS DOWN!';
           MessageTime:=NormalMessageTIme;
           EnemyLaserHurts:=True;
        End;
     End;
End;

{$ELSE}

Procedure UpdateBonusTimers(PlayerNo:byte);
Begin
     With PlayerRec[PlayerNo] do
     Begin

     { Firing }

     If DisableTime <>0 Then
        Begin
        Dec(DisableTime);
        If DisableTime = 0 Then
           Begin
           PlayerMessage:='I CAN SHOOT AGAIN!';
           MessageTime:=NormalMessageTime;
        End;
     End;

     { Slothfullness }

     If SlowedDownTime <>0 Then
     Begin
          Dec(SlowedDownTime);
          If SlowedDownTime = 0 Then
             PlayerSpeed:=NormalPlayerSpeed;
     End;

     { Key reversing, i.e. press key for left and you go right }

     If KeyReverseTime <>0 Then
        Dec(KeyReverseTime);

     { Shields }

     If InvulnerableTime <>0  Then
        Begin
        Dec(InvulnerableTime);
        If InvulnerableTime = 0 Then
           Begin
           PlayerMessage:='SHIELDS DOWN!';
           MessageTime:=NormalMessageTIme;
           EnemyLaserHurts:=True;
        End;
     End;

     { Toody's special bonus }

     If BanzaiTime <> 0 Then
        Begin
        Dec(BanzaiTime);
        If BanzaiTime = 0 Then
           Begin
           PlayerMessage:='TOODY''S POWER GONE!';
           MessageTime:=NormalMessageTime;
        End;
     End;

     End;
End;

{$ENDIF}

{
You have to check the player's status byte to determine whether
or not he's spinning, frozen, etc.
}


Procedure CheckPlayerStatusByte(PlayerNo:byte);
Begin
     With PlayerRec[PlayerNo] Do
     Begin
     {
     Now service the PlayerStatus bits
     }

     If (PlayerStatus And Frozen)=Frozen Then
        Begin
        If FrozenTime > 0 Then
           Dec(FrozenTime)
        Else
            PlayerStatus:=PlayerStatus And (255-Frozen);
     End;


     If (PlayerStatus And Spinning)=Spinning Then
        Begin

        Dec(SpinCount);
        If SpinCount <>0 Then
           UpdatePlayersSpin(PlayerNo)
        Else
            Begin

            PlayerStatus:= ShootAble;
            WaitCount:=MaxWaitCount;
            End;
        End
     Else
         If PlayerStatus = Exploding Then
            Begin

            Inc(ExplodeWidth,5);

            If ExplodeWidth >= MaxExplodeWidth Then
               Begin
               PlayerStatus:= Dead;
               Dec(PlayersAlive);
               End;
            End
         Else
             If PlayerStatus = Warping Then
                Begin
                Dec(ExplodeWidth,5);
                If ExplodeWidth <=5 Then
                   PlayerStatus:=ShootAble;
             End;

     End;
End;

{
Update the player's ships.

PlayerStatus is a combination of BIT FLAGS which indicate to the
program the current player status. Doh!

If bit 0 of PlayerStatus is set then the player is still ShootAble. (i.e. Alive)
If bit 1 of PlayerStatus is set then the player is Warping.
If bit 2 of PlayerStatus is set then the player is Exploding.
If bit 3 of PlayerStatus is set then the Player is Spinning.
If bit 4 of PlayerStatus is set the player is Frozen.

Bits 5 - 7 are undefined and should stay that way for now.
}

Procedure MoveShips;
Var PlayerCount: byte;
Begin
     For PlayerCount:=1 to PlayersOn do
         With PlayerRec[PlayerCount] do
         If (PlayerStatus = ShootAble) Then
            Begin
            Case PlayerCount Of

            1: AlterShip(1,keydown[2],keydown[15],keydown[30],keydown[45],keydown[42]);
            2: AlterShip(2,keydown[24],keydown[38],keydown[39],keydown[40],keydown[52]);
            3: AlterShip(3,keydown[71],keydown[76],keydown[73],keydown[74],keydown[81]);

            End;

{$IFNDEF BONUSES}
            UpdateBonusTimer(PlayerCount);
{$ELSE}
            UpdateBonusTimers(PlayerCount);
{$ENDIF}
            End
         Else
             CheckPlayerStatusByte(PlayerCount);
End;

{
O.K. You've got to update the lasers (and special weapons later
on, perhaps)

}

Procedure MoveLasers;
var playercount: byte;
    LaserCount: byte;
    ItWrapped: boolean;

Begin
     If LasersFired <>0 Then
        Begin
        For LaserCount:=1 to MaxLasers do
            With LaserRec[LaserCount] do
            Begin

            If LaserType<>LaserFree Then
               Begin

               Inc(LaserTravel);

               If LaserTravel < MaxLaserTravel Then
                  Begin

                  Inc(LaserX, Round(Qcos[LaserAngle]*LaserSpeed));
                  Inc(LaserY, Round(QSin[LaserAngle]*LaserSpeed));


                  CheckBounds(LaserX,LaserY, LaserType = LaserWraps,ItWrapped);


                  If ItWrapped Then
                     Begin
                     Case LaserType of
                     NormalLaser:   Begin
                                    LaserType:=LaserFree;
                                    LastLaserIndex:=LaserCount;
                                    Dec(LasersFired);
                                    End;

                     LaserRebound:  LaserAngle:=Random(359);
                     End;
                     End;
                  End
               Else

                   Begin
                   LaserType:=LaserFree;
                   Dec(LasersFired);



                   LastLaserIndex:=LaserCount;

                   End;
               End;
            End;
        End;
End;

{$IFDEF BONUSES}


{
The Bonuses are not player controlled (of course) so therefore
the MoveBonuses routine should initiate some bonuses as well
as move them.

How will the CPU know when to initiate bonuses? Well as you
know, it can't so It'll have to be a purely random thingie.
}

Procedure MoveBonuses;
Var BonusCount: byte;
    SearchCount: byte;
    BonusDidWrap: boolean;

Begin
     If BonusesOnScreen <>0 Then
        For BonusCount:=1 to MaxBonuses do
        With BonusRec[BonusCount] do
             If BonusType <>0 Then
             Begin
             Inc(BonusX,BonusXIncrement);
             Inc(BonusY,BonusYIncrement);
             CheckBounds(BonusX,BonusY,true,BonusDidWrap);

             End;

     {
     Of course, some bonuses just have to be initialised as
     well !
     }

     If (BonusesOnScreen <= MaxBonuses) And (Random(80)=40) Then
        Begin
        SearchCount:=1;
        Repeat
              With BonusRec[SearchCount] do
              If BonusType = 0 Then
                   Begin
                   Inc(BonusesOnScreen);

                   BonusType:=1+(Random(NumberOfBonuses));

                   BonusX:=Random(319);

                   Case Random(3) of
                   0..1: BonusY:=-1;
                   2..3: BonusY:=200;
                   End;

                   Case Random(3) of
                   0..1: BonusXIncrement:=-1;
                   2..3: BonusXIncrement:=1;
                   End;

                   Case Random(3) of
                   0..1: BonusYIncrement:=-1;
                   2..3: BonusYIncrement:=1;
                   End;

                   SearchCount:=MaxBonuses;
              End;

        Inc(SearchCount);

        Until SearchCount > MaxBonuses;
     End;

End;

{$ENDIF}










Function Collision(X1,Y1,X2,Y2:integer;DistX,DistY:word): boolean; {Assembler;}
Begin
     Collision:=(Abs(X2-X1) < DistX) And (Abs(Y2-Y1) < DistY)
End;

{===================================================================

Guess what this routine does ?

}


Procedure UpdatePlayerScore(PlayerNo: byte; HowManyPoints: integer);
Begin
     With PlayerRec[PlayerNo] do
     Begin
     Inc(PlayerScore,HowManyPoints);
     If PlayerScore > $7FFFFFFF Then
        PlayerScore := $7FFFFFFF;
     End;
End;

{=====================================================

I'm gonna have to optimize this one day.. For now tho'
I'll leave it as it is so that the B.Sc chaps can suss
what's happening..
}

Procedure DoPlayerToLaser;
Var PlayerCount: byte;
    LaserCount: byte;
    Object1X: integer;
    Object2X: integer;
    Object1Y: integer;
    Object2Y: integer;

    TempLaserPower: byte;
    PersonWhoShot: byte;

Begin
     If LasersFired <>0 Then
        For PlayerCount:=1 to PlayersOn do
            With PlayerRec[PlayerCount] do
            If ((PlayerStatus AND Shootable)<>0) Then
               Begin
               Object2X:=PlayerX;
               Object2Y:=PlayerY;


               For LaserCount:=1 to MaxLasers do
               If (LaserRec[LaserCount].LaserType <> LaserFree) Then
                  Begin
                  With LaserRec[LaserCount] do
                       Begin
                       Object1X:=LaserX;
                       Object1Y:=LaserY;
                  End;

                  If Collision( Object1X,Object1Y,
                                Object2X,Object2Y,8,8) Then
                     Begin
                     PersonWhoShot:=LaserRec[LaserCount].FiredBy;

                     With PlayerRec[PersonWhoShot] do
                          Begin
                          Inc(PlayerScore,PointsForShooting);
                          If Playerscore > $7FFFFF Then
                             PlayerScore:= $7fffff;
                     End;

                     {
                     Player has been hit so make the missile
                     whack into the ships side and disappear
                     }


                     With PlayerRec[PlayerCount] do
                          If (InvulnerableTime <>0) Then
                             LaserRec[LaserCount].LaserAngle:=Random(359)
                          Else
                              Begin
                              Dec(LasersFired);
                              LaserRec[LaserCount].LaserType:=LaserFree;
                              TempLaserPower:=LaserRec[LaserCount].LaserPower;

                              If LaserRec[LaserCount].Firedby <> PlayerCount Then
                                 Begin
                                 Dec(PlayerEnergy,TempLaserPower);
                                 If PlayerEnergy <= 0 Then
                                    Begin
                                    PlayerStatus:=Exploding;
                                    ExplodeWidth:=0;
                                 End;
                              End;
                          End;
                     End;
                 End;
     End;
End;

{==========================================================

Guess what this does ?

}

Procedure SpinPlayer( PlayerBumped, PlayerWhoBumped: byte);
Var SpeedVar: byte;
    Ratio: byte;

begin
     With PlayerRec[PlayerBumped] do
        Begin
        PlayerStatus:=PlayerStatus OR Spinning;

        SpeedVar := PlayerRec[PlayerWhoBumped].WaitCount;
        Ratio    := PlayerRec[PlayerWhoBumped].MaxWaitCount - SpeedVar;

        WaitCount:=SpeedVar;

        SpinAngle:=PlayerRec[PlayerWhoBumped].PlayerAngle;
        SpinSpeed:= (Ratio SHR 2)+4;
        SpinCount:= (Ratio SHL 1)+4;

        UpDatePlayersSpin(PlayerBumped);
     End
End;

{

Check if two players did bump
}


{$IFDEF BUMPING }


Procedure CheckBump(PlayerCount1, PlayerCount2 : byte);
var
    PlayerSpeed1: byte;
    PlayerSpeed2: byte;

Begin

     If (PlayerRec[PlayerCount1].PlayerStatus = Exploding)
     Or (PlayerRec[PlayerCount2].PlayerStatus = Exploding) Then Exit;


     If (PlayerRec[PlayerCount1].BanzaiTime <>0) And
     (PlayerRec[PlayerCount2].InvulnerableTime = 0) Then
        With PlayerRec[PlayerCount2] do
           Begin
           PlayerStatus:=Exploding;
           ExplodeWidth:=0;
           Message:='AARGH etc. etc. !!';
           MessageTime:=NormalMessageTime;
           End
        Else
            Begin
            PlayerSpeed1:= PlayerRec[PlayerCount1].WaitCount;
            PlayerSpeed2:= PlayerRec[PlayerCount2].WaitCount;

            If (PlayerSpeed2 <= PlayerSpeed1) Then
               SpinPlayer(PlayerCount1,PlayerCount2)
            Else
                UpdatePlayerScore(PlayerCount1,PointsForBumping);
            End;
End;



{$ENDIF}

{$IFDEF BUMPING}

Procedure DoPlayerToPlayer;
Var PlayerCount1: byte;
    PlayerCount2: byte;
    Object1X: integer;
    Object2X: integer;
    Object1Y: integer;
    Object2Y: integer;


Begin
     For PlayerCount1:=1 to PlayersOn do
         If (PlayerRec[PlayerCount1].PlayerStatus AND Shootable =
         ShootAble) Then
            Begin
            With PlayerRec[PlayerCount1] do
                 Begin
                 Object1X:=PlayerX;
                 Object1Y:=PlayerY;
            End;



            {
            Check if the two ships have bumped into each other.
            Not too keen on what I wrote for this part but it works.
            As I said when me B.Sc is finished this part will be
            upgraded.
            }


            For PlayerCount2:=1 to PlayersOn do
                If (PlayerRec[PlayerCount2].PlayerStatus And
                Shootable = Shootable) And
                   (PlayerCount1 <> PlayerCount2) Then
                   Begin
                   {
                   Check if a collision has occurred.
                   }

                   With PlayerRec[PlayerCount2] do
                        Begin
                        Object2X:=PlayerX;
                        Object2Y:=PlayerY;
                   End;

                   {
                   Bumping?
                   }

                   If Collision(Object1X,Object1Y,Object2X,Object2Y,12,12)
                   Then
                      Begin
                      CheckBump(PlayerCount1, PlayerCount2);
                      CheckBump(PlayerCount2, PlayerCount1);
                   End;
                End;
         End;
End;

{$ENDIF}

Procedure Warp(PlayerNo:byte);
Begin
     With PlayerRec[PlayerNo] do
     Begin
          PlayerStatus:=Warping;
          ExplodeWidth:=MaxExplodeWidth;
          PlayerAngle:= Random(359);
          PlayerX:=Random(319);
          PlayerY:=Random(199);
     End;
End;

{$IFDEF BONUSES}

Procedure DoPlayerToBonuses;
Var PlayerCount: byte;
    BonusCount: byte;
    OtherCount: byte;
    Object1X: integer;
    Object2X: integer;
    Object1Y: integer;
    Object2Y: integer;




Begin
     For PlayerCount:=1 to PlayersOn do
         If (PlayerRec[PlayerCount].PlayerStatus And Shootable) = Shootable
            Then Begin

            With PlayerRec[PlayerCount] do
            Begin
                 Object1X:=PlayerX;
                 Object1Y:=PlayerY;
            End;

            For BonusCount:=1 to MaxBonuses do

                If (BonusRec[BonusCount].BonusType <>0 ) Then
                   Begin

                   With BonusRec[BonusCount] do
                        Begin
                        Object2X:=BonusX;
                        Object2Y:=BonusY;
                   End;


                   If collision( Object1X,Object1Y,
                                 Object2X,Object2Y,12,12) Then

                   With BonusRec[BonusCount] do
                   Begin

                        If BonusType = UnknownBonus Then
                           BonusType:= Random(NumberOfBonuses-2)+1;





                        Case BonusType Of
                        SlowDownBonus: begin
                                       With PlayerRec[PlayerCount] do
                                            Begin
                                            Inc(PlayerScore,SlowDownBonusPointsValue);
{$IFDEF MESSAGES}
                                            PlayerMessage:='PICKED UP A SLOWDOWN BONUS !';
                                            MessageTime:=NormalMessageTime;
{$ENDIF}
                                        End;

                                        For OtherCount:=1 to PlayersOn do
                                        If OtherCount <> PlayerCount Then
                                            With PlayerRec[OtherCount] do
                                                 Begin
                                                 If PlayerSpeed <>SlowestPlayerSpeed Then
                                                    Dec(PlayerSpeed);

                                                 Inc(SlowedDownTime,MaxSlowedDownTime);
                                            End;
                                        End;


                   EnergyBonus: With PlayerRec[PlayerCount] do
                                Begin
                                Inc(PlayerScore,EnergyBonusPointsValue);
                                Inc(PlayerEnergy,EnergyIncrement);

                                If PlayerEnergy >MaxPlayerEnergy Then
                                   Begin
                                   PlayerEnergy:=MaxPlayerEnergy;
{$IFDEF MESSAGES}
                                   PlayerMessage:='I DIDN''T NEED THE ENERGY !';
                                   MessageTime:=NormalMessageTime;
{$ENDIF}
{$IFDEF MESSAGES}
                                   End
                                Else
                                    If PlayerEnergy <= EnergyIncrement Then
                                       Begin
                                       PlayerMessage:='ENERGY JUST IN TIME, TOO !';
                                       MessageTime:=NormalMessageTime;
                                       End
                                    Else
                                        Begin
                                        PlayerMessage:='PICKED UP AN ENERGY BONUS !';
                                        messageTime:=NormalMessageTime;
                                    End;

{$ENDIF}
                                End;


                   FreezeBonus: Begin
                                With PlayerRec[PlayerCount] do
                                     Begin
                                     Inc(PlayerScore,FreezeBonusPointsValue);
{$IFDEF MESSAGES}
                                     PlayerMessage:='PICKED UP A FREEZE BONUS !';
                                     MessageTime:=NormalMessageTime;
{$ENDIF}
                                End;

                                For OtherCount:=1 to PlayersOn do
                                    If OtherCount <> PlayerCount Then
                                    With PlayerRec[OtherCount] do
                                    Begin
                                    PlayerStatus:=PlayerStatus OR Frozen;
                                    Inc(FrozenTime,MaxFrozenTime);
                                    WaitCount:=MaxWaitCount;
                                End;
                                End;


                   ReverseBonus: Begin
                                 With PlayerRec[PlayerCount] do
                                 Begin
                                      Inc(PlayerScore,ReverseBonusPointsValue);
{$IFDEF MESSAGES}
                                      PlayerMessage:='PICKED UP A REVERSE BONUS !';
                                      MessageTime:=NormalMessageTime;
{$ENDIF}
                                 End;

                                 For OtherCount:=1 to PlayersOn do
                                    If OtherCount <> PlayerCount Then
                                    With PlayerRec[OtherCount] do
                                         Begin
                                         Inc(KeyReverseTime,MaxKeyReverseTime);
                                         PlayerMessage:='OH NO! KEYS ARE REVERSED !';
                                         MessageTime:=NormalMessageTime;
                                    End;
                                 End;


                   DisableBonus: Begin
                                 With PlayerRec[PlayerCount] do
                                      Begin
                                      Inc(PlayerScore,DisableBonusPointsValue);
{$IFDEF MESSAGES}
                                      PlayerMessage:='PICKED UP A DISABLE BONUS !';
                                      MessageTime:=NormalMessageTime;
{$ENDIF}
                                 End;

                                 For OtherCount:=1 to PlayersOn do
                                 If OtherCount <> PlayerCount Then
                                    Inc(PlayerRec[OtherCount].DisableTime,MaxDisableTime);
                                 End;


                   InvulnerabilityBonus: Begin
                                         With PlayerRec[PlayerCount] do
                                              Begin
                                              EnemyLaserHurts:=False;
                                              InvulnerableTime:=MaxInvulnerableTime;

                                              Inc(PlayerScore,InvulnerabilityBonusPointsValue);
{$IFDEF MESSAGES}
                                              PlayerMessage:='YEAH! I AM INVULNERABLE !';
                                              MessageTime:=NormalMessageTime;
{$ENDIF}
                                         End;
                                         End;


                   AssFiringBonus:  Begin
                                     With PlayerRec[PlayerCount] do
                                          Begin
                                          Inc(PlayerScore,AssFiringBonusPointsValue);
{$IFDEF MESSAGES}
                                          PlayerMessage:='PICKED UP AN Ass FIRING BONUS !';
                                          MessageTime:=NormalMessageTime;
{$ENDIF}
                                     End;

                                     For OtherCount:=1 to PlayersOn do
                                         If OtherCount <> PlayerCount Then
                                            With PlayerRec[OtherCount] do
                                            Begin
                                            AssFiring:=True;
                                         End;
                                     End;


                   NormalBonus:    Begin
                                   With PlayerRec[Playercount] do
                                   Begin
                                        DisableTime:=1;
                                        KeyReverseTime:=1;
                                        SlowedDownTime:=1;
                                        PlayerSpeed:=NormalPlayerSpeed;
                                        CurrentLaserType:=NormalLaser;
                                        AssFiring:=False;

                                        Inc(PlayerScore,NormalBonusPointsValue);
{$IFDEF MESSAGES}
                                        PlayerMessage:='PICKED UP A NORMALITY BONUS.';
                                        MessageTime:=NormalMessageTime;
{$ENDIF}
                                   End;
                                   End;


                   ToodysBonus:    Begin
                                   With PlayerRec[PlayerCount] do
                                        begin
                                        Inc(BanzaiTime,MaxBanzaiTime);

                                        Inc(PlayerScore,ToodysBonusPointsValue);
{$IFDEF MESSAGES}
                                        PlayerMessage:='BANZAI THE OTHER PLAYERS !';
                                        MessageTime:=MaxBanzaiTime;
{$ENDIF}
                                        End;

                                   For OtherCount:=1 to PlayersOn do
                                   If OtherCount <> PlayerCount Then
                                       With PlayerRec[OtherCount] do
                                       Begin
{$IFDEF MESSAGES}
                                       PlayerMessage:='DO NOT BUMP PLAYER '+chr(48 + PlayerCount)+' !';
                                       MessageTime:=MaxBanzaiTime;
{$ENDIF}
                                       End
                                   End;


                   LaserBonus:     Begin
                                   With PlayerRec[PlayerCount] do
                                   If CurrentLaserPower < MaxLaserPower Then
                                      Begin
                                      Inc(CurrentlaserPower);

                                      Inc(PlayerScore,LaserBonusPointsValue);
{$IFDEF MESSAGES}
                                      PlayerMessage:='LASERS ENHANCED !';
                                      MessageTime:=NormalMessageTime;
{$ENDIF}
                                      End
                                    Else
                                        Begin
                                        PlayerMessage:='WRAP AROUND LASERS !';
                                        CurrentLaserType:=LaserWraps;
                                        MessageTime:=NormalMessageTime;
                                    End;
                                   End;

                   WarpBonus:      With PlayerRec[PlayerCount] do
                                   Begin
                                        Warp(PlayerCount);

                                        Inc(PlayerScore,WarpBonusPointsValue);

{$IFDEF MESSAGES}
                                        PlayerMessage:='WARPING !';
                                        MessageTime:=NormalMessageTime;
{$ENDIF}
                                   End;


            BounceLaserBonus:      With PlayerRec[PlayerCount] do
                                   Begin
                                        CurrentLaserType:= LaserRebound;
{$IFDEF MESSAGES}
                                        PlayerMessage:='OOH! BOUNCY LASERS!';
                                        MessageTime:=NormalMessageTime;
{$ENDIF}
                                   End;
                   End;


                   { Indicate bonus has been taken
                   }


                   BonusRec[BonusCount].BonusType:=0;
                   Dec(BonusesOnScreen);


                End;
         End;
     End;
End;
{$ENDIF}

Procedure DoCollisions;
Begin

     DoPlayerToLaser;

{$IFDEF BUMPING}
     DoPlayerToPlayer;
{$ENDIF}

{$IFDEF BONUSES}
     DoPlayerToBonuses;
{$ENDIF}
End;

Begin
     LoadGraphics;
     If (PlanetSeg <>0) And (titleBitmapSeg<>0)
     And (EmporerSeg<>0) And (ScratchSeg<>0) Then
        Begin


        Repeat

              InitVGAMode;
              SetAllPalette(titleBitmapPalette);

              SetUpPlayers;

              SetAllPalette(DestroyerPalette);
              SetPalette(253,63,63,63);
              SetPalette(254,63,0,0);
              SetPalette(255,63,63,0);

              HookKeyboardInt;


              SelectFont(1);

              Repeat
                    BitmapCopy(PlanetSeg,PlanetOfs);
                    DrawPlayerStuff;
                    DrawLasers;

{$IFDEF BONUSES}
                    DrawBonuses;
{$ENDIF}

                    Vwait(1);
                    CopySourceBitmap ;


                    MoveShips;
                    MoveLasers;

{$IFDEF BONUSES}
                    MoveBonuses;
{$ENDIF}

                    DoCollisions;

                    delay(1);

              Until (keydown[1]) or (PlayersAlive <= 1);


              { back to normal crap DOS key reading }

              UnHookKeyboardInt;

              If PlayersAlive <= 1 Then
                 Begin

                 Memw[$0040:$1a]:=Memw[$0040:$1c];

                 SetAllPalette(EmporerPalette);

                 BitMapCopy(EmporerSeg,EmporerOfs);
                 SelectFont(6);

                 SetColour(255);

                 {
                 El snido messago (Adjust to suit your peer group)
                 }

                 Case Random(20) of
                 0: Message:='Even Paul Langa has scored more !';
                 1: Message:='Stop drinking and you''ll shoot better !';
                 2: Message:='Next time, press the fire button !';
                 3: Message:='Are you sure that you weren''t cheating ?';
                 4: Message:='Come in and meet my daughter, son!';
                 5: Message:='Next time SHOOT the other players !!';
                 6: Message:='Would you like to see my puppies ?';
                 7: Message:='Ian Makin has eyebrows just like these !';
                 9: Message:='<SPEECHLESS>';
                10: Message:='What a waste of good hard disk space !';
                11: Message:='Does your maw know you''re here ?';
                12: Message:='I bet you''re one of Tunstall''s mates !';
                13: Message:='Your performance was pure f***ing crap !';
                14: Message:='Come up and see my etchings, young man !';
                15: Message:='You sure did kick some ass out there !';
                16: Message:='I bet you drink Carling Black Label !';
                17: Message:='Err... I love you.';
                18: Message:='I never liked Dune that much anyway !';
                19: Message:='Your mum looks like Yoda from Star Wars !';
                20: Message:='I''m buying the rounds tonight son !';
                End;

                 OutTextXY( ((40 - Length(Message))DIV 2) *8,160,Message);

                 CopySourceBitmap ;

                 Delay(2000);

                 Memw[$0040:$1a]:=Memw[$0040:$1c];
                 TempKey:=ReadKey;
              End;

        Until Keydown[1];  { Until key is definitely ESC }

        {
        Right, deallocate the memory required for the
        game & virtual screens.
        }

        FreeBitmap(PlanetSeg,PlanetOfs);

        FreeBitmap(titleBitmapSeg,TitleBitmapOfs);

        FreeBitmap(EmporerSeg, EmporerOfs);

        FreeBitmap(ScratchSeg,ScratchOfs);
        End
   Else
       Begin
       Writeln;
       Writeln('Memory allocation error! 400K bytes free on heap needed.');
   End;
End.

{ I love you all !!! ;) }
