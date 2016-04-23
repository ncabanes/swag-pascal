Unit LF;

{$IFDEF Windows}
!! - Bite me!  This will not work with Windows!
{$ENDIF}

{ Text-mode font routines                                                    }
{ (c)1994 Chris Lautenbach                                                   }
{                                                                            }
{ Date         Revision     Description                                      }
{ ────────────────────────────────────────────────────────────────────────── }
{ Sep 07 94         1.0     Wrote real mode routines                         }
{ Sep 09 94         1.1     Added protected mode versions                    }
{ Sep 11 94         1.2     Added Set2FontMode() and SetNormalFontMode()     }

{ Notes:                                                                     }

{ It is important to note, that under protected mode, the normal VGA BIOS    }
{ extensions could not access the memory procured by GetMem().  This is why  }
{ the SimulateRealModeInt() and XGlobalDosAlloc() routines were needed.      }
{ XGlobalDosAlloc() allocates memory under the 1mb mark that the VGA BIOS is }
{ capable of accessing, and thereby allows font loads in p-mode.             }

{ Any size/line font may be used.  This is because I used subfunction $11    }
{ instead of $10.  $11 will calculate the scanlines/etc required for the     }
{ font you are loading by dividing the number of characters by the fonts     }
{ total size (as does LoadFont(), so that we may properly allocate memory).  }
{ I've tested 25, 33, 50, and 66 line mode fonts with it and they all work   }
{ fine.  Make sure the font you are loading is _pure_ binary, and does not   }
{ contain header information for some sort of font editing/loading program.  }

{ The calls to LoadFont() are identical in p-mode to real mode, so you won't }
{ need to do any code changes should you decide to switch between the modes  }
{ later on.  Nor is any special setup necessary.  Just USE it, and load      }
{ fonts, that's it! :)                                                       }

{ Using the VGA's 2 font mode:                                               }

{ The variable LoadBank has been provided so you can use LoadFont() to load  }
{ a font into a different font bank (VGA has up to 8 slots, 0-7).  The new   }
{ Set2FontMode() procedure allows you to switch to this mode.                }
{ SetNormalFontMode should be called to return you to normal mode.  To use   }
{ this mode, you must use two identical line mode fonts (eg. 25 line and 25  }
{ line, 50 and 50, etc).  One must be loaded into bank 0, and the other must }
{ be loaded into bank 6 (don't ask me why.. :).  Any characters that are     }
{ displayed in low intensity will be displayed in the font in bank 6, and    }
{ high intensity characters will be displayed in bank 0's font (the normal   }
{ font if you haven't changed it.                                            }

{ Restrictions:                                                              }

{ It is _ASSUMED_ that the machine has a VGA adapter.  If it does not, god   }
{ only knows what will happen.  It is up to you to make sure a VGA is        }
{ present before calling these routines.                                     }

{ Don't you dare use this code for profit without proclaiming my name in a   }
{ prominent place in your program!  :) (Oh, and it don't work under Windoze  }
{ but I'm sure you knew that...)                                             }

{ Oh, and I'm not an artist.  If you want to pay me for these routines,      }
{ leave me e-mail to viper@ttcbbs.com.                                       }

INTERFACE

{$IFDEF DPMI}
Uses WinApi;
{$ENDIF}

function LoadFont(FileName : string) : boolean;
{ Loads a 255-character font from FileName to font 0 and sets it on }

procedure NormalFont;
{ Returns the system to the normal system 8x16 character font }

procedure Set2FontMode;
{ Sets the VGA to allow 2 fonts simulataneously displayed }

procedure SetNormalFontMode;
{ Returns the VGA to normal single font mode }

var LoadBank : byte;                      { Default bank # to load font into }

IMPLEMENTATION

{$IFDEF DPMI}
Type LongRec = record
       Selector, Segment : word;
     end;

     DoubleWord = record
       Lo, Hi : word;
     end;

     QuadrupleByte = record
       Lo, Hi, sLo, sHi : byte;
     end;

     TDPMIRegisters = record
       EDI, ESI, EBP, Reserved, EBX, EDX, ECX, EAX : longint;
       Flags, ES, DS, FS, GS, IP, CS, SP, SS : word;
     end;

  function XGlobalDosAlloc(Size : longint; var P : Pointer) : word;
  { Allocates memory in an area that DOS can access properly }
  var Long : longint;
  begin
    Long := GlobalDosAlloc(Size);
    P := Ptr(LongRec(Long).Selector, 0);
    XGlobalDosAlloc := LongRec(Long).Segment;
  end;

  function SimulateRealModeInt(IntNo : word;
                               var Regs : TDPMIRegisters) : word; assembler;
  { Simulates a real mode interrupt }
  asm
    PUSH BP                                          { Save BP, just in case }
    MOV BX,IntNo                         { Move the Interrupt number into BX }
    XOR CX,CX                                                     { Clear CX }
    LES DI,Regs                              { Load the registers into ES:DI }
    MOV AX,$300                                { Set function number to 300h }
    INT $31                             { Call Interrupt 31h - DPMI Services }
    JC @Exit                                         { Jump to exit on carry }
    XOR AX,AX                                                     { Clear AX }
    @Exit:                                                      { Exit label }
    POP BP                                                      { Restore BP }
  end;

  function LoadFont(FileName : string) : boolean;
  { Loads a 255-character font from FileName to font 0 and sets it on }
  var FontFile : file;
      Font, Tmp : pointer;
      S, O, FontSize, RMSeg, DPSel : word;
      BPC : byte;
      Regs : TDPMIRegisters;
  begin
    {$I-}
    Assign(FontFile, FileName);                              { Open the file }
    Reset(FontFile, 1);                                           { Reset it }
    {$I+}
    If (IOResult <> 0) then                  { File opening was unsuccessful }
    begin
      LoadFont := FALSE;                                      { Return FALSE }
      Exit;                                               { Return to caller }
    end;
    FontSize := FileSize(FontFile);                      { Get the font size }
    FillChar(Regs, SizeOf(Regs), #0);             { Clear the DPMI registers }
    Regs.ES := XGlobalDosAlloc(FontSize, Font);            { Allocate memory }
    BlockRead(FontFile, Font^, FontSize);                    { Load the font }
    BPC := FontSize DIV 256;                 { Calculate bytes per character }
    Close(FontFile);                                   { Close the font file }
    DoubleWord(Regs.EBP).Hi := Regs.ES;       { Load font address into ES:BP }
    QuadrupleByte(Regs.EAX).Hi := $11;                    { Set function $11 }
    QuadrupleByte(Regs.EAX).Lo := $10;                { Set sub-function $10 }
    QuadrupleByte(Regs.EBX).Hi := BPC;        { Set # of bytes per character }
    QuadrupleByte(Regs.EBX).Lo := LoadBank;           { Set font number to 0 }
    DoubleWord(Regs.ECX).Lo := $FF;               { # of chars to load = 256 }
    DoubleWord(Regs.EDX).Lo := $0;                     { Set start char to 0 }
    SimulateRealModeInt($10, Regs);                     { Call the interrupt }
    GlobalDosFree(LongRec(Font).Selector);              { Free up the memory }
    LoadFont := TRUE;                   { Return TRUE - function successful! }
  end;
{$ENDIF}

{$IFDEF MSDOS}
  function LoadFont(FileName : string) : boolean;
  { Loads a 255-character font from FileName to font 0 and sets it on }
  var FontFile : file;
      Font, Tmp : pointer;
      S, O, FontSize, RMSeg, DPSel : word;
      BPC : byte;
  begin
    {$I-}
    Assign(FontFile, FileName);                              { Open the file }
    Reset(FontFile, 1);                                           { Reset it }
    {$I+}
    If (IOResult <> 0) then                  { File opening was unsuccessful }
    begin
      LoadFont := FALSE;                                      { Return FALSE }
      Exit;                                               { Return to caller }
    end;
    FontSize := FileSize(FontFile);                      { Get the font size }
    GetMem(Font, FontSize);                       { Allocate memory for font }
    BlockRead(FontFile, Font^, FontSize);                    { Load the font }
    BPC := FontSize DIV 256;                 { Calculate bytes per character }
    Close(FontFile);                                   { Close the font file }
    S := Seg(Font^);                                   { Get segment of font }
    O := Ofs(Font^);                                    { Get offset of font }
    asm
      PUSH BP                                                      { Save BP }
      MOV AL,$10                                      { Set sub-function $10 }
      MOV AH,$11                                          { Set function $11 }
      MOV BH,BPC                              { Set # of bytes per character }
      MOV BL,LoadBank                                   { Set font # to load }
      MOV CX,$FF                                    { Set # of chars to load }
      MOV DX,$0                           { Set start of load to character 0 }
      MOV ES,S                                { Load segment of font to load }
      MOV BP,O                                 { Load offset of font to load }
      INT $10                                      { Call BIOS Interrupt 10h }
      POP BP                                                    { Restore BP }
    end;
    FreeMem(Font, FontSize);                      { Release allocated memory }
    LoadFont := TRUE;                   { Return TRUE - function successful! }
  end;
{$ENDIF}

  procedure Set2FontMode; assembler;
  { Puts the VGA into double-font mode.  The first font should be contained
    in bank 0, and the second in bank 6. }
  asm
    MOV AL,$03                                  { Set register offset to 03h }
    MOV DX,$3C4                                    { Set output port to 3C4h }
    OUT DX,AL                                  { Send our command to the VGA }
    INC DX                           { Increment port to 3C5h, the data port }
    MOV AL,$12                                { Put our 'magic byte' into AL }
    OUT DX,AL                             { Send the 'magic byte' to the VGA }
  end;

  procedure SetNormalFontMode; assembler;
  { Puts the VGA back into normal single-font mode. }
  asm
    MOV AL,$03                                  { Set register offset to 03h }
    MOV DX,$3C4                                    { Set output port to 3C4h }
    OUT DX,AL                                  { Send the command to the VGA }
    INC DX                           { Increment port to 3C5h, the data port }
    MOV AL,$00                           { Put 00h into AL, all bets are off }
    OUT DX,AL                                  { Send our command to the VGA }
  end;

  procedure NormalFont; assembler;
  { Returns the system to the normal system 8x16 character font }
  asm
    MOV AL,$04                                        { Set sub-function 04h }
    MOV AH,$11                                            { Set function 11h }
    MOV BL,$00                           { Select font 0 as the one to reset }
    INT $10                                        { Call BIOS Interrupt 10h }
  end;

begin
  LoadBank := $00;                              { Set default load bank to 0 }
end.
