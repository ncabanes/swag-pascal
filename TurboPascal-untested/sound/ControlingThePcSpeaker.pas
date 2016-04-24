(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0027.PAS
  Description: Controling the PC Speaker
  Author: SEAN PALMER
  Date: 08-27-93  21:44
*)

{
SEAN PALMER

>I have TP 6.0, and I'am looking For a way to address my PC Speaker.  I don't
>know what Port it is (like PORT[$30] or something), or how to send raw Sound
>data to it. Could someone help me?

Try this, or actually a Variation on it. Doing VOC's and WAV's on a pc
speaker is not an easy task...

What you're looking For is embedded in the 'click' Procedure below...

'click' only works While no tone is being produced. click at different
rates to get different pitches/effects.

so I guess the simple answer to your question is that it's controlled by
bit 1 (from 0 to 7) of port $61.
}

Unit uTone;
Interface

Procedure tone(freq : Word);
Procedure noTone;
Procedure click;

Implementation

Const
  sCntrl   = $61; { Sound control port }
  SoundOn  = $03; { bit mask to enable speaker }
  SoundOff = $FC; { bit mask to disable speaker }
  C8253    = $43; { port address to control 8253 }
  seTimer  = $B6; { tell 8253 to expect freq data next }
  F8253    = $42; { frequency address on 8253 }

Procedure tone(freq : Word); Assembler;
Asm
  mov al, $B6
  out $43, al  {Write timer mode register}
  mov dx, $14
  mov ax, $4F38
  div freq     {1331000/Frequency pulse}
  out $42, al
  mov al, ah
  out $42, al  {Write timer a Byte at a time}
  in  al, $61
  or  al, 3
  out $61, al  {port B-switch speaker on}
end;

Procedure noTone; Assembler;
Asm
  in  al, $61
  and al, $FC
  out $61, al
end;

Procedure click; Assembler;
Asm
  in  al, $61
  xor al, 2
  out $61, al
end;

end.

