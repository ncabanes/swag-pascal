(*
  Category: SWAG Title: BITWISE TRANSLATIONS ROUTINES
  Original name: 0046.PAS
  Description: Reading on bit of an inte
  Author: MAYNARD PHILBROOK
  Date: 05-25-94  08:15
*)

{
 SK> 12345 --------------- Longinteger of the value 12345
 SK> ^^^^^
 SK> |||||
 SK> ||||+----------------- Integer value 5
 SK> ||||
 SK> |||+------------------ Integer value 4
 SK> |||
 SK> ||+------------------- Integer value 3
 SK> ||
 SK> |+-------------------- Integer value 2
 SK> |
 SK> +--------------------- Integer value 1

 SK> I tried using the procedure of geting the MOD of a number then div the
 SK> number out. It works fine until you get a number like
 SK> 10,100,1000,100000, etc....
 SK> Please help...
 not sure what your asking but have you  can use SHR, SHL, OR ect to fetch
 single bits..........
}
function getbitstate( bitpos:byte; lint:longint):boolean;
 begin
  asm
   mov @result, 00; { clear bolean first }
   cmp bitpos, 16
   jg  @higher;
   mov bx, lint;
@yup:
   test bx, bitpos;
   jnz @yes;
   jmp @done;
@higher:
   mov bx,lint+2;
   jmp @yup;
@yes:
   inc @result, 1;          { adjust bolean return }
@done:
  end;
end;

_____ to use it ____

Begin
 if getbitstate(8, $80) then Write(' Yup, it's on ');
end;

