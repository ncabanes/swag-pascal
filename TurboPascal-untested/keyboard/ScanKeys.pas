(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0063.PAS
  Description: Scan Keys
  Author: WAYNE BOYD
  Date: 01-27-94  12:20
*)

unit ScanCode;

{ This UNIT is created by Wayne Boyd, aka Vipramukhya Swami, BBS phone
   (604)431-6260, Fidonet node 1:153/763. It's function is to facilitate
   the use of Function keys and Alt keys in a program. It includes F1
   through F10, Shift-F1 through Shift-F10, Ctrl-F1 through Ctrl-F10,
   and Alt-F1 through Alt-F10. It also includes all of the alt keys, all
   of the Ctrl keys and many other keys as well. This UNIT and source code
   are copyrighted material and may not be used for commercial use
   without express written permission from the author. Use at your own
   risk. I take absolutely no responsibility for it, and there are no
   guarantees that it will do anything more than take up space on your
   disk. }


interface

CONST

  F1  = 59;   CtrlF1  =  94;   AltF1  = 104;   Homekey   = 71;
  F2  = 60;   CtrlF2  =  95;   AltF2  = 105;   Endkey    = 79;
  F3  = 61;   CtrlF3  =  96;   AltF3  = 106;   PgUp      = 73;
  F4  = 62;   CtrlF4  =  97;   AltF4  = 107;   PgDn      = 81;
  F5  = 63;   CtrlF5  =  98;   AltF5  = 108;   UpArrow   = 72;
  F6  = 64;   CtrlF6  =  99;   AltF6  = 109;   RtArrow   = 77;
  F7  = 65;   CtrlF7  = 100;   AltF7  = 110;   DnArrow   = 80;
  F8  = 66;   CtrlF8  = 101;   AltF8  = 111;   LfArrow   = 75;
  F9  = 67;   CtrlF9  = 102;   AltF9  = 112;   InsertKey = 82;
  F10 = 68;   CtrlF10 = 103;   AltF10 = 113;   DeleteKey = 83;

  AltQ = 16;   AltA = 30;   AltZ = 44;   Alt1 = 120;  ShftF1 = 84;
  AltW = 17;   AltS = 31;   AltX = 45;   Alt2 = 121;  ShftF2 = 85;
  AltE = 18;   AltD = 32;   AltC = 46;   Alt3 = 122;  ShftF3 = 86;
  AltR = 19;   AltF = 33;   AltV = 47;   Alt4 = 123;  ShftF4 = 87;
  AltT = 20;   AltG = 34;   AltB = 48;   Alt5 = 124;  ShftF5 = 88;
  AltY = 21;   AltH = 35;   AltN = 49;   Alt6 = 125;  ShftF6 = 89;
  AltU = 22;   AltJ = 36;   AltM = 50;   Alt7 = 126;  ShftF7 = 90;
  AltI = 23;   AltK = 37;                Alt8 = 127;  ShftF8 = 91;
  AltO = 24;   AltL = 38;                Alt9 = 128;  ShftF9 = 92;
  AltP = 25;   CtrlLf = 115;             Alt0 = 129;  ShftF10= 93;
               CtrlRt = 116;

  CtrlA  = #1;  CtrlK = #11; CtrlU = #21; CtrlB = #2;  CtrlL = #12;
  CtrlV  = #22; CtrlC = #3;  CtrlM = #13; CtrlW = #23; CtrlD = #4;
  CtrlN  = #14; CtrlX = #24; CtrlE = #5;  CtrlO = #15; CtrlY = #25;
  CtrlF  = #6;  CtrlP = #16; CtrlZ = #26; CtrlG = #7;  CtrlQ = #17;
  CtrlS  = #19; CtrlH = #8;  CtrlR = #18; CtrlI = #9;  CtrlJ = #10;
  CtrlT = #20;  BSpace = #8; EscapeKey = #27; EnterKey = #13; NullKey = #0;

implementation

end.

Program Sample;

uses
  scancode,
  crt;

procedure GetKey;
var
  ch : char;
begin
  repeat
    ch := upcase(readkey);  { check key }
    if ch = NullKey then    { NullKey = #0 }
    begin
      case ord(readkey) of  { check key again }
        F1   : Dothis;        { put your procedures here }
        F2   : DoThat;
        altx : AltXPressed;
      end; {case}
    end
    else
    case ch of
      CtrlY     : CtrlYPressed;   { put your procedures here }
      CtrlT     : CtrlTPressed;
      BSpace    : BackSpacePressed;
      EnterKey  : EnterKeyPressed;
      EscapeKey : quitprogram;
    end;
  until ch = EscapeKey;
end;

begin
  GetKey;
end.

