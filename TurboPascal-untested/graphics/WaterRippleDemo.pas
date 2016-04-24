(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0286.PAS
  Description: Water ripple demo
  Author: SCOTT TUNSTALL
  Date: 01-02-98  07:34
*)

{
PROGRAM NAME: SHAKEIT.PAS

AUTHOR      : SCOTT TUNSTALL B.Sc

CREATION    : 12TH AUGUST 1997
DATE


NOTES:
I guess you could call this a kind of "water ripple" demo.

It needs VGA, TP7 and my KOJAKVGA unit V3.3 to run (get it from
June 97 SWAG, GRAPHICS section) and in case you're wondering why
I wrote this, I was inspired by a demo that came with a file my
mate Geoff gave me ages ago. Which was much better than this <g> !

Hope you like it. The "shake" proc is quite interesting,
if I say so myself !!! ;)

Have fun!
     Scott.



DISCLAIMER:
Use this program at your OWN RISK. CGA/EGA card owners, do NOT complain
if this kills your PC! :>

If you use this routine at all, please credit KojakVGA. Thank you.
}



Program ShakeIt_Baby;


Uses KOJAKVGA,crt;       { My baby! ;) }



{ If you wanna see 1 kind of shake, use the $DEFINE below }

{$DEFINE USE_SHAKE}


type shaketype=(ShakeLeft,ShakeRight);


Const StartY=1;     { Pixel row where dat shakin' starts ! }
      EndY=199;       { And where it ends }



Var HiddenBMap : pointer;
    MyPalette  : PaletteType;
    ShakeDir   : ShakeType;
    XDistLatch,
    XDist      : byte;
    YCount     : byte;


Begin
     { Load PCX to "shake" into a hidden bitmap }

     HiddenBMap:=New64KBitmap;
     UseBitmap(HiddenBMap);
     Cls;


     { You can use any 256 colour PCX file you like (up to 320x200 in size,
       any bigger and the image is clipped) }

     LoadPCX(ParamStr(1),MyPalette);

     InitVGAMode;
     UsePalette(Mypalette);

     { Initial X distance }

     XDistLatch:=1;

     { And we're shaking to the left initially.. }

     ShakeDir:=ShakeLeft;


     Repeat
           { Draw "non-shaking" parts of screen.. If you're doing
             any scrolly messages etc., draw to bitmap <HiddenBmap>
           }

           If StartY >0 Then
              CopyAreaToBitmap(0,0,319,StartY-1,Ptr($a000,0),0,0);

           If EndY < 199 Then
              CopyAreaToBitmap(0,EndY+1,319,199,Ptr($a000,0),0,EndY+1);



           { Now do the "difficult" stuff. }

           XDist:=XDistLatch;
           For YCount:=StartY To EndY Do
           Begin


{$IFDEF USE_SHAKE}
               Case ShakeDir Of



               ShakeLeft: Begin
                          CopyAreaToBitmap(4,YCount,315,YCount,
                          Ptr($a000,0),3-XDist,YCount);
                          Inc(XDist);
                          End;

               ShakeRight: Begin
                           CopyAreaToBitmap(4,YCount,315,YCount,
                           Ptr($a000,0),XDist,YCount);
                           Inc(XDist);
                           End;
               End;

               If XDist=4 Then
               Begin
                  XDist:=1;
                  If ShakeDir = ShakeRight Then
                     ShakeDir:=ShakeLeft
                  Else
                      ShakeDir:=ShakeRight;
               End;


{$ELSE}

                CopyAreaToBitmap(4,YCount,315,YCount,
                Ptr($a000,0),3-XDist,YCount);
                Inc(XDist);
                If XDist=3 Then
                   XDist:=1;
{$ENDIF}


           End;


           { Make the Latch (XDist reload value) different for
             each time the for loop executes }


           Inc(XDistLatch);
           If XDistLatch = 3 Then
              Begin
              XDistLatch:=1;
              If ShakeDir = ShakeLeft Then
                 ShakeDir:= ShakeRight
              Else
                  ShakeDir:= ShakeLeft;
              End;


     { Wait 5 video retraces }

     Vwait(8);
     Until Keypressed;

     { Release hidden bitmap from memory }

     FreeBitmap(HiddenBMap);

End.





{ Here's the PCX file I used to test SHAKEIT.PAS; not very interesting,
  admittedly but hey...

  Needs XX3402 to decode. Put the PCX file in the same directory
  as the EXE file before you run.
}



{-------------------8< START CUT HERE----------------------------------}

*XX3402-006285-120897--72--85-64865-----SHAKEIT.PCX--1-OF--2
0UI-0++++++z+QQ+9+2g+E++++U60-+E2-UM40Yd8GYt+0Z0+12lAHYtCHZG+1ZO+270EY7O
+27X+2d8GYdX+++-E+2-++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++++++++++++++++++++++1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1o+AICzk1z+Dw+zk19+D++lkv32gU+2gIKsk125A6Puk144wY+5Aw+lVTX+AMCt+13-yg+
vk151gQGlk143iA+kVn24yg+lVj5+AAPnk143yA+2gICt+13-yg+vU141gcGlU143iA+lVjf
+AMPlE134ww+lVTX+AAGkkvY+AI5uk1i+AICn-93+AMKsk144yg+lVj2+AMPnk143yA+l-90
1iE+lETf+Co+l+v22g6+ll6KlE143iA+lVjf+AMPl+144ww+lVTX+AMGt+13-yg+vE111gAG
lU112gEKl+143iA+lVjp+AMPnk+PlFTX+AMGt++6l+Tf+Co+1gIGlk+GlFP2+AMKkU141Ag+
m-j6+AMPoU145Ro+lVjD+AAPklT0+AMLmk163gU+lV90+-931hk+kUX1-yg+vE142gQ+lVP2
+AIK3k171AQ+4AgPlU144wE+llr3+AgRo+142A6+mljA+AMPmVT5+AkKlU182gMCl+141gQ+
1gI6kk110A65uk1h+AUGnk113gALmkn3+-XB4wI+lFgRkk155QI+nFrD+AMEkU135QMPn+16
4wYLlE113wgKlE192gMCkk141gM+kkv10AE+l+U5uk1h+AYGkVPA+-P23wcAkUr3+AwPl++P
lFr1+AQRl+1D5Qs+lV10+AYRkVjA+AgPlVT3+AILmVP2+-PA2gECkk141gM+l+v00AE+lEXf
+Cs+ll953gU+lFT61AEBl+1E4wE+lVr0+AQRlE1D5Qs+lV10+AgRn+1B4wILkk153wYKl+10
3gkGl+v1+AMClE131UX2+AI6uk1i+AIGmlP4+AELkkn2+AQBkk144wE+l-j05QE+lVo+llr3
+AMRlE145Qo+lV12+AMRnk164wE+klj13wA+lVT2+AMKl+123gEGl+112gACkk141gE+lUv3
+AI6uk1j+AAGnFP3+AALl+n3+AMBl+124wM+lFr2+AoRlU135QM+lVrB+AMEl+145Qw+llj4
+AEPkVT1+AELlU133gE+lFP02gM+l-901g6+lUv2+AMClE120Ck+wE1C3Un2+A6Ll+n4+AMB
n+155QE+n-r5+AITlk135wo+lV12+AMRnk144wQ+lVj9+AALl-P2+AMKlk132Uv1+AMCkk13
1gM+l+Xg+DE+mFP11AE+kVT11+r4+AMBlk+Pmlr2+AgR5wM+oVzB+AMFl+102AERnk105QEP
lk144wM+mVT03gE+lVP5+AMGkk141g6+lUv4+AE6v+1s+AEKlEn1+-T01AABlU141QI+4woR
l+145QIT2QM+oVzB+AMFl+102QEEnk125Q6Plk144wE+nFQKl+143gQ+lV92+AICkU141gM+
l+Xg+Cw+kV17+AQAkk+LlEr4+AEBkUz2+AwRl+105QETlF502wI+oVzB+AMHl+142Qw+lVr5
+AMPkk114wkLl+143gQ+lV92+AMC+AIClk+CkkXg+Ck+1wIEmE141AA+lUr4+A6BkUz02AA+
mVo+l-oEl+105wEFm-D2+B6TnE142wE+kVD22Qw+lVr5+AMPkU+Bl-j33k133wE+lVP5+AMG
l+1A1gU+1g66v+1g+AMEmE141AA+lUr4+A6Dl-11+AMRlE+Rkl+Fl+102QIH+AMHl+145xY+
lVD2+AMHnk+NlFr5+AMPkU111QAPlE133wE+lVP5+AMGlE191gU+kUs6v+1g+AQElk141+r1
+AMBlU142A6+lVr3+A6El-52+AMHkU152wE+lFz4+AIHnU142wE+lVDD+-f14QARlU144k14
1QI+lVT2+-L43gM+3gIGlE+GmEvs+Co+lV+AlE141A6Bkk141QM+lV10+AMRlE132FD2+AMH
kk142wE+lVD3+AMHnE142wE+lVDD+-104gAN5QI+klr14w6+lUr3+AMLl++A3QIKlE113gAG
lU102gUCm+13-ig+vE132AgAkkr2+AMBlU142A6+lFr02-2+l-522wE+lVD2+AMHkk163+16
3Ao+lVD2+AMH+A6Hn++FkV114gAN+AQR4w6+1wQB+AEPl-T2+A6AkVL33U143g6Glk102gQC
m+13-ig+vU122AcAl+r2+AIB1wM+lV11+-r12AIFllD2+AMHl+102wEIl+1D3As+lVH2+AYH
n+112QAEkVf04QQRl+101wUBklj13wE+kkn03QkKm+112gICmE13-ig+vU122AYAl+r3+AAB
kUwElU142AA+kV132QcHkk142wI+klH16AE+nFHD+AMIl++Im-DA+-v22QAEkVf04QIRl+10
2A6Dlkr24w6Lkk131-L93gY+kl921gY+lEPf+D++2AUAlEr4+A6BkUz02AM+lV12+AAFllA+
lFD1+AAHklH3+-H46AE+mlHE+AMIlE123AEHn++SkVD12E+FkV104g6NkVr4+A6EkUz41E+B
klgLkk141++Jm-P8+AEGkUv8+AI4uk1m+AMAl+r6+A6Dl-14+AMElE152wA+lFD1+AMIlU14
6AM+m-HF+A6Ul-H4+AQIn+105gAH2Q6+kV502A6OmE112A6DkUr1+A6Bklj1+AMAkU+JlFPA
+AIG1gc+lEPf+Dw+zk1z+Dw+l+142jc+zk1z+Dw+zk11++b32jg+zk1z+Dw+zU+7kU110QEG
yk1z+Dw+zk1y+AQ7kl9v+Dw+zk1z+Ds+m+YGz+1z+Dw+zk1y+AU7zE1z+Dw+zk1y+AQ7zU1z
+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z
+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z
+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z
+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+C6++w66+wE++wA6+wE++lP05lM1mU+1
kUU1lU110+D3++D00+D2++D10+D10AM++w66-AE++kv15kX7++D00+HC+A66+wk++w66zk1P
+Dw+sU+TkWk6kk+28g6g7AA++m9490Q1m++6kWkTlE+1kmkKlE+6kWkTkk+18A6g8+AZkWk1
lE+KkWkRkk+T8gIg8Uv5+0D090bA+-gekmkTmE+16gAg8Uvz+BY+zk1W+-z09+X0++AdkWkY
l++ckmn07Wf090c1lk+6kWkTlE+VkmkclE+6kWkTkk+ZkWkc+k+KkWkRlE+bkWk1kU+Ykmkc
7Wf19+v3++D29+v8++v49-j6+0949+Hz+BU+zk1W+-z09+U++mX090X2+-z090U1kk+TkWkb
lk+6kWkTlE+dl0k1l++6kWkTkU+YkWke+w6++w6g8QE++w6g8A6+4w6g8+D1+-j090f3+-P2
90D8+0X09+E18Wkdlk+1kWkd+kX090Dz+BU+zk1W+-z09+U18A6g8+D1++Ae90Y1lE+ZkWk2
lU+6kWkTl++CkWkXkWkVl++6kWkT+0H090c2l++ZkWk2kk+RkWkKkU+e90Y1lE+b80A1l++c
90cZkWk1mE+R5m90+0P09AQ++lwV3g6+kWkazk1M+Dw+sU+TkWkG8A6g8+D2++X09054++X0
9-z4++X09-z2+0D09+Ad90b2++X09-wYkWke-AI+3g6g6QA+8A6g+k+6kWkVnE+1kWkX3g6g
3go++mcg7wk+-w6g5zw+q+1z+C6+5w6g8wAg5wI+5w6g0AQ+kWkalU+6kWkTkk+1kWkb+-r0
9+v1++X090j190T4++D090b0++D090L0+-z09+XB+0509+Q+8Wkcn++K8Wkc+wg+6g6g7Tw+
qE1z+C6+5wQg-AE+5w6g0AQ+kWkalU+6kWkTkk+KkWkK++D090D1++X59-j4+0L09+E+5Q6g
3g6+5w6g0AA+7gIg0AA+8GkdkU+XkWk1mk+ZkWkZ+wg+8g6g5zw+qE1z+C6+5wAg8W5090X2
+-z09+X5+A6g7gM+0A6g5wA+8A6g+w6+80ke+w6+0AEg5Q6g8UD3+-P0902+80kekk+TkWk6
kk+alGk6kU+CkWkVkU+CkWkTmk+61WYg8+D8++sKkWkYzk1M+Dw+sU+TkWke-++bkWkPkk+C
kWkTlU+6kWkVlU+6kWkTkU+1mGkKkU+6kmkG+-z090L3++D090Y1kWkXkk+6kWkTkk+2kUUX
kWk6kU+Xm0kdnE+KkWkKn++XkWk1zk1L+Dw+sU+TkWkCkU+1kWke+w6++w6g8QM+6w6g3UEa
9-z0++X09-z0+-z790T0++X09051+0b09+v3+0L090D09+v1++Ae90b4+-z09+U++mf79+T4
++A63UX0++X09-z4++A65ED0+-z09+Xz+BQ+zk1W+-z09+X1+-z090T1+0D090H2+-9090Y+
+w6g7w6+5Q6g1g6+8GkelEUbkWk1++X09-z1++T090c1l++Kl0kdlE+WkWkYl++18A6g0++K
kWkWl+UGkWkXlU+1kWkbkU+TkWkK++D00+A+3g6g5w6+7w6g+zw+pk1z+C6+5w6g0AE+8A6g
1g6++mf090YV5mT19+T0+0b090IV8Wke+k+5kWkXlE+KkWkT++X09-z2+0909092++D29053
++AckWkd6FwZl0k2+0T09+D3+0Yg8UD4+0T090IVkWke+k+6kWkT++AekWkV7Q6g7zw+q+1z
+C6+5w6g0AE+-w6g8UD0++EclWke1gA+-mf39-90+0D09+v3++D090Y+0A6g5wE++mf09+T2
+0L19+H4++Ablmkd1U+1kWkclU+VkWkKlU+18gEg8UH0++X09-z0++v390U1zk1M+Dw+sU+6
kVw1lE+KkVw6l++C6Q6a6lM1lE+16Q6a6ED1+-j05wQ+3g6T+ED05kX3++X05lP2++X15wY+
--z17Vw2kk+5kVw6lU+1kVwGlk+15Q6a6ED1++D05kX1++AVkWMR+zw+qE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
***** END OF BLOCK 1 *****



*XX3402-006285-120897--72--85-56142-----SHAKEIT.PCX--2-OF--2
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+
lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+zk1z+Dw+lE1z+Dw+
zk1z+Dw+lE+A++++0+U62-+E4-UM8GYd8HY+8I6+AH2lCHYtCJ6+CJc+EY70EZc+EaA+GYd8
GaA+Gag+GbA+IZ7GIbA+Ibg+KZ6+KZdOMqBXMtE+OqA+Oqg+OqhfOtk+QrBnQuI+SrhvV9o+
X6mAZ7GIb7mQfOqhhPKpjPqxngvCphPKrhvSvyzjxzTrzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
zzzzzzzzzzzzzzzzzzzzzzzzzzzz
***** END OF BLOCK 2 *****

{-------------------8< END CUT ----------------------------------------}

