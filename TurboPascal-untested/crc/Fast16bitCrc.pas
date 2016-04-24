(*
  Category: SWAG Title: 16/32 BIT CRC ROUTINES
  Original name: 0015.PAS
  Description: Fast 16bit CRC
  Author: DON PAULSEN
  Date: 05-25-94  08:03
*)


{
RE:     SWAG submission
        This 16-bit CRC function is compatible with those used in Chuck
        Forsberg's X-modem protocol.  It's very fast, because I unrolled
        the "for (i = 0; i < 8; ++i)" loop.  If a 32-bit CRC is not
        necessary, this is a great alternative because of its speed and
        small size.



{==============================================================}
FUNCTION Crc16 (var buffer; size, seed: word): word; assembler;

{ Set size parameter to 0 to process 64K.  If processing only one buffer, set
  seed parameter to 0 -- otherwise set to result from previous calculation.
  C code translated by Don Paulsen. }

(* This routine is a translation of the following C code by Chuck Forsberg.
   The added "seed" parameter allows for finding the CRC value of data spanning
   multiple buffers.  The innermost loop has been unrolled at a cost of 32
   bytes in code, but the speed increase is nearly two-fold.

     int    Crc16 (ptr, count)
     char   *ptr;
     int    count;

     {   int crc, i;

         crc = 0;
         while (--count >= 0) {
            crc = crc ^ (int)*ptr++ << 8;
            for (i = 0; i < 8; ++i)
                if (crc & 0x8000)
                    crc = crc << 1 ^ 0x1021;
                else
                    crc = crc << 1;
          }
         return (crc & 0xFFFF);
     }
*)

ASM
    les     di, buffer
    mov     dx, size
    mov     ax, seed
    mov     si, 1021h
@next:
    xor     bl, bl
    mov     bh, es:[di]
    xor     ax, bx

    shl  ax, 1;    jnc  @noXor1;    xor  ax, si
@noXor1:
    shl  ax, 1;    jnc  @noXor2;    xor  ax, si
@noXor2:
    shl  ax, 1;    jnc  @noXor3;    xor  ax, si
@noXor3:
    shl  ax, 1;    jnc  @noXor4;    xor  ax, si
@noXor4:
    shl  ax, 1;    jnc  @noXor5;    xor  ax, si
@noXor5:
    shl  ax, 1;    jnc  @noXor6;    xor  ax, si
@noXor6:
    shl  ax, 1;    jnc  @noXor7;    xor  ax, si
@noXor7:
    shl  ax, 1;    jnc  @noXor8;    xor  ax, si
@noXor8:

    inc     di
    dec     dx
    jnz     @next
END;


