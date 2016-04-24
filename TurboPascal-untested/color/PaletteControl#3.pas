(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0014.PAS
  Description: Palette Control #3
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

Unit Palette;

Interface

Type
  PalType     =  Array [0..768] of Byte;
Var
  FadePal     :  Array [0..768] of Real;
  Fadeend,
  FadeStep,
  FadeCount,
  FadeStart   :  Byte;
  FadeToPal   :  ^PalType;
  DoneFade    :  Boolean;

Procedure GetPCXPalettePas (PCXBuf,P:Pointer;PalOffset:Word);
Procedure GetPCXPaletteAsm (PCXBuf,P:Pointer;PalOffset:Word);

Procedure WritePalettePas  (Start,Finish:Byte;P:Pointer);
Procedure WritePaletteAsm  (Start,Finish:Byte;P:Pointer);

Procedure ReadPalettePas   (Start,Finish:Byte;P:Pointer);
Procedure ReadPaletteAsm   (Start,Finish:Byte;P:Pointer);

Procedure SetupFade        (Start,Finish:Byte;P:Pointer;Step:Byte);
Procedure FadePalette;
Procedure Oreo             (Start,Finish:Integer);

Implementation

Procedure CLI; Inline ($FA);
Procedure STI; Inline ($FB);

Procedure SetupFade (Start,Finish:Byte;P:Pointer;Step:Byte);
Var
  CurPal           :  Array [0..767] of Byte;
  ToPal            :  ^PalType;
  I,PalOfs,
  NumColors        :  Word;
  RealStep,
  RealToColor,
  RealCurColor     :  Real;
begin
  ToPal := Ptr (Seg(P^),Ofs(P^));
  ReadPaletteAsm (0,255,@CurPal);
  PalOfs := Start * 3;
  NumColors := (Finish - Start + 1) * 3;

  RealStep := Step;

  For I := 0 to NumColors-1 do begin
    RealCurColor := CurPal [PalOfs+I];
    RealToColor  :=  ToPal^[PalOfs+I];
    FadePal [PalOfs+I] := (RealCurColor - RealToColor) / RealStep;
    end;

  FadeStep  := 0;
  FadeCount := Step;
  FadeStart := Start;
  Fadeend   := Finish;
  FadeToPal := P;
  DoneFade  := False;
end;

Procedure FadePalette;
Var
  I,
  PalOfs,
  NumColors   :  Word;
  CurPal      :  Array [0..767] of Byte;
  Fact,
  RealToColor :  Real;
begin
  Inc (FadeStep);
  Fact := FadeCount - FadeStep;
  NumColors := (Fadeend - FadeStart + 1) * 3;
  ReadPaletteAsm (0,255,@CurPal);
  PalOfs := FadeStart * 3;

  For I := 0 to NumColors - 1 do begin
    RealToColor := FadeToPal^[PalOfs+I];
    CurPal[PalOfs+I] := Round (RealToColor + Fact * FadePal[PalOfs+I]);
    end;

  WritePaletteAsm (FadeStart,Fadeend,@CurPal);
  DoneFade := FadeStep = FadeCount;
end;

Procedure Oreo (Start,Finish:Integer);
Var
  I,PalOfs    :  Word;
  CurPal      :  Array [0..767] of Byte;
  Red,
  Blue,
  Green       :  Real;
  Gray        :  Byte;
begin
  ReadPaletteAsm (0,255,@CurPal);

  For I := Start to Finish do begin
    PalOfs := I * 3;
    Red   := CurPal[PalOfs + 0];
    Green := CurPal[PalOfs + 1];
    Blue  := CurPal[PalOfs + 2];

    Gray := Round ((0.30 * Red) + (0.59 * Green) + (0.11 * Blue));

    CurPal[PalOfs + 0] := Gray;
    CurPal[PalOfs + 1] := Gray;
    CurPal[PalOfs + 2] := Gray;
    end;
  WritePaletteAsm (Start,Finish,@CurPal);
end;

Procedure GetPCXPalettePas (PCXBuf,P:Pointer;PalOffset:Word);
Var
  I      :  Word;
  InByte :  Byte;
begin
  PCXBuf := Ptr (Seg(PCXBuf^),Ofs(PCXBuf^)+PalOffset);
  For I := 0 to 767 do begin
    InByte := Mem [Seg(PCXBuf^):Ofs(PCXBuf^)+I];
    InByte := InByte shr 2;
    Mem [Seg(P^):Ofs(P^)+I] := InByte;
    end;
end;

Procedure WritePalettePas (Start,Finish:Byte;P:Pointer);
Var
  I,
  NumColors   :  Word;
  InByte      :  Byte;
begin
  P := Ptr (Seg(P^),Ofs(P^)+Start*3);
  NumColors := (Finish - Start + 1) * 3;

  CLI;

  Port [$03C8] := Start;

  For I := 0 to NumColors do begin
    InByte := Mem [Seg(P^):Ofs(P^)+I];
    Port [$03C9] := InByte;
    end;

  STI;
end;

Procedure ReadPalettePas (Start,Finish:Byte;P:Pointer);
Var
  I,
  NumColors   :  Word;
  InByte      :  Byte;
begin
  P := Ptr (Seg(P^),Ofs(P^)+Start*3);
  NumColors := (Finish - Start + 1) * 3;

  CLI;

  Port [$03C7] := Start;

  For I := 0 to NumColors do begin
    InByte := Port [$03C9];
    Mem [Seg(P^):Ofs(P^)+I] := InByte;
    end;

  STI;
end;

Procedure GetPCXPaletteAsm (PCXBuf,P:Pointer;PalOffset:Word);
Assembler;
Asm
    push ds

    lds  si,PCXBuf
    mov  ax,PalOffset
    add  si,ax

    les  di,P

    mov  cx,768
  @@1:
    lodsb
    shr  al,1
    shr  al,1
    stosb
    loop @@1

    pop  ds
end;

Procedure WritePaletteAsm (Start,Finish:Byte;P:Pointer); Assembler;
Asm
    push ds

    lds  si,P

    cld

    xor  bh,bh               { P^ points to the beginning of the palette }
    mov  bl,Start            { data.  Since we can specify the Start and }
    xor  ax,ax               { Finish color nums, we have to point our }
    mov  al,Start            { Pointer to the Start color.  There are 3 }
    shl  ax,1                { Bytes per color, so the Start color is: }
    add  ax,bx               {   Palette Ofs = @P + Start * 3 }
    add  si,ax               { ds:si -> offset in color data }

    xor  ch,ch               { Next, we have to determine how many colors}
    mov  cl,Finish           { we will be updating.  This simply is: }
    sub  cl,Start            {    NumColors = Finish - Start + 1 }
    inc  cx

(*
    push      es
    push      dx
    push      ax

    xor       ax,ax                    { get address of status register }
    mov       es,ax                    {   from segment 0 }
    mov       dx,3BAh                  { assume monochrome addressing }
    test      Byte ptr es:[487h],2     { is mono display attached? }
    jnz       @@11                     { yes, address is OK }
    mov       dx,3DAh                  { no, must set color addressing }
  @@11:
    in        al,dx                    { read in status }
    jmp       @@21
  @@21:
    test      al,08h                   { is retrace on> (if ON, bit = 1) }
    jz        @@13                     { no, go wait For start }
  @@12:
                                       { yes, wait For it to go off }
    in        al,dx
    jmp       @@22
  @@22:
    test      al,08h                   { is retrace off? }
    jnz       @@12                     { no, keep waiting }
  @@13:
    in        al,dx
    jmp       @@23
  @@23:
    test      al,08h                   { is retrace on? }
    jz        @@13                     { no, keep on waiting }

    pop       ax
    pop       dx
    pop       es               *)

    mov  al,Start            { We are going to bypass the BIOS routines }
    mov  dx,03C8h            { to update the palette Registers.  For the }
    out  dx,al               { smoothest fades, there is no substitute }

    cli                      { turn off interrupts temporarily }
    inc  dx

  @@1:
    lodsb                    { Get the red color Byte }
    jmp  @@2                 { Delay For a few clock cycles }
  @@2:
    out  dx,al               { Write the red register directly }

    lodsb                    { Get the green color Byte }
    jmp  @@3                 { Delay For a few clock cycles }
  @@3:
    out  dx,al               { Write the green register directly }

    lodsb                    { Get the blue color Byte }
    jmp  @@4                 { Delay For a few clock cycles }
  @@4:
    out  dx,al               { Write the blue register directly }

    loop @@1

    sti                      { turn interrupts back on }
    pop  ds
end;

Procedure ReadPaletteAsm (Start,Finish:Byte;P:Pointer); Assembler;
Asm
    les  di,P

    cld

    xor  bh,bh               { P^ points to the beginning of the palette }
    mov  bl,Start            { buffer.  We have to calculate where in the}
    xor  ax,ax               { buffer we need to start at.  Because each  }
    mov  al,Start            { color has three Bytes associated With it }
    shl  ax,1                { the starting ofs is:            }
    add  ax,bx               {   Palette Ofs = @P + Start * 3  }
    add  si,ax               { es:di -> offset in color data   }

    xor  ch,ch               { Next, we have to determine how many   colors}
    mov  cl,Finish           { we will be reading.  This simply is:  }
    sub  cl,Start            {    NumColors = Finish - Start + 1     }
    inc  cx

    mov  al,Start            { We are going to bypass the BIOS routines }
    mov  dx,03C7h            { to read in from the palette Registers.   }
    out  dx,al               { This is the fastest method to do this.   }
    mov  dx,03C9h

    cli                      { turn off interrupts temporarily          }

  @@1:
    in   al,dx               { Read in the red color Byte               }
    jmp  @@2                 { Delay For a few clock cycles             }
  @@2:
    stosb                    { Store the Byte in the buffer             }

    in   al,dx               { Read in the green color Byte             }
    jmp  @@3                 { Delay For a few clock cycles             }
  @@3:
    stosb                    { Store the Byte in the buffer             }

    in   al,dx               { Read in the blue color Byte              }
    jmp  @@4                 { Delay For a few clock cycles             }
  @@4:
    stosb                    { Store the Byte in the buffer             }
    loop @@1

    sti                      { turn interrupts back on                  }
end;

end.
{

**********************************************
Here's the testing Program
**********************************************
}
Program MCGATest;

Uses
  Crt,Dos,MCGALib,Palette;

Var
  Stop,
  Start       :  LongInt;
  Regs        :  Registers;
  PicBuf,
  StorageBuf  :  Pointer;
  FileLength  :  Word;
  Pal,
  BlackPal    :  Array [1..768] of Byte;

Const
  NumTimes    = 100;

Procedure LoadBuffer (S:String;Buf:Pointer);
Var
  F           :  File;
  BlocksRead  :  Word;
begin
  Assign (F,S);
  Reset (F,1);
  BlockRead (F,Buf^,65000,FileLength);
  Close (F);
end;

Procedure Pause;
Var
  Ch     :  Char;
begin
  Repeat Until KeyPressed;
  While KeyPressed do Ch := ReadKey;
end;

Procedure Control;
begin
  SetGraphMode ($13);

  LoadBuffer ('E:\NAVAJO.PCX',PicBuf);

  GetPCXPaletteAsm (PicBuf,@Pal,FileLength-768);
  WritePalettePas (0,255,@Pal);
  DisplayPCX (0,0,PicBuf);

  FillChar (BlackPal,SizeOf(BlackPal),0);
  Pause;

  SetupFade (0,255,@BlackPal,20);
  Repeat FadePalette Until DoneFade;
  Pause;

  SetupFade (0,255,@Pal,20);
  Repeat FadePalette Until DoneFade;
  Pause;

  Oreo (0,255);
  Pause;

  SetupFade (0,255,@Pal,20);
  Repeat FadePalette Until DoneFade;
  Pause;
end;

Procedure Init;
begin
  GetMem (PicBuf,65500);
end;

begin
  Init;
  Control;
end.


