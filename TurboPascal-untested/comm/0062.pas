{
> We can me tell, how i can read the name of the fossil-driver and version
> number of the fossil-driver ?
}
program
  whothere;

uses
  dos;

function fossilname(fport : byte) : string;
type
  fossilrec = record
    strsize : word;
    majrev  : byte;
    minver  : byte;
    idofs   : word;
    idseg   : word;
    ibuff   : word;
    ifree   : word;
    obuff   : word;
    ofree   : word;
    swidth  : byte;
    sheight : byte;
    dte     : byte;
  end;
var
  regs : registers;
  fosinfo : fossilrec;
  fosname : string[78];
  i : byte;
begin
  regs.ah := $04;
  regs.dx := fport;
  intr($14, regs);
  if regs.ax <> $1954 then begin
    writeln('Unable to detect FOSSIL driver');
    halt;
  end;
  regs.ah := $1b;
  regs.cx := sizeof(fosinfo);
  regs.dx := fport;
  regs.es := seg(fosinfo);
  regs.di := ofs(fosinfo);
  intr($14, regs);
  if fosinfo.majrev <> 5 then begin
    writeln('FOSSIL is not Rev5 compatible');
    halt;
  end;
  fosname := '';
  i := 0;
  repeat
    fosname := fosname+chr(mem[fosinfo.idseg:fosinfo.idofs+i]);
    inc(i);
  until(mem[fosinfo.idseg:fosinfo.idofs+i] = 0);
  fossilname := fosname;
end;

begin
  writeln('Fossil name COM4=', fossilname(3));
end.
