(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0019.PAS
  Description: Complete color constants
  Author: JOSE ALMEIDA
  Date: 08-18-93  12:25
*)


UNIT HTcolors;

{ Complete set of all color attributes contants by their own names.
  Part of the Heartware Toolkit v2.00 (HTcolors.PAS) for Turbo Pascal.
  Author: Jose Almeida. P.O.Box 4185. 1504 Lisboa Codex. Portugal.
          I can also be reached at RIME network, site ->TIB or #5314.
  Feel completely free to use this source code in any way you want, and, if
  you do, please don't forget to mention my name, and, give me and Swag the
  proper credits. }

INTERFACE

const

  { black background }

  BlackOnBlack            : byte = $00;
  BlueOnBlack             : byte = $01;
  GreenOnBlack            : byte = $02;
  CyanOnBlack             : byte = $03;
  RedOnBlack              : byte = $04;
  MagentaOnBlack          : byte = $05;
  BrownOnBlack            : byte = $06;
  LtGrayOnBlack           : byte = $07;
  DkGrayOnBlack           : byte = $08;
  LtBlueOnBlack           : byte = $09;
  LtGreenOnBlack          : byte = $0A;
  LtCyanOnBlack           : byte = $0B;
  LtRedOnBlack            : byte = $0C;
  LtMagentaOnBlack        : byte = $0D;
  YellowOnBlack           : byte = $0E;
  WhiteOnBlack            : byte = $0F;

  { blue background }

  BlackOnBlue             : byte = $10;
  BlueOnBlue              : byte = $11;
  GreenOnBlue             : byte = $12;
  CyanOnBlue              : byte = $13;
  RedOnBlue               : byte = $14;
  MagentaOnBlue           : byte = $15;
  BrownOnBlue             : byte = $16;
  LtGrayOnBlue            : byte = $17;
  DkGrayOnBlue            : byte = $18;
  LtBlueOnBlue            : byte = $19;
  LtGreenOnBlue           : byte = $1A;
  LtCyanOnBlue            : byte = $1B;
  LtRedOnBlue             : byte = $1C;
  LtMagentaOnBlue         : byte = $1D;
  YellowOnBlue            : byte = $1E;
  WhiteOnBlue             : byte = $1F;

  { green background }

  BlackOnGreen            : byte = $20;
  BlueOnGreen             : byte = $21;
  GreenOnGreen            : byte = $22;
  CyanOnGreen             : byte = $23;
  RedOnGreen              : byte = $24;
  MagentaOnGreen          : byte = $25;
  BrownOnGreen            : byte = $26;
  LtGrayOnGreen           : byte = $27;
  DkGrayOnGreen           : byte = $28;
  LtBlueOnGreen           : byte = $29;
  LtGreenOnGreen          : byte = $2A;
  LtCyanOnGreen           : byte = $2B;
  LtRedOnGreen            : byte = $2C;
  LtMagentaOnGreen        : byte = $2D;
  YellowOnGreen           : byte = $2E;
  WhiteOnGreen            : byte = $2F;

  { cyan background }

  BlackOnCyan             : byte = $30;
  BlueOnCyan              : byte = $31;
  GreenOnCyan             : byte = $32;
  CyanOnCyan              : byte = $33;
  RedOnCyan               : byte = $34;
  MagentaOnCyan           : byte = $35;
  BrownOnCyan             : byte = $36;
  LtGrayOnCyan            : byte = $37;
  DkGrayOnCyan            : byte = $38;
  LtBlueOnCyan            : byte = $39;
  LtGreenOnCyan           : byte = $3A;
  LtCyanOnCyan            : byte = $3B;
  LtRedOnCyan             : byte = $3C;
  LtMagentaOnCyan         : byte = $3D;
  YellowOnCyan            : byte = $3E;
  WhiteOnCyan             : byte = $3F;

  { red background }

  BlackOnRed              : byte = $40;
  BlueOnRed               : byte = $41;
  GreenOnRed              : byte = $42;
  CyanOnRed               : byte = $43;
  RedOnRed                : byte = $44;
  MagentaOnRed            : byte = $45;
  BrownOnRed              : byte = $46;
  LtGrayOnRed             : byte = $47;
  DkGrayOnRed             : byte = $48;
  LtBlueOnRed             : byte = $49;
  LtGreenOnRed            : byte = $4A;
  LtCyanOnRed             : byte = $4B;
  LtRedOnRed              : byte = $4C;
  LtMagentaOnRed          : byte = $4D;
  YellowOnRed             : byte = $4E;
  WhiteOnRed              : byte = $4F;

  { magenta background }

  BlackOnMagenta          : byte = $50;
  BlueOnMagenta           : byte = $51;
  GreenOnMagenta          : byte = $52;
  CyanOnMagenta           : byte = $53;
  RedOnMagenta            : byte = $54;
  MagentaOnMagenta        : byte = $55;
  BrownOnMagenta          : byte = $56;
  LtGrayOnMagenta         : byte = $57;
  DkGrayOnMagenta         : byte = $58;
  LtBlueOnMagenta         : byte = $59;
  LtGreenOnMagenta        : byte = $5A;
  LtCyanOnMagenta         : byte = $5B;
  LtRedOnMagenta          : byte = $5C;
  LtMagentaOnMagenta      : byte = $5D;
  YellowOnMagenta         : byte = $5E;
  WhiteOnMagenta          : byte = $5F;

  { brown background }

  BlackOnBrown            : byte = $60;
  BlueOnBrown             : byte = $61;
  GreenOnBrown            : byte = $62;
  CyanOnBrown             : byte = $63;
  RedOnBrown              : byte = $64;
  MagentaOnBrown          : byte = $65;
  BrownOnBrown            : byte = $66;
  LtGrayOnBrown           : byte = $67;
  DkGrayOnBrown           : byte = $68;
  LtBlueOnBrown           : byte = $69;
  LtGreenOnBrown          : byte = $6A;
  LtCyanOnBrown           : byte = $6B;
  LtRedOnBrown            : byte = $6C;
  LtMagentaOnBrown        : byte = $6D;
  YellowOnBrown           : byte = $6E;
  WhiteOnBrown            : byte = $6F;

  { light gray background }

  BlackOnLtGray           : byte = $70;
  BlueOnLtGray            : byte = $71;
  GreenOnLtGray           : byte = $72;
  CyanOnLtGray            : byte = $73;
  RedOnLtGray             : byte = $74;
  MagentaOnLtGray         : byte = $75;
  BrownOnLtGray           : byte = $76;
  LtGrayOnLtGray          : byte = $77;
  DkGrayOnLtGray          : byte = $78;
  LtBlueOnLtGray          : byte = $79;
  LtGreenOnLtGray         : byte = $7A;
  LtCyanOnLtGray          : byte = $7B;
  LtRedOnLtGray           : byte = $7C;
  LtMagentaOnLtGray       : byte = $7D;
  YellowOnLtGray          : byte = $7E;
  WhiteOnLtGray           : byte = $7F;

  {·········································································}

  { black background blinking }

  BlackOnBlackBlink       : byte = $80;
  BlueOnBlackBlink        : byte = $81;
  GreenOnBlackBlink       : byte = $82;
  CyanOnBlackBlink        : byte = $83;
  RedOnBlackBlink         : byte = $84;
  MagentaOnBlackBlink     : byte = $85;
  BrownOnBlackBlink       : byte = $86;
  LtGrayOnBlackBlink      : byte = $87;
  DkGrayOnBlackBlink      : byte = $88;
  LtBlueOnBlackBlink      : byte = $89;
  LtGreenOnBlackBlink     : byte = $8A;
  LtCyanOnBlackBlink      : byte = $8B;
  LtRedOnBlackBlink       : byte = $8C;
  LtMagentaOnBlackBlink   : byte = $8D;
  YellowOnBlackBlink      : byte = $8E;
  WhiteOnBlackBlink       : byte = $8F;

  { blue background blinking }

  BlackOnBlueBlink        : byte = $90;
  BlueOnBlueBlink         : byte = $91;
  GreenOnBlueBlink        : byte = $92;
  CyanOnBlueBlink         : byte = $93;
  RedOnBlueBlink          : byte = $94;
  MagentaOnBlueBlink      : byte = $95;
  BrownOnBlueBlink        : byte = $96;
  LtGrayOnBlueBlink       : byte = $97;
  DkGrayOnBlueBlink       : byte = $98;
  LtBlueOnBlueBlink       : byte = $99;
  LtGreenOnBlueBlink      : byte = $9A;
  LtCyanOnBlueBlink       : byte = $9B;
  LtRedOnBlueBlink        : byte = $9C;
  LtMagentaOnBlueBlink    : byte = $9D;
  YellowOnBlueBlink       : byte = $9E;
  WhiteOnBlueBlink        : byte = $9F;

  { green background blinking }

  BlackOnGreenBlink       : byte = $A0;
  BlueOnGreenBlink        : byte = $A1;
  GreenOnGreenBlink       : byte = $A2;
  CyanOnGreenBlink        : byte = $A3;
  RedOnGreenBlink         : byte = $A4;
  MagentaOnGreenBlink     : byte = $A5;
  BrownOnGreenBlink       : byte = $A6;
  LtGrayOnGreenBlink      : byte = $A7;
  DkGrayOnGreenBlink      : byte = $A8;
  LtBlueOnGreenBlink      : byte = $A9;
  LtGreenOnGreenBlink     : byte = $AA;
  LtCyanOnGreenBlink      : byte = $AB;
  LtRedOnGreenBlink       : byte = $AC;
  LtMagentaOnGreenBlink   : byte = $AD;
  YellowOnGreenBlink      : byte = $AE;
  WhiteOnGreenBlink       : byte = $AF;

  { cyan background blinking }

  BlackOnCyanBlink        : byte = $B0;
  BlueOnCyanBlink         : byte = $B1;
  GreenOnCyanBlink        : byte = $B2;
  CyanOnCyanBlink         : byte = $B3;
  RedOnCyanBlink          : byte = $B4;
  MagentaOnCyanBlink      : byte = $B5;
  BrownOnCyanBlink        : byte = $B6;
  LtGrayOnCyanBlink       : byte = $B7;
  DkGrayOnCyanBlink       : byte = $B8;
  LtBlueOnCyanBlink       : byte = $B9;
  LtGreenOnCyanBlink      : byte = $BA;
  LtCyanOnCyanBlink       : byte = $BB;
  LtRedOnCyanBlink        : byte = $BC;
  LtMagentaOnCyanBlink    : byte = $BD;
  YellowOnCyanBlink       : byte = $BE;
  WhiteOnCyanBlink        : byte = $BF;

  { red background blinking }

  BlackOnRedBlink         : byte = $C0;
  BlueOnRedBlink          : byte = $C1;
  GreenOnRedBlink         : byte = $C2;
  CyanOnRedBlink          : byte = $C3;
  RedOnRedBlink           : byte = $C4;
  MagentaOnRedBlink       : byte = $C5;
  BrownOnRedBlink         : byte = $C6;
  LtGrayOnRedBlink        : byte = $C7;
  DkGrayOnRedBlink        : byte = $C8;
  LtBlueOnRedBlink        : byte = $C9;
  LtGreenOnRedBlink       : byte = $CA;
  LtCyanOnRedBlink        : byte = $CB;
  LtRedOnRedBlink         : byte = $CC;
  LtMagentaOnRedBlink     : byte = $CD;
  YellowOnRedBlink        : byte = $CE;
  WhiteOnRedBlink         : byte = $CF;

  { magenta background blinking }

  BlackOnMagentaBlink     : byte = $D0;
  BlueOnMagentaBlink      : byte = $D1;
  GreenOnMagentaBlink     : byte = $D2;
  CyanOnMagentaBlink      : byte = $D3;
  RedOnMagentaBlink       : byte = $D4;
  MagentaOnMagentaBlink   : byte = $D5;
  BrownOnMagentaBlink     : byte = $D6;
  LtGrayOnMagentaBlink    : byte = $D7;
  DkGrayOnMagentaBlink    : byte = $D8;
  LtBlueOnMagentaBlink    : byte = $D9;
  LtGreenOnMagentaBlink   : byte = $DA;
  LtCyanOnMagentaBlink    : byte = $DB;
  LtRedOnMagentaBlink     : byte = $DC;
  LtMagentaOnMagentaBlink : byte = $DD;
  YellowOnMagentaBlink    : byte = $DE;
  WhiteOnMagentaBlink     : byte = $DF;

  { brown background blinking }

  BlackOnBrownBlink       : byte = $E0;
  BlueOnBrownBlink        : byte = $E1;
  GreenOnBrownBlink       : byte = $E2;
  CyanOnBrownBlink        : byte = $E3;
  RedOnBrownBlink         : byte = $E4;
  MagentaOnBrownBlink     : byte = $E5;
  BrownOnBrownBlink       : byte = $E6;
  LtGrayOnBrownBlink      : byte = $E7;
  DkGrayOnBrownBlink      : byte = $E8;
  LtBlueOnBrownBlink      : byte = $E9;
  LtGreenOnBrownBlink     : byte = $EA;
  LtCyanOnBrownBlink      : byte = $EB;
  LtRedOnBrownBlink       : byte = $EC;
  LtMagentaOnBrownBlink   : byte = $ED;
  YellowOnBrownBlink      : byte = $EE;
  WhiteOnBrownBlink       : byte = $EF;

  { light gray background blinking }

  BlackOnLtGrayBlink      : byte = $F0;
  BlueOnLtGrayBlink       : byte = $F1;
  GreenOnLtGrayBlink      : byte = $F2;
  CyanOnLtGrayBlink       : byte = $F3;
  RedOnLtGrayBlink        : byte = $F4;
  MagentaOnLtGrayBlink    : byte = $F5;
  BrownOnLtGrayBlink      : byte = $F6;
  LtGrayOnLtGrayBlink     : byte = $F7;
  DkGrayOnLtGrayBlink     : byte = $F8;
  LtBlueOnLtGrayBlink     : byte = $F9;
  LtGreenOnLtGrayBlink    : byte = $FA;
  LtCyanOnLtGrayBlink     : byte = $FB;
  LtRedOnLtGrayBlink      : byte = $FC;
  LtMagentaOnLtGrayBlink  : byte = $FD;
  YellowOnLtGrayBlink     : byte = $FE;
  WhiteOnLtGrayBlink      : byte = $FF;



IMPLEMENTATION



END. { HTcolors.PAS }



