(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0040.PAS
  Description: TP AND SOUND BLASTER
  Author: BRIAN GRAINGER
  Date: 05-25-94  08:22
*)

{
CL▒    Come to speak of this...  do you (or anyone) know which ports to zap the
CL▒    data to for the SB to get it to play?  Or better yet, even how to get it
CL▒    to play in DMA transfer mode?

Try this code.
}
(* A unit to provide basic control over a Sound Blaster or compatible card.*)
(* It works by reading and writing to the standard Sound Blaster ports.    *)
(* Released to the public domain by Brian Grainger, Sparwood, BC.          *)

UNIT SoundBlaster;

(*********************************)INTERFACE(********************************)

PROCEDURE sbSetAddressDelay(StereoMode : BYTE);
PROCEDURE sbSetDataDelay(StereoMode : BYTE);
PROCEDURE sbSetDataReg(RegNum, Value, StereoMode : BYTE);
FUNCTION  sbGetStatus(StereoMode : BYTE) : BYTE;
PROCEDURE sbResetTimers;
PROCEDURE sbEnableInterrupts;
PROCEDURE sbTurnOff;
FUNCTION  sbIsInstalled : BOOLEAN;

(*******************************)IMPLEMENTATION(*****************************)

CONST
  cMono  = 0;
  cLeft  = 1;
  cRight = 2;

VAR
  vStatus1 : BYTE;
  vStatus2 : BYTE;
  vDelay   : BYTE;
  vI       : BYTE;

PROCEDURE sbSetAddressDelay(StereoMode : BYTE);
  BEGIN
    FOR vI := 0 TO 5 DO
      CASE StereoMode OF
        cMono  : vDelay := Port[$388];
        cLeft  : vDelay := Port[$220];
        cRight : vDelay := Port[$222];
      END;
  END;

PROCEDURE sbSetDataDelay(StereoMode : BYTE);
  BEGIN
    FOR vI := 0 TO 34 DO
      CASE StereoMode OF
        cMono  : vDelay := Port[$388];
        cLeft  : vDelay := Port[$220];
        cRight : vDelay := Port[$222];
      END;
  END;

PROCEDURE sbSetDataReg(RegNum, Value, StereoMode : BYTE);
  BEGIN
    CASE StereoMode OF
      cMono  : Port[$388] := RegNum;
      cLeft  : Port[$220] := RegNum;
      cRight : Port[$222] := RegNum;
    END;
    sbSetAddressDelay(StereoMode);
    CASE StereoMode OF
      cMono  : Port[$389] := Value;
      cLeft  : Port[$221] := Value;
      cRight : Port[$222] := Value;
    END;
    sbSetDataDelay(StereoMode);
  END;

FUNCTION sbGetStatus(StereoMode : BYTE) : BYTE;
  BEGIN
    sbGetStatus := 0;
    CASE StereoMode OF
      cMono  : sbGetStatus := Port[$388];
      cLeft  : sbGetStatus := Port[$220];
      cRight : sbGetStatus := Port[$222];
    END;
  END;

PROCEDURE sbResetTimers;
  BEGIN
    sbSetDataReg($04, $60, cMono);
  END;

PROCEDURE sbEnableInterrupts;
  BEGIN
    sbSetDataReg($04, $80, cMono);
  END;

PROCEDURE sbTurnOff;
  BEGIN
    FOR vI := $01 TO $F5 DO
      sbSetDataReg(vI, $00, cMono);
  END;

FUNCTION sbIsInstalled : BOOLEAN;
  BEGIN
    sbIsInstalled := FALSE;
    sbResetTimers;
    sbEnableInterrupts;
    vStatus1 := sbGetStatus(cMono);
    sbSetDataReg($02, $FF, cMono);  (* Set timer 1 data register *)
    sbSetDataReg($04, $21, cMono);  (* Start timer 1             *)
    FOR vI := 1 TO 4 DO
      sbSetDataDelay(cMono);        (* Wait at least 80 uSeconds *)
    vStatus2 := sbGetStatus(cMono);
    sbResetTimers;
    sbEnableInterrupts;
    IF (((vStatus1 AND $E0) = $00) AND ((vStatus2 AND $E0) = $C0)) THEN
      sbIsInstalled := TRUE;
  END;
END.

