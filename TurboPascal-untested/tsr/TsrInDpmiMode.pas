(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0012.PAS
  Description: TSR in DPMI Mode
  Author: CEES BINKHORST
  Date: 11-02-93  05:34
*)

{
CEES BINKHORST

> I have a Turbo Pascal program running in DPMI mode that needs to
> interface to a real mode TSR program.  The TSR program issues
> INT$61 when it has data that needs to be serviced.  I've installed
> an interupt service routine that works ok in real mode, but not DPMI.

Have a look at the following. With some amendments it will do what you want.

;from c't 1/1992 #196
.286p                  ;generate protected mode code for 286 or higher

dpmitsr segment public ;dpmitsr: name of program
                       ;segment: indicates start of programcode for
                       ; 'dpmitsr'. see also end of code: 'dpmitsr ends'
                       ;public (without addition (name)): instruction
                       ; for linker to put all of it in one segment
     assume cs:dpmitsr, ds:dpmitsr ;as soon as program starts 'cs' and
                                   ; 'ds' cpu-registers (code and data segment
                                   ; segment registers) are filled with memory
                                   ; position of start of program 'dpmitsr'
                                   ;there are no seperate code en data
                                   ; segments
olduserint     label word       ;
               dw    ?, ?
readmessage    db 'This text is in TSR and is be shown through a pointer.', 0
writemessage   db 'This text is copied from TSR', 0
writedata      equ $-offset writemessage ;calculate length 'writemessage' and
                                         ; use value later in program
;--------- procedure 'userint' is comparable with a pascal instruction if:
; case ah of 0: execute instruction 'message'
;            1: excute instruction 'read'
;            2: excute instruction 'write'
userint     proc far ;new int 61h
                     ;userint: name has only measning within thsi text for
                     ; compiler - see also end 'userint endp'
                     ;proc far: instruktion for compiler to generate code
                     ; to push a segment:offset return address on the stack
                     ; (near proc pushes only offset)
                     ; this procedure is called from another
                     ; code segment (dos through int. in dpmiwin!)
            pushf    ;save flags
            cmp ah, 00h ;message instruction - see dpmiwin dcs.eax:=$00000000
            je  message
            cmp ah, 01h ;read instruction = dpmiwin dcs.eax:=$00000100
            je  read
            cmp ah, 02h ;write instruction = dpmiwin dcs.eax:=$00000200
            je  write
            popf        ;put flags back if ah is not 00, 01 or 02 in ah and
            jmp dword ptr cs:[olduserint]  ; continue with old interrupt
;---------- procedure 'message'
message:    mov ax,0affeh     ;affe hex is in-memory mark of this program
            popf              ;put flags back
            iret              ;interrupt ends here and has only put
                              ; affe hex in cpu register ax
                              ;program dpmiwin will see it there and know then
                              ; that 'dpmitsr' is loaded in memory
;---------- procedure 'read'
read:       mov ax, seg dpmitsr  ;make registers es:di together pint to
            mov es, ax           ; string readmessage. this will then be used
                                 ; by 'dpmiwin' to put it on the screen
            mov di, offset readmessage
            popf              ;put flags back
            iret              ;interrupt ends now here
;---------- procedure 'write'
write:      push cx           ;save registers
            push si
            push ds
            cld               ;direction flag = 0
            mov cx, seg dpmitsr
            mov ds, cx        ;make ds:si point to string writemessage
            mov cx, writedata ;get calculated length of string writemessage
            mov si, offset writemessage
            rep movsb         ; and copy string from ds:si to es:di.
                              ; es:di are put in dpmicallstruc by dpmiwin
            pop ds            ;put registers back
            pop si
            pop cx
            popf              ;put flags back
            iret              ;interrupt now ends here
userint     endp              ;end of code for procedure 'userint'
                              ; van gehele echte interrupt dus
;---------- this code does not remain in memory
install:    mov ax, seg dpmitsr   ;make ds:dx point to string hello$
            mov ds, ax
            mov dx, offset hello$ ;offset of message that it is installed
                                  ; as a memory-resident program
            mov ah, 09h           ;send string hello$ to (dos) screen
            int 21h               ; to signal installation of 'dpmitsr'
            mov ax, 03561h        ;what is old address of int. 61h
            int 21h
            mov [olduserint], bx  ; and save it in two steps
            mov [olduserint+2], es ;
            mov ax, 2561h         ;subfunction 25 of int. 21: pu new address
            mov dx, offset userint; int. 61h (procedure 'userint') in memory
            int 21h
            mov dx, offset install ;how many bytes (convert to paragraphs by:
shr 4)
            shr dx, 4              ;  of program have to
            add dx, 011h           ;  remain in memory
            mov ax, 03100h         ;subfunction 31 of int. 21 with 'return
code' 0
            int 21h                ;makes part of program resident
hello$      db  13,10,'DPMITSR-example installed.',13,10,'$'
dpmitsr     ends
            end install            ;end of installation procedure

}
program dpmiwin;               {from c't 1/1992 # 197}

uses
  winprocs,
  wintypes,
  win31,
  wincrt;

type
  tDPMICallStruc = Record  {for use by RMInterrupt}
    EDI, ESI, EBP, Reserved,
    EBX, EDX, ECX, EAX : longint;
    Flags, ES, DS, FS,
    GS, IP, CS, SP, SS : word;
  end;

function RMInterrupt(IntNo, flags, copywords : byte;
                     var DPMICallStruc : tDPMICallStruc) : boolean;
begin
  asm
    push es       {save es en di from protected mode on stack}
    push di
    mov bh, flags {if bit 0 is zero interrupt controller ...}
                  {... and A20-line will be reset. other bits must be zero}
    mov bl, intno {put interrupt nummer to be executed in register bl}
    mov cx, word ptr copywords {cx = number of words that are to be copied...}
                  { from... prot. mode to real mode stack}
    mov ax, 0300h {put DPMI simulate real mode interrupt nummer in register ax}
    les di, dpmiCallStruc  {16-bits pointer to record - 32 bits uses edi}
                  {les di, ...: load segment (2 bytes) dpmicallstruc in}
                  { register di en offset (ook 2 bytes) }
                  { in register es. in short load pointer to dpmicallstruc}
                  { in registers di:es                                 }
    int 31h       {excute interrupt nummer in bl in real-mode after filling }
           { cpu-registers with values from dpmicallstruc and return in}
           { protected mode with contents of cpu-registers at end of real-mode}
           { interrupt in dpmicallstruc. i.o.w. act as if dpmicallstruc  }
           { are the cpu-registers at the end of excuting the real-mode int.}
    jc @error
    mov ax, 1           {function succesfull}
    jmp @done
   @error:
    xor ax, ax          {make ax=0, function not succesfull}
   @done:
    pop di              {put es and di back}
    pop es
  end;
end;

var
  selector  : word;
  segment   : word;
  selseg    : longint;
  dcs       : tdpmicallstruc;
  printstrg : pchar;

begin
  fillchar(dcs, sizeof(dcs), 0);    {zero dcs}
    {------- verify presence of dpmitsr in memory}
  dcs.eax := $00000000;  {just for clarity that ax is called with function 0}
                         { as contents is already zero because of use}
                         { of function filchar() on previous line. }
  rminterrupt($61, 0, 0, dcs);
  if (dcs.eax and $ffff = $affe) then
    writeln('DPMItsr in memory')
   else
     writeln('Something went wrong!');
             {this part needs improvement.                 }
             {if dpmitsr is not in memory then pc may crash,}
             { which is not strange as then an interrupt  }
             { is called that most likely is 0000:0000 in        }
             { memory.                                        }
             {this is to be substituted with a routine that first checks}
             { that pointer of int. 61 is not 0000:0000.        }
    {------- read string through pointer}
  dcs.eax := $00000100;              {call int. 61 (=dpmitsr) with ah = 1}
  rminterrupt($61, 0, 0, dcs);
  selector := allocselector(word(nil)); {make new selector and fill with values:}
  setselectorbase(selector, longint(dcs.es) * 16);
                                      { base: es is put in by 'dpmitsr'}
  setselectorlimit(selector, longint($ffff));
                                     { and limit: $ffff is maximum value. this}
                                     { does not give problems because we put a}
                                     { 'zero-terminated' string on the screen.}
  printstrg := ptr(selector, word(dcs.edi));   {also di is put in by 'dpmitsr'  }
  writeln(printstrg);
  freeselector(selector);
    {------- read string by making a copy from real-mode memory to
              Windows-memory in low 640k-area}
  selseg := globaldosalloc(100); {allocate 100 bytes Windows-memory below 640k.}
                               {high word of longint 'selseg' is segment for }
                               { use in real-mode and low word is selector    }
                               { for use in protected mode.                 }
  if selseg <> 0 then
  begin
    selector := word(selseg and $ffff);  {determine selector}
    segment  := word(selseg shr 16);      {determine segment}
    dcs.eax  := $00000200;               {call int. 61 (=dpmitsr) with ah = 2   }
    dcs.es   := segment;                   {use segment for int. 61 in real-mode}
    dcs.edi  := 0;                       {offset is 0                          }
    rminterrupt($61, 0, 0, dcs);
    printstrg := ptr(selector, 0);
    writeln(printstrg);
    globaldosfree(selector);
  end;
end.

{
To excute the program, dpmitsr.exe has to be executed before starting Windows.
Dpmitsr will remain permanently in memory.

Both DPMITSR.ASM and DPMIWIN.PAS were nicely running programs in early 1992
with TPW. Now, under BPW an error is reported from the SYSTEM unit.
However, as I now don't have the time to trace the error herewith the programs,
as it will surely point the way for you to go.
}

