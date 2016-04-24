(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0072.PAS
  Description: SBI (Sound Blaster Instrument) Files
  Author: YAGER HUANG
  Date: 05-26-95  23:27
*)

{
> (3) How can I do *ANYTHING* with an .SBI file?

 .SBI (Sound Blaster Instrument) Format (52 Bytes):
 Offset (Length)   Value        Remark
     00 (1)        = 53           ;'S'
     01 (1)        = 42           ;'B'
     02 (1)        = 49           ;'I'
     03 (1)        = 1A
 04..23 (32)       = xx           ;The Name of Instrument
 24..33 (16)       = xx           ;The Parameter of Instrument for (OPL2/OPL3)
        ┌─┬─┬─┬─┬─┬─┬─┬─┐
     24 │b│b│b│b│b│b│b│b│       ;Modulator
     25 │7│6│5│4│3│2│1│0│       ;Carrier
        └─┴─┴─┴─┴─┴─┴─┴─┘
            b7[1] : (AM) Amplitude Modulation
            b6[1] : (VIB) VIBrato
            b5[1] : (EG-TYP) Envelope Generator TYPe
            b4[1] : (KSR) Key Scale Rate
        b3..b0[4] : (MULTIPLE) Frequency Multiplier
        ┌─┬─┬─┬─┬─┬─┬─┬─┐
     26 │b│b│b│b│b│b│b│b│       ;Modulator
     27 │7│6│5│4│3│2│1│0│       ;Carrier
        └─┴─┴─┴─┴─┴─┴─┴─┘
        b7..b6[2] : (KSL) Key Scale Level
        b5..b0[6] : (TL) Total Level
        ┌─┬─┬─┬─┬─┬─┬─┬─┐
     28 │b│b│b│b│b│b│b│b│       ;Modulator
     29 │7│6│5│4│3│2│1│0│       ;Carrier
        └─┴─┴─┴─┴─┴─┴─┴─┘
        b7..b4[4] : (AR) Attack Rate
        b3..b0[4] : (DR) Decay Rate
        ┌─┬─┬─┬─┬─┬─┬─┬─┐
     2A │b│b│b│b│b│b│b│b│       ;Modulator
     2B │7│6│5│4│3│2│1│0│       ;Carrier
        └─┴─┴─┴─┴─┴─┴─┴─┘
        b7..b4[4] : (SL) Sustain Level
        b3..b0[4] : (RR) Release Rate
        ┌─┬─┬─┬─┬─┬─┬─┬─┐
     2C │b│b│b│b│b│b│b│b│       ;Modulator
     2D │7│6│5│4│3│2│1│0│       ;Carrier
        └─┴─┴─┴─┴─┴─┴─┴─┘
        b7..b2[6] : 0
        b1..b0[2] : (WS) Wave Select *[ Note: OPL3 using 3 bits ]*
        ┌─┬─┬─┬─┬─┬─┬─┬─┐
     2E │b│b│b│b│b│b│b│b│       ;Modulator
        │7│6│5│4│3│2│1│0│
        └─┴─┴─┴─┴─┴─┴─┴─┘
        b7..b4[4] : 0
        b3..b1[3] : (FB) FeedBack
            b0[1] : (C) Connection

 2F..33 (5) Reserved

            Note: Offset is HEX, (Length) is DEC.

 .IBK (Instrument BanK) Format (3204 Bytes):

  Offset (Length)   Value        Remark
     000 (1)        = 49           ;'I'
     001 (1)        = 42           ;'B'
     002 (1)        = 4B           ;'K'
     003 (1)        = 1A
004..803 (16*128)   = xx           ;The 128 Parameter of Instrument
                                   ;Equal to .SBI [24..33]
804..C83 (9*128)    = xx           ;The 128 Name of Instrument
}


