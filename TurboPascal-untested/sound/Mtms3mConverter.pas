(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0092.PAS
  Description: MTM->S3M converter
  Author: JON MERKEL
  Date: 11-25-95  09:26
*)

{
Things that WILL mess it up due to ST3 limitations:
    - more than 16 channels
    - more than 8 channels at left or at right
    - 16 bit samples
    - samples greater than 64000 bytes
}

program mtm2s3m;    {$G+,I-,S-}
 
type
    S3Mnote = record  n,i,v,e,a: byte;  end;
var
    mtm,s3m: file;
    MTMheader: record
        Marker: array [1..3] of char;
        Version: byte;
        SongName: array [0..19] of char;
        NumTracks: word;
        LastPattern, LastOrder: byte;
        Comment: word;
        NumSamples, Attribute, BPM, NumChannels: byte;
        PanPositions: array [0..31] of byte;
    end;
    S3Mheader: record
        Sname: array [0..27] of char;
        EOFtype: word;
        Reserved1: word;
        OrdNum, InsNum, PatNum, Flags, Cwtv, Ffi: word;
        SCRM: array [1..4] of char;
        GV, IS, IT, MV, UC, DP: byte;
        Reserved2: array [1..10] of byte;
        Channels: array [0..31] of byte;
    end;
    S3Mpan: array [0..31] of byte;
    MTMins: array [0..30] of record
            Mname: array [0..21] of char;
            MLength, MLoopBeg, MLoopEnd: longint;
            FineTune, Volume, Attrib: byte;
        end;
    S3Mins: record
        Itype: byte;
        Filename: array [0..12] of char;
        MemSeg: word;
        Length, LoopBeg, LoopEnd: longint;
        Vol: word;
        P, F: byte;
        C2spd: longint;
        Reserved: array [1..12] of byte;
        SampleName: array [0..27] of char;
        SCRS: array [1..4] of char;
    end;
    InsPtrPos, PatPtrPos, SamplePos: longint;
    temp: array [0..8192] of byte;
    tempw: array [0..4095] of word absolute temp;
    MTMtrack: array [0..63, 0..2] of byte absolute temp;
    pattern: array [0..63, 0..31] of S3Mnote;

function Init(var fname: string): boolean;
begin
    if pos('.', fname) <> 0 then
        fname[0] := chr(pos('.', fname)-1);
    assign(mtm, fname+'.MTM');
    reset(mtm,1);
    if ioresult<>0 then
        init := false
    else begin
        assign(s3m, fname+'.S3M');
        rewrite(s3m,1);
        init := true;
    end;
end;
 
procedure DoHeader;
var
    j, lcount, rcount: integer;
begin
    blockread(mtm, MTMheader, sizeof(MTMheader));
    fillchar(S3Mheader, sizeof(S3Mheader), 0);
    with MTMheader, S3Mheader do begin
        EOFtype := $101A; Cwtv := $1320; FFi := 2; SCRM := 'SCRM';
        GV := 64; IS := 6; IT := 125; MV := 176; UC := 16; DP := 252;
        move(SongName, Sname, 20);
        OrdNum := (LastOrder+3) and not 1;
        InsNum := NumSamples;
        PatNum := LastPattern+1;
        fillchar(Channels, 32, $FF);
        fillchar(S3Mpan, 32, 0);
        lcount := 0; rcount := 8;
        for j := 0 to NumChannels-1 do begin
            S3Mpan[j] := PanPositions[j];
            if S3Mpan[j] < 8 then begin
                Channels[j] := lcount; inc(lcount);
                if S3Mpan[j] <> 3 then S3Mpan[j] := S3Mpan[j] or $20;
            end
            else begin
                Channels[j] := rcount; inc(rcount);
                if S3Mpan[j] <> $0C then S3Mpan[j] := S3Mpan[j] or $20;
            end;
        end;
        blockwrite(s3m, S3Mheader, sizeof(S3Mheader));
        seek(mtm, 66 + NumSamples*37);
        fillchar(temp, 256, $FF);
        blockread(mtm, temp, LastOrder+1);
        blockwrite(s3m, temp, OrdNum);
        InsPtrPos := filepos(s3m);
        blockwrite(s3m, temp, InsNum*2);
        PatPtrPos := InsPtrPos + InsNum*2;
        blockwrite(s3m, temp, PatNum*2);
        blockwrite(s3m, S3Mpan, 32);
    end;
end;
 
const
    FineTuneTable: array [0..15] of word = (8363,8413,8463,8529,8581,
        8651,8723,8757,7895,7941,7985,8046,8107,8169,8232,8280);
 
procedure DoInstruments;
var
    j: integer;
    savepos: longint;
begin
    seek(mtm, 66);
    blockread(mtm, MTMins, MTMheader.NumSamples*37);
    blockwrite(s3m, temp, (16-filesize(s3m) and 15) and 15);
    SamplePos := filesize(s3m);
    for j := 0 to MTMheader.NumSamples-1 do with MTMins[j],S3Mins do begin
        tempw[j] := SamplePos shr 4 +j*5;
        fillchar(S3Mins, sizeof(S3Mins), 0);
        if MLength > 0 then Itype := 1;
        Length := MLength;
        LoopBeg := MLoopBeg;
        LoopEnd := MLoopEnd;
        Vol := Volume;
        F := byte(MLoopBeg<>MLoopEnd);
        C2spd := FineTuneTable[FineTune];
        move(Mname, SampleName, 22);
        SCRS := 'SCRS';
        blockwrite(s3m, S3Mins, sizeof(S3Mins));
    end;

    SavePos := filepos(s3m);
    seek(s3m, InsPtrPos);
    blockwrite(s3m, temp, MTMheader.NumSamples*2);
    seek(s3m, SavePos);
end;
 
const
    EffectTable: array [0..15] of byte = (
        $FF,6,5,7,8,12,11,18,24,15,4,2,$FF,3,19,1);
    NeedsFixing: array [0..15] of byte = (
          1,1,1,0,0,0,0,0,0,0,1,0,1,0,1,1);
 
procedure DoPatterns;
var
    j, k, l: integer;
    order: array [0..31] of word;
    SavePos, pos, mpos: word;
    mask: byte;
begin
    with MTMheader do
    for j := 0 to LastPattern do begin
        seek(mtm, 194+NumSamples*37+NumTracks*192+j*64);
        blockread(mtm, order, sizeof(order));
        fillchar(pattern, sizeof(pattern), $FF);
{ Convert MTM tracks to ST3-like pattern }
        for k := 0 to NumChannels-1 do if order[k] <> 0 then begin
            seek(mtm, 194+NumSamples*37+order[k]*192-192);
            blockread(mtm, MTMtrack, 192);
            for l := 0 to 63 do with pattern[l,k] do begin
                n := MTMtrack[l,0] shr 2;
                i := (MTMtrack[l,0] and 3) shl 4 + (MTMtrack[l,1] shr 4);
                e := EffectTable[MTMtrack[l,1] and 15];
                a := MTMtrack[l,2];
                if boolean(NeedsFixing[MTMtrack[l,1] and 15]) then
                    case MTMtrack[l,1] and 15 of
                        0: if a <> 0 then e := 10;
                        1: if a > $DF then a := $DF;
                        2: if a > $DF then a := $DF;
                       10: if a>$0F then a := a and $F0;
                       12: v := a;
                       14: case a shr 4 of
                            1: begin e := 6; a := $F0 + a and 15; end;
                            2: begin e := 5; a := $F0 + a and 15; end;
                            5: a := $20 + a and 15;
                            9: begin e := 17; a := a and 15; end;
                           10: begin e := 4; a := $0F + a shl 4; end;
                           11: begin e := 4; a := $F0 + a and 15; end;
                        end;
                       15: if a>=$20 then e := 20;
                    end;
            end;
        end;
        savepos := filepos(s3m) shr 4;
        seek(s3m, PatPtrPos+j*2);
        blockwrite(s3m, savepos, 2);
        seek(s3m, savepos*longint(16));
{ Now compress pattern }
        pos := 2;
        for k := 0 to 63 do begin
            for l := 0 to NumChannels-1 do with pattern[k,l] do begin
                mpos := pos;
                mask := 0;
                inc(pos);
                if not (((n or i)=0) or ((n and i)=$FF)) then begin
                    mask := mask or 32;
                    if n=0 then temp[pos] := $FF
                    else
                        temp[pos] := (n-1) div 12*16 + (n-1) mod 12 + 32;
                    temp[pos+1] := i;
                    inc(pos, 2);
                end;
                if v <> $FF then begin
                    mask := mask or 64;
                    temp[pos] := v;
                    inc(pos);
                end;
                if e<>$FF then begin
                    mask := mask or 128;
                    temp[pos] := e;
                    temp[pos+1] := a;
                    inc(pos,2);
                end;
                if mask <> 0 then
                    temp[mpos] := mask or l
                else dec(pos);
            end;
            temp[pos] := 0;
            inc(pos);
        end;
        tempw[0] := pos;
        blockwrite(s3m, temp, (pos+15) and not 15);
    end;
end;
 
procedure DoSamples;
var
    j: integer;
    savepos: word;
begin
    with MTMheader do begin
        seek(mtm,194+NumSamples*37+NumTracks*192+(LastPattern+1)*64+Comment);
        for j := 0 to NumSamples-1 do with MTMins[j] do begin
            savepos := filepos(s3m) shr 4;
            seek(s3m, SamplePos+j*80+14);
            blockwrite(s3m, savepos, 2);
            seek(s3m, savepos*longint(16));
            while Mlength > 8192 do begin
                blockread(mtm, temp, 8192);
                blockwrite(s3m, temp, 8192);
                dec(Mlength, 8192);
            end;
            blockread(mtm, temp, Mlength);
            blockwrite(s3m, temp, (Mlength+15) and not 15);
        end;
    end;
end;
 
var
    s: string;
begin
    write('Filename: ');
    readln(s);
    if not Init(s) then begin
        writeln('Error loading ', s+'.MTM');
        halt($FF);
    end;
    DoHeader;
    DoInstruments;
    DoPatterns;
    DoSamples;
    close(s3m);
end.

