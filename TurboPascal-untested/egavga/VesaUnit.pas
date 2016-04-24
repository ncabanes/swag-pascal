(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0092.PAS
  Description: Vesa Unit
  Author: OLAF BARTELT
  Date: 01-27-94  12:24
*)

{
> Any chance you can post that uVesa Unit? Or maybe a routine to
> set up a Vesa mode, and a Vesa plotPixel routine?
}

UNIT uVesa;                                    { (c) 1993 by NEBULA-Software }
     { Unterstützung des VESA-Standards      } { Olaf Bartelt & Oliver Carow }

INTERFACE                                      { Interface-Teil der Unit     }


TYPE tVesa = OBJECT                            { Objekt für VESA             }
               xmax, ymax : WORD;
               page       : WORD;
               switch_ptr : POINTER;

               CONSTRUCTOR init(modus : WORD);
               PROCEDURE   putpixel(x, y : WORD; c : BYTE);  { Longint    }
               FUNCTION    getpixel(x, y : LONGINT) : BYTE;  { wegen Berechn.}
             END;
VAR  vVesa : ^tVesa;


CONST c640x400  = $100;                        { VESA-Modi                   }
      c640x480  = $101;
      c800x600  = $102;
      c1024x768 = $103;

FUNCTION vesa_installed : BOOLEAN;


IMPLEMENTATION                                 { Implementation-Teil d. Unit }

USES DOS, CRT;                                 { Units einbinden             }


VAR regs   : REGISTERS;                        { benötigte Variablen         }


FUNCTION vesa_installed : BOOLEAN;             { VESA-Treiber vorhanden?     }
BEGIN
  regs.AH := $4F; regs.AL := 0; INTR($10, regs);
  vesa_installed := regs.AL = $4F;
END;


CONSTRUCTOR tVesa.init(modus : WORD);
VAR mib  : ARRAY[0..255] OF BYTE;
    s, o : WORD;
BEGIN
  IF vesa_installed = FALSE THEN
  BEGIN
    WRITELN(#7, 'Kein VESA-Treiber installiert! / No VESA-driver installed!');
    HALT(1);
  END;

  regs.AX := $4F02; regs.BX := modus; INTR($10, regs);
  regs.AX := $4F01; regs.DI := SEG(mib); regs.ES := OFS(mib); INTR($10, regs);

  s := mib[$0C] * 256 + mib[$0D]; o := mib[$0E] * 256 + mib[$0F];
  switch_ptr := PTR(s, o);

  CASE modus OF
    c640x400 : BEGIN xmax := 640; ymax := 400; END;
    c640x480 : BEGIN xmax := 640; ymax := 480; END;
    c800x600 : BEGIN xmax := 800; ymax := 600; END;
    c1024x768: BEGIN xmax := 1024; ymax := 768; END;
  END;

  page := 0;
  ASM
    MOV AX, 4F05h
    MOV DX, page
    INT 10h
  END;
END;


PROCEDURE   tVesa.putpixel(x, y : WORD; c : BYTE);
VAR bank   : WORD;
    offs   : LONGINT;
BEGIN
  offs := LONGINT(y)*640 + x;     { SHL 9+SHL 7 ist auch nicht schneller!! }
  bank := offs SHR 16;
  offs := offs - (bank SHL 16);   { MOD 65536 ist langsamer!! }

  IF bank <> page THEN
  BEGIN
    page := bank;
    ASM
      MOV AX, 4F05h
      MOV DX, bank
      INT 10h
    END;
  END;

  ASM
    MOV AX, 0A000h
    MOV ES, AX
    MOV DI, WORD(offs)
    MOV AL, c
    MOV ES:[DI], AL
  END;
END;


FUNCTION    tVesa.getpixel(x, y : LONGINT) : BYTE;
VAR bank   : WORD;
    offset : LONGINT;
BEGIN
  offset := y SHL 9+y SHL 7+x;
  bank := offset SHR 16;
  offset := offset - (bank SHL 16);

  IF bank <> page THEN
  BEGIN
    page := bank;
    ASM
      MOV AX, 4F05h
      MOV DX, bank
      INT 10h
    END;
  END;

  getpixel := MEM[$A000:offset];
END;


BEGIN
  NEW(vVesa);
END.

{
That routine could be faster if one implemented a bank switching routine by
doing a far call to the vesa bios (the address can be received by a simple
call, I just hadn't had time yet to implement it - if you should do it,
*please* post the modified routine for me - thanx!)
}
