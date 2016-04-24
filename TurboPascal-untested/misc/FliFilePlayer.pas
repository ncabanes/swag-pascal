(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0004.PAS
  Description: FLI File player
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:51
*)

{$G+}

Program FliPlayer;

{  v1.1 made by Thaco   }
{ (c) EPOS, August 1992 }


Const
  CLOCK_HZ              =4608;                   { Frequency of clock }
  MONItoR_HZ            =70;                     { Frequency of monitor }
  CLOCK_SCALE           =CLOCK_HZ div MONItoR_HZ;

  BUFFERSIZE            =$FFFE;                  { Size of the framebuffer, must be an even number }
  CDATA                 =$040;                   { Port number of timer 0 }
  CMODE                 =$043;                   { Port number of timers control Word }
  CO80                  =$3;                     { Number For standard Text mode }
  KEYBOARD              =28;                     { Numbers returned by PorT[$64] indicating what hardware caused inT 09/the - }
  MOUSE                 =60;                     { - number on PorT[$60] }
  MCGA                  =$13;                    { Number For MCGA mode }
  MCGACheck:Boolean     =True;                   { Variable For MCGA checking }
  UseXMS:Boolean        =True;                   { Variable For XMS usage }
  XMSError:Byte         =0;                      { Variable indicating the errornumber returned from the last XMS operation }

Type
  EMMStructure          =Record
                           BytestoMoveLo,              { Low Word of Bytes to move. NB: Must be even! }
                           BytestoMoveHi,              { High Word of Bytes to move }
                           SourceHandle,               { Handle number of source (SH=0 => conventional memory) }
                           SourceoffsetLo,             { Low Word of source offset, or ofS if SH=0 }
                           SourceoffsetHi,             { High Word of source offset, or SEG if SH=0 }
                           DestinationHandle,          { Handle number of destination (DH=0 => conventional memory) }
                           DestinationoffsetLo,        { Low Word of destination offset, or ofS if DH=0 }
                           DestinationoffsetHi  :Word; { High Word of destination offset, or SEG if DH=0 }
                         end;
  HeaderType            =Array[0..128] of Byte;  { A bufferType used to read all kinds of headers }


Var
  Key,                                           { Variable used to check if a key has been pressed }
  OldKey                :Byte;                   { Variable used to check if a key has been pressed }
  XMSRecord             :EMMStructure;           { Variable For passing values to the XMS routine }
  InputFile             :File;                   { Variable For the incomming .FLI File }
  Header                :HeaderType;             { Buffer used to read all kinds of headers }
  Counter,                                       { General purpose counter }
  Speed                 :Integer;                { Timedifference in video tics from one frame to the next }
  FileCounter,                                   { Variable telling the point to read from in the File stored in XMS }
  FileSize,                                      { Size of the .FLI-File }
  FrameSize,                                     { Variable indicating the datasize of current frame }
  NextTime,                                      { Variable saying when it is time to move on to the next frame }
  TimeCounter,                                   { Holding the current time in video tics }
  SecondPos             :LongInt;                { Number of Bytes to skip from the start of the .FLI File when starting - }
                                                 { - from the beginning again }
  Buffer,                                        { Pointer to the Framebuffer }
  XMSEntryPoint         :Pointer;                { Entry point of the XMS routine in memory }
  SpeedString           :String[2];              { String used to parse the -sNN command }
  FileName              :String[13];             { String holding the name of the .FLI-File }
  BufferHandle,                                  { Handle number returned from the XMS routine }
  BytesRead,                                     { Variable telling the numbers of Bytes read from the .FLI File }
  FrameNumber,                                   { Number of the current frame }
  Frames,                                        { total number of frames }
  Chunks                :Word;                   { total number of chunks in a frame }


Function UpCaseString(Streng:String):String;
{ takes a String and convert all letters to upperCase }
Var
  DummyString           :String;
  Counter               :Integer;
begin
  DummyString:='';
  For Counter:=1 to Length(Streng) do
    DummyString:=DummyString+UpCase(Streng[Counter]);
  UpCaseString:=DummyString;
end;


Procedure InitMode(Mode:Word); Assembler;
{ Uses BIOS interrupts to set a videomode }
Asm
  mov  ax,Mode
  int  10h
end;


Function ModeSupport(Mode:Word):Boolean; Assembler;
{ Uses BIOS interrupts to check if a videomode is supported }
Label Exit, Last_Modes, No_Support, Supported;
Var
  DisplayInfo           :Array[1..64] of Byte;   { Array For storing Functionality/state inFormation }
Asm
  push es

  mov  ah,1Bh                                    { the Functionality/state inFormation request at int 10h }
  mov  bx,0                                      { 0 = return Functionality/state inFormation }
  push ds                                        { push DS on the stack and pop it into ES so ES:DI could be used to - }
  pop  es                                        { - address DisplayInfo, as demanded of the interrupt Function }
  mov  di,offset DisplayInfo
  int  10h

  les  di,[dWord ptr es:di]                      { The first dWord in the buffer For state inFormation is the address - }
                                                 { - of static funtionality table }
  mov  cx,Mode                                   { Can only check For the 0h-13h modes }
  cmp  cx,13h
  ja   No_Support                                { Return 'no support' For modes > 13h }

  mov  ax,1                                      { Shift the right Byte the right - }
                                                 { - times and test For the right - }
  cmp  cx,10h                                    { - bit For knowing if the       - }
  jae  Last_Modes                                { - videomode is supported       - }
                                                 { -                                }
  shl  ax,cl                                     { -                                }
  test ax,[Word ptr es:di+0]                     { -                                }
  jz   No_Support                                { -                                }
  jmp  Supported                                 { -                                }
                                                 { -                                }
Last_Modes:                                      { -                                }
  sub  cx,10h                                    { -                                }
  shl  ax,cl                                     { -                                }
  test al,[Byte ptr es:di+2]                     { -                                }
  jz   No_Support                                { -                                }

Supported:
  mov  al,1                                      { AL=1 makes the Function return True }
  jmp  Exit

No_Support:
  mov  al,0                                      { AL=0 makes the Function return True }

Exit:
  pop  es
end;


Function NoXMS:Boolean; Assembler;
{ checks out if there is a XMS driver installed, and in Case it initialize the
  XMSEntryPoint Variable }
Label JumpOver;
Asm
  push es

  mov  ax,4300h                                  { AX = 4300h => inSTALLATION CHECK }
  int  2Fh                                       { use int 2Fh Extended MEMorY SPECifICATION (XMS) }
  mov  bl,1                                      { use BL as a flag to indicate success }
  cmp  al,80h                                    { is a XMS driver installed? }
  jne  JumpOver
  mov  ax,4310h                                  { AX = 4310h => GET DRIVER ADDRESS }
  int  2Fh
  mov  [Word ptr XMSEntryPoint+0],BX             { initialize low Word of XMSEntryPoint }
  mov  [Word ptr XMSEntryPoint+2],ES             { initialize high Word of XMSEntryPoint }
  mov  bl,0                                      { indicate success }
JumpOver:
  mov  al,bl                                     { make the Function return True (AH=1) or False (AH=0) }

  pop  es
end;


Function XMSMaxAvail:Word; Assembler;
{ returns size of largest contiguous block of XMS in kilo (1024) Bytes }
Label JumpOver;
Asm
  mov  ah,08h                                    { 'Query free Extended memory' Function }
  mov  XMSError,0                                { clear error Variable }
  call [dWord ptr XMSEntryPoint]
  or   ax,ax                                     { check For error }
  jnz  JumpOver
  mov  XMSError,bl                               { errornumber stored in BL }
JumpOver:                                        { AX=largest contiguous block of XMS }
end;


Function XMSGetMem(SizeInKB:Word):Word; Assembler;
{ allocates specified numbers of kilo (1024) Bytes of XMS and return a handle
  to this XMS block }
Label JumpOver;
Asm
  mov  ah,09h                                    { 'Allocate Extended memory block' Function }
  mov  dx,SizeInKB                               { number of KB requested }
  mov  XMSError,0                                { clear error Variable }
  call [dWord ptr XMSEntryPoint]
  or   ax,ax                                     { check For error }
  jnz  JumpOver
  mov  XMSError,bl                               { errornumber stored in BL }
JumpOver:
  mov  ax,dx                                     { return handle number to XMS block }
end;


Procedure XMSFreeMem(Handle:Word); Assembler;
Label JumpOver;
Asm
  mov  ah,0Ah                                    { 'Free Extended memory block' Function }
  mov  dx,Handle                                 { XMS's handle number to free }
  mov  XMSError,0                                { clear error Variable }
  call [dWord ptr XMSEntryPoint]
  or   ax,ax                                     { check For error }
  jnz  JumpOver
  mov  XMSError,bl                               { errornumber stored in BL }
JumpOver:
end;


Procedure XMSMove(Var EMMParamBlock:EMMStructure); Assembler;
Label JumpOver;
Asm
  push ds
  push es
  push ds
  pop  es
  mov  ah,0Bh                                    { 'Move Extended memory block' Function }
  mov  XMSError,0                                { clear error Variable }
  lds  si,EMMParamBlock                          { DS:SI -> data to pass to the XMS routine }
  call [dWord ptr es:XMSEntryPoint]
  or   ax,ax                                     { check For error }
  jnz  JumpOver
  mov  XMSError,bl                               { errornumber stored in BL }
JumpOver:
  pop  es
  pop  ds
end;


Procedure ExitDuetoXMSError;
begin
  InitMode(CO80);
  WriteLn('ERRor! XMS routine has reported error ',XMSError);
  XMSFreeMem(BufferHandle);
  Halt(0);
end;


Procedure GetBlock(Var Buffer; Size:Word);
{ reads a specified numbers of data from a diskFile or XMS into a buffer }
Var
  XMSRecord             :EMMStructure;
  NumberofBytes         :Word;
begin
  if UseXMS then
  begin
    NumberofBytes:=Size;
    if Size MOD 2=1 then
      Inc(NumberofBytes);  { one must allways ask For a EQUAL number of Bytes }
    With XMSRecord do
    begin
      BytestoMoveLo      :=NumberofBytes;
      BytestoMoveHi      :=0;
      SourceHandle       :=BufferHandle;
      SourceoffsetLo     :=FileCounter MOD 65536;
      SourceoffsetHi     :=FileCounter div 65536;
      DestinationHandle  :=0;
      DestinationoffsetLo:=ofs(Buffer);
      DestinationoffsetHi:=Seg(Buffer);
    end;
    XMSMove(XMSRecord);
    if XMSError<>0 then
      ExitDuetoXMSError;
    Inc(FileCounter,Size);
  end
  else
    BlockRead(InputFile,Buffer,Size);
end;


Procedure InitClock; Assembler; {Taken from the FLILIB source}
Asm
  mov  al,00110100b                                 { put it into liNear count instead of divide by 2 }
  out  CMODE,al
  xor  al,al
  out  CDATA,al
  out  CDATA,al
end;


Function GetClock:LongInt; Assembler; {Taken from the FLILIB source}
{ this routine returns a clock With occassional spikes where time
  will look like its running backwards 1/18th of a second.  The resolution
  of the clock is 1/(18*256) = 1/4608 second.  66 ticks of this clock
  are supposed to be equal to a monitor 1/70 second tick.}
Asm
  mov  ah,0                                         { get tick count from Dos and use For hi 3 Bytes }
  int  01ah                                         { lo order count in DX, hi order in CX }
  mov  ah,dl
  mov  dl,dh
  mov  dh,cl

  mov  al,0                                         { read lo Byte straight from timer chip }
  out  CMODE,al                                         { latch count }
  mov  al,1
  out  CMODE,al                                         { set up to read count }
  in   al,CDATA                                         { read in lo Byte (and discard) }
  in   al,CDATA                                         { hi Byte into al }
  neg  al                                         { make it so counting up instead of down }
end;


Procedure TreatFrame(Buffer:Pointer;Chunks:Word); Assembler;
{ this is the 'workhorse' routine that takes a frame and put it on the screen }
{ chunk by chunk }
Label
  Color_Loop, Copy_Bytes, Copy_Bytes2, Exit, Fli_Black, Fli_Brun, Fli_Color,
  Fli_Copy, Fli_Lc, Fli_Loop, Jump_Over, Line_Loop, Line_Loop2, Next_Line,
  Next_Line2, Pack_Loop, Pack_Loop2;
Asm
  cli                                            { disable interrupts }
  push ds
  push es                                        
  lds  si,Buffer                                 { let DS:SI point at the frame to be drawn }

Fli_Loop:                                        { main loop that goes through all the chunks in a frame }
  cmp  Chunks,0                                  { are there any more chunks to draw? }
  je   Exit
  dec  Chunks                                    { decrement Chunks For the chunk to process now }

  mov  ax,[Word ptr ds:si+4]                     { let AX have the ChunkType }
  add  si,6                                      { skip the ChunkHeader }

  cmp  ax,0Bh                                    { is it a FLI_COLor chunk? }
  je   Fli_Color
  cmp  ax,0Ch                                    { is it a FLI_LC chunk? }
  je   Fli_Lc
  cmp  ax,0Dh                                    { is it a FLI_BLACK chunk? }
  je   Fli_Black
  cmp  ax,0Fh                                    { is it a FLI_BRUN chunk? }
  je   Fli_Brun
  cmp  ax,10h                                    { is it a FLI_COPY chunk? }
  je   Fli_Copy
  jmp  Fli_Loop                                  { This command should not be necessary since the Program should make one - }
                                                 { - of the other jumps }

Fli_Color:
  mov  bx,[Word ptr ds:si]                       { number of packets in this chunk (allways 1?) }
  add  si,2                                      { skip the NumberofPackets }
  mov  al,0                                      { start at color 0 }
  xor  cx,cx                                     { reset CX }

Color_Loop:
  or   bx,bx                                     { set flags }
  jz   Fli_Loop                                  { Exit if no more packages }
  dec  bx                                        { decrement NumberofPackages For the package to process now }

  mov  cl,[Byte ptr ds:si+0]                     { first Byte in packet tells how many colors to skip }
  add  al,cl                                     { add the skiped colors to the start to get the new start }
  mov  dx,$3C8                                   { PEL Address Write Mode Register }
  out  dx,al                                     { tell the VGA card what color we start changing }

  inc  dx                                        { at the port abow the PEL_A_W_M_R is the PEL Data Register }
  mov  cl,[Byte ptr ds:si+1]                     { next Byte in packet tells how many colors to change }
  or   cl,cl                                     { set the flags }
  jnz  Jump_Over                                 { if NumberstoChange=0 then NumberstoChange=256 }
  inc  ch                                        { CH=1 and CL=0 => CX=256 }
Jump_Over:
  add  al,cl                                     { update the color to start at }
  mov  di,cx                                     { since each color is made of 3 Bytes (Red, Green & Blue) we have to - }
  shl  cx,1                                      { - multiply CX (the data counter) With 3 }
  add  cx,di                                     { - CX = old_CX shl 1 + old_CX   (the fastest way to multiply With 3) }
  add  si,2                                      { skip the NumberstoSkip and NumberstoChange Bytes }
  rep  outsb                                     { put the color data to the VGA card FAST! }

  jmp  Color_Loop                                { finish With this packet - jump back }


Fli_Lc:
  mov  ax,0A000h
  mov  es,ax                                     { let ES point at the screen segment }
  mov  di,[Word ptr ds:si+0]                     { put LinestoSkip into DI - }
  mov  ax,di                                     { - to get the offset address to this line we have to multiply With 320 - }
  shl  ax,8                                      { - DI = old_DI shl 8 + old_DI shl 6 - }
  shl  di,6                                      { - it is the same as DI = old_DI*256 + old_DI*64 = old_DI*320 - }
  add  di,ax                                     { - but this way is faster than a plain mul }
  mov  bx,[Word ptr ds:si+2]                     { put LinestoChange into BX }
  add  si,4                                      { skip the LinestoSkip and LinestoChange Words }
  xor  cx,cx                                     { reset cx }

Line_Loop:
  or   bx,bx                                     { set flags }
  jz  Fli_Loop                                   { Exit if no more lines to change }
  dec  bx

  mov  dl,[Byte ptr ds:si]                       { put PacketsInLine into DL }
  inc  si                                        { skip the PacketsInLine Byte }
  push di                                        { save the offset address of this line }

Pack_Loop:
  or   dl,dl                                     { set flags }
  jz   Next_Line                                 { Exit if no more packets in this line }
  dec  dl
  mov  cl,[Byte ptr ds:si+0]                     { put BytestoSkip into CL }
  add  di,cx                                     { update the offset address }
  mov  cl,[Byte ptr ds:si+1]                     { put BytesofDatatoCome into CL }
  or   cl,cl                                     { set flags }
  jns  Copy_Bytes                                { no SIGN means that CL number of data is to come - }
                                                 { - else the next data should be put -CL number of times }
  mov  al,[Byte ptr ds:si+2]                     { put the Byte to be Repeated into AL }
  add  si,3                                      { skip the packet }
  neg  cl                                        { Repeat -CL times }
  rep  stosb
  jmp  Pack_Loop                                 { finish With this packet }

Copy_Bytes:                                      
  add  si,2                                      { skip the two count Bytes at the start of the packet }
  rep  movsb
  jmp  Pack_Loop                                 { finish With this packet }

Next_Line:
  pop  di                                        { restore the old offset address of the current line }
  add  di,320                                    { offset address to the next line }
  jmp  Line_Loop


Fli_Black:
  mov  ax,0A000h
  mov  es,ax                                     { let ES:DI point to the start of the screen }
  xor  di,di
  mov  cx,32000                                  { number of Words in a screen }
  xor  ax,ax                                     { color 0 is to be put on the screen }
  rep  stosw
  jmp  Fli_Loop                                  { jump back to main loop }


Fli_Brun:
  mov  ax,0A000h
  mov  es,ax                                     { let ES:DI point at the start of the screen }
  xor  di,di
  mov  bx,200                                    { numbers of lines in a screen }
  xor  cx,cx

Line_Loop2:
  mov  dl,[Byte ptr ds:si]                       { put PacketsInLine into DL }
  inc  si                                        { skip the PacketsInLine Byte }
  push di                                        { save the offset address of this line }

Pack_Loop2:
  or   dl,dl                                     { set flags }
  jz   Next_Line2                                { Exit if no more packets in this line }
  dec  dl
  mov  cl,[Byte ptr ds:si]                       { put BytesofDatatoCome into CL }
  or   cl,cl                                     { set flags }
  js   Copy_Bytes2                               { SIGN meens that CL number of data is to come - }
                                                 { - else the next data should be put -CL number of times }
  mov  al,[Byte ptr ds:si+1]                     { put the Byte to be Repeated into AL }
  add  si,2                                      { skip the packet }
  rep  stosb
  jmp  Pack_Loop2                                { finish With this packet }

Copy_Bytes2:
  inc  si                                        { skip the count Byte at the start of the packet }
  neg  cl                                        { Repeat -CL times }
  rep  movsb
  jmp  Pack_Loop2                                { finish With this packet }

Next_Line2:
  pop  di                                        { restore the old offset address of the current line }
  add  di,320                                    { offset address to the next line }
  dec  bx                                        { any more lines to draw? }
  jnz  Line_Loop2
  jmp  Fli_Loop                                  { jump back to main loop }


Fli_Copy:
  mov  ax,0A000h
  mov  es,ax                                     { let ES:DI point to the start of the screen }
  xor  di,di
  mov  cx,32000                                  { number of Words in a screen }
  rep  movsw
  jmp  Fli_Loop                                  { jump back to main loop }


Exit:
  sti                                            { enable interrupts }
  pop  es
  pop  ds
end;



begin
  WriteLn;
  WriteLn('.FLI-Player v1.1 by Thaco');
  WriteLn('  (c) EPOS, August 1992');
  WriteLn;
  if ParamCount=0 then                           { if no input parameters then Write the 'usage Text' }
  begin
    WriteLn('USAGE: FLIPLAY <options> <Filename>');
    WriteLn('                   '+#24+'         '+#24);
    WriteLn('                   │         └──  Filename of .FLI File');
    WriteLn('                   └────────────  -d   = Do not use XMS');
    WriteLn('                                  -i   = InFormation about the Program');
    WriteLn('                                  -n   = No checking of MCGA mode support');
    WriteLn('                                  -sNN = Set playspeed to NN video ticks (0-99)');
    WriteLn('                                         ( NN=70 ≈ frame Delay of 1 second )');
    Halt(0);
  end;

  For Counter:=1 to ParamCount do                { search through the input parameters For a -Info option }
    if Pos('-I',UpCaseString(ParamStr(Counter)))<>0 then
    begin
      WriteLn('Program inFormation:');
      WriteLn('This Program plays animations (sequences of pictures) made by Programs like',#10#13,
              'Autodesk Animator (so called .FLI-Files). The Program decodes the .FLI File,',#10#13,
              'frame by frame, and Uses the systemclock For mesuring the time-Delay between',#10#13,
              'each frame.');
      WriteLn('Basis For the Program was the FliLib package made by Jim Kent, but since the',#10#13,
              'original source was written in C, and I am not a good C-Writer, I decided',#10#13,
              'to Write my own .FLI-player in Turbo Pascal v6.0.');
      WriteLn('This Program was made by Eirik Milch Pedersen (thaco@solan.Unit.no).');
      WriteLn('Copyright Eirik Pedersens Own SoftwareCompany (EPOS), August 1992');
      WriteLn;
      WriteLn('Autodesk Animator is (c) Autodesk Inc');
      WriteLn('FliLib is (c) Dancing Flame');
      WriteLn('Turbo Pascal is (c) Borland International Inc');
      Halt(0);
    end;

  Speed:=-1;
  Counter:=1;
  While (Copy(ParamStr(Counter),1,1)='-') and (ParamCount>=Counter) do { search through the input parameters to assemble them }
  begin
   if Pos('-D',UpCaseString(ParamStr(Counter)))<>0 then  { do not use XMS For storing the File into memory }
     UseXMS:=False
   else
     if Pos('-N',UpCaseString(ParamStr(Counter)))<>0 then  { do not check For a vga card present }
       MCGACheck:=False
     else
       if Pos('-S',UpCaseString(ParamStr(Counter)))<>0 then { speed override has been specified }
       begin
         SpeedString:=Copy(ParamStr(Counter),3,2);  { cut out the NN parameter }
         if not(SpeedString[1] in ['0'..'9']) or    { check if the NN parameter is legal }
            (not(SpeedString[2] in ['0'..'9',' ']) and (Length(SpeedString)=2)) then
         begin
           WriteLn('ERRor! Can not parse speed ''',SpeedString,'''.');
           Halt(0);
         end;
         Speed:=Byte(SpeedString[1])-48;  { take the first number, in ASCII, and convert it to a standard number }
         if Length(SpeedString)=2 then    { if there is two numbers then multiply the first With 10 and add the next }
           Speed:=Speed*10+Byte(SpeedString[2])-48;
         Speed:=Speed*CLOCK_SCALE;        { convert the speed to number of clock tics }
       end;
   Inc(Counter);
  end;

  if ParamCount<Counter then
  begin
    WriteLn('ERRor! No Filename specified.');
    Halt(0);
  end;

  FileName:=UpCaseString(ParamStr(Counter));
  if Pos('.',FileName)=0 then  { find out if there exist a . in the Filename }
    FileName:=FileName+'.FLI'; { if not then add the .FLI extension on the Filename }

  if MaxAvail<BUFFERSIZE then   { check if there is enough memory to the frame buffer }
  begin
    WriteLn('ERRor! Can not allocate enough memory to a frame buffer.');
    Halt(0);
  end;

  GetMem(Buffer,BUFFERSIZE);
  Assign(InputFile,FileName);
  Reset(InputFile,1);
  if Ioresult<>0 then  { has an error occured during opening the File? }
  begin
    WriteLn('ERRor! Can not open File ''',FileName,'''.');
    Halt(0);
  end;

  if not(MCGACheck) or ModeSupport(MCGA) then
    InitMode(MCGA)
  else
  begin
    WriteLn('ERRor! Video mode 013h - 320x200x256 colors - is not supported.');
    Halt(0);
  end;

  BlockRead(InputFile,Header,128);  { read the .FLI main header }

  if not((Header[4]=$11) and (Header[5]=$AF)) then  { check if the File has got the magic number }
  begin
    InitMode(CO80);
    WriteLn('ERRor! File ''',FileName,''' is of a wrong File Type.');
    Halt(0);
  end;

  if NoXMS then  { if no XMS driver present then do not use XMS }
    UseXMS:=False;

  if UseXMS then
  begin
    FileSize:=Header[0]+256*(LongInt(Header[1])+256*(LongInt(Header[2])+256*LongInt(Header[3])));
    if XMSMaxAvail<=(FileSize+1023) SHR 10 then  { is there enough XMS (rounded up to Nearest KB) availible? }
    begin
      WriteLn('ERRor! not enough XMS For the File');
      Halt(0);
    end
    else
    begin
      Seek(InputFile,0);  { skip back to start of .FLI-File to put it all into XMS }
      BufferHandle:=XMSGetMem((FileSize+1023) SHR 10);  { allocate XMS For the whole .FLI File }
      FileCounter:=0;
      Repeat
        BlockRead(InputFile,Buffer^,BUFFERSIZE,BytesRead);  { read a part from the .FLI File }
        if BytesRead MOD 2=1 then  { since BUFFERSIZE shoud be an even number, the only time this triggers is the last part }
          Inc(BytesRead);          { must be done because the XMS routine demands an even number of Bytes to be moved }
        if BytesRead<>0 then
        begin
          With XMSRecord do  { put data into the XMSRecord }
          begin
            BytestoMoveLo      :=BytesRead;
            BytestoMoveHi      :=0;
            SourceHandle       :=0;
            SourceoffsetLo     :=ofs(Buffer^);
            SourceoffsetHi     :=Seg(Buffer^);
            DestinationHandle  :=BufferHandle;
            DestinationoffsetLo:=FileCounter MOD 65536;
            DestinationoffsetHi:=FileCounter div 65536;
          end;
          XMSMove(XMSRecord);   { move Bytes to XMS }
          if XMSError<>0 then   { have any XMS errors occured? }
            ExitDuetoXMSError;
          Inc(FileCounter,BytesRead);  { update the offset into XMS where to put the next Bytes }
        end;
      Until BytesRead<>BUFFERSIZE;  { Repeat Until Bytes read <> Bytes tried to read => end of File }
    end;
    FileCounter:=128;  { we continue (after reading the .FLI File into XMS) right after the .FLI main header }
  end;

  Frames:=Header[6]+Header[7]*256;  { get the number of frames from the .FLI-header }
  if Speed=-1 then                  { if speed is not set by a speed override then get it from the .FLI-header }
    Speed:=(Header[16]+Integer(Header[17])*256)*CLOCK_SCALE;
  InitClock;  { initialize the System Clock }
  OldKey:=PorT[$60];  { get the current value from the keyboard }
  Key:=OldKey;        { and set the 'current key' Variable to the same value }

  GetBlock(Header,16);  { read the first frame-header }
  FrameSize:=Header[0]+256*(LongInt(Header[1])+256*(LongInt(Header[2])+256*LongInt(Header[3])))-16;  { calculate framesize }
  SecondPos:=128+16+FrameSize;  { calculate what position to skip to when the .FLI is finished and is going to start again - }
                                { the position = .FLI-header + first_frame-header + first_framesize }
  Chunks:=Header[6]+Header[7]*256;  { calculate number of chunks in frame }
  GetBlock(Buffer^,FrameSize);  { read the frame into the framebuffer }
  TreatFrame(Buffer,Chunks);  { treat the first frame }

  TimeCounter:=GetClock;  { get the current time }

  {
    The first frame must be handeled separatly from the rest. This is because the rest of the frames are updates/changes of the
    first frame.
    At the end of the .FLI-File there is one extra frame who handles the changes from the last frame to the first frame.
  }

  Repeat
    FrameNumber:=1;  { we start at the first frame (after the initial frame) }
    Repeat
      GetBlock(Header,16);  { read frame-header }
      FrameSize:=Header[0]+256*(LongInt(Header[1])+256*(LongInt(Header[2])+256*LongInt(Header[3])))-16;  { size of frame }
      if FrameSize<>0 then  { sometimes there are no changes from one frame to the next (used For extra Delays). In such - }
                            { - Cases the size of the frame is 0 and we don't have to process them }
      begin
        Chunks:=Header[6]+Header[7]*256;  { calculate number of chunks in the frame }
        GetBlock(Buffer^,FrameSize);  { read the frame into the framebuffer }
        TreatFrame(Buffer,Chunks);  { treat the frame }
      end;

      NextTime:=TimeCounter+Speed;   { calculate the Delay to the next frame }
      While TimeCounter<NextTime do  { wait For this long }
        TimeCounter:=GetClock;

      if PorT[$64]=KEYBOARD then   { check if the value at the keyboard port is caused by a key pressed }
        Key:=PorT[$60];            { get the current value from the keyboard }
      Inc(FrameNumber);  { one frame finished, over to the next one }
    Until (FrameNumber>Frames) or (Key<>OldKey);  { Repeated Until we come to the last frame or a key is pressed }

    if UseXMS then
      FileCounter:=SecondPos
    else
      Seek(InputFile,SecondPos);  { set current position in the File to the second frame }

  Until Key<>OldKey;  { Exit the loop if a key has been pressed }

  InitMode(CO80);  { get back to Text mode }

  Close(InputFile);            { be a kind boy and close the File beFore we end the Program }
  FreeMem(Buffer,BUFFERSIZE);  { and free the framebuffer }

  if UseXMS then
    XMSFreeMem(BufferHandle);
END.
