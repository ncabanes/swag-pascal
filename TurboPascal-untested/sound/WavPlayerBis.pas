(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0091.PAS
  Description: WAV Player
  Author: PETER TAYLOR
  Date: 11-22-95  13:29
*)


{Greetings yet again. Heres a prog that plays .WAV files through PC SPEAKER.
Someone want to modify it so they play through SOUND BLASTER? Anyway, this is
also coolos.Pete }

program player;

uses dos;

VAR
  Param:string[63];
  BytesRead,BlockSize,BlockRest:Word;
  dataptr,pp:pointer;
  f:file;
  I:Integer;
  SampRateDiv,times:byte;
  reverse,wavinfo:boolean;
  fmt: record
    wFormatTag:word;
    nChannels:word;
    nSamplesPerSec:longint;
    nAvgBytesPerSec:longint;
    nBlockAlign:word;
    wBitsPerSample:word;
end;

PROCEDURE PlaySound(bufptr:pointer;bufctr:longint;ratediv,times:word)
;{assember;}  var
    old_int8 : pointer;
    timesleft :word;
    savemask:byte;
  begin;
  ASM
        jmp     @PlayMain
  @int8_out_spk:
        xor     al,al
        out     42h,al
        mov     al,cl
        out     42h,al
        mov     ax,dx
        or      ax,si
        jz      @ready
        dec     bl
        jnz     @skip
        mov     bl,bh
        mov     al,es:[di]
        shr     al,1
        shr     al,1
        inc     al
        mov     cl,al
        inc     di
        jnz     @noseg
        mov     ax,es
        add     ax,1000h
        mov     es,ax
  @noseg:
        sub     si,+01
        sbb     dx,+00
  @skip:
        mov     al,20h
        out     20h,al
        iret
  @ready:
        mov     ch,0ffh
        jmp     @skip
  @PlayMain:
        cli
        mov     ax,3508h
        int     21h                    { get int vector 08 in es:bx }
        mov     word ptr old_int8,bx
        mov     word ptr old_int8+2,es
        in      al,21h                 { interruptmask }
        mov     savemask,al
        mov     al,0ffh                { disable all interrupts }
        out     21h,al
        sti
        push    ds
        mov     ax,cs
        mov     ds,ax
        mov     dx,offset @int8_out_spk
        mov     ax,2508h
        int     21h                    { set int vector 08 to ds:dx }
        pop     ds
        mov     al,34h
        out     43h,al                 { timer 0 mode }
        mov     al,36h                 { 22khz }
        out     40h,al
        xor     al,al
        out     40h,al
        mov     al,90h
        out     43h,al                 { timer 2 mode }
        in      al,61h                 { enable speaker }
        or      al,3
        out     61h,al
        mov     cx,times
        mov     timesleft,cx
        mov     cl,20h
        mov     bx,ratediv
        mov     bh,bl
        les     si,bufctr
        mov     dx,es
        les     di,bufptr
  @nexttime:
        push    di                     { bufptrlo }
        push    es                     { bufptrhi }
        push    si                     { bufctrlo }
        push    dx                     { bufctrhi }
        push    bx                     { ratediv  }
        xor     ch,ch                  { readyflag = false }
        mov     al,0feh                { enable timerinterrupt }
        out     21h,al
  @notready:
        or      ch,ch
        jz      @notready
        cli
        mov     al,0ffh                { disable all interrupts }
        out     21h,al
        sti
        pop     bx                     { ratediv }
        pop     dx                     { bufctrhi }
        pop     si                     { bufctrlo }
        pop     es                     { bufptrhi }
        pop     di                     { bufptrlo }
        dec     word ptr timesleft     { more times ? }
        jnz     @nexttime
        in      al,61h                 { disable speaker }
        and     al,0fch
        out     61h,al
        mov     al,34h
        out     43h,al                 { timer 0 mode }
        mov     al,0
        out     40h,al                 { timer 0 clock }
        out     40h,al                 { timer 0 clock }
        mov     al,0b6h
        out     43h,al                 { timer mode }
        mov     ax,533h
        out     42h,al                 { timer 2 spkr }
        mov     al,ah
        out     42h,al                 { timer 2 spkr }
        push    ds
        lds     dx,dword ptr old_int8
        mov     ax,2508h
        int     21h                    { set intrpt vector al to ds:dx }
        pop     ds
        mov     al,savemask            { enable timer and keyboard }
        out     21h,al
  END;
  end;

  { The following procedure is also used to half the samplerate }

  PROCEDURE Stereo2Mono(bufptr:pointer;bufctr:longint); assembler;
  ASM
        les     si,bufctr
        mov     dx,es
        les     di,bufptr
        push    ds
        mov     ax,es
        mov     ds,ax
        mov     bx,di
  @s2mNext:
        mov     ax,dx
        or      ax,si
        jz      @s2mRdy
        xor     ah,ah
        mov     al,es:[di]
        mov     cx,ax
        mov     al,es:[di+1]
        add     ax,cx
        shr     ax,1
        mov     ds:[bx],al
        inc     di
        jnz     @noseg1
        mov     ax,es
        add     ax,1000h
        mov     es,ax
  @noseg1:
        inc     di
        jnz     @noseg2
        mov     ax,es
        add     ax,1000h
        mov     es,ax
  @noseg2:
        inc     bx
        jnz     @noseg3
        mov     ax,ds
        add     ax,1000h
        mov     ds,ax
  @noseg3:
        sub     si,+01
        sbb     dx,+00
        jmp     @s2mNext
  @s2mRdy:
        pop     ds
  END;

  PROCEDURE ReverseData(bufptr:pointer;bufctr:longint); assembler;
  ASM
        push    ds
        les     bx,bufctr
        mov     dx,es
        les     di,bufptr
        mov     si,di
        add     si,bx                  { offset=offset+bufctrlo }
        mov     ax,dx
        adc     ax,0                   { bufctrhi=bufctrhi+carry }
        mov     cl,12
        shl     ax,cl
        mov     cx,ax
        mov     ax,es
        add     ax,cx
        mov     ds,ax                  {ds = segment of end of buffer}
        shr     dx,1
        rcr     bx,1                   { Bufctr = Bufctr / 2 }
  @RevNext:
        mov     ax,bx
        or      ax,dx
        jz      @RevRdy
        sub     si,+01
        jnc     @Rnoseg1
        mov     ax,ds
        sub     ax,1000h
        mov     ds,ax
  @Rnoseg1:
        mov     al,es:[di]             { swap bytes }
        xchg    al,ds:[si]
        mov     es:[di],al
        inc     di
        jnz     @Rnoseg2
        mov     ax,es
        add     ax,1000h
        mov     es,ax
  @Rnoseg2:
        sub     bx,+01
        sbb     dx,+00
        jmp     @RevNext
  @RevRdy:
        pop     ds
  END;

  PROCEDURE ReadFormat(var f:file);
  var
    str:string[4];
    chunksize:longint;
  BEGIN
    blockread(f,str[1],4);
    str[0]:=#4;
    if str='fmt ' then begin
      blockread(f,chunksize,4);
      if wavinfo then writeln('  ''fmt '' size=',chunksize);
      if chunksize=16 then begin
        blockread(f,fmt,sizeof(fmt));
        if wavinfo then with fmt do begin
          writeln('    wFormatTag=',wFormatTag);
          writeln('    nChannels=',nChannels);
          writeln('    nSamplesPerSec=',nSamplesPerSec);
          writeln('    nAvgBytesPerSec=',nAvgBytesPerSec);
          writeln('    nBlockAlign=',nBlockAlign);
          writeln('    wBitsPerSample=',wBitsPerSample);
        end;
        if fmt.wFormatTag<>1 then begin
          writeln('Unknown Format (',fmt.wFormatTag,')!');
          halt;
        end;
        case word(fmt.nSamplesPerSec) of
          33075..65535:sampratediv:=0;
          16538..33074:sampratediv:=1;
          9188..16537:sampratediv:=2;
          6432..9187:sampratediv:=3;
          4962..6431:sampratediv:=4;
          4043..4961:sampratediv:=5;
          3413..4042:sampratediv:=6;
          else halt;
        end;
      end
      else writeln('''fmt '' chunksize error (',chunksize,')!');
    end
    else writeln('''fmt'' chunk not found!');
  END;

 PROCEDURE PlayWAVE(var f:file;sampratediv,times:byte);
  var
    str:string[4];
    DataSize,l1:longint;
    p1,p2:pointer;
    s,o:word;
  BEGIN
    blockread(f,str[1],4);
    str[0]:=#4;
    if str='data' then begin
      blockread(f,DataSize,4);
      if wavinfo then writeln('  ''data'' size=',Datasize);
      If MaxAvail>DataSize THEN BEGIN
        if DataSize<$FFF0 then Blocksize:=DataSize else Blocksize:=$8000;
        GetMem(pp,BlockSize);
        DataPtr:=pp;
        blockread(f,pp^,BlockSize,bytesread);
        if BlockSize<DataSize then begin
          For I:=1 to pred(DataSize div BlockSize) do begin
            GetMem(pp,BlockSize);
            blockread(f,pp^,Blocksize,bytesread);
          end;
          BlockRest:=DataSize mod BlockSize;
          if BlockRest<>0 then begin
            GetMem(pp,BlockRest);
            blockread(f,pp^,BlockRest,bytesread);
          end;
        end;
        if fmt.nChannels=2 then begin
          if wavinfo then Write('Converting to mono..');
          Stereo2Mono(DataPtr,DataSize);
          DataSize:=DataSize shr 1;
          if wavinfo then writeln;
        end;
        if sampratediv=0 then begin
          sampratediv:=1;
          if wavinfo then Write('Dividing to half samplerate..');
          Stereo2Mono(DataPtr,DataSize);
          DataSize:=DataSize shr 1;
          if wavinfo then writeln;
        end;
        if reverse then ReverseData(DataPtr,DataSize);
        PlaySound(DataPtr,DataSize,SampRateDiv,Times);
      end
      else Writeln('Not enough memory!');
    end
    else writeln('''data'' chunk not found!');
  END;

  PROCEDURE ReadRIFF(var f:file);
  var
    str:string[4];
    RIFFsize,Chunksize:longint;
  BEGIN
    blockread(f,str[1],4);
    str[0]:=#4;
    if str='RIFF' then begin
      blockread(f,RIFFsize,4);
      if wavinfo then writeln('''RIFF'' size=',RIFFsize);
      REPEAT
        blockread(f,str[1],4);
        if str='WAVE' then begin
          ReadFormat(f);
          PlayWAVE(f,sampratediv,times);
        end
        else begin
          blockread(f,Chunksize,4);
          seek(f,filepos(f)+Chunksize);
        end;
      until filepos(f)>=RIFFsize+8;
    end
    else Writeln('No RIFF header found!');
  END;

  PROCEDURE ShowHelp;
  BEGIN
    Writeln('PLAYWAV  Bengt Holgersson 1991');
    Writeln('Use: PLAYWAV filename [/N:times] [/R] [/I]');
    Writeln('  /N:4   Play WAV 4 times');
    Writeln('  /R     Play WAV backwards');
    Writeln('  /I     Show info about WAV');
  END;

  procedure Getoption(s:string);
  var
    ch:char;
    W:word;
  begin
    if length(s)<2 then exit;
    ch:=s[2];
    case upcase(ch) of
      'R':reverse:=true;
      'N':begin
            if s[3]<>':' then exit;
            val(copy(s,4,255),times,w);
            if (w>0) or (times<1) then begin
              writeln('times should be in the range 1-65535');
            end;
          end;
      'I':wavinfo:=true;
      '?':showhelp;
    end;
  end;

BEGIN
  IF paramcount <1 then begin
    showhelp;
    halt;
  end;
  wavinfo:=false;
  reverse:=false;
  Times:=1;
  if paramcount >1 then begin
    for i:=2 to paramcount do getoption(paramstr(i));
  end;
  filemode:=0;
  Param:=paramstr(1);
  if Param[1]='/' then begin
    getoption(Param);
    halt;
  end;
  if pos('.',Param)=0 then Param:=Param+'.WAV';
  assign(f,Param);
  reset(f,1);
  IF Ioresult=0 then ReadRIFF(f)
  else writeln('File not found!');
END.


