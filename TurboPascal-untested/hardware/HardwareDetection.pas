(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0052.PAS
  Description: Hardware Detection
  Author: PEDRO EISMAN
  Date: 08-30-96  09:35
*)

{
I finally got ready my contribution to SWAG. I hope it will be
included in the August release :)

It consists of some software / hardware detection (pci boards, vesa
compliant cards, fpu, game port, xms, emm, 4dos, etc.)

Put it in the section that you think it's more appropiate. I think
HARDWARE would be nice (although it has some software routines) or maybe
MISC. I don't know. It's up to you :)

Anyway, I suppose you will include the appropiate keywords, won't you?

Well, here it is. Maybe I have time to send you some other
contributions for the August release.

 -------- cut ----------- cut ---------- cut ---------- cut ----------
}
program test_system;
uses crt;

{
      ***************************************************************
       This program detects some cool hardware and software stuff
       By Pedro Eisman, CRAMP / Dark Ritual, 1996
       Use it, modify it, etc. Please give credit when necessary ;-)
           Contribute to SWAG, so it will always be so cool!
      ***************************************************************
}

procedure biosdate; {Returns the bios date}
var

l:byte;

begin
     write('Bios date: ');
     for l:=1 to 8 do begin
         write(chr(mem[$f000:$fff4+l]))
     end;

     writeln;

end;



function pci:boolean; {Tells if there is a PCI board
               Returns TRUE if found}

          function ispci:byte;assembler;asm
                   mov ax,0b101h
                   int 01ah
                   mov al,ah
          end;

begin
     if ispci=0 then pci:=true
     else pci:=false;
end;



function detectfpu:boolean; {Detects a coprocessor, not 100% reliable
                             Returns true if found, false if not found}
var

val: byte;

begin
     val:= mem[$0000:$0410];

             if val and 2=2 then detectfpu:=true {Check bit 2}
             else detectfpu:=false;

end;


function detectgame:boolean; {Tells if there is a game card or joystick port
                              Returns TRUE if found}
var
val: byte;

begin
     val:= mem[$0000:$0411];
           if val and 6=6 then detectgame:=true {Check bit 6}
           else detectgame:=false;
end;



function xms:boolean; {Tells if there is an extended memory manager
                       Returns true if found}

         function checkxmm:byte;assembler;asm
                  mov ax,4300h
                  int 2fh
         end;

begin
     if checkxmm=$80 then xms:=true
     else xms:=false;
end;



function emm:boolean;  {Tells if there is an expanded memory manager, EMM386
                        Returns TRUE if found (not tested with QEMM) }
var
l: byte;
e: boolean;

const
name:string[8]='EMMXXXX0'; {We have to look in memory for this string}

         function addressemm:word;assembler;asm {It returns the segment where 
                                        the memory manager resides}
                  mov ax,3567h
                  int 21h
                  mov ax,es
         end;

begin

e:=true;

        for l:=10 to 17 do begin {This is where the string starts}
            if chr(mem[addressemm:l])<>name[l-9] then e:=false; {Compare it}
        end;

emm:=e;

end;


procedure svga; {Checks for a VESA compliant card}

var

infoptr: pointer; {Pointer where the cards gives us its info}
infoseg: word;
s,d: word;
i : byte;
fabric: string;  {Card's manufacturer name}

function isvesa:byte;assembler;asm {Checks if there's a VESA compliant card
                                    and finds where to get allits info}
         mov ax,infoseg
         mov es,ax
         xor di,di
         mov ax,4f00h
         int 10h
         xchg ah,al

end;

begin

     getmem(infoptr,257); {Reserve memory for card's info}
     infoseg:=seg(infoptr^);

if isvesa<>0 then writeln ('No VESA card found')
   else begin
        writeln('VESA card found');
        writeln('Version: ',mem[infoseg:5],'.',mem[infoseg:4]);
        d:=memw[infoseg:6];
        s:=memw[infoseg:8];
        i:=0;

        repeat
              i:=i+1;
              fabric[i]:=chr(mem[s:d+i-1]); {The manufacturer's string is in}
        until (mem[s:d+i-1]=0);             {ASCIIZ so this ends when 0 found}

   fabric[0]:=chr(i);
   writeln('Manufacturer: ',fabric);
   end;

   freemem(infoptr,257); {Free the info area}

end;

function cdrom:boolean;{Tells if MSCDEX is loaded (and consequently if there is
                          a CD-ROM drive. Returns TRUE if found}

          function check:byte;assembler;asm
                   mov ax,1100h
                   int 2fh
          end;

begin

     if check=255 then cdrom:=true
     else cdrom:=false;

end;

procedure _4dos; {Tells us if 4DOS.COM is loaded and its version}

         function _4check:word;assembler;asm {This checks that is loaded}
                  mov ax,0d44dh
                  xor bh,bh
                  int 2fh
         end;

         function major:byte;assembler;asm
                  mov ax,0d44dh
                  xor bh,bh
                  int 2fh
                  mov al,bl
         end;

         function minor:byte;assembler;asm
                  mov ax,0d44dh
                  xor bh,bh
                  int 2fh
                  mov al,bh
         end;

begin

     if _4check=$44dd then
        writeln('4DOS detected. Version: ',major,'.',minor)
     else
        writeln('4DOS not present');

end;

{Sample program using all functions and procedures}

begin
     clrscr; {No comments ;-) }

     biosdate; {Bios date}

     if pci then writeln ('PCI board found')  {PCI Board}
     else writeln ('No PCI board found');

     if detectfpu then writeln ('Coprocessor found') {Coprocessor}
     else writeln ('No coprocessor found');

     if detectgame then writeln ('Joystick port found')  {Joystick}
     else writeln ('No joystick port found');

     if xms then writeln ('Extended memory manager found') {XMM}
     else writeln ('No extended memory manager found');

     if emm then writeln ('Expanded memory manager found') {EMM}
     else writeln ('No expanded memory manager found');

     svga; {VESA card}

     if cdrom then writeln ('MSCDEX loaded, CD-ROM drive found') {CD-ROM}
     else writeln ('MSCDEX not loaded or there is no CD-ROM');

     _4dos; {4DOS.COM}

end.

{

        Well, that's all for today ;-). I have some other routines but I
didn't include them because they were so messy. I am also interested on
seing your routines :). A lot of this things can be easily taken out from
the famous Ralph Brown Interrupt List.

        Feel free to contact me for commentaries, questions, enhancements
or whatever.

        Pedro Eisman, Cramp / Dark Ritual Demo Group

        Fidonet: 2:341/70.108
        Internet: peisman@emporium.subred.org
        WWW: http://www.geocities.com/SiliconValley/Park/1216

}

