(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0048.PAS
  Description: Complete Keyboard Unit
  Author: ROB PERELMAN
  Date: 09-26-93  10:12
*)

(*
From: ROB PERELMAN
Subj: A COMPLETE Keyboard Unit in ASM
*)

UNIT Keyboard;

INTERFACE

   FUNCTION AltPress: Boolean;
   FUNCTION CapsOn: Boolean;
   FUNCTION CtrlPress: Boolean;
   FUNCTION InsertOn: Boolean;
   FUNCTION LAltPress: Boolean;
   FUNCTION LCtrlPress: Boolean;
   FUNCTION LShiftPress: Boolean;
   FUNCTION NumOn: Boolean;
   FUNCTION RAltPress: Boolean;
   FUNCTION RCtrlPress: Boolean;
   FUNCTION RShiftPress: Boolean;
   FUNCTION ScrollOn: Boolean;
   FUNCTION ShiftPress: Boolean;
   PROCEDURE ClearKbd;
   PROCEDURE PrintScreen;
   PROCEDURE SetCaps (CapsLock: Boolean);
   PROCEDURE SetEnhKbd (Enhanced: Boolean);
   PROCEDURE SetInsert (Ins: Boolean);
   PROCEDURE SetNum (NumLock: Boolean);
   PROCEDURE SetPrtSc (PrtScOn: Boolean);
   PROCEDURE SetScroll (ScrollLock: Boolean);
   PROCEDURE SpeedKey (RepDelay, RepRate: Integer);
   PROCEDURE TypeIn (Keys: String);

IMPLEMENTATION

{$F+}

{ the routines are actually in assembly language }

   FUNCTION AltPress; external;
   FUNCTION CapsOn; external;
   FUNCTION CtrlPress; external;
   FUNCTION InsertOn; external;
   FUNCTION LAltPress; external;
   FUNCTION LCtrlPress; external;
   FUNCTION LShiftPress; external;
   FUNCTION NumOn; external;
   FUNCTION RAltPress; external;
   FUNCTION RCtrlPress; external;
   FUNCTION RShiftPress; external;
   FUNCTION ScrollOn; external;
   FUNCTION ShiftPress; external;
   PROCEDURE ClearKbd; external;
   PROCEDURE PrintScreen; external;
   PROCEDURE SetCaps; external;
   PROCEDURE SetEnhKbd; external;
   PROCEDURE SetInsert; external;
   PROCEDURE SetNum; external;
   PROCEDURE SetPrtSc; external;
   PROCEDURE SetScroll; external;
   PROCEDURE SpeedKey; external;
   PROCEDURE TypeIn; external;

{$L KBD}

BEGIN
END.

{ ---------------------   CUT HERE -----------------------}

1.  CUT THIS OUT TO A SEPARATE FILE.
2.  Name it KBD.XX.
3.  Execute : XX3401 D KBD.XX
4.  KBD.OBJ will be created.

Here comes the XX-encoded KBD.OBJ file...

*XX3401-001215-010792--68--85-18007---------KBD.OBJ--1-OF--1
U+Y+-qhWN0tVQqrEZUQ+++F1HoF3F7U5+0VT+k6-+RCE6U2++ERHFJF1EJ-HjU++0p-G
GItIIoBGFIJCPE++02ZCIoJGJ2xCAE++0IBIIYlEIYJHImI+++VHFJFEIZFHEqw-++NI
KJ-3GIs2+U+8IoV7FZFEIYJHIy+-++JCJIpDHZo+++hGIoV7FZFEIYJHIuE+++hAIoV7
FZFEIYJHIpA+++ZHFJFHEp7DH2n++E+8H2BIIYlEIYJHIoY+++V1H2J-IYh0F-k+++dG
EpFGH3-GFJBHZU++023AJ3-GFJBH++++0Il-H3FEIYJHIno+++ZGEIlII373IpC4+++4
IoJIHZJBHk2+03B1IYxAH2xCf+++0JB3J2ZCIoJGJ0w-++N1EJ-HHosC+++7IoJIFIt6
Go72rU++03BEFIJ2GoJNw+2+u6U2++0W+R4UsU6-++0o+goKoSXFuB5cUy+-mvE0nFMn
qx1UoC1FotD9h+OmzwoVRTX9h+9B3h5coSW1s+59h+9B3XDPoC1FotD9h-9B3cf2oSW1
s+59h-9B3cf2Uy+-mvE0nFPFu6DU+Qio+goKAxjEsB1UoC1FotD9JJNL9c+y++++REPB
-JxSLQiQ9jwS++1fx9EGnFO8lB5coSXFu6DU+Qio2goKWgHFuB5cUy+-mvE0nFO1s+59
h+9B3XDPoC1EsB1UoC1FotD9JMjg5ch4-XDPXhg9k5E8U+sL-2+TLQc0+6+a3kGzuzFJ
WykSWoM40w-p5Gu+DU+++5EE9gIK++0s3WLB6Gv4-U+++-xRmU6+9c+y++++RTCs3XLB
6Gu75U++9ck4++0u+++C5vUK7QoV9gM4+++-ux7JWykSWoM4AxiCqkj+R+e+1VQ2U-xR
mU6+U0ML-5zfx3K9v-u9FUMnqsvP0w-o0c+C3kEU5pr8+U0+7VQ2ryjoJMjg5ch4-Uj+
RGkiU1s+++-p5vU3BQoV9cYS+++iX+M++9U37EsTiU++nG2ilUM+++2TLQc0+0u+DU++
+5Hni+IZ9gIK++1B6Gv4-U+++CjVJMjg5ch4-XDPXhg9k5E8U+sL--+TLQc0+6+a3kHj
uzGo+goKAxjFuB5HUy+-0wD9JMjg5cdy06dS-fU3+woK5pr8-+-JWylKJlv3RUMnmTmg
WgWu1k0sE+0Ck9wS+DcaWHsO+9g++8m8s+j+9hRp-2Zo18m4l8h8sCoaWHsQ+DgTLptR
mUE+UDk0RkC+l-+izms++Aw++++++++++++++-sk9W+G6G6X3mEZ7X6l4-YE2lwI3WwF
9FIg4WgP-kkt+WU2-EM68+c90+on11Ep0k61-+I4-kU70WQbAkooBE6SA0sU2W2W6lQY
7GMmAFUN2-AT3-Mj2GoJ9-cf4kQA8Fsk9W+G6G6X3mEZ7X6l4-YE2lwI3WwF9FIg4WgP
8SiQSE12Qp+-KU92UZ+-Kk92v3+-JE92x3+-JU92zZ+-JE930J+-JE933Z+-JU934p+-
K+935Z+-Fk938Z+-JE93TJ+-KU93WZ+-Kk93Xp+-LE93Zp+-J+93bZ+-KU93eJ+-KU93
h3+-Kk93ip+-KU947J+-Lk94IZ+-JU85cUc++Rs0UE++++2+wMc0++-o
***** END OF XX-BLOCK *****

