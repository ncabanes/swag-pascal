  Procedure HideCursor;  assembler;
  asm
    mov      ah,$01  { Function number }
    mov      ch,$20
    mov      cl,$00
    Int      $10     { Call BIOS }
  end;  { HideCursor }


  Procedure RestoreCursor;  assembler;
  asm
    mov      ah,$01  { Function number }
    mov      ch,$06  { Starting scan line }
    mov      cl,$07  { Ending scan line }
    int      $10     { Call BIOS }
  end; { RestoreCursor }
