(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0039.PAS
  Description: Re: Output to 26th line
  Author: KELD R. HANSEN
  Date: 08-30-96  09:35
*)

{
Can you tell me how to get 480 scan lines going in text mode.
Sure (routine assumes a global variable VGA that tells if running on a VGA
system or not, as the function is only available on VGA compatible cards):}

PROCEDURE SetScanLines(No : WORD); ASSEMBLER;
  ASM
                CMP     VGA,TRUE                { Test if VGA card!!    }
                JNE     @OUT
                CMP     No,480
                JE      @Set480
                MOV     AX,1200h
                MOV     BX,No
                CMP     BX,200
                JE      @SET
                INC     AX
                CMP     BX,350
                JE      @SET
                CMP     BX,400
                JNE     @OUT
                INC     AX
        @SET:   MOV     BL,30h
                INT     10h
                JMP     @OUT
        @Set480:MOV     DX,03CCh                { Set Sync-Polarity     }
                IN      AL,DX
                OR      AL,$C0
                MOV     DX,03C2h
                OUT     DX,AL
                MOV     AL,6                    { Vertical Total        }
                MOV     DX,03D4h
                OUT     DX,AL
                MOV     AL,11                   { CRT Overflow          }
                MOV     DX,03D5h
                OUT     DX,AL
                MOV     AL,7
                DEC     DX
                OUT     DX,AL
                MOV     AL,62                   { Maximum Scan Line     }
                INC     DX
                OUT     DX,AL
                MOV     AL,9
                DEC     DX
                OUT     DX,AL
                MOV     AL,79                   { Start Vert. Retrace   }
                INC     DX
                OUT     DX,AL
                MOV     AL,16
                DEC     DX
                OUT     DX,AL
                MOV     AL,234                  { End Vertical Retrace  }
                INC     DX
                OUT     DX,AL
                MOV     AL,17
                DEC     DX
                OUT     DX,AL
                MOV     AL,140                  { Vert. Disp Enable End }
                INC     DX
                OUT     DX,AL
                MOV     AL,18
                DEC     DX
                OUT     DX,AL
                MOV     AL,223                  { Start Vert. Blanking  }
                INC     DX
                OUT     DX,AL
                MOV     AL,21
                DEC     DX
                OUT     DX,AL
                MOV     AL,231                  { End Vertical Blanking }
                INC     DX
                OUT     DX,AL
                MOV     AL,22
                DEC     DX
                OUT     DX,AL
                MOV     AL,4
                INC     DX
                OUT     DX,AL
        @OUT:
  END;

Keld "HeartWare" Hansen, Sysop 2:234/10.0

