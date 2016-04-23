
{ Updated SOUND.SWG on May 26, 1995 }

{

> Hi, I am planning to write a MOD player and I need the file Structure

             **********************************************
             ******  Amiga Protracker Module Format  ******
             **********************************************

 ****************************
 *Offset**Bytes**Description*
*****************************************************************************
**   0     20    Module name.  Padded with spaces until the end (or should
**                 be).  Remember to only print 20 characters.
***Samples*******************************************************************
**  20( 0) 22    Sample Name.  Should be padded with nulls for the full
**                 length of it after the sample name.
**  42(22)  2    Sample Length.  Stored as an Amiga word which needs to be
**                 swapped on an IBM.  This word needs to be multiplied by
**                 two to get the real length.  If the initial length is
**                 greater than 8000h, then the sample is greater than 64k.
**  44(24)  1    Sample Finetune Byte.  This byte is the finetune value for the
**                 sample.  The upper four bits should be zeroed out.  The
**                 lower four are the fine tune value.
**                   Value ***** 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E F
**                   Finetune ** 0 +1 +2 +3 +4 +5 +6 +7 -8 -7 -6 -5 -4 -3 -2 -1
**  45(25)  1    Sample Volume.  The rangle is always 0-64.
**  46(26)  2    Sample Repeat.  Stored as an Amiga word.  Multiply this by
**                 two and add it to the beginning offset of the sample to get
**                 the repeat point.
**  48(28)  2    Sample Repeat Length.  Stored as an Amiga word.  Multiply this
**                 by two to get the Repeat Length.
*****************************************************************************
**          *** The remaining 14 or 30 samples follow this point ***
**          *** using the same format as above.  Note that the   ***
**          *** rest of this module format follows a 31 sample   ***
**          *** format, which is not different from the 15       ***
**          *** sample format except for the file offset.        ***
*****************************************************************************
** 950      1    The Song Length in the range of 1 to 128.
** 951      1    I don't know.  I was told that Noisetracker uses this byte
**                 for a restart, but I don't use Noisetracker.  Anyone have
**                 any information?
** 952    128    Play Sequences 0-127.  These indicate the appropriate
**                 pattern to play at this given position.
**1080      4    If this position contains:   "M.K." or "FLT4" or "FLT8"
**                                              - the module is 31 ins.
***Patterns******************************************************************
**1084(0)   1    Upper 4 bits: MSB of the instrument.  Must be ORed with the
**                 LSB.  Lower 4 bits:  Upper 4 bits of the period.
**1085(1)   1    Contains the lower 8 bits of the period.
**1086(2)   1    Upper 4 bits: LSB of the instrument.  Must be ORed with the
**                 MSB.  Lower 4 bits: Special effects command.  Contains a
**                 command 0-F.
**1087(3)   1    Special effects data.
*****************************************************************************
**          *** The number of patterns is the highest pattern    ***
**          *** number stored in the Play Sequence list.         ***
*****************************************************************************
** Each note is four bytes long.  Four notes make up a track.  They are
** stored like this:
**         0-3           4-7           8-11         12-15
**      Channel 1     Channel 2     Channel 3     Channel 4
**        16-19         20-23         24-27         28-31
**      Channel 1     Channel 2     Channel 3     Channel 4
** ...and so on.
**
**
**
**                  00           00           00           00
**                  ||           ||           ||           ||
**                  /\           //           /\           \\
**  MSB of Ins.   Note        LSB Ins. Spec. Com.   Data for special
**
** The samples immediately follow.
**
*****************************************************************************
}