(*
  Category: SWAG Title: FREQUENTLY ASKED QUESTIONS/TUTORIALS
  Original name: 0019.PAS
  Description: MIDI Information
  Author: ALTON PRILLAMAN
  Date: 11-02-93  06:06
*)

{
ALTON PRILLAMAN

HOWEVER, <g> now would be a good time to learn about "Bitwise Operators"
to accomplish your goal With minimal memory requirements.  I'll start With
the basics (no offense intended).  You may have heard, or remember from a
Programming class that a Byte is made up of 8 bits.  When looking at a Byte
in binary, each bit holds a value of 0 or 1 that when put together in
their respective places will add up to make the number.  Here's an
example of a Byte:

                               B I N A R Y
                                T A B L E
=========================================================================

             Power |   7   6   5   4   3   2   1   0 | of 2
             ------+---------------------------------+-----
             Bit # |   8   7   6   5   4   3   2   1 |
             ------+---------------------------------+-----
             Value | 128  64  32  16   8   4   2   1 | HEX
             ------+---------------------------------+-----
                0  |   0   0   0   0   0   0   0   0 | $00
                1  |   0   0   0   0   0   0   0   1 | $01
            *   2  |   0   0   0   0   0   0   1   0 | $02
                3  |   0   0   0   0   0   0   1   1 | $03
            *   4  |   0   0   0   0   0   1   0   0 | $04
                5  |   0   0   0   0   0   1   0   1 | $05
                6  |   0   0   0   0   0   1   1   0 | $06
                7  |   0   0   0   0   0   1   1   1 | $07
            *   8  |   0   0   0   0   1   0   0   0 | $08
                9  |   0   0   0   0   1   0   0   1 | $09
               10  |   0   0   0   0   1   0   1   0 | $0A
               11  |   0   0   0   0   1   0   1   1 | $0B
               12  |   0   0   0   0   1   1   0   0 | $0C
               13  |   0   0   0   0   1   1   0   1 | $0D
               14  |   0   0   0   0   1   1   1   0 | $0E
               15  |   0   0   0   0   1   1   1   1 | $0F
            *  16  |   0   0   0   1   0   0   0   0 | $10
                   |                                 |
            *  32  |   0   0   1   0   0   0   0   0 | $20
            *  64  |   0   1   0   0   0   0   0   0 | $40
            * 128  |   1   0   0   0   0   0   0   0 | $80
                   |                                 |
              255  |   1   1   1   1   1   1   1   1 | $FF
             ------+---------------------------------+-----

 * = All columns to the right had filled up With 1s, so we carried to the
     next column to the left.

Notice that when all of the "bit places" have a "1" in them, that the
total adds up to be 255 which is the maximum number that a Byte can hold.
In binary (the inner part of the Chart), "1" is the maximum value a bit
can hold Until it carries to the next column to the left.  This brings us
to the next Chart, HEXIDECIMAL:


                          H E X I D E C I M A L
                                T A B L E
=========================================================================

            Power| 1   0   |of 16        Power|  1  0   |of 16
          -------+---------+-----      -------+---------+-----
          Decimal|         |           Decimal|         |
            Value| 16  0   | HEX         Value| 16  0   | HEX
          -------+---------+-----      -------+---------+-----
                0|  0  0   | $00            31|  1  1   |  $1F
                1|  0  1   | $01         *  32|  2  0   |  $20
                2|  0  2   | $02            33|  2  1   |  $21
                3|  0  3   | $03              |         |
                4|  0  4   | $04            47|  2  F   |  $2F
                5|  0  5   | $05         *  48|  3  0   |  $30
                6|  0  6   | $06            63|  3  F   |  $3F
                7|  0  7   | $07         *  64|  4  0   |  $40
                8|  0  8   | $08            79|  4  F   |  $4F
                9|  0  9   | $09            80|  5  0   |  $50
               10|  0  A   | $0A            95|  5  F   |  $5F
               11|  0  B   | $0B         *  96|  6  0   |  $60
               12|  0  C   | $0C           111|  6  F   |  $6F
               13|  0  D   | $0D         * 112|  7  0   |  $70
               14|  0  E   | $0E           127|  7  F   |  $7F
               15|  0  F   | $0F         * 128|  8  0   |  $80
           *   16|  1  0   | $10           255|  F  F   |  $FF
               17|  1  1   | $11         * 256|         |$0100
          -------+---------+-----      -------+---------+-----

 * = All columns to the right had filled up With 15 (F) so we carried
     to the next column to the left.

The hexidecimal table is derived from BASE 16.  The value that each column
may hold a value of 15 (F) before we carry to the next column.  Also
notice that when both columns fill up With a value of "F" ($FF) that the
result is 255, which is the maximum For a Byte.


Okay, With that behind us, let's take a look at your application.  As you
may have noticed in the binary table in the previous message, a Byte will
give us the ability to track up to 8 bits.  Our goal here is to turn on or
off each of the 8 bits as each channel is turned on or off.  I assume that
you've got 16 channels to work With, so we'll use a Word instead of a
Byte.  When looked at in binary, a Word is like placing two Bytes
side-by-side.  Notice that the HEXIDECIMAL works the same way.

   256-------------------------+  +---------------------------- 128
   512----------------------+  |  |  +-------------------------  64
  1024-------------------+  |  |  |  |  +----------------------  32
  2048----------------+  |  |  |  |  |  |  +-------------------  16
  4096-------------+  |  |  |  |  |  |  |  |  +----------------   8
  8192----------+  |  |  |  |  |  |  |  |  |  |  +-------------   4
 16384-------+  |  |  |  |  |  |  |  |  |  |  |  |  +----------   2
 32768----+  |  |  |  |  |  |  |  |  |  |  |  |  |  |  +-------   1
          |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
          |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
 Power | 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0|of 2
-------+------------------------------------------------+-------
 Bit # | 16 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1|
-------+------------------------------------------------+-------
Decimal|                                                |
  Value|                   BINARY                       |   HEX
-------+------------------------------------------------+-------
      1|  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1| $0001
      2|  0  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0| $0002
      4|  0  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0| $0004
      8|  0  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0| $0008
     16|  0  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0| $0010
     32|  0  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0| $0020
     64|  0  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0| $0040
    128|  0  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0| $0080
    256|  0  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0| $0100
    512|  0  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0| $0200
   1024|  0  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0| $0400
   2048|  0  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0| $0800
   4096|  0  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0| $1000
   8192|  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0| $2000
  16384|  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0| $4000
  32768|  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0| $8000
-------+------------------------------------------------+-------

Though it has taken us a While to get here, you now have a "value" for
each of your midi channels.  if you need to use more than 16 channels, you
can use the same methods applied above using a LongInt to give you a total
of 32 channels (or bits).

You can now declare these as Constants in your Program like so:
}

Program MidiStuff;
Const
   {Midi Channels}
   Ch1  = $0001;
   Ch2  = $0002;
   Ch3  = $0004;
   Ch4  = $0008;
   Ch5  = $0010;
   Ch6  = $0020;
   Ch7  = $0040;
   Ch8  = $0080;
   Ch9  = $0100;
   Ch10 = $0200;
   Ch11 = $0400;
   Ch12 = $0800;
   Ch13 = $1000;
   Ch14 = $2000;
   Ch15 = $4000;
   Ch16 = $8000;

Var
  MidiChannels : Word;

{ Now you can turn on or off each channel and check to see if one is set by
using the following Procedures and Functions.  You can accomplish this by
using the or and and operators. }

Function ChannelIsOn(Ch : Word) : Boolean;
begin
   ChannelIsOn := (MidiChannels and Ch = Ch);
end;

Procedure TurnOnChannel(Ch : Word);
begin
   MidiChannels := MidiChannels or Ch;
end;

Procedure TurnOffChannel(Ch : Word);
begin
   MidiChannels := MidiChannels and not Ch;
end;

begin
   MidiChannels := $0000; {Initialize MidiChannels - No channels on!}
   TurnOnChannel(Ch2);
   if ChannelIsOn(Ch2) then
     Writeln('Channel 2 is on!')
   else
     Writeln('Channel 2 is off!');
   if ChannelIsOn(Ch3) then
     Writeln('Channel 3 is on!')
   else
     Writeln('Channel 3 is off!');
   TurnOnChannel(Ch16);
   TurnOnChannel(Ch10);
   TurnOffChannel(Ch2);
   if ChannelIsOn(Ch2) then
     Writeln('Channel 2 is on!')
   else
     Writeln('Channel 2 is off!');
end.


