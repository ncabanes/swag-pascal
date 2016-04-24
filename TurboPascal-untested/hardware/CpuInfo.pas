(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0013.PAS
  Description: CPU Info
  Author: BRUCE LACKLORE
  Date: 10-28-93  11:29
*)

Unit CPUInfo;

{        Version 1.1.0.P

        Requires Borland Turbo Pascal version 6.0 or later to compile.
        Author:  Bruce J. Lackore.  Created Saturday, October 9, 1993.
}

{$IFDEF Test}
        {$A+,B-,D+,F-,G-,I+,L+,O-,R+,S+,V-,X+}
{$ELSE}
        {$A+,B-,D-,F-,G-,I-,L-,O-,R-,S-,V-,X+}
{$ENDIF}

{        This unit contains a handy gadget for determining the CPU speed.  It is NOT
        coded for the Pentium family (if anyone wants to take a shot at it, please
        let me know the results)!
}

Interface

Const
        Cpu8086                                                                          = 1;
        Cpu80286                                                                         = 2;
        Cpu80386                                                                         = 3;
        Cpu80486                                                                         = 4;

Function WhatCPU:  Word;

{        This function examines the CPU and returns a number corresponding to the
        CPU type;  1 for 8086, 3 for 80386, etc.  This procedure came right out of
        Neil Rubenking's Turbo Pascal 6.0 Techniques and Utilities (thanx Neil!).
}

Procedure CPUSpd(Var MHz, KHz:  Word);

{        This procedure is a ROUGH estimation of how fast the CPU is running in
        MegaHertz.  It was adapted from a C program found in the Intel forum of
        CIS written by Glenn Dill.  I had to do some finagling of the original code
        because C allows for a 32-bit UNSIGNED integer, whereas Pascal allows for a
        32-bit SIGNED integer (the LongInt), therefore, I was forced to reduce all
        calculations by 10 in order to get it to fit properly.
}

{ ************************************************************************** }

Implementation

Function WhatCPU;  Assembler;

        Asm  { Function WhatCPU }
                        MOV            DX,Cpu8086
                        PUSH           SP
                        POP            AX
                        CMP            SP,AX
                        JNE                 @OUT
                        MOV                 DX,Cpu80286
                        PUSHF
                        POP            AX
                        OR             AX,4000h
                        PUSH           AX
                        POPF
                        PUSHF
                        POP            AX
                        TEST           AX,4000h
                        JE             @OUT
                        MOV                 DX,Cpu80386                        {        "DB 66h" makes '386 extended instruction }
                        DB 66h; MOV BX,SP              {        MOV EBX,ESP }
                        DB 66h, 83h, 0E4h, 0FCh {        AND ESP,FFFC        }
                        DB 66h; PUSHF           {        PUSHFD }
                        DB 66h; POP AX          {        POP EAX        }
                        DB 66h; MOV CX, AX      {        MOV ECX,EAX }
                        DB 66h, 35h, 00h
                        DB 00h, 04h, 00         {        XOR EAX,00040000        }
                        DB 66h; PUSH AX         {        PUSH EAX }
                        DB 66h; POPF            {        POPFD }
                        DB 66h; PUSHF           {        PUSHFD }
                        DB 66h; POP AX          {        POP EAX }
                        DB 66h, 25h,00h
                        DB 00h, 04h,00h                {        AND EAX,00040000 }
                        DB 66h, 81h,0E1h,00h
                        DB 00h, 04h,00h                {        AND ECX,00040000 }
                        DB 66h; CMP AX,CX              {        CMP EAX,ECX }
                        JE @Not486
                        MOV DX, Cpu80486
                @Not486:
                        DB 66h; PUSH CX         {        PUSH ECX }
                        DB 66h; POPF            {        POPFD }
                        DB 66h; MOV SP, BX      {        MOV ESP,EBX }
                @Out:
                        MOV AX, DX
        End;        { Function WhatCPU }

Procedure CPUSpd;

        Const
                Processor_cycles:                                Array[0..4] of Byte = (165, 165, 25, 103, 42);
                                                                                                                {        Cycle times of 8086, 80186, 80286, 80386, 80486}

                {        Notice that here I have defined the 8086 as a Processor type of 0 vice
                        the returned value of 1 from WhatCPU.  Since the original code did not
                        distinguish between the 8086 and the 80186, I can get away with this.
                }

        Var
                Ticks,
                Cycles,
                CPS:                                                                                LongInt;
                Which_CPU:                                                        Word;

        Function i86_to_i286:  Word;  Assembler;

                Asm  { Function i86_to_i286 }
                        CLI
                        MOV                CX,1234
                        XOR                DX,DX
                        XOR                AX,AX
                        MOV                AL,$B8
                        OUT                $43,AL
                        IN                AL,$61
                        OR                AL,1
                        OUT                $61,AL
                        XOR                AL,AL
                        OUT                $42,AL
                        OUT                $42,AL
                        XOR                AX,AX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IDIV        CX
                        IN                AL,$42
                        MOV                AH,AL
                        IN                AL,$42
                        XCHG        AL,AH
                        NEG                AX
                        STI
                End;  { Function i86_to_i286 }

        Function i386_to_i486:  Word;        Assembler;

                Asm  { Function i386_to_i486 }
                        CLI
                        MOV                AL,$B8
                        OUT                $43,AL
                        IN                AL,$61
                        OR                AL,1
                        OUT                $61,AL
                        XOR                AL,AL
                        OUT                $42,AL
                        OUT                $42,AL
                        DB 66H,$B8,00h,00h,00h,80h;
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        DB 66H,0FH,$BC,$C8;                                {        BSF        ECX,EAX }
                        IN                AL,42H
                        MOV   AH,AL
                        IN                AL,42H
                        XCHG        AL,AH
                        NEG                AX
                        STI
                End;  { Function i386_to_486 }

        Begin  { Procedure CPUSpd }
                Which_CPU := WhatCPU;
                If Which_cpu < 3 Then
                        Ticks := i86_to_i286
                Else
                        Ticks := i386_to_i486;
                Cycles := 20 * Processor_cycles[Which_CPU];
                CPS := (Cycles * 119318) Div Ticks;
                MHz := CPS Div 100000;
                KHz := (CPS Mod 100000 + 500) Div 1000
        End;  { Procedure CPUSpd }

End.  { Unit CPUInfo }

{ ---------------------   TEST PROGRAM --------------------------}

Program CPUSpeed;

{        Version 1.0.0.T.

        Requires Borland Turbo Pascal version 6.0 or later to compile.

        Author:  Bruce J. Lackore.  Created Saturday, October 9, 1993.
}

{$IFDEF Test}
        {$A+,B-,D+,E+,F-,G-,I+,L+,N-,R+,S+,V-,X+}
{$ELSE}
        {$A+,B-,D-,E+,F-,G-,I-,L-,N-,R-,S-,V-,X+}
{$ENDIF}

{$M 1024, 0, 0}

Uses CPUInfo;

Var
        MHz,
        KHz:                                                                                        Word;

Begin  { Program: Cpuspeed }
        CpuSpd(MHz, KHz);
        Writeln('The CPU speed is ', MHz, '.', KHz, ' MHz.')
End.  { Program:  Cpuspeed }

