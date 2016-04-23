{
As I promised, here is the other reply that I am sending you containing the
information on Programming the SB via CT-VOICE.DRV.

Before I begin, This message may be a little long, so if for any reason, you
loose the end of it or sumthin', let me know, and I'll repost it split up
into sections, but right now I'll just make one long message.

O.K. Here we go...
The information supplied will concern playback and recording of digital
samples on the SB's digital channel(s) using the driver supplied by
Creative Labs, CT-VOICE.DRV.

There should be a lot of information available on BBS's if you look for it
and want to follow up anything, but for the meaan time, this information
is taken from a book called "The Sound Blaster Book" by Axel Stolz,
published by Abacus ISBN 1-55755-164-2.

Let me first correct myself about the comment that the driver is executed
as an interrupt... Similar, but not quite... You don't actually make and
interrupt call (i.e: INT n), but rather make the actual call to the address
that the driver was loaded into (i.e: CALL n).

The first thing you need to do is load the driver into memory.  Note, the
segment may be anywhere (you store the pointer as a reference), but the
offset MUST be zero.  The loading is done as follows...
1.) Allocate memory and get pointer to the block.
2.) Load the driver from disk into the allocated space.
Note: I am not going into much detail regarding error checking, but you
should do checking on things such as allocation being ok and not NULL, and
see whether the file exists on the disk, and whether or not it is a valid
driver (this can be done by checking to see that the letters "CT" are
contained in bytes 3 and 4).

The code is as follows (in Pascal):
(Please forgive any minor discrepencies, as I am not a Pascal programmer,
 but a C programmer, and I'm only trying to extract those sections that seem
 inportant, so I may not know which functions are Pascal's and which are
 user defined, but you should get the general idea. )
}
VAR
   F : File;
   PtrToDrv : Pointer;

BEGIN
   Assign( F, 'CT-VOICE.DRV' );
   Reset( F, 1 );
   AllocateMem( PtrToDrv, FileSize(F) );
   Blockread( F, PtrToDrv^, FileSize(F) );
   Close( F );
END;
{
NOTE: The varible PtrToDrv should be global, as you will be needing it to
reference the memory at a later stage.

Now that you have the driver loaded, you can start to make function calls
to it.  This is done by setting the register BX to the number of the
function that you want to execute, and various other memory registers to
the parameters, and then calling the address stored in the "PtrToDrv"
varible.  Return values are usually stored in the register AX.

EXAMPLE: Function 6: Play a sample:
-------- Input registers:  BX = Function number
                           ES:DI = Pointer to sample
         Return registers: None.
}
PROCEDURE PlaySample( BufferAddr : Pointer );
VAR
   VSeg, VOfs : WORD;
BEGIN
   VSeg := Seg( BufferAddr^ );
   VOfs := Ofs( BufferAddr^ );
   ASM
      MOV   BX, 6
      MOV   ES, VSeg
      MOV   Di, VOfs
      CALL  PtrToDrv
   END;
END;

{
The following are a list of all the function available from the CT-VOICE.DRV
driver.  Note, you will call them by setting BX = function number, setting
the other registers, and then executing "CALL PtrToDrv":

----------------------------------------------------------------------------
#: Description:                  Parameters:
-- -------------------------     -------------------------------------------
0  Determain driver version      AH=Main number (on return)
                                 AL=Sub number (on return)

1  Set port address              AX=Port address

2  Set interrupt                 AX=Interrupt number

3  Initialize driver             AX=0 Successfull (on return)
                                 AX=1 SB not found (on return)
                                 AX=2 Port address error (on return)
                                 AX=3 Interrupt error (on return)

4  Loudspeaker on/off            AL=0 off
                                 AL=1 on

5  Set "StatusWord" address      ES:DI=Status address
                                 (The WORD varible at this address will store
                                  the status of the playback so that you can
                                  monitor the playback of the sample.)

6  Sample playback               ES:DI=Sample address

7  Record sample                 AX=Sampling rate
                                 DX:CX=Length
                                 ES:DI=Sample address

8  Abort sample                  none

9  De-Install driver             none
                              
10 Pause Sample                  AX=0 Successfull (on return)
                                 AX=1 Not successfull (on return)

11 Continue sample               AX=0 Successfull (on return)
                                 AX=1 Not successfull (on return)

12 Interrupt loop                AX=0 At end of loop
                                 AX=1 Immediately
                                 AX=0 Successfull (on return)
                                 AX=1 No loop being executed

13 User defined driver function  DX:AX=Function address
                                 ES:BX=Address of the current data block
}
