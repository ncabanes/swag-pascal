{

>> I'm not sure about I/O accesses in protected mode, I haven't had to
>> fiddle with it. It should work I think, the DPMI server should give the
>> program access to all ports?

> Through virtual emulation? Otherwise, they simply don't work...
> I can post some code here if you'd like to look into it.

I'd like to have a look. To at least see if it does the same on my system.
You could try this program:
}

Program TestIO;

TYPE
  TDescriptor = Record
    Limit0015 : Word;
    Base0015  : Word;
    Base1623  : Byte;
    Rights    : Byte;   { 7=Prsnt, 6-5=Dpl, 4=App,  }
                        { 3-0=Type                  }
    Rights386 : Byte;   { 7=Gran, 6=Size32, 5=0,    }
                        { 4=Avail, 3-0=Limit1619    }
    Base2431  : Byte;
  End;

Function  GetDPL(Sel: Word): Word;
Var
  Buffer : TDescriptor;
  p      : Pointer;
BEGIN
  p := @buffer;
  ASM
    { load descriptor }
    mov ax, 000Bh
    mov bx, [sel]
    les di, [p]
    int 31h

    Mov   Ax,[Word Ptr Buffer+5]
    shr ax, 5
    and ax, 3
    mov [@result], ax
  END
End;

FUNCTION GetIOPL: Word;
BEGIN
  ASM
    pushf
    pop ax

    mov cl, 12
    shr ax, cl
    and ax, 3
    mov [@result], ax
  END
END;


VAR
  dpl, iopl : Word;
Begin
  dpl := GetDPL(CSeg);
  WriteLn('Your current privilege level (DPL)  = ', dpl);
  iopl := GetIOPL;
  WriteLn('The required privilege level (IOPL) = ', iopl);
  IF (dpl <= iopl) THEN
    WriteLn('You have direct access to all IO ports')
  ELSE
  BEGIN
    WriteLn('You do not have rights to IN/OUT instructions,');
    WriteLn('unless it is allowed for the particular port');
    Writeln('in the IO Permission bitmap.')
  END;
  ASM
    mov dx, 3F8h
    in al, dx
    inc dx
    in al, dx
  END
End.

{
If the DPL and IOPL are the same (both are 3 on my system) you should have
direct access to the ports. If the IOPL is less than 3, the DPMI server isn't
giving you access for some reason. The 'IN's at the end run fine on my PC.

 > I know, i know, but where can i find the list of
 > interrupts *not automatically translated* by the DPMI server?

    I'm sure I've seen it in the manual somewhere, but can't find it now. Most
documented DOS/BIOS interrupts should be covered, but anything else most likely
isn't. The DPMI 0.9 Spec says:
"In general, any software interrupt interface that passes parameters in the
EAX, EBX, ECX, EDX, ESI, EDI and EBP registers will work as long as none of the
registers contains a segment value. In other words, if a software interrupt
interface is completely register based without any pointers, segment register,
or stack parameters, that API could work under any DPMI implementation."

    I THINK automatic translation of common functions is provided by RTM, and
not the DPMI server directly, which at least means that it should work the same
whether you're using Borlands DPMI server or one in a Dos box etc.
}
