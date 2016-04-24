(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0042.PAS
  Description: SBTALKER
  Author: WILBERT VAN LEIJEN
  Date: 05-25-94  08:22
*)

{
Sasha Case,

12-Apr-94 20:07, Sasha Case wrote to All
               Subject: SBTALKER
              Terminate 1.40 REGISTERED


 SC> @MSGID: 3:711/929@fidonet 72328398
 SC> @REGEED: 1.02u2 00910093
 SC> Hi Everyone,
 SC> 
 SC> I've tried once, a coupla months ago, but I'll try again:
 SC> 
 SC> I'm look for anyone with a Sound Blaster SDK or anyone who knows/has 
 SC> source for 
 SC> how to access SBTALKER that comes with soundblaster.  Programs like 
 SC> SBTALKER 
 SC> and READ do it, and I have seen source for something that did what I
 SC> needed,
 SC> except it used a library I haven't got.  Any help on Units that do this
 SC> or

Here you go!
}

Unit SBTS;

Interface

{     This unit provides an interface to the SBTALKER (TM) Text-to-Speech
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

       SBTALKER is a registred trade mark of First Byte, Inc. }

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
Procedure Settings(gender, tone, volume, pitch, speed : Integer);
Function UnloadDriver : Boolean;

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

{ Alter the settings of the SBTALKER driver.
  Gender: 0 is male, 1 is female;
  Tone:   0 is bass, 1 is treble;
  Volume, pitch and speed must be within the range 0..9.   }

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


