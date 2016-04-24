(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0056.PAS
  Description: Complete Print Screen Unit
  Author: SALVATORE MESCHINI
  Date: 08-30-97  10:21
*)

{
Hi Gayle, this is a complete Print Screen handling unit.
It can Enable/Disable that key (and get status) and/or install a new handler.
I'm looking forward for next SWAG releases!!!
}


Unit PrtScr;

{This is a COMPLETE print screen unit.}
{(C) 1997 SALVATORE MESCHINI - smeschini@ermes.it -
 - http://www.ermes.it/pws/mesk - Feel free to write me!}
{This unit is copyrighted FREEWARE -}

{Getstatus return print screen handler status (see below)
 Setstatus enable (00) or disable (01) print screen (see below)
 NicePrtScr is my own print screen handler (you can modify it, to suit your
 needs.
 GetInt get interrupt vector for restoring (you can use it in your programs)
 SetInt as you can imagine by yourself, set interrupt vector to our routine
 (can be useful in other programs)}

Interface

uses DOS;

var oldint:pointer;

Function  GetStatus:byte; {00=Enabled 01=Disabled FFh=Error}
Procedure SetStatus(mode:word); {This procedure Enable/Disable printscreen}
Procedure NicePrtScr;

Implementation

Function Getstatus;Assembler;
 asm
 mov ax,0050h
 xor bx,bx
 mov es,ax
 mov ax,es:[bx]
 end;

Procedure Setstatus(mode:word);assembler; {00=Enabled 01=Disabled}
 asm
  mov dx,mode
  mov ax,0050h
  xor bx,bx
  mov es,ax
  mov es:[bx],dx
 end;

 PROCEDURE JmpToInt(OldIntVector: pointer);
 INLINE (
    $5B/   {POP BX - Get Segment}
    $58/   {POP AX - Get Offset}
    $89/   {MOV SP,BP}
    $EC/
    $5D/   {POP BP}
    $07/   {POP ES}
    $1F/   {POP DS}
    $5F/   {POP DI}
    $5E/   {POP SI}
    $5A/   {POP DX}
    $59/   {POP CX}
    $87/   {XCHG SP,BP}
    $EC/
    $87/   {XCHG [BP],BX}
    $5E/
    $00/
    $87/   {XCHG [BP+2],AX}
    $46/
    $02/
    $87/   {XCHG SP,BP}
    $EC/
    $CB);  {RETF}

function GetKey: Char;

  var
    AsciiK: byte;

  begin
    asm
     xor ah,ah
     int 16h
     mov asciik,al
    end;
    GetKey := chr(asciik);
  end;


procedure MyInt(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
interrupt;
var x:char;
begin
 {asm cli end;}
 write('Are you sure?');  {Here you can put your routines}
 x:=getkey;               {Suggestions: You can make a TSR to print in
                           compressed font or write additional information
                           on paper (i.e. date/time, your name...) etc.}
 if (x = 'Y') or (x = 'y') then jmptoint(oldint);
 {asm sti end;}
end;

Procedure NicePrtScr;

 begin
 setintvec(05,@MyInt);
 end;

 begin
 getintvec(05,oldint);
 end.

 {-----------------------------------------------------------------------}

 Program Demo; {Just an idea}

 {$M 4096,0,0}

 uses Dos,PrtScr;

 begin
 if getstatus <> 0 then setstatus(0); {If disabled the enable printscreen}
 niceprtscr;
 keep(0);
 end.

