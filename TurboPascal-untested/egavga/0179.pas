{
     Hi Kai.  I read your message about 360x256x256 and saw you were using
Tweak.  This is message 1/2 which includes Pascal versions of Twkuser.c
and Tweak2c.  Thought they might be helpful to you.

Maurice L. Marvin
maurice@cs.pdx.edu
}

{$I-}
UNIT TWKUSER;

{=========================================================================
  TWKUSER.PAS is a Borland Pascal 7.0 compatible unit for using Robert
  Schmidt's TWEAK generated files.

  Ported to Pascal from Robert Schmidt's original C code.

  Donated to public domain.

  Maurice L. Marvin
  maurice@cs.pdx.edu
 ==========================================================================}

INTERFACE

 CONST

    { xxxxADDR defines the base port number used to access VGA
      component xxxx, and is defined for xxxx =
           ATTRCON    -   Attribute Controller
           MISC       -   Miscellaneous Register
           VGAENABLE  -   VGA Enable Register
           SEQ        -   Sequencer
           GRACON     -   Graphics Controller
           CRTC       -   Cathode Ray Tube Controller
           STATUS     -   Status Register }

    ATTRCON_ADDR        = $3C0;
    MISC_ADDR           = $3C2;
    VGAENABLE_ADDR      = $3C3;
    SEQ_ADDR            = $3C4;
    GRACON_ADDR         = $3CE;
    CRTC_ADDR           = $3D4;
    STATUS_ADDR         = $3DA;

 TYPE

    Register = RECORD
                  port   : WORD;
                  index  : BYTE;
                  value  : BYTE;
               END;

    RegisterPtr = ^Register;

PROCEDURE ReadyVgaRegs;
PROCEDURE OutReg(r : Register);
PROCEDURE OutRegArray(r : RegisterPtr;
                      n : INTEGER);
FUNCTION  LoadRegArray(fpath        : STRING;
                       VAR RegArray : RegisterPtr) : INTEGER;


IMPLEMENTATION


{--------------------------------------------------------------------------
  ReadyVGARegs does the initialization to make the VGA ready to accept
  any combination of configuration register settings.

  This involves enabling writes to index 0 to 7 of the CRT controller
  (port $3d4), by clearing the most significant bit (bit 7) of index
  $11.
 --------------------------------------------------------------------------}

PROCEDURE ReadyVGARegs;

 VAR

    v : BYTE;

 BEGIN {*** Begin procedure ReadyVGARegs ***}
    Port[$3d4] := $11;
    v := Port[$3d5] AND $7f;
    Port[$3d4] := $11;
    Port[$3d5] := v;
 END;  {*** End procedure ReadyVGARegs ***}


{--------------------------------------------------------------------------
  OutReg sets a single register according to the contents of the passed
  Register structure.
 --------------------------------------------------------------------------}

PROCEDURE OutReg(r : Register);

 VAR

    v : BYTE;

 BEGIN {*** Begin procedure OutReg ***}
    CASE (r.port) OF
       ATTRCON_ADDR   : BEGIN
                           v := Port[STATUS_ADDR]; { Reset read/write flip flop
}                           Port[ATTRCON_ADDR] := r.index OR $20;
                           { Ensure VGA output is enabled }
                           Port[ATTRCON_ADDR] := r.value;
                        END;
       MISC_ADDR,
       VGAENABLE_ADDR : BEGIN
                           Port[r.port] := r.value; { Directly to the port }
                        END;
       ELSE { Default method }
                        BEGIN
                           Port[r.port] := r.index; { Index to port }
                           Port[r.port + 1] := r.value; { Value to port + 1}
                        END;
    END;
 END;  {*** End procedure OutReg ***}


{--------------------------------------------------------------------------
  OutRegArray sets n registers according to the array pointed to by r.
  First, indexes 0-7 of the CRT controller are enabled for writing.
 --------------------------------------------------------------------------}

PROCEDURE OutRegArray(r : RegisterPtr;
                      n : INTEGER);

 VAR

    s : WORD;

 BEGIN {*** Begin procedure OutRegArray ***}
    s := SizeOf(Register);
    ReadyVGARegs;
    WHILE (n > 0) DO
       BEGIN
          OutReg(r^);
          ASM { Increment pointer to next record }
             MOV DX,s
             ADD WORD PTR [r],DX
          END;
          DEC(n);
       END;
 END;  {*** End procedure OutRegArray ***}


{--------------------------------------------------------------------------
  LoadRegArray opens the given file, does some validity checking, then
  reads the entire file into an array of Registers, which is returned
  via the RegArray parameter.

  You will probably want to provide your own error handling code in this
  function, as it never aborts the program, rather than just printing
  an error message and returning NULL.

  The returned value is the number of registers read.  The RegArray
  parameter is set to the allocated register array.

  If you use this function, remember to dispose the returned array pointer,
  as it was allocated dynamically using GetMem (unless NULL is returned,
  which designates an error).
 --------------------------------------------------------------------------}

FUNCTION LoadRegArray(fpath        : STRING;
                      VAR RegArray : RegisterPtr) : INTEGER;

 VAR

    handle : FILE;
    fsize  : LONGINT;

 BEGIN {*** Begin function LoadRegArray ***}
    LoadRegArray := 0;
    RegArray := NIL;
    ASSIGN(handle,fpath);
    RESET(handle,1);
    IF (IOResult <> 0) THEN { error opening file ? }
       BEGIN
          { include error handling code here }
          Exit;
       END;
    fsize := FileSize(handle);
    IF (IOResult <> 0) THEN { error acquiring file size ? }
       BEGIN
          CLOSE(handle);
          Exit;
       END;
    IF (fsize MOD SizeOf(Register) <> 0) THEN { Is filesize multiple of record
? }       BEGIN
          WriteLn('Illegal TWEAK file size: ',fpath);
          CLOSE(handle);
          Exit;
       END;
    IF (MaxAvail < fsize) THEN { Is there enough memory ? }
       BEGIN
          WriteLn('Out of memory allocating buffer for ',fpath);
          CLOSE(handle);
          Exit;
       END;
    GetMem(RegArray,fsize);
    BlockRead(handle,RegArray^,fsize);
    IF (IOResult <> 0) THEN { Error reading file ? }
       BEGIN
          CLOSE(handle);
          Dispose(RegArray);
          RegArray := NIL;
          Exit;
       END;
    CLOSE(handle);
    IF (IOResult <> 0) THEN { Error closing file ? }
       BEGIN
          Dispose(RegArray);
          RegArray := NIL;
          Exit;
       END;
    LoadRegArray := fsize DIV SizeOf(Register);
 END;  {*** End function LoadRegArray ***}


END.




{$I-}
PROGRAM TWEAK2P;

USES TWKUSER;

{=========================================================================
  TWEAK2P version 1.0

  Ported to Pascal from Robert Schmidt's original C code.

  Converts a TWEAK version 1.0 file to an include-able Pascal file,
  defining the equivalent register array, which is passable
  to the OutRegArray function defined in the TWKUSER unit.

  Maurice L. Marvin
  maurice@cs.pdx.edu
 =========================================================================}

VAR

   table   : RegisterPtr;
   btable  : RegisterPtr;
   regsize : INTEGER;
   handle  : TEXT;
   b1      : BYTE;
   b2      : BYTE;
   s       : WORD;

BEGIN {*** Begin program TWEAK2P ***}
   { Check command line arguments. }
   IF (ParamCount < 3) THEN
      BEGIN
         WriteLn;
         WriteLn('TWEAK2P version 1.0');
         WriteLn('Converts a TWEAK version 1.x file to an include-able Pascal
file.');         WriteLn;
         WriteLn('SYNTAX: TWEAK2P <TWEAK-File> <Pascal File to Create> <Array
Name>');         WriteLn('All Parameters are required.');
         Halt(1);
      END;
   { Load the register file. }
   regsize := LoadRegArray(ParamStr(1),table);
   { Save a pointer to the start of the table.  The pointer 'table' will
     be corrupted due to pointer arithmetic. }
   btable := table;
   { Check if we loaded the table successfully. }
   IF (Table = NIL) THEN
      BEGIN
         WriteLn;
         WriteLn('ERROR : Unable to load register file.');
         Halt(1);
      END;
   { Open the destination file. }
   ASSIGN(handle,ParamStr(2));
   REWRITE(handle);
   IF (IOResult <> 0) THEN { Check if error creating file. }
      BEGIN
         WriteLn;
         WriteLn('ERROR : Unable to create destination file.');
         Halt(1);
      END;
   { Write data structure }
   WriteLn(handle,'{ Tweaked include file generated by TWEAK2P } ');
   WriteLn(handle,'');
   WriteLn(handle,'CONST');
   WriteLn(handle);
   Write(handle,'   ',ParamStr(3),' : ARRAY[1..',RegSize);
   WriteLn(handle,'] OF Register = (');
   Write(handle,'       ');
   s := SizeOf(Register);
   { Write register values }
   WHILE (RegSize > 0) DO
      BEGIN
         Write(handle,'(Port : ',table^.port);
         Write(handle,'; Index : ',table^.index);
         Write(handle,'; Value : ',table^.value,')');
         DEC(RegSize);
         IF (RegSize = 0) THEN
            WriteLn(handle,');')
         ELSE
            WriteLn(handle,',');
         ASM { move to next record }
            MOV DX,s
            ADD WORD PTR [table],DX
         END;
         Write(handle,'       ');
      END;
   CLOSE(handle);
   Dispose(btable);
END. {*** End program Tweak2P ***}
