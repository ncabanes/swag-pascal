────────────────────────────────────────────────────────────────────────────────
<-=-=-=-=- Matthew Mclin to All -=-=-=-=>
 MM> Does anybody know the format of MOD/SAM/WAV/VOC file? Info on any
 MM> of those formats (how to read/write/play them using a PC Speaker or
 MM> LPT 1 with a mono DAC) would be greatly appreciated.

      You know, you are quite lucky that I just decided to pickup the
   Pascal echo even though I'm not a Pascal programmer. I have ALL of
   these file formats! Lucky you! I have had to search high and low all
   over the place for this junk and you're getting it all in one shot.
      Not only do I have those file formats, but I also understand how to
   play them back on the PC's Internal Speaker, LPT DACs, and Sound
   Blaster. I'll be posting that too.
      I have been interested in this field for quite a while, that's how I
   gather up all this information. If I had enough ambition, time, and
   patience, I'd probably write a book on it all because there is not ONE
   SINGLE book that explains how to play digital sound directly (ie,
   without specail drivers), with such drivers, what the file formats are,
   and includes code to do all that stuff.
      Gee, I bet that would make a lot of money, perhaps I should do that
   after all.... Those guys on the 80XXX Assembler echo would probably be
   able to do a better job as they are more knowledgable on this, but most
   of them are into writing demos and creating faster/better MOD players..
      Ok, since this will take up a lot of room, I'll be splitting it up
   into seperate messages. The simpilest stuff goes in this message.

 MM> I would also like info on raw sound data and how to edit/play it.

      Newbe to Digital Sound, eh? Well, you've come to the right place for
   information, or rather, the right person has come to you. Ok, the
   basics. A digital sound file is basically just a bunch of volume
   settings. On the PC, a volume setting of 128 is normally silence.
   Values farther away from 128 in either direction are louder depending
   on its distance from 128. 0 and 255 are the loudest volumes.
      One thing I should make clear, 128 is not nessicarily silence. When
   making a recording, there is always background noise. So, what may
   sound like silence to you, is actually 126-130 or so.
      Now, you have probably seen those neat little graphs that some
   programs make when displaying a digital sound file. VEdit (which comes
   with the Sound Blaster) shows the waveform in the modify part of it. If
   you wanted to display a graph yourself, you could just load in a byte
   from the file, then, use that byte for the Y location. The X location
   is where in the file you are at (which byte). You just keep loading in
   bytes until the end of the screen.
      I could go on and on, but this is just a message, not a book! Hmm,
   you said you wanted to play a digital sound file on the PC's Internal
   Speaker and on a printer port DAC. Well, here comes that part. I'll
   explain usage of printer port DACs first because they are easier to
   understand.
      To play a VOC, WAV, SND, etc file on the DAC, you just read in one
   byte from the file, output it to the printer port, and do it again but
   on the next byte. To get the I/O address of the printer port, read the
   word at memory location 40h:8h for LPT1, 40h:0Ah for LPT2, 40h:0Ch for
   LPT3, and if on a non-ps/2, 40h:0Eh for LPT4.
      The internal speaker is a bit more tricky, you have to do certain
   things to set it up correctly before outputting sound. Before you do
   ANY sound output, you must do the following (sorry, I'm not a Pascal
   programmer, so this is in Assembler):

   Out   43h, 0B6h                     ;Please make note: This code was
   Out   42h, 0FFh                     ;written by a friend of mine in
   Out   42h, 0                        ;australia named Phil Inch. He
   Out   43h, 90h                      ;posted code in the 80x86 Assembler
   In    ax, 61h                       ;echo (GTPN, not Fido) for the
   Or    ax, 3                         ;public domain. Thanks Phil!!
   Out   61h, ax

      Ok, the above sets the timer chip up correctly. From there it is
   pretty simple. Get a byte from the sound file. Divide the byte by a
   'shift' number (I'll explain about this later). Then, output this new
   byte to port 42h. Repeat this for the whole file.
      Ok, now, about that shift value. The PC's Internal Speaker wasn't
   designed for playing digital sound on it, it's just that brainy guys
   like Phil have figured out how to do with software what should have
   been done with hardware.. Anyway, the PC's Internal Speaker isn't very
   loud, so the range of volumes is much less than on a Sound Blaster or
   printer port DAC. This shift value varies from computer to computer, it
   depends on the size of your speaker and other stuff. Genernally, a
   shift value of 4 works on all computers. On my computer, I can get
   anyway with 3 on most files. The smaller the shift value, the louder
   the file will be played, but too small a shift value will cause
   distortion. Experiment!
      After you are finished playing the sound file, you must put the
   timer chip back the way it was supposed to be, or otherwise the next
   program that tries to make a noise on the internal speaker will make
   the noise but will not stop! Here is the code for that (again, sorry
   about the Assembler, it's just that I'm not a Pascal programmer):

   Out   43h, 0B6h
   In    ax, 61h
   And   ax, 0FCh
   Out   61h, ax

      There, that should do it. I hope I haven't totally confused you.
   Please write back if you have ANY questions what-so-ever. Gee, I'm
   already on line 107, time to go to a new message!

 MM> Note that these .MOD
 MM> and .SAM files are in the Amiga Module format (just incase there are
 MM> any others). Oh, there's also the .SND files. Or even .MID/.MDI files
 MM> if you can play them thru a DAC on an LPT port or the PC Speaker. Note
 MM> that I don't have a Sound Blaster (or any other sound card). Thanks.

SAM Files:

      As far as I know, these do not contain any header or specific
   structure. They are just raw sound files. The only trick you have to
   remember about these files are that they are signed, which means that
   when the 7th bit is set, the number is negative. When the 7th bit is
   clear, the number is positive. This is completely different from
   digital sound files that originated on the PC. Remember, MOD and SAM
   files originated from the Amiga, so they have this weird encoding.

      To convert a signed file to an unsigned file, just read in one byte
   from the original file. Add 128 to that byte. Output the answer to a
   new file. In the Amiga world, a byte of 0 is equalivilent to silence.
   A byte of -128 (and +128) is as loud as it gets on the Amiga.  On the
   PC, however, 0 (and 255) is as loud as it gets. A byte of 128 is
   equalivilent to silence on the PC. So, when we add 128 to a -128, we
   get a zereo, which is the same volume for a 128 on the Amiga.

WAV Files:

      The following text was written by Edward Schlunder and was based on
   information provided by Tony Cook on the GT Power Network's 80x86
   Assmebler echo.

                               WAV File Format
                       By: Edward Schlunder. 5-17-93

 BYTE(S)        NORMAL CONTENTS               PURPOSE/DESCRIPTION
 ---------------------------------------------------------------------------

 00 - 03        "RIFF"                        Just an identification block.
                                              The quotes are not included.

 04 - 07        ???                           This is a long integer. It
                                              tells the number of bytes long
                                              the file is, includes header
                                              size.

 08 - 11        "WAVE"                        Just an other I.D. thing.

 12 - 15        "fmt "                        Just an other I.D. thing.

 16 - 19        16, 0, 0, 0                   Size of header to this point.

 20 - 21        1, 0                          Format tag.

 22 - 23        1, 0                          Channels

 24 - 27        ???                           Sample rate, or (in other
                                              words), samples per second.

 28 - 31        ???                           Average bytes per second.

 32 - 33        1, 0                          Block align.

 34 - 35        8, 0                          Bits per sample. Ex: Sound
                                              Blaster can only do 8, Sound
                                              Blaster 16 can make 16.
                                              Normally, the only valid values
                                              are 8, 12, and 16.

 36 - 39        "data"                        Marker that comes just before
                                              the actual sample data.

 40 - 43        ???                           The number of bytes in the
                                              sample.

     Information from Tony Cook, Australia. GT Power 80x86 Assembler echo.

 MM> Does anybody know the format of .MOD/.SAM/.WAV/.VOC file? Info on any
 MM> of those formats (how to read/write/play them using a PC Speaker or
 MM> LPT 1 with a mono DAC) would be greatly appreciated. I would also like

VOC File Format:

      This file format was written by Phil Inch on the 80x86 Assembler
   echo on the GTPN. Thanks Phil!!

BYTE(S)        NORMAL CONTENTS               PURPOSE/DESCRIPTION
---------------------------------------------------------------------------

00 - 19        "Creative Voice File", 26     Just an identification block.
                                             The quotes are not included,
                                             and the 26 is byte 26 (1Ah) which
                                             is an end-of-file marker.  There-
                                             fore, if you TYPE a VOC file, you
                                             will just see Creative Voice File.

20 - 21        26, 00                        This is a low byte, high byte
                                             sequence which gives the offset
                                             of the first block of sound data
                                             in the file.  Currently this is
                                             26 ( 00 x 256 + 26 ) which is the
                                             length of the header, but it's
                                             probably good programming practice
                                             to read and use this value anyway
                                             in case the format changes later.

22 - 23        10,1                          These bytes give the version
                                             number of the VOC file, subnumber
                                             first, then main number.  The
                                             default, as you can see, is 1.10.

24 - 25        41,17                         These bytes are "check digits".
                                             These allow you to be absolutely
                                             SURE that you are working with a
                                             VOC file.  To use them, convert
                                             the version number (above) and
                                             this number to integers.  Do this
                                             with the formula below, where for
                                             convention the above bytes have
                                             been listed as byte1, byte2.

                                             (byte2*256)+byte1

                                             Therefore, for the default values
                                             we get the following integers:

                                             (1 x 256)+10     =  266
                                             (17 x 256)+41    = 4393

                                             When you add the two results, you
                                             get 4659.  If you do these calcs
                                             and get 4659, then you can be
                                             almost certain you're working with
                                             a VOC file.

OK, that takes care of the header information.  I hope you realise that I'll
never get a registration for VOCHDR now!  Oh well <sigh> perhaps people will
buy my games!

   Having gotten to byte 26, we now start encountering data blocks.  There
are eight types in all, conveniently numbered 0 - 7.  For each block, the
first byte will always tell you the type.

For notational convenience, bx means byte x, eg b5 means byte 5.

BLOCK 0 - THE "END BLOCK"

   Structure:     Byte 1: '0' to denote "end block" type

   This block is located at the END of a VOC file.  When a VOC player
   encounters a block 0, it should stop playing the VOC file.


BLOCK 1 - THE "DATA BLOCK"

   Structure:     Byte 1: '1' to denote "data block" type

                       2: \
                       3: | These bytes give the length:
                       4: / b2 + (b3*256) + (b4*65536)

                       5: Sampling rate: Calculated as 1000000 / (256-b5)

                       6: Pack type byte:
                              0 = data is not packed
                              1 = data is packed to four bits
                              2 = data is packed to 2 bits
                              3 = data is packed to 1 bit

                       7: Actual sample data starts here


BLOCK 2 - THE "MORE DATA BLOCK"

   Structure:     Byte 1: '2' to denote "more data block" type

                       2: \
                       3: | These bytes give the length:
                       4: / b2 + (b3*256) + (b4*65536)

                       5: Actual sample data starts here

   The point of this is simple:  If you have a sample that you want to chop
   up into smaller portions (the maximum block length in a VOC file is
   16,842,751 bytes but who's counting?), then define a "more data" block.
   This "carries over" the previously found sampling rate and pack type byte,
   so a "data block" should have been encountered earlier somewhere along
   the line.


BLOCK 3 - THE "SILENCE" BLOCK

   Structure:     Byte 1: '3' to denote "silence block" type

                       2: \
                       3: | These bytes give the length:
                       4: / b2 + (b3*256) + (b4*65536)

                          (Note that this value is usually 3 for a
                          silence block.)

                       5: Duration ( b5+(b6*255) ).  This gives the equivalent
                       6: number of bytes to "play" during the silence.

                       7: Sampling rate: Calculated as 1000000 / (256-b5)

   A silence block is used for long periods of silence.  When long silences
   are required, it's more efficient in size terms to insert one of these
   blocks, as seven bytes can then represent up to 65,536.

BLOCK 4 - THE "MARKER BLOCK"

   Structure:     Byte 1: '4' to denote "marker block" type

                       2: \
                       3: | The length of the block, as usual
                       4: /

                       5: Marker value, as low-high (ie b5 + (b6*255) )
                       6:

   The marker block is read by CT-VOICE.DRV.  When a marker block is
   encountered, the value in the marker value bytes (5 and 6) is copied into
   the status word specified when CT-VOICE was initialized.

   This allows your program to judge where in the sample you currently are,
   thus allowing for progress counters and the like.  It's also useful if
   you're trying to synchronize other processes to the playing of the sound.

   For example, by using appropriate marker blocks, you could send signals
   to your software to move the lips of a person on-screen in time with the
   speech in the VOC.  However, this does take some doing and a VERY good
   VOC editor!


BLOCK 5 - THE "MESSAGE BLOCK"

   Structure:     Byte 1: '5' to denote "message block" type

                       2: \
                       3: | The length of the block, as usual
                       4: /

                   5 - ?: Message, as ASCII text.

                       ?: 0, to denote end of text

   The message block simply allows you to embed text into a VOC file.
   Presumably you could use this to detect when other people have pinched
   your VOC files for their own applications.


BLOCK 6 - THE "REPEAT BLOCK"

   Structure:     Byte 1: '6' to denote "repeat block" type

                       2: \
                       3: | The length of the block, as usual
                       4: /

                       5: Number of times that data should be repeated
                       6: Total = 1 + b5 + (b6*255)

   Every "playable" data block between a block 6 and a block 7 will be repeated
   the number of times specified in b5 and b6.  Note that you add one to this
   value - the data blocks are ALWAYS played at least once.  However, if b5
   and b6 are zero, then you really don't need a repeat block, do you!

   I'm told that you cannot "nest" repeat blocks, but I've never tried it.
   This limitation would only apply to CT-VOICE.DRV I would have thought, but
   it depends how good other VOC players are.


BLOCK 7 - THE "END REPEAT BLOCK"

   Structure:     Byte 1: '7' to denote "end repeat block" type

                       2: \
                       3: | The length of the block, as usual
                       4: /

   This, as explained, marks the end of the block of blocks (!) that you wish
   to repeat.  Note that the "length" is always zero, so I don't know why
   the length bytes are required at all.
---------------------------------------------------------------------

This was picked up off the 80XXX Assembler echo on FidoNet. There are many
other file formats for MODs, but I have found this one to be most complete

Protracker 2.3A Song/Module Format:
-----------------------------------

Offset  Bytes  Description
------  -----  -----------
   0     20    Songname. Remember to put trailing null bytes at the end...
               When written by ProTracker this will be only uppercase;
               there are only historical reasons for this. (And the
               historical reason is that Karsten Obarski, who made the
               first SoundTracker, was stupid.)

Information for sample 1-31:

Offset  Bytes  Description
------  -----  -----------
  20     22    Samplename for sample 1. Pad with null bytes. Will only be
               uppercase.  The samplenames are often used for storing
               messages from the author; in particular, samplenames
               starting with a '#' sign will generally be a message.  This
               convention is a result of a player called IntuiTracker
               displaying all samples starting with # as a message to the
               person playing the module.
  42      2    A WORD with samplelength for sample 1.  Stored as number of
               words.  Multiply by two to get real sample length in bytes.
               This is a big-endian number; for all PC programmers out
               there, this means that to get your 8-bit-orginated format,
               you have to swap the two bytes.
  44      1    Lower four bits are the finetune value, stored as a signed
               four bit number. The upper four bits are not used, and
               should be set to zero.
               They should also be masked out reading; you can never be
               sure what some stupid program could have stored here...
  45      1    Volume for sample 1. Range is $00-$40, or 0-64 decimal.
  46      2    Repeat point for sample 1. Stored as number of words offset
               from start of sample. Multiply by two to get offset in bytes.
  48      2    Repeat Length for sample 1. Stored as number of words in
               loop. Multiply by two to get replen in bytes.

Information for the next 30 samples starts here. It's just like the info for
sample 1.

Offset  Bytes  Description
------  -----  -----------
  50     30    Sample 2...
  80     30    Sample 3...
   .
   .
   .
 890     30    Sample 30...
 920     30    Sample 31...

Offset  Bytes  Description
------  -----  -----------
.
 950      1    Songlength. Range is 1-128.
 951      1    This byte is set to 127, so that old trackers will search
               through all patterns when loading.
               Noisetracker uses this byte for restart, ProTracker doesn't.
 952    128    Song positions 0-127.  Each hold a number from 0-63 (or
               0-127) that tells the tracker what pattern to play at that
               position.
1080      4    The four letters "M.K." - This is something Mahoney & Kaktus
               inserted when they increased the number of samples from
               15 to 31. If it's not there, the module/song uses 15 samples
               or the text has been removed to make the module harder to
               rip. Startrekker puts "FLT4" or "FLT8" there instead.
               If there are more than 64 patterns, PT2.3 will insert M!K!
               here. (Hey - Noxious - why didn't you document the part here
               relating to YOUR OWN PROGRAM? -Vishnu)

Offset  Bytes  Description
------  -----  -----------
1084    1024   Data for pattern 00.
   .
   .
   .
xxxx  Number of patterns stored is equal to the highest patternnumber
      in the song position table (at offset 952-1079).

  Each note is stored as 4 bytes, and all four notes at each position in
the pattern are stored after each other.

00 -  chan1  chan2  chan3  chan4
01 -  chan1  chan2  chan3  chan4
02 -  chan1  chan2  chan3  chan4
etc.

Info for each note:

 _____byte 1_____   byte2_    _____byte 3_____   byte4_
/                \ /      \  /                \ /      \
0000          0000-00000000  0000          0000-00000000

Upper four    12 bits for    Lower four    Effect command.
bits of sam-  note period.   bits of sam-
ple number.                  ple number.


 MM> Does anybody know the format of .MOD/.SAM/.WAV/.VOC file? Info on any

      One thing you should keep in mind about MOD files is that they
   originated from the Amiga, so the samples are signed, see the
   discussion about SAM files for more information.

Note:
       Sounder and Sound Tool both use the same file extension, but have
 different file formats. To tell the difference, Read the first 6 bytes
 of the file. If it matches the magic number for Sound Tool .SND files,
 it is a Sound Tool file. Else, it's a Sounder file or a raw file.


Sounder File Format:

 BYTE(S)        NORMAL CONTENTS               PURPOSE/DESCRIPTION
 ---------------------------------------------------------------------------

 00 - 01        0, 0                          Bits per sample. Ex: Sound
                                              Blaster can only do 8, Sound
                                              Blaster 16 can make 16.
                                              Normally, the only valid value
                                              is 0, which is the code for an
                                              8 bit sample. Future versions
                                              of Sounder and DSOUND.DLL may
                                              allow 16 bit samples and such.

 02 - 03        ???                           Sampling rate. Currently, only
                                              22 KHz, 11 KHz, 7.33 KHz, and
                                              5.5 KHz are valid. If given a
                                              value like 9 KHz, it will be
                                              played at the next closest rate
                                              (in this case, 11 KHz). The
                                              sampling rate is calculated as
                                              follows:

                                              SampRate = Byte1 + (256 * Byte2)

 04 - 05        ???                           Volume to play the sample back
                                              at. Note: On the PC's Internal
                                              Speaker, there is a definite
                                              upper limit as to the volume,
                                              depending on the shift value
                                              (see below). The Sound Blaster
                                              and the Disney Sound Source
                                              aren't quite as restricted,
                                              but still are at some high
                                              value.

 06 - 07        4, 0                          Shift value. This is the number
                                              that each byte is divided by to
                                              "scale" the volume down to a
                                              point where the PC's Internal
                                              Speaker can handle it. See the
                                              discussion on playing back
                                              digitalized sound for more
                                              details.

   Information from Sounder text files and Sound Tool help (.HLP) files.
                       Rewritten by Edward Schlunder


Sound Tool File Format:

 BYTE(S)        NORMAL CONTENTS               PURPOSE/DESCRIPTION
 ---------------------------------------------------------------------------

 00 - 05        "SOUND", 26                   Just an identification thing.
                                              Helps a lot when you are trying
                                              to distinguish between Sounder
                                              .SND files and Sound Tool .SND
                                              files.

 08 - 11        ???                           This is the number of bytes in
                                              the sample. It is calculated as
                                              follows:

       ByteSam = Byte1 + (256 * Byte2) + (512 * Byte3) + (768 * Byte4)

 12 - 15        ???                           This points to the first byte
                                              to play in the file. It is
                                              calculated the same way as the
                                              number of bytes in the sample
                                              (see above).

 16 - 19        ???                           This points to the last byte in
                                              the sample to play. Calculated
                                              the same as above.

 20 - 21        ???                           Sampling rate of the sample.
                                              Valid values are 22 KHz, 11 KHz,
                                              7.33 , and 5.5 K, but if
                                              given a number not listed
                                              above, it will be played at the
                                              closest valid sampling rate.
                                              So, 9 KHz would be played at
                                              11 Khz.
                                              This is calculated as follows:
                                              SamRate =  Byte1 + (256 * Byte2)

 22 - 23        ???                           Bits per sample. Ex: Sound
                                              Blaster can only do 8, Sound
                                              Blaster 16 can make 16.
                                              Normally, the only valid value
                                              is 0, which is the code for an
                                              8 bit sample. Future versions
                                              of Sounder and DSOUND.DLL may
                                              allow 16 bit samples and such.

 24 - 25        ???                           Volume to play the sample back
                                              at. Note: On the PC's Internal
                                              Speaker, there is a definite
                                              upper limit as to the volume,
                                              depending on the shift value
                                              (see below). The Sound Blaster
                                              and the Disney Sound Source
                                              aren't quite as restricted,
                                              but still are at some high
                                              value.

 26 - 27        4, 0                          Shift value. This is the number
                                              that each byte is divided by to
                                              "scale" the volume down to a
                                              point where the PC's Internal
                                              Speaker can handle it. See the
                                              discussion on playing back
                                              digitalized sound for more
                                              details.

 28 - 123       ???                           This is the name of the sample.
                                              It is followed by an ASCII 0.

   Information from Sounder text files and Sound Tool help (.HLP) files.
                         Rewritten by Edward Schlunder