(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0034.PAS
  Description: Detect Float Error
  Author: GERD KORTEMEYER
  Date: 08-27-93  21:23
*)

{
GERD KORTEMEYER

here are two Units For trapping float-exceptions. In your Program you
will have to add

  Uses err387

and at the beginning of your main Program say For example

begin
   exception(overflow, masked);
   exception(underflow, dumpask);
   exception(invalid, dumpexit);
   autocorrect(zerodiv, 1.0);
   exception(precision, masked);

In this way you can choose For any kind of exception in which way it is
to be handeled. After the lines above the result of a division by zero
will be '1.0', in Case of an underflow there will be a dump of the copro
and the user will be asked For the result he wants the operation to have,
in Case of an overflow the largest available number will be chosen and
so on ...

Here are the Units

    err387 and dis387
}

{ ---------------------------------------------------------- }
{ Fehlerbehandlungsroutinen fuer den Intel 80387 bzw. 486 DX }
{ Geschrieben in Turbo Pascal 6.0                            }
{ von Gerd Kortemeyer, Hannover                              }
{ ---------------------------------------------------------- }

Unit err387;

Interface

Uses
  dis387, Dos, Crt;

Const
  invalid   = 1;
  denormal  = 2;
  zero_div  = 4;
  overflow  = 8;
  underflow = 16;
  precision = 32;
  stackfault= 64;
  con1      = 512;

  masked    = 0;
  runtime   = 1;
  dump      = 2;
  dumpexit  = 3;
  dumpask   = 4;
  autocorr  = 5;


Procedure exception(which, what : Word);
Procedure autocorrect(which : Word; by : Extended);

Procedure handle_off;
Procedure handle_on;

Procedure restore_masks;

Procedure clear_copro;
Function  status_Word : Word;

Var
  do_again : Word;

Implementation

Const
  valid = 0;
  zero  = 1;
  spec  = 2;
  empty = 3;

  topmask : Word = 14336;
  topdiv  = 2048;

  anyerrors : Word = 63;

  zweipot : Array [0..15] of Word =
    (1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024,
     2048, 4096, 8192, 16384, 32768);

  ex_nam : Array[0..5] of String=
    ('Invalid   ',
     'Denormal  ',
     'Zero-Div  ',
     'Overflow  ',
     'Underflow ',
     'Precision ');

Var
  setmasks : Byte;
  normal   : Record
    Case Boolean OF
      True : (adr : Pointer);
      False: (pro : Procedure);
    end;

  Exit_on,
  dump_on,
  ask_on,
  auto_on,
  standard : Word;

  auto_val : Array [0..5] of Extended;

Procedure Mask(which : Word);
Var
  cw : Word;
begin
  Asm
    fstcw cw
  end;
  cw := cw or which;
  setmasks := Lo(cw);
  Asm
    fldcw cw
  end;
end;

Procedure Unmask(which : Word);
Var
  cw : Word;
begin
  Asm
    fclex
    fstcw cw
  end;
  cw := cw and not (which);
  setmasks := Lo(cw);
  Asm
    fldcw cw
  end;
end;

Procedure restore_masks;
Var
  setm : Word;
  i    :Integer;
begin
  setm:=setmasks;
  For i := 0 to 5 do
    if (setm and zweipot[i]) <> 0 then
      Mask  (zweipot[i])
    else
      Unmask(zweipot[i]);
end;

Procedure clear_copro;
Var
  cw : Word;
begin
  Asm
    fstcw cw
  end;
  setmasks := Lo(cw);
  Asm
    finit
  end;
end;

Function status_Word;
begin
  Asm
    fstsw @result
  end;
end;

{ Bei welcher Exception soll was passieren? }
Procedure exception;
begin
  Case what OF

    masked  : Mask(which);

    runtime :
      begin
        Unmask(which);
        standard := standard or which;
      end;

    dump :
      begin
        Unmask(which);
        standard := standard and NOT(which);
        dump_on  := dump_on  or  which;
        Exit_on  := Exit_on  and NOT(which);
        ask_on   := ask_on   and NOT(which);
        auto_on  := auto_on  and NOT(which);
      end;

    dumpexit :
      begin
        Unmask(which);
        standard := standard and NOT(which);
        dump_on  := dump_on  or  which;
        Exit_on  := Exit_on  or  which;
        ask_on   := ask_on   and NOT(which);
        auto_on  := auto_on  and NOT(which);
      end;

    dumpask :
      begin
        Unmask(which);
        standard := standard and NOT(which);
        dump_on  := dump_on  or  which;
        Exit_on  := Exit_on  and NOT(which);
        ask_on   := ask_on   or  which;
        auto_on  := auto_on  and NOT(which);
      end;
   end;
end;

{ zum Setzen von Auto-Korrekt-Werten }

Procedure autocorrect;
Var
  i : Integer;
begin
   Unmask(which);
   standard := standard and NOT(which);
   dump_on  := dump_on  and NOT(which);
   Exit_on  := Exit_on  and NOT(which);
   ask_on   := ask_on   and NOT(which);
   auto_on  := auto_on  or  which;
   For i := 0 to 5 do
     if (which and zweipot[i]) <> 0 then
       auto_val[i] := by;
end;

{ ------------- Die Interrupt-Routine selbst ------------- }

Procedure errorcon; Interrupt;
Var
  copro : Record
    control_Word,
    status_Word,
    tag_Word, op,
    instruction_Pointer,
    ip, operand_Pointer, : Word;
    st                   : Array [0..7] of Extended;
  end;

  top : Integer; { welches Register ist Stacktop? }

  masked,            { welche Exceptions maskiert? }
  occured : Byte;    { welche Exceptions aufgetreten? }

  opcode  : Word;

  inst_seg,       { Instruction-Pointer, Segment }
  inst_off,       { "                  , Offset  }
  oper_seg,       { Operand-Pointer    , Segment }
  oper_off: Word; { "                  , Offset  }

  inst_point : ^Word;                 { zum Adressieren des Opcodes }

  oper_point : Record
    Case Integer of { zum Adressieren des Operanden }
      1 : (ex : ^Extended);
      2 : (db : ^Double);
      3 : (si : ^Single);
      4 : (co : ^Comp);
    end;

  marker: Array [0..7] of Word; { Register-Marker nach Tag-Word }

  opt_dump,               { soll ausgeben werden? }
  opt_exit,               { soll aufgehoert werden? }
  opt_ask,                { soll Ergebnis abgefragt werden? }
  opt_auto  : Boolean;    { soll Ergebnis automatisch korrigiert werden? }

  i         : Integer;

  mem_access: Boolean;    { gibt es Speicherzugriff? }

  op_name   : String;     { Mnemonik des Befehls }

{ Ersetze Stacktop durch abgefragten Wert }
Procedure ask_correct;
Var
  res  : Extended;
  ch   : Char;
  t    : String;
  code : Integer;
begin
   Asm
     fstp res
   end;
   WriteLN;
   Write('The result would be ', res, '. Change? (y/n) ' );
   Repeat
     Repeat Until KeyPressed;
     ch := ReadKey;;
   Until ch in ['Y','y','N','n'];
   Writeln;
   if ch in ['Y','y'] then
   Repeat
     Write('New value : ');
     READLN(t);
     VAL(t, res, code);
   Until code = 0;
   Asm
     fld res
   end;
end;

Function hex(w : Word) : String; { Ausgabe als HeX-Zahl }
Const
  zif : Array [0..15] of Char = ('0','1','2','3','4','5','6','7','8','9',
                                    'a','b','c','d','e','f');
begin
  hex := zif[w div zweipot[12]] +
         zif[(w MOD zweipot[12]) div zweipot[8]] +
         zif[(w MOD zweipot[8]) div zweipot[4]] +
         zif[w MOD zweipot[4]];
end;

Procedure choice;
Var
  ch : Char;
begin
  WriteLN;
  Write('C)ontinue, A)bort ');
  Repeat
    Repeat Until KeyPressed;
    ch:=ReadKey;;
    if ch in ['A','a'] then
      Halt(0);
  Until ch in ['C','c'];
  WriteLN;
end;

Procedure showcopro; { Ausgeben des FSAVE - Records }
Var
  i : Integer;
begin
  TextMode(LastMode);
  HighVideo;
  WriteLN('Floating point exception, last opcode: ',hex(opcode),
                                               ' (',op_name,')');
  NormVideo;
  WriteLN('Instruction Pointer : ',hex(inst_seg),':',hex(inst_off),
          ' (',hex(inst_point^),')');
  if mem_access then
  begin
    WriteLN('Operand Pointer     : ',hex(oper_seg),':',hex(oper_off));
    WriteLN('( Extended: ',oper_point.ex^,', Double: ',oper_point.db^);
    WriteLN('  Single  : ',oper_point.si^,', Comp  : ',oper_point.co^,' )');
  end
  else
  begin
    WriteLN;
    WriteLN ('No memory access');
    WriteLN;
  end;
  HighVideo;
  if (occured and stackfault) = 0 then
  begin
    WriteLN('Exception ','Masked':8,'Occured':8,'Should be masked':18);
    NormVideo;
    For i:=0 to 5 do
      WriteLN(ex_nam[i], (masked   and zweipot[i]) <> 0 : 8,
                         (occured  and zweipot[i]) <> 0 : 8,
                         (setmasks and zweipot[i]) <> 0 : 18);
    HighVideo;
  end
  else
  begin
    WriteLN('Invalid Operation:');
    if (copro.status_Word and con1) <> 0 then
      WriteLN('                       -- Stack Overflow --')
    else
      WriteLN('                       -- Stack Underflow --');
    WriteLN;
  end;

  WriteLN('Reg  ','Value':29,'Marked':10);
  Normvideo;
  For i := 0 to 7 do
  begin
    Write('st(',i,')', copro.st[i] : 29);
    Case marker[i] OF
       valid : WriteLN('Valid'   : 10);
       spec  : WriteLN('Special' : 10);
       empty : WriteLN('Empty'   : 10);
       zero  : WriteLN('Zero'    : 10);
    end;
  end;
end;

{ Ersetze Stacktop durch Auto-Korrekt-Wert }

Procedure auto_corr;
Var
  res : Extended;
  i   : Integer;
begin
  Asm
    fstp res
  end;
  For i := 0 to 5 do
    if ((occured and zweipot[i]) <> 0) and
       ((auto_on and zweipot[i]) <> 0) then
      res := auto_val[i];
  Asm
    fld res
  end;
end;


Procedure do_it_again;
Type
  codearr = Array[0..4] of Byte;
Var
  sam : Record
    Case Boolean OF
      True : (b: ^codearr );
      False: (p: Procedure);
    end;

  op_point : Pointer;
  x        : extended;
begin
  New(sam.b);
  sam.b^[0]:=Hi(opcode);
  sam.b^[1]:=Lo(opcode);
  if mem_access then
  begin
  { --- mod r/m auf ds:[di] stellen (00ttt101) --- }
    sam.b^[1] := sam.b^[1] and not (zweipot[7] + zweipot[6] + zweipot[1]);
    sam.b^[1] := sam.b^[1] or (zweipot[2] + zweipot[0]);
  end;
  sam.b^[2] := $ca; { retf 0000 }
  sam.b^[3] := $00;
  sam.b^[4] := $00;
  op_point  := oper_point.ex;
  Asm
    push ds
    lds di, op_point
  end;

  sam.p;

  Asm
    pop ds
  end;
  Dispose(sam.b);
end;

begin
  Asm
    push   ax
    xor    al,al
    out    0f0h,al
    mov    al,020h
    out    0a0h,al
    out    020h,al
    pop    ax
    fsave  copro
  end;

  { === Pruefen, ob Bearbeitung durch ERRORCON erwuenscht === }
  if (copro.status_Word and standard) <> 0 then
  begin
    Asm
      frstor copro
    end;
    normal.pro; { Bye, bye ... }
  end;
  { === Auswerten des FSAVE-Records ========================= }
  { --- Opcode wie im Copro gespeichert     --- }
  opcode := zweipot[15] + zweipot[14] + zweipot[12] + zweipot[11] +
            (copro.ip MOD zweipot[11]);
  op_name := dis(opcode);
  mem_access := op_name='...';
  { --- Was war maskiert, was ist passiert? --- }
  masked  := Lo(copro.control_Word);
  occured := Lo(copro.status_Word );
  { --- Der Instruction-Pointer             --- }
  inst_seg := copro.ip and (zweipot[15] + zweipot[14] + zweipot[13] +
                           zweipot[12]);
  inst_off := copro.instruction_Pointer;
  inst_point := Ptr(inst_seg,inst_off);
  { --- Der Operand-Pointer                 --- }
  oper_seg := copro.op and (zweipot[15] + zweipot[14] + zweipot[13] +
                            zweipot[12]);
  oper_off := copro.operand_Pointer;
  oper_point.ex := Ptr(oper_seg,oper_off);
  { --- Wer ist gerade Stacktop? --- }
  top := (copro.status_Word and topmask) div topdiv;
  { --- Einlesen der Marker aus Tag-Word --- }
  For i := 0 to 7 do
  begin
    marker[(8 + i - top) MOD 8] := (copro.tag_Word and (zweipot[i * 2] +
                                    zweipot[i * 2 + 1])) div zweipot[i * 2];
  end;

  { --- Welche Aktionen sollen ausgefuehrt werden? --- }
  opt_dump := (copro.status_Word and dump_on) <> 0;
  opt_exit := (copro.status_Word and Exit_on) <> 0;
  opt_ask  := (copro.status_Word and ask_on ) <> 0;
  opt_auto := (copro.status_Word and auto_on) <> 0;

  { === Aktionen ============================================ }
  if opt_dump then
    showcopro;
  if opt_exit then
  begin
    WriteLN;
    WriteLN('Exit Program due to Programmers request');
    HALT; { Bye, bye ... }
  end;
  if opt_dump and not (opt_ask) then
    choice;

  copro.control_Word := copro.control_Word or anyerrors;
  Asm
    frstor copro
    fclex
  end;
  { --- Befehl nochmals ausfuehren --- }
  if (occured and do_again) <> 0 then
    do_it_again;
  { --- Noch was? --- }
  if opt_auto then
    auto_corr;
  if opt_ask  then
    ask_correct;
  restore_masks;
end;

{ ------------- Ein- und Ausschalten ------------- }

Procedure handle_on;
begin
  Getintvec($75, normal.adr);
  Setintvec($75, @errorcon);
end;

Procedure handle_off;
begin
  Setintvec($75, normal.adr);
end;

begin
  handle_on;
  dump_on :=0;
  Exit_on :=0;
  ask_on  :=0;
  auto_on :=0;
  standard:=0;
  do_again:=invalid+zero_div+denormal;
  clear_copro;
end.






Unit dis387;

Interface

Function dis(opco : Word) : String;

Implementation

Function dis;
Var
  d, op : String;

  Procedure opcr(st : Word);
  Var
    t : String;
  begin
    str(st, t);
    op := ' st,st(' + t + ')';
  end;

  Procedure opc(st : Word);
  Var
    t : String;
  begin
    str(st, t);
    op := ' st(' + t + '),st';
  end;

  Procedure op1(st : Word);
  Var
    t : String;
  begin
    str(st, t);
    op := ' st(' + t + ')';
  end;

begin
  d  := '...';
  op := '';

  Case Hi(opco) OF
    $d8 :
      Case Lo(opco) div 16 OF
        $c :
          if opco MOD 16 >= 8 then
          begin
            d := 'fmul';
            opcr(opco MOD 16 - 8);
          end
          else
          begin
            d := 'fadd';
            opcr(opco MOD 16);
          end;

        $e :
          if opco MOD 16 >= 8 then
          begin
            d := 'fsubr';
            opcr(opco MOD 16 - 8);
          end
          else
          begin
            d := 'fsub';
            opcr(opco MOD 16);
          end;

        $f :
          if opco MOD 16 >= 8 then
          begin
            d := 'fdivr';
            opcr(opco MOD 16 - 8);
          end
          else
          begin
            d := 'fdiv';
            opcr(opco MOD 16);
          end;
      end;

   $d9 :
     Case Lo(opco) OF
       $d0 : d := 'fnop';
       $e0 : d := 'fchs';
       $e1 : d := 'fabs';
       $e4 : d := 'ftst';
       $e5 : d := 'fxam';
       $e8 : d := 'fld1';
       $e9 : d := 'fld2t';
       $ea : d := 'fld2e';
       $eb : d := 'fldpi';
       $ec : d := 'fldlg2';
       $ed : d := 'fldln2';
       $ee : d := 'fldz';
       $f0 : d := 'f2xm1';
       $f1 : d := 'fyl2x';
       $f2 : d := 'fptan';
       $f3 : d := 'fpatan';
       $f4 : d := 'fxtract';
       $f5 : d := 'fprem1';
       $f6 : d := 'fdecstp';
       $f7 : d := 'fincstp';
       $f8 : d := 'fprem';
       $f9 : d := 'fyl2xp1';
       $fa : d := 'fsqrt';
       $fb : d := 'fsincos';
       $fc : d := 'frndint';
       $fd : d := 'fscale';
       $fe : d := 'fsin';
       $ff : d := 'fcos';
     end;

   $db :
     Case Lo(opco) OF
       $e2 : d := 'fclex';
       $e3 : d := 'finit';
     end;
   $dc :
     Case Lo(opco) div 16 OF
       $c :
         if opco MOD 16 >= 8 then
         begin
           d := 'fmul';
           opc(opco MOD 16-8);
         end
         else
         begin
           d := 'fadd';
           opc(opco MOD 16);
         end;

       $e : if opco MOD 16 >= 8 then
         begin
           d := 'fsub';
           opc(opco MOD 16 - 8);
         end
         else
         begin
           d := 'fsubr';
           opc(opco MOD 16);
         end;

       $f :
         if opco MOD 16 >= 8 then
         begin
           d := 'fdiv';
           opc(opco MOD 16 - 8);
         end
         else
         begin
           d := 'fdivr';
           opc(opco MOD 16);
         end;
     end;

   $dd :
     Case Lo(opco) div 16 OF
       $c :
         begin
           d := 'ffree';
           op1(opco MOD 16);
         end;
       $d :
         if opco MOD 16 >= 8 then
         begin
           d := 'fstp';
           op1(opco MOD 16 - 8);
         end
         else
         begin
           d := 'fst';
           op1(opco MOD 16);
         end;
       $e :
         if opco MOD 16 >= 8 then
         begin
           d := 'fucomp';
           op1(opco MOD 16 - 8);
         end
         else
         begin
           d := 'fucom';
           op1(opco MOD 16);
         end;
     end;

   $de :
     Case Lo(opco) div 16 OF
       $c :
         if opco MOD 16 >= 8 then
         begin
           d := 'fmulp';
           opc(opco MOD 16 - 8);
         end
         else
         begin
           d := 'faddp';
           opc(opco MOD 16);
         end;

       $d : d := 'fcompp';

       $e :
         if opco MOD 16 >= 8 then
         begin
           d := 'fsubp';
           opc(opco MOD 16 - 8);
         end
         else
         begin
           d := 'fsubrp';
           opc(opco MOD 16);
         end;

       $f :
         if opco MOD 16 >= 8 then
         begin
           d := 'fdivp';
           opc(opco MOD 16 - 8);
         end
         else
         begin
           d := 'fdivrp';
           opc(opco MOD 16);
         end;
     end;
   end;

   dis := d + op;
end;

begin
end.

