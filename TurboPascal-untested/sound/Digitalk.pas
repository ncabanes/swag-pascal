(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0064.PAS
  Description: DigiTalk
  Author: GERHARD DALENOORT
  Date: 05-26-95  23:01
*)

{
  From: Gerhard Dalenoort                            Read: Yes    Replied: No
}
Program DigiTal; { Real-Mode Only }

{ Timer routines tnx to Unit digital

  InterruptVector   : Array [0..255] of Pointer Absolute $0000 : $0000;

  My Question is this: In DPMI mode were do I have to look
                       for the Interrupt Table ???
                       and How to program DMA ???

   GreetZ,
     Gerhard.
}

Uses Crt;
Const
  fname = 'c:\modplay\sounds\hcaprince.911';  { Can be any raw data File }
  SAMPLERATE = 16000; { about: 3Khz - 44Khz }

  HexTable : Array[0..15] of Char =
        ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

  Counter : Word = 1;
{ SB-DSP Constants }
   BASE       = $220;  { Change this to your card base adres }
   resetport  = Base + $6;
   readport   = Base + $A;
   Writeport  = Base + $C;
   statusport = Base + $E;
   dac_Write  = $10;
   adc_read   = $20;
   speakeron  = $D1;
   speakeroff = $D3;

{ Timer Constants}
  C8253ModeControl   = $43;
  C8253Channel       : Array [0..2] of Byte = ($40, $41, $42);
  C8253OperatingFreq = 1193180;
  C8259Command       = $20;
  TimerInterrupt     = $08;


Var
  OldTimerInterrupt : Pointer;
  InterruptVector   : Array [0..255] of Pointer Absolute $0000 : $0000;
  OK,DonePlaying    : Boolean;
  Sound             : Pointer;
  Size,
  SegSound, OfsSound: Word;
  Mbyte             : byte;

Procedure spk_on;
begin
   Repeat Until port[Writeport] < $80;
   port[Writeport] := $D1;
end;

Procedure spk_off;
begin
   Repeat Until port[Writeport] < $80;
   port[Writeport] := $D3;
end;

Function resetDSP : Boolean;
(*----------------------------------------------------------
 Not Mine...
 The Book says:
 - Write a 1 to ResetPort $2x6,
 - Wait 3 MicroSec. (µs)
 - Write a 0 to ResetPort $2x6
 - Wait until ready byte $0AA at DataPort $2xA
   (it is advisable to check first for a data avaible: Port $22E bit 7 set)
   Typically the DSP takes about 100 microsecs. to reset.

   Mine looks like this in pseudo code:
     Port[$226]:=1;
     Asm nop; nop; nop; End; { Consume time }
     Port[$226]:=0;
     I:=0; { Longint }
     Repeat Inc(I) until (I>123000) or (Port[$22A]=$0AA);
     ResetDSP:=(I<32000);
-------------------------------------------------------------- *)

Var
   count, bdum : Byte;
begin
   resetDSP := False;
   port[resetport] := 1;
   For count := 1 to 6 do bdum := port[statusport];
   port[resetport] := 0;
   For count := 1 to 6 do bdum := port[statusport];
   Repeat Until port[statusport] > $80;
   if port[readport] = $AA then resetDSP := True;
end;


Procedure generic(reg,cmd:Integer; data:Byte);
      { ?? not used here, what does it do ?? }
begin
   Repeat Until port[Writeport] < $80;
   port[reg] := cmd;
   Repeat Until port[Writeport] < $80;
   port[reg] := data;
end;


fUNCtION hEX( tHEvAR:wORD):sTRING; { See what the it looks like in HEX }
vAR
 bUF    : sTRING;
 w      : wORD;
bEGIN
 w := tHEvAR;
 bUF:=      hEXtABLE[ hI(w) sHR  4];
 bUF:=bUF + hEXtABLE[ hI(w) mOD 16];
 bUF:=bUF + hEXtABLE[ lO(w) sHR  4];
 bUF:=bUF + hEXtABLE[ lO(w) mOD 16];;
 hEX:=bUF;
eND;



{=[ 8253 Timer Programming Routines ]=====================================}
Procedure Set8253Channel(ChannelNumber : Byte; ProgramValue : Word);
begin
  Port[C8253ModeControl] := 54 or (ChannelNumber SHL 6); { XX110110 }
  Port[C8253Channel[ChannelNumber]] := Lo(ProgramValue);
  Port[C8253Channel[ChannelNumber]] := Hi(ProgramValue);
end;



{-[ Set Timer Interupt Vector To Default Handler ]------------------------}
Procedure SetTimerInterruptVectorDefault;
begin
  aSM cli END;
  InterruptVector[TimerInterrupt] := OldTimerInterrupt;
  aSM sti END;
end;


{-[ Set Clock Channel 0 Back To 18.2 Default Value ]----------------------}
Procedure SetDefaultTimerSpeed;
begin
  Set8253Channel (0, 0);
end;




{=[ MUST CALL BEFORE ExitING Program!!! ]=================================}
Procedure CleanUp;
begin
  SetDefaultTimerSpeed;
  SetTimerInterruptVectorDefault;
end;




{-[ Set Clock Channel 0 (INT 8, IRQ 0) To Input Speed ]-------------------}
Procedure SetPlaySpeed(Speed : LongInt);
Var ProgramValue : Word;
begin
  if Speed > 33000 then Speed:=33000;
  ProgramValue := C8253OperatingFreq div Speed;
  Set8253Channel(0, ProgramValue);
end;


Procedure PlayData; Interrupt;
var DATA : Byte;
begin
  if Not(DonePlaying) Then
  begin
    if Counter <= Size Then
    begin
      Data:=(Mem[SegSound:OfsSound+Counter] {SHR 2} ); { SHR = Volume down }
      Inc(Counter);

{     Port[$22C]:=$10;      NextByte is realtime sample Data
      Port[$22C]:=Data;     Sample Data
                 The next ASM is the same as these
                 two port Writes to the DSP, Maybe just faster.
}       Asm
          mov  dx,$22C
          in   al,dx
          mov  al,10h
          out  dx,al
          in   al,dx
          mov  al,data
          out  dx,al
        end;
    end else { Counter > Size }
    begin
      DonePlaying := True;
      Counter     := 1;
    end;
  end;

  Port[C8259Command] := $20; { Enable Interupts }
end;




{---------------------- LoadRawSampleData --------------------}
Function loadFile(Var buffer:Pointer; Filename:String) : Word;
Var
   fromf : File;
   size : LongInt;
   errcode : Integer;
begin
   assign(fromf,Filename);
   reset(fromf,1);
   errcode := ioresult;
   if errcode = 0 then
   begin
      size := Filesize(fromf);
      {Writeln(size);}
      getmem(buffer,size);
      blockread(fromf,buffer^,size);
   end
   else size := 0;
   loadFile := size;
   close(fromf);
end;



Procedure unload(buffer:Pointer; size:Word);
begin freemem(buffer,size); end;



Var I    : Integer;
    Ch   : Char;
Begin
 Clrscr;
 DonePlaying:=True;
 Size := LoadFile(Sound,Fname);
 SegSound:=Seg(Sound^);          { Get SegMent and Ofset of sample }
 OfsSound:=Ofs(Sound^);

 OK:=ResetDSP;                   { Reset DSP (soundCard) }
 if Not OK then begin Write(#7,'No card ?');Halt(1);end; { NO CARD DETECTED }
 Spk_on;

 SetPlaySpeed(SAMPLERATE);       { Set Herz Timer for Interrupt $8 }
 ASM cli END;                    { Point Interrupt $8 to My procedure }
  OldTimerInterrupt := InterruptVector[TimerInterrupt];
  InterruptVector[TimerInterrupt] := @PlayData;
 ASM sti END;

 GotoXY(10,10);
 Writeln('Testin: ',Counter:5);
 WriteLn(#13#10,' We Still got: ',MaxAvail,' Memory, load more samples,');
 WriteLn(' That would be ',MaxAvail div 64000,' samples of 64000 bytes
(MaxSampleSize) '); WriteLn(' and ',MaxAvail mod 64000,' bytes of memory,
enough ? ...nah.'); WriteLn(' Sample loaded is ',Size,' Bytes already');
 WriteLn(#13#10' O jeah, press space to play the sample, <Esc> to Quit ');

 repeat
   IF Port[$60]=57 then { SpaceBar is pressed ? }
     begin
       Delay(1);                    { Won't slow the playing }
       GotoXY(10,10);               { Won't slow the playing }
       Write('Testin: ',Counter:5); { Won't slow the playing }
       if DonEplaying then  { it means the sample is played }
            Begin              { Loop Mode }
              Counter:=1;      { First set the counter to 1, the interrupt }
              DonePlaying:=False; { plays as soon as DonePlaying = false }
            end;
     end else                  { if not spacebar is down }
     begin                     { Stop playing and reset the counter }
       DonePlaying:=True;
       counter:=1;
     end;
     if Keypressed Then Ch:=ReaDkEY; { The port doesn't read the key }
 Until Ch=#27;

 CleanUp; { Set the interrupt to original etc. }
 Unload(Sound,Size);  { Free Sample Memory }
 Spk_off; { DAC to output off }
 ClrScr;
end.

