{
Check out Hax #179 from PC Techniques vol.4 no.6 Feb/Mar issue (page 70),
(coincidently written by me), where a small program is presented that'll not
only detect whether a VGA adapter is installed, but is also capable of putting
the screen in 80x12, 80x14, 80x21, 80x25, 80x28, 80x43 or 80x50 mode...}

{$IFDEF VER70}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S+,T-,V-,X-}
{$ELSE}
{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S+,V-,X-}
{$ENDIF}
{$M 1024,0,0}
{
  VGA 3.0
  Borland Pascal (Objects) 7.01
  Copr. (c) 7-17-1993 DwarFools & Consultancy drs. Robert E. Swart
                      P.O. box 799
                      5702 NP  Helmond
                      The Netherlands

  Code size: 3248 Bytes
  Data size:  676 Bytes
}
Const
  VGAInside: Boolean = False; { Assume no VGA-card is installed }

var VGALines,i: Integer;

    procedure Lines200;
    { Set 200 scanlines on VGA display }
    InLine(
      $B8/$03/$00/  {  mov   AX,$0003  }
      $CD/$10/      {  int   $10       }
      $B8/$00/$12/  {  mov   AX,$1200  }
      $B3/$30/      {  mov   BL,$30    }
      $CD/$10);     {  int   $10       }

    procedure Lines350;
    { Set 350 scanlines on VGA display }
    InLine(
      $B8/$03/$00/  {  mov   AX,$0003  }
      $CD/$10/      {  int   $10       }
      $B8/$01/$12/  {  mov   AX,$1201  }
      $B3/$30/      {  mov   BL,$30    }
      $CD/$10);     {  int   $10       }

    procedure Lines400;
    { Set 400 scanlines on VGA display }
    InLine(
      $B8/$03/$00/  {  mov   AX,$0003  }
      $CD/$10/      {  int   $10       }
      $B8/$02/$12/  {  mov   AX,$1202  }
      $B3/$30/      {  mov   BL,$30    }
      $CD/$10);     {  int   $10       }

    procedure Font8x8;
    { Set 8x8 CGA-font on VGA display. }
    InLine(
      $B8/$03/$00/  {  mov   AX,$0003  }
      $CD/$10/      {  int   $10       }
      $B8/$12/$11/  {  mov   AX,$1112  }
      $B3/$00/      {  mov   BL,0      }
      $CD/$10);     {  int   $10       }

    procedure Font8x14;
    { Set 8x14 EGA-font on VGA display }
    InLine(
      $B8/$03/$00/  {  mov   AX,$0003  }
      $CD/$10/      {  int   $10       }
      $B8/$11/$11/  {  mov   AX,$1111  }
      $B3/$00/      {  mov   BL,0      }
      $CD/$10);     {  int   $10       }

    procedure Font8x16;
    { Set 8x16 VGA-font on VGA display }
    InLine(
      $B8/$03/$00/  {  mov   AX,$0003  }
      $CD/$10/      {  int   $10       }
      $B8/$14/$11/  {  mov   AX,$1114  }
      $B3/$00/      {  mov   BL,0      }
      $CD/$10);     {  int   $10       }


begin
  writeln('VGALines 3.0 (c) 1993 DwarFools & Consultancy' +
                         ', by drs. Robert E. Swart.'#13#10);
  ASM { Detect VGA display }
        mov   AX,$0F00
        int   $10
        cmp   AL,$03   { TextMode = CO80 }
        jne   @End
        mov   AX,$1C00
        mov   CX,$0007
        int   $10
        cmp   AL,$1C
        jne   @End
        mov   VGAInside,True { VGA display installed }
  @End:
  end { VGA display };

  Val(ParamStr(1),VGALines,i);

  if not ((ParamCount >= 1) and VGAInside and (i = 0) and
          (VGALines in [12,14,21,25,28,43,50])) then
  begin
    writeln('Usage: VGALines #Lines [test]'#13#10);
    writeln('Where #Lines is any of [12,14,21,25,28,43,50]':52);
    if not VGAInside then
      writeln(#13#10'Error: VGA display required!');
    Halt
  end;

  case VGALines of { first set scan-lines }
  12,14: Lines200;
  21,43: Lines350;
    else Lines400
  end;

  case VGALines of { then select the font }
  43,50: Font8x8;
  14,28: Font8x14;
    else Font8x16
  end;

  if ParamCount > 1 then { test parameter is used }
  begin
    for i:=0 to VGALines-1 do writeln(i);
    write(VGALines,' lines set.')
  end
end.
