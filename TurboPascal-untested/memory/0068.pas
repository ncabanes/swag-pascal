{
-> I'm having a problem in a program that I'm doing. I need to make
-> overlay files and I'm tying to put them in expanded memory with the
-> instruction OvrInitEMS but after that the program leaves to DOS
-> without doing any instruction else.
-> If someone knows how to solve this problem, I would like some Help

> Which TP version and which DOS version?  I found that EMM386 from DOS
> 6.2 didn't cooperate with some of my Borland products, so I killed DOS
> 6.2.

Here's the source code of an overlay manager that I have been using for
years without any problems.  It's based on the one found in the
documentation.
}

UNIT TNDOvrIn;
{$O+}  { Enable overlaying of this unit }
{$F+}  { Turn on Far Calls }

INTERFACE

IMPLEMENTATION
USES Dos,
     Crt,
     Overlay;

CONST
  OvrMaxSize = 128416;
  {OvrMaxSize = 0;}

VAR
  OvrName        : STRING[79];
  Message        : BOOLEAN;

PROCEDURE PrintMsg(pInString : STRING);
BEGIN
  WRITELN( pInString );
END;

BEGIN
  PrintMsg( '' );
  PrintMsg( 'Please wait for TNDM to load into memory.' );
  PrintMsg( '' );

  Message := FALSE;
  OvrName := 'TNDM.OVR';

  IF LO(DosVersion) >= 3 THEN
    OvrName := ParamStr(0)
  ELSE
    BEGIN
      OvrName := FSearch('TNDM.EXE', GetEnv('PATH') );
      IF (OvrName = '') THEN
        BEGIN
        PrintMsg( 'The main program must be named "TNDM.EXE" and it must' );
        PrintMsg( 'reside in your PATH or in the current directory.' );
        END;
    END;

  {WRITELN;}
  OvrName := FExpand(OvrName);
  {WRITELN('Loading ', OvrName, '...');}
  DEC(OvrName[0], 3);
  OvrName := OvrName + 'OVR';


  REPEAT
    OvrInit(OvrName);

    IF OvrResult = ovrNotFound THEN
      BEGIN
        PrintMsg( 'Overlay file not found: ' + OvrName );
        WRITE('Enter correct overlay file name: ');
        READLN(OvrName);
      END;
  UNTIL OvrResult <> ovrNotFound;

  IF OvrResult <> OvrOk THEN
    BEGIN
    PrintMsg( 'Overlay manager error.  Unable to continue.  Error loading overlay file.' );
    Halt(1);
    END;

  {WRITELN('Overlay manager has been installed.');}
  PrintMsg( '' );

  OvrInitEMS;
  IF OvrResult <> OvrOk THEN
    BEGIN
      CASE OvrResult OF
        ovrIOError     :
          BEGIN
          PrintMsg( 'Overlay file I/O error.  Unable to continue.' );
          HALT(1);
          END;

        ovrNoEMSDriver : {WRITE('EMS driver not installed')};

        ovrNoEMSMemory : {WRITE('Not enough EMS memory')};

      END;

      {*-- Increase buffer only if no EMS --*}
      OvrSetBuf(OvrGetBuf + OvrMaxSize);
      OvrSetRetry(OvrGetBuf DIV 3);
    END
  ELSE
    BEGIN
      {*-- Some extra buffer is still needed --*}
    OvrSetBuf(OvrGetBuf + OvrMaxSize );
    OvrSetRetry(OvrGetBuf DIV 6);
    END;

END.
