{
 DR> Hello I was wondering how I might be able to load a batch
 DR> file under Turbo Pascal. I was also wondering how to
 DR> change how the mouse symbol looks like when you install
 DR> the mouse in your programs. Thank you.
}
Type
        CursorData  = Array [1..32] of Word;

        ArrowMask : CursorData = ($7fff,$3fff,$1fff,$0fff,
                                  $07ff,$03ff,$01ff,$00ff,
                                  $007f,$03ff,$03ff,$29ff,
                                  $71ff,$f0ff,$faff,$f8ff,

                                  $8000,$C000,$A000,$9000,
                                  $8800,$8400,$8200,$8100,
                                  $8f80,$9400,$b400,$d200,
                                  $8a00,$0900,$0500,$0700);

        HourGlassMask : CursorData = ($0000,$0000,$0000,$c003,
                                      $e007,$f00f,$F81F,$fc3f,
                                      $fc3F,$F81F,$F00F,$e007,
                                      $c003,$0000,$0000,$0000,

                                      $0000,$7ffe,$0000,$1ff8,
                                      $0ff0,$0000,$0000,$0000,
                                      $0180,$0340,$07e0,$0e78,
                                      $1818,$0000,$7ffe,$0000);








Var
        Regs    : Registers;



Procedure SetMouseCursor(CursorMask : CursorData);

Begin
        Regs.AX := $0009;
        Regs.BX := $0004;
        Regs.CX := $0004;
        Regs.ES := Seg(CursorMask);
        Regs.DX := Ofs(CursorMask);
        Intr($33,Regs);
End;



Here's a little routine I used to change my cursor from an arrow to an
hour-glass and back.... You can design your own cursors by following my
examples. The First 16 Words of the array are the cursor the next 16 are
the mask.
