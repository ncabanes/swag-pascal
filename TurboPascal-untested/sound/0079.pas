{
> I want to make a .Wav file into a midi file. Actually all I really
> need are the frequencies that each note is played at... if that is
> posible. Does anyone know how to read .Wav files or that know of a
> program that will tell me the frequencies... I intend to make a
> program that will print out the note in a wave file.. maybe only one
> line of music.. but hay.. Thanks

Sounds great, huh.

Somehow, reading WAVs isn't awfully complex. There are tons of texts about
the RIFF chunks by Mickeysoft, the so-called "MULTI-MEDIA-FORMATS", which
WAV is one of.

(Header, from my code:)
}
  TWavDateiHeader=record       { guess it, it's German, and so am I  }
    RIFF:FourCharCode;
    Size:Longint;              { forget this                         }
    wave:FourCharCode;
    fmt_:FourCharCode;
    Sizefmt:Longint;

    FormatTag:Word;            { 1=PCM                               }
    Channels:Word;             { 1=Mono, 2=Stereo                    }
    SampleRate:Longint;
    AvgBytesPerSec:Longint;    { usually same as Sp.Rate             }
    nBlockAlign,               { too lazy to look it up :(           }
    nBitsperSample:Word;       { 8 or 16                             }
    dat_:FourCharCode;         { forget this                         }

    Sizedata:Longint;          { size of the sample data             }
  End;
{
followed immediately by the sample data. You should be able to figure out
what the fields mean. It's kind of inflexible interpreting a chunked file
this way, but the fmt is improbable to change any more.

For getting the frequencies out of a wav, you need to do an fft (Fourier
analysis). that gets you the sinus components of the wave, which is total
nonsense for converting to midi. But you may try and do it, best is to
go for some literature on it.
}

