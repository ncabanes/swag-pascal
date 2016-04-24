(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0054.PAS
  Description: General Midi Code
  Author: COLIN BUCKLEY
  Date: 11-26-94  04:55
*)

{
Here is the PASCAL version of a portion of the Assembler code I used in my
game to get General Midi sound.  I've compiled the program, and it works fine
on my GM device, MEGA-EM a TSR for the Gravis Ultrasound.

No checking is performed, make sure you have the correct hardware, but
it should run due to the timeout checking.

If you don't get sound, then it's probably because no instrument was
defined.  Send a program change midi sequence.

Feel free to toss this in SWAG.  Sound code is always requested,
and General Midi is so simple compared to everything else.
}
Program GMTest;

(*
Take from Colin Buckley's cheezy shareware game Tubes, written in BP.
The actual GM code is a converted assembler file, thus the obvious macro
like sequences, register passing, and semi-colon comments.  Sorry for any
typos/bugs introduced during the quick conversion.

This is completely public domain.  Which means no restrictions whatsoever.

{$DEFINE EducateTheMasses}
To the uninformed, you can not say something is public domain, then paste a
copyright on it and say it's required for you to be acknowledged or
get a post card or something.  You give up all rights when you give something
to the public domain.  What you want, is called freeware.
{$ENDIF}
*)

Const
  GMPort        = $331;
  Send          = $80;
  Receive       = $40;

{ AL:=Command; }
Procedure WriteGMCommand; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ;Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    {; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Receive                  {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    OUT   DX,AL                       {;Send Data                         }
End;

{ ; AL:=Data }
Procedure WriteGM; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ; Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    { ; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Receive                  {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    DEC   DX                          {;DX:=DataPort                     }
    OUT   DX,AL                       {;Send Data                        }
End;

{ ;Returns Data }
Function ReadGM:Byte; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ; Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    { ; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Send                     {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    DEC   DX                          {;DX:=DataPort                      }
    IN    AL,DX                       {;Receive Data                      }
End;

Procedure ResetGM; Assembler;
ASM
    { ;Reset GM }
    MOV   DX,GMPort
    MOV   AL,0FFh
    OUT   DX,AL
    {; Get ACK }
    CALL  ReadGM
    {; UART Mode }
    MOV   AL,03Fh
    CALL  WriteGMCommand
End;

Procedure SetNoteOn(Channel,Note,Volume:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,90h
    Call  WriteGM
    MOV   AL,[Note]
    CALL  WriteGM
    MOV   AL,[Volume]
    CALL  WriteGM
End;

Procedure SetNoteOff(Channel,Note,Volume:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,80h
    Call  WriteGM
    MOV   AL,[Note]
    CALL  WriteGM
    MOV   AL,[Volume]
    CALL  WriteGM
End;

Begin
  ResetGM;
  SetNoteOn(0,64,127);
  ASM
    { ;Wait for Key }
    XOR   AX,AX
    INT   16h
  End;
  SetNoteOff(0,64,127);
  ResetGM;
End.


