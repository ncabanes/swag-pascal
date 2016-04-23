{
> I have seen a lot of applications that use highintensity background
> colors in Text mode.  How do they do it??????
}

Uses Crt ;

Procedure DisableHiBackGround(SetHi : Boolean); Assembler;
Asm
     Mov  AX, $1003
     Mov  BL, SetHi
     Int  $10
end ;

begin
     ClrScr;
     TextAttr := White + (LightRed ShL 4);
     DisableHiBackGround(True) ;
     Write('Blinking...[Enter]') ;
     ReadLn ;
     DisableHiBackGround(False) ;
     Write('      WOW !!!     ') ;
     ReadLn ;
end.
