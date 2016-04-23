{
 Here's a routine that's faster than Pos on my system. It's written
 in external assembly language, and linked directly into TP program
 code.  I'm including an example of using the code, the assembly
 source code, and a pre-assembled ready-to-compile POSIN.OBJ file:

 Here's the example... }

(*******************************************************************)
PROGRAM Demo; { A faster Pos() for TP4+. June 17/94 Greg Vigneault  }

VAR str : STRING;  j : BYTE;

FUNCTION PosIn (Pattern, Str : STRING) : BYTE; EXTERNAL;
{$L POSIN.OBJ}    (* link in the external code *)

BEGIN
      WriteLn;
      str := 'Position of THIS in string is ';
      j := PosIn ('THIS',str);;  WriteLn (str,j);
      WHILE (j > 1) DO BEGIN Write (' '); DEC(j); END;
      WriteLn ('^^^^');
      WriteLn;
END.
(*******************************************************************)

Here's the assembly code source...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
code    segment byte public 'CODE'
        assume  cs:code
; FUNCTION PosIn (pattern, string : STRING) : BYTE;
pattern equ dword ptr 8[bp]
string  equ dword ptr 4[bp]
PosIn   proc    near
        public  PosIn
        push  bp                    ; preserve
        mov   bp, sp
        push  ds
        push  es
        cld                         ; assure forward scans
        lds   si, pattern           ; DS:SI -> pattern
        sub   ax, ax                ; zero
        lodsb                       ; get length byte
        test  ax, ax                ; null string?
        jz    done                  ; yes: exit with zero
        mov   dx, ax                ; length of pattern
        les   di, string            ; ES:DI -> string
        sub   bx, bx                ; zero
        mov   bl, es:[di]           ; string length
        cmp   bx, dx                ; pattern > string ?
        jc    none                  ; yes: exit with zero
        inc   di                    ; point to 1st string char
        lodsb                       ; get pattern 1st char
        dec   dx                    ; adjust pointer
        sub   bx, dx                ; don't need to check end
  po0:  mov   cx, bx                ; unsearched chars count
        repne scasb                 ; search for pattern char
        jne   none                  ; no char match
        mov   bx, cx                ; unsearched count
        push  di                    ; save text pointers
        push  si
        mov   cx, dx                ; length of pattern
        repe  cmpsb                 ; check for pattern
        pop   si                    ; restore pointers
        pop   di
        jne   po0                   ; loop if no pattern match
        lds   ax, string            ; string pointer
        xchg  ax, di                ; swap offsets
        sub   ax, di                ; subtract offsets
        dec   ax                    ; adjust for PosIn
        jmp   short done            ; found pattern
  none: sub   ax, ax                ; pattern not found
  done: pop   es                    ; restore
        pop   ds
        mov   sp, bp
        pop   bp
        ret   8
PosIn   endp
code    ends
        end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

USE XX3402 to decode this and obtain POSIN.OBJ requried for this unit.

*XX3402-000140-170694--72--85-37398-------POSIN.OBJ--1-OF--1
U+g+0L-jQqZi9Y3HHHGK-k++-2BDF2J2a+Q+82U++U6-v7+A+++--J-DIoZC++++pMU2++0W
+R4UH++-++-JWykS-jn3RUUfk8m3k5EkWx12TUEfqmO85HjOQW-5f2cfqcj9wetp3MjNJpO9
mjCaLZxpvgJ4-7QfloXf+Wj+-ly9tJr00+1nWU6++5E+
***** END OF BLOCK 1 *****

