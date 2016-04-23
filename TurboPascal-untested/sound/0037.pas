{ SBTS.PAS -- Sound Blaster Text To Speech Interface for Turbo Pascal 6.0 }

Unit SBTS;

Interface

{$IFNDEF VER60 }
   ** Needs Version 6.0 of Turbo Pascal to compile **
{$ENDIF }

{                                  SBTS.PAS

      This unit provides an interface to the SBTALKER (TM) Text-to-Speech
      driver.

      USAGE NOTES:
       1.  Make sure you have made SBTALKER resident, prior to running your
           application.  Call from the DOS command line:
              SBTALKER /DBLASTER

           SBTALKER.EXE and BLASTER.DRV are found on the diskettes that
           came with the Sound Blaster.
       2.  Due to the fact that this unit relies on the built-in assembler,
           you'll need Turbo Pascal, version 6.0 or later to recompile.
       3.  IMPORTANT:  Don't attempt to run an application within the
           Turbo Pascal Integrated Development Environment.  Do not launch
           it inside a software-debugger either!  It'll HANG your system.
           RUN it from the DOS command line.

       Written by Wilbert van Leijen, Amsterdam 1991.
       Released with source code and all to the Public Domain on an
       AS-IS basis.  The author assumes NO liability; you use this at your
       risk.

}
Type
  SpeechType   = Record                { SBTALKER configuration record }
                   talk,
                   phoneme     : String;
                   gender,
                   tone,
                   volume,
                   pitch,
                   speed       : Integer;
                 end;
Const
  TalkerReady  : Boolean = False;      { Flag indicating SBTALKER status }

Var
  TalkPtr      : Pointer;              { Pointer to the resident driver }
  SpeechRec    : ^SpeechType;          { Pointer to the configuration record }

Procedure Say(talk : String);
Procedure Settings(gender, tone, volume, pitch, speed : Integer); Function 
UnloadDriver : Boolean;

Implementation

{$R-,S- }

{ Talk to me }

Procedure Say(talk : String); Assembler;

ASM
        CMP    [TalkerReady], False
        JE     @1
        LES    DI, [SpeechRec]
        PUSH   DS
        LDS    SI, talk
        CLD
        LODSB
        STOSB
        XOR    CH, CH
        MOV    CL, AL
        REP    MOVSB
        POP    DS
        MOV    AL, 7
        CALL   [TalkPtr]
@1:
end;  { Say }


{ Alter the settings of the SBTALKER driver }

Procedure Settings(gender, tone, volume, pitch, speed : Integer); Assembler;

ASM
        CMP    [TalkerReady], False
        JE     @1
        LES    DI, [SpeechRec]
        CLD
        ADD    DI, SpeechType.gender
        MOV    AX, gender
        STOSW
        MOV    AX, tone
        STOSW
        MOV    AX, volume
        STOSW
        MOV    AX, pitch
        STOSW
        MOV    AX, speed
        STOSW
        MOV    AL, 2
        CALL   [TalkPtr]
@1:
end;  { Settings }

{ Unload the SBTALKER driver.  Returns True is successful }

Function UnloadDriver : Boolean; Assembler;

ASM
        MOV    AX, False
        CMP    [TalkerReady], False
        JE     @1
        MOV    AX, 0FBFFh
        INT    2Fh
@1:
end;  { UnloadDriver }

Begin  { SBTS }
ASM

  { Get the vector to multiplex interrupt 2Fh.  Assume it belongs to SBTALKER }

        MOV    AX, 352Fh
        INT    21h
        MOV    AX, ES
        OR     AX, AX
        JZ     @1

  { Pass the magic number to the handler }

        MOV    AX, 0FBFBh
        INT    2Fh

  { Driver responds if the return code is non zero }

        OR     AX, AX
        JNE    @1

  { Retrieve the pointers to the SBTALKER driver and its configuration record }

        MOV    AX, ES:[BX+4]
        MOV    DX, ES:[BX+6]
        MOV    Word Ptr [TalkPtr], AX
        MOV    Word Ptr [TalkPtr+2], DX
        ADD    BX, 20h
        MOV    Word Ptr [SpeechRec], BX
        MOV    Word Ptr [SpeechRec+2], DX

  { Put the default values for gender, tone etc. into this record }

        LES    DI, [SpeechRec]
        ADD    DI, SpeechType.gender
        CLD
        SUB    AX, AX
        STOSW                          { gender = male }
        STOSW                          { tone   = bass }
        MOV    AX, 5
        STOSW                          { volume = 5 }
        STOSW                          { pitch  = 5 }
        STOSW                          { speed  = 5 }
        MOV    AL, 2
        CALL   [TalkPtr]
        MOV    [TalkerReady], True
@1:
end;
end.  { SBTS }

Sample call:  Say('hello world!');

