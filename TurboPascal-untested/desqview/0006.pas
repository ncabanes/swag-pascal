{
      Simply pass a number (1-3) through it:
         1 -- Switches to next window
         2 -- Pops up the Alt menu
              ^^^^^^^^^^^^^^^^^^^^ this is what you want
         3 -- Close the current window

      I don't know about Alt-H though.. I know that if you used ReadKey
      you'd have to read it twice -- once for the #0 (tells you that
      it is an extended code) -- again for the extended code (35=Alt-H).

      Hope this helps!  Good luck.
      -- Jeff.Guillaume@launchpad.unc.edu
}

Procedure DesqView(Func : Byte); ASSEMBLER;
ASM
  mov   AH, $05
  cmp   Func, 1           { Switch to next window }
  je    @SwitchNext
  cmp   Func, 2           { Pop up Alt-menu }
  je    @PopDesqView
  cmp   Func, 3           { Close current window }
  je    @CloseWin
 
@SwitchNext:
  mov   CX, $FB00
  jmp   @CallInt
 
@PopDesqView:
  mov   CX, $FC00
  jmp   @CallInt
 
@CloseWin:
  mov   CX, $FE00
 
@CallInt:
  int   $16
 
End; {* DesqView *}
