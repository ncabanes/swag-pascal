(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0184.PAS
  Description: Lawnmower Simulation Game
  Author: SCOTT TUNSTALL
  Date: 05-31-96  09:17
*)

{
======================================

The SUPER Advanced LawnMower Simulator
(C) 1994 Scott Tunstall


Original AMIGA Idea by Team 7.5

--------------------------------------

Just for a laugh... go mow the lawn! Includes probably the EASIEST
control method ever. And what's more the 2 player sequel has been
posted as well!!! Take a LOOK at the QUALITY! :)


Up till June 15th 1996 you can contact me at: CG93SAT@IBMRISC.DCT.AC.UK
No queries about lawnmowers please.


Command line params: The path to where your CGA.BGI is stored
will do nicely. If no params are passed C:\tp7\BGI is used as default.
Obviously your BGI may not be there!!!!


}


Uses Graph, Crt;


{$r-,v-,s-}

Procedure MowTheLawn;
Var Sprite: array[1..16] of string [16];
    SpriteLine: string[16];
    Pixel: byte;

    PathToDriver: string[80];
    GraphicsDriver: integer;
    GraphicsMode: integer;
    X,Y: byte;

    SpriteMemNeeded: word;
    SpritePointer: pointer;

    GrassX: word;
    GrassY: word;

    LawnMowerX: integer;
    LawnMowerY: integer;
    RealX: integer;

Begin
     sprite[1] :='0000000000111100';
     sprite[2] :='0000000011111100';
     sprite[3] :='0000000000111100';
     sprite[4] :='0000000000111100';
     sprite[5] :='0000000001111100';
     sprite[6] :='0000000011111100';
     sprite[7] :='0000000110111100';
     sprite[8] :='0000001100111100';
     sprite[9] :='0000011000111100';
     sprite[10]:='0000110001100110';
     sprite[11]:='0001110001100110';
     sprite[12]:='0011110011000110';
     sprite[13]:='0011110011000110';
     sprite[14]:='0111110011000110';
     sprite[15]:='0011110111001110';
     sprite[16]:='0000000000000000';

     GraphicsDriver:=CGA;
     GraphicsMode:=CGAC0;


     {
     CHANGE THE PATHTODRIVER VARIABLE
     }


     If ParamCount <>0 Then
        PathToDriver:=ParamStr(1)
     Else
         PathToDriver:='C:\TP7\BGI';

     InitGraph(GraphicsDriver, GraphicsMode,PathToDriver);

     If GraphResult = grOk Then
        Begin
        For y:=1 to 15 do
            For x:=1 to 15 do
                Begin
                SpriteLine:=sprite[y];
                Pixel:=Ord(SpriteLine[x])-48;
                If Pixel = 0 Then
                   PutPixel(x,y,0)
                else
                    PutPixel(x,y,3);
            End;

        SpriteMemNeeded:=ImageSize(1,1,16,16);
        GetMem(SpritePointer,SpriteMemNeeded);
        GetImage(1,1,16,16,SpritePointer^);

        {
        O.K. Now clear the screen!
        }

        SetGraphMode(CGAC0);

        SetColor(2);
        MoveTo(160,0);
        LineTo(120,30);
        LineTo(200,30);
        LineTo(160,0);

        MoveTo(120,30);
        LineTo(120,71);
        LineTo(200,71);
        LineTo(200,30);

        Rectangle(130,34,150,54);
        Rectangle(190,34,170,54);

        {
        Draw the sun
        }

        SetColor(3);
        Circle(60,20,15);

        {
        And now the grass !
        }

        SetColor(1);
        GrassY:=72;
        Repeat
              GrassX:=0;
              Repeat
                    OutTextXY(GrassX,GrassY,'▒');
                    Inc(GrassX,8);
              Until (GrassX >= GetMaxX);
              Inc(GrassY,8);
        Until (GrassY >= 200);


        {
        Now lets kick ass with the LawnMower Man!
        }

        {Position the man}


        LawnMowerY:=72;

        Repeat
              LawnMowerX:=(GetMaxX-15);
              Repeat
                    PutImage(LawnMowerX,LawnMowerY,SpritePointer^,AndPut);
                    PutImage(LawnMowerX,LawnMowerY,SpritePointer^,OrPut);

                    Repeat
                          Sound (120);
                          Delay(50);
                          NoSound;
                    Until keypressed;

                    Memw[$40:$1a]:=Memw[$40:$1c];

                    PutImage(LawnMowerX,LawnMowerY,SpritePointer^,XorPut);
                    Dec(LawnMowerX, 4);
                    RealX:=LawnMowerX+4;

              Until (RealX = 0);
              Inc(LawnMowerY,16);
        Until LawnMowerY >= 192;

        FreeMem(SpritePointer,SpriteMemNeeded);
        End
     Else
         Begin
         TextMode(CO80);
         Writeln('Cannot use the required BGI file (CGA.BGI) !');
         Writeln;
         Writeln('This can be corrected, however. What you do is');
         Writeln('run this program passing the PATH where CGA.BGI');
         Writeln('resides as a program parameter, for example:');
         Writeln;
         Writeln('MOWLAWN C:\TP7\BGI   <- TP7\BGI dir is DEFAULT!');
         Writeln;
         Writeln('I recommend that you create a batch file that');
         Writeln('automatically passes this parameter..');
         Writeln;
         Halt;
     End;
End;





Procedure IntroduceMe;
Var DoItAgain: boolean;
    Choice: char;

Begin
     TextMode(CO40);
     Repeat
          DoItAgain:=False;
          TextBackground(Green);
          TextColor(White);
          ClrScr;
          Gotoxy(6,1);
          Write('ADVANCED LAWNMOWER SIMULATOR');
          Gotoxy(9,2);
          Write('THE HOT, SEXY SEQUEL !');
          Gotoxy(5,7);
          Write('Programming by: Scott Tunstall');
          Gotoxy(5,11);
          TextColor(Red);
          Write('Please select your lawn mower:');
          GotoXY(5,13);
          Write('1: The Tunstall - ''O'' - Matic');
          GotoXY(5,15);
          Write('2: The Ramsay Virgin Mower 2000');
          GotoxY(5,17);
          Write('3: The Lay - Z Langa Lawn Cutter');
          GotoXY(5,19);
          Write('4: The Bassett Lawn Buster');

          GotoXY(2,23);
          TextColor(Blue);
          Write('WARNING! Extended playing of this game');
          GotoXY(2,24);
          Write('can make you irresistible to women !');

          memw[$40:$1a]:=memw[$40:$1c];
          Choice:= Readkey;

          Randomize;
          If Random(1)=1 Then
             Begin
             ClrScr;
             TextColor(Red);
             GotoXY(4,12);
             Write('I am sorry, but that mower is out');
             GotoXY(4,13);
             Write('of order.');
             Delay(3000);

             DoItAgain:=true;
          End;

     Until DoItAgain = False;


End;





Procedure RudeComment;
var Message: string[40];
    XPos: byte;

Begin
     TextMode(CO40);
     TextColor(White);
     textBackground(Blue);

     ClrScr;
     Case Random(10) of
     0:  Message:='A job well done, son. Here''s 50p';
     1:  Message:='Son, My gran could cut better !';
     2:  Message:='Does your maw know you''re here ?';
     3:  Message:='Do you drink meths at all ?';
     4:  Message:='Come in and meet my daughter, son!';
     5:  Message:='What kind of grass cutting is that ?';
     6:  Message:='Do you do hair dressing, young man ?';
     7:  Message:='You haven''t even cut half the lawn !';
     8:  Message:='Do you want to see my puppies ?';
     9:  Message:='That was the shittest cut I''ve seen !';
     10: Message:='I bet you drink Carling Black Label !';
     End;

     XPos:= (40 - Length(Message)) shr 1;

     gotoXY(XPos,12);
     Write(Message);

     Delay(3000);
End;




Procedure YouShouldntSeeThis; Assembler;
Asm
JMP @SoapyBubble

@SoapyBubble:
End;





Begin
     Randomize;

     Repeat
           YouShouldntSeeThis;
           IntroduceMe;
           MowTheLawn;
           RudeComment;
     Until False;
End.


