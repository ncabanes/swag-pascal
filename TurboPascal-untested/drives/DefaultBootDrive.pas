(*
  Category: SWAG Title: DISK DRIVE HANDLING ROUTINES
  Original name: 0072.PAS
  Description: Default Boot Drive
  Author: LEE ARONER
  Date: 05-25-94  08:27
*)

{$A+,B-,D+,E-,F-,G-,I+,L-,N-,O-,R-,S-,T-,V-,X+}
{$M 3072,0,0}

(*  A program to test some interesting behaviour of Int 21h,
    function 44h subfunction 08h.....the MicroSoft documentation I
    have seen indicates only that this returns an error if the flags
    register is set. however, it seems that it also identifies the
    default bootable logical drive, whether the machine was booted
    from a floppy, and discriminates between Ram drives and normal
    HDrives.....& more! Would appreciate your assistance in
    running this test and returning this information to me by mail.
    The results will be published in the FIDO Pascal echo.

    **************** WARNING  *****************
    Although this program has run completely safely on all machines
    tested by me, you should shut down or save all critical processes
    before running this test.

                    L.R.A.  5/6/94                          *)

Program TestDisk;

Uses   Dos;

Const
  TapeDrive    = $01;
  CdRom        = $02;
  Floppy       = $03;    (* Old 8 inch & ALL Floppies *)
  Floppy360    = $04;    (* Also 320K Floppy *)
  Floppy720    = $05;
  Floppy12     = $06;
  Floppy14     = $07;
  Floppy28     = $08;
  Floptical    = $09;
  Bernoulli    = $0a;
  RamDrive     = $0b;
  HardDrive    = $0c;
  BootHrdDrive = $0d;   (* Default HARD-Disk BootDrive !!! *)

  DriveTypes : array[0..13] of string[12] =
               ('ERROR !',      'TapeDrive',    'CdRom',
                'Floppy',       '360K Floppy',  '720K Floppy',
                '1.2M Floppy',  '1.44M Floppy', '2.88M Floppy',
                'Floptical',    'Bernoulli',    'RamDrive',
                'HardDrive',    'BootHrdDrive');

Var
  i           : byte;
  bits        : string[16];
  buff        : array [0..2047] of byte;
  drive       : char;
  Dtype       : byte;
  f           : text;
  y,m,d,dow   : word;
  lastdrive   : byte;
  regs        : registers;
  version     : word;

(*------------------------------------------------------*)
Function BinStr(num:word;bits:byte):string; assembler;
ASM
      PUSHF
      LES  DI, @Result
      XOR  CH, CH
      MOV  CL, bits
      MOV  ES:[DI], CL
      JCXZ @@3
      ADD  DI, CX
      MOV  BX, num
      STD
@@1:  MOV  AL, BL
      AND  AL, $01
      OR   AL, $30
      STOSB
      SHR  BX, 1
      LOOP @@1
@@3:  POPF
End;

(*------------------------------------------------------*)
Function DosVersion : word;
Begin
  with regs do
    begin
      ax := $3000;
      Intr($21,regs);
      DosVersion := (word(al)*100)+word(ah);
   end;
End;

(*---------------------------------------------------------*)
   (* Uses Undocumented function 52h to return actual logical
      lastdrive even under Novell and even if LastDrive is not
      used in Config.Sys. Must be DOS 3.1 or higher !!
      Return is 1 based ie: A=1, B=2, C=3, etc. !!!!

      Note: this will always return 5 if lastdrive is not
      specified in config.sys, even if less then 5 drives !                            *)

Function GetLastDrive(Var Drives:byte):boolean;
Begin
  With regs do
    begin
      ah := $52;       (* Return pointer to List of Lists *)
      es := 0;
      bx := 0;
      Intr($21,regs);
  (* This offset is ONLY valid for DOS 3.1 and above !! *)
      Drives := Mem[es:bx+$21];
      GetLastDrive := (Drives <> $FF)
              AND ((es <> 0) AND (bx <> 0));
    end;
End;

(*-----------------------------------------------------------*)
(* Switches to requested drive and then checks for error -
   Be sure to call this with Drive UpCased !! - Should work OK
   with networks ???????                                     *)

Function DriveValid(drive: char): boolean; assembler;
asm
    mov   ah, 19h     { Select DOS sub function 19h }
    int   21h         { Call DOS for current disk drive }
    mov   bl, al      { Save drive code in bl }
    mov   al, Drive   { Assign requested drive to al }
    sub   al, 'A'     { Adjust so A:=0, B:=1, etc. }
    mov   dl, al      { Save adjusted result in dl }
    mov   ah, 0eh     { Select DOS sub function 0eh }
    int   21h         { Call DOS to set default drive }
    mov   ah, 19h     { Select DOS sub function 19h }
    int   21h         { Get current drive again }
    mov   cx, 0       { Preset result to False }
    cmp   al, dl      { Check if drives match }
    jne   @@1         { Jump if not--drive not valid }
    mov   cx, 1       { Preset result to True }
@@1:
    mov   dl, bl      { Restore original default drive }
    mov   ah, 0eh     { Select DOS sub function 0eh }
    int   21h         { Call DOS to set default drive }
    xchg  ax, cx      { Return function result in ax }
End;
(*-----------------------------------------------------*)
   (* Be sure to call this with drive UpCased ! *)

Function IsCDRom(drive : char) : boolean;
Begin
   with regs do
     begin
       ax := $150b;
       bx := $0000;
       cx := word(ord(drive)-65);
       Intr($2f,regs);
    (* If MSCDEX is loaded, bx will be $adad ! *)
       IsCDRom := (ax <> 0) AND (bx = $adad);
    end;
End;

(*-----------------------------------------------------*)
   (* Returns false if drive is local - untested !!! *)

Function DriveIsRemote(drive : char):boolean;
Begin
  with regs do
    begin
      ah := $44;
      al := $09;
      bl := ord(drive)-64;
      Intr($21,regs);
      DriveIsRemote := ((dx AND $1000) <> 0) AND (fCarry = 0);
 (* Can further check if drive is substituted with
                  dx AND $8000 = $8000 if so *)
    end;
End;

(*------------------------------------------------------*)
       (* Be sure that Drive is UPCASED !
    Returns FALSE on Anything that is NOT a HardDisk,
    including RamDisks, CdRom, etc.                    *)

Function IsHardDisk(drive:char):boolean;
Begin
  with regs DO
    begin
      ah := $44;
      al := $08;
      bl := ord(drive)-64;
      Intr($21, regs);
      IsHardDisk := (flags AND fCarry <> fCarry)
           AND (NOT (ax in [$0,$0f]));
     (* ax = $0 for removable, $0f on invalid drive spec ! *)
    end;
End;

(*------------------------------------------------------------------*)
   (* CAUTION !!!!! THIS FUNCTION IS EXPERIMENTAL !!!!!!!!!  *)

 (* Be sure that drive is UPCASED ! - This function goes to DOS
    internal structures to get params for floppy type drives.
    (Including Bernoulli). Because it tells DOS to rebuild the
    BPB (Bios Parameter Block) for drives with removable media,
    the Media Descriptor byte will always return the boot
    paramaters for the drive, ie: a 1.44M floppy will always
    return 1.44M, regardless of the size disk that is currently
    actually in the drive !!

    A return of BootHrdDrive indicates ONLY that this is the
    HardDrive with the DOS boot partition on it. It DOES NOT
    indicate that the machine was booted from that drive !!!

    Dos version is MINIMUM of 3.1 !! - Check FIRST !!

    Because it does NOT read the drive, this puppy is FAST !!

    Returns these Constant types :
                    ERROR !       = $00;
                    TapeDrive     = $01
                    CdRom         = $02;
Check against this- Floppy        = $03; -to get All floppys !!
                    Floppy360     = $04;
                    Floppy720     = $05;
                    Floppy12      = $06;
                    Floppy14      = $07;
                    Floppy28      = $08;
                    Floptical     = $09;
                    Bernoulli     = $0a;
                          RamDrive      = $0b;
                    HardDrive     = $0c;
                    BootHrdDrive  = $0d;     *)

Function DriveType(Var f:text;drive:char):byte;
Type
   PtrDpbPtr = ^DpbPtr;
   DpbPtr    = ^DPB;

   DPB  =  record           (* Drive Parameter Block *)
     DN   : byte;      (* 0=A etc Can compare this for Subst drive *)
     DDU  : byte;      (* Device Driver Unit Number *)
     BPS  : word;      (* Bytes Per Sector *)
     SPC  : byte;      (* Sectors Per Cluster *)
     CSC  : byte;      (* Cluster Shift Count *)
     BS   : word;      (* Boot Sectors *)
     Fats : byte;      (* Number of fats *)
     RDE  : word;      (* Max Root Dir entries *)
     FDS  : word;      (* First Data Sector *)
     HPC  : word;      (* Highest Possible Cluster # *)
    (* Case Variant *)
     Case byte of
        (* DOS < 4.0 OR OS2 *)
       0 : (SpfOld   : byte;   (* Sectors per fat *)
            JunkOld  : array[16..22] of byte;
            MdaOld   : byte;   (* Media Descriptor byte *)
            DummyOld : byte;
            NextOld  : DpbPtr); (* Pointer to next record *)
       (* DOS >= 4.0 *)
       1 :(SpfNew    : word;
           JunkNew   : array[17..23] of byte;
           MdaNew    : byte;
           DummyNew  : byte;
           NextNew   : DpbPtr);
       end;
Var
  dnum,i,
  num     : byte;
  CurrDpB : DpbPtr;
  MDA     : byte;
  SPF     : word;
  params  : array[0..31] of byte;
  UseNew  : boolean;

Begin
  DriveType := 0;              (* Assume failure *)
  dnum := ord(drive)-64;       (* 'A'=1, 'B'=2 etc. *)
  with regs do
    begin
      ah := $44;
      al := $08;
      bl := dnum;
      Intr($21, regs);
      if ax = $0f then exit;   (* Invalid drive ! *)
 (* Here's where we try the undocumented return params ! *)
      num := (ax+(flags AND fCarry)+(flags AND fParity));

   {  if (ax = 0) then        - Diversion for test purposes !
        begin  }
          (* OS2 will return > 10 *)
          UseNew := Lo(DosVersion) in [4..9];

    (* Get Ptr to List of Lists *)
          ah := $52;
          es := 0;
          bx := 0;
          Intr($21,regs);
          if (es = 0) OR (bx = 0) then exit;  (* Error ! *)

       (* Pointer to list - 0h is pointer to 1st DPB *)
          CurrDpb := PtrDpbPtr(Ptr(es,bx))^;
    (* Walk the chain of DPB's to our drive: 0='A' etc. *)
 (* Possible that drive is SUBSTed, so index from dnum instead of DN ! *)
    (* Don't index on 'A', cause it's already there ! *)
          for i := 2 to dnum do
            begin
       (* Offset set to $ffff on last in chain *)
              if (ofs(CurrDpb^) <> $ffff) then
                begin
                  if UseNew then CurrDpb := CurrDpb^.NextNew
                  else CurrDpb := CurrDpb^.NextOld;
                end
     (* Hit end of chain before got to our drive ! *)
              else exit;
            end;   (* Of for *)

          Case UseNew of
         (* >= DOS 4.0 and NOT OS2 *)
            true  : begin
                      MDA := CurrDpb^.MdaNew;
                      SPF := CurrDpb^.SpfNew;
                    end;
          (* < DOS 4 or OS2 *)
            false : begin
                      MDA := CurrDpb^.MdaOld;
                      SPF := CurrDpb^.SpfOld;
                    end;
            end;   (* Of case *)

       (* Write out buncha stuff for analysis *)
          writeln(f,'DN   is : ',CurrDpb^.DN);
          writeln(f,'DDU  is : ',CurrDpb^.DDU);
          writeln(f,'BPS  is : ',CurrDpb^.BPS);
          writeln(f,'SPC  is : ',CurrDpb^.SPC);
          writeln(f,'CSC  is : ',CurrDpb^.CSC);
          writeln(f,'BS   is : ',CurrDpb^.BS);
          writeln(f,'FATS is : ',CurrDpb^.Fats);
          writeln(f,'RDE  is : ',CurrDpb^.RDE);
          writeln(f,'FDS  is : ',CurrDpb^.FDS);
          writeln(f,'HPC  is : ',CurrDpb^.HPC);
          writeln(f,'SPF  is : ',SPF);
          writeln(f,'MDA  is : ',MDA);

    (* This work on last of multiple Benoulli drives ???? *)
          if (SPF > 2) AND (MDA >= $fc) then
                  DriveType := Bernoulli
          else
          if num = 0 then
            begin
    (* Tell DOS to build new BPB for removable types *)
              fillchar(params,sizeof(params),0);
              params[0] := 4;   (* Do NOT go to drive ! *)
              ax := $440d;
              cx := $0860;
              bl := dnum;
              dx := ofs(params);
              ds := seg(params);
              Intr($21, regs);
              Case params[1] of
                0  : DriveType := Floppy360;
                1  : DriveType := Floppy12;
                2  : DriveType := Floppy720;
               3,4 : DriveType := Floppy;
                6  : DriveType := TapeDrive;
                7  : DriveType := Floppy14;
                8  : DriveType := Floptical;
                9  : DriveType := Floppy28;
                end;
                  begin
                    writeln(f,'Params[1] is : ',byte(params[1]));
                    writeln(f,'BPS  is : ',word(params[7]));
                    writeln(f,'SPC  is : ',byte(params[9]));
                    writeln(f,'Fats is : ',byte(params[12]));
                    writeln(f,'RDE  is : ',word(params[13]));
                    writeln(f,'SPF  is : ',word(params[18]));
                    writeln(f,'MDA  is : ',byte(params[17]));
                  end;
            end     (* Of Not Bernoulli *)
      { end}
      else    (* ax > 0 ! *)
        begin
          Case num of
            1 : DriveType := HardDrive;
            5 : DriveType := BootHrdDrive;
            6 : begin
                  if IsCdRom(drive) then
                     DriveType := CDRom
                   else DriveType := RamDrive;
                end;
            else DriveType := 0;            (* Error ! *)
            end;  (* Of case *)
        end;  (* Not a floppy or bernoulli *)
    end;   (* With regs *)
End;




Begin      (* TestDisk *)
  GetDate(y,m,d,dow);
  {$I-}
  assign(f,'TESTDISK.RPT');
  rewrite(f);
  if IoResult <> 0 then
    begin
      write(^G);
      writeln('Can''t open report file: aborting !');
      exit;
    end;
  SetTextBuf(f,buff);
  writeln(f);
  writeln(f,'DOS Drive Detection Survey Report');
  writeln(f);
  writeln(f,'Please mail to: CDC Micro');
  writeln(f,'                PO Box 4457');
  writeln(f,'                Seattle WA 98104');
  writeln(f,'                (206) 435-1125');
  writeln(f);
  writeln(f,'Thanks for taking the time to help with this survey !');
  writeln(f);
  writeln(f,'Report dated : ',m:0,'/',d:0,'/',y:0);
  writeln(f);
  writeln(f,'Report submitted by : _________________________________________________________');
  writeln(f,'My address & phone # is : _____________________________________________________');
  writeln(f,'_______________________________________________________________________________');
  writeln(f,'Test equipment is : ___________________________________________________________');
  writeln(f,'_______________________________________________________________________________');
  writeln(f,'For this test, my machine was booted from the: _______ drive.');
  writeln(f,'For this test, I was running a RamDisk on Drive: ______,using _________________');
  writeln(f,'For this test, I had a Bernoulli drive connected as Drive: ________ (Yes/No?)');
  writeln(f,'For this test, I had a Tape/Optical drive connected as Drive: _______ (Yes/No?)');
  writeln(f,'For this test, I was running Stacker/DoubleSpace/Other compressor. (Yes/No ?)');
  writeln(f,'Test Conducted under : __________________________ operating/system/environment');
  writeln(f,'Comments ? ____________________________________________________________________');
  writeln(f);
  version := DosVersion;
  writeln(f,'DOS Version: ',version);
  if (version < 310) OR (NOT GetLastDrive(lastdrive)) then
  writeln(f,'Dos Version too low or lastdrive detection FAILED !!')
  else begin
  writeln(f,'LastDrive is: ',lastdrive:0);
  writeln(f);
  for i := 1 to lastdrive do with regs do
    begin
      drive := char(i+64);
       if DriveValid(drive) then
         begin
          IsHardDisk(drive);
          Dtype := ax+(flags AND fCarry)+(flags AND fParity);
          bits := BinStr(flags,16);
          writeln(f,'Drive '+Drive+':          Value of AX is: ',ax);
          writeln('Drive '+Drive+':          Value of AX is: ',ax);
          writeln(f,'Drive '+Drive+':       Value of flags is: ',flags);
          writeln('Drive '+Drive+':       Value of flags is: ',flags);
          writeln(f,'Drive '+Drive+':          Flags bits are: '+bits);
          writeln('Drive '+Drive+':          Flags bits are: '+bits);
          writeln(f,'Drive '+Drive+':      AX+carry+parity is: ',ax+(flags AND fCarry)+(flags AND fParity));
          writeln('Drive '+Drive+':      AX+carry+parity is: ',Dtype);

          writeln(f,'Drive '+Drive+':     flags AND fCarry is: ',flags AND fCarry,' ',flags AND fCarry = fCarry);
          writeln('Drive '+Drive+':     flags AND fCarry is: ',flags AND fCarry,' ',flags AND fCarry = fCarry);
          writeln(f,'Drive '+Drive+':    flags AND fParity is: ',flags AND fParity,' ',flags AND fParity = fParity);
          writeln('Drive '+Drive+':    flags AND fParity is: ',flags AND fParity,' ',flags AND fParity = fParity);
          writeln(f,'Drive '+Drive+': flags AND fAuxiliary is: ',flags AND fAuxiliary,' ',flags AND fAuxiliary = fAuxiliary);
          writeln('Drive '+Drive+': flags AND fAuxiliary is: ',flags AND fAuxiliary,' ',flags AND fAuxiliary = fAuxiliary);
          writeln(f,'Drive '+Drive+':      flags AND fZero is: ',flags AND fZero,' ',flags AND fZero = fZero);
          writeln('Drive '+Drive+':      flags AND fZero is: ',flags AND fZero,' ',flags AND fZero = fZero);
          writeln(f,'Drive '+Drive+':      flags AND fSign is: ',flags AND fSign,' ',flags AND fSign = fSign);
          writeln('Drive '+Drive+':      flags AND fSign is: ',flags AND fSign,' ',flags AND fSign = fSign);
          writeln(f,'Drive '+Drive+':  flags AND fOverFlow is: ',flags AND fOverflow,' ',flags AND fOverFlow = fOverFlow);
          writeln('Drive '+Drive+':  flags AND fOverFlow is: ',flags AND fOverflow,' ',flags AND fOverFlow = fOverFlow);

          if (Dtype > 0) then if DriveIsRemote(Drive)
                then writeln(f,'  ***** This drive is remote (network) or Substituted ?  Yes/No/Which  *****');

          writeln(f,'       *****  This is a '+DriveTypes[DriveType(f,Drive)]+' ?  Yes/No  *****');
          writeln(f);
          writeln;
        end;    (* Drive is valid *)
    end;     (* For loop *)
  end;   (* Lastdrive detection *)
  writeln(f,'End of Report... and Thanks for running this test !');
  close(f); {$I+}
  if IoResult <> 0 then;

  writeln('Please print out and mail in the TESTDISK.RPT file.');
  writeln('You''ll find it in this sub-directory.');
  writeln('Thanks for running this test !');
End.
