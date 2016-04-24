(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0086.PAS
  Description: Sound Blaster Stuff
  Author: DANNY SWETT
  Date: 09-04-95  10:57
*)


{Danny Swett
 This will play upto 44khz on a Sound Blaster
}

{ NOTE : Other units needed are at the end !! }


unit sb_voice;

interface
var
    SBstatus:word;

procedure setsb_port(address,int:word);
procedure setsb_speed(hertz:word);
procedure outputsb(buffer:pointer;len:longint);
procedure stopsb;
procedure continuesb;
procedure resetsb;
procedure setsb_speaker(on:boolean);

implementation

uses crt,dos;

var
    SBint,SBio:word;
    SBhighspeed,SBintset:boolean;
    oldint:pointer;
    s_low16:word;
    s_high4:byte;
    s_len:longint;
    oldexitproc:pointer;

procedure writesb(a:byte);
begin
    while((port[SBio+12] and $80)<>0) do ;
    port[SBio+12]:=a;
end;

procedure resetsb;
var
    a:byte;

begin
    SBstatus:=0;
    if(SBio<>0) then
    begin
        port[SBio+6]:=1;
        delay(10);
        port[SBio+6]:=0;
        delay(10);
        if(((port[SBio+14] and $80)<>$80) or (port[SBio+10]<>$aa)) then
            SBio:=0;
    end;
end;

procedure setsb_speed;
var
    a:byte;

begin
    if(SBio<>0) then
    begin
        a:=256-(1000000 div hertz);
        writesb($40);
        writesb(a);
        if(hertz>22050) then
            SBhighspeed:=true
        else
            SBhighspeed:=false;
    end;
end;

procedure stopsb;
begin
    if(SBio<>0) then
    begin
        SBstatus:=0;
        if(SBhighspeed=false) then
            writesb($d0)
        else
            port[$0a]:=5;
    end;
end;

procedure continuesb;
begin
    if(SBio<>0) then
    begin
        SBstatus:=1;
        if(SBhighspeed=false) then
            writesb($d4)
        else
            port[$0a]:=1;
    end;
end;

procedure setsb_speaker;
begin
    if(SBio<>0) then
    begin
        if(on=true) then
            writesb($d1)
        else
            writesb($d3);
    end;
end;

procedure outputcontinue;
var
    l:word;

begin
    l:=$ffff-s_low16;
    if(l>s_len) then
        l:=s_len;
    port[$0a]:=5;
    port[$0c]:=0;
    port[$0b]:=$49;
    port[$02]:=lo(s_low16);
    port[$02]:=hi(s_low16);
    port[$83]:=s_high4;
    port[$03]:=lo(l);
    port[$03]:=hi(l);
    port[$0a]:=1;
    if(SBhighspeed=false) then
    begin
        writesb($14);
        writesb(lo(l));
        writesb(hi(l));
    end
    else
    begin
        writesb($48);
        writesb(lo(l));
        writesb(hi(l));
        writesb($91);
    end;
    s_len:=s_len-l;
    s_low16:=0;
    s_high4:=s_high4+1;
end;

procedure sbinter; interrupt;
var
    a:byte;

begin
    a:=port[SBio+14];
    if(s_len>0) then
        outputcontinue
    else
    begin
        port[$0a]:=5;
        SBstatus:=0;
        a:=port[SBio+14];
    end;
    port[$20]:=$20;
end;

procedure setsb_int;
begin
    if((SBintset=false) and (SBio<>0) and (SBint<>0)) then
    begin
        SBintset:=true;
        getintvec(8+SBint,oldint);
        setintvec(8+SBint,addr(sbinter));
        port[$21]:=(port[$21] and ($ff-(1 shl SBint)));
    end;
end;

procedure outputsb;
var
    l:word;

begin
    if((SBstatus=0) and (SBio<>0)) then
    begin
        s_len:=len-1;
        setsb_int;
        setsb_speaker(true);
        SBstatus:=1;
        s_low16:=word(ofs(buffer^)+(seg(buffer^) shl 4));
        s_high4:=byte(((ofs(buffer^) shr 4)+seg(buffer^)) shr 12);
        l:=$ffff-s_low16;
        if(l>s_len) then
            l:=s_len;
        port[$0a]:=5;
        port[$0c]:=0;
        port[$0b]:=$49;
        port[$02]:=lo(s_low16);
        port[$02]:=hi(s_low16);
        port[$83]:=s_high4;
        port[$03]:=lo(l);
        port[$03]:=hi(l);
        port[$0a]:=1;
        if(SBhighspeed=false) then
        begin
            writesb($14);
            writesb(lo(l));
            writesb(hi(l));
        end
        else
        begin
            writesb($48);
            writesb(lo(l));
            writesb(hi(l));
            writesb($91);
        end;
        s_len:=s_len-l;
        s_low16:=0;
        s_high4:=s_high4+1;
    end;
end;

procedure deinitsb; far;
begin
    exitproc:=oldexitproc;
    if(SBio<>0) then
    begin
        setsb_speaker(false);
        if(SBstatus<>0) then
            stopsb;
        resetsb;
        if(SBintset=true) then
            setintvec(8+SBint,oldint);
        SBstatus:=0;
    end;
end;

procedure setsb_port;
begin
    SBstatus:=0;
    SBint:=int;
    SBio:=address;
    resetsb;
    if(SBio<>0) then
    begin
        setsb_speaker(false);
        setsb_int;
        SBstatus:=1;
        writesb($f2);
        delay(100);
        if(SBstatus<>0) then
        begin
            deinitsb;
            SBio:=0;
            writeln('IRQ failed');
        end;
    end;
end;

begin
    oldexitproc:=exitproc;
    exitproc:=addr(deinitsb);
    SBintset:=false;
    SBio:=0;
    SBint:=0;
end.

__________
sb_xms.pas
~~~~~~~~~~
{Danny Swett
 This will play upto 44khz on a Sound Blaster
 Can also play sound that are loaded into XMS memory
}


unit sb_xms;

interface
var
    SBstatus:word;

procedure setsb_port(address,int:word);
procedure setsb_speed(hertz:word);
procedure outputsb(buffer:pointer;len:longint);
procedure outputxmssb(buf:word);
procedure stopsb;
procedure continuesb;
procedure resetsb;
procedure setsb_speaker(on:boolean);

implementation

uses crt,dos,xms;

var
    SBint,SBio:word;
    SBhighspeed,SBintset:boolean;
    oldint:pointer;
    s_low16:word;
    s_high4:byte;
    s_len:longint;
    oldexitproc:pointer;

procedure writesb(a:byte);
begin
    while((port[SBio+12] and $80)<>0) do ;
    port[SBio+12]:=a;
end;

procedure resetsb;
var
    a:byte;

begin
    SBstatus:=0;
    if(SBio<>0) then
    begin
        port[SBio+6]:=1;
        delay(10);
        port[SBio+6]:=0;
        delay(10);
        if(((port[SBio+14] and $80)<>$80) or (port[SBio+10]<>$aa)) then
            SBio:=0;
    end;
end;

procedure setsb_speed;
var
    a:byte;

begin
    if(SBio<>0) then
    begin
        a:=256-(1000000 div hertz);
        writesb($40);
        writesb(a);
        if(hertz>22050) then
            SBhighspeed:=true
        else
            SBhighspeed:=false;
    end;
end;

procedure stopsb;
begin
    if(SBio<>0) then
    begin
        SBstatus:=0;
        if(SBhighspeed=false) then
            writesb($d0)
        else
            port[$0a]:=5;
    end;
end;

procedure continuesb;
begin
    if(SBio<>0) then
    begin
        SBstatus:=1;
        if(SBhighspeed=false) then
            writesb($d4)
        else
            port[$0a]:=1;
    end;
end;

procedure setsb_speaker;
begin
    if(SBio<>0) then
    begin
        if(on=true) then
            writesb($d1)
        else
            writesb($d3);
    end;
end;

procedure outputcontinue;
var
    l:word;

begin
    l:=$ffff-s_low16;
    if(l>s_len) then
        l:=s_len;
    port[$0a]:=5;
    port[$0c]:=0;
    port[$0b]:=$49;
    port[$02]:=lo(s_low16);
    port[$02]:=hi(s_low16);
    port[$83]:=s_high4;
    port[$03]:=lo(l);
    port[$03]:=hi(l);
    port[$0a]:=1;
    if(SBhighspeed=false) then
    begin
        writesb($14);
        writesb(lo(l));
        writesb(hi(l));
    end
    else
    begin
        writesb($48);
        writesb(lo(l));
        writesb(hi(l));
        writesb($91);
    end;
    s_len:=s_len-l;
    s_low16:=0;
    s_high4:=s_high4+1;
end;

procedure sbinter; interrupt;
var
    a:byte;

begin
    a:=port[SBio+14];
    if(s_len>0) then
        outputcontinue
    else
    begin
        port[$0a]:=5;
        SBstatus:=0;
        a:=port[SBio+14];
    end;
    port[$20]:=$20;
end;

procedure setsb_int;
begin
    if((SBintset=false) and (SBio<>0) and (SBint<>0)) then
    begin
        SBintset:=true;
        getintvec(8+SBint,oldint);
        setintvec(8+SBint,addr(sbinter));
        port[$21]:=(port[$21] and ($ff-(1 shl SBint)));
    end;
end;

procedure outputsb;
var
    l:word;

begin
    if((SBstatus=0) and (SBio<>0)) then
    begin
        s_len:=len-1;
        setsb_int;
        setsb_speaker(true);
        SBstatus:=1;
        s_low16:=word(ofs(buffer^)+(seg(buffer^) shl 4));
        s_high4:=byte(((ofs(buffer^) shr 4)+seg(buffer^)) shr 12);
        l:=$ffff-s_low16;
        if(l>s_len) then
            l:=s_len;
        port[$0a]:=5;
        port[$0c]:=0;
        port[$0b]:=$49;
        port[$02]:=lo(s_low16);
        port[$02]:=hi(s_low16);
        port[$83]:=s_high4;
        port[$03]:=lo(l);
        port[$03]:=hi(l);
        port[$0a]:=1;
        if(SBhighspeed=false) then
        begin
            writesb($14);
            writesb(lo(l));
            writesb(hi(l));
        end
        else
        begin
            writesb($48);
            writesb(lo(l));
            writesb(hi(l));
            writesb($91);
        end;
        s_len:=s_len-l;
        s_low16:=0;
        s_high4:=s_high4+1;
    end;
end;

procedure outputxmssb;
var
    l:word;
    info:longint;

begin
    if((SBstatus=0) and (SBio<>0)) then
    begin
        info:=xms_getinfo(buf);
        s_len:=longint(longint(word(info)) shl 10)-1;
        setsb_int;
        setsb_speaker(true);
        SBstatus:=1;
        info:=xms_lock(buf);
        xms_unlock(buf);
        s_low16:=word(info);
        s_high4:=byte(info shr 16);
        l:=$ffff-s_low16;
        if(l>s_len) then
            l:=s_len;
        port[$0a]:=5;
        port[$0c]:=0;
        port[$0b]:=$49;
        port[$02]:=lo(s_low16);
        port[$02]:=hi(s_low16);
        port[$83]:=s_high4;
        port[$03]:=lo(l);
        port[$03]:=hi(l);
        port[$0a]:=1;
        if(SBhighspeed=false) then
        begin
            writesb($14);
            writesb(lo(l));
            writesb(hi(l));
        end
        else
        begin
            writesb($48);
            writesb(lo(l));
            writesb(hi(l));
            writesb($91);
        end;
        s_len:=s_len-l;
        s_low16:=0;
        s_high4:=s_high4+1;
    end;
end;

procedure deinitsb; far;
begin
    exitproc:=oldexitproc;
    if(SBio<>0) then
    begin
        setsb_speaker(false);
        if(SBstatus<>0) then
            stopsb;
        resetsb;
        if(SBintset=true) then
            setintvec(8+SBint,oldint);
        SBstatus:=0;
    end;
end;

procedure setsb_port;
begin
    SBstatus:=0;
    SBint:=int;
    SBio:=address;
    resetsb;
    if(SBio<>0) then
    begin
        setsb_speaker(false);
        setsb_int;
        SBstatus:=1;
        writesb($f2);
        delay(100);
        if(SBstatus<>0) then
        begin
            deinitsb;
            SBio:=0;
            writeln('IRQ failed');
        end;
    end;
end;

begin
    oldexitproc:=exitproc;
    exitproc:=addr(deinitsb);
    SBintset:=false;
    SBio:=0;
    SBint:=0;
end.


_______
xms.pas
~~~~~~~
unit xms;

interface
type
    xmsmove_type=record
        len:longint;
        s_handle:word;
        s_offset:longint;
        d_handle:word;
        d_offset:longint;
    end;
    xmsmove_ptr=^xmsmove_type;
    { For some unknown purpose, varables of xmsmove_type must be global
    and not local varables }

function xms_version:word;              {returns version number in BCD style}
function xms_enablea20:word;            {Allows direct access to blocks}
function xms_disablea20:word;
function xms_statusa20:word;
function xms_largestfree:longint;       {Max amount that can be allocated}
function xms_totalfree:longint;         {Total free xms memory}
function xms_getmem(len:longint):word;  {returns handle to block allocated}
function xms_freemem(buf:word):word;    {frees allocated block}
function xms_movemem(m:xmsmove_ptr):word;{moves data around for you, only even
                                          lengths are allowed}
function xms_lock(buf:word):longint;    {returns 32bit address}
function xms_unlock(buf:word):word;
function xms_getinfo(buf:word):longint; {low word is size in kb}

implementation
{$S-}
{$I-}

var
    xmm:pointer;
    xms_installed:boolean;

function xms_version;
var
    c:word;

begin
    c:=0;
    asm
        mov ax,$4300
        int $2f
        cmp al,80h
        jne @nodriver
        mov [c],1
@nodriver:
    end;
    if(c=1) then
    begin
        asm
            mov ax,$4310
            int $2f
            mov word ptr [xmm],bx
            mov bx,es
            mov word ptr [xmm+2],bx
            xor ah,ah
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_version:=c;
        xms_installed:=true;
    end
    else
        xms_version:=0;
end;

function xms_enablea20;
var
    c:word;

begin
    xms_enablea20:=0;
    if(xms_installed) then
    begin
        asm
            mov ah,5
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_enablea20:=c;
    end;
end;

function xms_disablea20;
var
    c:word;

begin
    xms_disablea20:=0;
    if(xms_installed) then
    begin
        asm
            mov ah,6
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_disablea20:=c;
    end;
end;

function xms_statusa20;
var
    c:word;

begin
    xms_statusa20:=0;
    if(xms_installed) then
    begin
        asm
            mov ah,7
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_statusa20:=c;
    end;
end;

function xms_largestfree;
var
    c:word;

begin
    xms_largestfree:=0;
    if(xms_installed) then
    begin
        asm
            mov ah,8
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_largestfree:=longint(c) shl 10;
    end;
end;

function xms_totalfree;
var
    c:word;

begin
    xms_totalfree:=0;
    if(xms_installed) then
    begin
        asm
            mov ah,8
            call dword ptr [xmm]
            mov [c],dx
        end;
        xms_totalfree:=longint(c) shl 10;
    end;
end;

function xms_getmem;
var
    c:word;

begin
    xms_getmem:=0;
    if(xms_installed) then
    begin
        c:=word((len shr 10)+1);
        asm
            mov dx,[c]
            mov ah,9
            call dword ptr [xmm]
            mov [c],dx
        end;
        xms_getmem:=c;
    end;
end;

function xms_freemem;
var
    c:word;

begin
    xms_freemem:=0;
    if(xms_installed) then
    begin
        asm
            mov dx,[buf]
            mov ah,10
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_freemem:=c;
    end;
end;

function xms_movemem;
var
    c:word;

begin
    xms_movemem:=0;
    if(xms_installed) then
    begin
        asm
            push ds
            push si
            mov  bx,word ptr [m+2]
            mov  si,word ptr [m]
            mov  ds,bx
            mov  ah,11
            call dword ptr [xmm]
            mov  [c],ax
            pop  si
            pop  ds
        end;
        xms_movemem:=c;
    end;
end;

function xms_lock;
var
    c:longint;

begin
    xms_lock:=0;
    if(xms_installed) then
    begin
        asm
            mov dx,[buf]
            mov ah,12
            call dword ptr [xmm]
            mov word ptr [c],bx
            mov word ptr [c+2],dx
        end;
        xms_lock:=c;
    end;
end;

function xms_unlock;
var
    c:word;

begin
    xms_unlock:=0;
    if(xms_installed) then
    begin
        asm
            mov dx,[buf]
            mov ah,13
            call dword ptr [xmm]
            mov [c],ax
        end;
        xms_unlock:=c;
    end;
end;

function xms_getinfo;
var
    c:longint;

begin
    xms_getinfo:=0;
    if(xms_installed) then
    begin
        asm
            mov dx,[buf]
            mov ah,14
            call dword ptr [xmm]
            mov word ptr [c],dx
            mov word ptr [c+2],bx
        end;
        xms_getinfo:=c;
    end;
end;

begin
    xms_installed:=false;
    xms_version;
end.

