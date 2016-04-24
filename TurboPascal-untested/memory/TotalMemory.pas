(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0043.PAS
  Description: Total Memory
  Author: KENT BRIGGS
  Date: 01-27-94  12:22
*)

{
> How would you go about displaying themount of total memory ram
> installed in a computer.
> i have tried Intr($15,regs);
> with regs do
> AH := $88;
> Writeln(regs.(AX);
> I read the above in Peter Nortons Programmers Bible  but i get some
> number that I'm sure what to do which;
> i was wondering if some one could help thanks

     Russ, you have to load AH with $88 before the Int 15 call, not
     after.  However, HIMEM hooks this interrupt anyway and only shows
     available extended memory, not installed memory.  Try the following
     program instead:
}
program show_ram;
const
  int15: longint = $f000f859;
var
  baseram,extram: word;
begin
  asm
    int   12h
    mov   baseram,ax
    mov   ah,88h
    pushf
    call  int15
    mov   extram,ax
  end;
  writeln('Base RAM = ',baseram,' Kbytes');
  writeln('Extended RAM = ',extram,' KBytes');
end.

{
This works on 286 cpu's and above since 8088/8086's don't have
extended memory.
}

