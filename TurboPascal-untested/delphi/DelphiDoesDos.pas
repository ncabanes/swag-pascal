(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0010.PAS
  Description: DELPHI Does DOS
  Author: ERIC NIELSEN
  Date: 11-22-95  13:26
*)


Instructions for preparing DELPHI to compile a DOS EXE with DCC.EXE

Requirements:
  1) BP7 Runtime library source
  2) Delphi VCL source
  3) TASM.EXE
  4) The new DLIB.EXE (available from CompuServe DELPHI forum)

Assumptions:
  1) BP7 RTL is in \BP\RTL
  2) Delphi VCL is in \DELPHI\SOURCE
  3) \DELPHI\BIN is in your path as well as TASM.EXE

Copy from \BP\RTL\SYS to \DELPHI\SOURCE\RTL\SYS (all are .ASM):
  MAIN, PARS, LAST, HEAP, F87H, EI87, EI86, DLIB, DAPP
  (* note ERRC that was in this list has been removed - it should
     not be copied over or exception handling will not work *)

-- DOS Real Mode ----------------------------------------------------------
  Objective: create a TURBO.TPL with units compiled under DELPHI

1) The first and main requirement is to get a SYSTEM.TPU for DOS mode.
This will take some work because Delphi VCL source does not include
MAIN.ASM which is required for compiling SYSTEM.PAS in DOS mode.  
Some things need to be removed from MAIN.ASM because they now exist 
in EXIT.ASM:
  - remove HaltTurbo, HaltError, Terminate, PrintString from the PUBLIC
    section.
  - remove the procedure code for the above procedures.  (HaltError
    starts in around line 210 or so and HaltTurbo starts around 230
    or so.  PrintString ends around 395 +/- a few.)
  - up at the top in Externals after "ASSUME  CS:CODE,DS:DATA" add 
    another "EXTRN HaltError:NEAR,HaltTurbo:NEAR"
  - down in "Int3FHandler" remove "SHORT" from "JMP SHORT HaltError"
  - after "MOV AX,200" in Int00Handler add "JMP HaltError"
  - after "MOV AX,255" in Int23Handler add "JMP HaltTurbo"

2) Create OBJ from ASM: In \DELPHI\SOURCE\RTL\SYS type 
     TASM *.ASM

3) Compile SYSTEM: In \DELPHI\SOURCE\RTL\SYS type
     DCC -cd -$d- -o\BP\RTL\LIB SYSTEM
     
4) Start your TURBO.TPL: In \DELPHI\BIN type
     DLIB TURBO.TPL +..\SOURCE\RTL\SYS\SYSTEM.TPU
    
Other files you may want to compile and include in TURBO.TPL:
  unit      source can be found
  OVERLAY   \BP\RTL\OVR
  CRT       \BP\RTL\CRT
  DOS       \BP\RTL\DOS (need to use TASM again)
  PRINTER   \BP\RTL\PRT
  STRINGS   \DELPHI\SOURCE\RTL70    (optional)
  MEMORY    \BP\RTL\TV              (optional)
  OBJECTS   \BP\RTL\COMMON          (optional)
Compile the above files in the specified directory using DCC with the
parameters -cd and -$d- to create "ver 8.0" .TPU files.  Then add the
TPU files to TURBO.TPL as shown in step 4.

Now you're all set!  Use DCC with the "undocumented" -cd switch to create
DOS EXEs with classes, exception handling, etc.


-- DOS Protected Mode -----------------------------------------------------
  Objective: create a TPP.TPL with units compiled under DELPHI

1) Make sure the .OBJ files still exist from step 2 above.

2) Create OBP from ASM: In \DELPHI\SOURCE\RTL\SYS type 
     TASM -op -d_DPMI_ *.ASM *.OBP

3) Compile SYSTEM: In \DELPHI\SOURCE\RTL\SYS type
     DCC -cp -$d- -o\BP\RTL\LIB SYSTEM
     
4) Start your TURBO.TPL: In \DELPHI\BIN type
     DLIB TPP.TPL +..\SOURCE\RTL\SYS\SYSTEM.TPP

Other files you may want to compile and include in TPP.TPL:
  unit      source can be found
  CRT       \BP\RTL\CRT
  DOS       \BP\RTL\DOS (TASM -op -d_DPMI_ *.ASM *.OBP)
  PRINTER   \BP\RTL\PRT
  STRINGS   \DELPHI\SOURCE\RTL70    
  WINDOS    \DELPHI\SOURCE\RTL70
  WINAPI    \DELPHI\SOURCE\RTL\WIN
  MEMORY    \BP\RTL\TV              (optional)
  OBJECTS   \BP\RTL\COMMON          (optional)
  SYSUTILS  \DELPHI\SOURCE\RTL\SYS  (new, see below)
Compile the above files in the specified directory using DCC with the
parameters -cp and -$d- to create "ver 8.0" .TPP files.  Then add the
TPP files to TPP.TPL as shown in step 4.


-- SysUtils for DOS Protected Mode ----------------------------------------
To get SYSUTILS to work properly in DOS PM you need to make a few minor
changes to the source file (comes with VCL Source).  First make a backup
of the SYSUTILS.PAS file and then I suggest puting "{$IFDEF WINDOWS}..." 
around all of your changes.

1) FileRead/FileWrite: RTM.EXE only supports _lread/write not _hread/write
   and SysUtils needs to be updated to reflect that.  I will use FileRead
   as the example:
   In INTERFACE
     {$IFDEF WINDOWS}
     function FileRead(Handle: Integer; var Buffer; Count: Longint): Longint;
     {$ELSE}
     function FileRead(Handle: Integer; var Buffer; Count: Word): Word;
     {$ENDIF}
   In IMPLEMENTATION
     function FileRead(Handle: Integer; var Buffer; Count: Word): Word;
       external 'KERNEL' index 82; { _lread }
   FileWrite needs the same changes and it has an external index of 86.

2) Units used in the IMPLEMENTATION section:
     {$IFDEF WINDOWS}
     uses WinTypes, WinProcs, ToolHelp;
     {$ELSE}
     uses WinAPI;
     {$ENDIF}

3) Remove some exception (hardware, etc) handling.  Unfortunately RTM
   does not support MakeProcInstance and FreeProcInstance otherwise 
   none of the following would have to be removed.
   A) in the INTERFACE section
      {$IFDEF WINDOWS}
      procedure EnableExceptionHandler(Enable: Boolean);
      {$ENDIF}
      
   B) Around the procedure "GetModNameAndLogAddr" in the IMPLEMENTATION
      section add {$IFDEF WINDOWS} and {$ENDIF}.

   C) In the procedure "ShowException":
      var
        .. existing definitions
        Buffer: array[0..255] of Char;
        {$IFDEF WINDOWS}
        GlobalEntry: TGlobalEntry;
        hMod: THandle;
        {$ENDIF}
      begin
        {$IFDEF WINDOWS}
        .. existing code
        {$ENDIF}
      end;
   D) Before the procedure "ErrorHandler":
      {$IFDEF WINDOWS}
      const
        Flags   = $10;
        .. other consts
            
        Recurse: Word = 0;
      {$ENDIF}
   E) In the procedure "ErrorHandler":
        1: E := OutOfMemory;
        {$IFDEF WINDOWS}
        2,4..10: with ExceptMap[ErrorCode] do E := EClass.CreateRes(EIdent);
        3,11..16:
        ..
        end;
        {$ELSE}
        2..16: with ExceptMap[ErrorCode] do E := EClass.CreateRes(EIdent);
        {$ENDIF}
      else
   F) Before the procedure "InterruptCallBack" add {$IFDEF WINDOWS} and
      after the end of the procedure "EnableExceptionHandler" add {$ENDIF}.
   G) In procedure "DoneExceptions" put IFDEF WINDOWS around the call to
      EnableExceptionHandler.
   H) In procedure "InitExceptions" put IFDEF WINDOWS around the assignment
      "TaskID := GetCurrentTask;" and the call to EnableExceptionHandler.
      
4) Add profile support provide in RTM.EXE.  After the comment 
   "{ Initialization file support }" add the following:
      {$IFNDEF WINDOWS}
      function GetProfileInt( appName, keyName : pchar;
        default : integer ) : word; far; external 'KERNEL' index 57;
      function GetProfileString( appName, keyName, default, returned : pchar;
        size : integer ) : integer; far; external 'KERNEL' index 58; 
      {$ENDIF}                                                       
                                                                    
Compile SYSUTILS for DOS PM from the command line:
  DCC -cp SYSUTILS
  
It is all set to add the TPP.TPL and use in your programs.  I have not 
been able to test every function that is provided.  It would be diffucult
to get SysUtils working for DOS Real Mode because of its use of resource
files, although I am sure it is possible if someone would like to give it 
a shot.  You could probably remove all the exception handling and get it
to compile with BP7.



-- Classes for DOS Protected Mode -----------------------------------------
Getting the CLASSES unit to compile for DOS PM is very simple compared to
SYSUTILS.  

In the INTERFACE section change the uses clause:
  {$IFDEF WINDOWS}
  uses SysUtils, WinTypes, WinProcs;
  {$ELSE}
  uses SysUtils, WinAPI;
  {$ENDIF}

You need to create a unit called CONSTS that has the following:
(This information was obtained via the online browser because
Borland does not proved CONSTS.PAS - don't ask me why not!?):
========================================
unit Consts;

interface

const
  SClassNotFound             = 61447;
  SDuplicateClass            = 61457;
  SRegisterError             = 61498;
  SResNotFound               = 61449;
  SLineTooLong               = 61459;
  SReadError                 = 61443;
  SWriteError                = 61444;
  SInvalidImage              = 61448;
  SFCreateError              = 61441;
  SFOpenError                = 61442;
  SMemoryStreamError         = 61445;
  SInvalidProperty           = 61538;
  SUnknownProperty           = 61462;
  SPropertyException         = 61464;
  SInvalidPropertyPath       = 61461;
  SInvalidPropertyValue      = 61460;
  SReadOnlyProperty          = 61463;
  SCharExpected              = 61534;
  SSymbolExpected            = 61535;
  SParseError                = 61530;
  SDuplicateName             = 61455;
  SInvalidName               = 61456;
  SListIndexError            = 61451;
  SDuplicateString           = 61453;
  SSortedListError           = 61452;
  SIdentifierExpected        = 61531;
  SStringExpected            = 61532;
  SNumberExpected            = 61533;
  SInvalidBinary             = 61539;
  SInvalidString             = 61537;
  SAssignError               = 61440;

implementation

end.
========================================

Now copy TYPINFO.INT to TYPINFO.PAS and copy the procedure/function 
declarations from the INTERFACE to IMPLEMENTATION.  With each procedure and
function add a "Begin End;".  Have each function return NIL, 0, etc 
depending on its type.

Compile:
  DCC -cp CLASSES

You can now use TList, TStrings, TStringList, TStream, etc in your DOS PM
programs.  Because of changes to SysUtils THandleStream.Read/Write is
limited to a buffer size of word and not longint.  You won't be able to
use TReader and TWriter unless you can get Borland to give you the source
or TPP for TYPINFO.PAS.

