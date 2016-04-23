(*
Date:   02-05-95
From:   DON PAULSEN


        This unit provides routines to manipulate individual bits
        in memory, including test, set, clear, and toggle.  You may
        also count the number of bits set with NumFlagsSet, and get
        a "picture" of them with the function FlagString.

        All the routines are in the interface section to provide
        complete low-level control of your own data space used for
        flags.  Usually the oFlags object will be most convenient.
        Just initialize the object with the number of flags required,
        and it will allocate sufficient memory on the heap and clear
        them to zero.
*)


UNIT DpFlags;

{$A+,B-,D-,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
{$IFDEF VER70} {$P-,Q-,T-,Y-} {$ENDIF}

(*
    File(s)         DPFLAGS.PAS
    Unit(s)         None
    Compiler        Turbo Pascal v6.0+
    Author          Don Paulsen
    v1.00 Date       7-01-92
    Last Change     11-12-93
    Version         1.11
*)

{ Flags are numbered from left to right (low memory to high memory),
  starting with 0, to a maximum of 65520.  If the flags object isn't used,
  use the System.FillChar routine to set or clear all the flags at once.
  The memory for storing the flags can be allocated in the data segment
  or on the heap.

  Here are two methods for declaring an array for the flags (not needed if
  the oFlags object is used):

    CONST
       cMaxFlagNumber = 50;
       cNumberOfFlags = 51;

    VAR
       flags_A : array [0..(cMaxFlagNumber div 8)] of byte;
       flags_B : array [0..(cNumberOfFlags - 1) div 8] of byte;

  Note that since the first flag is flag 0, cNumberOfFlags is always 1 greater
  than cMaxFlagNumber. }


INTERFACE

PROCEDURE SetFlag     (var flags; flagNum : word);
PROCEDURE ClearFlag   (var flags; flagNum : word);
PROCEDURE ToggleFlag  (var flags; flagNum : word);
FUNCTION  FlagIsSet   (var flags; flagNum : word): boolean;
FUNCTION  NumFlagsSet (var flags; numFlags: word): word;
FUNCTION  FlagString  (var flags; numFlags: word): string;

TYPE
    tFlags = ^oFlags;
    oFlags = OBJECT
               CONSTRUCTOR Init (numberOfFlags: word);
               PROCEDURE   ClearAllFlags;
               PROCEDURE   SetAllFlags;
               PROCEDURE   SetFlag    (flagNum: word);
               PROCEDURE   ClearFlag  (flagNum: word);
               PROCEDURE   ToggleFlag (flagNum: word);
               FUNCTION    FlagIsSet  (flagNum: word): boolean;
               FUNCTION    NumFlagsSet : word;
               FUNCTION    FlagString  : string;
               DESTRUCTOR  Done;
             PRIVATE
                flags    : pointer;
                numFlags : word;
             END;


IMPLEMENTATION

{=======================================================}
PROCEDURE SetFlag (var flags; flagNum: word); assembler;

ASM
    les     di, flags
    mov     cx, flagNum
    mov     bx, cx
    shr     bx, 1
    shr     bx, 1
    shr     bx, 1
    and     cl, 7
    mov     al, 80h
    shr     al, cl
    or      es:[di][bx], al
END;

{=========================================================}
PROCEDURE ClearFlag (var flags; flagNum: word); assembler;

ASM
    les     di, flags
    mov     cx, flagNum
    mov     bx, cx
    shr     bx, 1
    shr     bx, 1
    shr     bx, 1
    and     cl, 7
    mov     al, 7Fh
    ror     al, cl
    and     es:[di][bx], al
END;

{==========================================================}
PROCEDURE ToggleFlag (var flags; flagNum: word); assembler;

ASM
    les     di, flags
    mov     cx, flagNum
    mov     bx, cx
    shr     bx, 1
    shr     bx, 1
    shr     bx, 1
    and     cl, 7
    mov     al, 80h
    shr     al, cl
    xor     es:[di][bx], al
END;

{=================================================================}
FUNCTION FlagIsSet (var flags; flagNum: word): boolean; assembler;

ASM
    les     di, flags
    mov     cx, flagNum
    mov     bx, cx
    shr     bx, 1
    shr     bx, 1
    shr     bx, 1
    and     cl, 7
    inc     cx
    mov     al, es:[di][bx]
    rol     al, cl
    and     al, 1
@done:
END;

{=================================================================}
FUNCTION NumFlagsSet (var flags; numFlags: word): word; assembler;

ASM
    push    ds
    cld
    lds     si, flags
    xor     bx, bx
    mov     cx, numFlags
    mov     dx, cx
    xor     di, di
    shr     cx, 1
    shr     cx, 1
    shr     cx, 1
    jcxz    @remainder
@byte8:
    lodsb
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    shl     al, 1;  adc     bx, di
    loop    @byte8
@remainder:
    mov     cx, dx
    and     cx, 7
    jz      @done
    lodsb
@bit:
    shl     al, 1
    adc     bx, di
    loop    @bit
@done:
    mov     ax, bx
    pop     ds
END;

{==================================================================}
FUNCTION FlagString (var flags; numFlags: word): string; assembler;

{ Returns a string of 0's & 1's showing the flags.  Note that at most 255
  flags can shown in a string.  Returns nul if numFlags is 0 or greater
  than 255. }

ASM
    push    ds
    cld
    lds     si, flags
    les     di, @result
    mov     cx, numflags
    or      ch, ch
    jz      @ok
    xor     cx, cx
@ok:
    mov     al, cl
    stosb                   { length of string }
    jcxz    @done
    mov     dx, cx
    push    dx              { save number of flags }
    mov     ah, '0'
    shr     dl, 1
    shr     dl, 1
    shr     dl, 1
    jz      @remainder
@byte8:                     { do 8 bits at a time }
    lodsb
    mov     bl, al
    mov     cl, 8
@bit8:
    mov     al, ah          { ah = '0' }
    shl     bl, 1
    adc     al, dh          { dh = 0 }
    stosb
    loop    @bit8
    dec     dl
    jnz     @byte8

@remainder:                 { do remaining (numFlags mod 8) bits }
    pop     dx
    mov     cx, dx
    and     cl, 7           { 0 <= cx <= 7 (number of flags in partial byte) }
    jz      @done
    lodsb                   { last byte containing flags  }
    mov     bl, al
@bit:
    mov     al, ah          { ah = '0' }
    shl     bl, 1
    adc     al, dh          { dh = 0 }
    stosb
    loop    @bit
@done:
    pop     ds
END;

{=============================================}
CONSTRUCTOR oFlags.Init (numberOfFlags: word);

BEGIN
    if numberOfFlags > 65520 then FAIL;
    numFlags:= numberOfFlags;
    GetMem (flags, (numFlags + 7) div 8);
    if flags = nil then FAIL;
END;

{==============================}
PROCEDURE oFlags.ClearAllFlags;

BEGIN
    FillChar (flags^, (numFlags + 7) div 8, #0);
END;

{============================}
PROCEDURE oFlags.SetAllFlags;

BEGIN
    FillChar (flags^, (numFlags + 7) div 8, #1);
END;

{========================================}
PROCEDURE oFlags.SetFlag (flagNum: word);

BEGIN
    DpFlags.SetFlag (flags^, flagNum);
END;

{==========================================}
PROCEDURE oFlags.ClearFlag (flagNum: word);

BEGIN
    DpFlags.ClearFlag (flags^, flagNum);
END;

{===========================================}
PROCEDURE oFlags.ToggleFlag (flagNum: word);

BEGIN
    DpFlags.ToggleFlag (flags^, flagNum);
END;

{==================================================}
FUNCTION oFlags.FlagIsSet (flagNum: word): boolean;

BEGIN
    FlagIsSet:= DpFlags.FlagIsSet (flags^, flagNum);
END;

{=================================}
FUNCTION oFlags.NumFlagsSet: word;

BEGIN
    NumFlagsSet:= DpFlags.NumFlagsSet (flags^, numFlags);
END;

{==================================}
FUNCTION oFlags.FlagString: string;

VAR
    w : word;

BEGIN
    w:= numFlags;
    if w > 255 then w:= 255;
    FlagString:= DpFlags.FlagString (flags^, w);
END;

{======================}
DESTRUCTOR oFlags.Done;

BEGIN
    if flags <> nil then FreeMem (flags, (numFlags + 7) div 8);
END;

END.        { Unit DpFlags }

