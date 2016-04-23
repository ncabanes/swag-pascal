{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}

{─ Fido Pascal Conference ────────────────────────────────────────────── PASCAL ─
Msg  : 193 of 292
From : Wilbert van Leijen                  2:281/256.14         14 May 93  19:29
To   : Vince Laurent                       1:382/10.0
Subj : a few questions...
────────────────────────────────────────────────────────────────────────────────
07 May 93, Vince Laurent writes to All:

 VL> 1. What is the quickest way to check for the existance of a file?
 VL>    I am going to be running the application on a network and would
 VL>    like to minimize network traffic.

You cannot bypass the file server for this purpose, the reason should be
obvious.  So peer-to-peer communication protocols are out.

Suggestion: obtain the file's attributes using INT 21h, AH=43h, DS:DX -> ASCIIZ
filename.
If this call sets the carry flag, the file doesn't exist.  Otherwise, it does.
Advantage: no need for an attempt to open it.}

Function FileExist(filename : String) : Boolean; Assembler;

ASM
        PUSH   DS
        LDS    SI, [filename]      { make ASCIIZ }
        XOR    AH, AH
        LODSB
        XCHG   AX, BX
        MOV    Byte Ptr [SI+BX], 0
        MOV    DX, SI
        MOV    AX, 4300h           { get file attributes }
        INT    21h
        MOV    AL, False
        JC     @1                  { fail? }
        INC    AX
@1:     POP    DS
end;  { FileExist }

