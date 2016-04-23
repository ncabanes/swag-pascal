
{
From what I gather from these two routines, in order to "Normalize" a crc
value, you must reverse the order of the four bytes in the value.

Example: crc value =  $01020304
         normalized = $04030201

Am I correct in assuming this?

If so, the two procedures above fail to perform that task, so here is a BASM
routine that I have tested and works perfectly.
}

Procedure Normalize(Var crc: LongInt); Assembler;
ASM
     LES   DI, crc
     MOV   AX, WORD PTR ES:[DI]
     MOV   BX, WORD PTR ES:[DI + 2]
     XCHG  AH, AL
     XCHG  BH, BL
     MOV   WORD PTR ES:[DI + 2], AX
     MOV   WORD PTR ES:[DI], BX
End;

Please forward a copy of your response to Serge Paquin who wrote the original
request for CRC routines.
