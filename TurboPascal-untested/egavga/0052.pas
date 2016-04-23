===========================================================================
 BBS: Canada Remote Systems
Date: 07-02-93 (14:00)             Number: 29054
From: SEAN PALMER                  Refer#: NONE
  To: FRANCIS BURIANEK              Recvd: NO  
Subj: DOS FONT                       Conf: (1221) F-PASCAL
---------------------------------------------------------------------------
FB>Would You know, where the Video Bios Fonts are located at? (address),
FB>or a way to access using an interrupt?

I pulled this off the echo a while back...

Type
  FontBlock    = 0..7;
  CharSetType  = (INT1F, INT43, ROM8x14, ROM8x8lo, ROM8x8hi, ROM9x14,
                 ROM8x16, ROM9x16);

{ Get a pointer to one of the eight resident VGA fonts }

Function GetFontPtr(charset : CharSetType) : Pointer; Assembler;ASM
        MOV    BH, charset
        MOV    AX,$1130
        INT    $10
        MOV    DX, ES
        XCHG   AX, BP
end;

{ Get font block index of current (resident) and alternate character set.
  Up to two fonts can be active at the same time }

Procedure GetFontBlock(Var primary, secondary : FontBlock); Assembler;ASM
  { Get character map select register:
    (VGA sequencer port 3C4h/3C5h index 3)

    7  6  5  4  3  2  1  0
          |  |  |  |  |  |
          |  |  |  |  +--+--   Primary font   (lower 2 bits)
          |  |  +--+--------   Secondary font (lower 2 bits)
          |  +--------------   Primary font   (high bit)
          +-----------------   Secondary font (high bit)     }

        MOV     AL, 3
        MOV     DX,$3C4
        OUT     DX, AL
        INC     DX
        IN      AL, DX
        MOV     BL, AL
        PUSH    AX
  { Get secondary font number: add up bits 5, 3 and 2 }
        SHR     AL, 1
        SHR     AL, 1
        AND     AL, 3
        TEST    BL,$20
        JZ      @1
        ADD     AL, 4
@1:     LES     DI, secondary
        STOSB
  { Get primary font number: add up bits 4, 1 and 0 }
        POP     AX
        AND     AL, 3
        TEST    BL,$10
        JZ      @2
        ADD     AL, 4
@2:     LES     DI, primary
        STOSB
end;

{ Store the font block index }

Procedure SetFontBlock(primary, secondary : FontBlock); Assembler;
Const
  MapPrimTable : Array[0..7] of Byte = ($00, $01, $02, $03,$10, $11, $12, $13);
  MapSecTable  : Array[0..7] of Byte = ($00, $04, $08, $0C,$20, $24, $28, $2C);
ASM
        MOV     AL, primary
        LEA     BX, MapPrimTable
        XLAT
        MOV     AH, AL
        MOV     AL, secondary
        LEA     BX, MapSecTable
        XLAT
        ADD     AL, AH
        MOV     BL, AL
{ Set block specifier }
        MOV     AX,$1103
        INT     $10
end;


 * OLX 2.2 * If at first you succeed, hide your astonishment...

--- Maximus 2.01wb
 * Origin: >>> Sun Mountain BBS <<< (303)-665-6922 (1:104/123)
