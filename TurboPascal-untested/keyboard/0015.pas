{AM▒Hi everyone, I have a question. I need to know if there is some simple
AM▒way to do the following. I want to pass as a parameter to a Procedure
AM▒that will indicate what keypresses are valid. I am doing this already
AM▒for regular keys, but I need to be able to list regular keys as well as
AM▒extended key(mostly Function keys).

AM▒I do like so,

AM▒Command_Keys : Set of Char ['Q', 'A', 'K'];
AM▒Is there a way to add extended keys to the above.

Declare extended scan codes, then format them into an Array:
}
Const

(* Function keys *)
    F1 = $3B00;       ShF1 = $5400;      CtrlF1 = $5E00;      AltF1 = $6800;
    F2 = $3C00;       ShF2 = $5500;      CtrlF2 = $5F00;      AltF2 = $6900;
    F3 = $3D00;       ShF3 = $5600;      CtrlF3 = $6000;      AltF3 = $6A00;
    F4 = $3E00;       ShF4 = $5700;      CtrlF4 = $6100;      AltF4 = $6B00;
    F5 = $3F00;       ShF5 = $5800;      CtrlF5 = $6200;      AltF5 = $6C00;
    F6 = $4000;       ShF6 = $5900;      CtrlF6 = $6300;      AltF6 = $6D00;
    F7 = $4100;       ShF7 = $5A00;      CtrlF7 = $6400;      AltF7 = $6E00;
    F8 = $4200;       ShF8 = $5B00;      CtrlF8 = $6500;      AltF8 = $6F00;
    F9 = $4300;       ShF9 = $5C00;      CtrlF9 = $6600;      AltF9 = $7000;
   F10 = $4400;      ShF10 = $5D00;     CtrlF10 = $6700;     AltF10 = $7100;
   F11 = $8500;      ShF11 = $8700;     CtrlF11 = $8900;     AltF11 = $8B00;
   F12 = $8600;      ShF12 = $8800;     CtrlF12 = $8A00;     AltF12 = $8C00;

(* Numeric keypad *)
    Up = $4800;       ShUp = $4838;      CtrlUp = $8D00;      AltUp = $9800;
  Down = $5000;     ShDown = $5032;    CtrlDown = $9100;    AltDown = $A000;
  Left = $4B00;     ShLeft = $4B34;    CtrlLeft = $7300;    AltLeft = $9B00;
 Right = $4D00;    ShRight = $4D36;   CtrlRight = $7400;   AltRight = $9D00;
  Home = $4700;     ShHome = $4737;    CtrlHome = $7700;    AltHome = $9700;
endKey = $4F00;      Shend = $4F31;     Ctrlend = $7500;     Altend = $9F00;
  PgUp = $4900;     ShPgUp = $4939;    CtrlPgUp = $8400;    AltPgUp = $9900;
  PgDn = $5100;     ShPgDn = $5133;    CtrlPgDn = $7600;    AltPgDn = $A100;
   Ins = $5200;      ShIns = $5230;     CtrlIns = $9200;     AltIns = $A200;
   Del = $5300;      ShDel = $532E;     CtrlDel = $9300;     AltDel = $A300;
  Pad5 = $4C00;     ShPad5 = $4C35;    CtrlPad5 = $8F00;    AltPad5 = $9C00;

(* Alphabetic keys *)
  LowA = $1E61;        UpA = $1E41;       CtrlA = $1E01;       AltA = $1E00;
  LowB = $3062;        UpB = $3042;       CtrlB = $3002;       AltB = $3000;
  LowC = $2E63;        UpC = $2E43;       CtrlC = $2E03;       AltC = $2E00;
  LowD = $2064;        UpD = $2044;       CtrlD = $2004;       AltD = $2000;
  LowE = $1265;        UpE = $1245;       CtrlE = $1205;       AltE = $1200;
  LowF = $2166;        UpF = $2146;       CtrlF = $2106;       AltF = $2100;
  LowG = $2267;        UpG = $2247;       CtrlG = $2207;       AltG = $2200;
  LowH = $2368;        UpH = $2348;       CtrlH = $2308;       AltH = $2300;
  LowI = $1769;        UpI = $1749;       CtrlI = $1709;       AltI = $1700;
  LowJ = $246A;        UpJ = $244A;       CtrlJ = $240A;       AltJ = $2400;
  LowK = $256B;        UpK = $254B;       CtrlK = $250B;       AltK = $2500;
  LowL = $266C;        UpL = $264C;       CtrlL = $260C;       AltL = $2600;
  LowM = $326D;        UpM = $324D;       CtrlM = $320D;       AltM = $3200;
  LowN = $316E;        UpN = $314E;       CtrlN = $310E;       AltN = $3100;
  LowO = $186F;        UpO = $184F;       CtrlO = $180F;       AltO = $1800;
  LowP = $1970;        UpP = $1950;       CtrlP = $1910;       AltP = $1900;
  LowQ = $1071;        UpQ = $1051;       CtrlQ = $1011;       AltQ = $1000;
  LowR = $1372;        UpR = $1352;       CtrlR = $1312;       AltR = $1300;
  LowS = $1F73;        UpS = $1F53;       CtrlS = $1F13;       AltS = $1F00;
  LowT = $1474;        UpT = $1454;       CtrlT = $1414;       AltT = $1400;
  LowU = $1675;        UpU = $1655;       CtrlU = $1615;       AltU = $1600;
  LowV = $2F76;        UpV = $2F56;       CtrlV = $2F16;       AltV = $2F00;
  LowW = $1177;        UpW = $1157;       CtrlW = $1117;       AltW = $1100;
  LowX = $2D78;        UpX = $2D58;       CtrlX = $2D18;       AltX = $2D00;
  LowY = $1579;        UpY = $1559;       CtrlY = $1519;       AltY = $1500;
  LowZ = $2C7A;        UpZ = $2C5A;       CtrlZ = $2C1A;       AltZ = $2C00;

(* Number keys, on top row of keyboard *)
  Num1 = $0231;                                                Alt1 = $7800;
  Num2 = $0332;                           Ctrl2 = $0300;       Alt2 = $7900;
  Num3 = $0433;                                                Alt3 = $7A00;
  Num4 = $0534;                                                Alt4 = $7B00;
  Num5 = $0635;                                                Alt5 = $7C00;
  Num6 = $0736;                           Ctrl6 = $071E;       Alt6 = $7D00;
  Num7 = $0837;                                                Alt7 = $7E00;
  Num8 = $0938;                                                Alt8 = $7F00;
  Num9 = $0A39;                                                Alt9 = $8000;
  Num0 = $0B30;                                                Alt0 = $8100;

(* Miscellaneous *)
   Space = $3920;
    BkSp = $0E08;                   CtrlBkSp = $0E7F;       AltBkSp = $0E00;
     Tab = $0F09;   ShTab = $0F00;  CtrlTab  = $9400;        AltTab = $A500;
   Enter = $1C0D;                   CtrlEnter= $1C0A;      AltEnter = $1C00;
     Esc = $011B;                                            AltEsc = $0100;

   Minus = $0C2D;                  CtrlMinus = $0C1F;      AltMinus = $8200;
                     Plus = $0D2B;                          AltPlus = $8300;
PadMinus = $4A2D;               CtrlPadMinus = $8E00;    AltPadMinus= $4A00;
 PadPlus = $4E2B;                CtrlPadPlus = $9000;    AltPadPlus = $4E00;
                     Star = $092A;
 PadStar = $372A;                                        AltPadStar = $3700;

{AM>I do like so,
AM>Command_Keys : Set of Char ['Q', 'A', 'K'];
  >Is there a way to add extended keys to the above.

  Hi Andrew!
  One painless way is to set the high bit For Function keys.
}
Uses Crt;
Const
  Home   = #199;      UArr  = #200;     PgUp  = #201;
  LArr   = #203;      Five  = #204;     RArr  = #205;
  endkey = #207;      DArr  = #208;     PgDn  = #209;
  Ins   = #210;       Del   = #211;

  CtrlHome = #247;    CtrlUP   = #141;    CtrlPgUp = #138;
  CtrlLArr = #243;    CtrlFive = #143;    CtrlRArr = #244;
  Ctrlend  = #245;    CtrlDown = #145;    CtrlPgDn = #246;
  CtrlIns  = #146;    CtrlDel  = #147;

  BackSp  = #8;
  Tab     = #9;       STab    = #143;
  Enter   = #13;
  Esc     = #27;

  CtrlPrtsc = #242;

  CtrlA  = #1;     AltA  = #158;        Alt1 = #248;
  CtrlB  = #2;     AltB  = #176;        Alt2 = #249;
  CtrlC  = #3;     AltC  = #174;        Alt3 = #250;
  CtrlD  = #4;     AltD  = #160;        Alt4 = #251;
  CtrlE  = #5;     AltE  = #146;        Alt5 = #252;
  CtrlF  = #6;     AltF  = #161;        Alt6 = #253;
  CtrlG  = #7;     AltG  = #162;        Alt7 = #254;
  CtrlH  = #8;     AltH  = #163;        Alt8 = #255;
  CtrlI  = #9;     AltI  = #151;        Alt9 = #134;
  CtrlJ  = #10;    AltJ  = #164;        Alt0 = #135;
  CtrlK  = #11;    AltK  = #165;        Altminus  = #136;
  CtrlL  = #12;    AltL  = #166;        Altequals = #137;
  CtrlM  = #13;    AltM  = #178;
  CtrlN  = #14;    AltN  = #177;
  CtrlO  = #15;    AltO  = #152;
  CtrlP  = #16;    AltP  = #153;
  CtrlQ  = #17;    AltQ  = #144;
  CtrlR  = #18;    AltR  = #147;
  CtrlS  = #19;    AltS  = #159;
  CtrlT  = #20;    AltT  = #148;
  CtrlU  = #21;    AltU  = #150;
  CtrlV  = #22;    AltV  = #175;
  CtrlW  = #23;    AltW  = #145;
  CtrlX  = #24;    AltX  = #173;
  CtrlY  = #25;    AltY  = #149;
  CtrlZ  = #26;    AltZ  = #172;

  F1  = #187;      sF1  = #212;      CtrlF1  = #222;      AltF1  = #232;
  F2  = #188;      sF2  = #213;      CtrlF2  = #223;      AltF2  = #233;
  F3  = #189;      sF3  = #214;      CtrlF3  = #224;      AltF3  = #234;
  F4  = #190;      sF4  = #215;      CtrlF4  = #225;      AltF4  = #235;
  F5  = #191;      sF5  = #216;      CtrlF5  = #226;      AltF5  = #236;
  F6  = #192;      sF6  = #217;      CtrlF6  = #227;      AltF6  = #237;
  F7  = #193;      sF7  = #218;      CtrlF7  = #228;      AltF7  = #238;
  F8  = #194;      sF8  = #219;      CtrlF8  = #229;      AltF8  = #239;
  F9  = #195;      sF9  = #220;      CtrlF9  = #230;      AltF9  = #240;
  F10 = #196;      sF10 = #221;      CtrlF10 = #231;      AltF10 = #241;
  F11 = #139;      sF11 = #141;      CtrlF11 = #154;      AltF11 = #156;
  F12 = #140;      sF12 = #142;      CtrlF12 = #155;      AltF12 = #157;

  Key  : Char = #0;

Var
  NextOn        : ^Word Absolute $0040:$001A;    {keyboard buffer}
  NextOff       : ^Word Absolute $0040:$001C;    {keyboard buffer}
  KeyStatusBits : Word    Absolute $0040:$0017;  {keyboard buffer}
  KeyStatus : Record
     RShift, LShift,
     RCtrl,  LCtrl,
     RAlt,   LAlt,
     Caps,   CapsON,
     Ins,    InsON,
     Scroll, ScrlON,
     Num,    NumON          : Boolean;
  end;

Procedure GetKeyStatus;   { Changes KeyStatus Variable }
Const Old : Word = 0;
begin
  Old := KeyStatusBits;
  FillChar(KeyStatus,SizeOf(KeyStatus),0);
  With KeyStatus do
  begin
   RShift := ((Old Shr 0 ) and 1) = 1;
   LShift := ((Old Shr 1 ) and 1) = 1;
   RCtrl  := ((Old Shr 2 ) and 1) = 1;  { Test For either CTRL Key }
   RAlt   := ((Old Shr 3 ) and 1) = 1;  { Test For either Alt Key }
   ScrlON := ((Old Shr 4 ) and 1) = 1;  { Is Scroll Lock light on }
   NumON  := ((Old Shr 5 ) and 1) = 1;  { Is Num Lock light on }
   CapsON := ((Old Shr 6 ) and 1) = 1;  { Is Caps Lock light on }
   InsON  := ((Old Shr 7 ) and 1) = 1;  { Is Insert State on }
   LCtrl  := ((Old Shr 8 ) and 1) = 1;  { This also sets bit 3 }
   LAlt   := ((Old Shr 9 ) and 1) = 1;  { This also sets bit 4 }
   Scroll := ((Old Shr 12) and 1) = 1;  { This toggles bit 5 }
   Num    := ((Old Shr 13) and 1) = 1;  { This toggles bit 6 }
   Caps   := ((Old Shr 14) and 1) = 1;  { This toggles bit 7 }
   Ins    := ((Old Shr 15) and 1) = 1;  { This toggles bit 8 }
  end;
end; { }

Function GetKey : Char;
begin
  If KeyPressed then         { Test For BIOS key pressed }
   begin
     Key := ReadKey;          { Basic BIOS Keyboard Entry }
     if Key = #0 then
     begin
       Key := ReadKey;
       Inc(Key,128);          { Make Expanded key codes one Byte }
     end; { }
   end else Key := #0;
   GetKey := Key;
end; { }

Procedure FlushBuffer;
begin
  Move(NextOn,NextOff,SizeOf(NextOn));
end; { }

Var test : Char ;
begin
  ClrScr;
  WriteLN('Press Both Shift Keys to end');
  Repeat
    GetKeyStatus;
    Test := GetKey;
    if Test <> #0 Then Write(Test);

  Until (KeyStatus.RShift and KeyStatus.LShift);
end.
