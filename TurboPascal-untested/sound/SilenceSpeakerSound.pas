(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0096.PAS
  Description: Silence Speaker Sound
  Author: ARNE DE BRUIJN
  Date: 05-31-96  09:17
*)

{
If you want absolute silence (no ticks and very short beeps you get with the
timer interrupt approach), and you are running QEMM 7.03 or higher, you can
use this.If anyone is interested, I have also some sources with the same
routines to capture IO access under QEMM.
===
{ NoSound, PC Speaker sound killer for QEMM 7.03+, Arne de Bruijn, 19960405. }
{ Released to the Public Domain. }
{ Run it to install, run with /U to remove it. }
{$G+}
uses dos;
{ Resident part }
{ Only code segment will be preserved, so necessary variables are stored here
}procedure QPI_CS; assembler; asm db 0,0,0; end;
procedure OldTrap_CS; assembler; asm end;
procedure OldIOTrap_CS; assembler; asm db 0,0,0; end;

procedure MyTrap; far; assembler; { Called when something accesses port $61 }
asm
 test cl,4      { Is the program writing to port $61? }
 jne @IsWrite   { Yes, jump to @IsWrite }
 push bx
 mov bx,ax
 mov ax,1a05h   { Pass port read to QEMM, to execute it }
 call dword ptr cs:[QPI_CS]
 mov ax,bx
 pop bx
 retf
@IsWrite:
 and al,not 2   { Clear speaker bits, so it's always off }
 push bx
 mov bx,ax
 mov ax,1a05h   { Pass port write to QEMM, to execute it }
 call dword ptr cs:[QPI_CS]
 mov ax,bx
 pop bx
end;

procedure End_Of_TSR_Label; assembler; asm end;

type
 TPtr=record Ofs,Seg:word; end;
const
 QPI:pointer=NIL;
function GetQemmApi(var QPI:pointer):boolean; assembler;
asm
 mov ah,3fh
 mov cx,'QE'
 mov dx,'MM'
 int 67h
 mov al,0
 test ah,ah
 jnz @NoQemm
 mov ax,di
 mov dx,es
 cld
 les di,QPI
 stosw
 mov ax,dx
 stosw
 mov al,1
@NoQemm:
end;

procedure QPI_SetIOCallback(IOCallback:pointer); assembler;
asm
 mov ax,1a07h
 les di,IOCallback
 call [QPI]
end;

function QPI_GetPortTrap(PortNo:word):boolean; assembler;
asm
 mov ax,1a08h
 mov dx,PortNo
 call [QPI]
 mov al,bl
end;

procedure QPI_SetPortTrap(PortNo:word); assembler;
asm
 mov ax,1a09h
 mov dx,PortNo
 call [QPI]
end;

procedure QPI_ClearPortTrap(PortNo:word); assembler;
asm
 mov ax,1a0ah
 mov dx,PortNo
 call [QPI]
end;

function QPI_GetVersion(var Version:word):boolean; assembler;
asm
 mov ax,word ptr [QPI]
 or ax,word ptr [QPI+2]
 jz @NoQemm
 mov ah,3
 call [QPI]
 jc @NoQemm
 les di,Version
 stosw
 mov al,1
 db 0a9h { Skip following instruction (2 bytes) }
@NoQemm:
 mov al,0
end;

procedure QPI_GetIOCallback(var IOCallBack:pointer); assembler;
asm
 mov ax,1a06h
 call [QPI]
 mov ax,di
 mov dx,es
 cld
 les di,IOCallBack
 stosw
 mov ax,dx
 stosw
end;

var
 W:word;
 OldIOTrap:pointer;
 S:string[2];
begin
 if not GetQemmApi(QPI) then
  begin WriteLn('QEMM not installed!'); Halt(1); end;
 pointer((@QPI_CS)^):=QPI;
 if not QPI_GetVersion(W) then
  begin WriteLn('QPI_GetVersion error!'); Halt(1); end;
 if W<$0703 then
  begin WriteLn('Need QEMM 7.03+'); Halt(1); end;
 QPI_GetIOCallback(OldIOTrap); { Get current IO trap function }
 if word(OldIOTrap)=Ofs(MyTrap) then { Ours? }
  begin
   S:=ParamStr(1); S[2]:=Upcase(S[2]);
   if S<>'/U' then
    WriteLn('NoSound already installed! Use /U to unload.')
   else
    begin
     { Restore port trap state }
     if not boolean(ptr(TPtr(OldIOTrap).Seg,ofs(OldTrap_CS))^) then
      QPI_ClearPortTrap($61);
     QPI_SetIOCallback(pointer(ptr(TPtr(OldIOTrap).Seg,ofs(OldIOTrap_CS))^));
     W:=TPtr(OldIOTrap).Seg-$10;  { TSR PSP segment (just under code segment)
}     asm
      mov ah,49h         { DOS function 'Free memory block' }
      mov es,W           { Get TSR PSP segment }
      push es            { Save it }
      mov es,es:[2ch]    { Get TSR environment segment }
      int 21h            { Free it }
      mov ah,49h         { Again 'Free memory block' }
      pop es             { Restore TSR PSP segment }
      int 21h            { Free it }
     end;
     WriteLn('NoSound removed.');
    end;
   Halt(0);
  end;
 QPI_SetIOCallback(@MyTrap);
 pointer((@OldIOTrap_CS)^):=OldIOTrap;
 boolean((@OldTrap_CS)^):=QPI_GetPortTrap($61);
 QPI_SetPortTrap($61);
 WriteLn('NoSound installed.');
 swapvectors;
 asm
  mov ax,3100h   { DOS function 'Terminate and stay resident' }
  mov dx,offset End_Of_Tsr_Label+15+256  { Calculate resident size }
  shr dx,4       { Scale down to paragraphs }
  int 21h        { Go TSR }
 end;
end.

