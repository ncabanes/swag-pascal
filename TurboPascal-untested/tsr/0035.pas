{
> upon another problem: how do I detect the "presence" of a
> self-developed TSR, which I made resident with KEEP(0) ?
}

VAR
  HandlerSeg : WORD;

Begin
  asm
    mov ax, $3565
    int $21
    mov Handlerseg, es
  End;

  IF (Handlerseg <> $FFFF)  THEN
  Begin
    asm
      push ds
      mov ax, $FFFF
      mov ds, ax
      mov ax, $2565
      mov dx, $0000
      int $21
      pop ds
    End;
  End
  ELSE
  Begin
    WriteLn( 'Program already installed.' );
    Halt( 0 );
  End;

  { Blah blah blah }
End.
