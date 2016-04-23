{
Here is how to trap errors on the 80X87.  I am not sure yet how it works with
the FP emulation library, but if you have a math coprocessor, you can trap
any FP exceptions:
}

{$N+,E+}
program FloatTest;
{ compliments of Steve Schafer, Compuserve address 76711, 522 }
const
  feInvalidOp  = $01;
  feDenormalOp = $02;
  feZeroDivide = $04;
  feOverFlow   = $08;
  feUnderFlow  = $10;
  fePrecision  = $20;

procedure SetFpuExceptionMask (MaskBits: Byte); assembler;
{ Masks floating point exceptions so that they won't cause a crash }
var
  Temp: word;
asm
  fstcw Temp
  fwait
  mov ax, Temp
  and al, $F0
  or al, MaskBits
  mov Temp, ax
  fldcw Temp
  fwait
end;

function GetFpuStatus: Byte; assembler;
{ determines the status of a previous FP operation }
var
  Temp: word;
asm
  fstsw Temp
  fwait
  mov ax, Temp
end;

procedure WriteStatus(Status: Byte);
{ This procedure is not necessary, it simply illustrates how to determine
  what happenend }
begin
  if (Status and fePrecision) <> 0 then Write('P')
  else Write('-');
  if (Status and feUnderflow) <> 0 then Write('U')
  else Write('-');
  if (Status and feOverflow) <> 0 then Write('O')
  else Write('-');
  if (Status and feZeroDivide) <> 0 then Write('Z')
  else Write('-');
  if (Status and feDenormalOp) <> 0 then Write('D')
  else Write('-');
  if (Status and feInvalidOp) <> 0 then Write('I')
  else Write('-');
end;

var
  X,Y: Single;

begin
  SetFPUExceptionMask (feInvalidOp + feDenormalOp + feZeroDivide
                     + feOverflow  + feUnderflow  + fePrecision);

  X:= -1.0;
  Y:= Sqrt(X);  { Invalid Operation }
  WriteStatus(GetFPUStatus);  
  Writeln('  ', Y:12, '  ', X:12);

  X:= 0.0;
  Y:= 1.0;
  Y:= Y/X;  { divide by Zero }
  WriteStatus(GetFPUStatus);
  Writeln('  ', Y:12, '  ', X:12);

  X:= 1.0E-34;
  Y:= 1.0E-34;
  Y:= Y*X;  { Underflow }
  WriteStatus(GetFPUStatus);
  Writeln('  ', Y:12, '  ', X:12);

end.
