(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0064.PAS
  Description: Virtual Screens
  Author: DAVID DUNSON
  Date: 05-25-94  08:18
*)


{
William Schroeder wrote in a message to All:

 WS> PROCEDURE CopyScreen(First, Second, Mask: Byte);
 WS> BEGIN
 WS>   Move(VirtualScreen[First],VirtualScreen[Second],64000);
 WS> END;

I would suggest that you use First and Second as Pointers as opposed to Bytes
and pass the address of your screens.

Try this procedure and see what this does for ya.

--------------------------------------------------------------------------
}
Program Mask;

Var
    s1, s2 : String;

Procedure CopyMask(Org, Dst: Pointer; Size: Word; Mask: Byte); Assembler;
ASM
      PUSH  DS
      LDS   SI, Org
      LES   DI, Dst
      MOV   CX, Size
      MOV   BL, Mask
@@1:  LODSB
      CMP   AL, BL
      JNZ   @@2
      INC   DI
      JMP   @@3
@@2:  STOSB
@@3:  LOOP  @@1
      POP   DS
End;

Begin
   s1 := 'Hello';
   s2 := 'XXXXXXXXX';
   CopyMask(@s1, @s2, 255, Byte('l'));
   WriteLn(s1);
   WriteLn(s2);
End.

-------------------------------------------------------------------------

If you run this program, you'll notice that s1 ('Hello') is copied to s2 with
the exception that 'l' was not copied giving s2 a value of 'HeXXo'.  Be
carefull in using this on Pascal type strings, because byte[0] (the length
byte) is also "masked".

In order for you to use this procedure for your virtual screens, you would have
to call it passing the address of your screens.  Example:

CopyMask(@VirtualScreen[first], @VirtualScreen[Second], 64000, Mask);

David

