{
>> Could someone please explain to me about VGA palette fading and
>> rotating?  I am writing a small screensaver program, and want to rotate
>> the palette and fade a little.  Any help would be greatly appreciated.

>First, a few questions for you.  Do you know how to access the Palette?  Do
>you know how the VGA Palette is set up?  If not, I can help you understand i
>& manipulate it.

JR>Once you know the above, fading & rotating is pretty easy.  Fading is just
JR>decrementing the values in the palette slowly while rotating is just moving
JR>all the values in the palette forward or backward.


Here is some source for Fadeing, Cycling, and Rotating the palette.  It
probably doesn't have the procedures you need for a Screensaver, but I
figure you will be able to understand it and write you own procedures
using the code provided.  (I have tested the code and find that it works
almost perfectly on my machine (there's a little "snow" at the top) but
I make no guarantees that it will work for anyone elses).

If you need a Demo program that uses this unit, just ask, I have one.


{ ********************************************************** }
{ ********************** Palette Unit ********************** }
{ ********************************************************** }
{ **************** Written by: Rick Haines ***************** }
{ ********************************************************** }
{ ***************** Last Revised 11/28/94 ****************** }
{ ********************************************************** }

Unit Palette;

{ ********************************************************** }
{ *********************** REMINDER!: *********************** }
{ ************* The first color in the palette ************* }
{ **************** is the background color! **************** }
{ ********************************************************** }

Interface

 Type
  RGBColor = Record
    R, G, B : Byte;
   End;
  RGBPalette = Array[0..255] Of RGBColor;

 Procedure WaitForVRT;                                       { Wait For Verticl}

 Procedure FadeInColor(ColorNum   : Byte);                   { Fade In a specif}
 Procedure FadeOutColor(ColorNum  : Byte);                   { Fade Out a speci}
 Procedure RestoreColor(ColorNum  : Byte);                   { Fade In Color im}
 Procedure BlackOutColor(ColorNum : Byte);                   { Fade Out Color i}
 Procedure CycleColor(ColorNum, Red, Green, Blue  : Byte);   { Cycle color into}
 Procedure ChangeColor(ColorNum, Red, Green, Blue : Byte);   { Change color int}
 Procedure CopyColor(Num      : Byte; Var Color : RGBColor); { Load a copy of C}
 Procedure GetCopyOfColor(Num : Byte; Var Color : RGBColor); { Get a Copy of Co}

 Procedure GetPalette;                                { Load the default Palett}
 Procedure CyclePalette;                              { Cycle from one Palette }
 Procedure FadeInPalette;                             { Fade Palette in slowly }
 Procedure FadeOutPalette;                            { Fade Palette out slowly}
 Procedure RestorePalette;                            { Fade Palette in immedia}
 Procedure BlackOutPalette;                           { Fade Palette out immedi}
 Procedure LoadPalette(PalName : String);             { Load a palette         }
 Procedure SavePalette(PalName : String);             { Save the palette that i}
 Procedure CyclePaletteToColor(ColorNum  : Byte);     { Cycle entire Palette Co}
 Procedure ChangePaletteToColor(ColorNum : Byte);     { Change entire Palette C}
 Procedure CopyPalette(Var NewPal    : RGBPalette);   { Load palette already in}
 Procedure GetCopyOfPalette(Var Copy : RGBPalette);   { Incase you don't want t}

 Procedure CyclePart(FirstC, LastC : Byte);                   { Cycle from one }
 Procedure FadeInPart(FirstC, LastC   : Byte);                { Fade Part in sl}
 Procedure FadeOutPart(FirstC, LastC  : Byte);                { Fade Part out s}
 Procedure RestorePart(FirstC, LastC  : Byte);                { Fade Part in im}
 Procedure BlackOutPart(FirstC, LastC : Byte);                { Fade Part out i}
 Procedure RotatePartForward(FirstC, LastC  : Byte);          { Rotate Part For}
 Procedure RotatePartBackward(FirstC, LastC : Byte);          { Rotate Part Bac}
 Procedure CyclePartToColor(FirstC, LastC, ColorNum  : Byte); { Cycle Part Colo}
 Procedure ChangePartToColor(FirstC, LastC, ColorNum : Byte); { Change Part Col}

Implementation
 Uses MostUsed;

 Const
  PalRange = $03C6;
  ReadPal  = $03C7;
  WritePal = $03C8;
  PalData  = $03C9;
  VRTPort  = $03DA;

 Var
  APalette,
  BackUpP  : RGBPalette;
  ExColor  : RGBColor;
  First,
  Last,
  I, II, Z : Byte;

 Procedure WaitForVRT; Assembler;
  Asm                  { Wait for Verticle Retrace so that }
   Mov     DX, VRTPort { "snow" is avoided                 }
  @VRT:
   In      AL, DX
   Test    AL, 8
   JNZ     @VRT        { Wait until Verticle Retrace starts }
  @NoVRT:
   In      AL, DX
   Test    AL, 8
   JZ      @NoVRT      { Wait until Verticle Retrace Ends   }
  End;

 Procedure WriteColor(ColorNum : Byte); Assembler;
  Asm

 { Initialization Stuff }

   Mov SI, Offset APalette { DS:SI := @APalette        }

   Xor CH, CH
   Mov CL, ColorNum        { CX := ColorNum            }
   Mov AX, CX
   ShL AX, 1               { Use a Shift by Two and an }
   Add CX, AX              { Add to Multiply by 3      }
   Add SI, CX              { Adjust Offset of APalette }

   Mov DX, PalRange        { DX := Palette Range Port  }
   Mov AX, 0FFh            { AX := Range is All Colors }
   Out DX, AX              { Write AX To Port DX       }

   Call WaitForVRT;        { Wait for Verticle ReTrace }

 { Write the color to Ports }

   Mov DX, WritePal        { DX := Color To Write Port      }
   Mov AL, ColorNum        { AL := Color To Write           }
   Out DX, AL              { Tell It We Want to Write Color }
   Mov DX, PalData         { DX := Palette Data Port        }
   Mov AL, [SI]            { AL := APalette[ColorNum].R     }
   Out DX, AL              { Write it                       }
   Inc SI                  { Inc Offset                     }
   Mov AL, [SI]            { AL := APalette[ColorNum].G     }
   Out DX, AL              { Write it                       }
   Inc SI                  { Inc Offset                     }
   Mov AL, [SI]            { AL := APalette[ColorNum].G     }
   Out DX, AL              { Write it                       }
  End;

 Procedure FadeInColor(ColorNum : Byte);
  Begin
   For I := 0 To 63 Do
    With APalette[ColorNum] Do
     Begin
      If R < BackUpP[ColorNum].R Then Inc(R);
      If G < BackUpP[ColorNum].G Then Inc(G);
      If B < BackUpP[ColorNum].B Then Inc(B);
      WriteColor(ColorNum);
     End;
  End;

 Procedure FadeOutColor(ColorNum : Byte);
  Begin
   For I := 0 To 63 Do
    With APalette[ColorNum] Do
     Begin
      If R > 0 Then Dec(R);
      If G > 0 Then Dec(G);
      If B > 0 Then Dec(B);
      WriteColor(ColorNum);
     End;
  End;

 Procedure RestoreColor(ColorNum : Byte);
  Begin
   APalette[ColorNum] := BackUpP[ColorNum];
   WriteColor(ColorNum);
  End;

 Procedure BlackOutColor(ColorNum : Byte);
  Begin
   With APalette[ColorNum] Do
    Begin
     R := 0;
     G := 0;
     B := 0;
    End;
   WriteColor(ColorNum);
  End;

 Procedure CopyColor(Num : Byte; Var Color : RGBColor);
  Begin
   With BackUpP[Num] Do
    Begin
     R := Color.R;
     G := Color.G;
     B := Color.B;
    End;
  End;

 Procedure CycleColor(ColorNum, Red, Green, Blue : Byte);
  Begin
   For I := 0 To 63 Do
    With APalette[ColorNum] Do
     Begin
      If R < Red   Then Inc(R);
      If G < Green Then Inc(G);
      If B < Blue  Then Inc(B);
      If R > Red   Then Dec(R);
      If G > Green Then Dec(G);
      If B > Blue  Then Dec(B);
      WriteColor(ColorNum);
     End;
  End;

 Procedure ChangeColor(ColorNum, Red, Green, Blue : Byte);
  Begin
   With BackUpP[ColorNum] Do
    Begin
     R := Red;
     G := Green;
     B := Blue;
    End;
  End;

 Procedure GetCopyOfColor(Num : Byte; Var Color : RGBColor);
  Begin
   With BackUpP[Num] Do
    Begin
     Color.R := R;
     Color.G := G;
     Color.B := B;
    End;
  End;

 Procedure GetPalette; Assembler;
  Asm

 { Initialization Stuff }

   Mov DI, Offset BackUpP  { DS:DI := @BackUpP         }

   Xor CX, CX              { CL := 0 (Counter)         }

   Mov DX, PalRange        { DX := Palette Range Port  }
   Mov AX, 0FFh            { AX := Range is All Colors }
   Out DX, AX              { Write AX To Port DX       }

   Call WaitForVRT;        { Wait for Verticle ReTrace }

 { Now Get the Entire Palette From Ports }

  @MainLoop:
   Mov DX, ReadPal         { DX := Color To Read Port           }
   Mov AL, CL              { AL := CL (Current Color)           }
   Out DX, AL              { Tell It We Want to Read Color # CL }
   Mov DX, PalData         { DX := Palette Data Port            }

   In  AL, DX              { Read Red            }
   Mov [DI], AL            { BackUpP[CL].R := AL }
   Inc DI                  { Inc Offset          }
   In  AL, DX              { Read Green          }
   Mov [DI], AL            { BackUpP[CL].G := AL }
   Inc DI                  { Inc Offset          }
   In  AL, DX              { Read Blue           }
   Mov [DI], AL            { BackUpP[CL].B := AL }
   Inc DI                  { Inc Offset          }
   Inc CX                  { Inc Counter         }
   Cmp CX, 256             { Are We Done?        }
   JNE @MainLoop           { No?  Then Loop      }

 { Now Do APalette := BackUpP }

   Mov SI, Offset BackUpP  { DS:SI := @BackUpP      }
   Mov DI, DS
   Mov ES, DI
   Mov DI, Offset APalette { ES:DI := @APalette     }
   Mov CX, 256*3           { How many bytes to copy }
   Shr CX, 1               { Div by 2 for Words     }
   ClD                     { Go downward in memory  }
   Rep MovSW               { Move It                }
  End;

 Procedure WritePalette; Assembler;
  Asm

  { Initialization Stuff }
   Mov SI, Offset APalette { DS:SI := @APalette        }
   Xor CX, CX              { CX := 0 (Counter)         }

   Mov DX, PalRange        { DX := Palette Range Port  }
   Mov AX, 0FFh            { AX := Range is All Colors }
   Out DX, AX              { Write AX To Port DX       }

   Call WaitForVRT;        { Wait for Verticle ReTrace }

 { Now write Entire Palette to Ports }

  @MainLoop:

   Mov DX, WritePal        { DX := Color To Write Port           }
   Mov AL, CL              { AL := CL (Current Color)            }
   Out DX, AL              { Tell It We Want to Write Color # CL }
   Mov DX, PalData         { DX := Palette Data Port             }

   Mov AL, [SI]            { AL := APalette[CL].R                }
   Out DX, AL              { Write it                            }
   Inc SI                  { Inc Offset                          }
   Mov AL, [SI]            { AL := APalette[CL].R                }
   Out DX, AL              { Write it                            }
   Inc SI                  { Inc Offset                          }
   Mov AL, [SI]            { AL := APalette[CL].G                }
   Out DX, AL              { Write it                            }
   Inc SI                  { Inc Offset                          }
   Inc CX                  { Inc Counter                         }
   Cmp CX, 256             { Are We Done?                        }
   JNE @MainLoop           { No?  Then Loop                      }
  End;

 Procedure CyclePalette;
  Begin
   For I := 0 To 63 Do
    Begin
     For II := 0 To 255 Do With APalette[II] Do
      Begin
       If R < BackUpP[II].R Then Inc(R)
        Else If R > BackUpP[II].R Then Dec(R);
       If G < BackUpP[II].G Then Inc(G)
        Else If G > BackUpP[II].G Then Dec(G);
       If B < BackUpP[II].B Then Inc(B)
        Else If B > BackUpP[II].B Then Dec(B);
      End;
     WritePalette;
    End;
  End;

 Procedure FadeInPalette;
  Begin
   For I := 0 To 63 Do
    Begin
     For II := 0 To 255 Do With APalette[II] Do
      Begin
       If R < BackUpP[II].R Then Inc(R);
       If G < BackUpP[II].G Then Inc(G);
       If B < BackUpP[II].B Then Inc(B);
      End;
     WritePalette;
    End;
  End;

 Procedure FadeOutPalette;
  Begin
   For I := 0 To 63 Do
    Begin
     For II := 0 To 255 Do With APalette[II] Do
      Begin
       If R > 0 Then Dec(R);
       If G > 0 Then Dec(G);
       If B > 0 Then Dec(B);
      End;
     WritePalette;
    End;
  End;

 Procedure RestorePalette;
  Begin
   APalette := BackUpP;
   WritePalette;
  End;

 Procedure BlackOutPalette; Assembler;
  Asm
   Mov DI, DS
   Mov ES, DI               { ES contains segment of Palette }
   Mov DI, Offset APalette; { DI contains offset of Palette  }
   Mov CX, 256*3            { CX = how many bytes to write   }
   ShR CX, 1                { Divide by 2 for how many words }
   Mov AX, 0                { Word to write to memory        }
   ClD                      { Go downward in memory          }
   Rep StoSW                { Write it all to memory         }
   Call WritePalette;       { Write the Palette              }
  End;

 Procedure LoadPalette(PalName : String);
  Var
   PalFile : File;
  Begin
   PalName := PalName + '.PAL';
   If Not FileExists(PalName) Then Exit;
   Assign(PalFile, PalName);
   Reset(PalFile, 3);
   For I := 0 To 255 Do
    Begin
     If EoF(PalFile) Then Break;
     BlockRead(PalFile, BackUpP[I], 1);
    End;
   Close(PalFile);
  End;

 Procedure SavePalette(PalName : String);
  Var
   PalFile : File;
  Begin
   If Length(PalName) > 8 Then Exit;
   PalName := PalName + '.PAL';
   Assign(PalFile, PalName);
   ReWrite(PalFile, 3);
   For I := 0 To 255 Do BlockWrite(PalFile, BackUpP[I], 1);
   Close(PalFile);
  End;

 Procedure CyclePaletteToColor(ColorNum : Byte);
  Begin
   For I := 0 To 63 Do
    Begin
     For II := 0 To 255 Do With APalette[II] Do
      Begin
       If R < BackUpP[ColorNum].R Then Inc(R)
        Else If R > BackUpP[ColorNum].R Then Dec(R);
       If G < BackUpP[ColorNum].G Then Inc(G)
        Else If G > BackUpP[ColorNum].G Then Dec(G);
       If B < BackUpP[ColorNum].B Then Inc(B)
        Else If B > BackUpP[ColorNum].B Then Dec(B);
      End;
     WritePalette;
    End;
  End;

 Procedure ChangePaletteToColor(ColorNum : Byte);
  Begin
   For I := 0 To 255 Do With APalette[I] Do
    Begin
     R := BackUpP[ColorNum].R;
     G := BackUpP[ColorNum].G;
     B := BackUpP[ColorNum].B;
    End;
   WritePalette;
  End;

 Procedure CopyPalette(Var NewPal : RGBPalette);
  Begin
   BackUpP := NewPal;
  End;

 Procedure GetCopyOfPalette(Var Copy : RGBPalette);
  Begin
   Copy := BackUpP;
  End;

 Procedure WritePart; Assembler;
  Asm

  { Initialization Stuff }

   Mov SI, Offset APalette { DS:SI := @APalette        }
   Xor BH, BH
   Mov BL, [First]
   Mov DI, BX
   ShL BX, 1
   Add DI, BX              { Mult By 3 Quick           }
   Add SI, DI              { Adjust Offset             }

   Xor CH, CH
   Mov CL, [First]         { CX := First (Counter)     }
   Xor BH, BH
   Mov BL, [Last]          { BX := Last Color          }
   Inc BX

   Mov DX, PalRange        { DX := Palette Range Port  }
   Mov AX, 0FFh            { AX := Range is All Colors }
   Out DX, AX              { Write AX To Port DX       }

   Call WaitForVRT;        { Wait for Verticle ReTrace }

 { Now write Palette to Ports }

  @MainLoop:

   Mov DX, WritePal        { DX := Color To Write Port           }
   Mov AL, CL              { AL := CL (Current Color)            }
   Out DX, AL              { Tell It We Want to Write Color # CL }
   Mov DX, PalData         { DX := Palette Data Port             }

   Mov AL, [SI]            { AL := APalette[CL].R                }
   Out DX, AL              { Write it                            }
   Inc SI                  { Inc Offset                          }
   Mov AL, [SI]            { AL := APalette[CL].R                }
   Out DX, AL              { Write it                            }
   Inc SI                  { Inc Offset                          }
   Mov AL, [SI]            { AL := APalette[CL].G                }
   Out DX, AL              { Write it                            }
   Inc SI                  { Inc Offset                          }
   Inc CX                  { Inc Counter                         }
   Cmp CX, BX              { Are We Done?                        }
   JNE @MainLoop           { No?  Then Loop                      }
  End;

 Procedure CyclePart(FirstC, LastC : Byte);
  Begin
   First := FirstC; Last := LastC;
   For I := 0 To 63 Do
    Begin
     For II := First To Last Do With APalette[II] Do
      Begin
       If R < BackUpP[II].R Then Inc(R)
        Else If R > BackUpP[II].R Then Dec(R);
       If G < BackUpP[II].G Then Inc(G)
        Else If G > BackUpP[II].G Then Dec(G);
       If B < BackUpP[II].B Then Inc(B)
        Else If B > BackUpP[II].B Then Dec(B);
      End;
     WritePart;
    End;
  End;

 Procedure FadeInPart(FirstC, LastC : Byte);
  Begin
   First := FirstC; Last := LastC;
   For I := 0 To 63 Do
    Begin
     For II := First To Last Do With APalette[II] Do
      Begin
       If R < BackUpP[II].R Then Inc(R);
       If G < BackUpP[II].G Then Inc(G);
       If B < BackUpP[II].B Then Inc(B);
      End;
     WritePart;
    End;
  End;

 Procedure FadeOutPart(FirstC, LastC : Byte);
  Begin
   First := FirstC; Last := LastC;
   For I := 0 To 63 Do
    Begin
     For II := First To Last Do With APalette[II] Do
      Begin
       If R > 0 Then Dec(R);
       If G > 0 Then Dec(G);
       If B > 0 Then Dec(B);
      End;
     WritePart;
    End;
  End;

 Procedure RestorePart(FirstC, LastC : Byte);
  Begin
   First := FirstC; Last := LastC;
   For I := First To Last Do APalette[I] := BackUpP[I];
   WritePart;
  End;

 Procedure BlackOutPart(FirstC, LastC : Byte); Assembler;
  Asm
   Mov BL, [FirstC]
   Mov [First], BL
   Mov BL, [LastC]
   Mov [Last], BL

   Mov DI, DS
   Mov ES, DI               { ES contains segment of Palette }
   Mov DI, Offset APalette; { DI contains offset of Palette  }
   Xor BH, BH
   Mov BL, [First]
   Mov CX, BX
   ShL CX, 1
   Add BX, CX               { Mult By 3 Quick                }
   Add DI, BX               { Adjust Offset Of Palette       }

   Xor BH, BH
   Mov BL, [Last]
   Xor CH, CH
   Mov CL, [First]
   Sub BX, CX               { Get Num Of Bytes to Write in CX}
   Mov CX, BX
   ShL CX, 1
   Mov AX, 0                { Word to write to memory        }
   ClD                      { Go downward in memory          }
   Rep StoSB                { Write it all to memory         }
   Call WritePart;          { Write the Palette              }
  End;

 Procedure CyclePartToColor(FirstC, LastC, ColorNum : Byte);
  Begin
   First := FirstC; Last := LastC;
   For I := 0 To 63 Do
    Begin
     For II := FirstC To LastC Do With APalette[II] Do
      Begin
       If R < BackUpP[ColorNum].R Then Inc(R)
        Else If R > BackUpP[ColorNum].R Then Dec(R);
       If G < BackUpP[ColorNum].G Then Inc(G)
        Else If G > BackUpP[ColorNum].G Then Dec(G);
       If B < BackUpP[ColorNum].B Then Inc(B)
        Else If B > BackUpP[ColorNum].B Then Dec(B);
      End;
     WritePart;
    End;
  End;

 Procedure ChangePartToColor(FirstC, LastC, ColorNum : Byte);
  Begin
   First := FirstC; Last := LastC;
   For I := First To Last Do With APalette[I] Do
    Begin
     R := BackUpP[ColorNum].R;
     G := BackUpP[ColorNum].G;
     B := BackUpP[ColorNum].B;
    End;
   WritePart;
  End;

 Procedure RotatePartForward(FirstC, LastC : Byte);
  Begin
   First := FirstC; Last := LastC;
   ExColor := APalette[Last];
   For I := Last DownTo First+1 Do APalette[I] := APalette[I-1];
   APalette[First] := ExColor;
   WritePart;
  End;

 Procedure RotatePartBackward(FirstC, LastC : Byte);
  Begin
   First := FirstC; Last := LastC;
   ExColor := APalette[First];
   For I := First To Last-1 Do APalette[I] := APalette[I+1];
   APalette[Last] := ExColor;
   WritePart;
  End;

End.

