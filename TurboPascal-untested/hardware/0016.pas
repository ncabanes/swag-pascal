{
ERIC SCHILKE

>  I need help in obtaining all pertinent information about
>  AuxInPtr and AuxOutPtr, as pertaining to TP 3.0 reserved
>  Words. These Pointers are referencing BIOS entry points.

This is from memory, since I don't have the references here, and
it has been a While....  AuxInPtr and AuxOutPtr are Pointers
containing the addresses of the respective AuxIn Function and
AuxOut Procedure, which are used (and not available as a standard
Function/Procedure) by the standard TP3 I/O drivers.

Each of the I/O possibilities has a corresponding Procedure/Function,
address Pointer, and BIOS entry point as follows:

     Device        proc/funct        address      BIOS entry

  CON:,TRM:,KBD:   ConIn:Char;       ConInPtr       CONIN
  CON:,TRM:,KBD:   ConOut(Ch:Char);  ConOutPtr      CONOUT
  LST:             LstOut(Ch:Char);  LstOutPtr      LIST
  AUX:             AuxIn:Char;       AuxInPtr       READER
  AUX:             AuxOut(ch:Char);  AuxOutPtr      PUNCH
  USR:             UsrIn:Char;       UsrInPtr       CONIN  ?
  USR:             UsrOut(ch,Char);  UsrOutPtr      CONOUT ?

I'm not sure about the last two entry points.  Also, if memory
serves correctly, there is another Function, ConSt:Boolean, which
is used by the KeyPressed Function, having a corresponding address
Pointer, ConStPtr, With BIOS entry Const.  if you Write your own I/O
drivers, you should assign the address of the corresponding driver
Function or Procedure to the proper Pointer Variable.  Your question
is a bit vague; what specific problems have you encountered?  I
think that my recollection is accurate; however, my old references
are in an attic in Pennsylvania, While I am here in Huntsville,
Alabama.  Perhaps someone else could confirm and/or amplify on
these observations.
}
