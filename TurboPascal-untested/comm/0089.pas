(*
  Serial Ports Info v.1.0

  Jose Antonio Noda
  Compuserve :     100667,2523
*)

Program SerialPorts;

Uses Dos, Crt;
Var
  Regs                  : Registers;
  Com1,Com2,Com3,Com4   : Word;

FUNCTION Hex(w:Word):String;
CONST
  Cifra:ARRAY[0..15] OF Char=
    ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');
BEGIN
  Hex:= Cifra[Hi(w) SHR  4] +
    Cifra[Hi(w) AND 15] +
    Cifra[Lo(w) SHR  4] +
    Cifra[Lo(w) AND 15];
END;

FUNCTION NoZero(s:String):String;
BEGIN
  WHILE (Length(s)>0) AND (s[1]='0') DO Delete(s,1,1);
  NoZero:=s;
END;

Begin
  Asm
    push  es
    push  di
    mov   ax, 0040h
    xor   bx, bx
    mov   es, ax
    mov   di, bx
    mov   ax, es:[di]
    mov   Com1, ax
    mov   ax, es:[di+2]
    mov   Com2, ax
    mov   ax, es:[di+4]
    mov   Com3, ax
    mov   ax, es:[di+6]
    mov   Com4, ax
    pop   di
    pop   es;
  End;
  Clrscr;
  Writeln('Serial Ports Info v.1.0                               (C) Jose Antonio Noda');
  Writeln;
  If Com1=0 then Writeln('Serial Port COM1 not installed')
  else Writeln('Serial Port COM1   : ',NoZero(Hex(Com1)));
  If Com2=0 then Writeln('Serial Port COM2 not installed')
  else Writeln('Serial Port COM2   : ',NoZero(Hex(Com2)));
  If Com3=0 then Writeln('Serial Port COM3 not installed')
  else Writeln('Serial Port COM3   : ',NoZero(Hex(Com3)));
  If Com4=0 then Writeln('Serial Port COM4 not installed')
  else Writeln('Serial Port COM4   : ',NoZero(Hex(Com4)));
end.

