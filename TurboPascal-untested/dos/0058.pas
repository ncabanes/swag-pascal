{
  Coded By Frank Diacheysn Of Gemini Software

  FUNCTION DOSFLUSH

  Input......: F = Variable File (Text Or File) To "Flush"
             :
             :
             :
             :

  Output.....: Logical
             :        TRUE  = Successfully Flushed Buffers
             :        FALSE = Flush Failed
             :
             :

  Example....: IF DOSFLUSH( TextFile ) THEN
             :   WriteLn('DOS Buffers For TEMP.TXT Flushed To Disk.')
             : ELSE
             :   WriteLn('DOS Error While Trying To Flush Buffers For TEMP.TXT');
             :

  Description: Flushes DOS Buffers For A File
             :
             :
             :
             :

}
FUNCTION DOSFLUSH( VAR F ):BOOLEAN; ASSEMBLER;
ASM
  MOV AX, 3000H
  INT 21H
  CMP AL, 3
  JL @Old
  CMP AH, 1EH
  LES DI, F
  MOV BX, ES:[DI]
  MOV AH, 68H
  INT 21H
  JC @BadEnd
  JMP @GoodEnd

  @Old:
  LES DI, F
  MOV BX, ES:[DI]
  MOV AH, 45H
  INT 21H
  JC @BadEnd
  @Ok:
  MOV BX, AX
  MOV AH, 3EH
  INT 21H
  JC @BadEnd
  @GoodEnd:
  MOV AX, 0
  @BadEnd:
END;
