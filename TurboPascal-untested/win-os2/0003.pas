{
>How can I check from my Dos Program that Windows are running in
>the background?
}

Unit Chk4Win;

Interface

Type
  Win3ModeType = (NoWin, RealStd, Enhanced);

Function CheckForWin3 : Win3ModeType;

Implementation

Function CheckForWin3 : Win3ModeType;  Assembler;
Asm
  mov    ax,1600h
  int    2Fh
  cmp    al,1
  jbe    @@CheckRealStd
  cmp    al,80h
  jae    @@CheckRealStd
  mov    al,2
  jmp    @@ExitPoint
@@CheckRealStd:
  mov    ax,4680h
  int    2Fh
  or     ax,ax
  jnz    @@notWin
  mov    al,1
  jmp    @@ExitPoint
@@notWin:
  xor    al,al
@@ExitPoint:
end;

end.
