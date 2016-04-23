{
GV>If it's high you may not be able to rely upon TP's Read/Write
  >procedures.  If it's really high you may need to let an ISR do
  >the job of i/o buffering.
JS> Oh! God. I hope not. I'm not ready for TSRs. Oops, you didn't
  > say TSR, you said ISR.

 Have no fear... I wouldn't lead you into waters that you couldn't
 navigate through on your own!  But, how about getting familiar
 with using the CPU Registers, and the BIOS, via TP?  [FYI: ISRs
 (interrupt service routines) can be run attached to the DOS, in
 the form of TSRs or device drivers, or temporarily as part of an
 application.]

 9600 bits-per-second (bps) is about as fast as vanilla DOS can
 go with the serial ports. To be safe from loosing data, your
 i/o should be buffered by a hardware-driven ISR. But, as you say,
 writing & interfacing to a TSR/ISR can be a bit heady, especially
 when all you need is the odd text string.

 I'd recommend that you use a "FOSSIL driver," such as X00.  It
 gets loaded as a TSR in your AUTOEXEC.BAT file, or as a device
 driver in CONFIG.SYS, and intercepts the BIOS serial interrupt
 to provide data capture & buffering. X00 is solid, and is used by
 many BBS SysOps. It's available for download at most local BBSs.
 It can be run under DOS, Windows, or DESQview.

 You can use TP's INTR() function to talk with the serial port, or
 use one of the existing TP source code libraries that can also be
 found on BBSs. The X00 archive comes with an example of using X00
 with TP, and even has a ready-to-link TPX00.OBJ file.

 The X00 commands are a superset of BIOS interrupt 14H commands, so
 you may already have a book which documents how to use it -- though
 you'll probably want to know how to set the buffer size, etc.  X00
 comes with thorough documentation.

JS> Although it is 9600 baud, a data string is sent only every second
  > or longer. One data string BTW consists of a concentration and a
  > date/time in a format something like this:
  >        350.0ppm 12:42:37 Jun 13'94
  > so you can see that the port is idle most of the time. I know
  > that might not matter.

 This should be easy enough to handle.  Here's an example snippet of
 using X00 with TP (from the X00 archive file) ...
}

  CONST   Buffer_Size = 1024;

  VAR     Regs : REGISTERS;
          Input_Buffer : ARRAY [1..Buffer_Size] OF BYTE;

  PROCEDURE Bypass; EXTERNAL;
  PROCEDURE TPX00( VAR Regs : REGISTERS ); EXTERNAL; {$L TPX00}

  BEGIN
  { Check for active FOSSIL }
  Regs.AH := $04;  Regs.BX := 0;  Regs.DX := $00FF;
  { INTR( $14, Regs ); is replaced with }
  TPX00( Regs );
  FOSSIL_Active := Regs.AX = $1954;

  IF FOSSIL_Active THEN BEGIN
    { Open FOSSIL port 0, COM1 }
    Regs.AH := $04;  Regs.BX := 0;  Regs.DX := $0000;
    { INTR( $14, Regs ); is replaced with }
    TPX00( Regs );
    { Do a block read from the FOSSIL input buffer for COM1 }
    Regs.AH := $18;                  { Block read func code }
    Regs.DI := OFS( Input_Buffer );  { Input buffer offset  to DI }
    Regs.ES := SEG( Input_Buffer );  { Input buffer segment to ES }
    Regs.CX := Buffer_Size;          { Max bytes to read to CX }
    Regs.DX := 0;                    { Data from COM1 }
    { INTR( $14, Regs ); is replaced with }
    TPX00( Regs );
    { Upon return, Regs.AX will contain the number of bytes that X00 }
    { placed into Input_Buffer. }
  END;
{
 If this looks too "scary," you could try one of the existing TP
 FOSSIL interface libraries, which would provide a higher-level of
 functions (eg. GetComChar, etc).
}
