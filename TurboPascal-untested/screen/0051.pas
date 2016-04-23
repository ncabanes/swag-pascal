
{
Here is some fade code.   It works in graphics mode as well as text mode. I
have tested it in 80x25 color text mode and 320 x 200 x 256 color graphics
mode (Standard VGA)   The Fade unit is followed by example test program that
shows fading in text mode.   If anyone wants a example for fading in graphics
mode, E-MAIL me.   The only thing I ask you for using this code is that you
E-MAIL me to tell me what you are using it in.   (Well, maybe you could give
me a little credit in the documentation of your program) I didn't write the
SetPalette and GetPalette routines so I don't know what the commented out
CLIs and STIs are for.
My E-MAIL address is ericbrodsky@pslc.psl.wisc.edu
{------------------------------------------------------------------------}
{$R-} {Range checking off (Helps the fade speed)}
{$G+} {286 instructions must be enabled}
unit Fade;

    interface

 type
     TColor =
  record
      R, G, B: byte;
  end;
     TPalette = array [0..255] of TColor;
     Proc = procedure; {Passed to fade procedures}

 procedure SetPalette(Pal: TPalette; First, Last: word);
 procedure GetPalette(var Pal: TPalette; First, Last: word);
 procedure BlackenPalette(First, Last: word);
   {Blackens all colors from First to Last.   Make sure you have the}
   {palette saved in a variable.}
 procedure FadeIn(Pal: TPalette; First, Last: Word; Speed: byte; AProc:
pointer);
   {AProc is called each palette step}
 procedure FadeOut(Pal: TPalette; First, Last: Word; Speed: byte; AProc:
pointer);
   {AProc is called each palette step}

    implementation

 procedure SetPalette(Pal: TPalette; First, Last: word); assembler;
     asm
  MOV   DX, 03DAh
       @Rt:
  IN    AL, DX       { wait for no retrace                 }
  TEST  AL, 8        { this bit is high during a retrace   }
  JZ    @Rt          { so loop until it goes high          }

  MOV   CX, [Last]   { CX = last colour to set             }
  MOV   AX, [First]  { AX = first colour to set            }
  SUB   CX, AX
  INC   CX           { CX = number of colours to set       }
  MOV   DX, 03C8h    { Palette Address register            }
  {CLI}
  OUT   DX, AL       { set starting register               }
  INC   DX           { Palette Data register               }
  PUSH  DS
  LDS   SI, [Pal]    { DS:SI -> palette                    }
  ADD   SI, AX
  ADD   SI, AX
  ADD   SI, AX       { DS:SI -> first entry to set         }
  MOV   AX, CX       { triple the value in CX              }
  ADD   CX, AX
  ADD   CX, AX       { CX = total number of bytes to write }
  REP   OUTSB        { write palette                       }
  {STI}
  POP   DS
     end;

 procedure GetPalette(var Pal: TPalette; First, Last: word); assembler;
     asm
    MOV   CX, [Last]     { CX = last colour                    }
    MOV   AX, [First]    { AX = starting colour                }
    SUB   CX, AX
    INC   CX             { CX = number of colours              }
    MOV   DX, 03C7h      { Palette Address register            }
    {CLI}
    OUT   DX, AL         { set starting register               }
    INC   DX
    INC   DX             { DX = Palette Data register          }
    LES   DI, [Pal]      { ES:DI -> palette                    }
    ADD   DI, AX
    ADD   DI, AX
    ADD   DI, AX         { ES:DI -> first entry to read        }
    MOV   AX, CX         { triple the value in CX              }
    ADD   CX, AX
    ADD   CX, AX         { CX = total number of bytes to read  }
    REP   INSB           { Read  palette                       }
    {STI}
     end;

 procedure BlackenPalette(First, Last: word);
     var
  Pal: TPalette;
  i: word;
     begin
  for i := First to Last do
      begin
   Pal[i].R := 0; Pal[i].G := 0; Pal[i].B := 0;
      end;
  SetPalette(Pal, First, Last);
     end;

 procedure FadeIn(Pal: TPalette; First, Last: Word; Speed: byte; AProc:
pointer);
     var
  i, j    : Byte;
  TempPal : TPalette;
     begin
  for i := 0 to Speed do
      begin
   for j := First to Last do
       begin
    TempPal[j].R := Pal[j].R * i div Speed;
    TempPal[j].G := Pal[j].G * i div Speed;
    TempPal[j].B := Pal[j].B * i div Speed;
       end;
   Setpalette(TempPal, First, Last);
   if (AProc <> nil) then Proc(AProc);
      end;
     end;

 procedure FadeOut(Pal: TPalette; First, Last: Word; Speed: byte; AProc:
pointer);
     var
  i, j    : Byte;
  TempPal : TPalette;
     begin
  TempPal := Pal;
  for i := Speed downto 0 do
      begin
   for j := First to Last do
       begin
    TempPal[j].R := Pal[j].R * i div Speed;
    TempPal[j].G := Pal[j].G * i div Speed;
    TempPal[j].B := Pal[j].B * i div Speed;
       end;
   Setpalette(TempPal, First, Last);
   if (AProc <> nil) then Proc(AProc);
      end;
     end;
    end.

{---------------------------------------------------------------------}

program FadeTest;
    uses
 CRT,
 Fade;
    const
 FadeSpeed1 = 64;

 FadeSpeed2 = 64;
    var
 Pal : TPalette;
 i : longint;
    procedure aProcedure; far;
      {This procedure will be called every fade step}
 begin
     Inc(i);
     writeln('Test 2 of Ethan Brodsky''s fade routines:   Fade Step #',
                    i);
 end;
    begin
 GetPalette(Pal, 0, 255);

 {Test part 1}
 BlackenPalette(0, 255);
 writeln('Test 1 of Ethan Brodsky''s fade routines');
 FadeIn(Pal, 0, 255, FadeSpeed1, nil);
 FadeOut(Pal, 0, 255, FadeSpeed1, nil);
 FadeIn(Pal, 0, 255, FadeSpeed1, nil);

 writeln('Press any key to continue . . .');
 repeat until KeyPressed;

 {Test part 2}
 i := 0;
 FadeOut(Pal, 0, 255, FadeSpeed2, @aProcedure);
 i := 0;
 FadeIn(Pal,  0, 255, FadeSpeed2, @aProcedure);
    end.

