{
 EH> I was wondering if there was some way that I could convert a Pascal
 EH> exe to some sys file that the computer loads/runs when booting.

You can use this, the only problem is that the units are not initialized (the
optional code before the last end. in a unit is not executed), and so system
(WriteLn/ReadLn) and crt (WriteLn/ReadLn) don't work.

===
{ DEVCLINE.PAS: Example of a device driver in TP, Arne de Bruijn, 19960302. }
{ Released to the Public Domain. }
{ This example shows the 'commandline' of the device driver }
{ (everything after DEVICE=), and removes itself from memory. }
type
 TReqHead=record                   { Structure passed to us by DOS }
  ReqLen:byte;
  SubUnit:byte;
  Cmd:byte;
  Status:word;
  Reserved:array[0..7] of byte;
  MediaDesc:byte;
  Address:pointer;
  case byte of
   0:(DevLine:pointer; DriveName:byte);
  255:
   (Count:word; Sector:word);
 end;

var
 DevStack:array[0..4094] of byte;  { Own stack, DOS's isn't that big }
 EndOfStack:byte;
 ReqHead:^TReqHead;

procedure DevStrat; far; forward;
procedure DevIntr; far; forward;

procedure Header; assembler;
{ The trick: put the device header as the very first procedure your source, }
{ so TP places it at the start of the .exe }
asm
 dd -1                 { Next device in chain (updated by MS-DOS) }
 dw 0                  { Device attribute, now block device }
 dw offset DevStrat    { Offset of strategy routine }
 dw offset DevIntr     { Offset of interrupt routine }
 db 0,0,0,0,0,0,0,0    { For block: 1 byte no of subunits, 7 bytes reserved }
end;

procedure DevStrat; assembler;
{ Strategy routine, save ES:BX for later use }
asm
 push ax
 push ds
 mov ax,seg @Data
 mov ds,ax
 mov word ptr [ReqHead],bx
 mov word ptr [ReqHead+2],es
 pop ds
 pop ax
end;

procedure WriteStr(S:string); assembler;
{ Units not initalized, can't use some System procs (WriteLn, etc.) }
asm
 cld
 mov bx,ds
 lds si,S
 lodsb
 mov cl,al
 xor ch,ch
 jcxz @NoStr
@PrtStr:
 lodsb
 mov ah,2
 mov dl,al
 int 21h
 loop @PrtStr
@NoStr:
 mov ds,bx
end;

procedure TPIntr;
{ Called by asm proc, ReqHead contains pointer to request header, }
{ Local stack in datasegment used (now 4k) }
type
 AByte=array[0..65534] of byte;
var
 S:string[50];
 I,IntNo:byte;
begin
 if ReqHead^.Cmd=0 then            { Initialization? }
  begin
   S[0]:=#50;                      { Max len of string }
   Move(ReqHead^.DevLine^,S[1],50);{ Copy from DOS buffer }
   I:=pos(#10,S);                  { Search for #10 }
   if I>0 then                     { Found? }
    begin
     byte(S[0]):=I-1;              { That's the len for now }
     I:=pos(#13,S);                { Also a #13? }
     if I>0 then byte(S[0]):=I-1;  { That must be the length }
    end;
   WriteStr('Cmdline:"'+S+'"'#13#10);  { Display 'command line' }
   { Remove device driver from memory }
   ReqHead^.MediaDesc:=0;          { Number of components }
   ReqHead^.Address:=ptr(cseg,0);  { First free address }
   ReqHead^.Status:=$100;          { Status OK }
  end
 else
  ReqHead^.Status:=$9003;          { Status unknown cmd }
end;

procedure DevIntr; assembler;
asm
 push ax
 push bx
 push cx
 push dx
 push si
 push di
 push ds
 push es
 mov ax,seg @Data
 mov ds,ax
 mov bx,ss
 mov cx,sp
 mov ss,ax                  { Set up local stack }
 mov sp,offset EndOfStack+1
 push bx
 push cx
 call TPIntr
 pop cx                     { Restore old stack pointer }
 pop bx
 mov ss,bx
 mov sp,cx
 pop es
 pop ds
 pop di
 pop si
 pop dx
 pop cx
 pop bx
 pop ax
end;

begin
 ReqHead:=@Header; {To include it in linking (smartlinker skips it otherwise)}
 { This is executed when run from the commandline }
 WriteStr('Must be loaded from CONFIG.SYS with DEVICE=DEVCLINE.EXE'#13#10);
end.
