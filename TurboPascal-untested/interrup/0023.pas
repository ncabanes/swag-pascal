
Program How_To_Create_YOUR_OWN_Interrupt;

(* Author: Salvatore Meschini - E-Mail: smeschini@ermes.it -
 WWW: http://www.ermes.it/pws/mesk - Please report bugs and suggestions -
 Get File Formats Encyclopedia at http://www.gdsoft.com/swag/ffe101.zip OR
 http://www.simtel.net/pub/simtelnet/msdos/pgmutl/ffe101.zip *)

uses
  crt, DOS;

var dummy:byte;

(*----------------------------------------------------------------------------*)
procedure Main;
  begin
    clrscr;
    textcolor(10);
    writeln('YOUR PROGRAM IS RUNNING!!! (Press any key)');
    readkey;
  end;

(*----------------------------------------------------------------------------*)
procedure Buzzer;
  begin
    textcolor(15);
    writeln('LONG BEEP...');
    sound(1000);
    delay(1000);
    nosound;
  end;

(*----------------------------------------------------------------------------*)

Procedure PrintResult;
   begin
     textcolor(12);
     writeln('AL=03 * CL=1 = ',dummy);
     delay(1000);
   end;

(*----------------------------------------------------------------------------*)
procedure MyInt(Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
                interrupt;
  begin
    asm cli end;
    case ax of
      0001: Main;
      0002: Buzzer;
      0003: asm
            mul cl {Do a silly mul (result -> in AL)}
            mov dummy,al
            end;
      0004: PrintResult;
      {...you can define your own routines...}
    end;
    asm sti end;
  end;

(*----------------------------------------------------------------------------*)
begin
  setintvec($FF, @myint); (* You can freely use interrupts from F1h (241) to
FFh (255)*)
  asm
   mov ax,0001
   int 0FFh    {Run a whole PROGRAM with INT instruction!
                    Hint: Hard to trace 4hackers...}

   mov ax,0002
   int 0FFh    {Beep}

   mov ax,0003
   mov cl,1
   int 0FFh     {Multiply with result in AL}

   mov ax,0004
   int 0FFh     {Now call PrintResult}
  end;
end.

