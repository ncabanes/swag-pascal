{
From: jurip@clinet.fi (Juri Pakaste)

Hopefully someone here has experience reading S3M headers...
I'm trying to read the S3M header. I get the name right, I think
I get the number of instruments right, but I can't get the number
of patterns right. If I understand correctly the file which comes
with Scream Tracker 3.01 (see below), the number of patterns
should be located in bytes 35-36 (why on earth two bytes? Who
would use over 255 patterns?). The numbers I get have nothing to
do with numbers DMP and Inertia Player give, though. My little test-
program, S3MREAD.EXE, tells me, for example, that a module that has
55 (I think) patterns, has in fact 99. Just great. Some of the values
it gives manage to get pretty near the ones DMP and IPlay give,
but... you get the idea.

Here is there relevant part of S3M technical documentation:

------------------------------------8<----------------------------------
 
                                Song/Module header
          0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
        -----------------------------------------------------------------
  0000: | Song name, max 28 chars (incl. NUL)                           |
        |---------------------------------------------------------------|
  0010: |                                               |1Ah|Typ| x | x |
        |---------------------------------------------------------------|
  0020: |OrdNum |InsNum |PatNum | Flags | Cwt/v |  Ffv  |'S'|'C'|'R'|'M'|
        |---------------------------------------------------------------|
  0030: |m.v|i.s|i.t|m.m| x | x | x | x | x | x | x | x | x | x | x | x |
        |---------------------------------------------------------------|
  0040: |Channel settings for 32 channels, 255=unused,+128=disabled     |
        |---------------------------------------------------------------|
  0050: |                                                               |
        |---------------------------------------------------------------|
  0060: |Orders; length=OrdNum (must be even)                           |
        |---------------------------------------------------------------|
  xxxx: |Parapointers to instruments; length=InsNum*2                   |
        |---------------------------------------------------------------|
  xxxx: |Parapointers to patterns; length=PatNum*2                      |
        -----------------------------------------------------------------

 
        Typ     = File type: 16=module,17=song
        Ordnum  = Number of orders in file
        Insnum  = Number of instruments in file
        Patnum  = Number of patterns in file
        Cwt/v   = Created with tracker / version: &0xfff=version, >>12=tracker
                        ST30:0x1300
        Ffv     = File format version;
                        1=original
                        2=original BUT samples unsigned
        Parapointers are OFFSET/16 relative to the beginning of the header.
 
        PLAYING AFFECTORS / INITIALIZERS:
        Flags   =  +1:st2vibrato 
                   +2:st2tempo
                   +4:amigaslides
                   +8:0vol optimizations
                   +16:amiga limits
                   +32:enable filter/sfx
        m.v     = master volume
        m.m     = master multiplier (&15) + stereo(=+16)
        i.s     = initial speed (command A)
        i.t     = initial tempo (command T)
 
        Channel types:
        &128=on, &127=type: (127=unused)
        8  - L-Adlib-Melody 1 (A1)      0  - L-Sample 1 (S1)
        9  - L-Adlib-Melody 2 (A2)      1  - L-Sample 2 (S2)
        10 - L-Adlib-Melody 3 (A3)      2  - L-Sample 3 (S3)
        11 - L-Adlib-Melody 4 (A4)      3  - L-Sample 4 (S4)
        12 - L-Adlib-Melody 5 (A5)      4  - R-Sample 5 (S5)
        13 - L-Adlib-Melody 6 (A6)      5  - R-Sample 6 (S6)
        14 - L-Adlib-Melody 7 (A7)      6  - R-Sample 7 (S7)
        15 - L-Adlib-Melody 8 (A8)      7  - R-Sample 8 (S8)
        16 - L-Adlib-Melody 9 (A9)
                                        26 - L-Adlib-Bassdrum (AB)
        17 - R-Adlib-Melody 1 (B1)      27 - L-Adlib-Snare    (AS)
        18 - R-Adlib-Melody 2 (B2)      28 - L-Adlib-Tom      (AT)
        19 - R-Adlib-Melody 3 (B3)      29 - L-Adlib-Cymbal   (AC)
        20 - R-Adlib-Melody 4 (B4)      30 - L-Adlib-Hihat    (AH)
        21 - R-Adlib-Melody 5 (B5)      31 - R-Adlib-Bassdrum (BB)
        22 - R-Adlib-Melody 6 (B6)      32 - R-Adlib-Snare    (BS)
        23 - R-Adlib-Melody 7 (B7)      33 - R-Adlib-Tom      (BT)
        24 - R-Adlib-Melody 8 (B8)      34 - R-Adlib-Cymbal   (BC)
        25 - R-Adlib-Melody 9 (B9)      35 - R-Adlib-Hihat    (BH)

So, shouldn't this piece of code be able to read the name,
number of instruments and number of patterns right:

}
Program S3MReader;
Var
   NameArray       :       Array [1..28] Of Char;
   InstrArray, PatArray : Array [1..2] Of Byte;
   InstrByte, PatByte   :       Byte;
   f : File;
   i       :       Integer;
   j       :       Integer;
   S3MName :       String;

Begin
   WriteLn;
   WriteLn;
   If ParamCount = 1 Then
   Begin
      Assign(f,ParamStr(1));
      Reset(f,1);
      BlockRead(f,NameArray,28,i);
      For j := 1 To 28 Do S3MName := S3MName + NameArray[j];
      j := 28;
      While (Ord(S3MName[Length(S3MName)]) = 0) Or (Ord(S3MName
   (continues...)[Length(S3MName)]) = 32) Do
      Begin
         j := j - 1;
         S3MName[0] := Chr(j);
      End;
      Seek(f,33);
      BlockRead(f,InstrArray,2,i);
      InstrByte := InstrArray[1] + InstrArray[2];
      BlockRead(f,PatArray,2,i);
      PatByte := PatArray[1] + PatArray[2];
      WriteLn('Name: ',S3MName);
      WriteLn('Number of instruments: ',InstrByte);
      WriteLn('Number of patterns: ',PatByte);
      Close(f);
   End;
End.

