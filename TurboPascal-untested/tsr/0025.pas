
{ This TSR, when press Crtl+Print Screen save to disk the screen. }
{Antonio Moro's routines, from Spain TP Echo}
{$M 1024, 0, 0}  (* 1 K for Stack *)
{$S-}
PROGRAM Caza;
USES Dos, Crt;
VAR   numfichero   : Byte;
      fichero      : File;
      s_num, drive : String [2];
      buffg        : Pointer;

PROCEDURE Graba (Flags, CS, IP, AX, BX, CX, DX, SI, DI, DS, ES, BP: Word);
INTERRUPT;
   Begin
        Str(numfichero,s_num);
        Inc(numfichero);
        Assign(fichero, drive + 'SCREEN.' + s_num);
        Rewrite(fichero,1);
        buffg:= Ptr($B000,0);     (* Hercules video memory direction *)
        BlockWrite(fichero,buffg^,32768); (* save 32K block of video memory    
                                          in a file*)
        Close(fichero);
   End;

BEGIN
     If ParamCount = 1 Then  drive:=ParamStr(1) + ':'
        Else drive:='C:';
     Writeln;
     HighVideo;
     Writeln('Resident Savescreen.');
     Write('For activate press SHIFT + PRTSCR');
     LowVideo;
     Writeln;
     numfichero:=0;
     SetINtVec(5, @Graba);  (* Change interrupt vector of 5 interruption
                               (print screen) *) 
     Keep(0);               (* End and Stay Resident *)

END.
