;-------------------------
; REBOOT.ASM   ver 192.5.1beta  ;-)
; Public domain from James Vahn, flush routines from Tim Arheit.
; "oh no!!" idea stolen from David Kirschbaum. 

cseg segment
assume cs:cseg,ds:cseg
org 100h

Begin:
        mov cx,100d             ;close everything in sight
Close_Lup:                      ;Loop to close first 100 possible
        mov ah,03Eh             ;open files.
        mov bx,cx
        int 21h
        loop Close_Lup

        mov ax,cs               ;Set DS to code segment.
        mov ds,ax
        mov ax,5D01h            ;Flush buffers and update directory
        mov dx,offset Params    ;entries. This call may have problems
        int 21h                 ;under OS/2 and DR-DOS..

        mov ah,0Dh              ;DOS flush file buffers.
        int 21h                 ;Most cache programs catch this call.

        mov ah,21h              ;flush for QCASHE
        int 13h

        mov ah,0A1h             ;flush for PC Kwik, PC-Cache v5
        mov si,4358h            ;Qcache v4
        int 13h

        mov ax,0FFA5h           ;flush for PC-Cache v6+
        mov cx,0DDDDh
        int 16h

        mov ax,0FE03h           ;flush for Norton Utilities NCACHE
        mov di,"NU"
        mov si,"CF"
        int 2Fh

        mov ax,4A10h            ;flush for SMARTDRV v4.00+ -API
        mov bx,0002h
        int 2Fh

;-----------------
; Flushed. On with the resetting..
;
        mov ax,40h              ;Set ES to BIOS data area.
        mov es,ax
        mov word ptr es:[72h],1234h   ;Remove this for cold boot.

;-----------------
; First attempt at a reset. If 15/4F isn't supported, hopefully
; no harm will come.
;
        mov dl,byte ptr es:[17h]
        or  byte ptr es:[17h],0Ch     ;Simulates CTRL-ALT-DEL
        mov ax,4F53h                  ;on some machines. PS/2?
        int 15h
        mov byte ptr es:[17h],dl

;-----------------
; Second attempt. This jumps to 'Beep' via the CMOS shutdown byte
; and resets via the 8042 keyboard interface chip if present.
;
        mov ax,cs                         ;Set DS to code segment.
        mov ds,ax
        mov word ptr es:[69h],ax          ;Prepare BIOS for PM
        mov word ptr es:[67h],offset Beep ; style reset.
        mov al,0Fh
        out 70h,al
        call Delay
        mov al,0Ah                    ;Set CMOS for BIOS JMP.
        out 71h,al
        call Delay
        mov al,0FEh                   ;Reset via 8042
        out 64h,al
        call Delay

;------------------
; Failed.. No 8042!  Ye olde standard reboot. If CMOS is present,
; this will also jump to Beep.

        db  0EAh,0h,0h,0FFh,0FFh       ;jmp FFFF:0000

;------------------
; Delay routine, approx 1/18.2 seconds
;
Delay:
        push    ds
        mov     ax,0040h
        mov     ds,ax
        mov     al,ds:[006Ch]
   lo1: cmp     al,ds:[006Ch]
        je      lo1
        pop     ds
        ret

;------------------
; If successful, the CMOS shutdown byte will cause a jump to here,
; making a tone and resetting via a triple exception error.
;
Beep:
        push cs
        pop ds

        mov ax,0E07h            ; Make a Beep.
        int 10h

        mov al,0B6h             ; Make another Beep.
        out 43h,al
        in al,61h
        or al,3h
        out 61h,al
        mov al,82h
        out 42h,al
        mov al,9h
        out 42h,al
        mov cx, 02000h
  lo2:  in al,04Fh
        loop lo2
.286p
        lidt fword ptr cs:Table       ; Forces a CPU reset.
        int 0
 Table  df 0
 msg    db 'Oh no!!!$'
 Params db 0                          ; Dynamic, 22 bytes.

cseg ends
end Begin

{ ----------------------   CUT -------------------------------}

Cut the following to a seperate file.  Name it REBOOT.XX
Use XX3402 to decode the following if you do not have TASM to build
the above code.  The COM file will be created.

example :  XX3402 D reboot.xx



*XX3402-000212-190296--72--85-20361------REBOOT.COM--1-OF--1
iKE+h1u9qQoVsjWAm6vMi+3RihA-nG4o1QoVh05B2vGVjZV1nFCsdTytrRrB3fU1zfxJHft4
Ewoji--8ik6+nGysE+0Ck0P5-b6+B-6aWVML+0O+1VQ+19VHHwoJ7cUK3k0Am6vM7eBd+0P5
-aQ+b+4k1yNku-A+g+faQSUA+91ytaHc-E1e++1zzlusE+0Cq8-g+1c4P+-oyVz11Vys-kvB
290qtYDYMEk1ta4kUiN0g+baEfY+6CFDsjki1k2Sl+5B+++++++++2xc64tj6G2V7+++
***** END OF BLOCK 1 *****

