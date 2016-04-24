(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0073.PAS
  Description: DMA Transfers with Sound Blaster
  Author: IAN ASH
  Date: 05-26-95  23:27
*)

{                                SBLASTER.PAS                            }
{ A small unit demonstrating DMA transfers to and from the Sound Blaster }
{ as well as simple double buffering techniques.                         }
{               Programmed by Ian Ash of Arcturus.                       }
Unit SBlaster;

interface
uses Crt, Dos;

  Procedure InitSB(rate : Word);
  Procedure SBPlay(segm, ofst, lgth : Word);
  Procedure SBRecord(segm, ofst, Lgth : Word);
  Procedure SetInterrupt(Intrrpt : Pointer);
  Procedure Record2Disk(var buf; name : String);

type
  InfoType = Array[1..1] Of Byte;
var
  samplerate : Byte;
  CurrentInterrupt : Pointer;
  FileIDByte : Array[1..2] Of Char;
  EndOfTransfer : Boolean;
const
  BasePort = $220;
  DSPReset = BasePort + $06;
  DSPRead = BasePort + $0A;
  DSPWrite = BasePort + $0C;
  DSPDataAvail = BasePort + $0E;
  IRQ2 = $0A;
  IRQ3 = $0B;
  IRQ5 = $0D;
  IRQ7 = $0F;

implementation
{ Simple interrupt handler for use. It acknowledges the end of transfer }
{ and then sets a flag EndOfTransfer to indicate the transfer end.      }
Procedure HandleInterrupt; interrupt;
var
  Info : Byte;
begin
  Info := Port[DSPDataAvail];
  Port[$21] := Port[$21] XOR 129;
  EndOfTransfer := True;
  Port[$20] := $20;
end;

Procedure InitSB(rate : Word);  { Initializes SoundBlaster And Sets The }
var                             { Sampling Rate To rate Which Is Given In }
  ActRate : LongInt;            { Hertz. }
  Count : Byte;
  InitComplete : Byte;
begin
  CurrentInterrupt := @HandleInterrupt;
  sampleRate := 256 - (1000000 div rate);
  Port[DSPReset] := 1;
  Delay(5);
  Port[DSPReset] := 0;
  Count := 0;
  If (Port[DSPDataAvail] And 128) = 128 Then
  repeat
    InitComplete := Port[DSPRead];
    Count := Count + 1;
  until (InitComplete = $AA) Or (Count > 150);
  FileIDByte[1] := 'I'; FileIDByte[2] := 'A';
end;

{ Plays a digitised sound clip. 'segm' and 'ofst' is the segment and }
{ offset where the data is stored and Lgth is the length in bytes of }
{ the sound clip. Note that this routine can only play a sound clip  }
{ of maximum size 64K.                                               }
Procedure SBPlay(segm, ofst, Lgth : Word);
var
  page : Byte;
  offset : Word;
  count : word;
  InitComplete : Byte;
  OldInt : Pointer;
begin
  SetIntVec(IRQ5, @HandleInterrupt);
  Port[$21] := Port[$21] XOR 129;
  page := Hi(segm) div $10;
  offset := (segm shl 4) + ofst;
  Port[$0A] := $05;
  Port[$0C] := $00;
  Port[$0B] := $49;
  Port[$02] := Lo(offset);
  Port[$02] := Hi(offset);
  Port[$83] := page;
  Port[$03] := lo(lgth);
  Port[$03] := hi(lgth);
  Port[$0A] := 1;
  Port[DSPWrite] := $D1;
  Port[DSPWrite] := $40;
  Port[DSPWrite] := samplerate;
  repeat until (Port[DSPWrite]  And 128) = 0;
  Port[DSPWrite] := $14;
  Delay(1);
  Port[DSPWrite] := lo(lgth);
  repeat until (Port[DSPWrite]  And 128) = 0;
  Port[DSPWrite] := hi(lgth);
end;

{ Records a sound clip to data location whose segment:offset is specified }
{ in 'segm' and 'ofst' respectively. 'lgth' is the number of bytes to be  }
{ recorded.                                                               }
Procedure SBRecord(segm, ofst, lgth : Word);
var
  page : Byte;
  offset : Word;
  OldInt : Pointer;
begin
  SetIntVec(IRQ5, @HandleInterrupt);
  Port[$21] := Port[$21] XOR 129;
  page := Hi(segm) div $10;
  offset := (segm shl 4) + ofst;
  Port[$0A] := $05;
  Port[$0C] := $00;
  Port[$0B] := $45;
  Port[$02] := Lo(offset);
  Port[$02] := Hi(offset);
  Port[$83] := page;
  Port[$03] := lo(lgth);
  Port[$03] := hi(lgth);
  Port[$0A] := 1;
  Delay(10);
  Port[DSPWrite] := $40;
  repeat until (Port[DSPWrite]  And 128) = 0;
  Port[DSPWrite] := samplerate;
  repeat until (Port[DSPWrite]  And 128) = 0;
  Port[DSPWrite] := $24;
  Delay(1);
  Port[DSPWrite] := lo(lgth);
  Delay(1);
  Port[DSPWrite] := hi(lgth);
end;

Procedure SetInterrupt(Intrrpt : Pointer);
begin
  CurrentInterrupt := Intrrpt;
end;

{ Records a digital sound to disk. buf is a data area to be used as a  }
{ buffer and must be 64K in size (a whole segment!!). name is the name }
{ of the DOS file to store the info in.                                }
Procedure Record2Disk(var buf; name : String);
type
  DataType = Array[1..1] Of Byte;
var
  f : File;
  Data : DataType absolute buf;
  WorkArea : Word;
  ch : Char;
begin
  Assign(f, name);
  Rewrite(f, 1);
  BlockWrite(f, FileIDByte, 2);
  FileIDByte[1] := Chr(samplerate);
  BlockWrite(f, FileIDByte, 1);
  FileIDByte[1] := 'I';
  ch := ReadKey;
  SetInterrupt(@handleInterrupt);
  EndOfTransfer := False;
  WorkArea := 1;
  SBRecord(Seg(Data[WorkArea]), Ofs(Data[WorkArea]), 30000);
  repeat
    repeat until EndOfTransfer;
    WorkArea := 30500;
    EndOfTransfer := False;
    SBRecord(Seg(Data[WorkArea]), Ofs(Data[WorkArea]), 30000);
    BlockWrite(f, Data[1], 30000);
    repeat until EndOfTransfer;
    WorkArea := 1;
    EndOfTransfer := False;
    SBRecord(Seg(Data[WorkArea]), Ofs(Data[WorkArea]), 30000);
    BlockWrite(f, Data[WorkArea + 30499], 30000);
  until KeyPressed;
  Close(f);
end;
end.

