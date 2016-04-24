(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0121.PAS
  Description: Calculate TRIG funcitons
  Author: ELLI LECHTMAN
  Date: 03-04-97  13:18
*)

{THIS PROGRAM SHOWS HOW YOU CAN CALCULATE THE 6 TRIG FUNCTIONS. I DID THIS
FOR A COMPUTER PROJECT AND THEREFORE PUT SOME GRAPHICS. THIS INCLUDES
A FADING UNIT FOR 640 X 480 X 16 COLOUR PCX FILES WHICH I CAN ALSO DISPLAY.
I HAVE CREATED A UNIT GAPP2 WHICH CONTAINS A LOT OF NEAT FUNCTIONS AND PROCS.

HAVE MANY OTHER NEAT GENERIC STUFF INCLUDING PLAYING HSC FILES IN BACKGROUND.
THIS IS AL DONE BY MYSELF ELLI LECHTMAN AND KEVIN EPSTEIN WHO IS AN EXPERT
DELPHI PROGRAMMER.

FOR MORE INTERESTING STUFF E - MAIL ME AT  ELLI@ICON.CO.ZA

ENJOY !!!!!}    





{$N+,E+,G+,F+,O+}
{$M 32768,0,655360}

{Compiler directives, are comments with a
          special syntax, and can be used wherever
          comments are allowed.}

PROGRAM Trig;
USES crt,graph,gapp2,screen_d;

{Constant used for the Do_Chan procedure which writes numbers next to the
graphic buttons.}

CONST Chan : ARRAY[1..7] OF Char = ('1','2','3','4','5','6','7');

{Variables used.}

VAR radians,cos_radians1,sIN_radians1,deg:real;
    place,i:INteger;

{Initializes Graphics mode.}

PROCEDURE DO_graph;
VAR gd,gm:INteger;
BEGIN
   gd:=detect;
   INitgraph(gd,gm,''); {Stick your bgi directory in here}
   IF GraphResult <> GrOk THEN
     BEGIN
          Clrscr;
          writeln('SomethINg wrong WITH Graphics');
          Writeln('Check INitlINe');
          Halt(1);
     END;
END;

{Function used to calculate n!.}

FUNCTION FacTOrial(number:INteger):extENDed;
VAR counter:INteger;
    TOtal:extENDed;
BEGIN
   TOtal:=1;
   counter:=0;
   FOR counter:=1 TO number DO TOtal:=TOtal*counter;
   FacTOrial:=TOtal;
END;

{Function used to calculate the the result of a base to the power.}

FUNCTION Exponent(base,power:real):extENDed;
VAR no,i:extENDed;
BEGIN
   no:=base;
   i:=1;
   WHILE i <= power-1 DO
   BEGIN
      no:=no * base;
      i:=i+1;
   END;
   Exponent:=no;
END;

{The Cos function.}

FUNCTION CosINe(rad:real;places:INteger):real;
VAR expo:INteger;
    str1,str2:STRING;
    Accurate:boolean;  {Accuracy to what user wants.}
    ans:real;
    j:INteger;
BEGIN
   expo:=2;
   ans:=1-(exponent(rad,expo)/facTOrial(expo));
   str(ans,str1);
   str1:=copy(str1,0,places+1);
   j:=1;
   Accurate:=false;
   WHILE NOT Accurate DO
   BEGIN
      INc(expo,2);
      IF j MOD 2 = 0 THEN ans:=ans- (exponent(rad,expo)/facTOrial(expo)) ELSE
                              ans:=ans + (exponent(rad,expo)/facTOrial(expo));
      INc(j);
      str(ans,str2);
      str2:=copy(str2,0,places+1);
      accurate:=str1=str2;
      str1:=str2;
      str2:='';
   END;
   cosINe:=ans;
END;

{The Sin Function}

FUNCTION sINe(rad:real;places:INteger):real;
VAR expo,j:INteger;
    str1,str2:STRING;
    Accurate:boolean;
    ans:real;
BEGIN
   expo:=3;
   j:=1;
   ans:=rad-(exponent(rad,expo)/facTOrial(expo));
   str(ans,str1);
   str1:=copy(str1,0,places+1);
   accurate:=false;
   WHILE NOT Accurate DO
   BEGIN
      INc(expo,2);
      IF j MOD 2 = 0 THEN ans:=ans- (exponent(rad,expo)/facTOrial(expo)) ELSE
                              ans:=ans + (exponent(rad,expo)/facTOrial(expo));
      INc(j);
      str(ans,str2);
      str2:=copy(str2,0,places+1);
      accurate:=str1=str2;
      str1:=str2;
      str2:='';
   END;
   sINe:=ans;
END;

{Reduction formulae for the Sin function. Used to deterimine which quadrant
the number is situated. Quadrant 1 is always positive.}

FUNCTION SINCheck(VAR num:real):real;
BEGIN
   IF (num<=180) AND (num>90) THEN num:=180-num ELSE {Quadrant 2}
   IF (num >180) AND (num<=270) THEN num:=-(num-180) ELSE {Quadrant 3}
   IF (num>270) AND (num<=360) THEN num:=-(360 -num); {Quadrant 4}
   SINcheck:=num;
END;

{Reduction formulae for the Cos Function. Same as Sin Function.}

FUNCTION CosCheck(VAR num:real):real;
BEGIN
   IF (num<=180) AND (num>90) THEN num:=-num ELSE {Quadrant 1}
   IF (num >180) AND (num<=270) THEN num:=-(180 - num)ELSE {Quadrant 2}
   IF (num > 270) AND (num <=360) THEN num:=360 - num; {Quadrant 3}
   CosCheck:=num;
END;

{Reduction formulae for Tan. As well as to check the different quadrants
of the individual Cos and Sin values.}

FUNCTION Tan_check(VAR num,sIN_radians,cos_radians:real):real;
BEGIN
   IF (num > 90) AND (num <=180) THEN num:=-(180-num); {Quadrant 2}
   IF (num >180) AND (num <=270) THEN num:=num-180; {Quadrant 3}
   IF (cos_radians >-1) AND (cos_radians < 1) AND
   (sIN_radians >=0) AND (sIN_radians<1) THEN
   Tan_check:=sINe(sIN_radians,place)/cosINe(cos_radians,place) ELSE
   IF (sIN_radians <0) OR (sIN_radians >1) AND (cos_radians<-1) OR (cos_radians>1)
   THEN BEGIN
           SINcheck(deg);
           sIN_radians:=(num*pi)/180;
           Coscheck(deg);
           cos_radians:=(num*pi)/180;
           Tan_check:=sINe(sIN_radians,place)/cosINe(cos_radians,place);
        END;
END;

{Function to convert a Real number to String. Works better than str and
is more easier in Assembler.}

FUNCTION RTOS( nNum: REAL; nLength, nDec: INTEGER ): STRING;
VAR
   s: ^STRING;
BEGIN
     ASM
          mov     sp, bp
          push    ss
          push    WORD PTR @RESULT
     END;
     STR( nNum:nLength:nDec, s^ );
END;

{Lets the user enter the degrees.}

PROCEDURE Write_degs(VAR degrees:real;VAR st:STRING);
VAR s:STRING;
    x,y,x1,y1,err:INteger;
BEGIN
   SETtextstyle(6,0,1);
   x:=30;
   x1:=30+120;
   y:=40;
   y1:=40 +120;
   SETcolOR(black);
   SETfillstyle(solidfill,blue);
   bar(x+550,y+225,x1-100,y1-20);
   frame(x+550,y+225,x1-100,y1-20,White,darkgray);
   Outtextxy(x+10,y+100,'   Please enter degrees : ');
   s:='';
   WHILE s = '' DO readlnxy(x+208,y+114,10,s,blue,white);
   st:=s;
   val(st,degrees,err);
END;

{Lets the user enter accuracy of decimal places.}

PROCEDURE Write_place(VAR deci:INteger);
VAR s:STRING;
    x,y,x1,y1,err:INteger;
BEGIN
     SETtextstyle(6,0,1);
     x:=30;
     x1:=30+120;
     y:=40;
     y1:=40 +120;
     SETcolOR(black);
     Outtextxy(x+23,y+135,' Please enter accuracy of decimal places : ');
     s:='';
     WHILE s = '' DO readlnxy(x+355,y+148,10,s,blue,white);
     val(s,deci,err);
END;

{Displays all the results of Sin Function.}

PROCEDURE DO_sINe;
VAR st,st2:STRING;
    x,y:INteger;
BEGIN
   x:=30;
   y:=40;
   st:='';
   SETtextstyle(6,0,1);
   write_degs(deg,st);
   write_place(place);
   radians:=(deg*pi)/180;
   SETcolOR(black);
   SETtextstyle(6,0,1);
   IF (radians >=0) AND (radians<1) THEN
   BEGIN
   Outtextxy(x+28,y+175,'The Sine of ');
   st:=st + '°';
   Outtextxy(x+120,y+175,st);
   Outtextxy(x+240,y+175,'is');
   SETcolOR(red);
   Outtextxy(x+220+50,y+175,rTOs(sINe(radians,place),5,place));
   END;
   IF (radians <0) OR (radians >1) THEN
   BEGIN
      SINcheck(deg);
      radians:=(deg*pi)/180;
      Outtextxy(x+28,y+175,'The Sine of ');
      st:=st + '°';
      Outtextxy(x+120,y+175,st);
      Outtextxy(x+240,y+175,'is');
      SETcolOR(red);
      Outtextxy(x+220+50,y+175,rTOs(sINe(radians,place),5,place));
   END;
   readln;
END;

{Same as Do_Sine but for Cos Function.}

PROCEDURE DO_Cos;
VAR st,st2:STRING;
    x,y:INteger;
BEGIN
   x:=30;
   y:=40;
   st:='';
   write_degs(deg,st);
   write_place(place);
   radians:=(deg*pi)/180;
   SETcolOR(black);
   SETtextstyle(6,0,1);
   IF (radians >-1) AND (radians < 1) THEN
   BEGIN
      Outtextxy(x+28,y+175,'The Cosine of ');
      st:=st + '°';
      Outtextxy(x+140,y+175,st);
      Outtextxy(x+240,y+175,'is');
      SETcolOR(red);
      Outtextxy(x+220+50,y+175,rTOs(cosINe(radians,place),5,place));
   END;
   IF (radians<-1) OR (radians>1) THEN
   BEGIN
      Coscheck(deg);
      radians:=(deg*pi)/180;
      Outtextxy(x+28,y+175,'The Cosine of ');
      st:=st + '°';
      Outtextxy(x+140,y+175,st);
      Outtextxy(x+240,y+175,'is');
      SETcolOR(red);
      Outtextxy(x+220+50,y+175,rTOs(cosINe(radians,place),5,place));
   END;
   readln;
END;

{Same as above}

PROCEDURE DO_Tan;
VAR x,y:INteger;
    st:STRING;
BEGIN
   x:=30;
   y:=40;
   st:='';
   write_degs(deg,st);
   SETtextstyle(6,0,1);
   {Due to assimptote situation.}
   IF (deg = 90) OR (deg = 270) OR (deg =450) OR (deg= 630) THEN
   Outtextxy(x+25,y+135,'Sorry, the result of this function is undefined !!!') ELSE
   BEGIN
      write_place(place);
      radians:=(deg*pi)/180;
      SETtextstyle(6,0,1);
      SETcolOR(black);
      cos_radians1:=(deg*pi)/180;
      sIN_radians1:=(deg*pi)/180;
      Outtextxy(x+28,y+175,'The Tan of ');
      st:=st + '°';
      Outtextxy(x+120,y+175,st);
      Outtextxy(x+240,y+175,'is');
      SETcolOR(red);
      Outtextxy(x+220+50,y+175,rTOs(tan_check(deg,sIN_radians1,cos_radians1),5,place));
   END;
   readln;
END;

{Inverse of Sin function. Cannot invert 0 so if answer is 0 then keep it.}

PROCEDURE DO_Cosec;
VAR st,st2:STRING;
    x,y:INteger;
BEGIN
   radians:=0;
   x:=30;
   y:=40;
   st:='';
   SETtextstyle(6,0,1);
   write_degs(deg,st);
   write_place(place);
   radians:=(deg*pi)/180;
   SETcolOR(black);
   SETtextstyle(6,0,1);
   IF (radians >=0) AND (radians<1) THEN
   BEGIN
     Outtextxy(x+28,y+175,'The Cosec of ');
     st:=st + '°';
     Outtextxy(x+136,y+175,st);
     Outtextxy(x+240+length(st)+20,y+175,'is');
     IF ((trunc(deg) MOD 360 = 0)) OR ((trunc(deg) MOD 360 = 180)) THEN
     BEGIN
       SETcolOR(red);
       Outtextxy(x+220+100,y+175,rTOs(sINe(radians,place),5,place));
     END;
     IF ((trunc(deg) MOD 360 <> 0)) OR ((trunc(deg) MOD 360 <> 180 )) THEN
     BEGIN
        SETcolOR(red);
        Outtextxy(x+220+100,y+175,rTOs(1/(sINe(radians,place)),5,place));
     END;
   END;
     IF (radians <0) OR (radians >1) THEN
     BEGIN
        SINcheck(deg);
        radians:=(deg*pi)/180;
        Outtextxy(x+28,y+175,'The Cosec of ');
        st:=st + '°';
        Outtextxy(x+136,y+175,st);
        Outtextxy(x+240+length(st)+20,y+175,'is');
        IF (trunc(deg) MOD 360 = 0) OR (trunc(deg) MOD 360 = 180) THEN
        BEGIN
          SETcolOR(red);
          Outtextxy(x+220+50,y+175,rTOs(sINe(radians,place),5,place));
        END;
        IF (trunc(deg) MOD 360 <> 0) OR (trunc(deg) MOD 360 = 180 ) THEN
        BEGIN
          SETcolOR(red);
          Outtextxy(x+220+50,y+175,rTOs(1/(sINe(radians,place)),5,place));
        END;
     END;
   readln;
END;

{Inverse of Cos Function.}

PROCEDURE DO_Sec;
VAR st,st2:STRING;
    x,y:INteger;
BEGIN
   radians:=0;
   x:=30;
   y:=40;
   st:='';
   SETtextstyle(6,0,1);
   write_degs(deg,st);
   write_place(place);
   radians:=(deg*pi)/180;
   SETcolOR(black);
   SETtextstyle(6,0,1);
   IF (radians >=0) AND (radians<1) THEN
   BEGIN
     Outtextxy(x+28,y+175,'The Sec of ');
     st:=st + '°';
     Outtextxy(x+116,y+175,st);
     Outtextxy(x+240,y+175,'is');
     IF ((trunc(deg) MOD 90 = 0)) OR ((trunc(deg) MOD 90 = 45)) THEN
     BEGIN
       SETcolOR(red);
       Outtextxy(x+220+50,y+175,rTOs(cosINe(radians,place),5,place));
     END;
     IF ((trunc(deg) MOD 90 <> 0)) OR ((trunc(deg) MOD 360 <> 45 )) THEN
     BEGIN
        SETcolOR(red);
        Outtextxy(x+220+50,y+175,rTOs(1/(cosINe(radians,place)),5,place));
     END;
   END;
     IF (radians <0) OR (radians >1) THEN
     BEGIN
        SINcheck(deg);
        radians:=(deg*pi)/180;
        Outtextxy(x+28,y+175,'The Sec of ');
        st:=st + '°';
        Outtextxy(x+116,y+175,st);
        Outtextxy(x+240,y+175,'is');
        IF (trunc(deg) MOD 90 = 0) OR (trunc(deg) MOD 90 = 45) THEN
        BEGIN
          SETcolOR(red);
           Outtextxy(x+220+50,y+175,rTOs(cosINe(radians,place),5,place));
        END;
        IF (trunc(deg) MOD 90 <> 0) OR (trunc(deg) MOD 90 = 45 ) THEN
        BEGIN
          SETcolOR(red);
          Outtextxy(x+220+50,y+175,rTOs(1/(cosINe(radians,place)),5,place));
        END;
     END;
   readln;
END;

{Inverse of Cot Function.}

PROCEDURE DO_Cot;
VAR x,y:INteger;
    st:STRING;
BEGIN
   x:=30;
   y:=40;
   st:='';
   write_degs(deg,st);
   SETtextstyle(6,0,1);
   IF (deg = 90) OR (deg = 270) OR (deg =450) OR (deg= 630) THEN
   Outtextxy(x+25,y+135,'Sorry, the result of this function is undefINed !!!') ELSE
   BEGIN
      write_place(place);
      radians:=(deg*pi)/180;
      SETtextstyle(6,0,1);
      SETcolOR(black);
      cos_radians1:=(deg*pi)/180;
      sIN_radians1:=(deg*pi)/180;
      Outtextxy(x+28,y+175,'The Cot of ');
      st:=st + '°';
      Outtextxy(x+120,y+175,st);
      Outtextxy(x+240,y+175,'is');
      IF (trunc(deg) MOD 180 = 0) THEN
      BEGIN
        SETcolOR(red);
        Outtextxy(x+220+50,y+175,rTOs(tan_check(deg,sIN_radians1,cos_radians1),5,place));
      END;
      IF (trunc(deg) MOD 180 <>0) THEN
      BEGIN
         SETcolOR(red);
        Outtextxy(x+220+50,y+175,rTOs(1/(tan_check(deg,sIN_radians1,cos_radians1)),5,place));
      END;
   END;
   readln;
END;

{Used to draw numbers next to a button to let user use program with keyboard
only.}

PROCEDURE DOChan(x,y : INteger;s : STRING);
BEGIN
     SETfillstyle(solidfill,black);
     Bar(x-2,y-2,x+25,y+25);
     Bar(x-2,y-2,x+25,y+25);
     Frame(x-2,y-2,x+25,y+25,White,darkgray);
     SETcolOR(White);
     SETtextstyle(6,0,2);
     Outtextxy(x+6,y-4,s);
END;

{Main menu. Loads a PCX file 640 X 480 X 16 dimensions. Then displays buttons.}

PROCEDURE Menu;
VAR i:INteger;
BEGIN
     Fadeout;
     readscr('background.pcx');
     DOButTOn(230,100,'Sin Function ');
     DOButTOn(230,100,'Sin Function ');
     DOButTOn(230,150,'Cos Function ');
     DObutTOn(230,200,'Tan Function');
     DOButTOn(230,250,'Cosec Function');
     DOButTOn(230,300,'Sec Function ');
     DOButTOn(230,350,'Cot Function ');
     DObutTOn(230,400,'Quit');
     ShowmousecursOR;
     FOR i := 1 TO 7 DO DOChan(180,50 + (i*50),Chan[i]);
     FadeIN;
END;

Procedure SetUpScreen;
Begin
     ClrScr;
     textcolor(blue);
     writeln;
     Writeln('                      Program written by Elli Lechtman         ');
     writeln;
     textcolor(lightred);
     Writeln('                                  STD 10 ');
     writeln('                          Sandringham High School');
     writeln('                                   1997');
     writeln;
     textcolor(lightblue);
     writeln('                                 Home Page');
     writeln('                    http://www.icon.co.za/~elli/welcome.htm');
     GotoXY (1,5);
     TextColor (yellow);
     GotoXY(21, 19);
     Writeln('This Program is Copyrighted by Elli Lechtman');
     GotoXY(13,21);
     Writeln('This Program is Public Domain as long as not sold for profit.');
End;

{This is where the user controls the Functions that he wants.}

PROCEDURE Menu_Screen;
VAR
   ch : Char;
   rep : INteger;
   quit:boolean;

   PROCEDURE Proc1;
   BEGIN
        Banimate(230,100,'Sin Function ');
        hidemousecursOR;
        DO_Sine;
        menu;
        showmousecursOR;
   END;

   PROCEDURE Proc2;
   BEGIN
        BAnimate(230,150,'Cos Function ');
        hidemousecursOR;
        DO_cos;
        menu;
        showmousecursOR;
   END;

   PROCEDURE Proc3;
   BEGIN
        Banimate(230,200,'Tan Function');
        hidemousecursOR;
        DO_tan;
        menu;
        showmousecursOR;
   END;

   PROCEDURE Proc4;
   BEGIN
        Banimate(230,250,'Cosec Function');
        hidemousecursOR;
        DO_cosec;
        menu;
        showmousecursOR;
   END;

   PROCEDURE proc5;
   BEGIN
       Banimate(230,300,'Sec Function ');
       hidemousecursOR;
       DO_sec;
       menu;
       showmousecursOR;
   END;

   PROCEDURE proc6;
   BEGIN
        Banimate(230,350,'Cot Function ');
        hidemousecursOR;
        DO_cot;
        menu;
        showmousecursOR;
   END;

   PROCEDURE MaINProc;
   BEGIN
     Quit := False;
     FOR i := 1 TO 6 DO DOChan(180,50 + (i*50),Chan[i]);
     REPEAT
           Ch := ' ';
           REPEAT
                 ShowmousecursOR;
                 IF Keypressed THEN Ch := readkey;
           UNTIL (GetbutTOnpressed = 1) OR (Ch <> ' ');
           IF (CButTOn(230,100,'Sin Function ') AND
           (getbutTOnpressed = 1))  OR (Ch = '1') THEN Proc1;
           IF (CbutTOn(230,150,'Cos Function ') AND
           (getbutTOnpressed = 1)) OR (Ch = '2') THEN Proc2;
           IF (CbutTOn(230,200,'Tan Function') AND
           (getbutTOnpressed = 1)) OR (Ch = '3') THEN Proc3;
           IF (CButTOn(230,250,'Cosec Function') AND
           (getbutTOnpressed = 1)) OR (Ch = '4') THEN Proc4;
           IF (CButTOn(230,300,'Sec Function') AND
           (getbutTOnpressed = 1)) OR (Ch = '5') THEN Proc5;
           IF (CButTOn(230,350,'Cot Function') AND
           (getbutTOnpressed = 1)) OR (Ch = '6') THEN Proc6;
           IF (CbutTOn(230,400,'Quit') AND (getbutTOnpressed = 1))
           OR (upCASE(Ch) = '7') THEN
           BEGIN
              quit:=true;
              Banimate(230,400,'Quit');
              fadeout;
              hidemousecursor;
              closegraph;
              fadein;
           END;
     UNTIL Quit;
END;
BEGIN
   maINproc;
END;

BEGIN
   radians:=0; {Initializes variables}
   deg:=0;
   place:=0;
   DO_graph;
   readscr('trig.pcx'); {Loads introductory PCX file}
   delay(3000);
   menu;
   menu_screen;
   restorecrtmode;
   SetUpScreen;
   readln;
END.

