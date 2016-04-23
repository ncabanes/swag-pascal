{
SEAN PALMER

> Does anyone know how to Write an ISR (interrupt service routine) that will
> continue With the interrupt afterwards. EX: if you Write an ISR that traps
> the mouse Int 33h but let the mouse still operate.

Try:
}

Var
  oldMouseHook : Procedure;

Procedure mouseHook(AX,BX,CX,DX,SI,DI,DS,ES,BP); interrupt;
begin

 {Your stuff goes here}
 {make sure it doesn't take TOO long!}

 Asm
   pushF;
 end;          {simulate an interrupt}

 oldMouseHook; {call old handler}
end;

{ to install: }

 getIntVec($33,@oldMouseHook);
 setIntVec($33,@mouseHook);

{ to deinstall: }

 setIntVec($33,@oldMouseHook);

