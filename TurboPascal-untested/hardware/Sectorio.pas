(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0009.PAS
  Description: SECTORIO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:48
*)

{... so there I was, sitting in a bar when a known C Programmer  }
{comes up to me and sniggers "still doing it in Pascal eh?"      }
{"Yup" I replied, and tossed the bartender another hundred.      }
{"Yeah well, when you're ready For a Real language, only C has   }
{all the aces."                                                  }
{I'm a Pascal Programmer.  I don't have to take that.  "Such as?"}
{I hoped he'd bite and he did.                                   }
{"Such as disk sector reading and writing For starters."         }
{"Well I hope you're not bluffin', 'cause here's a trick that    }
{I'll bet you ain't covered."                                    }
{I pulled it out With a swish and laid it on the table.  "Even   }
{provides support For >32M volumes, which the C run-time library }
{manual Forgets to tell you it won't do."                        }
{"Huh?  Where?"                                                  }
{"Right here" I said.  "Just where it says...                    }

Program AbsReadTest;

{This Program demonstrates a C-style absread and absWrite For TP.}
{As is, it reads the boot sector off drive A:, and optionally    }
{Writes it out to the very last sector on drive A: (assumes 1.2Meg}
{This Program IS dangerous, and is released to the public domain.}
{I take no responsibility For use or misuse, deliberate or       }
{accidental, of this Program or any Program which Uses the       }
{techniques described herein.                                    }

{Author: Mitch Davis 3:634/384.6 +61-3-890-2062 v1.0 28-Jun-92.  }

Var bp:Pointer; {Will point to the buffer For the sector data}

Function absread (drive:Char; nsects:Word; lsect:Word; buffer:Pointer):Boolean;

{Works just like the C runtime one- including being restricted to 32M volumes!}

{drive is a Character, nsects is the number of sectors, and lsect is the first}
{sector.  buffer points to the buffer you'd like filled from disk.  Function  }
{returns True if there was an error, or False if all went well.               }

Var kludgebuff:Array [0..$1f] of Byte; {Read Ralf Brown's interrupt listing}
    kludgePtr:Pointer;                 {Int 25h - ES:[BP+1E] may change    }

begin
  kludgePtr := @kludgebuff;
  absread := True;
  if drive < 'A' then Exit;
  if drive > 'Z' then Exit;
  Asm
    push  es
    push  bp
    push  di
    les   di, kludgePtr
    mov   al, drive      { Gets the passed parameter. }
    and   al, 1fh        { Cvt from ASCII to drive num }
    dec   al             { Adjust because A: is drive 0 }
    mov   cx, nsects     { number of sectors to read }
    mov   dx, lsect      { starting at sector.. }
    push  ds
    lds   bx, buffer      { Get the address of the buffer }
    mov   bp, di
    push  si
    int   25h            { Do the drive read. }
    pop   si             { Remove the flags int 25h leaves on stack}
    pop   si
    pop   ds
    pop   di
    pop   bp
    pop   es
    jc    @1
    mov   ah, 0          { No errors, so set Function to False }
    @1:
    mov   @result, ah
  end;
end;

Function absWrite
            (drive:Char; nsects:Word; lsect:Word; buffer:Pointer):Boolean;

{Works just like the C one - including being restricted to 32M volumes!}

{drive is a Character, nsects is the number of sectors, and lsect is the first}
{sector.  buffer points to the buffer you'd like filled from disk.  Function  }
{returns True if there was an error, or False if all went well.               }

Var kludgebuff:Array [0..$1f] of Byte;
    kludgePtr:Pointer;

begin
  kludgePtr := @kludgebuff;
  absWrite := True;
  if drive < 'A' then Exit;
  if drive > 'Z' then Exit;
  Asm
    push  es
    push  bp
    push  di
    les   di, kludgePtr
    mov   al, drive      { Gets the passed parameter. }
    and   al, 1fh        { Cvt from ASCII to drive num }
    dec   al             { Adjust because A: is drive 0 }
    mov   cx, nsects     { number of sectors to Write }
    mov   dx, lsect      { starting at sector.. }
    push  ds
    lds   bx, buffer      { Get the address of the buffer }
    mov   bp, di
    push  si
    int   26h            { Do the drive Write. }
    pop   si             { Remove the flags int 26h leaves on stack}
    pop   si
    pop   ds
    pop   di
    pop   bp
    pop   es
    jc    @1
    mov   ah, 0
    @1:
    mov   @result, ah
  end;
end;

Function absLread (drive:Char; nsects:Word; lsect:LongInt;
buffer:Pointer):Boolean;

{This Function reads sectors on disks which have the >32M style made popular}
{by Compaq Dos 3.31, MS-Dos 4+ and DR-Dos 5+.                               }

Var packet:Array [0..9] of Byte; {disk request packet - see Ralf Brown's ints}

begin
  absLread := True;
  if drive < 'A' then Exit;
  if drive > 'Z' then Exit;
  Asm
    mov   ax, Word ptr lsect     {Get the LSB of the start sector}
    mov   Word ptr packet[0], ax {Store it in the packet         }
    mov   ax, Word ptr lsect + 2 {Get the MSB of the start sector}
    mov   Word ptr packet[2], ax {Store this one too.            }
    mov   ax, nsects             {How many sectors to read       }
    mov   Word ptr packet[4], ax
    {Insert the Pointer to the data buffer into the packet}
    push  bp ; push ds
    lds   dx, buffer      { Get the address of the buffer }
    mov   Word ptr packet[6], dx
    mov   dx, ds
    mov   Word ptr packet[8], dx
    mov   al, drive      { Gets the passed parameter. }
    and   al, 1fh        { Cvt from ASCII to drive num }
    dec   al             { Adjust because A: is drive 0 }
    int   25h            { Do the drive read. }
    pop   si             { Remove the flags int 25h leaves on stack}
    pop   ds
    pop   bp
    jc    @1
    mov   ah, 0
    @1:
    mov   @result, ah
  end;
end;

Function absLWrite (drive:Char; nsects:Word; lsect:LongInt;
buffer:Pointer):Boolean;

{This Function Writes sectors on disks which have the >32M style made popular}
{by Compaq Dos 3.31, MS-Dos 4+ and DR-Dos 5+.                                }

Var packet:Array [0..9] of Byte;

begin
  absLWrite := True;
  if drive < 'A' then Exit;
  if drive > 'Z' then Exit;
  Asm
    mov   ax, Word ptr lsect
    mov   Word ptr packet[0], ax
    mov   ax, Word ptr lsect + 2
    mov   Word ptr packet[2], ax
    mov   ax, nsects
    mov   Word ptr packet[4], ax
    push  bp ; push ds
    lds   dx, buffer
    mov   Word ptr packet[6], dx
    mov   dx, ds
    mov   Word ptr packet[8], dx
    mov   al, drive      { Gets the passed parameter. }
    and   al, 1fh        { Cvt from ASCII to drive num }
    dec   al             { Adjust because A: is drive 0 }
    int   26h            { Do the drive Write. }
    pop   si             { Remove the flags int 26h leaves on stack}
    pop   ds
    pop   bp
    jc    @1
    mov   ah, 0
    @1:
    mov   @result, ah
  end;
end;

Function LongNeeded (drive:Char):Boolean;

{This Function returns True or False depending on whether the long versions}
{of absread/absWrite needed to be invoked; that is, it's a drive Formatted }
{in the Dos 4+ >32M style.                                                 }
{I strongly suggest you see Ralf Brown's interrupt listing For int21h subfs}
{440d and 53 - they'll tell you all you know to understand the guts of this}
{Function.                                                                 }

Label Escape;

Var drivestats:Array [0..31] of Byte;

begin
  LongNeeded := False;
  if drive < 'A' then Exit;
  if drive > 'Z' then Exit;
  Asm
    push ds
    mov  dx, ss
    mov  ds, dx
    lea  dx, drivestats
    mov  bl, drive      { Gets the passed parameter. }
    and  bl, 1fh        { Cvt from ASCII to drive num }
    mov  ax, 440Dh
    mov  cx, 0860h
    int  21h
    jc   Escape
    mov  ax, Word ptr drivestats[0Fh]
    or   ax, ax
    jnz Escape
    mov  @Result, 1
  Escape:
    pop  ds
  end;
end;

begin
  getmem (bp,2048);
  Writeln (LongNeeded ('A'));
  Writeln (LongNeeded ('C'));
  Writeln (absread  ('A',1,0,bp));
(*  Writeln (absWrite ('A',1,2399,bp)); *) {remove the comments at your own}
                                           {risk!!!}
  freemem (bp,2048);
end.

{So I bought him a drink.  The poor guy looked like he needed one....}

