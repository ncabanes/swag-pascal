(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0087.PAS
  Description: Another WAV Player
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  11:02
*)

{$M 16384,0,655360}

uses Dos, CRT, objects;

const SBase = $220;               {Default port base for Sound Blaster.
                                   Change if necessary}
      SIrq  = 5;                  {Default Irq line for Sound Blaster.
                                   Change if necessary}
      SDMA  = 1;                  {Default DMA channel for Sound Blaster.}

type
 TWAVRec = record
             ID: LongInt;
            Len: LongInt;
           end;
 PWAVFmt = ^TWAVFmt;
 TWAVFmt = record
            case word of
             1:( FTag: word;
                 NChan: word;
                 SampR: word;
                 AvgSR: word;
                 BLKAl: word;
                 FMTLen: word;
                 FMTDat: array[0..256] of byte);
             2:( Chunk:Pointer);
           end;
var
 WAVFile: TDosStream;             {WAV file object}
 BlkID: TWAVRec;                  {ID for each block in WAV}
 BlkFmt: PWAVFmt;                 {Block format}
 TotalSz: LongInt;                {Total size of WAV data}
 DSPCmd: byte;
 NumBits: byte;
 SampByte: byte;
 BlockSize: word;
 EOB: boolean;
 DF: String;

procedure NewBlock; interrupt;    {Procedure to set up next block or}
var X:Byte;                       {end playback}
begin

 X := port[SBase+$e];
 port[$20] := $20;
 EOB := true;

end;

procedure PrepareSB;
begin

 SetIntVec(SIrq + 8, @NewBlock);           {Set up service routine}

 asm
  in al,$61                                 {Enable timer 2, but}
  and al,$fc                                {do not turn on sound.}
  or al,1
  out $61,al

  sti

  mov dx,SBase+6                            {DSP (Digital Sound Processor)
                                             reset port}
  mov al,1                                  {Reset command}
  out dx,al

  mov bx,4
  call @9                                   {Wait 4 clocks}

  mov al,0                                  {Normal mode}
  out dx,al

 @3: mov dx,SBase+$e                        {DSP status port}
 @2: in al,dx                               {Read status}
  test al,$80                               {If high bit not set, no data}
  jz @2                                     {ready}

  mov dx,Sbase+$a                           {DSP read port}
  in al,dx                                  {Read status}
  cmp al,$aa                                {AA indicates ready}
  jnz @3
  jmp @4
 @5:
  in al,dx                                  {Wait for response to last byte}
  test al,$80                               {sent}
  jnz @5
  mov al,ah
  out dx,al                                 {Send next byte}
  ret

 @9:
  push bx
  mov al,$b6                                {Write count to timer #3}
  out $43,al

  mov al,0                                  {Low byte of count}
  out $42,al

  mov al,$10                                {High byte count}
  out $42,al

  sub bx,$1000
  neg bx                                    {1000h-clocks=desired count}
 @10:
  mov al,$80                                {Read count from timer}
  out $43,al

  in  al,$42                                {Low byte}
  mov ah,al
  in  al,$42                                {High byte}
  xchg ah,al

  cmp bx,ax                                 {Pause until count reached}
  jl  @10
  pop bx
  ret
 @4:
  mov dx,SBase+$c

  mov ah,$40                                {Set time constant}
  call @5

  mov ah,SampByte                           {Time divisor}
  call @5

 end;

 port[$21] := port[$21] and not (1 shl SIRQ);   {Enable SB interrupt}

end;

procedure ErrorEnd;
begin
 WAVFile.Done;
 Writeln('Error in .WAV');
 Halt(1);
end;

procedure PlaySound(SndLen: longint);

var AbsAddr: LongInt;
    FirstBlk, SecBlk, CurBlk: Pointer;

begin

 EOB := False;

 GetMem(BlkFmt, BlockSize*2);
 FirstBlk := BlkFmt;
 SecBlk := pointer(longint(FirstBlk) + BlockSize);
 CurBlk := FirstBlk;


 WAVFile.Read(BlkFmt^, BlockSize);
 SndLen := SndLen - BlockSize;

 repeat
  AbsAddr := Seg(CurBlk^);
  AbsAddr := AbsAddr * 16 +Ofs(CurBlk^);
  SndLen := SndLen - BlockSize;
  asm
   jmp @4

  @5:
   in al,dx                                 {Wait for response to last byte}
   test al,$80                              {sent}
   jnz @5
   mov al,ah
   out dx,al                                {Send next byte}
   ret

  @4:

   mov bx,1
   mov cx,integer(AbsAddr)
   mov dx,SBase+$c

   mov al,0                                 {Clear byte high/low flip-flop}
   out $c,al

   mov al,$49                               {Set memory read, single transfer,}
   out $b,al                                {channel 1}

   mov al,cl                                {Enter base address}
   out SDMA*2,al
   mov al,ch
   out SDMA*2,al

   mov ax,integer(AbsAddr+2)                {High 4 bits goes to DMA page reg}
   mov dx,$83
   mov cl,SDMA
   sub cl,2
   mov ch,2                                 {Calculate DMA page address}
   shr ch,cl
   xor dl,ch
   out dx,al                                {Send page byte}

   mov ax,BlockSize                         {Set byte count}
{   dec ax   }
   out SDMA*2+1,al
   xchg al,ah
   out SDMA*2+1,al
   push ax

   mov al,SDMA                              {Re-enable DMA channel 1}
   out $a,al

   mov dx,SBase+$c                          {DSP port}

   mov ah,DSPCmd                            {DMA 8-bit transfer}
   call @5

   pop ax                                   {Get transfer again}
   mov bl,al
   call @5
   mov ah,bl
   call @5

  end;

  DSPCmd := DSPCmd and $fe;

  if (CurBlk = FirstBlk) then CurBlk := SecBlk else CurBlk := FirstBlk;
  if SndLen > 0 then WAVFile.Read(CurBlk^, BlockSize);

  while not EOB do
   if Keypressed then ErrorEnd;
  EOB := False;

 until (SndLen<=0);
end;


begin

 DF := ParamStr(1);

 WAVFile.Init(DF, stOpenRead);              {Open WAV file}
 WAVFile.Read(BlkID, SizeOf(TWAVRec));      {Read in first block}

 if BlkID.ID = $46464952 then               {ID of WAV file}
 begin
  TotalSz := BlkID.Len;                     {Get total size}
  repeat
   WAVFile.Read(BlkID, 4);                  {Read in type chunk}
   TotalSz := TotalSz - 4;                  {and update TS}

   if BlkID.ID <> $45564157 then ErrorEnd;  {Must be "WAVE"}
   repeat
    WAVFile.Read(BlkID, SizeOf(TWAVRec));    {Read in format chunk}
    TotalSz := TotalSz - SizeOf(TWavRec);

    if BlkID.ID = $20746d66  then            {"fmt ", set WAV format}
    begin
     getmem(BlkFmt, BlkID.Len);
     WAVFile.Read(BlkFmt^, BlkID.Len);
     TotalSz := TotalSz - BlkID.Len;
     with BlkFmt^ do
     begin
      if FTag = $200 then DSPCmd := $75 else {ADPCM 4-bit compression}
       if FTag = 1 then DSPCmd := $14 else   {Normal}
        ErrorEnd;
      if DSPCmd = $75 then NumBits := 4 else NumBits := 8;
      if NChan = 2 then DSPCmd := DSPCmd + 8; {Stereo}
      SampByte := 256-(1000000 div SampR);   {Sampling rate}
      BlockSize := BlkAl;                    {Size of buffer}
     end;
     freemem(BlkFmt, BlkID.Len);
    end else

    if BlkID.ID = $61746164 then
    begin
     PrepareSB;                              {Perform init stuff}
     TotalSz := TotalSz - BlkID.Len;
     PlaySound(BlkID.Len);
    end else

     ErrorEnd;
   until TotalSz <= 0;
  until TotalSz <= 0;
 end else
  ErrorEnd;
 WAVFile.Done;
 port[$21] := port[$21] or (1 shl SIrq);
end.

