(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0068.PAS
  Description: Smoother Viewer
  Author: JON MERKEL
  Date: 11-22-95  13:33
*)


{ Ok, this viewer will smooth scroll through a text file.  There is no
    filesize limit, but it can only handle up to 147456(!) lines of text.
    Oh yeah, you'd best have a disk cache loaded or else it won't be
    smooth at all (because it reads every line from disk as it goes).
    It also displays a progress bar so that you know how far into the
    file you are. All code 100% original by Jon Merkel.  Use it in any
    way you want.                                                           }
 
 
{$G+,I-,R-,S-,M 4096,65536,655360}
const
    DownKey = $50;                          { Scan code for the down arrow  }
    UpKey   = $48;                          { Scan code for the up arrow    }
    EscKey  = $1;                           { Scan code for the escape key  }
    done: boolean = false;
type
    list = array [0..16382] of longint;     { array of file positions       }
var
    linelist: array [0..8] of ^list;        { holds up to 147456 lines      }
    f: text;
    pos, count, maximum, line, oldline: longint;
    j, k, velocity: integer;
    segment: word;
    s: string[80];
    buffer: array [0..24*160-1] of byte;
    DisplayString, Attribs: array [0..15] of byte;
 
procedure InitList;                         { Allocate file position lists  }
var
    j: word;
    fseg: word;
begin
    j := 0;
    while (MaxAvail > 65535) and (j<9) do begin
        getmem(linelist[j], 65535);
        inc(j);
    end;
    maximum := longint(j)*16384;
    writeln('Memory for ', maximum, ' lines');
end;
 
function TextPos(var f: text): longint; assembler;      { Get file position }
asm
    mov ax,4201h; les di,[f]; mov bx,es:[di]; xor cx,cx; xor dx,dx;
    int 21h; sub ax,es:[di+10]; add ax,word ptr es:[di+8]; adc dx,0;
end;
 
procedure TextSeek(var f: text; fpos: longint); assembler;  { Set file pos  }
asm
    mov ax,4200h; les di,[f]; mov bx,es:[di]; mov cx,word [fpos+2];
    mov dx,word [fpos]; int 21h; xor ax,ax; mov es:[di+8],ax;
    mov es:[di+10],ax;
end;
 
procedure display(segment: word; s: string);    { Write string at segment   }
var
    o, j: word;
begin
    o := 0;
    for j := 1 to length(s) do begin
        mem[segment:o] := ord(s[j]); inc(o,2); end;
    while o < 160 do begin
        mem[segment:o] := 32; inc(o,2); end;
end;
 
procedure movw(var source,dest; num: word); assembler;  { move() but words  }
asm
    push ds; les di,[dest]; lds si,[source];
    mov cx,[num]; rep movsw; pop ds
end;
 
procedure ModFont; assembler;
asm
    mov dx,03C4h; mov ax,0402h; out dx,ax; mov ax,0704h; out dx,ax
    mov dl,0CEh; mov ax,0204h; out dx,ax; mov ax,0005h; out dx,ax
    inc ax; out dx,ax
end;
procedure SetFont; assembler;
asm
    mov dx,03C4h; mov ax,0302h; out dx,ax; mov ax,0304h; out dx,ax
    mov dl,0CEh; mov ax,0004h; out dx,ax; mov ax,1005h; out dx,ax
    mov ax,0E06h; out dx,ax
end;
 
procedure ShowPercent;
var
    j, k: integer;
    whole, remainder: word;
    s: string[7];
    mask: byte;
begin
    inc(pos,12); inc(count,12);
    fillchar(DisplayString, 16, ' ');
    fillchar(attribs, 16, $4F);
    whole := (pos*128 div count) shr 3;
    remainder := (pos*128 div count) and 7;
    fillchar(DisplayString, whole, #219);
    str(pos*100 div count, s);
    dec(pos,12); dec(count,12);
    s := s+'%';
    k := 7 - length(s) shr 1;
    for j := 1 to length(s) do begin
        DisplayString[k+j] := ord(s[j]);
        if k+j < whole then
            attribs[k+j] := $F4;
    end;
    if remainder <> 0 then begin
        ModFont;
        move(mem[$A000:DisplayString[whole] shl 5], mem[$A000:864], 16);
        mask := not ($FF shr remainder);
        for j := 0 to 15 do
            mem[$A000:864+j] := mem[$A000:864+j] xor mask;
        SetFont;
        DisplayString[whole] := 27;
    end;
    for j := 0 to 15 do begin
        mem[$B800:j*2+260] := DisplayString[j];
        mem[$B800:j*2+261] := attribs[j];
    end;
end;
 
 
(**********************  M A I N  P R O G R A M  ***************************)
 
begin
    s := paramstr(1);
    for j := 1 to length(s) do s[j] := upcase(s[j]);
    assign(f, s);
    writeln;
    reset(f);
    if (paramstr(1)='') or (ioresult <> 0) then begin
        writeln('Specify VALID filename on command line');
        halt;
    end;
    count := 0;
    InitList;
    write('Now loading.');
    while not eof(f) and (count<maximum) do begin
        linelist[count shr 14]^[count and 16383] := TextPos(f);
        inc(count);
        if count and 1023=0 then write('.');
        readln(f);
    end;
    close(f);
    writeln;
    writeln(count, ' lines read');
    writeln;
    write('Press a key to continue...');
    asm mov ah,0; int 16h; end;
 
    asm mov ax,3; int 10h; end;                     { set 80x25 text mode   }
    asm mov dx,03DAh; in al,dx; mov dl,0C0h;
        mov al,30h; out dx,al; mov al,36; out dx,al; end;
    asm mov dx,03D4h; mov ax,7018h; out dx,ax;
        mov ax,1F07h; out dx,ax; mov ax,0F09h;
        out dx,ax; mov ax,0A00Dh; out dx,ax; end;
    asm in al,21h; or al,2; out 21h,al; end;        { disable the keyboard  }
    asm mov ax,0100h; mov cx,2000h; int 10h; end;   { hide the cursor       }
    display($B80A, '   Filename :                          Progress :');
    for j := 0 to 79 do
        mem[$B800:j*2] := 196;
    for j := 1 to length(s) do begin
        mem[$B80A:j*2+26] := ord(s[j]);
        mem[$B80A:j*2+27] := 11;
    end;
 
    pos := 0; velocity := 0; oldline := 0;
    count := (count-23)*16; if count<0 then count:=0;
    reset(f);
    for j := 0 to 23 do if not eof(f) then begin
        readln(f, s);
        display($B814+j*10, s);
    end;
    movw(mem[$B814:0], buffer, 24*80);
 
    repeat
        line := pos shr 4;
        while port[$3DA] and 8<>0 do;
        while port[$3DA] and 8=0 do;
        portw[$3D4] := (pos and 15) shl 8 + 8;
 
        j := line-oldline;
        if j>0 then begin                                   { Go forwards   }
            k := 24-j;
            movw(buffer[j*160], mem[$B814:0], k*80);
            segment := $B814 + k*10;
            for oldline := oldline+1 to line do begin
                readln(f, s);
                display(segment, s);
                inc(segment, 10);
            end;
            movw(mem[$B814:0], buffer, 24*80);
        end
        else if j<0 then begin                              { Go backwards  }
            TextSeek(f, linelist[line shr 14]^[line and 16383]);
            segment := $B814;
            for oldline := oldline-1 downto line do begin
                readln(f,s);
                display(segment, s);
                inc(segment, 10);
            end;
            movw(buffer, mem[$B814:-j*160], (24+j)*80);
            TextSeek(f, linelist[(line+24) shr 14]^[(line+24) and 16383]);
            movw(mem[$B814:0], buffer, 24*80);
        end;
        ShowPercent;
 
        case port[$60] of
            DownKey : if velocity < 350 then inc(velocity,2);
            UpKey   : if velocity > -350 then dec(velocity,2);
            EscKey  : done := true;
        end;
        inc(pos, velocity);
        if pos<0 then begin
            pos := 0; velocity := 0; end
        else if pos>count then begin
            pos := count; velocity := 0; end;
        if velocity > 0 then
            dec(velocity)
        else if velocity < 0 then
            inc(velocity);
 
    until done;
 
    asm in al,21h; and al,253; out 21h,al; end;         { enable keyboard   }
    asm mov ax,3; int 10h; end;                         { reset text mode   }
end.

