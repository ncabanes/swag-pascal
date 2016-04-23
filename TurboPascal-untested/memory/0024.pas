{
HENRIK SCHMIDT-MOELLER

I've made some procedures for EMS addressing in TP. EMS uses a technic called
bank switching. It reserves a 64k area (EmmSeg) in memory for EMS and maps/
unmaps 16k EMS-pages in this area. Look at interrupt 67h for a complete list of
EMS commands. I haven't had time to comment on these procedures, so if you
don't understand them, feel free to ask. OK, here goes nothing...

Oh, by the way, REMEMBER to DEallocate!!!
}

VAR
  EmmSeg,
  EmmHandle : Word;
  Err       : Byte;

PROCEDURE DeallocateMem(Handle : Word); Forward;

PROCEDURE Error(E : String);
BEGIN
  DeallocateMem(Emmhandle);
  WriteLn(#7 + E);
  Halt(1);
END;

PROCEDURE AllocateMem(LogPages : Word);
BEGIN
  ASM
    MOV  AH, 43h
    MOV  BX, LogPages
    INT  67h
    MOV  Err, AH
    MOV  EmmHandle, DX
  END;
  CASE Err OF
    $80 : Error('AllocateMem: Internal error in EMS software');
    $81 : Error('AllocateMem: Malfunction in EMS software');
    $84 : Error('AllocateMem: Undefined function');
    $85 : Error('AllocateMem: No more handles available');
    $87 : Error('AllocateMem: Allocation requested more pages than are' + #13#10 +
                '             physically available; no pages allocated');
    $88 : Error('AllocateMem: Specified more logical pages than are'+ #13#10 +
                ' currently available; no pages allocated');
    $89 : Error('AllocateMem: Zero pages requested');
  END;
END;

PROCEDURE MapEmm(PsyPage : Byte; LogPage : Word);
BEGIN
  ASM
    MOV  AH, 44h
    MOV  AL, PsyPage
    MOV  BX, LogPage
    MOV  DX, EmmHandle
    INT  67h
    MOV  Err, AH;
  END;
  CASE Err OF
    $80 : Error('MapEmm: Internal error in EMS software');
    $81 : Error('MapEmm: Malfunction in EMS software');
    $83 : Error('MapEmm: Invalid handle');
    $84 : Error('MapEmm: Undefined function');
    $8A : Error('MapEmm: Logical page not assigned to this handle');
    $8B : Error('MapEmm: Physical page number invalid');
  END;
END;

PROCEDURE DeallocateMem(Handle : Word);
BEGIN
  ASM
    MOV  AH, 45h
    MOV  DX, Handle
    INT  67h
  END;
END;

PROCEDURE GetPageSeg;
BEGIN
  ASM
    MOV  AH, 41h
    INT  67h
    MOV  EmmSeg, BX
    MOV  Err, AH;
  END;
  CASE Err OF
    $80 : Error('GetPageSeg: Internal error in EMS software');
    $81 : Error('GetPageSeg: Malfunction in EMS software');
    $84 : Error('GetPageSeg: Undefined function');
  END;
END;

PROCEDURE GetMaxPages(VAR Num : Word);
VAR
  Dummy : Word;
BEGIN
  ASM
    MOV  AH, 42h
    INT  67h
    MOV  Dummy, BX
    MOV  Err, AH;
  END;
  Num := Dummy;
  CASE Err OF
    $80 : Error('GetMaxPages: Internal error in EMS software');
    $81 : Error('GetMaxPages: Malfunction in EMS software');
    $84 : Error('GetMaxPages: Undefined function');
  END;
END;

PROCEDURE WriteMem(Page : Byte; Pos : Integer; Ch : Char);
BEGIN
  Mem[EmmSeg : Page * $4000 + Pos] := Ord(Ch);
END;

PROCEDURE ReadMem(Page : Byte; Pos : Integer; VAR Ch : Char);
BEGIN
  Ch := Chr(Mem[EmmSeg : Page * $4000 + Pos]);
END;

