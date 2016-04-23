{
=================================================================

FILENAME  : PIXFADIN.PAS

AUTHOR    : SCOTT "Lieutenant Kojak" TUNSTALL

CREATION  : 24TH NOVEMBER 1996
DATE

PURPOSE   : To demonstrate the fast blit functions of KOJAKVGA 3.


NOTES     :

I saw this 16 x 10 pixel "fade-in" first at College and thought
"ooh! Ain't that smart" (well, I'd never seen a SVGA PC before;
I'd come from Amiga-Land, 32 colours etc. etc.)

As a programming exercise I reproduced the effect with my
KOJAKVGA unit. Hope you like it.


What YOU do is:

o Specify the name of the PCX file to fade in (can be up to 320 x
  200 in size) as the command line parameter.

o Gasp with amazement as the PCX fades into your view.
  (That was sarcasm)

o Press CTRL+ALT+DEL to rid yourself of the misery.




DISCLAIMER :

Use this at your own risk. If you really must.
This program works just dandy on my PC.

-----------------------------------------------------------------
}



Uses KOJAKVGA,crt;


const BLOCK_WIDTH = 16;      { 320 MOD BLOCK_WIDTH must always be 0 }
      BLOCK_HEIGHT = 20;     { 200 MOD BLOCK_HEIGHT must always be 0 }




Var TempBitmap : pointer;
    TempPal    : PaletteType;
    xc,yc      : word;
    Count      : word;



Begin
     TempBitmap:=New64KBitmap;
     UseBitmap(TempBitmap);
     Cls;
     LoadPCX(ParamStr(1),TempPal);

     InitVGAMode;
     UsePalette(TempPal);


     Randomize;

     Repeat
           xc:=random(320 div BLOCK_WIDTH);
           yc:=random(200 div BLOCK_HEIGHT);


           { Syntax for CopyAreaToBitmap is:
             CopyAreaToBitmap(x1,y1,x2,y2,DestPtr,DestX,DestY)
           }


           CopyAreaToBitmap(xc*BLOCK_WIDTH,yc*BLOCK_HEIGHT,
           (xc*BLOCK_WIDTH)+(BLOCK_WIDTH-1),
           (yc*BLOCK_HEIGHT)+(BLOCK_HEIGHT-1),
           ptr($a000,0),xc*BLOCK_WIDTH,yc*BLOCK_HEIGHT);

           Delay(40);
     Until keypressed;

     FreeBitmap(TempBitmap);
End.


