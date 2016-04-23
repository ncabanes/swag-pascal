
CONST
  { Constants for bit plane, video page, and memory block sizes: }
  MonoBase      = $B000;     { Segment offset of MDA/Herc video buffer  }
  CGABase       = $B800;     { Segment offset of CGA video buffer       }
  EGAVGABase    = $A000;     { Segment offset of EGA/VGA video buffer   }

  { Size of one video page buffer in modes 0..3: }
  TxtVidPageSize   : Array[0..3] of Word = ($800,$800,$1000,$1000);
  { Actual number of bytes used in these buffers }
  TxtVidPageFilled : Array[0..3] of Word = (2000,2000,4000,4000);

  CGAMemBankSize    = $2000; { Size of one CGA memory bank in modes 4, 5 and 6}
  CGAMemBankFilled  = 8000;  { Actual number of bytes used in that bank       }
  HercMemBankSize   = $2000; { Size of one Hercules memory bank               }
  HercMemBankFilled = 7830;  { Actual number of bytes used in that bank       }
  VGA256MemBankSize = 64000;

  MDAPageSize   = 4000;      { Size of MDA text buffer }
  V400PageSize  = 32000;     { Size video page in V400VM mode }


FUNCTION GetVidMode: Byte;
  VAR Regs : Registers;
  BEGIN
    Regs.AH := $0F;
    Intr($10,Regs);
    GetVidMode := Regs.AL;
  END; { GetVidMode }


FUNCTION VidAddress: Pointer;
  VAR VM: Byte;
  BEGIN
    VM := GetVidMode;
    CASE VM OF
      0..3   : VidAddress := Ptr(CGABase,GetVisualPage * TxtVidPageSize[VM]);
      4..6   : VidAddress := Ptr(CGABase,0);
      7      : VidAddress := Ptr(MonoBase,0);  { Also HercVM }
      13..19 : VidAddress := Ptr(EGAVGABase,0);
      V400VM : VidAddress := Ptr(EGAVGABase,GetVisualPage * V400PageSize);
      ELSE     DumBool := CheckError(TRUE,'VIDADDRESS',68);
    END;
  END; { VidAddress }
