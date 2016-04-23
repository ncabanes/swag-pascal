# Der User Chris Obee@1:234/26 musste am Donnerstag, dem 22.04.93 um 12:09 Uhr
# in der Area PASCAL folgendes seiner Tastatur antun................

>     I would like to write a program in pascal that will accomplish an
> complete system reboot.  The moral equivilent of pressing the big red
> button.  A program that simulates the Cntr-Alt-Del sequence is not
> sufficient.  Anyone who can advise me on if this is possible of not, will
> receive many thanks.
>
> TTFN:  chris

That's not as hard as it might seem to be at first glance:

program coldboot;
begin
 memw[0:$0472] := 0;
 asm
  mov ax,$FFFF
  mov ds,ax
  jmp far ptr ds:0
 end;
end.

Hope you understand the assembler code... :-)


Michael : [NICO] : [Whoo haz broquen mei brain-waschaer?]
~~~~~~~~~~~~~~~~

--- CrossPoint v2.1
 * Origin: Send me ALL your money - IMMEDIATELY!! (2:2401/411.2)
                                   