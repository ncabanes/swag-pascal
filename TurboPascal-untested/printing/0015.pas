===========================================================================
 BBS: The Beta Connection
Date: 06-08-93 (20:02)             Number: 819
From: JEFF PALEN                   Refer#: 777
  To: DAN SABIN                     Recvd: YES 
Subj: PRINTER CRASHING               Conf: (232) T_Pascal_R
---------------------------------------------------------------------------
DS>Does anyone know how you can check from Turbo Pascal that the
DS>printer is turned on so that you won't get a device error that
DS>will crash a program?  I can't find anything about this.

Program  Printer_Status;
Uses Dos;
Function PrinterOnLine : Boolean;
  Const
    PrnStatusInt  : Byte = $17;    (*  Dos interrupt *)
    StatusRequest : Byte = $02;    (*  Interrupt Function Call *)

    PrinterNum    : Word = 0;  { 0 for LPT1, 1 for LPT2, etc. }
  Var
    Regs : Registers ;         { Type is defined in Dos Unit }

    Begin  (* PrinterOnLine*)
      Regs.AH := StatusRequest;
      Regs.DX := PrinterNum;
      Intr(PrnStatusInt, Regs);
      PrinterOnLine := (Regs.AH and $80) = $80;
    End;

Begin (* Main Program *)
  If PrinterOnLine Then
    Writeln('Ready To Print')
  Else
    Writeln('Please check the printer!');
End.

---
 ■ RM 1.0  ■ Eval Day 4 ■ Programmer's do it with bytes and nybbles....
 * Channel 1(R) * 617-354-7077 * Cambridge MA * 85 lines
 * PostLink(tm) v1.06  CHANNEL1 (#15) : RelayNet(tm)
