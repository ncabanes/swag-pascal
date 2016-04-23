unit RJScan;

{******************************}
{                              }
{            RJScan            }
{                              }
{             v1.1             }
{                              }
{                              }
{              by              }
{                              }
{        Roland Skinner        }
{                              }
{      Copyright (c) 1992      }
{                              }
{         RJS Software         }
{                              }
{    Released to the public    }
{         domain 1994.         }
{                              }
{******************************}


{ Implements scanning ability for the DFI HS-3000 PLUS HANDY SCANNER or }
{ other 100% compatible hand-scanners (including certain GeniScans).    }

{ NOTE - This unit may be overlayed.                                    }
{      - This unit requires Turbo Pascal 6 (or above).                  }

{$B-,D-,F+,G-,I-,L-,O+,R-,S-,V-,X-}

{=============================================================================}

interface

{-----------------------------------------------------------------------------}

  const
    AnyResolution = 0;

{-----------------------------------------------------------------------------}

  type
    ScanError = (scOK,scNoScanner,scInvalidResolution,scIncorrectResolution,
                 scInvalidImageWidth);

{-----------------------------------------------------------------------------}

  type
    ScanLineBufferProc = function(LineNumber : Integer) : Pointer;
                         { NOTE - This function should return  the  address }
                         {        of the scan-buffer for the "LineNumber"th }
                         {        line. First line is number 0.             }
    DisplayScannedLineProc = procedure(LineNumber : Integer);
                             { NOTE - This  procedure  should  display  (if }
                             {        necessary)  the  "LineNumber"th  line }
                             {        that was scanned in.  First  line  is }
                             {        number 0.                             }
    StopScanningProc = function : Boolean;
                       { NOTE - This function should return "False", unless }
                       {        some  event  has  occurred  which  requires }
                       {        scanning to stop.                           }

{-----------------------------------------------------------------------------}

  function  ScanImage(DesiredResolution,MaxLinesToScan,BytesPerLine : Integer;
                      ScanLineBuffer : ScanLineBufferProc;
                      DisplayScannedLine : DisplayScannedLineProc;
                      StopScanning : StopScanningProc) : ScanError;
    {- This function will scan an image  with  width  8*"BytesPerLine"  and }
    {  height "MaxLinesToScan". It is possible to specify the resolution at }
    {  which to scan the image  in  "DesiredResolution"  (100,200,300,400). }
    {  If the resolution set on the scanner is different to that specified, }
    {  then   the   "scIncorrectResolution"   error   will   be   returned. }
    {  If "DesiredResolution" is "AnyResolution", then any resolution  will }
    {  be allowed. "scInvalidResolution" will be returned if  a  resolution }
    {  other than 100,200,300,400 or "AnyResolution" is specified.          }
    {  "ScanLineBuffer",  "DisplayScannedLine"   and   "StopScanning"   are }
    {  procedures/functions whose functions are discussed above. These must }
    {  be FAR procedures/functions.                                         }
    {  If "BytesPerLine" is too  large  for  the  scanner-resolution,  then }
    {  "scInvalidImageWidth" will be returned.                              }
    {  If scanner is not installed then "scNoScanner" is returned.          }
    {  If successful, then "scOK" will be returned.                         }
    {  This function may not work with  certain hand-scanners (if  so,  use }
    {  "GenericScanImage").                                                 }
  function  GenericScanImage(MaxLinesToScan,BytesPerLine : Integer;
                             ScanLineBuffer : ScanLineBufferProc;
                             DisplayScannedLine : DisplayScannedLineProc;
                             StopScanning : StopScanningProc) : ScanError;
    {- This  function  will  scan  an  image  in  an  analogous  manner  as }
    {  "ScanImage". However, it does not do any checks for valid resolution }
    {  or image-width. This is to allow compatibility for scanners which do }
    {  not allow for scan-resolution selection.                             }
    {  "scOK", "scNoScanner" and "scInvalidImageWidth" may be  returned  by }
    {  this function. Refer to "ScanImage" for a discussion about these.    }
  function  ScannerIsInstalled : Boolean;
    {- Returns installed-status of scanner.                                 }
  function  ResolutionOfScanner : Integer;
    {- Returns the resolution  set  on  the  scanner.  If  scanner  is  not }
    {  installed, then -1 will be returned.                                 }
    {  This function may not work with certain hand-scanners.               }

{=============================================================================}

implementation

{-----------------------------------------------------------------------------}

  const
    MaxBytesPerLine : Array[1..4] of Byte = (50,102,154,205);

{-----------------------------------------------------------------------------}

  var
    ScannerInstalled        : Boolean;
    ScannerResolution       : Word;
    ScannerResolution100    : Byte;
    DMAChannel              : Byte;
    DMAPageRegister         : Word;
    DMACurAddrRegister      : Word;
    DMACurWordCountRegister : Word;
    DMAClearSingleMaskBit   : Byte;
    DMASetSingleMaskBit     : Byte;
    DMAModeRegisterSetting  : Byte;
    DMAWriteRequest         : Byte;
    DMATerminalCountReached : Byte;

{-----------------------------------------------------------------------------}

  procedure DetermineScannerResolution; assembler;
  var
    Data : Byte;
  asm
    xor     ax,ax
    jmp     @Start
  @ResSettings:
    db      21h,41h,51h,71h
  @Start:
    mov     dx,27Bh
    mov     cx,300
  @1:
    in      al,dx
    and     al,10000000b
    jnz     @1
  @2:
    in      al,dx
    and     al,10000000b
    jz      @2
    loop    @1
  @3:
    in      al,dx
    and     al,10000000b
    jnz     @3
  @4:
    in      al,dx
    and     al,00100100b
    shr     al,1
    shr     al,1
    or      ah,al
    shr     al,1
    shr     al,1
    or      ah,al
    and     ah,00000011b
    xor     al,al
    xchg    al,ah
    mov     bl,4
    sub     bl,al
    mov     al,bl
    push    ax
    mov     bx,OFFSET (@ResSettings-1)
    add     bx,ax
    mov     al,[cs:bx]
    mov     dx,27Ah
    out     dx,al
    mov     Data,al
    pop     ax
    mov     ScannerResolution100,al
    mov     cx,100
    mul     cx
    mov     ScannerResolution,ax
  end;

{-----------------------------------------------------------------------------}

  procedure DetermineScannerDMA; assembler;
  asm
    mov     dx,27Bh
    in      al,dx
    and     al,00001010b
    cmp     al,00001000b
    je      @UseDMA1
    cmp     al,00000010b
    je      @UseDMA3
    jmp     @NoDMA
  @UseDMA1:
    mov     DMAChannel,1
    mov     DMAPageRegister,        83h
    mov     DMACurAddrRegister,     02h
    mov     DMACurWordCountRegister,03h
    mov     DMAClearSingleMaskBit,  00000001b
    mov     DMASetSingleMaskBit,    00000101b
    mov     DMAModeRegisterSetting, 01000101b
    mov     DMAWriteRequest,        00000001b
    mov     DMATerminalCountReached,00000010b
    jmp     @Exit
  @UseDMA3:
    mov     DMAChannel,3
    mov     DMAPageRegister,        82h
    mov     DMACurAddrRegister,     06h
    mov     DMACurWordCountRegister,07h
    mov     DMAClearSingleMaskBit,  00000011b
    mov     DMASetSingleMaskBit,    00000111b
    mov     DMAModeRegisterSetting, 01000111b
    mov     DMAWriteRequest,        00000011b
    mov     DMATerminalCountReached,00001000b
    jmp     @Exit
  @NoDMA:
    mov     DMAChannel,0
  @Exit:
  end;

{-----------------------------------------------------------------------------}

  procedure TurnScannerOn; assembler;
  asm
    mov     dx,27Ah
    mov     al,01h
    out     dx,al
  end;

{-----------------------------------------------------------------------------}

  procedure TurnScannerOff; assembler;
  asm
    mov     dx,27Ah
    mov     al,00h
    out     dx,al
  end;

{-----------------------------------------------------------------------------}

  procedure DMADelay; assembler;
  asm
    nop
    nop
    nop
  end;

{-----------------------------------------------------------------------------}

  function  DoScan(MaxLinesToScan,BytesPerLine : Integer;
                   ScanLineBuffer : ScanLineBufferProc;
                   DisplayScannedLine : DisplayScannedLineProc;
                   StopScanning : StopScanningProc) : ScanError;
  var
    LinesScanned : Integer;
    ScanBuffer   : Pointer;
    WidthToScan  : Word absolute BytesPerLine;
    QuitScanning : Boolean;
  begin
    if (BytesPerLine>0) and (BytesPerLine<=MaxBytesPerLine[ScannerResolution100]) then
    begin
      LinesScanned := 0;
      QuitScanning := False;
      repeat
        ScanBuffer := ScanLineBuffer(LinesScanned);
        asm
        {-Disable DMA transfer }
          mov     al,DMASetSingleMaskBit
          out     0Ah,al
          call    DMADelay;
          mov     al,DMAModeRegisterSetting
          out     0Bh,al
          call    DMADelay
        {-Setup Buffer address }
          les     di,ScanBuffer
          mov     dx,es
          mov     al,dh
          mov     cl,4
          shl     dx,cl
          shr     al,cl
          add     dx,di
          adc     al,0
          mov     cx,dx
          mov     dx,DMAPageRegister
          out     dx,al
          call    DMADelay
          out     0Ch,al
          call    DMADelay
          mov     dx,DMACurAddrRegister
          mov     al,cl
          out     dx,al
          call    DMADelay
          mov     al,ch
          out     dx,al
          call    DMADelay
        {-Setup bytes to transfer }
          out     0Ch,al
          call    DMADelay
          mov     ax,WidthToScan
          dec     ax
          mov     dx,DMACurWordCountRegister
          out     dx,al
          call    DMADelay
          mov     al,ah
          out     dx,al
        {-Start DMA transfer }
          mov     dx,27Bh
          out     dx,al
          dec     dx
          in      al,dx                 { DX = 027Ah }
          mov     al,DMAWriteRequest
          out     09h,al
          call    DMADelay
          mov     al,DMAClearSingleMaskBit
          out     0Ah,al
        end;
      {-Scan line }
        asm
          mov     bl,DMATerminalCountReached
        @1:
          in      al,08h
          and     al,bl
          cmp     al,bl
          je      @2
          push    bx
          call    StopScanning
          pop     bx
          or      al,al
          jz      @1
          mov     QuitScanning,True
        @2:
        end;
        DisplayScannedLine(LinesScanned);
        Inc(LinesScanned);
      until (LinesScanned=MaxLinesToScan) or QuitScanning;
      DoScan := scOK;
    end
    else
      DoScan := scInvalidImageWidth;
  end;

{-----------------------------------------------------------------------------}

  function  ScanImage(DesiredResolution,MaxLinesToScan,BytesPerLine : Integer;
                      ScanLineBuffer : ScanLineBufferProc;
                      DisplayScannedLine : DisplayScannedLineProc;
                      StopScanning : StopScanningProc) : ScanError;
  begin
    if ScannerInstalled then
    begin
      if (DesiredResolution=AnyResolution) or ((DesiredResolution div 100) in [1..4]) then
      begin
        TurnScannerOn;
        DetermineScannerResolution;
        if (DesiredResolution=AnyResolution) or (DesiredResolution=ScannerResolution) then
          ScanImage := DoScan(MaxLinesToScan,BytesPerLine,
                              ScanLineBuffer,DisplayScannedLine,StopScanning)
        else
          ScanImage := scIncorrectResolution;
        TurnScannerOff;
      end
      else
        ScanImage := scInvalidResolution;
    end
    else
      ScanImage := scNoScanner;
  end;

{-----------------------------------------------------------------------------}

  function  GenericScanImage(MaxLinesToScan,BytesPerLine : Integer;
                             ScanLineBuffer : ScanLineBufferProc;
                             DisplayScannedLine : DisplayScannedLineProc;
                             StopScanning : StopScanningProc) : ScanError;
  begin
    if ScannerInstalled then
    begin
      TurnScannerOn;
      ScannerResolution100 := 4;
      GenericScanImage := DoScan(MaxLinesToScan,BytesPerLine,
                          ScanLineBuffer,DisplayScannedLine,StopScanning);
      TurnScannerOff;
    end
    else
      GenericScanImage := scNoScanner;
  end;

{-----------------------------------------------------------------------------}

  procedure DetermineScannerPresence;
  begin
    TurnScannerOn;
    DetermineScannerDMA;
    TurnScannerOff;
    ScannerInstalled := (DMAChannel<>0);
  end;

{-----------------------------------------------------------------------------}

  function  ScannerIsInstalled : Boolean;
  begin
    ScannerIsInstalled := ScannerInstalled;
  end;

{-----------------------------------------------------------------------------}

  function  ResolutionOfScanner : Integer;
  begin
    if ScannerInstalled then
    begin
      TurnScannerOn;
      DetermineScannerResolution;
      TurnScannerOff;
      ResolutionOfScanner := ScannerResolution;
    end
    else
      ResolutionOfScanner := -1;
  end;

{-----------------------------------------------------------------------------}

begin
  DetermineScannerPresence;
end.

{=============================================================================}
