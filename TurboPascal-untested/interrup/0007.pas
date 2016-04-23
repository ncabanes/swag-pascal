==============================================================================
 BBS: -=- Edge of the Century -=-
  To: PERCY WONG                   Date: 03-22-93 (10:19)
From: GAYLE DAVIS                Number: 4475   [140] Pascal
Subj: Capturing Dos Output       Status: Public
------------------------------------------------------------------------------
PW>-> PW>  EXEC(GETENV(COMSPEC),' \C DIR'); { or whatever it is }
PW>-> >can i then capture each line (or even one line) of the Dir output to

Percy or Kerry ??,

An elegant  way of accomplishing  your goal  is  to grap INT29.  This is an
UNDOCUMENTED  DOS function,  however, it's  really simple  to use. DOS uses
this to write EVERYTHING to the screen.  The problem is that there is a LOT
of data  output when screen writing  takes place. If you  try to capture to
much you will  need LOTS of memory. However, short  output like your trying
to get is OK.

Here is some sample code that will let you capture output :


{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V-,X+,Y+}
{$M 4096,0,400000}

Uses DOS,Crt;

Type
  ISRRegisters =
    record
      case Byte of
        1 : (BP, ES, DS, DI, SI, DX, CX, BX, AX, IP, CS, Flags : Word);
        2 : (j1,j2,j3,j4,j5 : Word; DL, DH, CL, CH, BL, BH, AL, AH : Byte);
    end;

CONST

  OrigInt29 : Pointer = nil;             {Old int 29 vector}

Var
    grab  : Array[1..32768] Of Char;   { this MAY NOT be enough !!!     }
    idx : LongInt;                     { if output EXCEEDS this, might  }
                                       { lock up machine, so be careful }
    S   : String;
    I   : LongInt;

{ Here is the MAGIC }
procedure Int29(BP : Word); interrupt;

var
  Regs : ISRRegisters absolute BP;

begin


 Grab[Idx] := CHAR(Regs.AL);
 Inc(idx);

 { WILL LOOSE OUTPUT, BUT BETTER THAN LOCKING MACHINE !!}
 If Idx > SizeOf(Grab) THEN Idx := 1;

 ASM
 PopF
 call OrigInt29
 END;

end;

BEGIN

  GetIntVec($29, OrigInt29);
  SetIntVec($29, @Int29);


  Clrscr;
  Idx := 1;

  {Shell to DOS and run your program}

  SwapVectors;
  Exec(GetEnv('COMSPEC'), '/c '+ YOURPROGRAM);
  SwapVectors;

  { GRAB now contains ALL of our output }

  FOR I := 1 TO Idx DO
      BEGIN
      If Grab[i] = #10 Then BEGIN
                           WriteLn(S);
                           S := ''
                           END ELSE If Grab[i] <> #13 THEN S := S + Grab[i];

      END;

  { ABSOLUTELY MUST BE DONE !! }
  if OrigInt29 <> nil then SetIntVec($29, OrigInt29);


UtiExprt: To be continued in next message ...
---
 * T.I.F.S.D.B.(from MD,USA 301-990-6362)
 * PostLink(tm) v1.05  TIFSDBU (#1258) : RelayNet(TM)
