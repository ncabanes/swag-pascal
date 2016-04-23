Uses Dos;
Var
    regs :  Registers;
    stat :  Byte;
    inse, caps, numl, scrll, alt, ctrl, lshift, rshift : Boolean;
    { declaration of all the bools hidden :) }
begin
     regs.ah:=2; intr($16,regs);
     stat:=regs.al;

     inSE   := stat and 128 <> 0;   { Insert on    }
     CAPS   := stat and  64 <> 0;   { CapsLock     }
     NUML   := stat and  32 <> 0;   { NumLock      }
     SCRLL  := stat and  16 <> 0;   { ScrolLock    }
     ALT    := stat and   8 <> 0;   { ALT pressed  }
     CTRL   := stat and   4 <> 0;   { CTRL pressed }
     LSHifT := stat and   2 <> 0;   { left Shift " }
     RSHifT := stat and   1 <> 0;   { right Shift" }

     Writeln(inSE);
     Writeln(CAPS);
     Writeln(NUML);
     Writeln(SCRLL);
     Writeln(ALT);
     Writeln(CTRL);
     Writeln(LSHifT);
     Writeln(RSHifT);
end.
