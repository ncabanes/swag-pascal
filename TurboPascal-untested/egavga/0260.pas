{Tested under BP7.01 in Win'95, protected mode target: }

program VesaInfo;
uses DPMI,WinAPI,WinDOS;

procedure GetVESAInfo;
type
  PVESAInfo = ^TVESAInfo;
  TVESAInfo = array [0..511] of byte;
var
  i:         byte;
  SegAndSel: longint;
  VESAInfo:  PVESAInfo;
  Regs:      TRealModeRegs;

begin
  SegAndSel:=GlobalDOSAlloc(SizeOf(TVESAInfo));
  if SegAndSel=0 then writeln('Can''t allocate DOS memory for VESA Info.')
  else begin
    VESAInfo:=Ptr(LoWord(SegAndSel),0);
    FillChar(Regs,SizeOf(Regs),#0);
    Regs.AX:=$4F00;
    Regs.ES:=HiWord(SegAndSel);
    { Regs.DI:=0; - done already by FillChar }
    RealModeInt($10,Regs);
    if Regs.AX=$4F then begin
      for i:=0 to 3 do write(Char(VesaInfo^[i]));
      write(' v.',VesaInfo^[5]:1,'.');
      if VesaInfo^[4]<10 then write('0');
      writeln(VesaInfo^[4]:1);
      { process VESAInfo here }
    end else begin
      write('Can''t load VESA information: ');
      if Regs.AL<>$4F then writeln('VESA BIOS not loaded.')
      else case Regs.AH of
        1: writeln('VESA BIOS call failed.');
        2: writeln('function not supported by hardware configuration.');
        3: writeln('function invalid in current video mode.');
        else writeln('unknown VESA BIOS error.');
      end;
    end;
    GlobalDOSFree(LoWord(SegAndSel));
  end;
end;

begin
  GetVESAInfo;
end.
