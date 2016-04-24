(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0038.PAS
  Description: Speaker Module in ASM
  Author: RICHARD SANDS
  Date: 02-15-94  08:40
*)

UNIT Tone;  {$S-,R-,D-,L-}

    (* TONE.PAS - Sound Module for Turbo Pascal 6.0 - Turbo Vision
     * Written by Richard R. Sands
     * Compuserve ID 70274,103
     * January 1991
     *
     * NOTE: Do Not Overlay
     *)

INTERFACE

   Procedure Sound(Hz:Word);
   Procedure NoSound;
   Procedure Delay(MS : Word);

   Procedure Beep(Hz, MS:Word);
     { Same as
               Sound(Hz);
               Delay(MS);
               NoSound;       ...but with more efficient code. }

   Procedure BoundsBeep;
     { Used for signalling a boundry or invalid command }

   Procedure ErrorBeep;
     { Used for signalling an error condition }

   Procedure AttentionBeep;
     { Used for signalling the user }

IMPLEMENTATION

  VAR
    OneMS : Word;

{ ------------------------------------------------------------------------- }
Procedure Beep(Hz, MS:Word); assembler;
     { Make the Sound at Frequency Hz for MS milliseconds }
  ASM
    MOV  BX,Hz
    MOV  AX,34DDH
    MOV  DX,0012H
    CMP  DX,BX
    JNC  @Stop
    DIV  BX
    MOV  BX,AX
    IN          AL,61H
    TEST AL,3
    JNZ  @99
    OR          AL,3
    OUT  61H,AL
    MOV  AL,0B6H
    OUT  43H,AL
 @99:
    MOV  AL,BL
    OUT  42H,AL
    MOV  AL,BH
    OUT  42H,AL
 @Stop:
 {$IFOPT G+}
    PUSH MS
 {$ELSE }
    MOV  AX, MS   { push delay time }
    PUSH AX
  {$ENDIF }
    CALL Delay    { and wait... }

    IN   AL, $61  { Now turn off the speaker }
    AND  AL, $FC
    OUT  $61, AL
  end;

{ ------------------------------------------------------------------------- }
Procedure BoundsBeep; assembler;
  asm
  {$IFOPT G+ }
     PUSH 1234      { Pass the Frequency }
     PUSH 10        { Pass the delay time }
  {$ELSE}
     MOV  AX, 1234  { Pass the Frequency }
     PUSH AX
     MOV  AX, 10    { Pass the delay time }
     PUSH AX
   {$ENDIF }
     CALL Beep
  end;

{ ------------------------------------------------------------------------- }
Procedure ErrorBeep; assembler;
  asm
  {$IFOPT G+ }
     PUSH 800   { Pass the Frequency }
     PUSH 75    { Pass the delay time }
  {$ELSE}
     MOV  AX, 800  { Pass the Frequency }
     PUSH AX
     MOV  AX, 75   { Pass the delay time }
     PUSH AX
  {$ENDIF }
     CALL Beep
  end;

{ ------------------------------------------------------------------------- }
Procedure AttentionBeep; assembler;
  asm
  {$IFOPT G+ }
     PUSH 660   { Pass the Frequency }
     PUSH 50    { Pass the delay time }
  {$ELSE}
     MOV  AX, 660  { Pass the Frequency }
     PUSH AX
     MOV  AX, 50   { Pass the delay time }
     PUSH AX
  {$ENDIF }
     CALL Beep
  end;

{ ------------------------------------------------------------------------- }
Procedure Sound(Hz:Word); assembler;
   ASM
      MOV  BX,Hz
      MOV  AX,34DDH
      MOV  DX,0012H
      CMP  DX,BX
      JNC  @DONE
      DIV  BX
      MOV  BX,AX
      IN   AL,61H
      TEST AL,3
      JNZ  @99
      OR   AL,3
      OUT  61H,AL
      MOV  AL,0B6H
      OUT  43H,AL
@99:  MOV  AL,BL
      OUT  42H,AL
      MOV  AL,BH
      OUT  42H,AL
@DONE:
  end;

{ ------------------------------------------------------------------------- }
Procedure NoSound; assembler;
  asm
     IN   AL, $61
     AND  AL, $FC
     OUT  $61, AL
  end;

{ ------------------------------------------------------------------------- }
procedure DelayOneMS; assembler;
  asm
     PUSH CX         { Save CX }
     MOV  CX, OneMS  { Loop count into CX }
  @1:
     LOOP @1         { Wait one millisecond }
     POP  CX         { Restore CX }
  end;

{ ------------------------------------------------------------------------- }
Procedure Delay(ms:Word); assembler;
  asm
     MOV  CX, ms    
     JCXZ @2           
  @1:
     CALL DelayOneMS
     LOOP @1
  @2:
  end;

{ ------------------------------------------------------------------------- }
Procedure Calibrate_Delay; assembler;
  asm   
     MOV  AX,40h         
     MOV  ES,AX          
     MOV  DI,6Ch          { ES:DI is the low word of BIOS timer count }
     MOV  OneMS,55        { Initial value for One MS's time }
     XOR  DX,DX           { DX = 0 }
     MOV  AX,ES:[DI]      { AX = low word of timer }
  @1:
     CMP  AX,ES:[DI]      { Keep looking at low word of timer }
     JE   @1              { until its value changes... }
     MOV  AX,ES:[DI]      { ...then save it }
  @2:
     CAll DelayOneMs      { Delay for a count of OneMS (55) }
     INC  DX              { Increment loop counter }
     CMP  AX,ES:[DI]      { Keep looping until the low word }
     JE   @2              { of the timer count changes again }
     MOV  OneMS, DX       { DX has new OneMS }
  end;

BEGIN
  Calibrate_Delay
END.

{ ==============================  DEMO ==================================}

Program ToneTest;

USES Tone;

begin
   ErrorBeep;
   Delay(500);
   AttentionBeep;
   Delay(500);
   BoundsBeep;
   Delay(500);
   Beep(440, 250);
end.

