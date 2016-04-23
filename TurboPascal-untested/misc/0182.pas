{
========================================================

       EARTH INVADERS (Original LCD game by CGL 1982..)
       (I feel a copyright wangle coming on - NOT!)

--------------------------------------------------------

PC CONVERSION EXCLUSIVELY FOR SWAG, BY SCOTT TUNSTALL 1996
   (But why? ;) )

Reqs: Turbo Pascal 5.5 +
      CGA
      Good technique in chatting up women


==========

DISCLAIMER

----------

I (Scott Tunstall) am not responsible if this program causes any
damage to ANY hardware or software part of the computer system it
runs on or detriment to mental health caused (finding any bugs I
may have missed) OK?.

You can alter/delete or even ADD (if you're sad enough) new bits
to the program just as long as I am credited with the ORIGINAL
version. You are not permitted to distribute the original or
changed code for monetary gain however.



========

FORENOTE

--------

I was playing a hand held LCD game one saturday and it was actually
simple to play, yet quite addictive. Unusual for a hand held.

Anyway, being the sad idiot that I am, I decided to convert it to
Pascal, and give y' all a taste of the game. Hope you enjoy playing
it, I certainly almost did ! (in between debugging)



========

THE GAME

--------

Aliens appear on the screen, you must dig holes for them to fall in.
If an alien falls in you must bury it in the hole, but beware! If
an alien touches an alien in a hole it is helped out and will jump
at the human!!!

Maybe, I will write a two player version of this game. After the Bsc,
perhaps?.



Keys are (until I write a define key routine)

CTRL = Dig hole
ALT  = Fill hole in (to kill an alien you do this)

CURSOR UP    = Move up
CURSOR DOWN  = Move down
CURSOR LEFT  = Move left
CURSOR RIGHT = Move right


Err... your guy is represented by a 'x' and the aliens are all 's (until
I actually draw up some GFX! (Knowing me - NEVER!).

Hell, what do you want from me, SVGA? ;^)



=============

FOR YOU TO DO

-------------

Add a title screen
Better sound (even samples)
Check if all aliens are dead
2/3/4 player mode
A lager drinking section.... (please! I've always wanted to see a game
                              with this in it!)




=====

NOTES

-----

NewKbdInt (The Multiple key reader) is appended to the bottom of
this source so it can be compiled. I didn't write it - Lou Duchez
did. Credits to him....

}




uses crt, nwkbdint;     { Present in the SWAG }




{

All objects are mapped directly to the map,
no external data types are used to contain Aliens X,Y coordinates



0 = Empty
1 = Wall
2 = Human
3 = Quarter Dug Hole 1
4 = Half Dug Hole 2
5 = Three Quarter Dug Hole 3
6 = Fully Dug Hole

20..40 = Alien (In various stages of falling.. 40 = Not inhole)
}




const Empty               = 0;
      Wall                = 1;
      Human               = 2;
      QuarterDugHole      = 3;
      HalfDugHole         = 4;
      ThreeQuarterDugHole = 5;
      FullyDugHole        = 6;

      AlienFilledIn         = 19;
      AlienCompletelyBuried = 30;
      AlienBeginsClimbOut   = 36;
      AlienAlmostBuried     = 40;
      AlienHalfBuried       = 50;
      NormalAlien           = 70;
      AlienTripped          = NormalAlien-5;

      Amateur             = 1;
      Pro                 = 2;
      Kamikaze            = 3;  { Not implemented, Pro is hard enough! }

      UpKey               = 72;
      DownKey             = 80;
      LeftKey             = 75;
      RightKey            = 77;
      DigKey              = 29;
      FillKey             = 56;





var map         : array[1..7,1..5] of byte;    { Playfield }
    killedplayer  : boolean;
    SkillLevel  : byte;
    GameLevel   : byte;
    GameSpeed   : byte;
    AlienPause  : byte;


    HumanX, HumanY : byte;
    Currx,Curry : byte;





type AlienInfo      = record
     AlienState     : byte;
     AlienX, AlienY : byte;
     end;




{
The following values are written to the map, the values contained
may be:

0 = Empty
1 = Wall
2 = Human
3 = Quarter Dug Hole 1
4 = Half Dug Hole 2
5 = Three Quarter Dug Hole 3
6 = Fully Dug Hole

20 + = Reserved for aliens, see constants above


Therefore, if map[1,1] was 3 then that means a Quarter Dug hole
is at the top left of the map.

}










procedure initmap;
var x:byte;
    y:byte;

begin
     {
     Erase all of map. If you're sad enough, like me, then you
     could design small maps, or even extend 'em to fill the
     entire screen.
     }


     for y:=1 to 5 do
         for x:=1 to 7 do
         map[x,y]:=empty;

     {
     Set Walls
     }


     for x:=1 to 3 do
         begin
         map[x *2,2]:=Wall;
         map[x *2,4]:=Wall;
     end;

     {
     Determine game speed
     }

     case SkillLevel of
     Amateur  : GameSpeed:=6;
     Pro      : GameSpeed:=2;    { Life expectancy - 3 seconds }
     Kamikaze : GameSpeed:=1;    { Life expectancy - NIL! }
     end;

     AlienPause:=GameSpeed;


     {
     Now place aliens
     }



     for x:=1 to 3 do
         map[x*2,1]:=NormalAlien;

     if gamelevel > 1 then
        begin
        map[2,3]:=NormalAlien;
        map[6,3]:=NormalAlien;
     end;


     if gamelevel > 2 then
        map[4,3]:=NormalAlien;


     {
     Place human
     }

     HumanX:=4;
     HumanY:=5;

     map[HumanX,HumanY]:=Human;

end;





{ The following 2 procedures are NOT mine; they were written by
  Robert E. Swart and cut and pasted to this routine

  I modified these routines for my own use!
}



procedure Lines200;
    { Set 200 scanlines on VGA display }
    InLine(
      $B8/$01/$00/  {  mov   AX,$0001  }
      $CD/$10/      {  int   $10       }
      $B8/$00/$12/  {  mov   AX,$1200  }
      $B3/$30/      {  mov   BL,$30    }
      $CD/$10);     {  int   $10       }


    procedure Font8x16;
    { Set 8x16 VGA-font on VGA display }
    InLine(
      $B8/$01/$00/  {  mov   AX,$0001  }
      $CD/$10/      {  int   $10       }
      $B8/$14/$11/  {  mov   AX,$1114  }
      $B3/$00/      {  mov   BL,0      }
      $CD/$10);     {  int   $10       }







procedure SetCurPos(newx, newy: byte);
begin
     currx:=newx-1;             { Conv phys to log }
     curry:=newy-1;
end;



{ Faster than using the write command for only one char }

procedure text(TheChar: char; TheColour: byte);
begin
     memw[$b800: (curry * 80) + (currx SHL 1)]:=word (ord(TheChar)+(TheColour SHL 8));
end;








{
====================================================================

Draw the game screen.

Note: All of the aliens actually exist on map, they are not simply
sprites overlaid on the map during draw time, so in theory you could
fill the entire map with aliens.... Have fun!

--------------------------------------------------------------------
}



procedure DrawMap;
var x, y : byte;

begin
     for y:=1 to 5 do
         for x:=1 to 7 do
         begin
         SetCurPos(x,y);

         case map[x,y] of
         Empty               : text(' ', BLACK);
         Wall                : text('#', BLUE);
         Human               : text('x', RED);
AlienCompletelyBuried..
(AlienBeginsClimbOut-1)      : text(#1, random(7) OR 1);

AlienBeginsClimbout..
(NormalAlien-1)              : text(#1, GREEN);

         NormalAlien         : text(#2, GREEN);
         QuarterDugHole      : text('.',LIGHTGRAY);

         HalfDugHole,
         ThreeQuarterDugHole : text('o', LIGHTGRAY);
         FullyDugHole        : text('O',LIGHTGRAY);
         end;
     end;
end;







{
==============================================================

Free an alien that may be trapped at maybex, maybey on the map


--------------------------------------------------------------
}



Procedure ReleaseAlien(maybex, maybey: byte);
var TheObject: byte;

begin
     if (maybex > 0) and (maybex < 8) and (maybey > 0) and (maybey < 6) then
        begin
        theObject:=map[maybex, maybey];
        if (theObject> AlienFilledIn) And
           (theobject < NormalAlien) Then
           map[maybex, maybey]:=NormalAlien;
        end;
end;










procedure MoveAliens;
var AlienArray        : Array[1..10] of AlienInfo;
    x, y, TheObject   : byte;
    index             : byte;
    noblank           : boolean;
    NewDir,
    NewXp,
    NewYp,
    ObjectHit         : byte;


begin
     dec(AlienPause);
     if AlienPause = 0 Then

     { Find all aliens on the map, and remember where they
       are so they can be moved later.
     }


         Begin
         AlienPause:=GameSpeed;

         index:=1;
         For y:=1 to 5 do
             For x:=1 to 7 do
                 begin
                 TheObject:=map[x,y];
                 If (TheObject >=AlienCompletelyBuried) And
                    (TheObject <=NormalAlien) Then
                    With AlienArray[index] do
                    Begin
                    AlienState :=TheObject;
                    AlienX     :=x;
                    AlienY     :=y;
                    Inc(index);
                    End;

             end;


         { Now that an array of aliens has been built up,
           move em out! Also note x is being re-used. }

         for x:=(index-1) downto 1 do
         With AlienArray[x] do
             begin
             if AlienState = NormalAlien Then
                Begin

                { An alien can free it's trapped brother }

                releasealien(AlienX-1,AlienY);
                releasealien(AlienX+1,AlienY);
                releasealien(AlienX,AlienY-1);
                releasealien(AlienX,AlienY+1);

                {
                =============================

                Move alien in a direction

                -----------------------------
                }


                NewDir :=random(5)+1;
                NewXp  :=AlienX;
                NewYp  :=AlienY;

                case NewDir of
                1: if newxp <> 1 then dec(newxp);
                2: if newxp <> 7 then inc(newxp);
                3: if newyp <> 1 then dec(newyp);
                4: if newyp <> 5 then inc(newyp);
                5..6: if newyp < humany then         { A wee bit of AI :) }
                      inc(newyp)
                   else
                       if newyp > humany then
                          dec(newyp);

                end;


                {
                }


                noblank:=false;
                objecthit:=map[newxp,newyp];

                case objecthit of
                empty               : map[newxp, newyp]:=NormalAlien;
                human               : killedplayer:=true;
                QuarterDugHole      : map[newxp, newyp]:=AlienTripped;
                HalfDugHole         : map[newxp, newyp]:=AlienHalfBuried;
                ThreeQuarterDugHole : map[newxp, newyp]:=AlienAlmostBuried;
                FullyDugHole        : map[newxp, newyp]:=AlienCompletelyBuried;
                else
                    noblank:=true;
                end;

                {
                Noblank, when set FALSE means the alien has moved
                and the area where the alien was on the map shall be
                set empty.
                }


                if not noblank then
                   map[AlienX, AlienY]:=Empty;

                { I used this for debugging. I thought it was cos
                  the SWAG keyboard handler was dodgy, but it wasn't
                  - my code was !!! }

                { gotoxy(1,24); write (chr (random(128)+32)); }

                end
             else
                 If AlienState < NormalAlien Then
                    Begin
                    TheObject:=Map[AlienX, AlienY];
                    Inc(TheObject,1);
                    If TheObject > NormalAlien Then
                       TheObject:=NormalAlien;

                    Map[AlienX,AlienY]:=TheObject;
                    End;
             end;
         end;



end;







{
======================

Guess what this does ?

----------------------
}




Procedure DigHole(holex, holey: byte);
var TheObject: byte;

Begin


     TheObject:=Map[holex, holey];
     If TheObject = Empty Then
        Map[HoleX,Holey]:=QuarterDugHole
     Else
         If (TheObject >= QuarterDugHole)
         And (TheObject < FullyDugHole) Then
             Begin
             Sound(50);
             Delay(100);
             NoSound;
             Inc(Map[HoleX,HoleY]);
             End;
End;





{
==============================

FILL IN A HOLE / BURY AN ALIEN

------------------------------
}




Procedure FillHole(holex, holey:byte);
Var TheObject: byte;

Begin


     TheObject:=Map[Holex, Holey];
     If (TheObject >= QuarterDugHole) And (TheObject <= FullyDugHole) Then
        Begin
        Sound(20);
        Delay(100);
        NoSound;
        Dec(Map[HoleX, HoleY]);
        If Map[HoleX, HoleY] < QuarterDugHole Then
           Map[HoleX, HoleY]:=Empty;
        End
     Else
         If (TheObject >=AlienFilledIn) And
         (TheObject <= AlienBeginsClimbOut) Then
            Begin
            Sound(90);
            Delay(40);
            NoSound;
            Dec(Map[HoleX,HoleY],1);
            If Map[HoleX,HoleY] <= AlienFilledIn Then
               Map[HoleX,HoleY]:=Empty;
            End;
End;








{
=======================================

Try and move the human to a new square.

If he walks into an alien though....

---------------------------------------
}



Procedure TryMove(newx, newy: byte);
Var TheObject: byte;

Begin
     TheObject:=Map[NewX, NewY];
     If TheObject = Empty Then
        Begin
        Map[HumanX, HumanY]:=Empty;
        Map[NewX, NewY]:=Human;
        HumanX:=newx;
        HumanY:=newy;
        End
     Else
         If TheObject = NormalAlien Then
            killedplayer:=true;
End;









{
=====================

MOVE THE HUMAN AROUND

---------------------
}





Procedure MovePlayers;

var currpx, currpy     : byte;
    digging, burying : boolean;

Begin
     currpx:=humanx;
     currpy:=humany;

     digging:=false;
     burying:=false;

     if (keydown[DigKey]) then
        digging:=true
     else
         if (keydown[FillKey]) then
            burying:=true;


     if keydown[UpKey] and (currpy <>1) then
        begin
        if digging or burying then
           begin
           if digging then
              dighole(currpx, currpy-1)
           else
               fillhole(currpx, currpy-1);
           end
        else
            trymove(currpx,currpy-1);
        end
     else
         if keydown[DownKey] and (currpy <>5) then
            begin
            if digging or burying then
               begin
               if digging then
                  dighole(currpx, currpy+1)
               else
                   fillhole(currpx, currpy+1);
               end
            else
                trymove(currpx,currpy+1);
            end
         else
             if keydown[LeftKey] and (currpx <>1) then
                begin
                if digging or burying then
                   begin
                   if digging then
                      dighole(currpx-1, currpy)
                   else
                       fillhole(currpx-1, currpy);
                   end
                else
                    trymove(currpx-1,currpy);
                end
             else
                 if keydown[RightKey] and (currpx <>7) then
                    begin
                    if digging or burying then
                       begin
                       if digging then
                          dighole(currpx+1, currpy)
                       else
                           fillhole(currpx+1, currpy);
                       end
                    else
                        trymove(currpx+1,currpy);
                    end;
end;
















begin
     randomize;
     skilllevel:=amateur;
     gamelevel:=1;

     initmap;                   { Set map up }

     Lines200;
     Font8x16;

     hookkeyboardint;

     repeat
           drawmap;

           movealiens;
           moveplayers;
           delay(125);


     until keydown[1] or killedplayer ;
     textmode(CO80);

     unhookkeyboardint;
end.




{
If you actually play this game in it's unaltered state.. my commiserations! 
Contact address: CG93SAT@IBMRISC.DCT.AC.UK

What I'd like to see more of in the SWAG are humour games... the Amiga
has loads (cos it's a joke machine - just kidding, I own one too)

Remember to write that lager drinking sim now ;)  !!!
}

