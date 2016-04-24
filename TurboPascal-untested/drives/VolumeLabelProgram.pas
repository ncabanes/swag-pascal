(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0081.PAS
  Description: VOLUME LABEL Program
  Author: GREG VIGNEAULT
  Date: 08-25-94  09:11
*)

{
>Can someone please tell me how to read the volume label off a hard
>disk or floppy. I haven't been able to find any information on how
>to do this.  Thanks for any help you can offer.

 Here's one way, which is valid for DOS 3.0 or higher...

}
PROGRAM VOLAB;                    { Read a disk volume label (TP4+) }
                                  { June 12, 1994. Greg Vigneault   }
USES  Dos;                              { import MsDos, Registers   }
TYPE  ASCIIZ  = ARRAY [0..255] OF CHAR; { ASCIIZ strings            }
CONST TAB     = #9;                     { ASCII horizontal tab      }
VAR   Drv     : CHAR;                   { drive letter 'A'..'Z'     }
      Volume  : STRING;                 { for volume label          }
      Reg     : Registers;              { to access CPU registers   }

PROCEDURE Asciiz2TP (AStr:ASCIIZ; VAR Temp:STRING);
  { convert an ASCIIZ (DOS) string to a TP string }
  VAR Index:BYTE; BEGIN  Index := 0;
    WHILE (Index < 255) AND (AStr[Index] <> #0) DO BEGIN
      Temp[Index+1] := AStr[Index];;  INC(Index);
    END{WHILE};;  Temp[0] := CHR(Index);
  END {Asciiz2TP};

PROCEDURE TP2Asciiz (TStr:STRING; VAR Temp:ASCIIZ);
  { convert a TP string to an ASCIIZ (DOS) string }
  VAR Index:BYTE; BEGIN Index := ORD(TStr[0]);; Temp[Index] := #0;
    WHILE (Index > 0) DO BEGIN
      Temp[Index-1] := TStr[Index];;  DEC(Index);
    END{WHILE};
  END {TP2Asciiz};

FUNCTION GetVolLabel (Drv:CHAR):STRING;
  VAR Temp:ASCIIZ; Temp2:STRING; Index:BYTE;  seg0,ofs0:WORD;
      DTA : ARRAY [0..127] OF CHAR; BEGIN  Temp2 := '';
    IF Drv IN ['A'..'Z'] THEN BEGIN       { valid drive spec?       }
      Reg.AH := $2F;; MsDos(Reg);         { get current DTA address }
      seg0 := Reg.ES;; ofs0 := Reg.BX;    { save the orig DTA       }
      Reg.DS := SEG(DTA);; Reg.DX := OFS(DTA);  { our local DTA     }
      Reg.AH := $1A;; MsDos(Reg);               { activate our DTA  }
      Temp2 := '?:\*.*';; Temp2[1] := Drv;      { build filespec    }
      TP2Asciiz (Temp2, Temp);                  { xlate to ASCIIZ   }
      Reg.DS := SEG(Temp);; Reg.DX := OFS(Temp);; Reg.CX := 8;
      Reg.AH := $4E;; MsDos(Reg); { label search, then reset DTA... }
      Reg.DS := seg0;; Reg.DX := ofs0;; Reg.AH := $1A;; MsDos(Reg);
      IF NOT ODD(Reg.FLAGS) { no DOS error? }
        THEN FOR Index := $1E TO $2A DO Temp[Index-$1E] := DTA[Index]
        ELSE Temp[0] := #0;             { if no volume label found  }
      Asciiz2TP(Temp, Temp2);           { xlate DOS to TP string    }
      IF (Length(Temp2) > 8) AND (Temp2[9] = '.') { if 8/3 format   }
        THEN Delete (Temp2,9,1);
    END{IF Drv};
    GetVolLabel := Temp2;
  END {GetVolLabel};

BEGIN {VOLAB: here we go...}

  WriteLn;; WriteLn (TAB,'ReadVOL v0.01 Greg Vigneault');; WriteLn;
  REPEAT
    Write (TAB,'Read volume label from which drive [A..Z] ? ');
    Read (Drv);;  Drv := UpCase(Drv);
  UNTIL Drv IN ['A'..'Z'];
  Volume := GetVolLabel (Drv);;  WriteLn;
  IF Length(Volume) <> 0
    THEN WriteLn (TAB,'Volume in drive ',Drv,': is ', Volume)
    ELSE WriteLn (TAB,'No label for volume in drive ',Drv,':');
  WriteLn;

END {VOLAB}.

