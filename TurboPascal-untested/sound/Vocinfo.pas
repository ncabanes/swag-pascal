(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0013.PAS
  Description: VOCINFO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
 I posted beFore about sample converting... the .VOC to the sample
 Format used by MODS.  You gave me some example code, but the prob is,
 VOC Files have a header, how would I do it so that the header wasn't
 converted?

Here is the VOC File Format that was posted here a While back.  It works
well For me.


A .VOC File consists of a 26-Byte header Record plus sample data.
The header Record has the following layout:
}
VoiceHeader  : Record
     signature   : Array[1..20] of Char;   { Vendor's name }
     DataStart   : Word;      { Start of data in File }
     Version     : Integer;   { BCD value: min. driver version required }
     ID          : Integer;   { 1-Complement of Version field+$1234 }
   end;                       { used to indentify a .VOC File }

The data is divided into 'blocks'.  There are 8 Types of blocks:

-  0 : Terminator
       1 Byte Record, value 00

-  1 : Voice Data
       1 Byte, value 01: identifier
       3 Bytes: length of voice data (len data + 2)
       1 Byte: SR= 256-(1,000,000 / sampling rate)
       1 Byte: pack field, value:
         0 : unpacked, 1 : 4-bit, 2 : 2.6 bit, 3 : 2 bit packed
       <follows voice data>

-  2 : Voice Continuation
       1 Byte, value 02: identifier
       3 Bytes: length of voice data
       <follows voice data>

-  3 : Silence
       1 Byte, value 03: identifier
       3 Bytes: length of silence period (value 3?)
       2 Bytes: silence period in Units of sampling cycles
       1 Byte: SR (see above)

-  4 : Marker
       1 Byte, value 04: identifier
       3 Bytes: length of marker, value 2
       2 Bytes: user defined marker

-  5 : ASCII Text
       1 Byte, value 05: identifier
       3 Bytes, length of String (not counting null Byte)
       <String>
       1 Byte, value 0: String terminator

-  6 : Repeat Loop
       1 Byte, value 06: identifier
       3 Bytes: length of block, value 2
       2 Bytes: count value+1

-  7 : end Repeat Loop
       1 Byte, value 07: identifier
       3 Bytes: length of block, value 0

{
to my knowledge, the .VOC File Format is proprietary and the data
herein is only of value For the specific SoundBlaster hardware. I think
you'll have a hard time converting samples to another synthesizer.
}

