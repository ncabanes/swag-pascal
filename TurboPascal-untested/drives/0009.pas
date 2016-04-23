{
> Does anyone know if there is a way For a Pascal Program to determine
> whether a drive is a local hard drive, a network drive, a Dos
> SUBSTituted drive, or a RAMDRIVE?

Hmm... I'm reading this one week after it got posted. and a month after the
original question. I haven't read last week's messages, hope you hadn't
recieved to many answers about this now. But because you apparently hadn't got
anything two weeks after asking, I thought you may want this, so here comes...

There is a service in Dos that identifies a given drive as local or remote.
This service also tells you if the drive is SUBSTed. You can also get info
about whether it Uses removable media from another service. There is no way to
detect a RAM-drive, as Far as I know, and I've got the facts from Microsoft's
own MSJ! The Dos 5 DosSHELL simple checks the volume identifier. if it's
'MS-RAMDRIVE', 'RDV' or 'VDISK', the drive is ASSUMED to be a RAM-disk. But
it's, again according to Microsoft Systems Journal, impossible to foolproof
check if a drive is a logical RAM-drive. A design flaw in Dos.

However, I will show a few lines of TP-code For checking if a drive is remote
or local, and SUBSTed or not. I use the TP 5.5 (and older) method of Intr-calls
For simulating Asm, of course if could be written clearer With TP6's
Asm-keyWord. The code consists of the actual Function and a test stub, cut the
stub when you have looked at it. Code Compiles and runs fine on my system; I
couldn't test if it work With remote drives, but it should. I've used similar
code that worked With that too, so...

}
Program TestDrv;

{ --- A very short test-Program For Dos-IOCTL, Jacob Stedman 930223 --- }

Uses
  Dos;

Function IsDriveValid(cDrive: Char; Var bLocal, bSUBST: Boolean): Boolean;
{
  Parameters: cDrive is the drive letter, 'A' to 'Z', that's about
  to be checked. if not in this range, the Function will return False.

  Returns: Function returns True if the given drive is valid, else
  False (!). bLocal is set if drive is local, bSUBST if drive is
  substituted. if Function returns False, the Booleans are undefined.
}
Var
  rCPU: Dos.Registers;
begin
  { --- Call Dos and process returns --- }
  if not (UpCase(cDrive) in ['A'..'Z']) then { --- letter OK?--- }
    IsDriveValid := False
  else
  begin
    { --- Valid letter, set up For the Dos-call --- }
    rCPU.bx := ord(UpCase(cDrive))-ord('A')+1;
    rCPU.ax := $4409;
    { --- Call the Dos IOCTL (InOutConTroL)-Functions --- }
    Intr($21, rCPU);
    if (rCPU.ax and FCarry) = FCarry then
      IsDriveValid := False
    else
    begin { --- drive is valid, check status --- }
      IsDriveValid := True;
      bLocal := ((rCPU.dx and $1000) = $0000);
      if bLocal then
        bSUBST := ((rCPU.dx and $8000) = $8000)
      else
        bSUBST := False;
    end;
  end;
end;

Var
  cCurChar : Char;          { loop counter, drive }
  bLocal,
  bSUBST   : Boolean;       { drive local/remote?; SUBSTed or not? }

begin
  { --- Write header --- }
  Writeln; Writeln('  VALID DRIVES:'); Writeln;
  { --- Loop from 'A' to 'Z', For each iteration check a drive --- }
  For cCurChar := 'A' to 'Z' do
    if IsDriveValid(cCurChar, bLocal, bSUBST) then
    begin
      Write(cCurChar, ': ');
      if bLocal then
        Write(' local ')
      else
        Write(' remote');
      if bSUBST then
        Write('   SUBSTed ')
      else
        Write('   not SUBSTed');
      Writeln;
    end;
  { --- Write footer --- }
  Writeln;
end.

{
The code is simple. It calls the Dos IOCTL-service #09h, 'Is Drive Remote',
with the drive number (1-A:, 2-B:, ...) in the bl-register. if the drive isn't
valid, the carry flag is set. if valid, carry is clear, and the dx-register
contains bit-fields you're interested in. Bit 12 is 1 if remote, 0 if local. if
local, bit 15 is 1 if the drive is a substitution. In TP, you get access to
them, in this Case, by using the 'and'-binary operator.

I guess you're interested in making a Filemanager or a report util or that
like. then, you're maybe interested to get source For detection of CD-ROM
drives and floppys? if so, post me a new msg. I always like to recieve new
mail... I didn't include this here, this msg is too long without that extra
code. Feel free to Write if you get any problems.
}