(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0005.PAS
  Description: GLOBALS.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

Unit globals;

{ Use this Unit For Procedures, Functions and Variables that every Program you
  Write will share.
}

Interface

Uses 
  Dos;
  
Type
  str1 = String[1]; str2 = String[2]; str3 = String[3];
  str4 = String[4]; str5 = String[5]; str6 = String[6];
  str7 = String[7]; str8 = String[8]; str9 = String[9];
  str10 = String[10]; str11 = String[11]; str12 = String[12];
  str13 = String[13]; str14 = String[14]; str15 = String[15];
  str16 = String[16]; str17 = String[17]; str18 = String[18];
  str19 = String[19]; str20 = String[20]; str21 = String[21];
  str22 = String[22]; str23 = String[23]; str24 = String[24];
  str25 = String[25]; str26 = String[26]; str27 = String[27];
  str28 = String[28]; str29 = String[29]; str30 = String[30];
  str31 = String[31]; str32 = String[32]; str33 = String[33];
  str34 = String[34]; str35 = String[35]; str36 = String[36];
  str37 = String[37]; str38 = String[38]; str39 = String[39];
  str40 = String[40]; str41 = String[41]; str42 = String[42];
  str43 = String[43]; str44 = String[44]; str45 = String[45];
  str46 = String[46]; str47 = String[47]; str48 = String[48];
  str49 = String[49]; str50 = String[50]; str51 = String[51];
  str52 = String[52]; str53 = String[53]; str54 = String[54];
  str55 = String[55]; str56 = String[56]; str57 = String[57];
  str58 = String[58]; str59 = String[59]; str60 = String[60];
  str61 = String[61]; str62 = String[62]; str63 = String[63];
  str64 = String[64]; str65 = String[65]; str66 = String[66];
  str67 = String[67]; str68 = String[68]; str69 = String[69];
  str70 = String[70]; str71 = String[71]; str72 = String[72];
  str73 = String[73]; str74 = String[74]; str75 = String[75];
  str76 = String[76]; str77 = String[77]; str78 = String[78];
  str79 = String[79]; str80 = String[80]; str81 = String[81];
  str82 = String[82]; str83 = String[83]; str84 = String[84];
  str85 = String[85]; str86 = String[86]; str87 = String[87];
  str88 = String[88]; str89 = String[89]; str90 = String[90];
  str91 = String[91]; str92 = String[92]; str93 = String[93];
  str94 = String[94]; str95 = String[95]; str96 = String[96];
  str97 = String[97]; str98 = String[98]; str99 = String[99];
  str100 = String[100]; str101 = String[101]; str102 = String[102];
  str103 = String[103]; str104 = String[104]; str105 = String[105];
  str106 = String[106]; str107 = String[107]; str108 = String[108];
  str109 = String[109]; str110 = String[110]; str111 = String[111];
  str112 = String[112]; str113 = String[113]; str114 = String[114];
  str115 = String[115]; str116 = String[116]; str117 = String[117];
  str118 = String[118]; str119 = String[119]; str120 = String[120];
  str121 = String[121]; str122 = String[122]; str123 = String[123];
  str124 = String[124]; str125 = String[125]; str126 = String[126];
  str127 = String[127]; str128 = String[128]; str129 = String[129];
  str130 = String[130]; str131 = String[131]; str132 = String[132];
  str133 = String[133]; str134 = String[134]; str135 = String[135];
  str136 = String[136]; str137 = String[137]; str138 = String[138];
  str139 = String[139]; str140 = String[140]; str141 = String[141];
  str142 = String[142]; str143 = String[143]; str144 = String[144];
  str145 = String[145]; str146 = String[146]; str147 = String[147];
  str148 = String[148]; str149 = String[149]; str150 = String[150];
  str151 = String[151]; str152 = String[152]; str153 = String[153];
  str154 = String[154]; str155 = String[155]; str156 = String[156];
  str157 = String[157]; str158 = String[158]; str159 = String[159];
  str160 = String[160]; str161 = String[161]; str162 = String[162];
  str163 = String[163]; str164 = String[164]; str165 = String[165];
  str166 = String[166]; str167 = String[167]; str168 = String[168];
  str169 = String[169]; str170 = String[170]; str171 = String[171];
  str172 = String[172]; str173 = String[173]; str174 = String[174];
  str175 = String[175]; str176 = String[176]; str177 = String[177];
  str178 = String[178]; str179 = String[179]; str180 = String[180];
  str181 = String[181]; str182 = String[182]; str183 = String[183];
  str184 = String[184]; str185 = String[185]; str186 = String[186];
  str187 = String[187]; str188 = String[188]; str189 = String[189];
  str190 = String[190]; str191 = String[191]; str192 = String[192];
  str193 = String[193]; str194 = String[194]; str195 = String[195];
  str196 = String[196]; str197 = String[197]; str198 = String[198];
  str199 = String[199]; str200 = String[200]; str201 = String[201];
  str202 = String[202]; str203 = String[203]; str204 = String[204];
  str205 = String[205]; str206 = String[206]; str207 = String[207];
  str208 = String[208]; str209 = String[209]; str210 = String[210];
  str211 = String[211]; str212 = String[212]; str213 = String[213];
  str214 = String[214]; str215 = String[215]; str216 = String[216];
  str217 = String[217]; str218 = String[218]; str219 = String[219];
  str220 = String[220]; str221 = String[221]; str222 = String[222];
  str223 = String[223]; str224 = String[224]; str225 = String[225];
  str226 = String[226]; str227 = String[227]; str228 = String[228];
  str229 = String[229]; str230 = String[230]; str231 = String[231];
  str232 = String[232]; str233 = String[233]; str234 = String[234];
  str235 = String[235]; str236 = String[236]; str237 = String[237];
  str238 = String[238]; str239 = String[239]; str240 = String[240];
  str241 = String[241]; str242 = String[242]; str243 = String[243];
  str244 = String[244]; str245 = String[245]; str246 = String[246];
  str247 = String[247]; str248 = String[248]; str249 = String[249];
  str250 = String[250]; str251 = String[251]; str252 = String[252];
  str253 = String[253]; str254 = String[254]; str255 = String[255];

Const
  MaxWord    = $ffff;
  MinWord    = 0;
  MinInt     = Integer($8000);
  MinLongInt = $80000000;
  UseCfg     = True;

  {Color Constants:
   Black     = 0; Blue   = 1; Green   = 2; Cyan   = 3; Red   = 4;
   Magenta   = 5; Brown  = 6; LtGray  = 7;
   DkGray    = 8; LtBlue = 9; LtGreen = A; LtCyan = B; LtRed = C;
   LtMagenta = D; Yellow = E; White   = F
   }

Const  Blink               = $80;

  {Screen color Constants}
Const   BlackOnBlack       = $00;          BlueOnBlack        = $01;
Const   BlackOnBlue        = $10;          BlueOnBlue         = $11;
Const   BlackOnGreen       = $20;          BlueOnGreen        = $21;
Const   BlackOnCyan        = $30;          BlueOnCyan         = $31;
Const   BlackOnRed         = $40;          BlueOnRed          = $41;
Const   BlackOnMagenta     = $50;          BlueOnMagenta      = $51;
Const   BlackOnBrown       = $60;          BlueOnBrown        = $61;
Const   BlackOnLtGray      = $70;          BlueOnLtGray       = $71;
Const   GreenOnBlack       = $02;          CyanOnBlack        = $03;
Const   GreenOnBlue        = $12;          CyanOnBlue         = $13;
Const   GreenOnGreen       = $22;          CyanOnGreen        = $23;
Const   GreenOnCyan        = $32;          CyanOnCyan         = $33;
Const   GreenOnRed         = $42;          CyanOnRed          = $43;
Const   GreenOnMagenta     = $52;          CyanOnMagenta      = $53;
Const   GreenOnBrown       = $62;          CyanOnBrown        = $63;
Const   GreenOnLtGray      = $72;          CyanOnLtGray       = $73;
Const   RedOnBlue          = $14;          MagentaOnBlue      = $15;
Const   RedOnGreen         = $24;          MagentaOnGreen     = $25;
Const   RedOnCyan          = $34;          MagentaOnCyan      = $35;
Const   RedOnRed           = $44;          MagentaOnRed       = $45;
Const   RedOnMagenta       = $54;          MagentaOnMagenta   = $55;
Const   RedOnBrown         = $64;          MagentaOnBrown     = $65;
Const   RedOnLtGray        = $74;          MagentaOnLtGray    = $75;
Const   BrownOnBlack       = $06;          LtGrayOnBlack      = $07;
Const   BrownOnBlue        = $16;          LtGrayOnBlue       = $17;
Const   BrownOnGreen       = $26;          LtGrayOnGreen      = $27;
Const   BrownOnCyan        = $36;          LtGrayOnCyan       = $37;
Const   BrownOnRed         = $46;          LtGrayOnRed        = $47;
Const   BrownOnMagenta     = $56;          LtGrayOnMagenta    = $57;
Const   BrownOnBrown       = $66;          LtGrayOnBrown      = $67;
Const   BrownOnLtGray      = $76;          LtGrayOnLtGray     = $77;
Const   DkGrayOnBlack      = $08;          LtBlueOnBlack      = $09;
Const   DkGrayOnBlue       = $18;          LtBlueOnBlue       = $19;
Const   DkGrayOnGreen      = $28;          LtBlueOnGreen      = $29;
Const   DkGrayOnCyan       = $38;          LtBlueOnCyan       = $39;
Const   DkGrayOnRed        = $48;          LtBlueOnRed        = $49;
Const   DkGrayOnMagenta    = $58;          LtBlueOnMagenta    = $59;
Const   DkGrayOnBrown      = $68;          LtBlueOnBrown      = $69;
Const   DkGrayOnLtGray     = $78;          LtBlueOnLtGray     = $79;
Const   LtGreenOnBlack     = $0A;          LtCyanOnBlack      = $0B;
Const   LtGreenOnBlue      = $1A;          LtCyanOnBlue       = $1B;
Const   LtGreenOnGreen     = $2A;          LtCyanOnGreen      = $2B;
Const   LtGreenOnCyan      = $3A;          LtCyanOnCyan       = $3B;
Const   LtGreenOnRed       = $4A;          LtCyanOnRed        = $4B;
Const   LtGreenOnMagenta   = $5A;          LtCyanOnMagenta    = $5B;
Const   LtGreenOnBrown     = $6A;          LtCyanOnBrown      = $6B;
Const   LtGreenOnLtGray    = $7A;          LtCyanOnLtGray     = $7B;
Const   LtRedOnBlue        = $1C;          LtMagentaOnBlue    = $1D;
Const   LtRedOnGreen       = $2C;          LtMagentaOnGreen   = $2D;
Const   LtRedOnCyan        = $3C;          LtMagentaOnCyan    = $3D;
Const   LtRedOnRed         = $4C;          LtMagentaOnRed     = $4D;
Const   LtRedOnMagenta     = $5C;          LtMagentaOnMagenta = $5D;
Const   LtRedOnBrown       = $6C;          LtMagentaOnBrown   = $6D;
Const   LtRedOnLtGray      = $7C;          LtMagentaOnLtGray  = $7D;
Const   YellowOnBlack      = $0E;          WhiteOnBlack       = $0F;
Const   YellowOnBlue       = $1E;          WhiteOnBlue        = $1F;
Const   YellowOnGreen      = $2E;          WhiteOnGreen       = $2F;
Const   YellowOnCyan       = $3E;          WhiteOnCyan        = $3F;
Const   YellowOnRed        = $4E;          WhiteOnRed         = $4F;
Const   YellowOnMagenta    = $5E;          WhiteOnMagenta     = $5F;
Const   YellowOnBrown      = $6E;          WhiteOnBrown       = $6F;
Const   YellowOnLtGray     = $7E;          WhiteOnLtGray      = $7F;
Const   BlackOnDkGray     = Blink + $00;   BlueOnDkGray      = Blink + $01;
Const   BlackOnLtBlue     = Blink + $10;   BlueOnLtBlue      = Blink + $11;
Const   BlackOnLtGreen    = Blink + $20;   BlueOnLtGreen     = Blink + $21;
Const   BlackOnLtCyan     = Blink + $30;   BlueOnLtCyan      = Blink + $31;
Const   BlackOnLtRed      = Blink + $40;   BlueOnLtRed       = Blink + $41;
Const   BlackOnLtMagenta  = Blink + $50;   BlueOnLtMagenta   = Blink + $51;
Const   BlackOnYellow     = Blink + $60;   BlueOnYellow      = Blink + $61;
Const   BlackOnWhite      = Blink + $70;   BlueOnWhite       = Blink + $71;
Const   GreenOnDkGray     = Blink + $02;   CyanOnDkGray      = Blink + $03;
Const   GreenOnLtBlue     = Blink + $12;   CyanOnLtBlue      = Blink + $13;
Const   GreenOnLtGreen    = Blink + $22;   CyanOnLtGreen     = Blink + $23;
Const   GreenOnLtCyan     = Blink + $32;   CyanOnLtCyan      = Blink + $33;
Const   GreenOnLtRed      = Blink + $42;   CyanOnLtRed       = Blink + $43;
Const   GreenOnLtMagenta  = Blink + $52;   CyanOnLtMagenta   = Blink + $53;
Const   GreenOnYellow     = Blink + $62;   CyanOnYellow      = Blink + $63;
Const   GreenOnWhite      = Blink + $72;   CyanOnWhite       = Blink + $73;
Const   RedOnDkGray       = Blink + $04;   MagentaOnDkGray   = Blink + $05;
Const   RedOnLtBlue       = Blink + $14;   MagentaOnLtBlue   = Blink + $15;
Const   RedOnLtGreen      = Blink + $24;   MagentaOnLtGreen  = Blink + $25;
Const   RedOnLtCyan       = Blink + $34;   MagentaOnLtCyan   = Blink + $35;
Const   RedOnLtRed        = Blink + $44;   MagentaOnLtRed    = Blink + $45;
Const   RedOnLtMagenta    = Blink + $54;   MagentaOnLtMagenta= Blink + $55;
Const   RedOnYellow       = Blink + $64;   MagentaOnYellow   = Blink + $65;
Const   RedOnWhite        = Blink + $74;   MagentaOnWhite    = Blink + $75;
Const   BrownOnDkGray     = Blink + $06;   LtGrayOnDkGray    = Blink + $07;
Const   BrownOnLtBlue     = Blink + $16;   LtGrayOnLtBlue    = Blink + $17;
Const   BrownOnLtGreen    = Blink + $26;   LtGrayOnLtGreen   = Blink + $27;
Const   BrownOnLtCyan     = Blink + $36;   LtGrayOnLtCyan    = Blink + $37;
Const   BrownOnLtRed      = Blink + $46;   LtGrayOnLtRed     = Blink + $47;
Const   BrownOnLtMagenta  = Blink + $56;   LtGrayOnLtMagenta = Blink + $57;
Const   BrownOnYellow     = Blink + $66;   LtGrayOnYellow    = Blink + $67;
Const   BrownOnWhite      = Blink + $76;   LtGrayOnWhite     = Blink + $77;
Const   DkGrayOnDkGray    = Blink + $08;   LtBlueOnDkGray    = Blink + $09;
Const   DkGrayOnLtBlue    = Blink + $18;   LtBlueOnLtBlue    = Blink + $19;
Const   DkGrayOnLtGreen   = Blink + $28;   LtBlueOnLtGreen   = Blink + $29;
Const   DkGrayOnLtCyan    = Blink + $38;   LtBlueOnLtCyan    = Blink + $39;
Const   DkGrayOnLtRed     = Blink + $48;   LtBlueOnLtRed     = Blink + $49;
Const   DkGrayOnLtMagenta = Blink + $58;   LtBlueOnLtMagenta = Blink + $59;
Const   DkGrayOnYellow    = Blink + $68;   LtBlueOnYellow    = Blink + $69;
Const   DkGrayOnWhite     = Blink + $78;   LtBlueOnWhite     = Blink + $79;
Const   LtGreenOnDkGray   = Blink + $0A;   LtCyanOnDkGray    = Blink + $0B;
Const   LtGreenOnLtBlue   = Blink + $1A;   LtCyanOnLtBlue    = Blink + $1B;
Const   LtGreenOnLtGreen  = Blink + $2A;   LtCyanOnLtGreen   = Blink + $2B;
Const   LtGreenOnLtCyan   = Blink + $3A;   LtCyanOnLtCyan    = Blink + $3B;
Const   LtGreenOnLtRed    = Blink + $4A;   LtCyanOnLtRed     = Blink + $4B;
Const   LtGreenOnLtMagenta= Blink + $5A;   LtCyanOnLtMagenta = Blink + $5B;
Const   LtGreenOnYellow   = Blink + $6A;   LtCyanOnYellow    = Blink + $6B;
Const   LtGreenOnWhite    = Blink + $7A;   LtCyanOnWhite     = Blink + $7B;
Const   LtRedOnDkGray     = Blink + $0C;   LtMagentaOnDkGray = Blink + $0D;
Const   LtRedOnLtBlue     = Blink + $1C;   LtMagentaOnLtBlue = Blink + $1D;
Const   LtRedOnLtGreen    = Blink + $2C;   LtMagentaOnLtGreen= Blink + $2D;
Const   LtRedOnLtCyan     = Blink + $3C;   LtMagentaOnLtCyan = Blink + $3D;
Const   LtRedOnLtRed      = Blink + $4C;   LtMagentaOnLtRed  = Blink + $4D;
Const   LtRedOnLtMagenta  = Blink + $5C;   LtMagentaOnLtMagenta= Blink + $5D;
Const   LtRedOnYellow     = Blink + $6C;   LtMagentaOnYellow = Blink + $6D;
Const   LtRedOnWhite      = Blink + $7C;   LtMagentaOnWhite  = Blink + $7D;
Const   YellowOnDkGray    = Blink + $0E;   WhiteOnDkGray     = Blink + $0F;
Const   YellowOnLtBlue    = Blink + $1E;   WhiteOnLtBlue     = Blink + $1F;
Const   YellowOnLtGreen   = Blink + $2E;   WhiteOnLtGreen    = Blink + $2F;
Const   YellowOnLtCyan    = Blink + $3E;   WhiteOnLtCyan     = Blink + $3F;
Const   YellowOnLtRed     = Blink + $4E;   WhiteOnLtRed      = Blink + $4F;
Const   YellowOnLtMagenta = Blink + $5E;   WhiteOnLtMagenta  = Blink + $5F;
Const   YellowOnYellow    = Blink + $6E;   WhiteOnYellow     = Blink + $6F;
Const   YellowOnWhite     = Blink + $7E;   WhiteOnWhite      = Blink + $7F;

Var
  TempStr    : String;
  TempStrLen : Byte Absolute TempStr;
  
Function Exist(fn: str80): Boolean;
{ Returns True if File fn exists in the current directory                    }

Function ExistsOnPath(Var fn: str80): Boolean;
{ Returns True if File fn exists in any directory specified in the current   }
{ path and changes fn to a fully qualified path/File.                        }

Function StrUpCase(s : String): String;
{ Returns an upper Case String from s. Applicable to the English language.   }

Function StrLowCase(s : String): String;
{ Returns a String = to s With all upper Case Characters converted to lower  }

Function Asc2Str(Var s; max: Byte): String;
{ Converts an ASCIIZ String to a Turbo Pascal String With a maximum length   }
{ of max Characters.                                                         }

Procedure Str2Asc(s: String; Var ascStr; max: Word);
{ Converts a TP String to an ASCIIZ String of no more than max length.       }
{ WARNinG:  No checks are made that there is sufficient room in destination  }
{           Variable.                                                        }

Function LastPos(ch: Char; s: String): Byte;
{ Returns the last position of ch in s                                       }

Procedure CheckIO(a: Byte);

Implementation

Function Exist(fn: str80): Boolean;
  begin
    TempStrLen := 0;
    TempStr    := FSearch(fn,'');
    Exist      := TempStrLen <> 0;
  end; { Exist }

Function ExistsOnPath(Var fn: str80): Boolean;
  begin
    TempStrLen   := 0;
    TempStr      := FSearch(fn,GetEnv('PATH'));
    ExistsOnPath := TempStrLen <> 0;
    fn           := FExpand(TempStr);
  end; { ExistsOnPath }

Function StrUpCase(s : String): String;
  Var x : Byte;
  begin
    StrUpCase[0] := s[0];
    For x := 1 to length(s) do
      StrUpCase[x] := UpCase(s[x]);
  end; { StrUpCase }

Function StrLowCase(s : String): String;
  Var x : Byte;
  begin
    StrLowCase[0] := s[0];
    For x := 1 to length(s) do
      Case s[x] of
      'a'..'z': StrLowCase[x] := chr(ord(s[x]) and $df);
      else StrLowCase[x] := s[x];
      end; { Case }
  end; { StrLowCase }

Function Asc2Str(Var s; max: Byte): String;
  Var stArray  : Array[1..255] of Char Absolute s;
      len      : Integer;
  begin
    len        := pos(#0,stArray)-1;                       { Get the length }
    if (len > max) or (len < 0) then               { length exceeds maximum }
      len      := max;                                  { so set to maximum }
    Asc2Str    := stArray;
    Asc2Str[0] := chr(len);                                    { Set length }
  end;  { Asc2Str }

Procedure Str2Asc(s: String; Var ascStr; max: Word);
  begin
    FillChar(AscStr,max,0);
    if length(s) < max then
      move(s[1],AscStr,length(s))
    else
      move(s[1],AscStr,max);
  end; { Str2Asc }


Function LastPos(ch: Char; s: String): Byte;
  Var x : Word;
  begin
    x := succ(length(s));
    Repeat
      dec(x);
    Until (s[x] = ch) or (x = 0);
  end; { LastPos }

Procedure CheckIO(a: Byte);
  Var e : Integer;
  begin
    e := Ioresult;
    if e <> 0 then begin
      Writeln('I/O error ',e,' section ',a);
      halt(e);
    end;
  end; { CheckIO }

end. { Globals }
  

