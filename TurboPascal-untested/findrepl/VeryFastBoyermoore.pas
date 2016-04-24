(*
  Category: SWAG Title: SEARCH/FIND/REPLACE ROUTINES
  Original name: 0019.PAS
  Description: VERY FAST Boyer-Moore
  Author: COSTAS MENICO
  Date: 11-21-93  09:26
*)

{
  The originial benchmark program was to demonstrate the speed difference
  between the POS() in Turbo Pascal 4 or 5 brute-force
  and the Boyer-Moore method function POSBM()
  Program author: Costas Menico

   Call: posbm(pat,buf,buflen);
   or if you are using a string buffer:
         posbm(pat,s[1],length(s));
}

program bufSearch;

uses
  dos, crt;


{$F+}
function posbm(pat:string; var buf; buflen:word):word; EXTERNAL;
{$L BM.OBJ}
{$F-}

function bruteForce(var such:string; var buf; buflen:word):word; ASSEMBLER;
ASM
        cld
        push ds
        les        di,buf
        mov        cx,buflen
        jcxz @@30
        lds        si,such
        mov  al,[si]
        or   al,al
        je   @@30
        xor  ah,ah
        cmp  ax,cx
        ja   @@30
        mov  bx,si
        dec  cx
  @@10:
        mov  si,bx
        lodsw
        xchg al,ah          { AH=Stringlänge, AL=Suchchar }
        repne scasb
        jne  @@30
        dec  ah
        or   ah,ah
        je   @@20

        inc  cx             { CX++ nach rep... }
        xchg cx,ax
        mov  cl,ch
        xor  ch,ch
        mov  dx,di
        repe        cmpsb
        mov  di,dx
        mov  cx,ax
        loopne @@10
  @@20:
        mov  ax,buflen
        sub  ax,cx
        dec  ax
        jmp  @@40
  @@30:
        xor  ax,ax
  @@40:
        pop  ds
end;



procedure showtime(s : string; t : registers);

begin
  writeln(s, ' Hrs:', t.ch, ' Min:', t.cl, ' Sec:', t.dh, ' Milsec:', t.dl);
end;

var
  pat    : string;
  i,
  j      : integer;
  start,
  finish : registers;
  arr    : array[1..4096] of char;

const
  longloop = 5000;

begin
  clrscr;
  randomize;
  for i := 1 to 4096 do
    arr[i] := chr(random(255)+1);

  move(arr[4090],pat[1],5); pat[0]:=#5;

  writeln('Search using Brute-Force Method <please wait>');
  start.ah := $2C;
  msdos(start);
  for j := 1 to longloop do
    i := bruteForce(pat,arr,4096);
  finish.ah := $2C;
  msdos(finish);
  showtime('Start  ', start);
  showtime('Finish ', finish);
  writeln('Pattern found at position ', i);
  writeln;
  writeln('Search using Boyer-Moore Method <please wait>');
  start.ah := $2C;
  msdos(start);
  for j := 1 to longloop do
    i := posbm(pat, arr,4096);
  finish.ah := $2C;
  msdos(finish);
  showtime('Start  ', start);
  showtime('Finish ', finish);
  writeln('Pattern found at position ', i);
  writeln;
  writeln('Done ... Press Enter');
  readln;
end.

{ --------------------------   XX34 OBJECT CODE  ----------------------- }
{ ------------------------- CUT OUT AND SAVE AS BM.XX  ------------------}
{ ------------------------  USE XX3401 D BM.XX   ------------------------}

*XX3401-000392-050693--68--85-03573----------BM.OBJ--1-OF--1
U-M+32AuL3--IoB-H3l-IopQEYoiEJBBYcUU++++53FpQa7j623nQqJhMalZQW+UJaJm
QqZjPW+n9X8NW-k+ECbfXgIO32AuL3--IoB-H3l-IopQEYoiEJBB+sU1+21dH7M0++-c
W+A+E84IZUM+-2BDF2J3a+Q+OCQ++U2-1d+A+++--J-DIo7B++++rMU2+20W+N4Uuk+-
++-JUSkA+Mjg5X9YzAKq4+4AbUM-f+f+REDdjU09m6Z4+6aq-+53hVE-X7s8+Mi42U29
k5I1uO6+WIM0WPM6+MDt+LIPlPM2+On2jUU-Wos0weto+ya1+6jrUys0uqyEXLs2XB8C
kcd4+6fUiM++wuj3hUE-XJs2Wos+GMjRXKs2AiGgWzW60y9tf6jsW+i9uwKq0+4BTUG9
JU78WoM+G19zzGjEQXE1w6cQBcc-0g-pwMjSWos+l9s2+Iw1yTCaR+ms+E0BTUG9wn9z
uxK9lgKq0+2flUI0+Cg0Aw1w5sjZUQEA+Jr80U-fWU6++5E+
***** END OF XX-BLOCK *****

{ --------------------------   ASSEMBLER CODE  ------------------------- }
{ ------------------------- CUT OUT AND SAVE AS BM.AMS ------------------}
{ ------------------------  USE TASM TO ASSEMBLE ------------------------}

; filename: BM.ASM
; fast search routine to search strings in ARRAYS OF CHARS
; function in Turbo Pascal >= 4. Based on the Boyer-Moore algorithm.
; program author: Costas Menico.
; Very small modifications for using an ARRAY OF CHAR buffer instead of
; a string made by Jochen Magnus in May 93.
; declare as follows:
; {$F+}
; {$L BM.OBJ}
; function posbm(pat:string; var buffer; buflen:word):WORD; external;
; call as follows from Turbo 4..7:
; location := posbm(pat, buf, buflen);
; call for a search in a string typed buffer:
; location := posbm(pat, str[1], length(str));


skiparrlength        equ        256

; function work stack

dstk                struc
patlen                dw        ?
strlen                dw        ?
skiparr                db        skiparrlength dup(?)
pattxt                dd        0
strtxt                dd        0
dstk                ends

; total stack (callers plus work stack)

cstk                struc
ourdata                db        size dstk dup(?)
bpsave                dw        0
retaddr                dd        0
paramlen       dw   0                                                           ; JO
straddr                dd        0
pataddr                dd        0
cstk                ends

paramsize        equ        size pataddr+size straddr +size paramlen           ; +2  JO

code                segment        para public
                assume cs:code

; entry point to posbm function

posbm                proc        far
                public        posbm

                push        bp
                         sub        sp, size dstk
                         mov        bp, sp
                         push    ds
                         xor        ah, ah
                         cld

; get and save the length and address of the pattern

                lds        si, [bp.pataddr]
                         mov        word ptr [bp.pattxt][2], ds
                         lodsb
                         or        al, al
                         jne        notnullp
                         jmp        nomatch

notnullp:
                mov        cx, ax
                         mov        [bp.patlen], ax
                         mov        word ptr [bp.pattxt], si

; get and save the length and address of the string text

                lds        si, [bp.straddr]
                         mov        word ptr [bp.strtxt][2], ds
                         mov ax,[bp.paramlen]                                          ; JO
                         or  ax,ax                                                              ; JO
                         jne        notnulls
                         jmp        nomatch

notnulls:
                mov        [bp.strlen], ax
                         mov        word ptr [bp.strtxt], si
                         cmp        cx, 1
                         jne        do_boyer_moore
                         lds        si, [bp.pattxt]
                         lodsb
                         les        di, [bp.strtxt]
                         mov        cx, [bp.strlen]
                         repne        scasb
                         jz        match1
                         jmp        nomatch

match1:
                mov        si, di
                         sub        si, 2
                         jmp        exactmatch

do_boyer_moore:

; fill the ASCII character skiparray with the
; length of the pattern

                lea        di, [bp.skiparr]
                         mov        dx, ss
                         mov        es, dx
                         mov        al, byte ptr [bp.patlen]
                         mov        ah, al
                         mov        cx, skiparrlength/2
                         rep        stosw

; replace in the ASCII skiparray the corresponding
; character offset from the end of the pattern minus 1

                lds        si, [bp.pattxt]
                         lea        bx, [bp.skiparr]
                         mov        cx, [bp.patlen]
                         dec        cx
                         mov        bx, bp
                         lea        bp, [bp.skiparr]
                         xor        ah, ah

fill_skiparray:
                lodsb
                         mov        di, ax
                         mov        [bp+di], cl
                         loop        fill_skiparray
                         lodsb
                         mov        di, ax
                         mov        [bp+di], cl
                         mov        bp, bx

; now initialize our pattern and string text pointers to
; start searching

                lds        si, [bp.strtxt]
                         lea        di, [bp.skiparr]
                         mov        dx, [bp.strlen]
                         dec        dx
                         mov        ax, [bp.patlen]
                         dec        ax
                         xor        bh, bh
                         std

; get character from text. use the character as an index
; into the skiparray, looking for a skip value of 0.
; if found, execute a brute-force search on the pattern

searchlast:
                sub        dx, ax
                         jc        nomatch
                         add        si, ax
                         mov        bl, [si]
                         mov        al, ss:[di+bx]
                         or        al, al
                         jne        searchlast

; we have a possible match, therefore
; do the reverse brute-force compare

                mov        bx, si
                         mov        cx, [bp.patlen]
                         les        di, [bp.pattxt]
                         dec        di
                         add        di, cx
                         repe        cmpsb
                         je        exactmatch
                         mov        ax, 1
                         lea        di, [bp.skiparr]
                         mov        si, bx
                         xor        bh, bh
                         jmp        short searchlast

exactmatch:
                mov        ax, si
                         lds        si, [bp.strtxt]
                         sub        ax, si
                         add        ax, 2
                         jmp        short endsearch

nomatch:
                xor        ax, ax

endsearch:
                cld
                         pop        ds
                         mov        sp, bp
                         add        sp, size dstk
                         pop        bp
                         ret        paramsize
posbm                endp

code                ends
                end
{-----------------------   END OF ASSEMBLER CODE -------------------------}
