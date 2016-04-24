(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0099.PAS
  Description: Access FLAT memory in REAL Mode
  Author: HERMAN DULLINK
  Date: 11-29-96  08:17
*)


{ SWAG NOTE :  The code for this material is attached below and encoded
  using XX3402 }

FLAT REAL / REAL BIG / UNREAL MODE (v1.2)

Flat Real mode, Real Big mode and UnReal mode are three names with the very
same meaning, I will call it FLAT in this text.

Since the  first PC-XT, people have  searched for methods to  get access to
more and more memory for their DOS programs: EMS, UMBs, XMS, DPMI. With the
i386, Intel has  given 32-bit power to the PC's.  Here's an example to take
advantage of  the 32-bit capabilities  of the i386  and compatibles without
the need  of protected mode,  DOS-extenders and/or special  interfaces like
VCPI & DPMI.

FLAT simply  allows you to  use 32-bit access  on top of  the normal 16-bit
addressing.  32-bit access  is possible  as the  well-known 64KB limits are
just registers  on the i386  and can be  altered to almost  any value up to
4GB. FLAT is not new, Microsoft's  HIMEM.SYS already uses it since 1988 for
its 'Move Extended Memory Block' service.

To understand  how FLAT works, you  have to understand how  the i386 works.
The  i386  is  not  made  as  one  but  several  seperate units; an ALU, an
INSTRUCTION PREFETCHER,  a SEGMENTATION UNIT,  a PAGING UNIT,  etc. Most of
these units  have no clue  about the  state  of the CPU;  Real or Protected
Mode.

The SEGMENTATION UNIT only holds the BASE, the LIMIT and some attributes of
the segment registers. These values are used for addressing rather than the
value  of the  segment registers.  When a  segment register  is assigned  a
value, in Real Mode and in a V86 task the BASE is loaded with 16 times this
value  so the  addressing is  compatible with  the 8086.  Most of the other
fields, including LIMIT, are unaffected. In normal Protected Mode operation
this value is  used as an index for the  GLOBAL/LOCAL DESCRIPTOR TABLE from
where all fields  BASE, LIMIT and attributes are fetched.  So, to alter the
LIMITs, we have to be in Protected Mode.

The SEGMENTATION UNIT will report a  fault when an instruction is trying to
address beyond a  LIMIT, or when an instruction is  trying to do an illegal
access like writing to a read-only segment. This fault will raise interrupt
number 13. In Protected Mode there's  an exception handler that will handle
this. In normal DOS operation (Real Mode), there is _no_ exception handler.
In fact, in the PC design interrupt  #13 is used for handling IRQ number 5.
This is  the reason DOS  will hang the  system when 32-bit  access is used.
While the IRQ  #5 handler expects the address of  the _next_ instruction is
pushed onto the stack, exception #13 will push the instruction which caused
the  exception. When  the IRQ  #5 handler  does an  IRET, the  CPU tries to
execute the very  same instruction, resulting in an  exception #13 (again),
etc, etc..

After a RESET or a switch to a V86 task, all segment LIMITs have a value of
64KB, this  to be compatible  with the  8086  and the 80286.  As the LIMITs
can't be altered from within a V86 task, FLAT will never work here. FLAT is
thus incompatible  with environments/programs where  a V86 task  is used to
simulate DOS, including:  - MS-Windows 3.x in 'Enhanced  Mode' - MS-Windows
NT - OS/2 2.x, Warp - Emm386, Qemm, etc.. simulating UMBs

Some environments/programs have an option to disable the DOS simulation:
 - MS-Windows'95; check the 'MS-DOS Mode' option
 - Emm386 simulating EMS; enter 'Emm386 OFF' at the DOS prompt

Due to a bug in Qemm (7.02),  its simulation cannot be disabled after being
enabled.  As  long  Qemm  stays  disabled  FLAT  will  work.  I do not have
experience with other EMS simulators (e.g 386max)

FLAT is fully compatible with:
 - DOS 2.0 and above
 - MS-Windows 3.x in 'Real Mode' and 'Standard Mode'
 - DesqView
 - Himem/XMS/UMB drivers
 - EMS drivers

All FLAT actually does it jump  to Protected Mode, alter the segment LIMITs
using a DESCRIPTOR with  a 4GB LIMIT, and jump back to  Real Mode. As other
programs/TSRs may  enter Protected Mode,  there's the possibility  that the
LIMITs are altered to 64KB again. This is why I have implemented FLAT as an
exception handler.  To allow IRQ  #5 to be  handled, the exception  handler
first checks the Interrupt Controller if IRQ  #5 is 'In Service'. If so, it
calls the IRQ #5 handler. FLAT will  terminate the program if it detects an
instruction  that is  causing an  exception #13,  even when  the LIMITs are
(re)set to 4GB.

To activate  FLAT, just call  the FLAT_install routine,  to remove/deactive
it, call  FLAT_destall. As FLAT must  be installed on top  of the interrupt
#13 handler,  FLAT has to be  deactivated first before any  changes to this
interrupt vector can  take place. As said above,  interrupt #13 is normally
used for IRQ #5.

FLAT is called FLAT because with  32-bit access the whole 4GB address space
of the 386  can be accessed with only using  offsets. But as the addressing
mechanism needs a segment the format [0000:<32-bit offset>] is used.

Using XMS, when an  EMB is locked, the physical base address  of the EMB is
returned. This base address can be used as base for access to the EMB:

        mov ah,09h                      ; Allocate EMB
        mov dx,256                      ; 256KB
        call XMS_driver                 ; Do it!
        test ax,ax                      ; Error?
        jz alloc_error
        mov ah,0Ch                      ; Lock EMB
        call XMS_driver                 ; Do it!
        test ax,ax                      ; Error?
        jz lock_error
        mov di,dx                       ; DX has high word of 256KB chunk
        shl edi,16
        mov di,bx                       ; BX has low word of 256KB chunk
        xor eax,eax                     ; Clear EAX
        mov es,ax                       ; ES:EDI now points to first address of 256KB chunk
        mov ecx,10000h                  ; 256KB equals 64K dwords
        rep stos dword ptr es:[edi]     ; Clear 256KB chunk

32-bit access is not specially meant for extended memory, it can be used for conventional memory as well. DOS allows memory allocations larger than 64KB which now is addressable as one big chunk rather than separate chunks of 64KB and/or less:

        mov ah,48h                      ; Allocate Memory
        mov bx,4000h                    ; 256KB (16K paragraphs)
        int 21h                         ; Do it!
        jc alloc_error                  ; Out of memory?
        mov es,ax                       ; 256KB can be accessed using es:00000000 through es:0003FFFFh
        xor eax,eax                     ; Clear EAX
        xor edi,edi                     ; ES:EDI now points to first address of 256KB chunk
        mov ecx,10000h                  ; 256KB equals 64K dwords
        rep stos dword ptr es:[edi]     ; Clear 256KB chunk

With the new VESA VBE Core Standard  2.0, the entire video memory of a SVGA
or other video adapter that  support linear/flat addressing can be accessed
as one large  chunk of memory somewhere in the  4GB(/16MB) address space of
the 386(sx):

        mov ax,4F01h                    ; Get VBE Mode Information
        mov cx,100h                     ; Mode : 640x400, 256 colours
        les di,ModeInfoBlockPtr         ; ES:DI now points to ModeInfoBlock structure
        int 10h                         ; Do it!
        cmp ax,4Fh                      ; Error?
        jne VBE_error
        mov ax,4F02h                    ; Set VBE Mode
        mov bx,0C100h                   ; Mode : 640x400, 256 colours, linear/flat, don't clear display
        int 10h                         ; Do it!
        cmp ax,4Fh                      ; Error?
        jne VBE_error
        xor eax,eax                     ; Clear EAX
        mov edi,dword ptr es:di[28h]    ; ModeInfoBlock[28h] = 'PhysBasePtr'
        mov es,ax                       ; ES:EDI now points to first address of 256KB video buffer
        mov ecx,10000h                  ; 640 x 400 bytes equals 256000 bytes equals about 64K dwords
        rep stos dword ptr es:[edi]     ; Clear 256KB video buffer

Accessing video memory  without the need of bankswitching  really speeds up
video  performance. In  terms of  pixels per  second, drawing  lines in the
1600x1200,256 colours graphics mode is now  faster than in the 320x200, 256
colours mode.

The only limitation of FLAT is your imagination. And you'll need that as no
high-level language DOS compiler I've seen (yet) supports 32-bit addressing
without  the need  of some  kind of  DOS-extender. However,  FLAT will link
smoothly with  almost any 16-bit DOS  compiler. I use Turbo  Pascal 5.5 and
6.0 myself for the body of the  programs I'm writing, and use some assembly
at  the places  I need  the 32-bit   addressing. See  EX2 for  a very  nice
example.


        Herman Dullink
        Groningen (the emulator city; CPC, MSX, ZX :-)
        the Netherlands
        +31-50-132829
        csg669@wing.rug.nl (fast)
        herman.dullink@prgbbs.idn.nl (1 day slower)

{ ---------------------------   CUT  ----------------------- }
{ cut this out, name it flat.xx to create flat.zip :
           xx3402 d flat.xx
}


*XX3402-011730-281096--72--85-57319--------FLAT.ZIP--1-OF--3
I2g1--E++U+6+6+8+FyMIbnt-k2++2E0+++5++++FJUm9Y3HHKpFjIv1A-1S6zYRPUEF3PLE
eUcHG1+l6BGhWd-X5ooYCvNwGJjS5Xid2uCGkSTvziuGDA5sj0bSkGRmRFwCS4YCc6p2ZYL-
utZfel-KArHnPFnoV5-eiVdqjOgAT5+GrfxSf64r2bVZXbX9AdM7blNAV+SBPESqfpEX+bB7
+ovIOuwFJ6VVR0HaqqXmqvszvvu2gHz-DnJFt6nsOqDNsa4vGKCc1fKmAuPB2IMg7rghZHFX
Gh7EYNeQeBVLxavtK0MwLbUtwRjmSV88QuFHBxJicZQnvB-4Bs2w4GT-RgvjICnxb18LsI7B
2aHBu2VLXpXutUuvcGsrzrpBP8JBztzjYnnTgSkLI2g1--E++U+6+6E8+FwzkeFbV+I++8gH
+++6++++FYl-J0t-IoqpK4pjqYUEzcv2TtWHeWNJLEs1XJ9m6KcVXG9paZvUqUxFVFNvgDSu
hgbiah1yyhjp4qhvHOueuYUEvwiwD1Dvv+kLY1zj4N3kVsHxeHzU5EoUGbm2otov49rcxzcx
HvyeFq+EMGlVausNxTFA6E8624aYpbVWeVSPIzZWdSP1qyK8lY6GldnwnQTgHOwqNvBRDD5+
wZn+HPt6t08Ys+RJdZ6FPe1viM-NWBsrq0EQDWtTPHE2dobAjYAGkzXwvCK9VWnXBRba9iwD
MrgZ7Vg9bQYkf4xhfZLvBow8LrRiw87heKdhODcrnW62QP9uiCnr-ge59HnxLA1WfwILc+86
Udni82AzE-xo75XeGNf2dtQ43W6GXvZ1HyD8RHN3KHNcQkt0d+dv7cEtfib-Xpl3a5+7bwoB
HoRnELM68ce-UCQkLmXR+FIGSHgIjX0kN9EREmFv-mryLQ+pGfWtyzgpvB0HOjJnK8WFRVd4
mEtmJMsNy56Mprj53xDvwGHwqdvpl1FVzYffQL-hqTuMQ-yqYYAdkoYq4r5I2CKF7qnq8E3b
Gc-ddEVN-QD2WjKvZ16TfZamJj4Rcz+srKcsZaHBo8+2rwypJ+MfpuvbmzjFJspjCyRxoFLR
ClF8+Ne-JS-bsSsu7VmZddLgC2kB727by0OouTX0eIG6I+UGc+KfTEZn7b6JWO0RKtukSLIM
cr4Kxn-mEqiE7fCV4vNBKm8DO2mISMxIVc0Q8vEnHbMvN-SCOmi9OLyRTtwgEmcoikOQF+eZ
VtFm32+YA0F0+ca-XgzDlDuD2wQRCWTDHfGonyRbotehjkuX2jbPE-nx36WXHV+94mgd3MUn
2gS7-7seh46Ug8BQdcE-liez7BOLN+qztiq4gPyhlchPwDWhBwTKfKTXheDwOCL3uifOCpNG
DtmyVDYazTpzjgjcdq8p1VvGFDPfhB+WU0P07T6JGn2OlCfvjByvbWxf0jn5zBhxrJHwUINI
keZv-ijj2cJlDnPr3gaiF1j1TCxhDe8HYAPUdNnfWeecf+O1EPSgmlM+zwGdEBxooqjg4KvI
2pdgLuiDsK1UjfMNLuHtdODyuhFD-3NvFyAXSxwoni+3jDIw3+6s1I6diXQCjIpMrzW7-+U-
7r5808TmCvnAbJ1s8kTS55CUTLRJ1ckaUw5MTJ4-7t0Jmz+VnEjX0hFLCc7uOPxLdb4Zmmzg
vjQM2L7phTRKvfUtdLSgx6LJx9PG9kLDXfyNb4KVt6Zd7Q-lHLyIBhne8epAeAmoYAEyErvN
JJnZBhf8p8uXxZNwUowrAu0PL+AJQ59nwRLWuivnnSnel292n-ayAkUuGEha5MMCMMNVFHbv
v4KBVgj1uMnAQhcc54jXhd9wrlxUwHWDl9FSPrJUCxCIIN3SUKZbtSsJ-3AfRvctfuNqO9VS
w3Niw9E81LP2de-qsbZdZ18GwP8RUcKMchXSHvuqOZfWypkTnKE1WxifRehF25UnjHDRYR6h
E2y-d-4O8MRa+4e01F+AcHbxNtr9MGY9z0nY1soeoW0oVDXuSA7RuktcNrUUM0A+VPtJpjgK
XCIp6fd+bBoNgGdinemDgQTa8hOZuWSSGDEYyYIrp-GgVCOyKsx3FxXTAyqGoOS-XpYtwt-W
WXMAGbLfjRBYD-D8mTIOaCNLOwTUq3cGh+xjvAB-DanQkP3TseWf8hTGQV1j4wUYytLW8F-p
+ZYGc4egRSUlGsB+q8c76kSOavgDMPatRUvBAkpkf5qR7r5qawbWxadeYYanSX2J8gTlKAwL
CgCBhIGTAGEQVAQFsrPdukt1in-nzAb3jxUQ8-lyKrAkzvYCOxnN5FF4hfi1FT2nqSpC0IfX
kmLRvUbofJyKdCKjPCfRw2WxxLjz+J-9+kEI++6+0+030U2TkwUy71g0++0K+U++0++++2NA
EJEiHo78HN79O-BF46Lz4yCoXOZHW-E2GKt0E2Euc+Z-J0GVWG-42wUUUGtYKaSGE18dwuXR
39fGO2jkFF4NE-uPi0a8EIc3WKqgrMFYoIKZas9WUqn3VEjXDl483vvVrAAQvjoDRx24kp7K
o9VEshdOUE9+0JtLdjAod8dWPXcf8dHS2-IpYtSdXnjnj1+4kFzKtJ5LESd1sF-OoFI9EBeI
ZOQf13UbMy36tBYEd-S6VN+v1lo+l5st4i7jLfaSs2DF87voyXwr5-asek0CUVK0JT8cj+22
k10GWny1wN6lJHfzHHz9YjouoKwNnhyGfpbQZNOQTd0sywsiT4Hww+aKhqg-YBvjKmKCA-jU
8aoqFhNXQBHJReyFOBjBdnAebJLm8IL6IIKwfKQIIOK0FfCWc4dIY4b4RmuUnfhhLUkKzUIh
47kIN1ajIIL5DqEeo9aAciZ0ZccmefmQ2qIBAwv-dPV83uGO5pmPswNlO7rYGKg0iMW2YELY
1IxKewS+jAAN9SOQECsBjbiSgUp62pVcsbP9C+kh0oz0NEP6BjHvHonFVgSRoyJLE9dkg9VT
n0sErFpzSSEfvQ2LKeR7nQ3haOv-xP4UUMOC37RGGq2j3bG-qE2h654p5S-MActbphYmsomk
h4Ybf8TNUvT1IBkfPVMz3rjSDyVAiMPM0jh0GbOynzEPP5ig+QX6iY+4DMpWHkYlNLN-MrCW
MdMJaNwFNnJwDRWCMfWVNQTdDQUdV2Ai6F5Y8b8L7xI5y6uojp-9+kEI++6+0+040U2TP7Oc
rWU1++0A0E++-k+++2JMAWtEEJDBJapjaoUEzav7Ty+yXFF9EClMU7q+mvZG9eaHecbGGdKG
8cdCj0m4Cw7Og2t-JTxvNrQ-UoCWxAjdJd4+qKSSbLZaRdlBFhSNykWYA-rMtWE5DqDCQ1+Q
y1HB4TUoULTkbKM-943YK9eCam-KF+fQQfDA9SzpuREsTU+OUVyt4I6JrH-bwyAHmpuQzbJq
za4Z0B6brDHQb8-XEhBpb988nczEl5qfPqwPxd-v7GAJ62u10Nf08ff8yVE5PHTPK-X0IGHU
SXZBhcn+m9BpzJqRGR28-Yfwe2sN1buAfW-AL1OZrXwzVkDImWT-BWCkiXfxybSAyfV7se-q
X4GdanXD6+3t1d4oe5QzeowrdNfbN3ob-fbAgejLzUfO5g3PD-8GfZaoUqaR81q0BivMHNIV
t724F1qvgLIMksean0tgx3pHFchGBGS47d62KNkZG7Z1aj4G0EAk0dSlScjTpquVMPXE50SF
NMCn3goq9ysxYXvkHNxWB55eeqXEU8Gh-i0M6ogLg73VnIuRlXeTppPnbCCZ5ryHHJZ5at2B
QNZYPB9UXP6IE4QLuRhmUZNhxMYwP0lw1w2saE+KHzKqcQMvCezSX-CheRmS7dmxGaZg5tKp
62W7tJQXIhmf-SFF-ae7XkFAHEAL1lih5ZvWB6uTVRm6CHPAgLacQivmjOKBGznfCFD1jYQv
DrTSCeR3AzgBaaTlvbVCNVp5uR1URfo+cY288KLR9-BPpyHq1gW5nl89vUPzYh6-btQ5PHGg
SEtoDVOusg0PD7iZL0X6QI2NjThKrt7xm0K5-AFLSMBoCq+5yfUDCanpLNz17ysEVr+PYMnQ
kLgkUIIYfKDNN0FEtNsq2QxjTGnLLNMzkSukt3jTTkD9HIi2FPw6bwJ-uSgWTBY5jGc0JfdX
OPS6cWjHeP7ELWWkLC8Se+gseh9Lt9Lebunp8-3DrgMdNKcpNBLFGjeKKjxI3ahQnqFlKTmc
jfqJOzyljpSP5ceC8eRQZNImOEkiBsHzItYKpTns1uJeNUVzqOMgHjX3Lw8-OJIz8QpjNS9a
sYK4NeoodzDTkL0+9BDVs6xTI2g1--E++U+6+6k8+FxP5REDs+2++3s2+++5++++FJUl9Y3H
HLpIoKvHA-FxfxFzC5pV1uGEA6Ge3Vsq8BCYwP6VxX-Bm53i4oiC5RYi0rzDRNAquNNVeL3x
vzL7CQTLKO2RrvI6i0KVrwQ59hIKZGpcCXYIf-hFpNeEHGTHWSFI15fOJaE0uZqiZMmNfVf0
ypr3BR6jtFvbYCXzIFCQWOyyiTXtKlYTVBN9Ew6ZPOWUDXGqrvfhTgvGh6mjdWPPfqhbNNlL
FwujAN+AXqQAA-WAM2HC+-yjQcWWQCExT0oY1OJKxYwfiIbCAH7Ky4eprHY2JhmtSgUdBezJ
k-9SbGwyxOb4iUCgO2NV9sIbfCzkSMsoHFzsZnt4bCT2m1D00BwmmHPZTzVykLqd+g2Ot5d5
9l4wGilassZJgHBWCp70VIeMJvvUFrZevPTfm1nM4dcq+Jsu6bCkyGKGP773Cif1jKhN2fEm
YMDCZapCqw9bS4qgQALI-KEtP10K3Ok5bekfI+T5xWoTKAPXQRRRg6vqiz+K6UGbwbuvhWkc
nhakFosufKjgImdglGxmTr3RpRM3MQ7gBVgWC+dlqFaBcdBp-jncEYxgEq+5RpuN9EfZG-tR
XHaCbUqOjoRsUzADwpk3h6TdcEliplQrwxWfgpag4RsjAYIxz+XkSb-QjCdiBljk1p-9+kEI
++6+0+0D0U2TXg6Rq-sB+++m6E++0++++2NAEJEiJ3VIpJfzPxisYjxt0zFzaAA1nUZCQKmb
nOLdrPqp2nQpBavmseHPiwKWc0LOsYMWxIX8LxtTTnB1mNORy5Pj8r+-ifN3QXXnaSyXzLHP
TsG5MTwKHgD5M5G1Ltyyw6zlrTIEXVPRRizsvNirPntZkgC13-bY7d3Fy1dEQzs7EWTkd1T9
68k2bpcdEMhQCZUeby610Ehdpy1k4SFGO8Lb2MlkBQgU3jUTtM4tIVdr8kRSfbmPfdwc5Iia
A3DKSPWzCjbq422VHN37GAJ0UdD0leZAM4MgIjSdGN0+UPbo6C7MCjuJ4ljMtGytl6wpbo1O
mg9prEE8OyNKtCsGViB7-2zXUMjU4rqxjVyDqj-n9MkuinV5zfKL4P9UM8sKIgBNvqG8QVFa
8GrRG1jjfpei1NyZZGq5hsBQWNkMdqLlX+kZ0u4xa2gkAntE2MZ36OMeIpsVWBIGrQcGl0Mj
V3THf+9MZ7srO6YUs4OIkwjMmuFG4QdqUbV8bIV9L0Gb89MfN8lEPEeZg1C-A24aY8CjJzQX
yDgUASiTpC6IQfo4p7FNCZWPYUEcrMPR0aO1qXB3nOwqBgQ9iiRVGt7Mr6COPyyREbIL-ZRE
5Y+kuSVGNhb7gnN91STjTVcUNvbmXerfhx7tg58ib0RduAcRP-1Y8R97Q-I-E1N3ZVgw6jEO
3W6f7NE3DLtrAqVLBiSEJMzc9GAMexUONqMSpTJtB-uCqtBzbG+78oKm7cYRaOdXcylyi9VU
0m9KKaCnY1+A80Qk1jMpm2nwr+6bvI93Yj3wFC-M2NvMHQomA92oxhZ310oPhLylPGAaPqr1
MzqvsXwL0SBbh6FdWIn8VPG6jtA3TbeIKmCX5wY8yvRD2LqCjYkS5tui5YRrLy1yMTVdy5Xp
STW+Gn+Nrcm5LlvvjDHoNTF61yzvBuAjBxJDuSAqX+bNc4tLLF1MpkNWkZdAOyB2ETn4mezi
bnu4G69krKzARKmG0WHQws63Z0lP6lFN2clYo7wA6ztqClfXAU5ZH6uLSawJEf-p5GTbiREB
***** END OF BLOCK 1 *****



*XX3402-011730-281096--72--85-32747--------FLAT.ZIP--2-OF--3
iq5sY4KqW4-MeBkEEfOK0cVPGguQWa-akM+C2zotZFe-qZwV3EaYCBRsVEVI6cdp1A4s1eG8
nbt3XLfVbXQWoi5A096eXeNRL3QIKnZE-ctQW1MBnb3d4mOqMTWWQr4ycnMk9C3AGMGJS28p
7IG+AMo0AZfANemVBclovRSvOUD1JeOAPj83LlVKkQ3DuIGiudU9BvRrUzvhuSrRJTwKfcSH
esTFzSDR+nnq-vR1a3aHkl7N6pzC8jseZKzJrR+oAHeHbV7-4mMa0evjdRpO0AerZ-jraYc0
z+wP5yQe8khXDKdd7gfA2rwu0COw9KCKbd8LLFC0l2-E0BupBgFiXGd0w9hb2wD9KGPbW5MJ
8nZ29urmxEJ+YSa2DOCmCX7h73Flm3k9tKE6x9MgDCUmbm6irHBKttsSmFkqmGeK-HCK6hVN
Q6G8NbX0iasO-OLFfGIQPSnvC+e2GQHjqblzGNidn2Hgcp+2ICu2F79HB3XzIzRgMpFYG5mM
g-Uxz8KKurq3U+dV+U3mS+plJbAy1zuvRZvaEF2jAV9REDuggZ-x2DozjRw+6JQ3MiOOLZQv
p5QhJzvvjZu9oZ47MbFJ41UjsiSc+EB7ljnFnV1g4lGKeMdHW+I9HciPUpLESML5l2VKsyVV
y-XJMFSwdN60iN+f4NRSvZJbXIgXVAuJ4NiOofg4ERkSWPZEydVHEQU5v1vx4HaRU6TVNDV6
ZWv+9NJ5xhZSuzUKgJzLYH9sNz-BgEqnZDmXeW7YXnoIonUOV-wxWb-xpr-v8UdOjZYKVCW0
-5N0PZGZMh80din7eFP6PfSZUYx9Fq3mXl4d3wcOHQ8soveEf+DMBeXLhcjGC7KL4SL2uvh7
6z-Sjbo17n0SbDmgR29JpZZvFT0rVVcJ4pRiqhfTxSKFbxlBHbjEOuwWy3bMUVwBwtn9pPz6
D8zIJBxBaeIeZkhhmdmjGl4ocg22rJBgIYtA8wwUlufd4PrDTij1yswEdn6C0Oq38rG+NOU6
BfVgAXMQHnsWEqFAfKfpvhCb3UWziFMtn+hDr3yLAdXLh4FX7K5Vu-zPbRtllDLNZYCm-eeL
df6K6k5-BXiJR8zIz6lh81DsU4Yt9xNiSq-f84EWPFVFi0OeX-J3-ugY3MZg5055cY+p4wMu
C79hCO-IiJURPkdh0hlZZerr1Hr+GX9rqdqEyeNa6EzNmWPihbVjOo7Jd9-BqvaKvexTZJnm
XwweZzbdhz5Yx4YwUAGeVPEiu+KNrjlyyuOD2XCX6jOZ62MtmWUDjtItpxKvuGFetC+xLmyt
HV5BpAxU0GfBByI5QgyIds6gm4kf7hND+9MqpBD5mMC1L8kfgxZbdIthl2ncC8X1KcSgpUUL
kiso2Bm-Q8nP7dNZiYORgv8dBN6YK4oKsjLYWMRBu81eE-p0KZVCchqkjcbWcSpZ1keQXnP7
wAdcPop4ixGg7cfAhIMO7e5ZO9JVB+Bbm+asorOjN6dqktmFReuoeD70VGmFlzC7x7noxecK
VczeHJ4dR0xFF00dDJvKOOe-wd4JlovuiVyfyWC-R-T2+f2JVMuDdkFoadtxdyjdUHKZJpdm
gKRZPVPmB73w5DLWcr08HmGGHv1Jg9EtINq4V6Q9b7iPrShinJ2VJKI6uja1wefP-0YzO4ce
Nq5Gg2OZ0HoDmNNHq7PY+b2oZdhJ5UAIaMW1FHiV8hyCLdMxcQX8phju7mWmrMkTQN04TosZ
Zkn-gLNf54unItB7RfSuVb23Af8NFJmQPzddDZGr63li-aKPqEkJuBck85rRjHTOY3kG0AfZ
D7lkXRu6FncYXsRTCjVryIwJTs5WjzmueQ76i0SalfCMib+SXUSVBMeTOywdofJH81xAVLhF
ZpLvfTGZpFHTqNRrRZP0pWo9fr35i7YWJMEiWOQTQfA+YIOR1mawyjQFyVamFtOANuc1mGfe
jHwzR+0LTe8RP9UcvjQESpzNSKp+yPz1fJvGR4AJWRIVcYBfXTonPjrhPlm+siyGbXEYi1cc
kGr0Kr5zjwMHeL05dIF3mM4HRAgrRg-InJD8jXnmMhkUHYjxX1FQac326hrn9Q5dMM81E7+W
wyjoJgO0F55Y+LYykZIaVMJVzphpcLE5NGTV7tT1ul3cj9+kGbgqfF+y4YOvmkBHXJRFZtkZ
DKUv6DxOWglFoc82d53spgc0b1QiD650cnXiwVS2uBQRzbRiTDjaFJB2-IspBwnKDAXpv-ym
5bi3gKeJP9OyF5hWclRGIouUKL2MXm5cBCZfQq3H1FTfdS+ti-oJ6ymwbg7kAUvR2A35UtK+
a8X4VnnyIjAUlQs+lwZ0w00AZpnRLxE1oEm7vDXpisjTxygktujCH3TFixSJgpLDITTw7m+y
tZMIeHj4ckdFv5IDr9LfJvz3HERyPShRmNCRUC8Tzt+pJZfT0zEVj2hrqObyO8tjmbZODHjv
V5zdTxctS5SW6jnrzxgtBWw1h3n0py4Y1pw5EvWWr9ydhbjhHZLKOOxkMO2GOKc9Fm22H9vS
x8Z51cJgK-S785kxP53ZkGCbH4ZYsbF4PqAOyLJTOtI1gARI9f0l-VuCVcuoaf0wilYQbLPD
lsDXUkL+YJgRBvlW3PrvpCYSgD+PuFY2bWCBRAXirC1lsO0Tx61OyR+ZeeOnShR-q0V7lWMn
7HISDx0fXYF3h6Y6wpnxrhhRgrZVBHjP6JGgdNKJnrIvTwXbsfk6QeSzbwgESUFUBvomN9o1
Y2oOY4qXGCTe+31z6IlFooUWG+kBDK8qrIGt6VDfznD-zkg7Yr7yok2HxIjj6jpp8zJ4YS5t
DoDfDZqvUL1mrhjKzrXS1Pss9KQnOTxEV24Jk+dE8H-Roo0uWXJ6fPDz99kJyKx2cJrarfvd
gzxHEBU7AOyx57k8zFnaQTm0Er6eRkJLtqJFbGyYNSzJp7KAB5S3X2qVJV63k5JkAXMuWG0l
MYaYmDVQ5Jau8DGeqyhoccO-+iQw3PjkfdU9WWLAVDBpWetCbzIuexuSRTCNnLmSCl-y8lVa
CgVOrTygQHScLAmdXSI-OJwbx9H3MnqSbkfiJPHV6j6YYkiNEGPoj8ErgJGAoDV3IKAxOj2P
NebVO0rxQFqDrOOPqgPWpx1axp5DGjCDtbjMBbkqGtclBcSC0C2niBkMbqPfOVemTLhNjIVh
gYS17yfj5YgvBL+j51IzvxjjSKtmrit+jbMmaqrSiIlBgeu1yqOwBqfZxGi3A5+VWi33abAm
bx89rm+JhuZsc6NFjYGV1FAdMTWh3lebA3bK8dPpeqxKsRgrDrmKN3xkLKMYBHusgMPyjk-0
aZBaBGW1KDbpFvWujsdUDDYKkPxxUwgHedhcplR7WFBJlovo1qTRYzSRYytNvu9rUG8MatyT
TzWFn9BhmrZPNr-2tYObIvuzbMHvTmngT1dpPNJcrhK3F8n-NTEi5rTzCp-9+kEI++6+0+0G
0U2Ty4vfpO2+++0c++++-k+++2JMAWtDEYdfs4FUHuokobAAxUreI4-UM7+78Gp8mZRk90tC
nIr8GGpGI+V99GfCnAxHABMnbBL-ny1kIe4DJluamP414GXWAsq7UG21l3ksNFcP+sinjsif
uklqVUlN-WN4lVgH--UM41bRT-l1sdrx+m8-hYnhM43kKAEsQM2W+mA1EqXr4vaocqJwOITe
CB8uzJXG1ftYydmKjZEyxd++kxgicBYZ+3-9+kEI++6+0+0H0U2TJqD2yQA-++1x+E++-k++
+2JMAGt1HopBYHpc322MVaR4KOC7HY0krDpK1vhgYHgCoSPwGFRlAJSQd3fjNhO3r4mQaMpd
V5EWYGqgxw-knMYK3ZR2-HotI7jXKW3Bz22DfVI9-QzNgoWyMjVsVlSSVqxo5yoSEMDtMWzh
RNortn-zWvNaoIgTDEyTTTYnagBxUChAeG-YQ2x4KXA-WMd206p6gfc4JNTANDZTbdu5si90
vIV1n9ZWKY2YsCPGtSK3NhlUfUg+uD-YKKrfNwJjNOihWnyGFMfrCnVdNDNjPcUywKqvV9Xr
oDP7-ui2Pd355xhZlBzh5yIShesEdxLj5bwpl8SQUPi9ZkRixIuYM3r4cEmO6BbRl1+e01Gg
gI-d0+F2lEhZhSaS87XW17YKWGZS1MG6BQV2tA+-P2FG7w2OA44qK1GNo8NXHu4w5NzkRUYt
zERv33J6vX4NaCTlw21AyqLJ02tQzwLgRlWXPx0-aXvhjQzHn7gMcyaCVhnbsTOpUX4uN3K7
9bCjLGISlKQeV5Pc2whScR0PkzFgPslSnu-o9yqbLxBlsOx7JdpXR6QytPLVe1vdog3wptnG
W5ry9rPGW8qkA6S54lhAtbN9arKqfeBM47pzI2g1--E++U+6+7Q8+Fyv04CgD+o++7+G+++5
++++FJUm9YJMFOpMTpFHRtOzvmQVE69G6jJ52UeacpMKW8IhF9EUoheVF-F3LCeU7KfLcUoj
EKSelX6xBbaIbSvCv7Zmx-kkvFlbwMxUQrOTgBg4UY17EG5g5ZVdCtOuxYhXbLPgG2TRNCxv
+MhnSiPgvhaQQzDxtbvjjRzDzRvvvjqyZ3Lz+hFUV2Hs2TiXRogcK+z8NmYGUuF0Kcmo52Z5
+Pl2+nWEF8ESd04Y2B62oiR6Bt0yFPe1Z6+4BW27G09GPt5C6rIVyN2yFJ8n+CZ6ut0SFP6U
PIAuU5E2OF5gVdJ6iRFic8+DDY4OzqY3NC1LPeVozKTH1NfgMmK4gfGyUj7Sqi93uQDoPgXl
SzN-qwwUytdfMmH5Lv+lojUHXlL0P7GrEXxT1nWBsB-CUpWs1oOzy+0YZbuXWsjmyw-NK+zZ
xejhyq1pFV0zapgQsD6LmPn55y0hLhFi-PFjTkzrh60b6fNr5qy-tZvDmy-8DT+U2+QnrIfR
lt9Xhu1y-FP4fiO243F8GOq+0YjnV2LO-XaV0ciIf+nYjxVtgBjeoS+34dLS2ET38rrwmvVN
umzdDZWiVFBHSDnTiRxUIMPVoQ3-FJkQET0Q0ZPpTUzTZGHv4aTjy5DPgjsqSEw2FVskBV3P
bvCdu1SmLUXHLifLHCzcpRUyWQ1oAXrnRZcqnquaBXPvrldByYh4Tw1NRGXztwte-KNuIPE7
Hmmt0IA1HFVkGmm2iD6rYRN2NXSQqEdhKw4AaHnR1zAtdLPBj0mPzUqMbvIbBKJNo7Wi+a1u
Jq-ynjuk2awZdiygk7+yUW2BjqNyretfTEOpn9EXFNZ2-WqhNHX4X6KfnKJn2ee4KEbz+l7D
aQjhGRvsyzi55nBPv6ZBj9kxvU5VFSPBxdFtipCsh+-LdjKICPi-aLs1n2xXzVo1lPdwH36w
7cGGGKRaEtwHYZA8bNKXZ-BePQCgef1AKt8oAAiS4NY7NS+K4PX3XdpAHwcMDU2izD4Lj7Xy
Sn+zMqDB4loOQmpWyXaMfMXduDwM2lQDvzmzcr6KPcIZ4CtbvfI9gDksl0c8YQ-pcmP5rne-
JSTIeGfbhyghdozhD7rzVHpLGpoxGxZTCeKvMnLtKmOgcasBK9BQiiSt+LsBPCKO-nptMCqt
mZen85shdnwRwAJr1P2OzL0uFDpsC5rfjjoBVYCqUrhhhOwMP5KjqjTPuVcAhM9VE3phUq0c
fHTgBnqJpr+sLNq7WUmb8B8cK3lPLrxEABXg833je1Isxhg2Syo-EpoxnUvKjp7L9u0CHU4J
pTswNzKg+LrUt8EK0XU+4e7FLVntiwjQzNeORNjTkZ5qR6grsPcV1BQANkpJEYdKjwkxZFJ3
XtEtL9NOf5j31NbcIE3TnUZtpWlDCNSZdJ69CCpNPFijqu6py-AdvODyA5Gfc4Km7R1mSIgs
As8QbTcsPPjqhxOemqFDp8QRHjM-IbnLln55Yh0l9LJvNT04QYSRHTOitD0SiYD0zcDpu2uZ
S2BbjSXEKDiCeOnW0umpNteyNRrvbfuaBrZyTw0iE3P0Vnw5rLMBoHD8d5IJosQgGaMZAgeY
BFhN4BeUHoj4C5CQc1Mn1ZtWU4k1oUsyJKuIR5DijgnXNtlklU2aztZLsQk7CDAuf1xn08Hp
***** END OF BLOCK 2 *****



*XX3402-011730-281096--72--85-48760--------FLAT.ZIP--3-OF--3
oC9zw++MrNklblDisbUV4WLfOCZ7S5hal-GOyQPn4iUoyeuzceEZmsTHxM2iJCYpCcob6M9P
wKPKFbgNWkz6Jet8TIpM9GpQw1uEIYv8Lj1DQ-v6KgttNuIxpSXIb+F8+ic0w4E3tpjsjc2w
mUIExZ9CAWSvU8je-5L6fXeTNaMOuIv8zETrjoK4TC0Ad1Zc5yIFADyDkNiO-ilxBe-ATgxV
tDkI+VORZ2OpH1U91q5Ptjftps5GJppq3fsCM8Q0wazkIQCd+czFGUpzurqFd15SMd90Y5Va
C2DwC2wgNIZ4ZBF5qtFnkig-AhrPpLbiFZKSitnDQlxYwoQP5wjzMqB4NCWkDb9dw796FzaO
Mx0M2VbCnncCXEaiJ2GXyGbun+mdE+9SLSU+ILAMF6F6pf+WfdBo7YVGaPb36PSwx+UPZ8Ws
A0BVbGBzcejY7HTeiKz8ajYrvLGibrn9--J608KFXEnFOAmq8-zL4lR29h3tFw+KbtzrAqVY
m+To2+iYYrPrfiEDMro6YjRcRzx8zcUwZqqIgaSz3hVAPO9HOLH+6FJzry3GBXCiYkpRZTZz
CwiLtnB-dwM-ea1gR4EXsbMq6GGYa86h+tUpcisp26C2Vorqvp+3YwZCHzod6AjhMeJDpbEh
V68lVgInhwG7OvJb4PgeYPZSuzqbuwLikDIWxw1p6ZGuJdhtvrdho3Zs+cCaYgDZ-E2PNv1h
-6MPaKezTK5ihS3I5BJj4Yy+ydcRQsyYFF0D9izWQLOUVDOC1tGkHbXf1GSsGV8POnE17QYv
aCOmVToZqO15QtYJZRtaiUymMj12IPdnL30XtjZleN+J7pkZ1nKLdPdeodf93fj8ZXOLME4G
xT1-vHj44wJ8RhAacqVL4TiC7dca3JkOwhTF0lFKN44BCIL6BfD0ViTAGsH5n7GEMSO37wq9
VMra785QP9-R9fUW-6pjIgLYpp1keQAjrUfzGw8Y65ZJt0Fs1SFpkBZFS5vemz0v-Nw8PIMr
VJfjY7SVSCfrsPSRVOxWTfhZ+q2pSE4A+pGGifUMUNbwFZS7miWeIRQcHiPp5KSBMdb8i87A
xTYXAZVbcErDBE41FNN0uRFAa04bU2nSAzZFETbm7V2OjCchamgk1KpEVQzrGbFeBK6raRL0
2vtshws-iP8j3OGCecvomibbA9Ul3QC9T-emaEebtCAD6GYm36tLq+lF+JYBQRIvRUMWzL80
Ch6WZnNLM8czw5GYIhIv+XsaBneRGDZc51V87pSb0H5J+bflWXW1k-3ECU7uL+O1c7sibIJU
7US-h2KJ1FwbSk1BlqZ6+8drV7SGfO-+GY36KZ68t5+o52TKUGlQ8gu6JuNyEr6UhdQ9xr9r
rnNiUhnPSCAO33DrU3RnAkniWoLsjQafZSQxFHTpUM6NMQzaWiouLfmwud6vhE5QSEuZb2us
-lE1IGO+pvrj21YOOSfZ7N0QVQzV5NLqSLZxWzySSZ76DSSSi65BxysRz-PiWc4CipArkfnv
WrARIzTWx9jkG9NhfyG5YyBeRfoMSC1xcEj9rNJaTUCMjV9vi-HcNAR6QsXdxGk3XksMDVIw
-j0g-2wK4D5ZM1IYSr8lRx+TT27RK+Wzi7RpnjT2Q9dfKLA7rHH+HbohpzV9K9CklbTxCoUN
wbUOd2ltv+RdbJnv7Kl03dp3saaBFICSd1L2EojMVPvbNG1jZrHkPZATLxLoVTv2k1y+wxvH
1Qm5oSVqrxPVRD44wsJIeafbXicLRxLcsmt96s0WKDU4wMMHXdCWMDf6B8bsRhRH047DEY1E
hnw80LtVEMjTK8-9-c2rhXw2sOyO+uho4u+dbCnGf+SLfUXuRDbEv2S334k9yS+lUyRNY-NG
4Uiz7OV+pt+Tlz-eG15xs3Ygpppw41qIXy8PxjKEk-S-g89vxlHqsDN069bE5O461he9U8k5
Pnud-7EWHo+rEtAsKQG5THz95OTq0nlt0cf1hk8R9y38dlcTeH0PSyrqBqmq-GpIiTg03bQT
cO18UcKK2+OeAfJghXbTFfBlvV2TDtkS+5d7FiOO7z8STCfdz+9nqg7pxUdvjP1zZHc1LWUC
qUkULuwU8oYBwcpFz3ewAzCNdI9gbzZQb-+5NXsH-uifa13aB3UdHWS2VNwYH7sucdsNbFZf
ue4OlW+V7Dz2qmJ5EJA6l4z2iz8lzqguX6uCXequhCFr1Gln8SJrTlkR4EqJqPwwTIHvjT9d
6pksuTFwzNdU1QNjSaqYuHCxk6xyCHclRGQMapwR1S2w6LFobfVGfDiCez6iBf7MT1cYvrW5
t6ECb5Noj3IWR1EXPsHdO-t2pUIBrCcsNmtroBtmxq1iJvTSnTLzcluvep9Vp59Plff5sgXX
a6UXpg+GnJkp932DeO4fQnmguXcz5aOurVyTeskZx3egykjLbVwLYhNulsLY+TtNk7TNn+cS
PpSNI0qPe8Hbn5Eb+xYYttvGMiFOePnHnJe9BN2oSIFv8hbILUWbKPcT+j6EJ43G75Mj-F6D
xxLtvTlqMzEFn4g4grFLL40q9NYyQWJ7g1NaAAZ9FnaQjXwio1unwqUq0D3jJKMDdxj8LNlo
1cL3zsV7fV0LGP--jd-nsa-nw5Ojovt+IPEnl+XGlsecoiBaqphNaehawI17obHiTcAnVJ-c
aIEL1OSjRY9H3KVUHLtHG-kGFqHfm5vfJouss+FlaKzRQ5c1XOiH-FC0kMawlE7H5Du1C9Ne
-CyDgpNYQvvpaAulU9D4WtK7q79kw-I1haHtMD4M-ofknlcN+QvIyD7rQtuwuGDXGKlWAICq
i3Ix+WDJrSzXDmV2lxmN0zGmdfigUzQJlZNksTtbILNCfWbqZ1pHJ9mVN0Dwbnwoz1REGk20
3++I++6+0+0+0U2Ta37wyEQ-++-2+U++-k+++++++++-+0++++++++++FJUm9Y3HHJ-9+E6I
+-E++U+6+6E8+FwzkeFbV+I++8gH+++6++++++++++2+6++++0k-++-4H23I9Y3HHJ-9+E6I
+-E++U+6+6I8+Fz1m1sYCk6++7M0+++6++++++++++++6++++BM4++-4H23I9Yx0GZ-9+E6I
+-E++U+6+6M8+FxgZeXS8+A++6k7+++5++++++++++2+6++++1Q7++-3K16iI23HI2g-+VE+
3++0++U+X+c-5pgRp+zU+E++LUE+++Q++++++++++E+U++++V+k++2JMAGt-IopEGk203++I
++6+0+0D0U2TXg6Rq-sB+++m6E++0++++++++++-+0++++071U++FYl-J0tIK3FEGk203++I
++6+0+0G0U2Ty4vfpO2+++0c++++-k+++++++++-+0++++1B4k++FJUm9Yx0GZ-9+E6I+-E+
+U+6+7A8+FxLMwHtkk2++Do-+++5++++++++++2+6++++7AQ++-3K12iEoxBI2g-+VE+3++0
++U+Zkc-5vg6Mukw1E++Y-6+++Q++++++++++++U++++Sls++2JMAWt3K2JEGkI4++++++Y+
0E1U+E++r0g+++++
***** END OF BLOCK 3 *****



