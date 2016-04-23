{To make all cursor routines complete, here are the ones I use: }

procedure setcursorshape(shape : word); assembler; asm
  mov ah,1; mov cx,shape; int 10h; end;

procedure linecursor;
begin
  case Rows of
    25 : case VidCard of
           cga,ega : setcursorshape(256*6+7);
           mda : setcursorshape(256*$b+$c);
           vga : setcursorshape(256*$d+$e);
         else setcursorshape(256*6+7);
         end;
    40 : setcursorshape(256*8+9);
  else setcursorshape(256*6+7);
  end;
end;

procedure halfcursor;
begin
  case Rows of
    25 : case VidCard of
           cga,ega : setcursorshape(256*3+7);
           mda : setcursorshape(256*6+$c);
           vga : setcursorshape(256*7+$e);
         else setcursorshape(256*3+7);
         end;
    40 : setcursorshape(256*4+9);
  else setcursorshape(256*3+7);
  end;
end;

procedure blockcursor; begin
  setcursorshape($10); end;

procedure cursoron; assembler; asm
  mov ah,3; mov bh,0; int 10h; and ch,not 20h; mov ah,1; int 10h; end;

procedure cursoroff; assembler; asm
  mov ah,3; mov bh,0; int 10h; or ch,20h; mov ah,1; int 10h; end;

function getcursorshape : word; assembler; asm
  mov ah,3; mov bh,0; int 10h; mov ax,cx; end;

>--- cut here 

The carddetectionroutines are as follows:

>--- cut here 

const
  mda = 0;                                                     { MDA and HGC }
  cga = 1;
  ega = 2;
  ega_mono = 3;                                        { EGA and MDA-Monitor }
  vga = 4;
  vga_mono = 5;                                           { VGA and VGA-Mono }
  mcga = 6;
  mcga_mono = 7;                                        { MCGA and MCGA-Mono }

var
  VidCard : byte;                                { Code for active videocard }

procedure VideoInit;

const
  VidMode : array[0..11] of byte = (mda,cga,0,ega,ega_mono,0,vga_mono,
                                    vga,0,mcga,mcga_mono,mcga);
  EgaMode : array[0..2] of byte = (ega,ega,ega_mono);

var
  Regs : registers;                           { Processorregisters for int's }

begin
  VidCard := $ff;                                { No videocard detected yet }

  { --- Check card-type ---------------------------------------------------- }

  Regs.ax := $1a00;                                 { Call BIOS function 1Ah }
  intr($10,Regs);
  if Regs.al = $1a then begin                           { VGA of MCGA? - Yes }
    VidCard := VidMode[Regs.bl-1];                      { Get cod from table }
    Color := not ((VidCard = mda) or (VidCard = ega_mono));
  end
  else begin                               { No VGA or MCGA, search EGA-card }
    Regs.ah := $12;                           { Function 12h subfunction 10h }
    Regs.bl := $10;
    intr($10,Regs);                                        { Call Video-BIOS }
    if Regs.bl <> $10 then begin                                { EGA? - Yes }
      VidCard := EgaMode[(Regs.cl shr 1) div 3];                  { Get Code }
      Color := VidCard <> ega_mono;
    end;
  end;

  { --- Define pointer to video-RAM ---------------------------------------- }

  Regs.ah := 15;                                  { Define actual video-mode }
  intr($10,Regs);                                { Call BIOS video-interrupt }
  if Regs.al = 7 then v_vidseg := $b000                   { Monochrome mode? }
  else v_vidseg := $b800;                                    { No, Colormode }

  if VidCard = $ff then begin                   { No EGA, VGA or MCGA? - Yes }
    if Regs.al = 7 then VidCard := mda else VidCard := cga;
    Color := not ((Regs.al = 0) or (Regs.al = 2) or (Regs.al = 7));
    SnowProtect := true;
  end;

  Regs.ah := 5;                                   { Chose actual screen page }
  Regs.al := 0;                                                  { Page zero }
  intr($10,Regs);                                { Call BIOS video-interrupt }
end;

>--- cut here 

This might not compile straight off, but I guess you can imagine what's
possibly missing. ;-) (like 'uses dos')

If everything works, you can easily define your cursor with statements as:

linecursor,
blockcursor,
cursoroff,
cursoron,
etc...

Should work on every possible videocard.
