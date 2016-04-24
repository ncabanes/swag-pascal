(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0014.PAS
  Description: VOCPLAY.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
> Does anybody know where to get some good source that plays Vocs?
}

{$A+,B-,D+,E-,F+,G-,I-,L-,N-,O+,R-,S-,V-,X-}
{$M   1024,0,0 }
Unit  VOCPlay;

Interface

Uses
  Dos;

Var
  VoiceStatusWord           : Word;
  VocPaused,VOCDrvInstalled : Boolean;

Procedure AllocateMem(Var P : Pointer;Size : LongInt);
Function  AllocateMemFunc(Var P : Pointer;Size : LongInt) : Boolean;
Function  ReAllocateMem(Var P : Pointer;NewSize : LongInt) : Boolean;
Procedure DisAllocateMem(Var P : Pointer);

Procedure VocOutPut(AdrtoPlay : Pointer);
Procedure VocStop;
Procedure VocPause;
Procedure VocContinue;
Procedure VocSetSpeaker(Onoff : Boolean);
Function  VocInitDriver : Byte;
Function  LoadVoctoMem(DateiName : String;Var VocMem : Pointer) : Boolean;

Implementation
Const
  VocDriverHeader         = 12;
  VocFileHeaderLen        = $1A;
Var
  PtrtoDriver,OldExitProc : Pointer;
  Regs                    : Registers;
  SizeIntern              : Word;

Procedure AllocateMem;
begin
  Inc(Size,15);
  SizeIntern := (Size SHR 4);
  Regs.AH    := $48;
  Regs.BX    := SizeIntern;
  MsDos(Regs);
  if Regs.Flags and FCarry <> 0 then
    P := NIL
  else
    P := Ptr(Regs.AX,0);
end;

Function AllocateMemFunc;
begin
  AllocateMem(P,Size);
  AllocateMemFunc := P <> NIL;
end;

Function ReAllocateMem;
begin
  Inc(NewSize,15);
  SizeIntern    := (NewSize SHR 4);
  Regs.AH       := $4A;
  Regs.BX       := SizeIntern;
  Regs.ES       := Seg(P^);
  MsDos(Regs);
  ReAllocateMem := (Regs.BX=SizeIntern);
end;

Procedure DisAllocateMem;
begin
  Regs.AH := $49;
  Regs.ES := Seg(P^);
  MsDos(Regs);
end;

Function Exists(FileName : String) : Boolean;
Var
  S : SearchRec;
begin
  FindFirst(FileName,AnyFile,S);
  Exists := (DosError=0);
end;

Function VocInitDriver;
Const
  DriverName = 'CT-VOICE.DRV';
Type
  DriverType = Array [0..VocDriverHeader] of Char;
Var
  Out,S,O    : Word;
  F          : File;
begin
  Out := 0;
  if not Exists(DriverName) then
 begin
   VocInitDriver := 4;
   Exit;
 end;
  Assign(F,DriverName);
  Reset(F,1);
  if not AllocateMemFunc(PtrtoDriver,FileSize(F)) then Out := 5;
  if Out=0 then BlockRead(F,PtrtoDriver^,FileSize(F));
  Close(F);
  if Out<>0 then
 begin
   VocInitDriver := Out;
   Exit;
 end;
  if (DriverType(PtrtoDriver^)[3]<>'C') or
     (DriverType(PtrtoDriver^)[4]<>'T') then
 begin
   VocInitDriver := 4;
   Exit;
 end;
  S := Seg(VoiceStatusWord);
  O := ofs(VoiceStatusWord);
  Asm
    mov   bx,3
    call  PtrtoDriver
    mov   Out,ax
    mov   bx,5
    mov   es,S
    mov   di,O
    call  PtrtoDriver
  end;
  VocInitDriver := Out;
end;

Procedure VocUninstallDriver;
begin
  if VocDrvInstalled then
  Asm
    mov   bx,9
    call  PtrtoDriver
  end;
end;

Procedure VocOutPut;
Var
  S,O : Word;
begin
  VocSetSpeaker(True);
  S := Seg(AdrtoPlay^);
  O := ofs(AdrtoPlay^)+VocFileHeaderLen;
  Asm
    mov   bx,6
    mov   es,S
    mov   di,O
    call  PtrtoDriver
  end;
end;

Procedure VocStop;
begin
  Asm
    mov   bx,8
    call  PtrtoDriver
  end;
end;

Procedure VocPause;
begin
  Asm
    mov   bx,10
    call  PtrtoDriver
  end;
end;

Procedure VocContinue;
begin
  Asm
    mov   bx,11
    call  PtrtoDriver
  end;
end;

Procedure VocSetSpeaker;
Var B : Byte;
begin
  B := ord(Onoff) and $01;
  Asm
    mov   bx,4
    mov   al,B
    call  PtrtoDriver
  end;
end;

Function LoadVoctoMem;
Var F            : File;
    Out          : Boolean;
    Gelesen,Segs : Word;
begin
  Out := Exists(DateiName);
  if Out then
 begin
   Assign(F,DateiName);Reset(F,1);
   if not AllocateMemFunc(VocMem,FileSize(F)) then
  begin
    Close(F);
    LoadVoctoMem := False;
    Exit;
  end;
   Segs := 0;
   Repeat
     BlockRead(F,Ptr(Seg(VocMem^)+4096*Segs,ofs(VocMem^))^,$FFFF,Gelesen);
     Inc(Segs);
   Until Gelesen=0;
   Close(F);
 end;
  LoadVoctoMem := Out;
end;

{$F+}
Procedure VocPlayExitProc;
begin
  VocUninstallDriver;
  ExitProc := OldExitProc;
end;
{$F-}

begin
  OldExitProc     := ExitProc;
  ExitProc        := @VocPlayExitProc;
  VoiceStatusWord := 0;
  VocPaused       := False;
  VocDrvInstalled := (VocInitDriver=0);
end.


{$A+,B-,D+,E-,F-,G-,I-,L-,N-,O-,R-,S-,V-,X-}
{$M   1024,0,0 }
Uses  Crt,VOCPlay;
Var   VocMem   : Pointer;
      FileName : String;
      Ok       : Boolean;
begin
  FileName := ParamStr(1);
  Ok       := False;
  if VocDrvInstalled then Ok := LoadVoctoMem(DateiName,VocMem);
  if Ok then
 begin
   Write('Playing VOC-File ...');
   VocOutPut(VocMem);
   Repeat
   Until (VoiceStatusWord=0) or KeyPressed;
   Writeln;
   DisAllocateMem(VocMem);
 end
 else Writeln('Hey, there was something wrong.');
end.

