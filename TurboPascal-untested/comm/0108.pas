
{
 *  Interface unit for the X00 device driver. This unit supports all
 *  comm fossil calls needed to do most communication tasks.
 *
 *  Author  Gordon Tackett
 *  Date    01-31-91
 *
 *  $Revision:   1.0  $
}

{$IFDEF LOCAL}

Program X00;

{$ELSE}

Unit X00;

Interface

{$ENDIF}

Uses Dos;


Type

  {
  * Driver Information Block.
  *    This record holds all of the current settings from the
  *    X00 driver after a call to funciton $1B
  }
  DvrInfo = Record
      Size  : Word;
      Spec  : byte;
      Rev   : Byte;
      ID    : Pointer;
      Ibuf  : Word;
      Iavl  : Word;
      OBuf  : Word;
      Oavl  : Word;
      Width : Byte;
      Height: Byte;
      Baud  : Byte;
    End;

  {
  * Timer Fuctions & Pointers
  *    This procedure type is used to define a pointer the the procedure
  *    that may be sent to the X00 driver for calling during a timer
  *    tick. These procedures must be declared far
  }
  TimerFunction = Procedure;
  TimerFunctionPtr = ^TimerFunction;


  {
  *  X00 Driver object
  *    This is the main object for this module. It has all the interface
  *    routines and data needed to call all the major functions of the
  *    X00 device driver.
  }
  X00Dvr = Object
    Port        : Word;
    Baud        : Word;
    Size        : Word;
    Parity      : Char;
    Stops       : Word;
    Status      : Word;
    MaxFuncs    : Word;
    RevLevel    : Word;
    CtrlCFlags  : Byte;
    CurInfo     : DvrInfo;

    Constructor Init(Prt,Bd,Sz : Word; Prty : Char; StpBts : Word);
    Function    GetLastStatus : Word;
    Function    GetInfoSize : Word;
    Function    GetInfoSpec : Word;
    Function    GetInfoRev  : Word;
    Function    GetInfoId   : Pointer;
    Function    GetInfoIbuf : Word;
    Function    GetInfoIavl : Word;
    Function    GetInfoOBuf : Word;
    Function    GetInfoOAvl : Word;
    Function    GetInfoCrtW : Word;
    Function    GetInfoCrtH : Word;
    Function    GetInfoBaud : Word;
    Function    GetPort     : Word;
    Function    GetBaud     : Word;
    Function    GetSize     : Word;
    Function    GetParity   : Char;
    Function    GetStops    : Word;
    Function    GetMaxFuncs : Word;
    Function    GetRevLevel : Word;

    Procedure   SetBaud(Bd,Sz : Word; Prty : Char; StpBts : Word);
    Procedure   TxChar(Ch : Char);
    Function    RxChar : Char;
    Function    GetStatus : Word;
    Procedure   InitFossil;
    Procedure   DeinitFossil;
    Procedure   DropDTR;
    Procedure   RaseDTR;
    Procedure   SystemTimerParams(Var TicksPerSec,MsPerTick : Word);
    Procedure   FlushBuffer;
    Procedure   PurgeOutputBuffer;
    Procedure   PurgeInputBuffer;
    Procedure   TxCharNoWait(Ch : Char);
    Function    RXPeekChar(Var Ch : Char) : Boolean;
    Function    KBPeekChar(Var Ch : Word) : Boolean;
    Function    KBRead : Word;
    Procedure   FlowControl(XONCTS : Byte);
    Procedure   CtrlCChkOn;
    Procedure   CtrlCChkOff;
    Procedure   XmitOff;
    Procedure   XmitOn;
    Procedure   GotoXY(X,Y : Word);
    Procedure   GetCursorLoc(Var X,Y : Word);
    Procedure   AnsiWriteChar(Ch : Char);
    Procedure   EnableWatchDog;
    Procedure   DisableWatchDog;
    Procedure   WriteChar(Ch : Char);
    Function    InsertTimerFunction(TF : TimerFunctionPtr) : Boolean;
    Function    DeleteTimerFunction(TF : TimerFunctionPtr) : Boolean;
    Procedure   Reboot(Tp : Boolean);
    Procedure   RecvBuffer(Buffer : Pointer; Var Sz : Word);
    Procedure   SendBuffer(Buffer : Pointer; Sz : Word);
    Procedure   StopBreak;
    Procedure   GetInfo;
    {7e}
    {7f}
  End;


Const
  OutputBuffEmpty    = $4000;
  OutputBuffNotFull  = $2000;
  InputBuffOverrun   = $0200;
  CharInInputBuff    = $0100;
  CarrierDetect      = $0080;
  TxXonXoff          = $01;
  TXCts              = $02;
  RxXonXoff          = $03;




Var
  Comm1 : X00Dvr;
  Comm2 : X00Dvr;


{$IFNDEF LOCAL}

Implementation

{$ENDIF}


Var
  Regs : Registers; { register structure used in X00 calls}

Const
  CommVect = $14;          {X00 interrupt vector}


{
*  Init - set up object and init port.
* This routine will clear unused bytes to 0 and will init the
* X00 fossil driver to the baud,size,parity,and stops as needed
* by the user application.
-----------------------------------------------------------------------------}
Constructor X00Dvr.Init(Prt,Bd,Sz : Word; Prty : Char; StpBts : Word);
  Begin
    Port := Prt;
    CtrlCFlags := 0;
    InitFossil;
    If MaxFuncs = 0 Then
        Exit;
    SetBaud(Bd,Sz,Prty,StpBts);
  End;



{
* Get Last Status
*
* Interface function to get a copy of the status word storied in the
* object body.
-----------------------------------------------------------------------------}
Function X00Dvr.GetLastStatus : Word;
  Begin
    GetLastStatus := Status;
  End;



{
* Get Information Size
*
* Interface function to get a copy of the word size from the info block.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoSize : Word;
  Begin
    GetInfoSize := CurInfo.Size;
  End;



{
* Get Information Specification
*
* Interface function to get a copy of the fossil interface spec supported
* by this driver.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoSpec : Word;
  Begin
    GetInfoSpec := CurInfo.Spec;
  End;



{
* Get Information Revision
*
* Interface function to get a copy of the fossil document revision supported
* by this driver.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoRev : Word;
  Begin
    GetInfoRev := CurInfo.Rev;
  End;



{
* Get Information ID
*
* Interface function to get a copy of the pointer to the ascii
* string containing the name of the driver.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoId : Pointer;
  Begin
    GetInfoId := CurInfo.Id;
  End;



{
* Get Information Input Buffer Size
*
* Interface function to get a copy of the size of the input buffer
* in bytes.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoIbuf : Word;
  Begin
    GetInfoIBuf := CurInfo.IBuf;
  End;


{
* Get Information Input Buffer Avaliable
*
* Interface function to get a copy of the amount of input buffer that is
* avaliable for use.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoIavl : Word;
  Begin
    GetInfoIavl := CurInfo.Iavl;
  End;



{
* Get Information Output Buffer Size
*
* Interface function to get a copy of the size of the output buffer
* in bytes.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoOBuf : Word;
  Begin
    GetInfoOBuf := CurInfo.OBuf;
  End;



{
* Get Information Output Buffer Avaliable
*
* Interface function to get a copy of the amount of Output buffer that is
* avaliable for use.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoOAvl : Word;
  Begin
    GetInfoOAvl := CurInfo.OAvl;
  End;

{
* Get Information Current CRT Width
*
* Interface function to get a copy of the width of the CRT
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoCrtW : Word;
  Begin
    GetInfoCrtW := CurInfo.Width;
  End;



{
* Get Information Current CRT Height
*
* Interface funciton to get a copy of the height of the CRT
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoCrtH : Word;
  Begin
    GetInfoCrtH := CurInfo.Height;
  End;



{
* Get Information Current Baud Rate
*
* Interface function to get a copy of the current baud rate as returned
* in the curinfo structure.
-----------------------------------------------------------------------------}
Function X00Dvr.GetInfoBaud : Word;
  Begin
    GetInfoBaud := CurInfo.Baud;
  End;



{
* Get the port number
*
* Interface function to return the port number that was used to call
* the constructor Init. Once this constructor is called the port value
* can't be changed.
-----------------------------------------------------------------------------}
Function X00Dvr.GetPort : Word;
  Begin
    GetPort := Port;
  End;



{
* Get the Baud Rate
*
* Interface function that is used to get the last baud rate sent to
* this object from an application. This may not be the current correct
* baud rate.
-----------------------------------------------------------------------------}
Function X00Dvr.GetBaud : Word;
  Begin
    GetBaud := Baud;
  End;



{
* Get the Word Size
*
* Interface function that is used to get the last word size sent to
* this object from an application. This is always correct
-----------------------------------------------------------------------------}
Function X00Dvr.GetSize : Word;
  Begin
    GetSize := Size;
  End;



{
* Get the Parity
*
* Interface function that is used to get the last parity value that was
* sent to this object from an application. this is always correct.
-----------------------------------------------------------------------------}
Function X00Dvr.GetParity : Char;
  Begin
    GetParity := Parity;
  End;




{
* Get Stop Bits
*
* Interface function that is used to get the last number of stop bits
* that was sent to this object from an application. This is always correct.
-----------------------------------------------------------------------------}
Function X00Dvr.GetStops : Word;
  Begin
    GetStops := Stops;
  End;




{
* Get Maximum Function
*
* Interface function to return the maximum functions supported
* by this fossil driver.
-----------------------------------------------------------------------------}
Function X00Dvr.GetMaxFuncs : Word;
  Begin
    GetMaxFuncs := MaxFuncs;
  End;



{
* Get Fossil Rev
*
* Interface function to return the revision level of the fossil
* that is in use.
-----------------------------------------------------------------------------}
Function X00Dvr.GetRevLevel : Word;
  Begin
    GetRevLevel := RevLevel;
  End;



{
* Set Baud Rate
*
* BaudRate code in AL:
* Bits [7:5] 000 = 19200, 001 = 38400, 010 = 300, 011 = 600, 100 = 1200,
* 101 = 2400, 110 = 4800, 111 = 9600. Parity: [4:3] 00 or 10 = none,
* 01 = odd, 11 = even. StopBits: [2:2] 0 = 1, 1 = 2
* CharLength: 5 bits plus value [1:0] Support for [4:0] = 00011 required of
* driver, others optional
-----------------------------------------------------------------------------}
Procedure X00Dvr.SetBaud(Bd,Sz : Word; Prty : Char; StpBts : Word);
  Var
    Bits : Word;
  Begin
    Baud := Bd;
    Size := Sz;
    Parity := Prty;
    Stops := StpBts;

    Regs.Dx := Port;

    Case Baud of
        300 : Bits := 2;
        600 : Bits := 3;
       1200 : Bits := 4;
       2400 : Bits := 5;
       4800 : Bits := 6;
       9600 : Bits := 7;
      19200 : Bits := 0;
      38400 : Bits := 1;
    Else
      Exit;
    End;

    Bits := Bits Shl 2;
    If Parity = 'E' Then
      Bits := Bits + 3
    Else if Parity = 'O' Then

{  c╛ε║DæB6┤= Bits + 1;}

    Bits := Bits Shl 1;
    If Stops = 2 then
      Bits := Bits + 1;
    Bits := Bits Shl 2;
    Case Size Of
      6 : Bits := Bits + 1;
      7 : Bits := Bits + 2;
      8 : Bits := Bits + 3;
    Else
      Bits := Bits + 3;
    End;

    Regs.Al := Bits;
    Regs.Ah := $00;
    Intr(CommVect,Regs);
    Status := Regs.AX;
  End;


{
* Transmit Character
*
* Character is queued for transmission. If there is room in the transmitter
* buffer when this call is made, the character will be stored and control
* returned to caller. If the buffer is full, the driver will wait for room.
* This can be dangerous when used in combination with flow control (see
* Function 0Fh)
-----------------------------------------------------------------------------}
Procedure X00Dvr.TxChar(Ch : Char);
  Begin
    Regs.al := Ord(Ch);
    Regs.Ah := $01;
    Regs.Dx := Port;
    Intr(CommVect,Regs);
    Status := Regs.AX;
  End;



{
* Receive Character
*
* The next character in the input ring buffer is returned to the caller. If
* none available, the driver will wait for input.
-----------------------------------------------------------------------------}
Function  X00Dvr.RxChar : Char;
  Begin
    Regs.Dx := Port;
    Regs.Ah := $02;
    Intr(CommVect,Regs);
    RxChar := Char(Regs.Al);
  End;



{
* Get Status
*
* Bits are:
* AH[6:6] 1 = Output buffer empty
* AH[5:5] 1 = Output buffer not full
* AH[1:1] 1 = Input buffer overrun
* AH[0:0] 1 = Characters in input buffer
* AL[7:7] 1 = Carrier Detect signal
* AL[3:3] 1 = Always (never 0)
-----------------------------------------------------------------------------}
Function  X00Dvr.GetStatus : Word;
  Begin
    Regs.Dx := Port;
    REgs.Ah := $03;
    Intr(CommVect,Regs);
    GetStatus := Regs.Ax;
    Status := Regs.AX;
  End;



{
* Init Fossil Driver
*
* Required before I/O can take place on comm port.  When DX = 00FFh,  then
* any initialization needed to make the keyboard/display available for FOSSIL
* use should be performed.  BX = 4F50h signals that ES:CX points to a flag
* byte in the application that the driver should increment when its
* keyboard routines detect a Ctl-C.
-----------------------------------------------------------------------------}
Procedure X00Dvr.InitFossil;
  Begin
    Regs.Dx := Port;
    Regs.Ah := $04;
    Regs.Bx := 0;
    Intr(CommVect,Regs);
    If Regs.Ax <> $1954 Then
      Begin
        MaxFuncs := 0;
        RevLevel := 0;
      End
    Else
      Begin
        MaxFuncs := Regs.Bl;
        RevLevel := Regs.Bh;
      End;
  End;



{
* De-Init Fossil Driver
*
* Disengages driver from comm port. Should be done when operations on the
* port are complete.  IF DX = 00FFh, then the initialization that was
* performed when FOSSIL function 04h with DX = 00FFh should be undone.
-----------------------------------------------------------------------------}
Procedure X00Dvr.DeinitFossil;
  Begin
    If MaxFuncs < $05 Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $05;
    Intr(CommVect,Regs);
  End;

{
* Drop Dtr Line
*
* Used to control Data Terminal Ready signal line on com port. This line
* usually has some effect on modem operation (most modems will drop
* carrier if DTR is lowered, for example).
-----------------------------------------------------------------------------}
Procedure X00Dvr.DropDTR;
  Begin
    If MaxFuncs < $06 Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $06;
    Regs.Al := 0;
    Intr(CommVect,Regs);
  End;


{
* Rase Dtr Line
*
* Used to control Data Terminal Ready signal line on com port. This line
* usually has some effect on modem operation (most modems will drop
* carrier if DTR is lowered, for example).
-----------------------------------------------------------------------------}
Procedure X00Dvr.RaseDTR;
  Begin
    If MaxFuncs < $06 Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $06;
    Regs.Al := 1;
    Intr(CommVect,Regs);
  End;



{
* Get System Timming Parameters
*
* Returns statistics needed to do some critical timing in any MS-DOS system.
* The interrupt number in AL can be used to intercept a timer interrupt
* that happens (AH) times per second. DX is essentially 1000/AH. Function
* 16h is the preferred way to install timer tick code. AH and DX should
* be accurate for the 16h timer tick.
-----------------------------------------------------------------------------}
Procedure X00Dvr.SystemTimerParams(Var TicksPerSec,MsPerTick : Word);
  Begin
    If MaxFuncs < $07 Then
        Exit;
    Regs.Ah := $07;
    Intr(CommVect,Regs);
    TicksPerSec := Regs.Ah;
    MsPerTick := Regs.Dx;
  End;



{
* Flush Output Buffer
*
* This is used to wait for all output to complete. If flow control is active
* it is possible for this code never to return control to the caller. (See
* function 0Fh)
-----------------------------------------------------------------------------}
Procedure X00Dvr.FlushBuffer;
  Begin
    If MaxFuncs < $08 Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $08;
    Intr(CommVect,Regs);
  End;



{
* Purge Output Buffer
*
* Zero the output buffer. Returns to the caller immediately. Characters
* that have not been transmitted yet are lost.
-----------------------------------------------------------------------------}
Procedure X00Dvr.PurgeOutputBuffer;
  Begin
    If MaxFuncs < $09 Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $09;
    Intr(CommVect,Regs);
  End;



{
* Purge Input Buffer
*
* Zeroes the input buffer. If any flow control restraint has been employed
* (dropping RTS or transmitting XOFF) the port will be "released" (by doing
* the reverse, raising RTS or sending XON). Returns to caller immediately.
-----------------------------------------------------------------------------}
Procedure X00Dvr.PurgeInputBuffer;
  Begin
    If MaxFuncs < $0A Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $0A;
    Intr(CommVect,Regs);
  End;



{
* Transmit Character without wait
*
* Character is queued for transmission. If there is room in the transmitter
* buffer when this call is made, the character will be stored and control
* returned to caller with AX=1. If the buffer is full, control is returned
* to caller with AX=0. This allows the application to make its own decisions
* on how to deal with "buffer full".
-----------------------------------------------------------------------------}
Procedure X00Dvr.TxCharNoWait(Ch : Char);
  Begin
    Repeat
    If MaxFuncs < $0B Then
        Exit;
      Regs.Dx := Port;
      Regs.Ah := $0B;
      Regs.Al := Ord(Ch);
      Intr(CommVect,Regs);
    Until (Regs.Ax <> 0);
  End;



{
* Keyboard Peek Character
*
* The next character in the input ring buffer is returned to the caller. If
* none available, the driver returns a value of FFFFH. This "read" does not
* actually remove a character from the input buffer!
-----------------------------------------------------------------------------}
Function  X00Dvr.RXPeekChar(Var Ch : Char) : Boolean;
  Begin
    If MaxFuncs < $0C Then
      c╛ε║DæB6Q|   Regs.DX := Port;
    Regs.AH := $0C;
    Intr(CommVect,Regs);
    Ch := Char(Regs.AL);
    If Regs.AX = $FFFF Then
        RxPeekChar := False
    Else
        RxPeekChar := True;
  End;



{
* Keyboard Peek Character
*
* The next character in the keyboard buffer is returned to the caller. If
* none available, the driver returns a value of FFFFH. This "read" does not
* actually remove a character from the input buffer! For function keys, IBM
* PC scan codes must be returned.
-----------------------------------------------------------------------------}
Function  X00Dvr.KBPeekChar(Var Ch : Word) : Boolean;
  Begin
    If MaxFuncs < $0D Then
        Exit;
    Regs.DX := Port;
    Regs.AH := $0D;
    Intr(CommVect,Regs);
    Ch := Regs.AX;
    If Regs.AX = $FFFF Then
        KBPeekChar := False
    Else
        KBPeekChar := True;
  End;



{
* Keyboard Read Character
*
* Return the next character from the keyboard buffer. Wait for a keystroke
* if the buffer is empty. For function keys, IBM PC scan codes are required.
-----------------------------------------------------------------------------}
Function X00Dvr.KBRead : Word;
  Begin
    If MaxFuncs < $0E Then
        Exit;
    Regs.AH := $0E;
    Intr(CommVect,Regs);
    KBRead := Regs.AX;
  End;



{
* Flow Control
*
* AL[0:0] 1= enables remote to restrain FOSSIL transmitter using XON/XOFF;
* AL[1:1] 1= enables modem restraint of FOSSIL transmitter using CTS and
*            FOSSIL restraint of modem using RTS
* AL[3:3] 1= enables FOSSIL to restrain remote using XON/XOFF.
-----------------------------------------------------------------------------}
Procedure X00Dvr.FlowControl(XONCTS : Byte);
  Begin
    If MaxFuncs < $0F Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $0F;
    Regs.Al := XonCTS;
    Intr(CommVect,Regs);
  End;



{
* Ctrl C Checking On
*
* AL[0:0] 1 = enable/disable CtlC/CtlK check (driver will set internal flag
*             which is returned by this function when it detects a CtlC/CtlK).
* AL[1:1] 1 = stop transmitter
*         0 = release previous stop
*             This is used primarily for programs that can't trust XON/XOFF
*             at FOSSIL level (such as BBS software).
-----------------------------------------------------------------------------}
Procedure X00Dvr.CtrlCChkOn;
  Begin
    If MaxFuncs < $10 Then
        Exit;
    Regs.Dx := Port;
    Regs.AH := $10;
    CtrlCFlags := CtrlCFlags Or 1;
    Regs.AL := CtrlCFlags;
    Intr(CommVect,Regs);
  End;



{
* Ctrl C Checking Off
*
* AL[0:0] 1 = enable/disable CtlC/CtlK check (driver will set internal flag
*             which is returned by this function when it detects a CtlC/CtlK).
* AL[1:1] 1 = stop transmitter
*         0 = release previous stop
*             This is used primarily for programs that can't trust XON/XOFF
*             at FOSSIL level (such as BBS software).
-----------------------------------------------------------------------------}
Procedure X00Dvr.CtrlCChkOff;
  Begin
    If MaxFuncs < $10 Then
        Exit;
    Regs.Dx := Port;
    Regs.AH := $10;
    CtrlCFlags := CtrlCFlags And Not 1;
    Regs.AL := CtrlCFlags;
    Intr(CommVect,Regs);
  End;



{
* Transmitter On
*
* AL[0:0] 1 = enable/disable CtlC/CtlK check (driver will set internal flag
*             which is returned by this function when it detects a CtlC/CtlK).
* AL[1:1] 1 = stop transmitter
*         0 = release previous stop
*             This is used primarily for programs that can't trust XON/XOFF
*             at FOSSIL level (such as BBS software).
-----------------------------------------------------------------------------}
Procedure X00Dvr.XmitOn;
  Begin
    If MaxFuncs < $10 Then
        Exit;
    Regs.Dx := Port;
    Regs.AH := $10;
    CtrlCFlags := CtrlCFlags And Not 2;
    Regs.AL := CtrlCFlags;
    Intr(CommVect,Regs);
  End;

--- FD 1.99c
 * Origin: If you clone around you'll end up talking to yourself! (1:105/324.1)

─ Turbo Pascal ──────────────────────────────────────────────────────── PASCAL ─
Msg  : 351 of 400                                                               
From : Gordon Tackett                      1:105/324.1          01 Apr 91  10:44 
To   : Roland Frederic                     2:292/500.0                           
Subj : BBS Program in TP. Part 5 of 5                                         
────────────────────────────────────────────────────────────────────────────────
{
* Transmitter Off
*
* AL[0:0] 1 = enable/disable CtlC/CtlK check (driver will set internal flag
*             which is returned by this function when it detects a CtlC/CtlK).
* AL[1:1] 1 = stop transmitter
*         0 = release previous stop
*             This is used primarily for programs that can't trust XON/XOFF
*             at FOSSIL level (such as BBS software).
-----------------------------------------------------------------------------}
Procedure X00Dvr.XmitOff;
  Begin
    If MaxFuncs < $10 Then
        Exit;
    Regs.Dx := Port;
    Regs.AH := $10;
    CtrlCFlags := CtrlCFlags Or 2;
    Regs.AL := CtrlCFlags;
    Intr(CommVect,Regs);
  End;



{
* Goto XY
*
* Identical to IBM PC BIOS INT 10h, subfunction 02h. FOSSIL should do
* sanity checks but software should not assume that that is the case.
-----------------------------------------------------------------------------}
Procedure  X00Dvr.GotoXY(X,Y : Word);
  Begin
    If MaxFuncs < $11 Then
        Exit;
    Regs.Dh := Lo(Y-1);
    Regs.Dl := Lo(X-1);
    Regs.AH := $11;
    Intr(CommVect,Regs);
  End;



{
* Get Cursor Location
*
* Identical to IBM PC BIOS INT 10h, subfunction 03h.
-----------------------------------------------------------------------------}
Procedure  X00Dvr.GetCursorLoc(Var X,Y : Word);
  Begin
    If MaxFuncs < $12 Then
        Exit;
    Regs.AH := $12;
    Intr(CommVect,Regs);
    Y := Regs.Dh + 1;
    X := Regs.Dl + 1;
  End;



{
* Ansi Write Character
*
* ANSI processing is a requirement of this call. It therefore should not be
* considered re-entrant, since DOS might be used (via ANSI.SYS)
-----------------------------------------------------------------------------}
Procedure X00Dvr.AnsiWriteChar(Ch : Char);
  Begin
    If MaxFuncs < $13 Then
        Exit;
    Regs.Al := Ord(Ch);
    Regs.AH := $13;
    Intr(CommVect,Regs);
  End;



{
* Enable Watch Dog
*
* FOSSIL will force the system to reboot if Carrier Detect on the specified
* port drops while "watchdog" is ON. It is not necessary for the port to
* be "active" (Function 04h) for this function to be used.
-----------------------------------------------------------------------------}
Procedure X00Dvr.EnableWatchDog;
  Begin
    If MaxFuncs < $14 Then
        Exit;
    Regs.AL := 1;
    Regs.Dx := Port;
    Regs.Ah := $14;
    Intr(CommVect,Regs);
  End;



{
* disable Watch Dog
*
* FOSSIL will force the system to reboot if Carrier Detect on the specified
* port drops while "watchdog" is ON. It is not necessary for the port to
* be "active" (Function 04h) for this function to be used.
-----------------------------------------------------------------------------}
Procedure X00Dvr.DisableWatchDog;
  Begin
    If MaxFuncs < $14 Then
        Exit;
    Regs.AL := 0;
    Regs.Dx := Port;
    Regs.Ah := $14;
    Intr(CommVect,Regs);
  End;



{
* Write Character
*
* Write character to screen using re-entrant code. ANSI processing may
* not be assumed. This call may be used by DOS device drivers.
-----------------------------------------------------------------------------}
Procedure  X00Dvr.WriteChar(Ch : Char);
  Begin
    If MaxFuncs < $15 Then
        Exit;
    Regs.AL := Ord(Ch);
    Regs.AH := $15;
    Intr(CommVect,Regs);
  End;



{
* Insert Timer Function
*
* Allows FOSSIL to manage timer tick chain, which provides some measure of
* security over just snagging the interrupt. Use "insert" instead of
* grabbing the vector and "remove" in place of restoring it.
-----------------------------------------------------------------------------}
Function X00Dvr.InsertTimerFunction(TF : TimerFunctionPtr) : Boolean;
  Begin
    If MaxFuncs < $16 Then
        Exit;
    Regs.AH := $16;
    Regs.AL := 1;
    Regs.ES := Seg(TF^);
    Regs.Dx := Ofs(TF^);
    Intr(CommVect,Regs);
    If Regs.Ax = 0 Then
        InsertTimerFunction := True
    Else
        InsertTimerFunction := False;
  End;



Function X00Dvr.DeleteTimerFunction(TF : TimerFunctionPtr) : Boolean;
  Begin
    Iä╬ε║DæB6±9 < $16 Then
        Exit;
    Regs.AH := $16;
    Regs.AL := 0;
    Regs.ES := Seg(TF^);
    Regs.Dx := Ofs(TF^);
    Intr(CommVect,Regs);
    If Regs.Ax = 0 Then
        DeleteTimerFunction := True
    Else
        DeleteTimerFunction := False;
  End;



{
* Reboot
*
* Provides a machine-independent way for a "troubled" application to reset
* the system. Some machines may not support both "flavors" of bootstrap,
* in which case the setting of AL will not have any effect.
-----------------------------------------------------------------------------}
Procedure  X00Dvr.Reboot(Tp : Boolean);
  Begin
    If MaxFuncs < $17 Then
        Exit;
    Regs.AH := $17;
    Regs.Al := 0;
    If Tp Then
      Regs.Al := 1;
    Intr(CommVect,Regs);
    WriteLn('System Error - Unable to ReBoot');
    While (True) Do;
  End;



{
* Receive Buffer
*
* Transfer as many characters as are available into the specified user
* buffer, up to the maximum specified in CX. ES and DI will not be modified
* by this call. The actual number of characters transferred will be in AX.
* This function does not wait for more characters to become available if the
* number in CX exceeds the number of characters currently stored.
-----------------------------------------------------------------------------}
Procedure X00Dvr.RecvBuffer(Buffer : Pointer; Var Sz : Word);
  Begin
    If MaxFuncs < $18 Then
        Exit;
    If (Self.GetStatus And $0100) = 0 Then
      Begin
        Size := 0;
        Exit;
      End;
    Regs.Dx := Port;
    Regs.Es := Seg(Buffer^);
    Regs.Di := Ofs(Buffer^);
    Regs.Cx := Sz;
    Regs.Ah := $18;
    Intr(CommVect,Regs);
    Size := Regs.Ax;
  End;



{
* Send Buffer
*
* Transfer as many characters as will fit, from the specified user buffer
* into the output buffer, up to the maximum specified in CX. ES and DI
* will not be modified by this call. The actual number of characters
* transferred will be in AX.
-----------------------------------------------------------------------------}
Procedure X00Dvr.SendBuffer(Buffer : Pointer; Sz : Word);
  Var
    Cptr   : ^Char;
    I     : Integer;
  Begin
    If MaxFuncs < $19 Then
        Exit;
    Cptr  := Buffer;
    Regs.Dx := Port;
    Regs.Es := Seg(Buffer^);
    Regs.Di := Ofs(Buffer^);
    Regs.Cx := Sz;
    Regs.Ah := $19;
    Intr(CommVect,Regs);
    If Regs.Ax <> Sz Then
      Begin
        Regs.Di := Regs.Di + Regs.Ax;
        Cptr := Ptr(Regs.Es, Regs.Di);
        For I := Regs.Ax To Sz Do
          Begin
            Self.TxChar(Cptr^);
            Cptr := Ptr(Seg(Cptr^),Ofs(Cptr^) + 1);
          End;
      End;
  End;



{
* Stop Break
*
* Used for special applications such as certain high speed modems. Resets
* all transmit flow control restraints (such as an XOFF received from remote)
* Init (Function 4) or UnInit (Function 5) will stop an in-progress Break.
* Note: the application must determine the "length" of the BREAK.
-----------------------------------------------------------------------------}
Procedure X00Dvr.StopBreak;
  Begin
    If MaxFuncs < $1A Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $1A;
    Regs.Al := 0;
    Intr(CommVect,Regs);
  End;



{
* Send Break
*
* Used for special applications such as certain high speed modems. Resets
* all transmit flow control restraints (such as an XOFF received from remote)
* Init (Function 4) or UnInit (Function 5) will stop an in-progress Break.
* Note: the application must determine the "length" of the BREAK.
-----------------------------------------------------------------------------}
Procedure X00Dvr.SendBreak;
  Begin
    If MaxFuncs < $1A Then
        Exit;
    Regs.Dx := Port;
    Regs.Ah := $1A;
    Regs.Al := 1;
    Intr(CommVect,Regs);
  End;



{
* Get Info Block
*
* Get The Info Block Record from Fossil to usable memory. An Info Block is:
*
* Offset 0 (word) = Structure size
*        2 (byte) = FOSSIL spec version
*        3 (byte) = Driver rev level
*        4 (dwrd) = Pointer to ASCII ID
*        8 (word) = Input buffer size
*       0A (word) = Bytes avail (input)
*       0C (word) = Output buffer size
*       0E (word) = Bytes avail (output)
*       10 (byte) = Screen width, chars
*       11 (byte) = Screen height, chars
*       12 (byte) = Baud rate mask
*                   (See call 00h)
-----------------------------------------------------------------------------}
Procedure  X00Dvr.GetInfo;
  Begin
    If MaxFuncs < $1B Then
        Exit;
    Regs.Cx := Sizeof(CurInfo);
    Regs.Es := Seg(CurInfo);
    Regs.Di := Ofs(CurInfo);
    Regs.Dx := Port;
    Regs.Ax := $1B;
    Intr(CommVect,Regs);
  End;



{
*
*
* Used to install user appendages into the INT 14h dispatcher.  Appendage
* codes 80h - BF are supported.  Codes 80h - 83h are reserved.  The error
* return,  BH = 00h and AX = 1954h, should mean that another appendage
* has already been installed with the code specified in AL.  The appendage
* will be entered via a far call whenever INT 14h call is made with AL
* equal to the appendage code.  The appendage should return to the INT
* 14h dispatcher via a far return.  The INT 14h dispatcher should not modify
* any registers prior to making the far call to the appendage and after the
* appendage returns control to the dispatcher.
-----------------------------------------------------------------------------}
{7E}
{
*
*
* Used to remove a user appendage that was installed using function 7Fh. An
* error return means that either the entry point specified in ES:DX did
* not match the entry point currently in the dispatcher table for the code
* given in AL,  or that no entry for the code given in AL currently exits.
-----------------------------------------------------------------------------}

{7F}

{$IFDEF LOCAL}
Var
  t1,t2,t3 : Word;
Begin
  Comm1.Init(0,2400,8,'N',2);
{$ENDIF}
End.

--- FD 1.99c
 * Origin: If you clone around you'll end up talking to yourself! (1:105/324.1)

