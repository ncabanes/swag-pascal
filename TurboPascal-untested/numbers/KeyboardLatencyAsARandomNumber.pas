(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0063.PAS
  Description: Keyboard Latency as a Random Number
  Author: JIM ROBB
  Date: 11-26-94  05:09
*)

{
> Bruce Schneier suggests keyboard latency as a good source of randomness.
> I suspect you'd find the delays far more regular than you'd guess, but
> it's worth looking at.  Show us an implementation!

Thanks, DJ.  (And I was hoping a simple appeal to a recognized authority
would suffice!  I guess I should have known better.)  But fair enough -
here's an admittedly crude implementation:
}

program TestKey;

{ Test keyboard latency as a potential source of random numbers. }
{ NOTE - NO ERROR CHECKING!                                      }

uses
  Dos, Crt;

const
  FileName = 'RANDOM.TST';

var
  PrevTime : Word;
  RandByte : Byte;
  Regs     : Registers;
  Bit      : Word;
  RandFile : file of Byte;
  Ch       : Char;

begin
  { open the file }
  Assign( RandFile, FileName );
  Rewrite( RandFile );

  { get DOS time and save low word }
  Regs.AH := 0;
  Intr( $1A, Regs );
  PrevTime := Regs.DX;

  Bit := 0;
  RandByte := 0;
  WriteLn( 'Start typing now.  Press <ESC> to quit.' );

  repeat
    { get a keystroke }
    repeat until KeyPressed;
    Ch := ReadKey;

    { if the Escape key }
    if Ch = #27 then
      Break;

    { get DOS time }
    Regs.AH := 0;
    Intr( $1A, Regs );

    { calculate the time difference, isolate the low-order bit, and }
    { use it to build the hopefully-random byte in progress.        }
    RandByte := RandByte + ( ( Lo( Regs.DX - PrevTime ) and 1 ) shl Bit );
    PrevTime := Regs.DX;
    Inc( Bit );

    { If we have a full byte, write it to the file and start over }
    if ( Bit > 7 ) then begin
      Write( RandFile, RandByte );
      RandByte := 0
      Bit := 0;
    end;

    { Ignore special keys, display the rest }
    if Ch = #0 then
      Ch := ReadKey
    else
      Write( Ch );
    if Ch = #13 then
      Write( #10 )

  until False;
  Close( RandFile )
end.

{
I ran this thing and typed in the first page of a DOC file.  This is what I
got:

  24  98  AD  94  E2  C8  00  58  20  83  09  F1  5D  F5  76  59
  31  A9  86  DC  32  6D  96  17  65  C4  75  31  A3  18  F5  97
  87  0A  69  B4  B6  E7  0A  C1  F8  09  BE  B0  7B  C5  4A  BA
  69  42  8C  D4  E4  71  12  DF  5E  19  5C  A0  0D  79  D7  F1
  66  BC  40  36  E9  8D  DB  B5  37  A9  7A  0C  02  90  05  04
  EA  53  38  CA  94  18  92  8A  46  A6  F1  56  D0  E7  38  97
  25  2D  C3  C8  7E  79  DE  02  58  FC  36  7E  BC  3C  F9  6D
  E6  2E  C0  28  06  AD  C1  4B  55  CD  C4  98  DD  08  DD  4E
  11  56  76  83  BC  7A  AF  05  F6  AC  C3  40  28  D5  2B  8E
  C1  93  B5  F9  54  E2  00  3D  5A  5D  37  36  C3  5F  37  3A
  AB  60  36  72  27  26  21  86  2F  B4  6B  D9  70  94  DE  00
  C8  23  34  5F  83  C9  FB  AF  F8  F5  CE  21  B3  40  FA  ED
  21  4B  65  00  D9  A0  6E  43  E4  FF  66  1B  BC  17  80  29
  FD  6F  10  4B  D7  D3  ED  5C  C9  18  0E  24  89  1F  03  BC
  B3  0B  CB  E5  1E  16  B8  DA  99  EC  93  84  7E  8A  FE  61
  9D  B7  2E  30  11  7F  0A  C6  83  C2  C1  97  3B  08  61  8D
  7B  5E  7E  69  99  F8  F3  36  BA  31  6E  41  60  8C  DC  B7
  48  FB  44  A2  78  D5  AF  88  D9  10  50  E7  C7  BE  68  41
  C2  E8  D8  1B

The distribution of bytes looks like this:

         0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
     +-----------------------------------------------------------------
 0   |   4   0   2   1   1   2   1   0   2   2   3   1   1   1   1   0
 1   |   2   2   1   0   0   0   1   2   3   1   0   2   0   0   1   1
 2   |   1   3   0   1   2   1   1   1   2   1   0   1   0   1   2   1
 3   |   1   3   1   0   1   0   5   3   2   0   1   1   1   1   0   0
 4   |   3   2   1   1   1   0   1   0   1   0   1   3   0   0   1   0
 5   |   1   0   0   1   1   1   2   0   2   1   1   0   2   2   2   2
 6   |   2   2   0   0   0   2   2   0   1   3   0   1   0   2   2   1
 7   |   1   1   1   0   0   1   2   0   1   2   2   2   0   0   4   1
 8   |   1   0   0   4   1   0   2   1   1   1   2   0   2   2   1   0
 9   |   1   0   1   2   3   0   1   3   2   2   0   0   0   1   0   0
 A   |   2   0   1   1   0   0   1   0   0   2   0   1   1   2   0   3
 B   |   1   0   0   2   2   2   1   2   1   0   2   0   5   0   2   0
 C   |   1   4   2   3   2   1   1   1   3   2   1   1   0   1   1   0
 D   |   1   0   0   1   1   2   0   2   1   3   1   1   2   2   2   1
 E   |   0   0   2   0   2   1   1   3   1   1   1   0   1   2   0   0
 F   |   0   3   0   1   0   3   1   0   3   2   1   2   1   1   1   1


Question - is it random?  Well, it's far too small a sample to be sure, and I
wasn't about to retype "War and Peace" to get a bigger sample.  It passes
one test of randomness - non-compressability.  LHA won't compress it, anyway.
(A text file of similar size compressed to 64%.)  I don't consider this
definite proof of randomness, although it looks hopeful.

Question - is it unpredictable?  Given the above source code and the list of
bytes generated, I don't think I could predict what the next byte would be.

Question - can it be reliably reproduced?  Not at my level of typing ability,
unless I cheat and just hold down a key.  Even then, there are minor
variations between bytes.

Problem - the timer is too coarse.  It uses the BIOS time-of-day count, which
ticks over about 18.2 times per second.  For a 30-wpm (3 character-per-second)
typist like me, it _seems_ to produce acceptable results.  For a professional
typist, churning out 110 wpm (11 characters per second), it probably won't.
Something using the 8253 timer (a modification of the Abrash "Zen Timer", for
example) would probably be adequate for even the fastest typist, but that's a
bit too exotic for me to attempt.

Problem - it takes a lot of typing to generate a decent pad.  By my
calculations, a 110-wpm typist would have to type for 20 minutes to create a
pad big enough to encrypt one double-spaced typewritten page.  Possible
solution - rewrite the thing as a TSR, so that a typist can do useful work
while generating random (?) numbers in the background.  Then, turn the whole
typing pool loose on the problem.

Does anyone have a better timer routine and a faster typist?
}

