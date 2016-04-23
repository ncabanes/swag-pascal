{ Does anyone know the routine For making a Program DV aware, and if it
 finds it, can you get it to make calls to it instead of Dos?
}
Here is a desqview Unit I have used in the past.

Unit DESQVIEW ;

{$O+,F+}

Interface

Uses Dos ;

Var
  DV_ACTIVE    : Boolean ;          { True if running under DESQview     }
  Win_ACTIVE   : Boolean ;          { True if Windows 3.x Enhanced Mode  }
  DV_VERSION   : Word ;             { desqVIEW version number            }
  DV_VSEG      : Word ;
  DV_VMODE     : Byte Absolute $0040:$0049 ;
  DV_VWIDTH    : Byte ;
  DV_VROWS     : Byte ;
  DV_VofS      : Word ;


Procedure DV_RQM   ;                { Give up the rest of our timeslice  }
Procedure DV_begin_CRITICAL ;       { Turn Task Switching off.           }
Procedure DV_end_CRITICAL ;         { Turn switching back on.            }
Procedure DV_VIDEO_BUFFER ;         { Set Global Video Variables         }
Function  DV_Window_NUMBER : Byte ; { Returns Window Number              }
Procedure DV_COMMON_MEMorY(Var AVAIL, LARGEST, toTAL: Word) ;
Procedure DV_CONV_MEMorY  (Var AVAIL, LARGEST, toTAL: Word) ;
Procedure DV_EMS_MEMorY   (Var AVAIL, LARGEST, toTAL: Word) ;
Procedure DV_FASTWrite    (X,Y: Word; STR: String; FG,BG: Word) ;

Implementation

Var
  REG     : Registers ;

Procedure DV_RQM ;

begin
  if DV_ACTIVE then begin
    Asm
      mov  ax, 1000h
      int  15h
    end ;
  end else begin
    if Win_ACTIVE then begin
      Asm
        mov  ax, 1680h
        int  2fh
      end ;
    end ;
  end ;
end { dv_rqm };

Procedure DV_begin_CRITICAL ;

begin
  if DV_ACTIVE then begin
    Asm
      mov   ax, $101b
      int   15h
    end ;
  end else begin
    if Win_ACTIVE then begin
      Asm
        mov  ax, 1681h
        int  2fh
      end ;
    end ;
  end ;
end ; { dv_begin_critical }

Procedure DV_end_CRITICAL ;

begin
  if DV_ACTIVE then begin
    Asm
      mov   ax, $101c
      int   15h
    end ;
  end else begin
    if Win_ACTIVE then begin
      Asm
        mov  ax, $1682
        int  2fh
      end ;
    end ;
  end ;
end ; { dv_end_critical }

Procedure DV_VIDEO_BUFFER ;

begin
  if DV_ACTIVE then begin
    Asm
      mov  ax, $2b02
      mov  bx, $4445  ; { DE }
      mov  dx, $5351  ; { SQ }
      int  21h
      mov  DV_VSEG, dx
      mov  DV_VWIDTH, bl
      mov  DV_VROWS, bh
      mov  DV_VofS, 0
    end ;
  end else begin
    if (DV_VMODE = 7) then DV_VSEG := $b000 else DV_VSEG := $b800 ;
    DV_VWIDTH := memw[$0040:$004a] ;
    DV_VROWS  := 25 ;
    DV_VofS   := memw[$0040:$004e] ;
  end ;
end ; { dv_video_buffer }

Function DV_Window_NUMBER ;

begin
  if DV_ACTIVE then begin
    Asm
      mov   ax, $de07
      int   15h
      mov  @RESULT, al
    end ;
  end else begin
    DV_Window_NUMBER := 0 ;
  end ;
end ;

Procedure DV_COMMON_MEMorY ;

begin
  if DV_ACTIVE then begin
    Asm
      mov  ax, $de04
      int  15h
      les  di, AVAIL
      mov  es:[di], bx
      les  di, LARGEST
      mov  es:[di], cx
      les  di, toTAL
      mov  es:[di], dx
    end ;
  end else begin
    AVAIL := 0 ;
    LARGEST := 0 ;
    toTAL := 0 ;
  end ;
end ;

Procedure DV_CONV_MEMorY ;

begin
  if DV_ACTIVE then begin
    Asm
      mov  ax, $de05
      int  15h
      les  di, AVAIL
      mov  es:[di], bx
      les  di, LARGEST
      mov  es:[di], cx
      les  di, toTAL
      mov  es:[di], dx
    end ;
  end else begin
    AVAIL := 0 ;
    LARGEST := 0 ;
    toTAL := 0 ;
  end ;
end ;

Procedure DV_EMS_MEMorY ;

begin
  if DV_ACTIVE then begin
    Asm
      mov  ax, $de06
      int  15h
      les  di, AVAIL
      mov  es:[di], bx
      les  di, LARGEST
      mov  es:[di], cx
      les  di, toTAL
      mov  es:[di], dx
    end ;
  end else begin
    AVAIL := 0 ;
    LARGEST := 0 ;
    toTAL := 0 ;
  end ;
end ;

Procedure DV_FASTWrite ;

Var
  I      : Word ;

begin
  X := DV_VofS + ((Y-1) * DV_VWIDTH + (X-1)) * 2 ;
  For I := 1 to length(STR) do begin
    MEMW[DV_VSEG:X] := (((BG shl 4) + FG) shl 8) + ord(STR[I]) ;
    X := X + 2 ;
  end ;
end ;

begin { main }
  REG.AX := $2b01 ;
  REG.CX := $4445 ;  { DE }
  REG.DX := $5351 ;  { SQ }
  intr($21,REG) ;

  Win_ACTIVE := False ;
  DV_ACTIVE := (REG.AL <> $ff) ;

  DV_VERSION := 0 ;
  if DV_ACTIVE then begin
    DV_VERSION := REG.BX ;
    REG.AX := $de0b ;
    REG.BX := $0200 ;  { Minimum of Desqview 2.00 }
    intr($15,REG) ;
  end else begin
    REG.AX := $1600 ;
    intr($2f,REG) ;
    Case REG.AL of
      $00 : ; { An enhanced Windows API is not Running }
      $80 : ; { An enhanced Windows API is not Running }
      $01 : ; { Windows / 386 Version 2.x              }
      $ff : ; { Windows / 386 Version 2.x              }
      else begin
        Win_ACTIVE := True ;
        DV_VERSION := swap(REG.AX) ;
      end ;
    end ;
  end ;

  DV_VIDEO_BUFFER ;
end. { main }
