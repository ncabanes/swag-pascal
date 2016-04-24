(*
  Category: SWAG Title: INTERRUPT HANDLING ROUTINES
  Original name: 0001.PAS
  Description: BITSTUFF.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{
 Well Percy (or is it Kerry?), I see that the regular crowd here have
 shown you how bit-level thingys work.  So, I'll give you a working
 example, including a Procedure to display the binary notation of any
 Integer, so you can play With the inFormation they've given you. The
 following Program reads & displays info from the equipment list Word
 (Note: I've made [lazy] use of global Variables, do not emulate)...
}
(*******************************************************************)
Program BitsNBytes;                 { ...or Digital Road Kill       }
Uses
  Dos;                              { import Intr() and Registers   }
Var
  NumberFDD,                        { number of floppy drives       }
  InitVMode,                        { intial video mode             }
  COMcount,                         { number of serial ports        }
  LPTcount    : Byte;               { number of Printer ports       }
  Is8087,                           { math copro installed?         }
  IsMouse,                          { pointing device installed?    }
  IsDMA,                            { DMA support installed?        }
  IsGame,                           { game port installed?          }
  IsModem     : Boolean;            { internal modem installed?     }
  EqWord      : Word;               { the equipment list Word       }
  Reg         : Registers;          { to access CPU Registers       }
{-------------------------------------------------------------------}
Function BitSet(AnyWord : Word; BitNum : Byte) : Boolean;
 { return True if bit BitNum of AnyWord is 1, else False if it's 0  }
begin
  BitSet := (BitNum in [0..15]) and ODD(AnyWord SHR BitNum);
end {BitSet};
{-------------------------------------------------------------------}
Procedure WriteBitWord( AnyWord : Word );   { show Word as binary   }
Var
  BinString : String[16];                   { represent binary bits }
  MaxBit,                                   { max number of bits    }
  BitNum    : Byte;                         { bits 0..15            }
begin
  BinString := '0000000000000000';          { default to 0          }
  MaxBit := Length(BinString);              { total bit count (16)  }
  For BitNum := 0 to PRED(MaxBit) do        { process bits (0..15)  }
    if BitSet(AnyWord, BitNum) then
      INC(BinString[MaxBit - BitNum]);
  Write( BinString );                       { Write the binary Form }
end {WriteBitWord};
{-------------------------------------------------------------------}
Procedure ProcessEquipList;     { parse equipment list Word EqWord  }
Var
  BitNum  : Byte;               { to check each bit                 }
  EBitSet : Boolean;            { True if a BitNum is 1, else False }
begin
  For BitNum := 0 to 15 do
  begin                                     { EqWord has 16 bits    }
    EBitSet := BitSet(EqWord,BitNum);       { is this bit set?      }
    Case BitNum of                          { each bit has meaning  }
      0       : if EBitSet then             { if EqWord.0 is set    }
                  NumberFDD := (EqWord SHR 6) and $3 + 1
                else
                  NumberFDD := 0;
      1       : Is8087    := EBitSet; { if math co-pro found  }
      2       : IsMouse   := EBitSet; { if pointing device    }
      3       : ; {reserved, do nothing}
      4       : InitVMode := (EqWord SHR BitNum) and $3;
      5..7    : ; {ignore}
      8       : IsDMA     := EBitSet;
      9       : COMcount  := (EqWord SHR BitNum) and $7;
      10,11   : ; {ignore}
      12      : IsGame    := EBitSet;
      13      : IsModem   := EBitSet;
      14      : LPTcount  := (EqWord SHR BitNum) and $7;
      15      : ; {ignore}
    end; {Case BitNum}
  end; {For BitNum}
end {ProcessEquipList};
{-------------------------------------------------------------------}
Function Maybe(Truth : Boolean) : String;
begin
  if not Truth then
    Maybe := ' not '
  else
    Maybe := ' IS ';
end {Maybe};
{-------------------------------------------------------------------}
begin
  Intr( $11, Reg );
  EqWord := Reg.AX;
  WriteLn;
  Write('Equipment list Word: ',EqWord,' decimal = ');
  WriteBitWord( EqWord );
  WriteLn(' binary');
  WriteLn;
  ProcessEquipList;
  WriteLn('Number of floppies installed: ', NumberFDD );
  WriteLn('Math-coprocessor',Maybe(Is8087),'installed' );
  WriteLn('PS/2 Mouse',Maybe(IsMouse),'installed' );
  Write('Initial video mode: ',InitVMode,' (' );
  Case InitVMode of
    0 : WriteLn('EGA, VGA, PGA)');
    1 : WriteLn('40x25 colour)');
    2 : WriteLn('80x25 colour)');
    3 : WriteLn('80x25 monochrome)');
  end;
  WriteLn('DMA support',Maybe(IsDMA),'installed' );
  WriteLn('Number of COMs installed: ',COMcount );
  WriteLn('Game port',Maybe(IsGame),'installed' );
  WriteLn('IBM Luggable modem',Maybe(IsModem),'installed');
  WriteLn('Number of Printer ports: ',LPTcount );
end {BitsNBytes}.
(*******************************************************************)


