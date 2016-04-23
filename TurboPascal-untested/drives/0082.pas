
program valid_drv;

uses dos;

{ 
Function ready_drives reports as valid only drives that are 
ready to be read. Findfirst does not cause a critical error even 
if a floppy is not ready and in machines with a single floppy 
the prompt to insert a diskette when testing for the B: drive 
(from IO.SYS) is avoided by the use of DOS services $4408 and 
$440E (requires DOS 3.2 or up). - 
Jose Campione (1:163/513.3) August 1994 -
} 

function ready_drives: string;
var
  regs : registers;
  i : byte;
  drs: string;
  sr : searchrec;

  function is_last(d:byte):boolean;
  {true if d is the only or the last name assigned to that drive}
  begin
    regs.ax:= $440E;
    regs.bl:= d;
    msdos(regs);
    is_last:= ((regs.flags and fcarry) = 0) and ((regs.al = 0) or (regs.al = d));
  end;

  function is_floppy(d: byte): boolean;
  {true if d is a removable medium}
  begin
    regs.ax:= $4408;
    regs.bl:= d;
    msdos(regs);
    is_floppy := ((regs.flags and fcarry) = 0) and (regs.ax = 0);
  end;

begin
  drs:= '';
  for i:= 1 to 26 do begin
    if (not is_floppy(i)) or is_last(i) then begin
      findfirst(chr(i + 64) + ':\*.*',AnyFile,sr);
      if doserror = 0 then drs:= drs + chr(i + 64);
    end;
  end;
  ready_drives:= drs;
end;

begin
  writeln('drives ready : ',ready_drives);
end.

