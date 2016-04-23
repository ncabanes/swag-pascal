
{you've seen it before, but not this fast... :-) }
(********************************************************************
 Originally idea  : Nick Batalas, ( dated    14-6-1994 )
 Sourced from                   : Eric Coolman, ( modified 19-6-1994 )
 Rewritten by                   : Wil Barath,              03-9-1994
 new : assembly optimisation, random weaving, memory reduction, etc.
 ********************************************************************)
Program SnowFall;
const
  Flakes = 3000;     { higher = more flakes }
  Fastest= 240;      { try smaller numbers for slower flakes}
  Explosion = False; { False for no explosion }
Var r:Word;
{---------------- Stuff not specific to snowfall ----------------}
Procedure vidMode(mode : byte);assembler;
  asm mov ah,$00;  mov al,mode; int 10h; end;
Function ReadKey:Char;Assembler;
asm Mov ax,0000h; int 16h; end;
Function Keypressed:Boolean;Assembler;
asm Mov ax,0100h; int 16h; JNZ @1; Xor ax,ax; Ret;
@1: Inc ax; end;
Procedure Perturb;assembler;  {Peturbation algorhythm (C) 1982 BarathSoft}
asm Mov dx,r; Xor dx,0aa55h; SHL dx,1; Adc dx,$118; Mov r,dx; end;
{---------------------------MAIN PROGRAM-------------------------}
Type FlakeyRec = Record x,y:Byte;p:Word; end;
var  CurFlake,s,pf:Word;
                 Flake:Array[0..flakes] of flakeyrec;
Procedure Pascal_Version;
Begin
  repeat
    for CurFlake:= 1 to flakes do with flake[curflake] do
    begin
      Perturb; Mem[$a000:p]:=0;
      If x>=lo(r) then Inc(p);
      If y>=Hi(r) then Inc(p,320);
      Mem[$a000:p]:=y SHR 5 + $18;
    end;
    Repeat Until (port[$3da] and $08) = $08;  {wait for vRetrace }
  until keypressed;
end;
Procedure Assembly_version;
Begin
  repeat              { * NOTE * the above pascal version was derived }
       ASM            { from the assembly below, and is Very optimal. }
          Mov dx,r
          Mov cx,flakes             {for CurFlake:= 1 to flakes do}
          Mov pf,Offset flake;      {with flake[curflake] do}
          Mov ax,0a000h
          Mov es,ax                 {begin}
          Mov bx,$118
@0:       Xor dx,0aa55h             {Perturb }
          SHL dx,1
          Adc dx,bx
          Mov si,pf
          Mov di,[si.FlakeyRec.p]
          Xor al,al
          Mov es:[di],al            {Mem[$a000:p]:=0;}
          Cmp dl,[si.FlakeyRec.x]   {If x>=Lo(r) then Inc(p);}
          Jnc @1
          Inc di
@1:       Mov ah,[si.FlakeyRec.y]
          Cmp dh,ah                 {If y>=Hi(r) then Inc(p,320);}
          Jnc @2
          Add di,320
@2:       Mov Word Ptr [si.FlakeyRec.p],di
          Shr ah,5                  {Mem[$a000:p]:=y SHR 5 + $18;}
          add ah,bl
          Mov es:[di],ah
          Add pf,Type flakeyRec
          Loop @0
          Mov r,dx
        end;                        {end;}
    Repeat Until (port[$3da] and $08) = $08;  { wait for vRetrace }
  until keypressed;
End;
Begin
  for CurFlake:=0 to Flakes do With Flake[curflake] do
  begin                              { set up snow lookup table }
    Perturb; Inc(s,r);
    y:=Hi(Hi(r)*fastest)+5;
    x:=Hi(Lo(r)*y)+1;                {limit x movement}
    If explosion = False then p:=s;
  end;
  vidMode($13);                      { 320x200x256 graphics mode }
  Repeat
    Pascal_version;
    If ReadKey=#27 then Break;
    Assembly_version;
  Until ReadKey=#27;
  vidMode($03);                      { return to 80x25 textmode }
end.
