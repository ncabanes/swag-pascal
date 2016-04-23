{
> Does anyone know how TP returns a string from a function?  Does it
> return a  pointer to the string in AX:DX?  I'm writing a data
> compression for a science  project, and I'm trying to optimize my
> Pascal into BASM as much as possible to  speed things up. Thanks.
}

{───────────────────────────────────────────────────────────────────────}
{                Notes on Assembler returns with functions              }
{                                                                       }
{  AL: byte/char/shortint/boolean results                               }
{  AX: word/integer results                                             }
{  AX:DX: 4 byte results (pointer/longint)                              }
{  AX:BX:DX 6 byte results (real)                                       }
{═══════════════════════════════════════════════════════════════════════}
