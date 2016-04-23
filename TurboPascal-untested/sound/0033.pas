{
EDWARD SCHLUNDER

> Hey everyone.. I am requesting some info on the File format of MOD
> Files  and also WAV Files. I would Really appreciate any help on this topic.

Well, the MOD File format has been posted over the place many times, so I
won't post THAT again. But here comes the WAV File format that you wanted..

               WAV File Format. Written by Edward Schlunder.
                        Information from Tony Cook

 Byte(S)        NORMAL CONTENTS               PURPOSE/DESCRIPTION
 ---------------------------------------------------------------------------

 00 - 03        "RIFF"                        Just an identification block.
                                              The quotes are not included.

 04 - 07        ???                           This is a long Integer. It
                                              tells the number of Bytes long
                                              the File is, includes header,
                                              not just the Sound data.

 08 - 11        "WAVE"                        Just an other I.D. thing.

 12 - 15        "fmt "                        Just an other I.D. thing.

 16 - 19        16, 0, 0, 0                   Size of header to this point.

 20 - 21        1, 0                          Format tag. I'm not sure what
                                              'Format tag' means, but I
                                              believe it has something to
                                              do With how the File is
                                              formated, so that if someone
                                              wants to change the File
                                              format to include something
                                              new, they could also change
                                              this to show that it's a
                                              different format.

 22 - 23        1, 0                          Channels. Channels is how many
                                              Sounds to be played at once.
                                              Sound Blasters have only one
                                              channel, and this is probably
                                              why this is normally set to 1.
                                              The Amiga has 4 (hence 4
                                              channel MODs) channels. The
                                              Gravis Ultra Sound has many
                                              more, I believe up to 32.

 24 - 27        ???                           Sampling rate, or (in other
                                              Words), samples per second.
                                              This is used to determine
                                              how fast to play the WAV. It
                                              is also essentially the same
                                              as Bytes 28-31.

 28 - 31        ???                           Average Bytes per second.

 32 - 33        1, 0                          Block align.

 34 - 35        8, 0                          Bits per sample. Ex: Sound
                                              Blaster can only do 8, Sound
                                              Blaster 16 can make 16.
                                              Normally, the only valid values
                                              are 8, 12, and 16.

 36 - 39        "data"                        Marker that comes just before
                                              the actual sample data.

 40 - 43        ???                           The number of Bytes in the
                                              sample.

      There, I hope you like it.. if you ever have any needs For Sound
   card or just Sound related Programming information, give me a *bang*
   and I'll run... I might be late replying, but I will get back to you.
}
