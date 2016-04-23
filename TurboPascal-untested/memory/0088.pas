
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