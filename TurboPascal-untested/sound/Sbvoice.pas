(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0009.PAS
  Description: SBVOICE.PAS
  Author: AMIT MATHUR
  Date: 05-28-93  13:57
*)

{---------------------------------------------------------------------------
                   Unit SBVoice (v1.10) For Turbo Pascal 6.0
       For interfacing With the SoundBlaster's digitized voice channel.
           Copyright (c) 1991, Amit K. Mathur, Windsor, Ontario.

                        By: Amit K. Mathur
                            3215 St. Patrick's Drive
                            Windsor, Ontario
                            N9E 3H2 CANADA
                        Ph: (519) 966-6924

 Networks:  RIME(tm) R/O ->WinDSor, ILink (Shareware), NA-Net (Gaming),
            WWIVNet (#198@5950), or direct on NorthSTAR (519)735-1504.

 These routines are released to the public domain.  However I will gladly
 accept contributions towards further development of this and other products.
 Please send any changes or improvements my way.  and I'm interested in
 other SoundBlaster utilities and Programming tools.  Thanks in advance.
 --------------------------------------------------------------------------}

{$O+,F+}
{ Allow this Unit to Be Overlayed (doesn't affect Compilation if you decide
  not to overlay it), and Force Far calls.                                 }

Unit SBVoice;

Interface

Uses MemAlloc;                                    { Memory Allocation Proc }

Var
{$ifNDEF NoSBVoiceArray}                          { to use your own        }
     SoundFile: Array[1..64000] of Byte;          { whatever size you want }
{$endif}
     sgSBDriver, ofSBDriver: Word;                { seg and ofs of Driver  }
     SBDriver: Pointer;                           { Pointer to the driver  }
     StatusWord: Word;                            { stores SB status       }
     SBFound: Boolean;                            { whether Init worked    }

Procedure loaddriver(fi:String);
{ Loads CT-VOICE.DRV into memory.  'fi' is the path to the driver.         }

Procedure closedriver;
{ Clean up routine.  not Really necessary if your Program is over.         }

Procedure loadvoice(f:String;start,size:Word);
{ Load 'f' into memory.  Start is the start of the area within
  'f' to load and size is the amount to laod.  if you set size to 0
  then it will load the entire File.                                      }

Function sb_getversion:Integer;
{ Get the version number of the CT-VOICE.DRV
  Returns the Version number                                              }

Function sb_init:Integer;
{ Initialize the SoundBlaster.  Call this right after load driver, unless
  you have to change the BaseIOAddress or Interrupt number and haven't
  changed the CT-VOICE.DRV File itself.
  Returns:  0 - no problem
            1 - Sound card failiure
            2 - I/O failiure
            3 - DMA interrupt failiure                                    }

Procedure sb_output(sg,os:Word);
{ Output the digitized Sound.  You must load the Sound first!
  sg and os are the segment and offset of either SoundFile or whatever
  Array you use to store the Sound.  if you use a .VOC File then call
  With 26 added to the offset.                                            }

Procedure sb_setstatusWord(sg,os:Word);
{ Sets the location of the status Word.  This is the third thing you should
  do, after loading the driver and initializing it.
  The StatusWord will contain $0FFFF if input/output is in output, and
  0 when it's done.  It will also hold the values of the markers in voice
  Files if any are encounterred, allowing you to coordinate output with
  your Programs.                                                          }

Procedure sb_speaker(mode:Word);
{ Set the speaker on/off.  off is mode 0, and On is anything else.  This
  is the fourth thing you should do in your initialization.               }

Procedure sb_uninstall;
{ Uninstall the driver from memory.   Used by CloseDriver.                }

Procedure sb_setIOaddress(add:Word);
{ Override the IOaddress found inside the CT-VOICE.DRV File.  Add is the
  new IO address.                                                         }

Procedure sb_setinterruptnumber(intno:Word);
{ Allows you to override the Interrupt number in the driver.  IntNo is your
  new interrupt number (3, 5, 7 or 9).                                    }

Procedure sb_stopoutput;
{ Stops the output in progress                                            }

Function sb_pauseoutput: Integer;
{ PaUses the output in progress.
  Returns:  0 - success
            1 - fail                                                      }

Function sb_continueoutput: Integer;
{ Continues a paused output.
  Returns:  0 - success
            1 - fail (nothing to continue)                                }

Function sb_breakloop(mode:Word): Integer;
{ Breaks out of the currect output loop.
  Modes:  0 - continue round, stop when done
          1 - stop immediately
  Returns:  0 - success
            1 - not in loop                                               }

Procedure sb_input(highlength,lowlength,seginputbuff,ofsinputbuff:Word);
{ Input digitized Sound.
  HighLength: The high Byte of the length of the input buffer.
  LowLength:  The low Byte of the length of the input buffer.
  SegInputBuff: The Segment of the start of the input buffer.
  ofsInputBuff: The offset of the start of the input buffer.              }

Procedure sb_setuserFunction(segaddress,ofsaddress:Word);
{ Sets up a user Function that the SB calls when it encounters a new data
  block.  It must perForm a Far ret, preserve DS,DI,SI and flag register.
  Clear Carry flag if you want the driver to process the block, or set it
  if your routine will.  It must be clear if the block Type is 0, that
  is the terminate block.
  SegAddress is the segment of your user Function in memory.
  ofsAddress is the ofset of your user Function in memory.                }

Implementation

Uses Dos;

Procedure Abort(s:String);
begin
  Writeln('The Following Error Has Occurred: ',s);
  Writeln('Remedy and try again.  We apologize For any inconvenience.');
  halt(1);
end;

Procedure loaddriver(fi:String);
Var f: File;
    k: Integer;
    t: String[8];
begin
    assign(f,fi+'CT-VOICE.DRV');
    {$I-} Reset(f,1); {$I+}
    if Ioresult <> 0 then
        Abort('Cannot Open '+fi+'CT-VOICE.DRV');
    blockread(f,Mem[sgSBDriver:ofSBDriver],Filesize(f));
    close(f);
    t:='';
    For k:=0 to 7 do
        t:=t+chr(Mem[sgSBDriver:ofSBDriver+k+3]);
    if t<>'CT-VOICE' then
        abort('Invalid CT-VOICE Driver!');
end;

Procedure closedriver;
begin
    sb_uninstall;
    if dalloc(sbdriver)=0 then
        abort('Uninstall Error!');
end;

Procedure loadvoice(f:String;start,size:Word);
Var fi: File;
    k: Word;
begin
    assign(fi,f);
    {$I-} Reset(fi,1); {$I+}
    if Ioresult <> 0 then
       abort('Cannot Open '+f+'!');
    k:=0;
    seek(fi,start);
    if size=0 then size:=Filesize(fi);
    blockread(fi,Mem[seg(SoundFile):ofs(SoundFile)],size);
    close(fi);
end;

Function sb_getversion: Integer; Assembler;
Asm
   push  bp
   mov   bx,0
   call  SBDriver
   pop   bp
end;

Procedure sb_setIOaddress(add:Word); Assembler;
Asm
   push  bp
   mov   bx,1
   mov   ax,add
   call  SBDriver
   pop   bp
end;

Procedure sb_setinterruptnumber(intno:Word); Assembler;
Asm
   push  bp
   mov   bx,2
   mov   ax,intno
   call  SBDriver
   pop   bp
end;

Procedure sb_stopoutput; Assembler;
Asm
   push  bp
   mov   bx,8
   call  SBDriver
   pop   bp
end;

Function sb_init: Integer; Assembler;
Asm
   push  bp
   mov   bx, 3
   call  SBDriver
   pop   bp
end;

Function sb_pauseoutput: Integer; Assembler;
Asm
   push  bp
   mov   bx,10
   call  SBDriver
   pop   bp
end;

Function sb_continueoutput: Integer; Assembler;
Asm
   push  bp
   mov   bx,11
   call  SBDriver
   pop   bp
end;

Function sb_breakloop(mode:Word): Integer; Assembler;
Asm
   push  bp
   mov   bx,12
   mov   ax,mode
   call  SBDriver
   pop   bp
end;

Procedure sb_output(sg,os:Word); Assembler;
Asm
    push bp
    push di
    mov  bx,6
    mov  di,os             { offset of voice  }
    mov  es,sg             { segment of voice }
    call SBDriver
    pop  di
    pop  bp
end;

Procedure sb_input(highlength,lowlength,seginputbuff,ofsinputbuff:Word);
Assembler;
Asm
    push bp
    push di
    mov  bx,7
    mov  dx,highlength
    mov  cx,lowlength
    mov  es,seginputbuff
    mov  di,ofsinputbuff
    call SBDriver
    pop  di
    pop  bp
end;

Procedure sb_setstatusWord(sg,os:Word); Assembler;
Asm
    push bp
    push di
    mov  bx,5
    mov  di,os
    mov  es,sg
    call SBDriver
    pop  di
    pop  bp
end;

Procedure sb_speaker(mode:Word); Assembler;
Asm
   push  bp
   mov   bx,4
   mov   ax,mode
   call  SBDriver
   pop   bp
end;

Procedure sb_uninstall; Assembler;
Asm
   push  bp
   mov   bx,9
   call  SBDriver
   pop   bp
end;

Procedure sb_setuserFunction(segaddress,ofsaddress:Word); Assembler;
Asm
   push  bp
   mov   dx,segaddress
   mov   ax,ofsaddress
   mov   bx,13
   call  SBDriver
   pop   bp
end;


begin {set up SB}

  if DosMemAvail < 5000 then                           { lower the heap   }
      abort('not Enough Memory');                      { With $M to fix   }
  StatusWord:=MAlloc(SBDriver,5000);
  if StatusWord<>0 then
      abort('Memory Allocation Error');

  sgSBDriver:=MemW[seg(SBDriver):ofs(SBDriver)+2];
  ofSBDriver:=MemW[seg(SBDriver):ofs(SBDriver)];

  Loaddriver('');                                      { change at will   }
  if sb_init<>0 then                                   { or stick in your }
      SBFound:=False                                   { own Program init }
  else
      SBFound:=True;

  if SBFound then begin
      sb_setstatusWord(seg(statusWord),ofs(statusWord));
      sb_speaker(1);                                   { turn SB on       }
  end;
end.


{There's the Unit For .VOC playing.}

