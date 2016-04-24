(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0065.PAS
  Description: DS and ES Registers
  Author: RAPHAEL VANNEY
  Date: 08-26-94  07:26
*)

{
 ET> On entry in an assembler routine, I haven't (yet?) noticed a
 ET> difference between the DS and ES registers. Can I rely on that??

No. You can assume ES to be uninitialized (ie, random value), and
DS pointing to the program's data segment.
Try this and see for yourself :-)

Note that if you change "b^:=a" to "a:=b^", DS and ES hold the same
value when entering ShowESAndDS.

}

Var  a    : String ;
     b    : ^String ;

Procedure ShowESAndDS ;
Var  _ES,
     _DS  : Word ;
Begin
     Asm
          Mov  _ES, ES
          Mov  _DS, DS
     End ;
     WriteLn('ES=', _ES, ', DS=', _DS) ;
End ;

Begin
     New(b) ;
     b^:=a ;
     ShowESAndDS ;
     Dispose(b) ;
End.


