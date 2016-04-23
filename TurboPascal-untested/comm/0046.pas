{---------------------------------------------------------}
{  Project : Async12 for Windows                          }
{  By      : Ir. G.W van der Vegt                         }
{---------------------------------------------------------}
{  Based on the following TP product :                    }
{                                                         }
{  ASYNC12 - Interrupt-driven asyncronous                 }
{            communications for Turbo Pascal.             }
{                                                         }
{            Version 1.2 - Wedensday June 14, 1989        }
{            Copyright (C) 1989, Rising Edge Data Services}
{                                                         }
{            Permission is granted for non-commercial     }
{            use and distribution.                        }
{                                                         }
{            Author : Mark Schultz                        }
{                                                         }
{---------------------------------------------------------}
{                                                         }
{ -Because of the complex nature of serial I/O not all    }
{  routines are 100% tested. I don't feel/am/will ever be }
{  responsible for any damage caused by this routines.    }
{                                                         }
{ -Some routines don't work (yet) because some fields are }
{  mentioned in the BP7 help file but are missing in      }
{  Wintypes. The routines are SetCTSmode, SetRTSMode &    }
{  SoftHandshake.                                         }
{                                                         }
{ -Some routines can't be implemented in windows. They    }
{  are listed behind the end.                             }
{                                                         }
{ -From the original ASYNC12 code, only the syntax, some  }
{  high level pascal code and pieces of comment are used. }
{  Due to the different way windows handels devices, all  }
{  assembly codes couldn't be reused and was rewritten in }
{  Borland Pascal. I used parts of ASYNC12 because I find }
{  it a very complete package for Serial I/O and it works }
{  very well too. Sources were supplied and documented    }
{  very well.                                             }
{                                                         }
{---------------------------------------------------------}
{  Date   .Time  Revision                                 }
{  ------- ----  ---------------------------------------- }
{  9406017.1200  Creation.                                }
{---------------------------------------------------------}

Library Async12w;

Uses
  Winprocs,
  Wintypes;

{****************************************************************************}

{----Public definition section}

TYPE
  T_eoln     = (C_cr,C_lf);

CONST
  C_MaxCom   = 4;                   {----Supports COM1..COM4}
  C_MinBaud  = 110;
  C_MaxBaud  = 256000;

TYPE
  C_ports      = 1..C_MaxCom;       {----Subrange type to minimize programming errors}

{****************************************************************************}

{----Private definition section}

CONST
  portopen   : Array[C_ports] OF Boolean = (false,false,false,false);   {----Open port flags    }
  cids       : ARRAY[C_ports] OF Integer = (-1,-1,-1,-1);               {----Device ID's        }
  inbs       : ARRAY[C_ports] OF Word    = ( 0, 0, 0, 0);               {----Input  buffer sizes}
  outbs      : ARRAY[C_ports] OF Word    = ( 0, 0, 0, 0);               {----Output buffer sizes}
  txdir      = 0;                                                       {----Used for FlushCom  }
  rxdir      = 1;                                                       {----Used for FlushCom  }
  fon        = 1;                                                       {----Used for Handshakes}
  foff       = 0;                                                       {----Used for Handshakes}
  eolns      : ARRAY[C_ports] OF T_eoln  = (C_cr,C_cr,C_cr,C_cr);       {----Eoln characters    }

VAR
{----Don't seem to be declared in Wintypes, neccesary to fake}
  foutx,
  foutxCTSflow,
  fRTSflow   : Byte;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComReadCh(ComPort:Byte) : Char; External;                     *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                                                                          *}
{*  Returns character from input buffer of specified port.  If the buffer   *}
{*  is empty, the port # invalid or not opened, a Chr(0) is returned.       *}
{*                                                                          *}
{****************************************************************************}

Function ComReadCh(comport:C_ports) : Char; Export;

Var
  stat : TComStat;
  ch   : Char;
  cid  : Integer;

Begin
  ComReadCh:=#0;

  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

      {----See how many characters are in the rx buffer}
        If (GetCommError(cid,stat)=0) AND
           (stat.cbInQue>0)           AND
           (ReadComm(cid,@ch,1)=1)
          THEN ComReadCh:=ch;
      End;
END; {of ComReadCh}

{****************************************************************************}
{*                                                                          *}
{*  Function ComReadChW(ComPort:Byte) : Char; External;                     *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                                                                          *}
{*  Works like ComReadCh, but will wait until at least 1 character is       *}
{*  present in the specified input buffer before exiting.  Thus, ComReadChW *}
{*  works much like the ReadKey predefined function.                        *}
{*                                                                          *}
{****************************************************************************}

Function ComReadChW(comport:C_ports) : Char; Export;

Var
  stat : TComStat;
  ch   : Char;
  ok   : Boolean;
  cid  : Integer;

Begin
  ComReadChW:=#00;

  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];
        ok :=false;

      {----See how many characters are in the rx buffer}
        REPEAT
          IF (GetCommError(cid,stat)<>0)
            THEN ok:=True
            ELSE
              BEGIN
                IF (stat.cbInQue<>0)       AND
                   (ReadComm(cid,@ch,1)=1)
                  THEN ComReadChW:=ch;
                ok:=true;
              END;
        UNTIL ok;
      End;
END; {of ComReadChW}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteCh(ComPort:Byte; Ch:Char); External                   *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*  Ch:Char       ->  Character to send                                     *}
{*                                                                          *}
{*  Places the character [Ch] in the transmit buffer of the specified port. *}
{*  If the port specified is not open or nonexistent, or if the buffer is   *}
{*  filled, the character is discarded.                                     *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteCh(comport:C_ports; Ch:Char); Export;

VAR
  stat : TComStat;
  cid  : Integer;

BEGIN
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

        IF (GetCommError(cid,stat)=0)   AND
           (stat.cbOutQue<outbs[comport])
          THEN TransmitCommChar(cid,ch);
      End;
END; {of CommWriteCh}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteChW(ComPort:Byte; Ch:Char); External;                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*  Ch:Char       ->  Character to send                                     *}
{*                                                                          *}
{*  Works as ComWriteCh, but will wait until at least 1 free position is    *}
{*  available in the output buffer before attempting to place the character *}
{*  [Ch] in it.  Allows the programmer to send characters without regard to *}
{*  available buffer space.                                                 *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteChW(comport:C_ports; Ch:Char); Export;

VAR
  stat : TComStat;
  cid  : Integer;
  rdy  : Boolean;

BEGIN
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];
        rdy:=False;

        REPEAT
          IF (GetCommError(cid,stat)<>0)
            THEN rdy:=true
            ELSE
              IF (stat.cbOutQue<outbs[comport])
                THEN rdy:=TransmitCommChar(cid,ch)=0;
        UNTIL rdy;
      End;
End; {of ComWriteChW}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ClearCom(ComPort:Byte); IO:Char)                              *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  IO:Char       ->  Action code; I=Input, O=Output, B=Both                *}
{*                    No action taken if action code unrecognized.          *}
{*                                                                          *}
{*  ClearCom allows the user to completely clear the contents of either     *}
{*  the input (receive) and/or output (transmit) buffers.  The "action      *}
{*  code" passed in <IO> determines if the input (I) or output (O) buffer   *}
{*  is cleared.  Action code (B) will clear both buffers.  This is useful   *}
{*  if you wish to cancel a transmitted message or ignore part of a         *}
{*  received message.                                                       *}
{*                                                                          *}
{****************************************************************************}

Procedure ClearCom(ComPort:C_Ports;IO:Char); Export;

Var
  cid  : Integer;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

        Case Upcase(IO) OF
          'I' : FlushComm(cid,rxdir);
          'B' : Begin
                  FlushComm(cid,rxdir);
                  FlushComm(cid,txdir);
                End;
          'O' : FlushComm(cid,txdir);
        End;
      End;
End; {of ClearComm}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComBufferLeft(ComPort:Byte; IO:Char) : Word                   *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Returns 0 if Port # invalid or unopened.              *}
{*  IO:Char       ->  Action code; I=Input, O=Output                        *}
{*                    Returns 0 if action code unrecognized.                *}
{*                                                                          *}
{*  ComBufferLeft will return a number (bytes) indicating how much space    *}
{*  remains in the selected buffer.  The INPUT buffer is checked if <IO> is *}
{*  (I), and the output buffer is interrogated when <IO> is (O).  Any other *}
{*  "action code" will return a result of 0.  Use this function when it is  *}
{*  important to avoid program delays due to calls to output procedures or  *}
{*  to prioritize the reception of data (to prevent overflows).             *}
{*                                                                          *}
{****************************************************************************}

Function ComBufferLeft(ComPort:C_ports; IO:Char) : Word; Export;

VAR
  stat : TComStat;
  cid  : Integer;

Begin
  ComBufferLeft := 0;

  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

        IF (GetCommError(cid,stat)=0)
          THEN
            CASE Upcase(IO) OF
              'I' : ComBufferLeft:=inbs [comport]-stat.cbInQue;
              'O' : ComBufferLeft:=outbs[comport]-stat.cbOutQue;
            END;
      End;
End; {ComBufferLeft}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWaitForClear(ComPort:Byte)                                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*                                                                          *}
{*  A call to ComWaitForClear will stop processing until the selected out-  *}
{*  put buffer is completely emptied.  Typically used just before a call    *}
{*  to the CloseCom procedure to prevent premature cut-off of messages in   *}
{*  transit.                                                                *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWaitForClear(ComPort:C_ports); Export;

Var
  stat  : TComStat;
  cid   : Integer;
  Empty : Boolean;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid  :=cids[comport];
        empty:=false;

        REPEAT
          IF (GetCommError(cid,stat)<>0)
            THEN empty:=true
            ELSE empty:=stat.cbOutQue=0
        UNTIL empty;
      End;
End; {ComWaitForClear}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWrite(ComPort:Byte; St:String)                             *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     ->  String to send                                        *}
{*                                                                          *}
{*  Sends string <St> out communications port <ComPort>.                    *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWrite(ComPort:C_ports; St:String); Export;

Var
  X : Byte;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      For X := 1 To Length(St) Do
        ComWriteChW(ComPort,St[X]);
End; {of ComWrite}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteln(ComPort:Byte; St:String);                          *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     ->  String to send                                        *}
{*                                                                          *}
{*  Sends string <St> with a CR and LF appended.                            *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteln(ComPort:C_ports; St:String); Export;

Var
  X : Byte;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        For X := 1 To Length(St) Do
          ComWriteChW(ComPort,St[X]);
        ComWriteChW(ComPort,#13);
        ComWriteChW(ComPort,#10);
      End;
End; {of ComWriteln}

{****************************************************************************}
{*                                                                          *}
{*  Procedure Delay(ms:word);                                               *}
{*                                                                          *}
{*  ms:word       ->  Number of msec to wait.                               *}
{*                                                                          *}
{*  A substitute for CRT's Delay under DOS. This one will wait for at least *}
{*  the amount of msec specified, probably even more because of the task-   *)
{*  switching nature of Windows. So a msec can end up as a second if ALT-TAB*}
{*  or something like is pressed. Minumum delays are guaranteed independend *}
{*  of task-switches.                                                       *}
{*                                                                          *}
{****************************************************************************}

Procedure Delay(ms : Word);

Var
  theend,
  marker  : Longint;

Begin
{----Potentional overflow if windows runs for 49 days without a stop}
  marker:=GetTickCount;
{$R-}
  theend:=Longint(marker+ms);
{$R+}

{----First see if timer overrun will occure and wait for this,
     then test as usual}
  If (theend<marker)
    Then
      While (GetTickCount>=0) DO;

{----Wait for projected time to pass}
  While (theend>=GettickCount) Do;
End; {of Delay}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteWithDelay(ComPort:Byte; St:String; Dly:Word);         *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     ->  String to send                                        *}
{*  Dly:Word      ->  Time, in milliseconds, to delay between each char.    *}
{*                                                                          *}
{*  ComWriteWithDelay will send string <St> to port <ComPort>, delaying     *}
{*  for <Dly> milliseconds between each character.  Useful for systems that *}
{*  cannot keep up with transmissions sent at full speed.                   *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteWithDelay(ComPort:C_ports; St:String; Dly:Word); Export;

Var
  X   : Byte;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        ComWaitForClear(ComPort);
        For X := 1 To Length(St) Do
          Begin
            ComWriteChW(ComPort,St[X]);
            ComWaitForClear(ComPort);
            Delay(dly);
          End;
      End;
End; {of ComWriteWithDelay}

{****************************************************************************}
{*                                                                          *}
{* Procedure ComReadln(ComPort:Byte; Var St:String; Size:Byte; Echo:Boolean)*}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     <-  Edited string from remote                             *}
{*  Size:Byte;    ->  Maximum allowable length of input                     *}
{*  Echo:Boolean; ->  Set TRUE to echo received characters                  *}
{*                                                                          *}
{*  ComReadln is the remote equivalent of the standard Pascal READLN pro-   *}
{*  cedure with some enhancements.  ComReadln will accept an entry of up to *}
{*  40 printable ASCII characters, supporting ^H and ^X editing commands.   *}
{*  Echo-back of the entry (for full-duplex operation) is optional.  All    *}
{*  control characters, as well as non-ASCII (8th bit set) characters are   *}
{*  stripped.  If <Echo> is enabled, ASCII BEL (^G) characters are sent     *}
{*  when erroneous characters are intercepted.  Upon receipt of a ^M (CR),  *}
{*  the procedure is terminated and the final string result returned.       *}
{*                                                                          *}
{****************************************************************************}

Procedure ComReadln(ComPort:C_ports; Var St:String; Size:Byte; Echo:Boolean); Export;

Var
  Len,X : Byte;
  Ch    : Char;
  Done  : Boolean;

Begin
  St:='';
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        Done := False;
        Repeat
          Len:=Length(St);
          Ch :=Chr(Ord(ComReadChW(ComPort)) And $7F);

          Case Ch Of
            ^H : If Len>0
                  Then
                    Begin
                      Dec(Len);
                      St[0]:=Chr(Len);
                      If Echo Then ComWrite(ComPort,#8#32#8);
                    End
                  Else ComWriteChW(ComPort,^G);
            ^J : If eolns[comport]=C_lf
                   Then
                     Begin
                       Done:=True;
                       If Echo Then ComWrite(ComPort,#13#10);
                     End;
            ^M : If eolns[comport]=C_cr
                   Then
                     Begin
                       Done:=True;
                       If Echo Then ComWrite(ComPort,#13#10);
                     End;
            ^X : Begin
                   St:='';
                   If Len=0 Then ComWriteCh(ComPort,^G);
                   If Echo
                     Then
                       For X:=1 to Len Do
                         ComWrite(ComPort,#8#32#8);
                 End;
          #32..
          #127 : If Len<Size
                   Then
                     Begin
                       Inc(Len);
                       St[Len]:=Ch;
                       St[0]:=Chr(Len);
                       If Echo Then ComWriteChW(ComPort,Ch);
                     End
                   Else
                     If Echo Then ComWriteChW(ComPort,^G);
          Else
            If Echo Then ComWriteChW(ComPort,^G)
          End;
        Until Done;
      End;
End; {of ComReadln}

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetRTSMode(ComPort:Byte; Mode:Boolean; RTSOn,RTSOff:Word)     *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  Mode:Boolean  ->  TRUE to enable automatic RTS handshake                *}
{*  RTSOn:Word    ->  Buffer-usage point at which the RTS line is asserted  *}
{*  RTSOff:Word   ->  Buffer-usage point at which the RTS line is dropped   *}
{*                                                                          *}
{*  SetRTSMode enables or disables automated RTS handshaking.  If [MODE] is *}
{*  TRUE, automated RTS handshaking is enabled.  If enabled, the RTS line   *}
{*  will be DROPPED when the # of buffer bytes used reaches or exceeds that *}
{*  of [RTSOff].  The RTS line will then be re-asserted when the buffer is  *}
{*  emptied down to the [RTSOn] usage point.  If either [RTSOn] or [RTSOff] *}
{*  exceeds the input buffer size, they will be forced to (buffersize-1).   *}
{*  If [RTSOn] > [RTSOff] then [RTSOn] will be the same as [RTSOff].        *}
{*  The actual handshaking control is located in the interrupt driver for   *}
{*  the port (see ASYNC12.ASM).                                             *}
{*                                                                          *}
{****************************************************************************}

Procedure SetRTSmode(ComPort:C_ports; Mode:Boolean; RTSOn,RTSOff:Word); Export;

Var
  dcb : tdcb;
  cid : Integer;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

        If GetCommState(cid,dcb)=0
          Then
            Begin
              With dcb Do
                Case mode of
                  True  : Begin
                            fRTSflow:=fon;
                            Xonlim  :=inbs[comport]-RTSon ;
                            Xofflim :=inbs[comport]-RTSoff;
                          End;
                  False : Begin
                            fRTSflow:=foff;
                          End;
                End;
              SetCommState(dcb);
            End;
      End;
End; {of SetRTSmode}

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetCTSMode(ComPort:Byte; Mode:Boolean)                        *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  Mode:Boolean  ->  Set to TRUE to enable automatic CTS handshake.        *}
{*                                                                          *}
{*  SetCTSMode allows the enabling or disabling of automated CTS handshak-  *}
{*  ing.  If [Mode] is TRUE, CTS handshaking is enabled, which means that   *}
{*  if the remote drops the CTS line, the transmitter will be disabled      *}
{*  until the CTS line is asserted again.  Automatic handshake is disabled  *}
{*  if [Mode] is FALSE.  CTS handshaking and "software" handshaking (pro-   *}
{*  vided by the SoftHandshake procedure) ARE compatable and may be used    *}
{*  in any combination.                                                     *}
{*                                                                          *}
{****************************************************************************}

Procedure SetCTSMode(ComPort:Byte; Mode:Boolean); Export;

Var
  dcb : tdcb;
  cid : Integer;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

        If GetCommState(cid,dcb)=0
          Then
            Begin
              Case mode of
                True  : foutxCTSflow:=fon;
                False : foutxCTSflow:=foff;
              End;
              SetCommState(dcb);
            End;
      End;
End; {of SetCTSmode}

{****************************************************************************}
{*                                                                          *}
{*  Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char)    *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  Mode:Boolean  ->  Set to TRUE to enable transmit software handshake     *}
{*  Start:Char    ->  START control character (usually ^Q)                  *}
{*                    Defaults to ^Q if character passed is >= <Space>      *}
{*  Stop:Char     ->  STOP control character (usually ^S)                   *}
{*                    Defaults to ^S if character passed is >= <Space>      *}
{*                                                                          *}
{*  SoftHandshake controls the usage of "Software" (control-character)      *}
{*  handshaking on transmission.  If "software handshake" is enabled        *}
{*  ([Mode] is TRUE), transmission will be halted if the character in       *}
{*  [Stop] is received.  Transmission is re-enabled if the [Start] char-    *}
{*  acter is received.  Both the [Start] and [Stop] characters MUST be      *}
{*  CONTROL characters (i.e. Ord(Start) and Ord(Stop) must both be < 32).   *}
{*  Also, <Start> and <Stop> CANNOT be the same character.  If either one   *}
{*  of these restrictions are violated, the defaults (^Q for <Start> and ^S *}
{*  for <Stop>) will be used.                                               *}
{*                                                                          *}
{****************************************************************************}

Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char); Export;

Var
  dcb : tdcb;
  cid : integer;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

        If GetCommState(cid,dcb)=0
          Then
            Begin
              Case mode of
                True  : Begin
                          foutx:=fon;
                          If (start IN [#00..#31]) And (start<>stop)
                            Then dcb.Xonchar:=start
                            Else dcb.Xonchar:=^Q;
                          If (stop  IN [#00..#31]) And (start<>stop)
                            Then dcb.Xoffchar:=stop
                            Else dcb.Xoffchar:=^S;
                        End;
                False : foutx:=foff;
              End;
              SetCommState(dcb);
            End;
      End;
End; {of Softhandshake}

{****************************************************************************}
{*                                                                          *}
{*  Function ComExist(ComPort:Byte) : Boolean                               *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Returns FALSE if out of range                         *}
{*  Returns TRUE if hardware for selected port is detected & tests OK       *}
{*                                                                          *}
{****************************************************************************}

Function ComExist(ComPort:C_ports) : Boolean; Export;

VAR
  mode : String;
  dcb  : tdcb;

Begin
  If (ComPort IN [1..C_MaxCom])
    Then
      Begin
        mode:='COM'+Chr(Comport+Ord('0'))+' 19200,N,8,1'#0;
        ComExist:=(BuildCommDCB(@mode[1],dcb)=0);
      End
    Else ComExist:=false;
End; {of Comexist}

{****************************************************************************}
{*                                                                          *}
{*  Function ComTrueBaud(Baud:Longint) : Real                               *}
{*                                                                          *}
{*  Baud:Longint  ->  User baud rate to test.                               *}
{*                    Should be between C_MinBaud and C_MaxBaud.            *}
{*  Returns the actual baud rate based on the accuracy of the 8250 divider. *}
{*                                                                          *}
{*  The ASYNC12 communications package allows the programmer to select ANY  *}
{*  baud rate, not just those that are predefined by the BIOS or other      *}
{*  agency.  Since the 8250 uses a divider/counter chain to generate it's   *}
{*  baud clock, many non-standard baud rates can be generated.  However,    *}
{*  the binary counter/divider is not always capable of generating the      *}
{*  EXACT baud rate desired by a user.  This function, when passed a valid  *}
{*  baud rate, will return the ACTUAL baud rate that will be generated.     *}
{*  The baud rate is based on a 8250 input clock rate of 1.73728 MHz.       *}
{*                                                                          *}
{****************************************************************************}

Function ComTrueBaud(Baud:Longint) : Real; Export;

Var
  X : Real;
  Y : Word;

Begin
  X := Baud;
  If X < C_MinBaud Then X := C_MinBaud;
  If X > C_MaxBaud Then X := C_MaxBaud;
  ComTrueBaud := C_MaxBaud / Round($900/(X/50));
End; {of ComTrueBaud}

{****************************************************************************}
{*                                                                          *}
{* Function Lstr(l : Longint) : String;                                     *}
{*                                                                          *}
{* l:Longint       ->  Number converted to a string                         *}
{*                                                                          *}
{* This function converts longint l to a string.                            *}
{*                                                                          *}
{****************************************************************************}

Function Lstr(l : Longint) : String;

Var
  s : String;

Begin
  Str(l:0,s);
  Lstr:=s;
End; {of Lstr}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComParams(ComPort:Byte; Baud:Longint;                         *}
{*                      WordSize:Byte; Parity:Char; StopBits:Byte);         *}
{*                                                                          *}
{*  ComPort:Byte   ->  Port # to initialize.  Must be (1 - C_MaxCom)        *}
{*                     Procedure aborted if port # invalid or unopened.     *}
{*  Baud:Longint   ->  Desired baud rate.  Should be (C_MinBaud - C_MaxBaud)*}
{*                     C_MinBaud or C_MaxBaud used if out of range.         *}
{*  WordSize:Byte  ->  Word size, in bits.  Must be 5 - 8 bits.             *}
{*                     8-bit word used if out of range.                     *}
{*  Parity:Char    ->  Parity classification.                               *}
{*                     May be N)one, E)ven, O)dd, M)ark or S)pace.          *}
{*                     N)one selected if classification unknown.            *}
{*  StopBits:Byte  ->  # of stop bits to pad character with.  Range (1-2)   *}
{*                     1 stop bit used if out of range.                     *}
{*                                                                          *}
{*  ComParams is used to configure an OPEN'ed port for the desired comm-    *}
{*  unications parameters, namely baud rate, word size, parity form and     *}
{*  # of stop bits.  A call to this procedure will set up the port approp-  *}
{*  riately, as well as assert the DTR, RTS and OUT2 control lines and      *}
{*  clear all buffers.                                                      *}
{*                                                                          *}
{****************************************************************************}

Procedure ComParams(ComPort:C_ports; Baud:LongInt; WordSize:Byte; Parity:Char; StopBits:Byte); Export;

Var
  mode : String;
  cid  : Integer;
  dcb  : tdcb;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];

      {----Like COM1 9600,N,8,1}
        mode:='COM'+Chr(Comport+Ord('0'))+' '+Lstr(baud)+','+Upcase(Parity)+','+Lstr(Wordsize)+','+Lstr(stopbits)+#0;
        IF (BuildCommDCB(@mode[1],dcb)=0)
          Then
            Begin
              dcb.id:=cid;
              SetCommState(dcb);
            End;
      End;
End; {of ComParams}

{****************************************************************************}
{*                                                                          *}
{*  Function OpenCom(ComPort:Byte; InBufferSize,OutBufferSize:Word):Boolean *}
{*                                                                          *}
{*  ComPort:Byte        ->  Port # to OPEN (1 - C_MaxCom)                   *}
{*                          Request will fail if out of range or port OPEN  *}
{*  InBufferSize:Word   ->  Requested size of input (receive) buffer        *}
{*  OutBufferSize:Word  ->  Requested size of output (transmit) buffer      *}
{*  Returns success/fail status of OPEN request (TRUE if OPEN successful)   *}
{*                                                                          *}
{*  OpenCom must be called before any activity (other than existence check, *}
{*  see the ComExist function) takes place.  OpenCom initializes the        *}
{*  interrupt drivers and serial communications hardware for the selected   *}
{*  port, preparing it for I/O. Once a port has been OPENed, a call to      *}
{*  ComParams should be made to set up communications parameters (baud rate,*}
{*  parity and the like).  Once this is done, I/O can take place on the     *}
{*  port. OpenCom will return a TRUE value if the opening procedure was     *}
{*  successful, or FALSE if it is not.                                      *}
{*                                                                          *}
{****************************************************************************}

Function OpenCom(ComPort:C_ports; InBufferSize,OutBufferSize:Word) : Boolean; Export;

Var
  cid  : Integer;
  comp : String;

Begin
  OpenCom := False;
  If    (ComPort IN [1..C_MaxCom]) And
     Not(portopen[ComPort])      And
         ComExist(comport)
    Then
      Begin
        comp:='COM'+Chr(comport+Ord('0'))+#0;
        cid:=OpenComm(@comp[1],InBufferSize,OutBufferSize);
        If (cid>=0)
          Then
            Begin
              cids [comport]     :=cid;
              inbs [comport]     :=InBufferSize;
              outbs[comport]     :=OutBufferSize;
              portopen[comport]:=true;
            End;
        OpenCom:=(cid>=0);
      End;
End; {of OpenCom}

{****************************************************************************}
{*                                                                          *}
{*  Procedure CloseCom(ComPort:Byte)                                        *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to close                                       *}
{*                    Request ignored if port closed or out of range.       *}
{*                                                                          *}
{*  CloseCom will un-link the interrupt drivers for a port, deallocate it's *}
{*  buffers and drop the DTR and RTS signal lines for a port opened with    *}
{*  the OpenCom function.  It should be called before exiting your program  *}
{*  to ensure that the port is properly shut down.                          *}
{*  NOTE:  CloseCom shuts down a communications channel IMMEDIATELY,        *}
{*         even if there is data present in the input or output buffers.    *}
{*         Therefore, you may wish to call the ComWaitForClear procedure    *}
{*         before closing the ports.                                        *}
{*                                                                          *}
{****************************************************************************}

Procedure CloseCom(ComPort:C_ports); Export;

Var
  cid : integer;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      Begin
        cid:=cids[comport];
        portopen[comport]:=Not(CloseComm(cid)=0);
      End;
End; {of CloseCom}

{****************************************************************************}
{*                                                                          *}
{*  Procedure CloseAllComs                                                  *}
{*                                                                          *}
{*  CloseAllComs will CLOSE all currently OPENed ports.  See the CloseCom   *}
{*  procedure description for more details.                                 *}
{*                                                                          *}
{****************************************************************************}

Procedure CloseAllComs; Export;

Var
  X : C_ports;

Begin
  For X := 1 To C_MaxCom Do
    If portopen[X] Then CloseCom(X);
End; {of CloseAllComs}

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComSetEoln(ComPort:C_ports;EolnCh : T_eoln)                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # for which to alter the eoln character          *}
{*                    Request ignored if port closed or out of range.       *}
{*  EolnCh:T_eoln ->  Eoln character needed                                 *}
{*                                                                          *}
{*  With this function one can toggle the eoln character between cr and lf. *}
{*                                                                          *}
{****************************************************************************}

Procedure ComSetEoln(ComPort:C_ports;EolnCh : T_eoln); Export;

Begin
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then eolns[comport]:=EolnCh;
End; {of ComSetEoln}

{****************************************************************************}
{*                                                                          *}
{*  Function  ComGetBufsize(ComPort:C_ports;IO : char)                      *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # for which to retrieve the buffersize           *}
{*                    Request ignored if port closed or out of range.       *}
{*  IO:Char       ->  Action code; I=Input, O=Output                        *}
{*                    Returns 0 if action code unrecognized.                *}
{*                                                                          *}
{*  This function will return the buffer size defined for a serial port.    *}
{*                                                                          *}
{****************************************************************************}

Function ComGetBufsize(ComPort:C_ports;IO : Char) : WORD; Export;

Begin
  ComGetBufSize:=0;
  If (ComPort IN [1..C_MaxCom]) And
     (portopen[ComPort])
    Then
      CASE Upcase(IO) OF
        'I' : ComgetBufSize:=inbs [comport];
        'O' : ComgetBufSize:=outbs[comport];
      END;
End; {of ComGetBufferSize}

{****************************************************************************}

Exports
  ComReadCh         index  1,
  ComReadChW        index  2,
  ComWriteCh        index  3,
  ComWriteChW       index  4,
  ClearCom          index  5,
  ComBufferLeft     index  6,
  ComWaitForClear   index  7,
  ComWrite          index  8,
  ComWriteln        index  9,
  ComWriteWithDelay index 10,
  ComReadln         index 11,
  SetRTSmode        index 12,
  SetCTSMode        index 13,
  SoftHandshake     index 14,
  ComExist          index 15,
  ComTrueBaud       index 16,
  ComParams         index 17,
  OpenCom           index 18,
  CloseCom          index 19,
  CloseAllComs      index 20,
  ComSetEoln        index 21,
  ComGetBufSize     index 22;

Begin
End.

{----The following procedures/functions from the async12 }
{    package are not available                           }

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetDTR(ComPort:Byte; Assert:Boolean);                         *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  DTR assertion flag (TRUE to assert DTR)             *}
{*                                                                          *}
{*  Provides a means to control the port's DTR (Data Terminal Ready) signal *}
{*  line.  When [Assert] is TRUE, the DTR line is placed in the "active"    *}
{*  state, signalling to a remote system that the host is "on-line"         *}
{*  (although not nessesarily ready to receive data - see SetRTS).          *}
{*                                                                          *}
{****************************************************************************}

Procedure SetDTR(ComPort:Byte; Assert:Boolean);

Begin
End; {of SetDTR}

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetRTS(ComPort:Byte; Assert:Boolean)                          *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  RTS assertion flag (Set TRUE to assert RTS)         *}
{*                                                                          *}
{*  SetRTS allows a program to manually control the Request-To-Send (RTS)   *}
{*  signal line.  If RTS handshaking is disabled (see C_Ctrl definition     *}
{*  and the the SetRTSMode procedure), this procedure may be used.  SetRTS  *}
{*  should NOT be used if RTS handshaking is enabled.                       *}
{*                                                                          *}
{****************************************************************************}

Procedure SetRTS(ComPort:Byte; Assert:Boolean);

Begin
End; {of SetRTS}

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetOUT1(ComPort:Byte; Assert:Boolean)                         *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  OUT1 assertion flag (set TRUE to assert OUT1 line)  *}
{*                                                                          *}
{*  SetOUT1 is provided for reasons of completeness only, since the         *}
{*  standard PC/XT/AT configurations do not utilize this control signal.    *}
{*  If [Assert] is TRUE, the OUT1 signal line on the 8250 will be set to a  *}
{*  LOW logic level (inverted logic).  The OUT1 signal is present on pin 34 *}
{*  of the 8250 (but not on the port itself).                               *}
{*                                                                          *}
{****************************************************************************}

Procedure SetOUT1(ComPort:Byte; Assert:Boolean);

Begin
End;  {of SetOUT1}

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetOUT2(ComPort:Byte; Assert:Boolean)                         *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  OUT2 assertion flag (set TRUE to assert OUT2 line)  *}
{*                                                                          *}
{*  The OUT2 signal line, although not available on the port itself, is     *}
{*  used to gate the 8250 <INTRPT> (interrupt) line and thus acts as a      *}
{*  redundant means of controlling 8250 interrupts.  When [Assert] is TRUE, *}
{*  the /OUT2 line on the 8250 is lowered, which allows the passage of the  *}
{*  <INTRPT> signal through a gating arrangement, allowing the 8250 to      *}
{*  generate interrupts.  Int's can be disabled bu unASSERTing this line.   *}
{*                                                                          *}
{****************************************************************************}

Procedure SetOUT2(ComPort:Byte; Assert:Boolean);

Begin
End; {of SetOUT2}

{****************************************************************************}
{*                                                                          *}
{*  Function CTSStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*  Returns status of Clear-To-Send line (TRUE if CTS asserted)             *}
{*                                                                          *}
{*  CTSStat provides a means to interrogate the Clear-To-Send hardware      *}
{*  handshaking line.  In a typical arrangement, when CTS is asserted, this *}
{*  signals the host (this computer) that the receiver is ready to accept   *}
{*  data (in contrast to the DSR line, which signals the receiver as        *}
{*  on-line but not nessesarily ready to accept data).  An automated mech-  *}
{*  ansim (see CTSMode) is provided to do this, but in cases where this is  *}
{*  undesirable or inappropriate, the CTSStat function can be used to int-  *}
{*  terrogate this line manually.                                           *}
{*                                                                          *}
{****************************************************************************}

Function CTSStat(ComPort:Byte) : Boolean;

Begin
End; {of CTSstat}

{****************************************************************************}
{*                                                                          *}
{*  Function DSRStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*  Returns status of Data Set Ready (DSR) signal line.                     *}
{*                                                                          *}
{*  The Data Set Ready (DSR) line is typically used by a remote station     *}
{*  to signal the host system that it is on-line (although not nessesarily  *}
{*  ready to receive data yet - see CTSStat).  A remote station has the DSR *}
{*  line asserted if DSRStat returns TRUE.                                  *}
{*                                                                          *}
{****************************************************************************}

Function DSRStat(ComPort:Byte) : Boolean;

Begin
End; {of DSRstat}

{****************************************************************************}
{*                                                                          *}
{*  Function RIStat(ComPort:Byte) : Boolean                                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*                                                                          *}
{*  Returns the status of the Ring Indicator (RI) line.  This line is       *}
{*  typically used only by modems, and indicates that the modem has detect- *}
{*  ed an incoming call if RIStat returns TRUE.                             *}
{*                                                                          *}
{****************************************************************************}

Function RIStat(ComPort:Byte) : Boolean;

Begin
End; {of RIstat}

{****************************************************************************}
{*                                                                          *}
{*  Function DCDStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*                                                                          *}
{*  Returns the status of the Data Carrier Detect (DCD) line from the rem-  *}
{*  ote device, typically a modem.  When asserted (DCDStat returns TRUE),   *}
{*  the modem indicates that it has successfuly linked with another modem   *}
{*  device at another site.                                                 *}
{*                                                                          *}
{****************************************************************************}

Function DCDStat(ComPort:Byte) : Boolean;

Begin
End; {of DCDstat}

{ ---------------    WINDOWS INTERFACE UNIT -------------------- }

Unit WinAsync;

Interface

CONST
  C_MaxCom   = 4;             {----supports COM1..COM4                        }
  C_MinBaud  = 110;           {----min baudrate supported by windows 3.1      }
  C_MaxBaud  = 256000;        {----max baudrate supported by windows 3.1      }

TYPE
  T_eoln     = (C_cr,C_lf);   {----used to change EOLN character from cr to lf}
  C_ports    = 1..C_MaxCom;   {----subrange type to minimize programming errors}


Function  ComReadCh(comport:C_ports)  : Char;
Function  ComReadChW(comport:C_ports) : Char;
Procedure ComReadln(ComPort:C_ports; Var St:String; Size:Byte; Echo:Boolean);

Procedure ComWriteCh(comport:C_ports; Ch:Char);
Procedure ComWriteChW(comport:C_ports; Ch:Char);
Procedure ComWrite(ComPort:C_ports; St:String);
Procedure ComWriteln(ComPort:C_ports; St:String);
Procedure ComWriteWithDelay(ComPort:C_ports; St:String; Dly:Word);

Procedure ClearCom(ComPort:C_Ports;IO:Char);
Function  ComBufferLeft(ComPort:C_ports; IO:Char) : Word;
Procedure ComWaitForClear(ComPort:C_ports);

Procedure SetRTSmode(ComPort:C_ports; Mode:Boolean; RTSOn,RTSOff:Word);
Procedure SetCTSMode(ComPort:Byte; Mode:Boolean);
Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char);

Function  ComExist(ComPort:C_ports) : Boolean;
Procedure ComParams(ComPort:C_ports; Baud:LongInt; WordSize:Byte; Parity:Char; StopBits:Byte);
Function  ComTrueBaud(Baud:Longint) : Real;
Function  OpenCom(ComPort:C_ports; InBufferSize,OutBufferSize:Word) : Boolean;

Procedure CloseCom(ComPort:C_ports);
Procedure CloseAllComs;
Procedure ComSetEoln(ComPort:C_ports;EolnCh : T_eoln);

Function ComGetBufsize(ComPort:C_ports;IO : Char) : WORD;

Implementation

Function  ComReadCh(comport:C_ports)  : Char;                                  external 'async12w';
Function  ComReadChW(comport:C_ports) : Char;                                  external 'async12w';
Procedure ComWriteCh(comport:C_ports; Ch:Char);                                external 'async12w';
Procedure ComWriteChW(comport:C_ports; Ch:Char);                               external 'async12w';
Procedure ClearCom(ComPort:C_Ports;IO:Char);                                   external 'async12w';
Function  ComBufferLeft(ComPort:C_ports; IO:Char) : Word;                      external 'async12w';
Procedure ComWaitForClear(ComPort:C_ports);                                    external 'async12w';
Procedure ComWrite(ComPort:C_ports; St:String);                                external 'async12w';
Procedure ComWriteln(ComPort:C_ports; St:String);                              external 'async12w';
Procedure ComWriteWithDelay(ComPort:C_ports; St:String; Dly:Word);             external 'async12w';
Procedure ComReadln(ComPort:C_ports; Var St:String;Size:Byte; Echo:Boolean);   external 'async12w';
Procedure SetRTSmode(ComPort:C_ports; Mode:Boolean; RTSOn,RTSOff:Word);        external 'async12w';
Procedure SetCTSMode(ComPort:Byte; Mode:Boolean);                              external 'async12w';
Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char);          external 'async12w';
Function  ComExist(ComPort:C_ports) : Boolean;                                 external 'async12w';
Function  ComTrueBaud(Baud:Longint) : Real;                                    external 'async12w';
Procedure ComParams(ComPort:C_ports; Baud:LongInt; WordSize:Byte;
                                     Parity:Char; StopBits:Byte);              external 'async12w';
Function  OpenCom(ComPort:C_ports; InBufferSize,OutBufferSize:Word) : Boolean; external 'async12w';
Procedure CloseCom(ComPort:C_ports);                                           external 'async12w';
Procedure CloseAllComs;                                                        external 'async12w';
Procedure ComSetEoln(ComPort:C_ports;EolnCh : T_eoln);                         external 'async12w';

Function ComGetBufsize(ComPort:C_ports;IO : Char) : WORD;                      external 'async12w';


End.

{ ------------------------------   TEST PROGRAM  ----------------------- }

Program Asynctst;

Uses
  Wincrt,
  Asyncwin;

{----Demo main program for Async12w}

Var
  p : Byte;
  s : string;
  i : Integer;

Begin
  Write('Enter serial port number [1..4] : '); readln(p);
  IF ComExist(p) And OpenCom(p,1024,1024)
    Then
      Begin
        ComParams(p,9600,8,'N',1);

      {----Hayes modems echo a cr,lf so lf as eoln char is easier to program.
           The cr is skipped also. Default eoln character is cr, equivalent
           to BP's readln procedure}
        ComSetEoln(p,c_lf);
        Writeln('Enter a Hayes Command, like ATX1');
        Readln(s);
        If (s<>'')
          THEN
            BEGIN
              Write('Sending...');
              ComWriteWithDelay(p,s+#13#10,500);
              Writeln(' ok, press <enter> to continue.');

              Readln;
              Repeat
                Write('[',CombufferLeft(p,'I'):3,']');
                ComReadln(p,s,255,false);
                Writeln('[',ComBufferLeft(p,'I'):3,']',s);
              Until (ComBufferLeft(p,'I')=1024);
            END;
        CloseCom(p);
      End
    Else Writeln('Error opening COM',p,' port');
END.


