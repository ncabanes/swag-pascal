(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0022.PAS
  Description: A Working TSR
  Author: MIKE CHAMBERS
  Date: 02-03-94  07:07
*)

{
---------------------------------------------------------------------------
 MD> How do you write something so it is interup driven?

 MD> Can anyone post some simple code to perhaps count a number
 MD> up by one and display it to the screen while at the same
 MD> time allowing another part of the program do what ever it's
 MD> suppose to.?

Marek:

The features to which you refer constitute writing a TSR program.
These programs are executed and terminate, but stay resident in
system memory.  Prior to termination they insert themselves into
the Interrupt Service Routine chain of a known interrupt vector.

This programming was simplified somewhat in turbo Pascal Release
4 or 5 with the addition of the Keep, GetIntVec and SetIntVec
procedures of the DOS unit.  However, these procedures are only
a small fraction of the coding needed to write reliable TSR's.
This fact explains the lack of simple code examples.

To write good TSR's you need to read about them and play with
someone else's code for a while. (I've coded pascal for 17 years,
but my first TSR took about 3 days to debug).  For a solid
Pascal reference, try Tom Swan's 'Mastering Turbo Pascal'.
To figure out what the interrupt functions are doing, I recommend
Ralf Brown's & Jim Kyle's 'PC Interrupts'.  The book is derived
from their well-known interrupt list (INTERnn.ZIP) available
on many programming oriented BBS systems.  The index of the book
is well worth the money.  Finally, I recommend Ed Mitchell's
"Borland Pascal Developer's Guide". Ed's TSR code is thorough
and documented with education in mind.  Since I'm quoting
ED's book here, please buy a copy if you find the code useful.

Good luck

-------------------------------------------------------------------------
                             TSR Code Example
-------------------------------------------------------------------------
}

{ TSR.PAS
  Sample TSR application written in Turbo Pascal.
  IMPORTANT!
  This TSR operates only in TEXT mode, and, as
  written, supports only 80 x 25 sized screens
  (not 43- or 50- line display modes).

  This TSR will only operate on DOS 3.x or newer
  versions of DOS.

  Use this code as an example to write your own TSR code.
  Modify the $M compiler directive, below, to specify
  the maximum stack size, minimum heap and maximum heap
  required for your TSR application.

  Please see the text and other source comments
  for important restrictions.

  TSRs can be DANGEROUS, so be careful.
}

{$S-}
{$M 3072, 0, 512}
uses
  Crt, Dos;

type
  { Defines an array to store the screen image.
  For greater efficiency, your code may want to save only
  the portion of the screen that is changed by your TSR
  code. This implementation saves the entire screen image,
  at popup time, for the greatest flexibility. }
  TSavedVideo=Array[0..24, 0..79] of Word;
  PSavedVideo=^TSavedVideo;


{ The following items define the TSR's identification
string. }
type
  String8=String[8];
const
  IdStr1:String8='TP7RTSR';
  IdStr2:String8='TSRInUse';

var
  CPURegisters: Registers;
    { General register structure for Intr calls. }
  CursorStartLine: Byte;
    { Stores cursor shape information. }
  CursorEndLine: Byte;
    { Stores cursor shape information. }
  DiskInUse: Word;
    { Tracks INT 13 calls in progress. }
  MadeActive: Boolean;
    { TRUE if this TSR has been asked to pop up. }
  OurSP: Word;
  OurSS: Word;
    { Saved copies of our SS and SP registers. }
  PInt09: Pointer;
    { Saved address of keyboard handler. }
  PInt12: Pointer;
    { Saved address of GetMemorySize interrupt. }
  PInt1B: Pointer;
    { Ctrl-Break interrupt address. }
  PInt24: Pointer;
    { DOS Critical error handler. }
  PInt28: Pointer;
    { Saved address of background task scheduler. }
  PInt1C: Pointer;
    { Saved address of timer handler. }
  PInDosFlag: ^Word;
    { Points to DOS's InDos flag. }
  VideoMem: PSavedVideo;
    { Points to actual video memory area. }
  SavedVideo:TSavedVideo;
    { Stores the video memory when TSR is popped up. }
  SavedWindMin: Word;
   { Holds saved copy of WindMin for restoring window. }
  SavedWindMax: Word;
   { Holds saved copy of WindMax for restoring window. }
  SavedSS,
  SavedSP: Word;
   { Saves caller stack registers; must be global
   to store in fixed memory location, not on local
   stack of interrupted process. }
  SavedX,
  SavedY: Word;
    { Stores X, Y cursor prior to TSR popup }
    { for restoration when TSR goes away. }
  TempPtr: Pointer;
    { Used internally to DoUnInstall. }
  TSRInUse: Boolean;
    { Set TRUE during processing to avoid double
    activation. }



procedure SaveDisplay;
{ Copies the content of video memory to an internal
  array structure. Saves the cursor location and cursor
  shape definitions. }
var
  CursorLines: Byte;
begin
  { Save cursor location. }
  SavedX := WhereX;
  SavedY := WhereY;
  { Saved existing window values. }
  SavedWindMin := WindMin;
  SavedWindMax := WindMax;

  { Get and save current cursor shape. }
  with CPURegisters do
  begin
    AH := $03;
    BH := 0;
    Intr($10, CPURegisters);
    CursorStartLine := CH;
    CursorEndLine:= CL;
  end;

  { Get equipment-type information. If Monochrome
    adapter in use, then point to $B000; otherwise use the
    color memory area. }
  Intr( $11, CPURegisters );
  if  ((CPURegisters.AX shr 4) and 7) = 3 then
  begin
    VideoMem := Ptr( $B000, 0 );
    CursorLines := 15;
  end
  else
  begin
    VideoMem := Ptr( $B800, 0 );
    CursorLines := 7;
  end;
  SavedVideo := VideoMem^;

  { Change cursor shape to block cursor. }
  with CPURegisters do
  begin
    AH := $01;
    CH := 0;
    CL := CursorLines;
    Intr($10, CPURegisters);
  end;

end; { SaveDisplay }


procedure RestoreDisplay;
{ Always called sometime after calling SaveDisplay.
  Restores the video display to its state prior to the
  TSR popping up. }
begin
  { Restore screen content. }
  VideoMem^ := SavedVideo;

  { Restore cursor shape. }
  with CPURegisters do
  begin
    AH := $01;
    CH := CursorStartLine;
    CL := CursorEndLine;
    Intr($10, CPURegisters);
  end;

  { Resize window so the GotoXY (below) will work. }
  Window (Lo(SavedWindMin)+1, Hi(SavedWindMin)+1,
          Lo(SavedWindMax)+1, Hi(SavedWindMax)+1);
  Gotoxy ( SavedX, SavedY );

end; { Restore Display }


procedure TrapCriticalErrors;
assembler;
{ INT 24H }
{
This handler is enabled only while the TSR is popped
up on-screen.

This handler exists solely to catch any DOS
critical errors and is a crude method of doing so. Since
this routine does nothing, any critical errors that
occur while the TSR is popped up are ignored--which
could be very dangerous. Also, if another TSR or ISR
pops up after this one, it may get the critical
error that was intended for this TSR.
NOTE: Normally, this could be an "interrupt" type
procedure. However, Turbo Pascal pushes and then pops
all registers prior to the IRET instruction. By writing
this as an assembler routine, this generates the IRET
directly, followed by one superfluous RET instruction
generated by the assembler, resulting in substantial
code savings.
}
asm
  IRET
end; { TrapCriticalErrors }




procedure CBreakCheck;
assembler;
{ INT 1BH }

{ This routine results in a no operation; when hooked to
the INT 1B Ctrl-Break interrupt handler, it causes
nothing to happen when Ctrl-Break or Ctrl-C are pressed.
This routine is hooked only when the TSR is popped up. }
asm
        IRET
end; { CBreakCheck }




function GetKey : Integer;
{ Pauses for input of a
single keystroke from the keyboard and returns the ASCII
value. In the case where an Extended keyboard key is
pressed, GetKey returns the ScanCode + 256. The Turbo
Pascal ReadKey function is called to perform the
keystroke input. This routine returns a 0 when an Extended
key has been typed (for example, left or right arrow)
and we must read the next byte to determine the Scan
code.
}
var
  Ch : Char;
begin
  { While waiting for a key to be pressed, call
  the INT $28 DOS Idle interrupt to allow background
  tasks a chance to run. }
  repeat
    asm
      int $28
    end;
  until KeyPressed;
  Ch := ReadKey;
  If Ord(Ch) <> 0 then
    GetKey := Ord(Ch)   { Return normal ASCII value. }
  else
    { Read the DOS Extended SCAN code that follows. }
    GetKey := Ord(ReadKey) + 256;
end;{GetKey}




procedure  DoPopUpFunction;
{ This procedure is the "guts" of the popup
  application. You can code your own application here, if
  you want. Be sure to read the text for important
  restrictions on what can be written in a TSR.

  As implemented here, this popup displays a table
  of ASCII values.
}

const
  UpperLeftX=10;
  UpperLeftY=5;
    { Define upper-left corner of TSR's popup window. }

  LowerLeftX=70;
  LowerRightY=20;
    { Define lower-right corner of TSR's popup window. }

  Width=LowerLeftX - UpperLeftX + 1;
  Height=LowerRightY - UpperLeftY + 1;
    { Calculated width and height of popup window. }
  MinX=6;
    { Distance from left edge to display ASCII table. }
  RightEdge=8;
    { Marks the right edge (Width-RightEdge) of table. }
  MinY=4;
    { Distance from top of window to start ASCII Table. }
  ValuesPerLine=Width-8 - MinX;
    { Computed number of ASCII values in each line. }
  NumLines=255 div ValuesPerLine;
    { Computed number of lines in the ASCII table. }
  KEY_LEFTARROW = 331;
    { Keystroke values for extended keyboard codes. }
  KEY_RIGHTARROW = 333;
  KEY_DOWNARROW = 336;
  KEY_UPARROW = 328;
  KEY_ESCAPE = 27;
  KEY_ENTER = 13;


procedure PutChar( X, Y: Integer; ChCode: Char );
{ Writes the single character ChCode to the screen
at (X, Y), where (X, Y) is relative to the TSR popup
window. This routine is used for displaying the ASCII
table because the usual Pascal Write() translates ASCII
7 to a bell ring, and ASCII 13 and 10 to carriage return
and line feed. By using the PC BIOS routine directly, we
bypass Pascal's translation of these characters. }
begin
  with  CPURegisters  do
  begin
    { Move the cursor to adjusted (X, Y). }
    AH := $02;
    BH := 0;
    DH := UpperLeftY + Y - 2;
    DL := UpperLeftX + X - 2;
    Intr($10, CPURegisters);

    { Output the character to the current cursor location. }
    AH := $09;
    AL := byte(ChCode);
    BH := 0;
    BL := 3 shl 4 + 14;
      { Background=color 3; Foreground=color 14 }
    CX := 1;
    Intr($10, CPURegisters);
  end;
end; {PutChar}


var
  ASCIICode: Integer;
    { Computed from X, Y location in table. }
  I: Integer;
    { For loop index variable. }
  TextLine: String[Width];
    { Buffer to hold width of window's text. }
  X, Y: Integer;
    { Tracks cursor location in ASCII table. }
  Ch : Integer;
    { Holds the keystroke typed. }

begin {DoPopUpFunction}
  { Select White text on Cyan background for
  { Set up a viewing window; makes calculation
  of X, Y easier. }
  Window(UpperLeftX, UpperLeftY, LowerLeftX, LowerRightY);

  { Enclose the window by drawing a border around
  it and filling the interior with blanks. }
  FillChar( TextLine[1], Width, ' ');
  TextLine[0] := Chr( Width );
  TextLine[1] := chr( 179 );
  TextLine[Width] := chr( 179 );

  for I := 2 to Height - 2 do
  begin
    Gotoxy(1, I);
    Write( TextLine );
  end;

  FillChar( TextLine[1], Width, Chr(196));
  TextLine[1] := Chr( 218 );
  TextLine[Width] := Chr( 191 );
  Gotoxy( 1 , 1 );
  Write( TextLine );

  TextLine[1] := Chr( 192 );
  TextLine[Width] := Chr( 217 );
  Gotoxy ( 1, Height - 1 );
  Write( TextLine );

  { Display window title }
  Gotoxy ( Width div 2 -10, 2 );
  Write( 'Table of ASCII Values' );

  { Draw the ASCII table on the display }
  X := MinX;
  Y := MinY;
  for I := 0 to 255 do
  begin
    PutChar( X, Y, Chr(I) );
    Inc(X);
    If  X = (Width-RightEdge)  then
    begin
      Inc( Y );
      X := MinX;
    end;
  end;

  Gotoxy ( Width div 2 - 20 , 11 );
  Write('Use arrow keys to navigate; Esc when done');
  X := MinX; Y := MinY;
  repeat
    { Compute ASCII code and value at X, Y }
    ASCIICode := (X-MinX + (Y-MinY)*ValuesPerLine);
    Gotoxy (Width div 2 - 11 , 13);
    { NOTE: This allows display of
    "ASCII codes" greater than 256 if cursor
    moves into blank area in table. }
    Write('Character= ', '  ASCII=',ASCIICode:3);
    PutChar(Width div 2, 13, Chr(ASCIICode));
    { Display that value, below }
    Gotoxy ( X, Y );
    Ch := GetKey;
    Case  Ch  Of
      KEY_LEFTARROW:  if  X > MinX  then  Dec(X);
      KEY_RIGHTARROW:
        if  X < (Width - RightEdge - 1)  then  Inc(X);
      KEY_DOWNARROW: if  Y < (MinY+NumLines)  then Inc(Y);
      KEY_UPARROW:  if    Y > MinY  then    Dec(Y);
    end;
  until  Ch = 27;

  { End of TSR popup code. }
end; {DoPopUpFunction}



procedure RunPopUp;
{ Switches from system stack to TSR's stack. Calls
DoPopUpFunction to run the actual TSR application. This
keeps all the ugly details separate from the
application. Note that while the TSR is up on the
screen, and only while the TSR is up, we trap the
Ctrl-Break and DOS critical errors interrupt. We do
nothing when we see them except return, thereby ignoring
the interrupts. }
begin
 { Switch stacks. }
   asm
     CLI
   end;
   SavedSS := SSeg;
   SavedSP := SPtr;
   asm
     MOV   SS, OurSS
     MOV   SP, OurSP
     STI
   end;
   GetIntVec( $1B, PInt1B );
     { Disable Ctrl-Break checking. }
   SetIntVec( $1B, @CBreakCheck );
   GetIntVec( $24, PInt24 );
     { Trap DOS critical errors. }
   SetIntVec( $24, @TrapCriticalErrors );
   SaveDisplay;

   DoPopUpFunction;

   RestoreDisplay;
   SetIntVec( $24, PInt24 );
     { Reenable DOS critical error trapping. }
   SetIntVec( $1B, PInt1B );
     { Reenable Ctrl-C trapping. }
   { Restore stacks. }
   asm
     CLI
     MOV   SS, SavedSS
     MOV   SP, SavedSP
     STI
   end;
end; {RunPopUp}


procedure BackgroundInt;
interrupt;
{ INT 28H }
{ This routine is hooked in the DOS INT 28H chain,
known variously as the DOSOK or DOSIdle interrupt. The
idea is that when applications are doing nothing except
waiting for a keystroke, they can call INT 28
repeatedly. INT 28 runs through a chain of applications
that each get a crack at running.

The keyboard interrupt handler watches for the
magic TSR popup key. Some of the time it runs the TSR
popup directly; when DOS is doing something, however, it
can't run the TSR. So, it sets a flag saying "Hey, INT
28, if you see this flag set, then do the TSR." So the
INT 28 code, here, examines the flag. If the flag is set, INT 28
knows that the TSR was activated, so it calls it now.
We can do this because DOS calls INT 28 only if it's safe
for something else to run.
}
begin
  { Call saved INT 28H handler. }
  asm
    PUSHF
    CALL PInt28
  end;
  if  MadeActive  then
  begin
    TSRInUse := True;
    MadeActive := False;
    RunPopUp;
    TSRInUse := False;
  end;
end; {BackgroundInt}



procedure KeyboardInt;
interrupt;
{ INT 09H }
{ Examines all keyboard interrupts. First calls the
existing interrupt handler. If our TSR is NOT currently
running, then it checks for the magic pop keystrokes. If
the TSR is already running, then we do not want to
activate it again, so we ignore keystroke checking when
the TSR is already alive and on-screen.

Several bytes in low memory contain keyboard status
information. By checking the values in these bytes,
various "not normal" key combinations can be detected.
As implemented here, the TSR is made active by pressing
the left Alt key, plus the SysRq key (Print Screen on my
PC). You can change these keystrokes to something else.
}
const
  CallTSRMask = 6;
  { ACTIVATE TSR = left Alt key + SysRq key }
var
  ScanCode: byte absolute $40:$18;
    { One of the keyboard status bytes. }
begin
  { Call existing keyboard interrupt handler. }
  asm
    PUSHF
    CALL PINT09
  end;

  if  not TSRInUse  then
    if  (ScanCode and CallTSRMask) = CallTSRMask  then
    begin
      { The TSR has been activated. }
      TSRInUse := True;
        { Set to TRUE to prevent reactivation of this TSR. }
      if  (PInDosFlag^ = 0)  then
      begin
        { If in "Safe" DOS area, then pop up now. }
        MadeActive := False; { So INT $28 won't call us. }
        RunPopUp;
        TSRInUse := False;
      end
      else
        MadeActive := True;
          { o/w, set flag let INT 28 call us when ok. }
    end;
end; {KeyboardInt}




procedure DoUnInstall ( var Removed: Boolean ); forward;


{ These are "local" to OurInt12; it is safer to store them in the
TSR's global data area than to place them on the stack as
local variables. }
var
  IdStr : ^String8;
  MessageNum : Integer;

procedure OurInt12
  (_AX, BX, CX, DX, SI, DI, DS, ES, BP:Word);
interrupt;
{ INT 12H }
{ Intercepts INT 12H calls. If the ES:BX register
just happens to point to IdStr1, then the command-line
TSR program just called in. If this is the case, the
other registers could be used to pass a message to the
running TSR. Here, it's used by the running TSR to return
a pointer to another string, confirming that the TSR is
indeed running.
}

var
  DeInstallOk: Boolean;
begin
  IdStr := Ptr( ES, BX );
    { Check to see if ES:BX points to the }
    { magic ID string }
  If  IdStr^ = IdStr1  then
    MessageNum := CX
  else
  begin
    MessageNum := 0;
      { No message rcvd; this is normal DOS call. }
    asm
       pushf
       call    PInt12
       mov     _AX, ax
         { AX returns the memory size value. }
    end;
  end;
  if  MessageNum > 0   then
  { Process a message directed to this TSR. }
  begin
    case  MessageNum  of
      1:  begin
          { Returns pointer to IdStr2 indicating this
          TSR is here. }
            ES := Seg(IdStr2);
            BX := Ofs(IdStr2);
          end;
      2:  begin { Performs request to uninstall the TSR. }
            DoUnInstall (DeInstallOk);
            if   DeInstallOk  then
              CX := 0 { Report success. }
            else
              CX := 1; { Report failure. }
          end;
    end;
  end;
end; {OurInt12}



procedure DoUnInstall ( var Removed: Boolean );
begin
  { See if any TSRs have loaded in memory after us.
  If another TSR has loaded after us, then we really
  cannot safely terminate this TSR. Why? Because when they
  terminate, they may reset their interrupts to point back
  to this TSR. And if this TSR is no longer in memory,
  uh-oh... }

  Removed := True;
  GetIntVec( $28, TempPtr );
  if  TempPtr <> @BackgroundInt  then
    Removed := False;
  GetIntVec( $12, TempPtr );
  If  TempPtr <> @OurInt12  then
    Removed := False;

  GetIntVec( $09, TempPtr );
  if  TempPtr <> @KeyBoardInt  then
    Removed := False;

  if  Removed  then
  begin
    { Restore interrupts }
    SetIntVec( $28, PInt28 );
    SetIntVec( $12, PInt12 );
    SetIntVec( $09, PInt09 );

    { Free up memory allocated to this program using
    INT 21 Func=49H "Release memory". }
    CPURegisters.AH := $49;
    CPURegisters.ES := PrefixSeg;{ Current program's PSP }
    Intr( $21, CPURegisters );
  end;
end; {DoUnInstall}





procedure InstallTSR (var AlreadyInstalled: Boolean );
{ Installs all interrupt handlers for this TSR. }

var
  PSPPtr : ^Word;
  IdStr : ^String8;
begin

  { Check to see if the TSR is already running by
  executing INT 12 with ES:BX pointing to IdStr1. If,
  after calling INT 12, ES:BX points to IdStr2, then the
  TSR is running since it must have intercepted INT 12 and
  set ES:BX to those return values. }

  with  CPURegisters  do
  begin
    ES := Seg(IdStr1);
    BX := Ofs(IdStr1);
    CX := 1;
    Intr( $12, CPURegisters );
    IdStr := Ptr( ES, BX );
    if  IdStr^ = IdStr2  then
    begin
       AlreadyInstalled := True;
       Exit;
    end;
    { TSR hasn't been installed, so install our
    INT 12 driver. }
    asm
      cli
    end;
    GetIntVec( $12, PInt12 );
    SetIntVec( $12, @OurInt12 );
    asm
      sti
    end;
  end;
  AlreadyInstalled := False;
  MadeActive := False;
  DiskInUse := 0;

  { Check to see if TSR is already installed. }
  TSRInUse := False;

  { Deallocate DOS Environment block if not needed. }
  { Comment out this code if you need to access
    environment strings. }
  PSPPtr := Ptr( PrefixSeg, $2C );
  CPURegisters.AX := $4900;
  CPURegisters.ES := PSPPtr^;
  Intr( $21, CPURegisters);

  asm
    cli
  end;

  { Save and set INT 28H, background process interrupt. }
  GetIntVec( $28, PInt28 );
  SetIntVec( $28, @BackgroundInt );

  { Save and set INT 09H, the keyboard interrupt handler. }
  GetIntVec( $09, PInt09 );
  SetIntVec( $09, @KeyboardInt );
  asm
    sti
  end;

  { Initialize pointer to DOS's InDos flag. }
  { Uses INT 21H Function 34H to retrieve a pointer to the
  InDos flag. The result is returned in the ES:BX
  registers. }
  CPURegisters.AH := $34;
  Intr( $21, CPURegisters );
  PInDosFlag := Ptr( CPURegisters.ES, CPURegisters.BX );

  asm
    CLI
  end;
  { Save our SS:SP for later use. }
  OurSS := SSeg;
  OurSP := SPtr;
  asm
    STI
  end;
end; {InstallTSR}

var
  InstallError: Boolean;

begin {program}
  InstallTSR( InstallError );
  if  InstallError  then
  begin
    { This means that the TSR is already running.
      In that case, see if the command line requests
      an uninstall. }
    if  (ParamStr(1) = '/u') or (ParamStr(1) = '/U')  then
      { Send an Uninstall message to the TSR }
      with  CPURegisters  do
      begin
        ES := Seg(IdStr1);
        BX := Ofs(IdStr1);
        CX := 2;
        Intr( $12, CPURegisters );
        if  CX = 0  then
          Writeln('TSR is now uninstalled.')
        else
          Writeln('Unable to uninstall.');
        Exit;
      end
    else
      Writeln('!!!TSR is already installed!!!');
  end
  else
  begin
    Writeln('TSR is now resident.');
    Keep( 0 );
     { Exit to DOS, leaving program memory-resident. }
  end;
end. {program}

