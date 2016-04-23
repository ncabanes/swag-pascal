{
>A VGA's screen values can be found by defining something like:

>   VGAScreen : Array[1..64000] of Byte Absolute $A000:0000

>But, how do I find out exactly what color #200 is? It must be held in memory
>some place. Can anyone supply a Procedure, Function or some

I've written this short Program quite a While ago For some testing,
it should compile and work ok. Just note that it Uses slow BIOS
Function, it's not a good choice For fast palette animations but
otherwise works fine.
}

Program Palette256;
Uses Dos;

Type
  VGAColour = Record
    RByte, GByte, BByte : Byte;
  end;

  VGAPal = Array[0..$FF] of VGAColour;

Var
  Palette : VGAPal;
  i : Byte;

Procedure GetVGAPal(Var Pal : VGAPal);
Var
  CPUregs : Registers;
begin
with CPUregs do
  begin
  ax:=$1017;
  bx:=$00;
  cx:=$100;
  es:=Seg(Pal);
  dx:=Ofs(Pal);
  end;
  Intr($10,CPUregs);
end; {GetVGAPal}

Procedure SVMode(vmod : Byte);
Var
  CPUregs : Registers;
begin
CPUregs.ah:=0;
CPUregs.al:=vmod;
Intr($10,CPUregs);
end; {SVMode}

begin
SVMode($13);
GetVGAPal(Palette);
SVMode($02);
for i:=0 to $FF do
  Writeln('Entry ',i:3,' Red : ',Palette[i].RByte:3,' Green : ',
           Palette[i].GByte:3,' Blue : ',Palette[i].BByte:3);
end.
