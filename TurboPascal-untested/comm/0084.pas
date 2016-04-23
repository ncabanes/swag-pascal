{
> I'm looking for any transfer protocols in pascal... that can be used with
> 7.0 *any* protocol... but DSZ supports most so if you got dsz that would
> be nice

Heres *something*....  not much to go on, but it supposedly works....

Basic States table for each of the protocols. There is a Rosetta Stone at
the bottom of the document.

I can't claim copyright for these tables, but they do work.

Mark Dignam - Perth Omen BBS - 3:690/660.0@Fidonet

-----------------------------------------------------------------------------

Xmodem CheckSum

Sender                                       Receiver
                                                NAK
                                                NAK
SOH 01 FE data[128] sum
                                                ACK
SOH 02 FD data[128] sum
                                                NAK
SOH 02 FD data[128] sum
                                                ACK
SOH 03 FC data[128] sum
                                                ACK
SOH 04 FB data[100] 1A[28] sum
                                                ACK
EOT
                                                ACK

 -----------------------------------------------------------------------------

Xmodem CRC

Sender                                     Receiver
                                                C
                                                C
SOH 01 FE data[128] crchi crclo
                                                ACK
SOH 02 FD data[128] crchi crclo
                                                NAK
SOH 02 FD data[128] crchi crclo
                                                ACK
SOH 03 FC data[128] crchi crclo
                                                ACK
SOH 04 FB data[100] 1A[28] crchi crclo
                                                ACK
EOT
                                                ACK
-----------------------------------------------------------------------------

Ymodem Batch (usually CRC!)

 Sender                                     Receiver
                                                C
                                                C
SOH 00 FF Y/Zmodem Header[128] crchi crclo
                                                ACK
                                                C

STX 01 FE data[1024] crchi crclo
                                                ACK
STX 02 FD data[1024] crchi crclo
                                                NAK
STX 02 FD data[1024] crchi crclo
                                                ACK
STX 03 FC data[1024] crchi crclo
                                                ACK
STX 04 FB data[1024] crchi crclo
                                                ACK
EOT
                                                ACK
                                                C
SOH 00 FF NUL[128]

-----------------------------------------------------------------------------
 Ymodem-G Batch (usually CRC!)  Sender just looks for NAK. Single Nak bombs
                               Transfer.

Sender                                     Receiver
                                                G
                                                G
SOH 00 FF Y/Zmodem Header[128] crchi crclo
                                                G

STX 01 FE data[1024] crchi crclo
STX 02 FD data[1024] crchi crclo
STX 03 FC data[1024] crchi crclo
STX 04 FB data[1024] crchi crclo
EOT
                                                ACK
                                                G
SOH 00 FF NUL[128]
                                                ACK

-----------------------------------------------------------------------------
Sealink - Don't wait for the ACK's, if they start arriving, just make sure
          they stay within 6 blocks of blocks being sent.

 Sender                                         Receiver
                                                C
                                                C
SOH 00 FF SealinkHeader[128] crchi crclo
                                                ACK 00 FF
SOH 01 FE data[128] crchi crclo
                                                ACK 01 FE
SOH 02 FD data[128] crchi crclo
                                                NAK 02 FD
SOH 02 FD data[128] crchi crclo
                                                ACK 02 FD
SOH 03 FC data[128] crchi crclo
                                                ACK 03 FC
SOH 04 FB data[100] 1A[28] crchi crclo
                                                ACK 04 FB
EOT
                                                ACK 05 FA
                                                C
SOH 00 FF NUL[128] crchi crclo
                                                ACK 00 FF

-----------------------------------------------------------------------------
Zmodem - for futher on this - find Chuck Forsbergs document on the Zmodem
          protocol. Its a bit much to go into here, but basicly the ^X char,
         which is called a ZDLE, is the whole key. To send a ^X as part of
         data, you must send a $18,$58, etc.

         The various 'frames' (the ZRINIT, ZDATA etc) start with a ZDLE and
         are fully variable depending on the exact frame type, the method of
         Crc (CRC16 or CRC32) and the flags which are exchanged between each
         system at start of transmission

Sender                                         Receiver

ZRQINIT XON
                                                ZRINIT
ZFILE
                                                ZRPOS
ZDATA
data[1024] crchi crclo
data[1024] crchi crclo
data[1024] crchi crclo
ZEOF
                                                ZRINIT
ZFIN
                                                ZFIN
 OO

-----------------------------------------------------------------------------
Yapp - This is a specialised protocol used (at this stage) only on Packet
       Radio. It requires a error link end to end, but compared to say
       YmodemG or Zmodem, is a bit of a slug!

       Lenblock is sent as a byte, and therefore Max Blocksize is 256.

Sender                                         Receiver

ENQ SOH
                                                ACK SOH
SOH lenblock filename NUL size_in_ascii nul
                                                ACK STX
STX lenblock data[lenblock]
STX lenblock data[lenblock]
STX lenblock data[lenblock]  {until eof}

BRK SOH
                                                ACK BRK
If more files - goto SOH lenblock etc, else

 EOT SOH
                                                ACK EOT

-----------------------------------------------------------------------------

Ahh The Rosetta Stone.

SOH       = $01
STX       = $02
BRK       = $03
EOT       = $04
ENQ       = $05
ACK       = $06
NAK       = $15
CAN       = $18
CRCNAK    = $43
YGNak     = $47
ZDLE      = $18

Ymodem/Zmodem header block. Ymodem pads it out to 128 bytes with nulls,
Zmodem just sends it as is.

record =
       filename : array[1..max] of char; { must be in lower case! Terminated }
                                        { with a null, and remove paths if  }
                                        { you like, but you don't have to.  }
                                        { if path left in, must use '/', ala}
                                        { unix, not '\' ala dos             }
      separator : byte = $00            { End of filename                   }
      length    : array[1..max] of char { this is optional, and is sent in  }
                                        { ASCII, using decimal digits from  }
                                        { $30..$39                          }
      Separator : byte = $20            { separates the length and the time }
      datetime  : array[1..11] of char  { Date time of the file in unix     }
                                        { style, ie number of seconds since }
                                        { 00:00 1/1/1970. Is sent in OCTAL  }
                                        { ASCII, using digits from $30..$37 }
      separator : byte = $00            { End of datetime                   }
end;


Sealink is a little bit different - but send similar info.

Record =
        Length    : Longint              { length of file in standard Intel   }
                                         { Hi_lo format                       }
         TimeDate  : Longint              { TimeStamp of file, in standard     }
                                         { MSDOS format                       }
        Filename  : array[0..16] of char { filename , terminated with a null  }
        ProgName  : array[0..14] of char { sending programs name.             }
        Ackless   : Boolean              { Can handle overdrive.              }
        Fill      : array[0..86] of char { Nulls                              }
end;

