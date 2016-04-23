{
PROGRAM NAME : STUPID ALIEN INVADERS FROM ORKNEY (Revision 2)

AUTHOR       : SCOTT TUNSTALL B.Sc

CREATION     : JUNE 1996
DATE

	       ALL OFFENSIVE CRAP & EXPLETIVES REMOVED

			"Kojak's on the case!"


----------------------------------------------------------------------


NOTE: THE PCX AND IMAGE FILES THAT THIS GAME USES ARE ATTACHED TO
THE BOTTOM OF THIS PROGRAM, IN XX3402 FORMAT!!!

EXTRACT THE FILE IMAGES.ZIP USING XX3402, THEN COMPILE THIS FILE
AND UNZIP THE IMAGES INTO THE ** SAME DIRECTORY ** AS THE EXECUTABLE!!!!

THEN RUN, OF COURSE!!!



DISCLAIMER
----------

If this crashes on you, try FORMAT C: and re-install (THAT WAS A JOKE)
No, instead try unzipping the image files first and compiling with
TP6 or better.

And don't run this on a P90, see the game flash by, and blame me. Try
and slow it down yourself you geek! :)




REQUIREMENTS
------------

NEWGRAPH unit, from June 96 GRAPHICS.SWG - heading "Improved Graphics
Routines". Author : Me!

Turbo Pascal 6 or better running TPX.EXE (You may have to change "switches")
386 (Or better) processor
500K memory
A sense of humour
Penchant for sheep



GAME INFO
---------

Z 	     = Move Ship left
X 	     = Move Ship Right
SPACE 	     = Fire Missile
CTRL-ALT-DEL = Mercy :)



Included in this game is:

	 o Dave Norrie (P90 man)

	 o Fish (Alright Alan Henderson? :) )

	 o Aliens who don't fire back (makes game more fun)

	 o Orvilles!!!! I HATED THAT DUCK WHEN HE WAS ON TELLY
	   SO THIS IS MY REVENGE!!! ;)

	 o Sheep




Thanks to Dave Jack for his "inspirational" advice!





PARAMETERS -> PROGRAM


-speech       If you have a speech synthesiser then use this switch.
	      Surely EVERYONE must have access to a speech synthesiser
	      program somehow, they come with soundblasters and you can
	      get em off the 'Net easy! I use TRAN.EXE anyway.


-nofilth      No effect - there aren't any rude words in this game. If you
	      want the hardcore, uncut all singing all dancing :)
	      version, send £4000 used notes in Sterling to:

		       Kojak Van Damme
		       Somewhere in Dunfermline
		       Fife
		       Don't tell the missus


-nocrap       Skips the "Lieutenant Kojak Van Damme" bit at the start.
	      If you want to cut the crap and get straight to the title
	      proper, then pass this parameter!


-realstupid   Makes the aliens sitting ducks!! :)
	      They don't move AT ALL!




IF YOU LOVE SHEEP
-----------------

If any of you lot out there are emotionally attached to sheep then this
game could offend you. Instead, try something like "meeting women". You
can participate in this pastime by attending pubs, nightclubs or even
in the street of your village! If you are a woman and love sheep then
well...


}


Program YaAlienBasts;


Uses Crt, Dos,NewGraph; { NEWGRAPH was posted to the SWAG, it's
			  in the June 96 GRAPHICS.SWG - author:
			  Scott Tunstall }


{$m 4096,0,327680}







Const SPEECH_SYNTHESISER = 'TRAN.EXE';           { Change if you have
                                                   a better one }





Type AlienRec = Record

     AlienType    : byte;   { 0 = Dead, 1 = A Orville, 2 = Normal Alien }
     AlienDying   : byte;

     AlienX       : integer;
     AlienY       : integer;
End;





{
My KOJAKVGA unit (which wasn't placed in the SWAG despite it being
ultra cool) gets rid of this seg: offs crap, but as y'all are using
NEWGRAPH (maybe :) )
}


Var     Title1Seg,
        Title1Ofs,
        Title2Seg,
        Title2Ofs : word;

        LutherPal,
	Title1Pal,
        Title2Pal          : PaletteType;

        PlayFieldSeg,
	PlayFieldOfs       : word;


        PlayerPtr,
        MissilePtr,
        FishPtr,
        NorriePtr,
        SheepImg,
        ItsTuckMsg,
        WantAP90Msg,
	LoveOberMsg        : pointer;

        AlienPtr, OrvillePtr,
        DeadAlienPtr,
	AbuseMsg           : Array[0..1] of Pointer;

        SaySpeech,
        ShowCrap,
        ShowFilth,
        AngelWords,
        AliensMove,
        LaserOn,
        NorrieOn,
        FishOn,
        SheepOn,
        GameOver,
        NextLevel          : boolean; { Before you say it, I know it's
                                        a waste of RAM OK? }
        Alien:
        Array[1..8, 1..6] of AlienRec;


        AnimFrame,
        AnimDelay,
	AnimLatch,
        AlienCount         : byte;
        AliensPauseVar,
        AlienDirection,
        NorrieTime,
        SheepMessage,
        SheepMessageTime   : byte;


	PlayerX,
	LaserX,
	LaserY             : integer;

	FishX,
	SheepX             : integer;






{ If these switches give you errors in Tp6, compile with Turbo 7 or
remove some of 'em! }




{$r-,q-,v-,s-,x+}







Procedure GetSwitches;
Var Count: byte;
Begin
     SaySpeech   :=False;                 { Defaults }
     ShowCrap    :=True;
     ShowFilth   :=True;		  { No filth in this game }
     AngelWords  :=True;
     AliensMove  :=True;


     If ParamCount = 0 Then exit;


     For Count:=1 to ParamCount do
	 Begin
	 If ParamStr(Count) = '-speech' Then
	    SaySpeech:=True
	 Else
	     If ParamStr(Count) = '-nocrap' Then
		ShowCrap:=False
	     Else
		 If ParamStr(Count) = '-nofilth' Then
		    ShowFilth:=False
		 Else
		     If ParamStr(Count) = '-noangelwords' Then
			AngelWords:=False
		     Else
			 If ParamStr(Count) ='-realstupid' Then
			    AliensMove:=False;

     End;

End;







{
Load In Title pages, sprites, Messages etc.
}







Procedure LoadGraphics;
Begin
     Bitmap(Title1Seg, Title1Ofs);
     SetSourceBitmapAddr(Title1Seg, Title1Ofs);
     LoadPCX('TITLEPGE.PCX',Title1Pal);
     Bitmap(Title2Seg, Title2Ofs);
     SetSourceBitmapAddr(Title2Seg, Title2Ofs);
     LoadPCX('2NDTITLE.PCX',Title2Pal);

     LoadShape('PLAYER.IMG'   , PlayerPtr);
     LoadShape('MISSILE.IMG'  , MissilePtr);
     LoadShape('ALIEN1.IMG'   , AlienPtr[0]);
     LoadShape('ALIEN2.IMG'   , AlienPtr[1]);
     LoadShape('ORVILLE1.IMG' , OrvillePtr[0]);
     LoadShape('ORVILLE2.IMG' , OrvillePtr[1]);
     LoadShape('DEADGUY1.IMG' , DeadAlienPtr[0]);
     LoadShape('DEADDUCK.IMG' , DeadAlienPtr[1]);
     LoadShape('FISH.IMG'     , FishPtr);
     LoadShape('NORRIE.IMG'   , NorriePtr);
     LoadShape('SHEEP.IMG'    , SheepImg);

     LoadShape('ITS_TUCK.IMG' , ItsTuckMsg);
     LoadShape('WANTP90.IMG'  , WantAP90Msg);
     LoadShape('LOVEOBER.IMG' , LoveOberMsg);

     Bitmap(PlayfieldSeg, PlayFieldOfs);
     SetSourceBitmapAddr(PlayFieldSeg, PlayFieldOfs);
     CCls(0);
End;














Procedure InitObjects;
Var Across, Down: byte;

Begin
     PlayerX:=160;
     LaserOn:=False;

     SheepOn:=False;
     FishOn:=False;
     NorrieOn:=False;


     GameOver:=False;
     NextLevel:=False;

     AlienCount:=48;
     AliensPauseVar:=AlienCount;

     AnimFrame:=0;
     AnimDelay:=AlienCount DIV 6;

     AnimLatch:=AnimDelay;


     AlienDirection:=1;

     For Across:=1 to 8 do
         With Alien[Across,1] do
         Begin
	      AlienType:=1;

              AlienDying:=0;
	      AlienX:=((Across-1) * 18) ;
              AlienY:=40;
         End;

     For Down:=2 to 6 do
         For Across:=1 to 8 do
         With Alien[Across,Down] do
         Begin
              AlienType:=2;
              AlienDying:=0;
              AlienX:=((Across-1) * 18) ;
              AlienY:=40+((Down-1) * 18);
         End;
End;













Procedure DrawObjects;
Begin
     If NorrieOn Then
	Begin
	Blit(40,160,NorriePtr^);         { Draw Dave Norrie }
        If NorrieTime < 128 Then         { Display WANT A P90 ? }
           Blit(16,144,WantAP90Msg^)
        Else
            Blit(16,144,ItsTuckMsg^);    { Announce Norries Arrival ! }
     End;


     {
     Draw Fish! Alan Henderson come on down!
     }

     If FishOn Then
        ClipBlit(FishX,20,FishPtr^)
     Else
         If SheepOn Then
            Begin
            ClipBlit(SheepX,20,SheepImg^);              { Draw Sheep }
            If SheepMessage = 1 Then                    { Display .. }
               ClipBlock(SheepX-40,0,LoveOberMsg^);     { I LOVE OBER }
            End;
End;











{ Taito made a killing from Space Invaders.

  It's quite simple to program, actually!

}



Procedure DrawAliens;
Var Across, Down: byte;

Begin
     For Across:=1 to 8 do
         For Down:=1 to 6 do
         With Alien[Across,Down] do
         Begin
         If AlienType <>0 Then
            Begin
            If (AlienDying = 0) Then
               Begin
                    Case AlienType Of
                    1 : Blit(AlienX,AlienY,OrvillePtr[AnimFrame]^);
                    2 : Blit(AlienX,AlienY,AlienPtr[AnimFrame]^);
                    End;
               End
            Else

                {
                  Draw Alien with Halo!

                  }


                Begin
                     Case AlienType Of
                     1 : ClipBlit(AlienX, AlienY, DeadAlienPtr[1]^);
                     2 : ClipBlit(AlienX, AlienY, DeadAlienPtr[0]^);
                     End;
                End;

            End;
         End;
End;








{
Even tho there is only 1 command in here it helps make the
code more 'modular'
}



Procedure DrawLaser;
Begin
     Blit(LaserX, LaserY, MissilePtr^);
End;







Procedure DrawPlayer;
Begin
     Blit(PlayerX, 192, PlayerPtr^);
end;






{
All non-essential objects are updated, i.e. Sheep/Fish/Norrie
}



Procedure UpdateCharacters;
Begin
     If NorrieOn Then
        Begin
	Dec(NorrieTime);
	If NorrieTime=0 Then NorrieOn:=False;
        End
     Else
         If Random(500)=1 Then
            Begin
            NorrieOn:=True;
            NorrieTime:=200;
         End;





     If FishOn Then
        Begin
        Inc(FishX,1);           { Move fish right }
	If FishX >320 Then
           FishOn:=False;
        End
     Else
         If Not SheepOn Then
            Begin
            If Random(20)=10 Then
               Begin
               FishOn:=True;
               FishX:=-12;
	    End;
         End;


     {
     When SheepMessage = 2 that means it's already been displayed
     }


     If SheepOn Then
        Begin
        If SheepMessage<>1 Then
           Begin
           Dec(SheepX,1);
           If SheepX < -12 Then
              SheepOn:=False
           Else
               If (SheepMessage <>2) And (SheepX < 164) Then
                  Begin
		  SheepMessage:=1;
                  SheepMessageTime:=50;
               End;
           End
        Else
            if SheepMessage = 1 Then
               Begin
               Dec(SheepMessageTime);
               If SheepMessageTime = 0 Then
                  SheepMessage:=2;
            End;
	End

     Else
         If Not FishOn Then
            Begin
	    If Random(20)=10 Then
               Begin
               SheepOn:=True;
               SheepMessage:=0;
               SheepX:=320;
            End;
         End;

End;












Function UpdateAliensPos(IncX, IncY: integer) : boolean;
Var Across, Down : byte;
    IsGameOver   : boolean;

Begin
     IsGameOver:=False;
     For Down:=1 to 6 do
         For Across:=1 to 8 do
	     With Alien[Across,Down] do
             Begin
             If (AlienType <> 0) And (AlienDying = 0) Then
                Begin
                Inc(AlienX, IncX);
                Inc(AlienY, IncY);
                If AlienY >= 192 Then
                   IsGameOver:=True;
                End;
             End;


     UpdateAliensPos:=IsGameOver;
End;








{
The procedure name gives a small hint as to what it actually does.
(Unlike some software eh Geoff? :) :) :) )

I couldn't be bothered giving it a name like:

  "Move Aliens about until they hit the bottom of the screen
  Or get shot to pieces" :)
}



Procedure UpdateAliens;

Var ChangeDirectionNow: boolean;
    Across, Down,Sway: byte;
    NewX, NewY : integer;


Begin



     Dec(AnimDelay);
     If AnimDelay = 0 Then
        Begin
        If AliensPauseVar > 6 Then
           AnimDelay:=(AliensPauseVar DIV 6)+2
        Else
            AnimDelay:=1;

        If AliensMove Then
           Begin
           AnimFrame:=AnimFrame XOR 1;


{ SOMEBODY ** PLEASE ** ADD SOME .WAV PLAYING CODE !! (And a WAV!) }


	   Sound(AnimFrame * 40);                  { 20 }
           Delay(25);
           NoSound;



        End;


        ChangeDirectionNow:=False;

        For Down:=1 to 6 do
            For Across:=1 to 8 do
            With Alien[Across,Down] do
            Begin
            If (AlienType<> 0) And (AlienDying = 0) Then
               Begin


{ Sorry about the extreme nesting, but as I said I didn't intend this
  code to be examined... I've already spent ages removing the
  expletives from my code !!! >-| }


               If AliensMove Then
                  Begin

                  If AlienDirection = 0 Then
                     Begin
		     NewX:=integer (AlienX) - 4;
                     If NewX <= -1 Then
                        Begin
                        ChangeDirectionNow:=True;
                        Across:=8;
                        Down:=6;
                        End;
                     End
                  Else
                      Begin
                      NewX:=integer (AlienX) + 4;
		      If NewX >= 304 Then
			 Begin
                         ChangeDirectionNow:=True;
                         Across:=8;
                         Down:=6;
			 End;
                      End;


{
If any aliens have made it to the edge of the screen
obviously a change of direction is required.
And of course to move the aliens down one row.
}


                  End;


               End
            Else

                { Alien with halo }


                If AlienType <>0 Then
                Begin
                If AlienDying = 1 Then
                   begin
                   Dec(AlienY,2);

                   {
                   Make alien sway about as he flies to heaven!
                   }

                   Sway:=Random(50) AND 3;
                   Case Sway Of
                   0: Dec(AlienX,2);
                   2: Inc(AlienX,2);
                   End;


                   {
                   If alien has reached Nirvana then update
                   dead alien counter
		   }


                   If AlienY <= 4 Then
                      Begin
		      AlienType:=0;
                      Dec(AlienCount);
                      If AlienCount=0 Then
                          NextLevel:=True;
                      end;
                   end
                end;

            End;



            If AliensMove Then
            Begin
                 If ChangeDirectionNow Then
                    Begin
                    AlienDirection:=AlienDirection XOR 1;
                    GameOver:=UpdateAliensPos(0,16);
                    End
                 Else
                     Begin
                     If AlienDirection = 0 Then
                        UpdateAliensPos(-4,0)
                     Else
                         UpdateAliensPos(4,0);
                     End;
            End;

     End;
End;










{
This is the laser to alien collision detection routine.
Tis groovy! (As you chaps can guess, modesty was never my
weak point)
}


Procedure UpDateLaser;
Var DistX, Disty: integer;
    Across, Down: byte;
Begin
     Dec(LaserY,4);
     If LaserY <=20 Then
	Begin
	LaserOn:=False;
	Exit;
     End;


     { Hit any aliens ? }

     For Down:=1 to 6 do
	 For Across:=1 to 8 do
	 With Alien[Across,Down] do
	      Begin
	      If (AlienType<> 0) And (AlienDying = 0) Then
		 Begin

		 DistX:=Abs(AlienX - LaserX);
		 DistY:=Abs(AlienY - LaserY);


		 If (DistX < 8) And (DistY < 6) Then
		    Begin
		    LaserOn:=False;
		    Dec(AliensPauseVar);
		    AlienDying:=1;

{
You know, you could add some code to play .VOC/WAV files here,
such as Aargh, ieeee etc. For more sound FX ideas, check out
those old "Commando" magazines, where the enemy dies in various
awful ways... "Mein leben, I never knew there was a rather large
machine gun round das corner" :)
}


		    Sound(80);
		    Delay(10);
		    NoSound;

		    Down:=6;
		    Across:=8;
		 End;
	      End;
	 End;
End;










Procedure UpDatePlayer;
Begin
     If Keypressed Then
	Begin
	Case upcase(ReadKey) Of
	'Z' : If PlayerX > 0 Then Dec(PlayerX,2);
	'X' : If PlayerX < 304 Then Inc(PlayerX,2);
	' ' : If Not LaserOn Then
		 Begin
		 LaserX:=PlayerX+3;
		 LaserY:=184;
		 LaserOn:=True;
	      End;
	End;


	Mem[$40:$1a]:=Mem[$40:$1c];             { Flush key buffer }
     End;
End;





















{
Change SPEECH_SYNTHESISER constant at top if you have a better
speech synthesis program on the go.

I use a SoundBlaster Pro myself, but unfortunately I can't get
Speech Synthesis on the go (without CT-VOICE.DRV anyway)
}



procedure CallTran(WhatToSay: String);
Var F: Text;

Begin
     Assign(F,'INFILE.TXT');
     ReWrite(F);
     Writeln(F,WhatToSay);
     Close(F);
     Delay(1000);
     exec(SPEECH_SYNTHESISER, '-v INFILE.TXT');
End;








{
My tribute to DOOM 2 !
}




Procedure Disclaimer;
Var COunt: byte;
    CurrDir: string[80];
Begin
     TextMode(CO80);
     TextColor(YELLOW);
     TextBackground(BLACK);
     ClrScr;

     TextBackGround(BLUE);



     GotoXY(1,1);
     For Count:=1 to 10 do
	 Write('        ');

     GotoXY(1,1);
     Write('STUPID INVADERS FROM ');
     TextColor(LIGHTRED);
     Write('O**NEY II ');
     TextColor(YELLOW);
     Write('(C) 1996 ');
     TextColor(WHITE);
     Write('SCOTT TUNSTALL. ');
     TextColor(YELLOW);
     Write('Version 1.2.9.(b)');

     GotoXY(1,4);
     TextColor(LightGray);
     TextBackground(BLACK);

     For Count:=1 to 10 do
         Write('========');

     Writeln('THIS GAME IS ALKYWARE. IF YOU USE IT, SEND BEER TO ME. OR WOMEN..');
     Writeln('DISTRIBUTE FREELY AMONGST YOUR WORST ENEMIES, GIRLS WHO HAVE GIVEN YOU THE');
     Writeln('ELBOW FOR AN UGLIER BLOKE (Oh hi Susie!) AND THOSE MATES WHO WON''T BUY A');
     Writeln('ROUND IN THE PUB.');


     For Count:=1 to 10 do
	 Write('========');

     Writeln;
     Writeln('<Press any key>');

     ReadKey;


     ClrScr;
     TextColor(LightGray);
     Writeln('CONTROLS :');
     Writeln;
     Writeln('Z     = Move Wellwood raider rocket Left');
     Writeln('X     = Move Rocket Right');
     Writeln('SPACE = Fire abuse missile :)');
     Writeln('Q     = Quit the game');
     Writeln('CTRL + ALT + DEL = Best thing ever ! :)');
     Writeln;
     Writeln;
     TextColor(RED + BLINK);
     Writeln('PRESS ANY KEY TO BEGIN THIS CRAP !!!!');


     if SaySpeech And ShowFilth Then
        begin
        CallTran('DONT PLAY THIS CRAP');
     end;


     Readkey;
End;









Procedure ShowTitleScreens;
Var ExitTitles: boolean;
    Count: word;
Begin
     InitVGAMode;
     ExitTitles:=False;
     While Keypressed do
           ReadKey;


     Repeat
           SetAllPalette(Title1Pal);
           ShowBitmap(Title1Seg,Title1Ofs);
           For Count:=1 to 1000 do
               begin
	       If Keypressed Then
                  begin
                  exittitles:=true;
                  Count:=1000;
                  end;
               delay(10);
               end;

           if exittitles = false Then
              Begin
              SetAllPalette(Title2Pal);
	      ShowBitmap(Title2Seg, Title2Ofs);
              For Count:=1 to 500 do
                  begin
                  If Keypressed Then
                     begin
                     exittitles:=true;
                     Count:=500;
                  end;
                  delay(10);
              end;
           end;
     Until exittitles;
end;














Begin
     LoadGraphics;
     GetSwitches;                       { Any params passed ? }


{
  Has anyone ever told you I look like Jean Claude Van Damme? :)
  (I wish! Then my woman problems would be solved :) )
}

     If ShowCrap Then                   { You can skip it by using the -nocrap
					  switch }
	Begin
	Disclaimer;
	InitVGAMode;
	SetSourceBitmapAddr($a000,0);
	LoadPCX('LUTHER.PCX',LutherPal);
	SetAllPalette(LutherPal);
	Delay(3000);
     End;





     Repeat
           ShowTitleScreens;

{ It's not bad spelling, it's phonetics ya eejit! :) }

           If SaySpeech Then
              CallTran('GET REDY TO DIE, HEWMAN SCUM');

           InitVGAMode;                  { back to normal colours }
           SetSourceBitmapAddr(PlayFieldSeg, PlayFieldOfs);

	   InitObjects;
           Repeat
                 Cls;
		 DrawAliens;
                 DrawObjects;

                 If LaserOn Then
		    DrawLaser;

                 DrawPlayer;
                 ShowBitmap(PlayFieldSeg, PlayFieldOfs);

                 UpdateCharacters;

                 UpdateAliens;

		 If LaserOn Then
                    UpdateLaser;       { This is the collision detection routine }

                 UpdatePlayer;

                 Delay(1);

           Until GameOver OR NextLevel;       { NextLevel ? Is there one!!! }

           If GameOver = True Then
              CallTran('HA HA HA YOU LOST!');

     Until false;

End.





{

CUT ALL OF THE THE FOLLOWING BINARY CODE OUT
DO NOT SEPERATE THE BLOCKS, JUST SAVE IT ALL AS ONE FILE!!!

SAVE CUT TEXT AS IMAGES.XX


USE XX3402 TO DECODE THIS FILE INTO IMAGES.ZIP
UNZIP IMAGES.ZIP TO THE SAME DIRECTORY AS THE GAME EXE FILE!!!!!
}



*XX3402-020714-120996--72--85-20677------IMAGES.ZIP--1-OF--5
I2g1--E++U+6+DawY0+FiyFO7E+++4s++++8++++EIl7FIsl9YZBFyDVN2+4yY+2--+4a+bY
E+HJkIUTf+fAVaa-0U6-2tm+YX+8-U-EGkA23++0++U++PqE66l05qgc++++Rk++++c+++--
H2Z3HX6iGIp5syJYE+TuE61AVj5oxRL-00cCsM-syX+x2+sHG+2H+pEL2kB2+-I++3-9+kEI
++6+0+0ne7IUa3ILBZE+++-i+E++1++++2F3EIF5JJYl9YZBFsKEIEf+A+V1NETM+FP6Pwxz
kqnKhckeKpe8teZ6fxDydO2AIj1RgsyMSOeQVcHbSBX63bvY+wXcV9rGflZWfgGEic5rcWF+
ZehvFzY7lrceI8BRBp-9+kEI++6+0+0ae7IUEIjDS2c+++-t+E++0++++2N7IoUiGIp5ZMv7
1E+V1+B1-LbHG3lzOIi+VFl0WDZ2wgW4mbE58E1aDFUY+spUg491n9w8SGaXh07deCb04D49
t6mshqZjtIPskKescZaW7ntEGkA23++0++U+74aI6AK+dpmF++++4EU+++k+++-7J3BTJ3J1
Gmt7HITRZ42CU0+6VPb-yx2VriYuzyymEe4KChrMWXb5+DaafpUL0HP2q6B3vWhNQeYlOjUc
EAuv0g9YHwRg3koraBZMMhedxAkRrHZBa5EiEVK4MNVlya0QV7J5Pg8wNX0OoMZMUO2TZggX
PUNAkUmZeRYIvCpfZ9NabH-xigdz3Xh--gRPt0mB5BlzN2YUOcT7Bqk1I2g1--E++U+6+1-d
Z007w957VE+++AA4+++A++++H2xKFIx0FJ6iGIp5pRFh0c+U1+PUvEHvoGJqdwtzY3H29nPB
u6IOdA5oMRLmD+UOUUVHNWureZf4b6jNNcKrAxaH-FcXXmIJfZiof4apu3FwTMOwtFKubrWz
OVZYXlM+bRv6ApduqGvLyuU9KXfNcaRJovm3KfbqlB+VHZwXzwOxwk-rpC-CgPz7-6A1HFy8
0p-9+kEI++6+0+1KO7EUUyUlqFE++++s++++0k+++2p7IpB7H2IiGIp5MyBYU+7yTekYDnyM
oh-UU7AU++-EGkA23++0++U+lKWI6BtnHFO-++++cU6+++c+++-CHp7GGIIiGIp5bQsv2gAk
0+J+u8-W7ZK8b6PXtRF-5kH6IdDLM0wMzDv+jrbBL5VfBDVOHbvuk3upcpPLGDLS4kD3VRgg
mx4VCKnvzEdQvVP51cqllxYGi5kwCyjQ11vafigWM+ForP7BF6F6MrLu8IfnmGbjGPZtOb-l
hhXpIFsC1lR9ZA8GuXozI2g1--E++U+6++WxY00twqeH4++++4s++++8++++I2l-KIJG9YZB
FyDVN2+5zDk2qTnwA+sz30+lEFlYBV6++3-9+kEI++6+0+0oO7EURcn-g2Y+++1t++++0E++
+3B6FIJE9YZBFlDaNQ+0h8+MJEl1-+EM4DUNyDYN670-IIi9IMgT+I0eV6KpU26Q60s5-pF6
0mE22MCcMc0664g2acki+54K3c703Y6Kkm82-U-EGkA23++0++U+jKWI6DGNoLmO++++kkM+
++g+++-LEItII1Yk9YZBFxKIoEr16+l2qS+yigHhZDY5OMD-CEWVw44dhIEUQ5cs-z5lGe4-
W3+meGozPHuzYJKZ6psnPKRgrB5GqENJvW8Ah4QbsXaOiqWgcva-9ZOsxU4ReOPio4ta4QYL
gd5CgtP14KRxPS29mqVwFuDrSc84cf4+pajPN7oO4rqtcf3UW3tsCQLEjr4j5gGJafUexazY
3+PycBADlFhEGkA23++0++U+NLb067AJ1eMx++++VU++++k+++-DIZN7H2l3AGt7HITXsKN+
+ol+66FU+XZ0Q0NIVdyTWMaT5u86LkUcm+xY0+5JAT5k+3K+BA1IUvI8ULK0C2kAEal++3G7
MWQ+I2g1--E++U+6+4dtkW0mw+CuBE+++7k++++A++++Hp7KGIlAFH6iGIp5syBak+FAE002
n+3mVN+sQBbzztaMzjy58Toj-7Hs1pI5l1kwE5IU3Y6TJ8IEWUpgP-0A1U-EGkA23++0++U+
76P064q89rtG++++BU2+++k+++-2FI32F3J1Gmt7HISBXw28k0+AErDmgYCUpstyzqwO3wNI
43Uh9LZev5rVA2cFzoVkdSG5TBD8e5F9MH+aWIkhRpKft0dNfqc5lc35-59rSryERfFlH1Bk
au2ptp3oI2g1--E++U+6++G3kW-sMsaAJEM++DYK+++A++++AYt2J2ZIH2IiI2BMvJVDWlF5
35wv2+UVo+Q3XkdnOJ0cklsIyi-05zM1X1+5XrDo6jFJ4A2j6DU-39kgv3KMWv1MLTpzNaRr
BQeu4WIP2saEfDxMYklqLfpuLJDHqtfYf1BJR9rrezexJuxSjNvRvvtNyVPkQrsdVNKZ1BNU
PSo0xfI9uXD1vsLNP2OX4LKQSznswJCbHdotQyPQiLCkh98oF0gjLvtuxSfpuxRjrPdp-ytY
KTPwyLCODpi-qFKMrEIIgBqRkNINf1-EETqBsIgNjsTEIQw7Gl37Mt9SgHFVGGtUogYMjoSO
ht+s0QydBP4HBXG76p4flW3drY-8admoPpYLCRUWb7l0USc1Kso9IdkQYL4Bj2MX6Kt2Hp-C
76HykKW2O8eVW9rybGZ173897KAVsnwHTYViO2eZpvjN7yk1fRKQCHpXUwpkLYdQYjElfLhA
q2RU8hJJC7GtDHuI4Z4Yi0NO+7IJ3OiYXcx2ksVjApt+HhHgR6Pg3KkmC8OsOGEY0vZH5upm
HGAQ-yrIi+bes0avgP7PNxAi8aAoZj38jRjk00eRAHszEUGdKo9cdd0tCMnR4AQMSFRb0hG9
0TMIGikFxZ-gsvm5U0GlIm97-2b4e0eENVCYWmMVFm73K4-LV749qzUAMSvi2JiAH1Z4gI+5
QaHAL6kBAWa4X-V1N+fRATOGlvj6U8okl85M+WYG6hN95xAdVSVmV+NIm27bVrSdeGDZhbiD
X0KAdBl9BWWlDqsn3ciMXOaZHs2CJhYegFTob9iSwJDPGVhRqsfIhaZXC2TY0wMG6GpXCTYY
uNk9T-NogXMbvSsHZd+J9SZR5PK2CtKYfgCcX1pFWFTnfb7bYxYkaxEFBqnIFuLGMiy6XI8U
dk9jCbOR--VKJr2wUclX7uZIpD596I3woIdV9C0xE+gFgRcKw666Bd1HHWVb581g9PWQZ0Mg
ASRQowEIylvY3foCYgEXqHO7Z9gjyS-z79SWnlnoZ27T2dDBW1T9511S2zRL1gKIzNmOx4Z9
JQoO6IhoV-ZrOX5DypC8FCecefGxY81qnJioc3aP3hGRfeBV7y2HWYd-dFbnNqfRi9dMTAd+
HbQttI-d+nbbUutOXz+s0ufDyUqbPgCIWoRRqrGUWjz2bh5Qb9doLx-96CFP9Noh8b9pSri0
qWp8ch1NBRclSf97pHg3-v47hG8ZIVTHeUkxft2hF16Molvcn4jUDVIkRFYGgw5Ac+yFDf3S
dt7SRsSMCIWDCFVH0BHKTu-lFaBxEjIdZGOLTX2jIIa3AaCa+ZTdcp8fvxCsc-KGQYGOT2qs
rfzU+CHoZXXYoCim3Nb0ezeCYSQt5J53YGNLhlUvcAUYq4j4p9c3QwN3TIeZ9Y9TMuc+Ghva
cesM7tGTBiAwkNEDYaPbXLi1V8JyGACdWzRfCdCuADwzrdXeHQXS8RoCmyy+AZ1GHsp1SfrC
+pOHw1fSM9vkvd3QwmArsh84FR0RwGy3UXa9TyJHAvGP2KpsnjKFAZdjS72bhDcWYkaYN3VB
To1v9gJD3a2nUdwWPNutnZ49S+dPMVzkWfPbYBeKd-0ptJ52vo8gosNkUXIvumGWQx0Ub0Tq
b16uIZOZGLtd8944W901DoePd1bTEwbxTeC2pfJLYtLpXkcFRP73AZoFMlBuOIf2z5S8jgkV
ZseOH5PkLMnS5RUJ1yLLFWt7TaDYUiGrFgt7TaRYH5how9rpxt1WDnEmJb8IDlUNAVHzB88G
zdeHcTGr7LJawrKvsXQXVB-tU3N3tuJZto25HwbGT2ZzTrsRTlpz5LzNsyzJDzpU5PykjftC
czKy4jPJdw7jjuce4ZLIQTO72mSurOsEkjCwpRLJLewr4+m069VqvReB4nRirvsx4cr8ghnT
ruTtZEzJ28cBE+5PFUL10jk4M4bPUS4kiXagBcPJgq3JeTOg4atIktgBkB8q+uBFZMuejJ5p
OZFJefqeFbjJ84o+ZfMR++VCEi--o6QUI8oTU-T+mK+Fg9HhUCQ3epvExs8-3kGe1E8j5rWf
1Q1GhUCxLb0l3klukOJS28Vq8SUBUhv3-a-dqk2+zlXsLT0LkTRJKzOVuwAlTl4khCp+hyiT
vjf9LRzfyftebhxRxfib4s0ZPES2w7S3TpPstsLjerPS3qRxgRk+94ov+4oTnAxz+3-9+kEI
++6+0+0qbGcVOXyb1Bkr++-jU+++0U+++2lJJ2V3IWtEEpWpTRhispWK7FD6-8M5zN9u+UYU
cT-LH0MU+aM8IOzuUbuU+IeMychtY+-HEDu2U5tE+WGEwOF1GbPMQQq9L0LKV9iuoMDikE+n
9nCBgH9AKKjjQoXO2JZHpNaJNNJZVGGSmvuijTPVTzngYzzUsPzzxAa3xwIbZtvwBz4wZSTJ
rh1nVVBjiD84hHTqjD524uywQSrBD4wqwKMfPpNvbrnlWTQ9zbjNAwRRPrCrCKtvargwXezl
8D5+DqkC0znS5+oSTwHTy5LFYpRSq1RhxQyRD1Jsp-XqDrbDrHjBwEezTimhkybapjFy4mR3
PpDVtoTv7TnYvymLiMRwK9y6Uy4L3T6haqDWFmP7wDYoKiGPEqwFPEsFLjxSFpTU3lwLyiQp
5hzVuPLxBWB1p5zaw5v+3qIa4+JVV7xsDIorymGRVijUykR9Mfenr-kjxRiBbM9ytONyfSzx
lpuqCFUzu+RxT9YTDMb1YKyWC185X7CugWhIqdKvY+hShhBk3uix5QNRStJrqJYWjDpSJiJS
-V23i3G-etaUuDi1M-1sFFW3EHXxnWvS4zraGrpotaP5ILhPfwFZ1huzu0SenG3Az23zN68y
5y0f-rvTy5pS8+aWg7zV5QSrxhBQVZRqGOtYdMkAgzN89fdAsDSmz5MsryjirC21JQFFwtil
JcCyL8UAEbxYYgW5f7XXvviP8mByOFSbgBQfDb6hTPJobmrYXJjvW+lrdj+BtmDHsxfVGRwD
nxAdd2dbp0vmsoLPKo4Ud7PSHWvOLJjyav2mq6ik8u5-3H0rO-1ock194YNMq5sFF71ZNA4j
fJf-i-TdD7OxVxCuP-NsQqwcSLk-EXnmiSqMWxTbZ2kEMHIXD-aR-i2+ZoWmR4qefXfhf8uw
vgumg9fLjKMXQT8jVKmhLVVzIwN38UNQjn+MQ2o95xgLxWDwGe-GwqmxeLNqtAzhvnz6QxKN
0zjxBvEtSmm8LzE1yQ6-jdVmNzU2OVHuISmjsqVVeaivkBz9VkoYb9N9jr-jRxveoyMEQ52A
BbkUrqju48RgTFx8UfodgEYPitvBkfP9IgeUtPiir7suYv8tjqvSOWpOpMit-tzWIfX8+3jH
5z+m7h-h0W3xq7kUH4+YRbN-Tv+9f-dufqP-K4akiaLgJKxOqqdu0OvFxziQ3tP6w89xg1wO
X29C23SDF6KXC-4RDRU733N54p3uOPzwfPBf4uShoqW+gTSl-tU57VCeqVGWgfVcTtFWvoTb
IPVi-ecPw2PghYtkpxblgeCwiwO4mUQV+fR7m-bddYSQ+fG3apJ+FEQEPdVGGjLag6skdnRK
acrMCRqhhwstBRhYpp9ThdAt4jUHn6-LkjV3rjcV-+teCg91V1tb4jfxCBlItt0XzSOUZvfc
9dmn26rDQPCxO+TECgfaAn8yIcoULV6XB+VqjWUGbct8TvHpeQSMSdH4di9ueTQefS7ifH2g
f0KmOrhTRfHILYaLU-dZ-dUXTgB+12P-0+f40q18TYYHC2X0SHH3H0hJc1wqRZCzwuetXd3Z
***** END OF BLOCK 1 *****



*XX3402-020714-120996--72--85-19304------IMAGES.ZIP--2-OF--5
ZWqvPmxIIUMdYZ+hC3Rw9oJxB-qRZBnA6+zH82jAMbB9QLGGw9mnPhjaBNKUkirWwR8yuu9p
me6nlP4b6hcDF4ukOs2TMlbVRS26MHSUU5usXiPFdUebMMOhjBDD4f4UOOOmMorIbRgRisGj
DDBtUMTlmgzV8CJtOJxv9ezfrypfKvmjzRjxqbrynWiga4cctOkihUPf70uKKsA-lp2FEcRX
2sscWOBs30vKwG6vLQRVeghKNYP4SS52ucoJzRqjCa8XgR8lyH4hfQ80aw+fOJult0DXQwly
C+V528wF19KT9S-uYgolL-Wc2GIpAyh3meRC8ZKkbbRBfjArOedSqF4vlpO4JxcNagyjv4xx
fN1bnlyxpjuMnzzFOo6h8cjihXXxNXgq3FJ1UV88Pxx26GM53MZ12mJV-YQI7Z3exbAzL212
pVEOH0JRdCQo2th1he4RzaTNYZxz+cIpMuNplgqyo159s6p4Q5tkKh-ekZ71gYms02kOyR2o
bOQNjB+wkMsZa9tNdBBYLKNt8zsjPCGxPTOV2GmRFLRKy9Zyx-9ZfnCLxb5lCLws2vJzMZyO
SNX4Ni5jKoNgR+7Ivs5z-6M30Xu8UfwlI4zcHFUbOF4j3mNRIwWCWzAk4DIFDIP7B3aYwm87
BrgLRZxplMkjz3IaNEqngpBeq-UPk9I3sf2BtEWtEFf1l0QakhOQFb2uHHBg+wojDVf3gA7l
AcI-ApGcFK8aMLmytfzTP+tjf1ivlQOIcfcTHe1wzAI5kwGYmcyA5WxzfVDKrxjDPvrjf7V-
1zT4lYlkzR2IwdBWnAZWOi93D1a9nwpojYvL53ZjWXFhWrR+sg7sPR7t44RfUlTHBqqsoSG6
tJxjy7RB84Tc7DHLhdSMEF3sW3IX2oyHINn20AQLNgo6uONMTtpWd-6haGe7ng7+QfUIQnTA
CmhA7Jq5IJ7YFNDhe3Bm+Qrisuemyp0WRjNroNbFnidxOsMdIVTKHHehQ-M+gkZ8eDiL6olb
aY41IsBQ3ZdwS6NBUvLRr8nD3tUEn368CnNWV6tsBlCfbKtioX+i6ZW+TNPaa5NZlSd8PA0j
Dt4LxjiNZSpgA+FRJLA9enj0oZ7eY3rQ37ZVp9LDNKXvPokqdzAy7h-wu1WAaobcviInMT+2
SHngqRYIGr-VHRV97r6O9rzA31wKdCiCOHODj8Ntx5drNZSxjn3CvuoVDgeoa-OBcVUK8VAV
Urfb29RmbOLZiYWn5UGEtUrtEMXIc+UcQmQGTYNZT6sBT4hbsmGhz3b5y4hBtfdbIu6avmO4
kmJ2GARYU+ZB4ACxMoBi27tWcolSd+jwa1ZgwTYuvoKoREF0Y7R+tmVkcr+PVT3NwVLw1vzj
bqlkqEpN19HrwNWjPLXmQ-sTjewPifUoz38H4beGa4YGDGCV4OftHKOhvE4PYOHnOH7Tz5q-
KFoHN-YAmUS0GcH-3sU20UXM3CMuBgbw544mmo2pUX2qcjZfnCKe6pGZEtooQMc7zzGFA7U6
9VpPQGWk5TYqLIk9n8VMIA5UCYrzIyBztbhWmADU-3cnlHkGy7EWHGFSSKS-1NRfvbHfruUk
3AubMEKsB5qi6cnWCgi9jQfptd+P9aeuG481PpxUYwCGGFKGPgFGW4NDWV-SnOF7-0Z73lUh
JDE5atxdbh2awV8UrpiY0YcTyxkAO3AMklHQT6jfDQgZBPj1lTSdmROIjzD3B7p8G+R9KGIO
L0Dp8MCHWBTCjWbGQoFf1bnMqbms-HZdkvYXKylI8Py9NaSqpfWJwWXgBhLSdSSWmNqJChD6
--v6lIQ0p41BMjIqsgaVDygwmkrp86DcnFTbn2VgWUAsUNU6kG815MhVqsfgb2grrxY3qxZE
vSfTBSPLRfm3gpnW8V5CVl4LqcRdbOt3lMwuN9A5dbD6wXKwSfe4V0rK9jMAOFU8+acyM2aM
j1IBLJegowGoOrhdlqmFqj61EzOb5dQT41cBaBrmAvEnYXYklejODN0TOYEMmITSCsfVlkq-
Kh3yV3fvfrC2ADUTYdP2l7bPC00g+s6TTOGoy1HWhCYQvy9A628L3YqsP53WSvJTOpPL9FPY
I-7bYejkhkIWfTs+8VLBMMcnu+5J2Ce6CS5DDR8hCHE0ibUqHGtu8NHlGqXWW5D-J79n3Cc9
PNmb1QlJqWgMelIK8Te32t8cKLT7BA0hH8jUovgkEU7tAV8k8cGbV63M678-X4Ld5DgFlJzV
zuMdZi2E0XmcyCqdTw6RERlgAcFiusSMzMI+3JM0TeI7LBhp8HddwPpdYX+UZEDcSVn2WtUq
XX2mNkCbgE0iXL+Gy1kwH9KtqzI+bW2j+wcJXfMALm-ONdpC3uYpFqIHxyY3LcVUaoPHWvxc
0V6wQkcv9Dd3KwBFyPoZhVwjYaaApNnyDNkVlVx80cZ6-+91kAEkLJakXWBX+gvP7qkFy8RD
A1La8oxVMCTdSTOmkTouVMpTCCsqBxqqWpwuJlUXs2+80lwCVsOsba0f9zsyX2s-IMmMlURV
mYwXTK40EaDAMLy3RrDtMLhThx++5lrcLoCiLGRTyLC5Hrray3pmOmKmh-6eTtcXEYF6Dh+y
aBFjgXZ2WB5HE2gIH9k65hAaKyUbV2wRVN6vEY4q2QFabeXxvZGG5-tvpOEajqE4bPdFoM5e
H0wWB6zm0RqfqOQlgeMdVnsUdXzcczkZlOF-BBJ62ZyoltOkrABAX-1980uFf2jCtXmniwuZ
5TW1RCHD5PhnRJWOmuNGpSdkUbKD2BM-G4+4hBbHv5-k++g3xsMDb9BisASc1XKa2K2Ew+RA
2p-LkVn8FAIoHhuoQAOZRQezTC-hUWaPmREdWvAoadsNa+l7WYm3AHCWVQC3pW9GKB+VWD0g
ay8eq0kHbQ9SZ2X7kyX70SOCnIauPqWQnIonyVOAMbXVkUkXcQPXY29xMR46i2oQMdCKQL94
X64Vl75F1m93X+hC00F00AGOP1y64IaOldqaUDpxl7CkcJAgxBBs+EnWoZf40v46isQZarzD
e0yv6KsLvSmU-uV--kJGUCbLaMotwQXGNDcPZbRXV9DmGUuvyGH292eF+YGfcqVBqlwnz7kX
jdV4WlRh0DGX1LZTCh2m1HXOp8-VOOBdEFW3oRVFJUU7DWDh-TpxlfWToVXZ1ukA3gl+4k4H
nKYTobYK-lSqm9FddNEvphN9LDpdOmpHqJUJjYd+t6kHHeMIC6az7MsZW9+sotHenYKslmEu
+I7OPFrUkw55wCvnOE4tGwrt4U3jB9zi42EP3-lrbQfuWxNieiIV3DUIGdT2047Gs13dDATG
50EP3SbedH1igFMUJNHa+-Sa+8lU8siImA9unBJRHECku8vdZMiKa415V5TQREHPYVdEhEYl
YYI0Kk35XyEfWJCi+ANnZ0UHuQVV1gyzqSgAAqkZTCpNL-0SYRJ9IFSFSPsISqqOyNianaDQ
A9Ox9EQ36xEDMPiaoFZRk3ZmZW+7mWVK+a5lYqY2XKe0zB7SqQ1ZoJEPP38qumuivjYJxvkh
yHU6tI5lVRY0BlHpP-AakAHVUV2fG8MmNl-5KPWJrD-c2qq7Kq5a1wM4Tx-jNBB7X8r-Fke8
IdIzZt18WDjxrUdcGyFkOvzh38PZdF8Dw1EM6JATbQ-ek8Q+9cNw+78Ud56+hsMMJqeeccae
y1o9g1zCdiQasZt+Ud-25nA5ihXrI4JTqTKsgWOVuCFtarhR1U2usV6gX3A2h0S0nFbYmNE-
4ftPSK7uoqwvFfYpDcVaaMT2mJe4T914ggezYqGwO89mJYEjClK+-oJJnckJp-AKkV-v4dPb
MGGa-4Z2HwEPukON5jHoVIkKKs5A66J9Z8jTW7-XOHcMl8IhCZoq6t493xNa4KQsvStgPY3x
w2x5dr42JJ5ozVG0al7urGg6kyh+MLe4ZjCqY6jwZf-NjcOPUqm6KADSJBMDLXRmwJqPj3UR
jUgNzQ4zwHSE-x+VU5U+gW70UF03ZwpHhkCrT59fmdpnVU6r4L02fAG6W8J89QTQiSVYqw37
b0dE++jeNR3J37Wd+e3bR67GIj+2kQ6Nld+mdQuG05z0V4weFuJ-5UNA0atk9WgjZJUlvtXD
FSiPLubrinTBqiwSqAP4O-Yv3dEtIHEt0NwUyEVEXYL+gpOfEsy3zpwk50Oy6DOtC7c5rwAW
ONL-L59JM3P2xlrmvBNeVSYMecu0ec8NphbkVr7sSg8655-o4I60QhprXV6Ljo3Z706iV+qB
E-untdjt5H7igqP4rZAo6ggJcfcfNIpAIs9jYfvQLZ2MeouMskT2wYOIWx37W1dA91O0MbUg
yCI9I0ac6jnAO-5EWJaD0E02M22VRE6dzh2RrvVAGWvuLnjZzmhpuXNhjxT6Qk5H37oWQ+Ee
-QuK63cPRSnmPRbu56tKmUkxJCYGDousDau1QSpp0gzrXHIGhu9-27JjCrPuSv4XdO6WZwr0
D6MGPfhKEm+UU0GAOOAbG0x8F0pm2LLo+-OSMG+rSMcuL0cT+AoY4cFkS5ipDuVz5UVhEqo2
ByfFjXnX7mqFVgkiFarBQ0nhI0UUCp2Ytt2m-3BAtT+fwdx2ARl96WAVm74hKFY+-AV8ApH8
scI-A74sbx9Nijci6yAd54BSJ09V4ncyIHh5tyf8XODPhLdUl5FPtkU-bH7f8G2yf+ZDeIjf
dlVO0jt8k2GTIc3MM6GQ385PO1fbtaudGLUbd1VzNdLvHaFczslWxx7Sv7ICsBt36NTK7lQR
5VgRSs2fM7BksGSgI4Ac0+wLAToTwhsjdPE9sQYACJYc92H7EZJUQu0RKKT3jh1hts7YnnMr
VsM7pU1BfLrNRjWVJ+JMidGNqrEF2s3WoAh9+xhTF6Z+5Bllt0BE5T5rAIc-mOWTx8Bk+Swa
B+-eBEPG8d8C-HjqlVetUUPpFHCGtqs22WeL2-VJuUCWumWQ+qcda5rGuaAg++9czRQtElv6
AErtfF-Hc5RyB3UE-iHMpbCKNzOqZW2V0lRe9mZV7nfIG509lzBCV3NcJ5WdERD1a+1F7eDR
yCYIlVTC45m0y+l7pm9x9N60+-LMEgt4G3iXlDWcOi3300ht8i8b38So2TIRXSGrz9BgCKdz
Q5jn-VO551syYBjoV81sjnqZI-PCy4rIUo9B02oJ3-i2fhnAEBMayUq0K+E74-id+m3XKFEB
TT9cKBF-uUXPd2YEZdR6OeaVWcM87bDeQh3Zo-NKovUyfn4s0w0-s1Toy4BuZo6vz7yS2o1X
6UQ9GJNMEeEl8H848GjXHA+5Lu0yVXq4CNsXaE1wV0diPsiobTJ-KApIlkYtaxB0G9mfNVNj
DCFWwOpgjyc6jwUSVvWnT2VIy9hXR5N-RK7bnJLAv-FcurkB4w0R9EWUUMW-S7XV3agnBqNx
XjWm7tl+D06kdW6z1Q63QobEMp12oSJvNjPeQV+GG8Xngc33i6UDFsSRtjUwgd5zXpRqUrL3
qpoR9siTMX1buS7wPO0bEDa68lZmXl+UdQdoIxoZkcxDxdIbCsXxkREDpfuImuLS1myZHYhX
WMCAL2jwag2o69zPQEcWXMaHHevazzL8BaJh62by628OgiO-FJaffg1qyWAK2zjkVuZIay+4
ILAYwJ8kgU5s6a3zg6+xb0Bcld6WPa3OmBeI--XNthrj5K-kv5-dR2bBcsQRdhjsod4ICbK3
ctdE7gJnZ1hkaEJloiFdF17nM9vg2uwC2Sc-cJhA3y6AK9MH3X9dOl-IiXaMEgu7qztjcb5T
t7cov9wh925zwX3ZbiCUobwktdrM+6vN0c64GxL1kVcBtxA0l770AWEc3V01K4XZ6Ihq+Ehq
7F34y0uk7KKoV8mzB22ArsNzmKLEMdd23hOPJavTCOvwHMSbO-c+MhQaDaRMABX299RVuRsY
jo2-D-79nh4QcbH18U41ON-xK7fZI3VTXoDsZ0-OM9BpzGHLqpEuYcDW7IrYRxoW5mwS-6mC
v8j8DOJvJRgaLrA1rp9+iN13Grecp6DLF7+1Y5AW1cVs6JYm636aWDiXSE33yoNl2+a9Pb88
***** END OF BLOCK 2 *****



*XX3402-020714-120996--72--85-61607------IMAGES.ZIP--3-OF--5
6DLOgGkg2O7gMT69OwNhrOuohPgRa48v1z--oxHqh8dAqChzSA9OSkdstInlK-4WMXoLZ-iS
CV1QC28lB+Mr1BYsrbX48TG37SqHL133-L-2FBoUn1F6JnW-L29+GVqp8Z256mxIVKEEqwsU
yTSf-qLjkd369XhgC-qvtEC8Q4Ql0pTb0DdZ0Jaa-qt-FsI3Dsr6w4EwZN-r0AlZ2JA3IKni
GvINm8qMq34IfFTbaLBCFxZDSB+PyakdKvzckbqa+FOPsiqTCOjmwrNGrMrGWNb4lE--D+AO
VmXE7a+6dpBUC0Mi23R0sI1PVkp-dXs8BcTTnZZ9-qF487qh0z+N-RZkItNU7KF-5UPL6eLk
bVXkmgvUVuOefXBvMtTuHwx10Wt85zqtWJkpAEtsUkj7shR0pV3xmpW+AT5wPDdJn6kHzDAP
cO81cNQ+OX5oXalG05kVK9017MedjPHIBfpHH67VF5LNp+5OZcGaDD1x6k9Anwq7IfRhLhhp
7hGdVH5Cnw+0aNwnhwVRaJuM-M0T4F6xNQ-4piQyMk00s4oDQ-c+HoevCM1jUTWJDca8AIBx
hMMEOljP3gVpzu5VKDqtcrSvJbtoGxu8K2zdMH8747xdV4CmPn72hWXW7qRT6LZ0G0llCRQR
iXCRbs49Y9CyWZcGSURwcJ25H4Y8FgAMwBO-9ZdMJZpj8x9rPIbYcb5Tx1Gj9SViP9b7HKcf
fpZmmzOFW8aVylSjUnvMGCgSz2S29ByEoUMlAoGPpk6l5gy+fm3wVPr3WUBBC7715EWsOd7j
whEwXIQ12X0YXAzN9SVZs4rjH-Bi0D7IkJy7ZlKfz80Ar9F6+DN4T7ShpH4cdo8IYN4MSJmn
O5d4Zo+k7SgZK38gyFYw-wI17VPFDsh8VamjuJc0a6oMpqD1G9SELpK6ufvhCDiRUmwS7AsB
RkDviJ0u-OsBRgmr53durUC6EjDy4y+if5NaMVtUEslsobbuhIZELGRP0uGDUJGw3bGXyHQ3
QskvNIxNOC8RFG1iLpiYihj9kk2Womd+yqHAm4FMT-vHI8JJ6ZwEql0k6UvTp4BR4HMWGq1b
3zkLihN6EUmgMOMAAz4zKXiEgG1ED4lh4pDt2D7uoK8CvH8Nhb4D4fuUGNo5TSZHE21VVrAd
1mm6-qPY5A0bFA7i2jG0k4Z+JDgdOiBnNd6kNUbXMZFKUCk0mnBJyzL4dgU5fJ27p93dJ8Bl
x7SRjdv0WhaoV1AnuC4F0AA5gN4dAup6lNKBUHf3IsBBtjImRgB+ufaUtuWbo2JAGHV2I7MF
Xm9OcR4dVGxgfbxfqYu2-lLiHQCzMd0oXgWsudABV6JWaoUUb3v894r15fZh0gegPWm2cyU3
v5L2uf4O1gsmWK0Amf3oB1mNpevcRSxRwOEsgUy4OaQOJDz8xJeqS-KHa1I1ES3EyNENdggA
g926O1O1bNt8kK2j71GJBLBEZWnljELeM3UuJDabNp19q4TBF0gj4esSWeCfjU5siJJjTRId
B9ls05L9NmG2VyNkaKGJ6jyI1NVg5G0x61IKjWSpLj6D3NF1UYKRfcLO+URubgNMCf-lYMNP
oupcK8SUXxTjCkGehVDgGXGV7SoJjMnQGoPBEXwZEmAWcPGj9Lcgd8s3uPVlkbe9LmZI2aj1
8aAlHv1P-7HWb+ewRu7B2J8pouM57RKvegmDJd1OBW2lg83gKtwQDCa06wpJm+lMh4qIf+YK
8Odw8tkxiINacex60k-MEWd8nB+OJK+0oMcQsQprsZEjShdEp6bd5nT8PVxOnGNs0PIFB0Gl
EiYWH6EN+Fga5YLo-BR2x8VTHwKFJSW-ec5I77v8xcJnTrGKb4yeNnPmAU7s+fRE094mHHEz
Rde3KsU6pO0Fx4OFa8chIroat+lVktXxPknN3ygYEBcRNSOUY-rq9EES+dHqP-gnFm6wf97g
vLBHPnjMFHrOfejPkU2Q4ojFqRVScUvjAxKKDl6xkFaHnh60L8LsX4c5YIIo+PM5rJRcgWUB
iHUgVn33HkX4F11a+Wpc6JEBxw3Zbd6e5dkt+X6ZvI5D9R-tqPFPDYFYWx1zYbYTSmiZ4t4v
-kszylu7xG3C-dJb6O4y1syAY9Ve5CES4QqIZ9wAQFnQMT-ZDvOsRiL2qvZS8MlJyfaevGYg
5VH5qkvVNhoeGhG+JDO0iRF6KAzGv63R949aMz3j21yGss0i3Jo9yINIlJ+8mN1174RFsQSu
aJPZvZn8tIPbMDhBRRqKV7HeTarF+3G6-EPQ0VeUm2+dflQ02jpCu3Ftr3RGB2SeHHNWf-C0
+CEuMwV2WA1DW32sF20fmZTqGAD+pgCQAjYRX0+8Z5yp1Z7dpJwK9TuidlVKqRF6ijVJ6I1U
Vw09gSxFxCIveONcgvOoxH7r+0+lM+w+0EYaVjIWtE2h5EfqJ0Uo7TyNfA23ylzW8Sd907-X
x48DX-PM9-n8RoiWLmWYT90lcPOzrTwcqzoMQnAz+lVxCCs3Kok7MlXhBVIWQ0+y02Cq50V0
ZML9TOcky-fCE8c4CG8A-PU9H-cLq18KUjPKoBmeGPOmuuejbPPrWoszcpjqfZHkyOvtyo7C
+zWxlqyJ1aCz4-0e5-HGSkKM7SEGuuVV0eEepJCBtZ9tXBYCPP-p8l7kG6FO-F+33Fk-gEw8
5JFOiRdeQ8Y6c4hIjgMYLfKYa8732+3RKlFlxqXJfqH3TqShj5MHolYfxNf2Jz6+6qZ3M7oU
HfJidA+MHN5DrKV7R3jKuGiE88EnutbmmgbboBFIHOuWK0yvnRb8XBD4pWuiq-bfnsqzh381
uMikMz0V+YkEaGrv8owZCYIIGhFMkT4SYMc6InQJOchIod+75qESblN8sStNArRPJUJLzOvc
R6JTh+FRVl+WBbiAA1sSjfAhniv6wBLFAWF2427qe5-7dKQ5ArYWBHpUC7ZJDtS6QFE-MfVP
Nvbjb7O8f81y+TSW3-x7YreBnPsd8erM59fhb-6TDPTsSTaUOdDtPCpU1rXoJM8890Zx6iAU
Sdx4H2CGhAChcBxJcFJ5fr4XOJn1daCVNO3hSIwX-uJEYAUVZhreufIRrvKZwPQ7EI6zBx+4
TfVzRhN8i6z-bdlmsF1oRjJAhpfV9Er7msMIEO19JA7rvsZTgs2cFwZOaxEaL0-kPwYo9nch
wuvKwQhkGH7u6+xx0NYlZGYu65rV3MxwmnECm5idt886blFpm4lQMmonvM2pqDhjfRpytwma
SYZ+BnPP9-e0guj5RGeNdGKrLTpmq360fFCu787OSbE8KuIo-1U7a-82wzBCVs0q5aFhnCWW
zB8RLK2oWxbfOGYBXerkBf+R3s9PPGhhciYGwxqj-3j4UIPjULFwWzSB78vVbq+6w5W7qkR8
QhysIq4+RO2Q4eA0uP8m94XghvNkW7MGCf6LpaAxTo1bOR7rnTNz7FnHwNDZH-WOURHGjx66
MSzcx+GAUsK34OkU4M3NJMKgpGFc77oL0d7Nvdq4igl+VJ3nm0nKSylGq6oUh-T8Rt-LTXaO
mGMxliu35Au0vQeY3Ww3iVkcdU2D8-Wl-BaZzA6750r0dpkc0llgSrNjZOVk7mSzK8qW9P33
Lm2nZ-cbrNKDheukh-SywijUbFV268JcZIiMGAdDopFZ-OxWwrFcsqI39LRqrwFIMDXDCRC4
xo7QEcdHgUE5YULhZVMq9p3GjHgcFLPg3k4R+53209wUaBEbtAAisomw44-3peiFrMH8brJd
hZdjoqivHXch2INx79ThrXc2FKQO-LpVAzNRhpB+S5jr9i3WfuEjfFpx+JD-s2yBJCPA6PTA
AE2zEstB8IphytVPwJhnv7nwh5DNZ498PZWRPAOpOvthJ2uDKCaUSoI9kQH-domo4C3-+Z1D
aUeT3OAYnwT0CXTND4wD8CZh9BWYpB9WMPSEiB-rPaGreeaJ3GVLPBoq8OdlOCBp0xsquLog
tuYM9JsGIkTA6QnQhPE-vtzNSDpKFpDeWIcCa9XKABWcZmPVswt76XvrnVs-wvk7DImnk2Kb
tQAC7P3pQOaDwmb8aekwNR8-r18s8xDGBHIjjrAFKR2EUmJr3nNnxEmfP+vuhfhS2ozQoM2J
1e3G0j8qcEGoCLpjnHl6+0YX-zk6NnUjS4M+4RqBZAYS47g+3tosoD4mP2+idORb+1uT0QzW
61F4dvwuYRgfHJFiVIptjvKY32fyaksvfV6bBkXNmmX0vkDg+3oW9R3AFvOp1AvQT4jqNROY
t6JEjSptC9QIg+B-R+1MFRP+XCvzRGQDqtOqKZ7n1uubgnZusRWeN2xCLd61TCEYes-YOvMX
2aQh75xYOEr2Cl-VYgkQ54NTKBexN0dtaeyzRai9ABEcNzvS2LOkCCwqIb3H3LXrwf28qvDC
mWuTwAE67oC8lwmrx3+k2B6Lk4GYRMZbs2q7D892mOFfIpZvQ8hiIEnPLOxkg8GEg7sNNScR
947odlOwOLxqUxtqiUdRw01b8nbwW8WJf-g90uKjtkEFaE4A3tuAUBFc9lVXzuYBf6VAexQc
aXuESx3HfEZeq6nrj3AUnllhNIlBHRKqg4nijqwLwE4lDksoiMOQ3N8X-UAN0kcpH2A7R-hl
219w2k7KbNMx4pHRih-2SX1mPpJVqG8kZRmvdEJrSXdzR13J+v2Rh24to4DRq59K3xwu6+U+
NN1Xn5kxokkB9NIGs+VUmgDedVkwkQ9KrV5bPH4fICjfXZ9vssBYNmHVNJzN-pEtDKy2Y13F
MmA5bJZw3XjIN5tiCfTeohEQr9Z84hULtx0zggbDAYptRUqXguokhgXXuosNF9qhv6mQHgXF
mP8kcPoj7lnkhIw0su3S3RhNJpfbiKmxAuz4LVQ34zJO4CRSEznGdECJ7JFThFvjSNRTXMMD
0JHvWhYBx5k3boUGQakS+QZeiVtcG4c2MBLal2vuONrchulKrQjarGDtAnQiChWwqpPRQkP8
ddjxMLCyc5+Clp9cI+vg0wXC0CJ62XYyGOcUdv5CqhfhutMmhJIWyHi9IRytzJE0Nd2dh33I
fiDajXZooXH5QLOdtkh8PZyCad11uJVu6i438Dp6pNziPmiR3LjPYr8E2Rkqyh4EDeeGu5OS
WJwiBGDXa97oMnShf5MRmjoXDhCZ1LdR9ME47d1xgO2tVY7SpJHsC0S2KgZV3Ye5HT-2PNeA
EU9JdV99lve2iRSIVREMD2YLD+F0670vVdkaDjb0bX7dqgvWRamNIQremxa3VMXKG51UeJ2w
N25qd+FJyDvQ2aKBlI3QK8TFWcuB-5MIqwvNRbMC+Vxs60mLd3l-l+SG9plM3zQ5lh+z6Lv4
MzgHsiKTRhvCDiRfT4vYRPlISxSSddZV6Fcc9-9NQ3248SY4MDJXuvaKkYkHZX5N8Sfo1VPm
JMBYf-WEHcsezNkQOVFSlS78XHmKqfJegW79zu14wmJP1Lyug6Anxf4n1nRcbJ+VTxiLYGTw
l9AqtIFGLwu3Md+s28YMWKMLYbJ1BC+kpssIVsYgpeJ0vR90R515G5nBsbz-dfe0fABk4kWe
ZKMhtSYUaNb+-AqtJ7e7OaSgDMzdntpEyRC5wr58Yod78l+zAW0vVxN-YXKd8MqsBEpbB0QL
JTe+P1K4jVLGVY9w52lqo7DFAlGFRQQjo1BdzI0g0fFV9pusP8UO8Z9Ppc1iCbBmofKJtqLb
BNqCYLZQQJxEmW5RKSM+2oQ27BERYbboqIs2IK4N5QUOtEMI69exNvHd7aDtGsv7MT2GB41o
IcE8cUUzPHEZOo-rlK3HhlSR0DuuJRNfDG9b7wWE9bwdExzNPRUqKw673BptCCT6csWU6kBl
cFdc11nsRzIJW4xNK1-IX6ceg01lYToyu8Eru3nWP6Lp-AFzJ+MiXa7MAAzmNsc5D7SIdCJW
IAdSqsAL5cVCNvUvzPDgj3FwL2huQhPhc8y5xY6xx7FEabZFTreVa6QzmJYef1Igk+fWOGfM
ZsEoFtuDWZsPxWUccvHcuoF6S7Za8ciPiqr1kl4Ambeyrn5bOcmIIspRclvuxkT4Oahbo4PO
***** END OF BLOCK 3 *****



*XX3402-020714-120996--72--85-14088------IMAGES.ZIP--4-OF--5
eIFmQZWZJ92MG5ma94+hOMLgcJwfFdmhdzy3J5QmaSFA83ieCvLbiydlFd66c0WEHeIvufMx
xfAGODSeMQuNHdRUKyhZ--a0gRMTK2uucWfkrRubpa5-ed7qUiy5IWPPa0Qyxc4QYli0U1KI
MAq63FvF7UhJKst7eFdkb+ZNdbPHRVhRRm7qppONxVLqtjab3BRWs5oWCyn9sPp4aVR-QnDn
fm7diyRKXgn+bagoobB-x0VY6nZ5kZAc-NevoDE4hcJZn+uFgCk+JHfShtttjzJqvv4Lvkjv
+81nzXYST2pTtzAGXxpva+ltXzvPvjqhpkHzQffbpfQCOW-YyztbZYUhdp4li7ek1cWC8WpK
yLdyclOsiRJ04+h4dpF1arzewP5hEOPGst-ed59F282QOgE7kEOy9ypYC51yTc55fVasjcSj
jyewNinbzhUKsbgN1naKotylCJwOWrXrGqIBI112reDs2l0PwSJjWWmgHoUPUhIMX8EMF1t6
z5GVf7p90TAIxcTvZjeTZSNvioDD+TyOxtSRmLH4yNTBFvhuHjeOVMYHNWHhPuKkn80qPrR+
1UiK32HCFN9UJxlOiCAlweC6LOLMEBWURKNP80laR8jcl+p7L0xhqzDPrg2CkhiwPqQ+oktF
8VhFshyZ3PLfXcXdu3y0KGC9qVQtkZAiDkDUUJcvLrV7Acayd4vxUNiA88hcwM+Zi+V7CVEZ
Pme1Xb2YnPx2WxciNRCotxApgSZOtr9l5c8zgrjUpbbLIO0TZmbHPTvMJ0DOFYex7oliVFI4
OaHchEdF2f24ad4KTHZhKrUnQUlyEJdTnDvOhP-s0JVh3K5E8jwncKyuYtapnJmFI7pAwNsz
vFnygXaxugotvB0WPW6vVQGbZ1ES7g7BIEe1YHB-7TuHUwc2CNGxsZEMlP93o3MpLONcMvdb
KYxox8naA4nJzrNf5ea7qf3GvBRKVAnNg36SbA8X6rf12IweAidpe9hmRXPRg3WmHsZU0173
5noEHmLbVEOGB1gE+qrEW6FGlTJAYkbSGrb-NHNvNVfqFBsf9OjTakTMdfh3F5OeWWb5bzRh
DspM7K3l1TeSS+AlhK8hF6vuYeiG11mEWZP-BVRdLqIQ8HX8CooDd9NVxbZKR2eVvYlYCzmK
jxbq+mYlLYx12oCbT0IeMqZ9O6K2MK6xlN9oBRcLoyb7H9tUw5UGfNw7q43HRriU+b4KPOMW
zPovdizJ6xDClpL5Lr4D0l3TNonOxy4TzfZ1v+Q28YTjxspOZs58dcFT+XoGRly6PYe6vxhv
C11npgLL06gguBmaqFcMhbqAyuYEhMFkwAf09jM2lI94qx2e1j5tFmnvpadUyrfnoLzp9Vea
JiHfCTbWdLESFaB+HFbxnnVsWMf3waV7I86VyKS8GCWnVwxWTVcZJ-MBrqRHA5TiRdoXZumk
r0jwkZBirzzzNvGnXsQnQdzwJuzhJtCq8b08X7lBtquGM2x+vngt1qF8kdOHm39bB-06Hzu3
THCl-diJbhu+YVsGy4kRdlTh0SLLqdJofuEKXYs5tQOh9YnxpYtAmUgwjrsoCrtayzuzqLDu
w8IXWPtp1nVmaUj4i9tEdCG2GRzcmP+XRkW47CwkrwV9EeBaYXKK833Etetc1dJppcLBgxbi
+NWZgWPbSMb2B6CwSDzmYHbzHWNarZitAVotOvOYSpsEflt8p-CK2YCDp2AHH+oYcip9qcJN
WJfj-GyltOAvKre0+QnWIDk3KZ2qBlSCGOL5RMWBNBDmPORPhKWttRiCzCb-TEyhjvWqbtic
STEcbD-djHAZ9Jq10AKkFY9j4QW4eG08Rn1-Ke2fUUi3J05mBO4YyLbac-w3UsbLNiaZ3P3q
CLwIvTqMHLjy8BOy2c5vW1pfKodrQiQLiLi3XM+YBNSIlEGTMIAywvKt0bAFB3GxYIKL5HTk
m2B43OSsu9IMIaLoR7GL6ZaaqsqUU2jPLeWJbJ0CDy2h4+HjEId8IFN98g1mE6-je9ASLG1q
2l8zvtl9RKjOjCeakm3lMZx7rsMYU+wCmvZeutqLHHbHRROvy0vnPN2Y34ev-9lQC1qaK5Dk
jcGz3Tiyc6pFNaB3Rli5ehhGNMwAEK5WucBXoR2NyZMqPTQUVif29AuDuTteT37vnL4fj3UY
vgX6IQCownOVxjiT8dpPHe0Jn7MQATObFKdFjjuqNEDdQIFuZeloLBhv99J5NJkrKTEPOxn8
He-SDDFPJszgbthNPMbliU6XCKJM621dHj6Zb-dsAaOPvyhtms2hyvBHFacNFB-SxBemCFPM
bKL3ejZJtmNHEb-ewfy5Civw0ruiDn7YihVvRvQPCR14u51vUccdvCxz6eALqfBjIpgCKBA5
U44du2fyhRn0et5+XXErHLxJVo3tyR0PrirgUJBZNnev-uDZPAcDYg-q5jPYjwDCAfIM-JfL
8PtSinYo+yQAI-7F-QhVVuK6aeBuk88icvKodq7IPJRWqJEbh-Ptkh4l5ir-fihBv+Nws4fQ
q9RBwaqCgHKz2e36lV0s26rvIkESQg5DDiobOe+m3FS93+1Q6rSkDPBOgntrr7Klr68m2rBj
api6DNPwXnU9wnCydBI+opP5vUItYBDTxMbF8Eq0Hk20xHxZX31qTQ43vrVy0e95l-sjYGsm
h-Ix27JBtSVjjAODgitjvF9yWG5zX6qlovv9+YxWM6bbyqefDIZj0U4u3MGXLaHA7awGXEjL
OdU7OAENSrfZ+BT1FLAzbEMhjSxa3rfMK5i6YE9pRciNpuDSC9-r9GhxKs8Ig6xNVFs5aQXt
WajLahI9orbeuir5n4rfXzOYt6PNxBdtZThhkngcvT9euFwOJ-cFAmrLmeVQ+siYUE37pETk
GlNt6ZU6XlTbySEErIBKi2A6WeAv5SY5ipxu12QvwkTroRVI9dQ9GebsT0daTe04rTWTkaVy
NUOTIMvCKNp8MGeni-1rH+uQSD3eiZ0Rm9TB9SbI1p9axwqgbxhvFwE0FTVP7ibGqK5NbLqP
EXem+s65v1VMDj2WYXUJZtKnD5ffISXQsPNnnuCWQnlJay0KHTLrsM3r2cJMT7NmJeeuqms6
1i6HjPQ6Gx818Nfrq7yAbcSnIqLx5VDPiU4KctXUe4lMZbfKYHiPtPaZlfncxWdpuPBFLp5K
UIpSykd3-uno14n3l+c14JZ-DqLYNnKMAVWZvN4+6nx0DoPkid3nmxPPDiVSg8OWorTK-ZJr
ieeFwWWEwki-E+NIy9N+PTZDFblga2lnx-80aV83gZ4EVW1JMnGF9f-q5YNAwExhGTVhilXq
G4BTcWBR-4Anrc2Kdsk3fNHPV9f758+yCqU08HknA2hxraXf7jeOJQmYQkT3vgqhnD3Fwqzl
s3G0hYXTuG8xtaZVSUuvdvQko9jCe6pWCXzsF4kJXqb5F4C2tNEes-y516HryG6YSEpFjLKq
ClSKayP4ZuJ3+DQD7OFc5BFQaxUYc-4fsIgidvJO-kkd5XC+BAOGl2bdhexbOy1TgijqW7CL
Qe8OOp7cBOC9SMK-Ge8xMSL+uYcUyFNH339B-OECkZHjX8TrndFk-VpCOTQ+zyyg5fPbPIbV
RDikxJdGz7uWMa89yUCPKsk49Nkbl-Mq4EOei63WgVkgYvkSq8jRQmNTRuXCdfb5MHjlPSDi
B1+QO3LFwX+0jMCRG45T9jL+Mcq8+Iia6lYPvn2KL1KbXcZDjeAxCf1VsuD+oEj-Ehj0Vyaw
XovnjrgvZsaSSw9DJK2nYi3Xb6KhL52Jg0GUC-Iqk5L5LKgG4EYm60mgyu91obZdsO8qJpVD
OLjxAz1EOkh3R4CdcjBS5LGfSJK+Fa9m2MbQmIohFunSVYOF618mSCetr-V6VyjQ6+ctr+jS
10rE7LXN6MkKPOb7afcr5lZp3k7u52PxzAX9LhGXRylPRV-fFFXsJUt-6uyBL18d9MOwqJGY
fFM00IYaBl9cASjSqxT35RwrMPepErT0jjw+uH3B+BIRuAsCweLYrvpcM6wwMX5x-C0anxBW
Hm6VizoRuyGF7AEbv+V-poH2iuud+SRhJ7YmlxqvoPLYpzihF5gPemV8dDw6k95vApOoP+tA
EJjfIOa1Md24u6UaPn1WUT9gkE9ROFiRUgxUh1UizTUah8JNAf7YvBZp7zZyyw-MaaB9Zjzy
Ho+mTqfIzsi36+noTCFGFRBbyqMMMso96HJCsuw832DWjVmam7R6SFmlR8S4WlKHTd+4okt4
M0rVkEvmmd9RDw-SihhjPA4ezA+g3AowsLEfrVp6Qz6-nwAXBgD4D5oGDwLkHraPjMWbyMrY
J1eNZlm869kiGGwjPBDRJQxoXrUcCcTYibCHKtPM7I8unPsb0WpZD1EqMfJC0tsT8-j7PbAt
oRgD3zBY7kkc+XMIkJ-Cs14yQojruUddccHxQBYS4OvrlRPEnbHx-WKKksyImu-Hso4P6tPV
MjM0VsJoVANUwGpsRUTsc2w8ZZ3tDwV+PiC3XqHDvI2ZvZ-ORl09XCtJtrmEBXsUTxOidjF4
ZU-DCKJAbOQbwLwEts9H1o6EWz2P-X+GBD82QM2EurUeM3tOP9WkBkxmRxQiCjQ7VKaGacQU
nkIexG+-sp7zFpMkHtv5lCEkOXGHHlRbFZUa+cXFo6vot1acoIaqPIzGuDfdcahSpFHwM0xT
BzzPSbzv3xxSzRzkDeyiOqxNSvbbtFAjLrYtPwThJFCjKbZJ9SyMSDI8vyBLSdCVhlduxL1c
1MSHsL+p5BP1gHQQHsPXpL-Q1qTSQ1MNnZP1KHpQSgDZN9VQ1NTpADS4yKGMfsNtDOmwMHIN
JehVJKBokrcmf3T1iiMkjQbMKsqxSXnolgD7S9UO1yjlq-iD7yDlOXmilnBjD7iANujlf-sj
jT3mAZuilghub5jXT19CJyCw5ZTSi7eAexKseX5XQHoNpuhlLLDeraHafKNSDFhugy3YBZnB
VjJgvAr4YxZsBFjLgtYraopagxJgJgyKraktaGpLgqIxmvpNDdbZepZSnmdjJYpapKdKpJX3
KHqNpOhNLGwxPyZBZhteuRL9cPQQHdP1pL7M9wTSQXlNXZT9QPqQSQjNN1ZP9KTpQiYhZtDZ
QfJQpgjQKyOHNPtOtjKmwdPJN3ahZZKxtCNAZjJeKRTQ6ayGSujQezCVZkwbyL0J1yhwvCLX
GHtStSAubrbtP79DJjagndRSjdnYmpKyfDDQmzB7bezmjAsf9uwaSPL8elevbRSHj3vZRQph
xmOJhuewiVdupL-G1JTJg8v4LXKSJCBJBOufaJTB7hJgJQreOiZJmoapL3L9igex8dxIyOf8
uufmeadGJOieeW3-JHqduZJ3CFBdwZOp03AxbBH1JGoPLswbxLVJmmPJgoYxKxKmcDJmIWxL
hImynWRpjedZc5IpeOgJjpryeygJjjvz+J-9+kEI++6+0++tbWcVGsjzgR+5++-f6U++1+++
+3F7J2l3I2R39Z-1KCpODqwQhl8bU+gE-+yskcJ9sr03Q5-lVEcLJxX+3jc+JuVkeH9ZTc+f
z-5w+Jmsp+Ssoj1iYbjvtouGfGEjYE5NZioI1Z9YTq6tn5+st77vpBr71Vvmw7uo+t6nt6z1
sL-6XTrN7piTAjWtjNKnCpgnVXw5wAgC1bHhM+zcM2zxGDXRYp7WHG8lfHhPv0ByHVbjN0l-
Gc4MuAmlmP3tWCkAqZa5+pL6tto2uUboJJFWaJV8gSEYpx+0uAXKCK9eDaOQu-mnPu0KUmFZ
OIRxnNUNo-lMvXlafXbVQsSbqUgOezjegEGJsWGuqu3HPxFjqUfW8Oca93XS6RicCEjG6EbE
MWDRgYuXaXjOx2lO8aqW6U+W8izI9HpHisR8dVSzKXy+mJ-BjZN-PcQ7qB74APGzg5A2n0RO
uVjQROedfSKK7lmxH9rFqz4UFfKEHvJQPz2FyVbnNVhgPe-PcyidRpu0lrJ-ytEFJPUTb5XB
b7mUIioVzfOOIyqq4oxpHurKGxdTTiLupmnhpY00pI+d2aRn6BLCg3p0KJ7RmItMqcD3xG1i
***** END OF BLOCK 4 *****



*XX3402-020714-120996--72--85-33614------IMAGES.ZIP--5-OF--5
x+uVLa7RwtujESFE4YFRBsUE2bc38rhn-p5lLXW6OTSEmd9cY3+87c+AShe3APo22HDI0wN1
LE-dzggpe88PKJFRBuWY4bHrE63xjUMnvo7QvQu+2WlpKyDa0+emLYJZUaLSSvI4BSr0tkBP
ZgMK3hD53frL1bPJnHpgrMOBGhfMaeKlCFdV4Njrren3VbpEWedeFWKlEbfbu44exDICqmHJ
FgVNWPXI1BYOiU-hMiQIRglshOcv5Z2sUB+3jKD76stccNK1aM3raJAWeCrvfrMpUOSVeMiU
5lzVraHS1--ej-ZIqwmUnhSAHUWQxVsKvcHuy7JsfBHGNqm4YtJY-Yt5PcNp5nl1w-8RK7-x
i-Aa4ZEJ1VMCeUcw9ef+Q83FCFd3K9Qne6dzxZ4VI96b9Ba4W9kB7UEGE+YGF52cCQX2RcMw
gJpGKwYtxIilbyNZ3Yjn71iW4JVm+G6U1dE-eLM778Wi89z6g2zhw+GBASoNZe+fC+PC0FxQ
A11JmJKaQijfdoj68hZqQA9hlxuAUaM1Km4tAnKwmqQ-l2nDka4KMtkZ1uvcwELM+6mKsLm0
tX1ho-laTxDqAZ620opW+AkWquNnyOgKZJuuKKM7NhM8H7FM7C5IrQoGFBeYKK+qrkqzMD70
LXmyYCnvXJe5o5eyp58DnXBKk52hs9OgwFsibDS1ii5VFiV8xV7vJbEXp2+3Zg7t0kXUOTlb
xjXfAgS6ZY5gnGV4BzRxGLn7naWYQ2M94khBjPbHGy8j4dZptwsBPiOHvAoZ6st+gwezbIgA
zAc6fs79ew-YCNX7irN9XCot15fVKOs0863Zux82BvQpLa5FjfE4wqv0MwxS0oTzflmPaNji
WKSXlOKKPSukNQgiKZNB5QLApP4wYwocpqCO2NLbAEjm3CttMbC7n8obTglJwRxLzwJSoQpd
IfMisAkxVFqfORTAzhFkpNyU2xLR5pOCDcOfT6PYXWv-MofQez-cxOtKdyc9EAbE1rGNSmUd
wcudJ9lrv3ToGcui97PEIiypooPXuDSBjsPFn5BLXHUVztmpYBpLrRy9penoBrpMnJhqTYKc
2YD2XwgkiTAGzK+MEyK4ACv0TYQHQSmRqpTUJMqxXB6wqhiCA5DymUUvkacoroZbxB1C9rLG
DkWvgC36up-UDBM5dcEXBgBrg5hMJcrwBlrI-EMnBR6xdDyAY5C4iF-V2laOCCF0V7SsA-bD
oYZJIXt2rulbHZNYFgaHn2Y0pIuq7eKgNI679NAgAgYTmJtT2H5lgsA4BBRN6i3UuakShrWu
fRB0TaMKc2dIJ5JDYRMhBKjZgsHBiNaINxvYfGHvRgoe8RSLLN7qanitg-E-jrBqB9BUnP9e
3KW3xEHRHeq8zsHfQ4uj6VJxXiUI3FU-x7IsdmR1ELpy0ckevIBKo3JM9MpuFp52F7KjbIVV
bY3iZB3d7lJRR7zrEEHSSbutISye01dubR+nHqRui2oRj3yt+jLMDRlUx-kTfwRobOXLPfoo
Gc+h-DPvCHV8DLjBPODkaxnFwgWkhZyGfFg2bG4mrrdnTIKm2wQFlBIUEbja2gF9hAVuusTw
NpAYrrwfh2vZNJtGcd+TyqRaXfRHgK9ozxe1ynxPztDJ+v1t+4kDNHq+DuA5GWO0gUdZ4QfG
+LUXw1ERMdxodJmED0ItjAc4Q+c5yET78xF9mmjgswxT1G0G1V9Ijw6yfav5JeOkTRYH7b-g
G8QDYxI1i9y-OaiDmqEtmN9zymXJzrLZTpdbvDfpuzpyTnUQXYOXrRrRwLWwjvwTlz4xSzTi
rvzzwC51uLFOJRLtyHbqJxy2mIQA4j+xYakWKOGsIGBki45-N06THCGXWHmPG8ayAnZt70QD
KU854lNAdn8TmhCdT1iJIbpjtTFIHjCKkC44-Mn3BpUwMj2SWqDpvQJg39APgGxki45-O-Hj
Xi8xIPkzWaDpvQSXjLWoql6sr9-UD6vjXiDxQTntC6vJxrYwrcz5Rpg0VlgKA-NRMp4TFHgg
WhGr2v3yl8t3jg1VVULxTbGn5yrocp2zWhErWjcvITxaGy-kks9VABcNFfS4oSpV38bjRXGw
3EprKU854lM2ztw5yCRTI2g-+VE+3++0++U+yPmE6-4vt3cZ++++PU++++c++++++++++E+U
+++++++++23AGIJCAGt7HIREGk203++I++6+0++-jN+UX26TOmU+++-r++++0U+++++++++-
+0++++-B++++EIl7FIsm9YZBFp-9+E6I+-E++U+6+9CcZG0MJFQqJ++++4s-+++A++++++++
++++6++++7o+++-2FI32FpJNAGt7HIREGk203++I++6+0+0ae7IUEIjDS2c+++-t+E++0+++
+++++++-+0+++++P+E++FYZHG0t7HIREGk203++I++6+0++YONEUlM0bL72++++N0+++1+++
+++++++++0++++09+E++GJFHLpFJEogiGIp5I2g-+VE+3++0++U+A4aI66bkgQa3++++kkM+
++k++++++++++++U++++FU6++2lDJYJDEYJG9YZBFp-9+E6I+-E++U+6+BNcZ001u15N3+++
+1U++++9++++++++++2+6++++DI0++-BGJBHGIl39YZBFp-9+E6I+-E++U+6+AJcZ01SQooK
UE+++860+++8++++++++++++6++++161++-CHp7GGIIiGIp5I2g-+VE+3++0++U+09qE69bn
OdAM++++PU++++c++++++++++E+U++++qkA++3-AEJZ3IWt7HIREGk203++I++6+0+0oO7EU
Rcn-g2Y+++1t++++0E+++++++++-+0+++++P-+++IoV3FJ+iGIp5I2g-+VE+3++0++U+jKWI
6DGNoLmO++++kkM+++g++++++++++++U++++WkE++3R-HZFECH+iGIp5I2g-+VE+3++0++U+
NLb067AJ1eMx++++VU++++k++++++++++E+U++++HUI++2xGJYZAH2Il9YZBFp-9+E6I+-E+
+U+6+4dtkW0mw+CuBE+++7k++++A++++++++++2+6++++9I3++-DIZN7H2l3AWt7HIREGk20
3++I++6+0++YVg6UPMcjTZ6++++q+E++1++++++++++++0+++++I-U++F2J-F2FJEogiGIp5
I2g-+VE+3++0++U+-6L065VXWMlJ-U++yFM+++k++++++++++++U++++Y+M++17CF3F7J2l3
9Z-1K3-9+E6I+-E++U+6+9OR8W3eDuQAr1Q++4y++++8++++++++++++6+++++wB++-AJJF6
FJ6iI2BMI2g-+VE+3++0++U+CNse6Ii9zv5E-k++Om6+++k++++++++++++U++++2oI++3F7
J2l3I2R39Z-1K3-9-EM+++++2E+F+AQ1+++BHE++++++
***** END OF BLOCK 5 *****

