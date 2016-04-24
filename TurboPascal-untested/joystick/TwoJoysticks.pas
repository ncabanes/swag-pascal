(*
  Category: SWAG Title: JOYSTICK ROUTINES
  Original name: 0006.PAS
  Description: Two Joysticks
  Author: SWAG SUPPORT TEAM
  Date: 05-31-93  08:11
*)

==============================================================================
 BBS: «« The Information and Technology Exchan
  To: MATT CRILL                   Date: 01-05─92 (23:03)
From: DANIEL CHURCHMAN           Number: 4144   [101] PASCAL
Subj: JOYSTICK 1                 Status: Public
------------------------------------------------------------------------------
Program Joy;  { Read Joystick positions and button states }

Uses DOS, Crt;

Const
  Buttons          : Byte = 0;
  Joystick         : Byte = 1;

  JoyIntr          : Byte = $15;
  JoyFunc          : Byte = $84;

  CStart           : Byte = 0; { To hold cursor start line }
  CEnd             : Byte = 0; { To hold cursor end line }

  kX               : Real = 6.25; { constant for horizontal conversion }
  kY               : Real = 20.0; { constant for vertical conversion }

  LastKey          : Char = ' ';

Var
  { Variables for Joystick 1 }
  Joy1Vert         : Word; { Vertical Position }
  Joy1Hori         : Word; { Horizontal Position }
  Joy1But1         : Boolean; { Button 1 }
  Joy1But2         : Boolean; { Button 2 }

  { Variables for Joystick 2 }
  Joy2Vert         : Word; { Vertical Position }
  Joy2Hori         : Word; { Horizontal Position }
  Joy2But1         : Boolean; { Button 1 }
  Joy2But2         : Boolean; { Button 2 }

  Error            : Boolean; { We'll set this if the joystick isn't found }

  Regs             : Registers;
  NewX, NewY       : Byte;
  OldX, OldY       : Byte;
  MinX, MinY,
  MaxX, MaxY       : Word;

{ Checkjoy and CheckBut are really the only two procedures of real }
{ interest to you; the rest is just support code to do something   }
{ with the samples.                                                }


Procedure CheckJoy;
    begin   { Prepare and make Int 15h, subfunction 84h call }
      With Regs do
      begin
        AH := JoyFunc;
        DX := Joystick;  { Subfunction 1 = joystick }
        Intr(JoyIntr, Regs);
        Joy1Hori := AX;
        Joy1Vert := BX;
        Joy2Hori := CX;
        Joy2Vert := DX;
        Error := ((Flags AND FCarry) <> 0)
      end;
    end;

Procedure CheckBut;
    Const
      MaskJ1B1     = $10;
      MaskJ1B2     = $20;
      MaskJ2B1     = $40;
      MaskJ2B2     = $80;
    begin   { Prepare and make Int 15h, subfunction 84h call }
      With Regs do
      begin
        AH := JoyFunc;
        DX := Buttons;  { Subfunction 0 = buttons }
        Intr(JoyIntr, Regs);
        Joy1But1 := (AL AND MaskJ1B1) <> MaskJ1B1;
        Joy1But2 := (AL AND MaskJ1B2) <> MaskJ1B2;
        Joy2But1 := (AL AND MaskJ2B1) <> MaskJ2B1;
        Joy2But2 := (AL AND MaskJ2B2) <> MaskJ2B2;
        Error := ((Flags AND FCarry) <> 0)
      end;
    end;

Procedure Calibrate;
    Var
      n            : Byte;
    begin
      { Calibrate joystick 1 }
      CheckJoy;
      If Error then
      begin
        Write('No Joystick(s) found - terminating program');
        Halt(1)
      end;

      If (Joy1Vert + Joy1Hori) = 0 then
        Writeln('Joystick 1 Absent')
      else
        Writeln('Joystick 1 Present');
      If (Joy2Vert + Joy2Hori) = 0 then
        Writeln('Joystick 2 Absent')
      else
        Writeln('Joystick 2 Present');

(*      { Get centre joystick values for X and Y }
      Write('Hold joystick in centre position and press a button');
      Repeat
        CheckBut
      Until (Joy1But1 OR Joy1But2);
      CentreX := 0;
      CentreY := 0;
      For n := 1 to 10 do
      begin
        CheckJoy;
        CentreX := CentreX + Joy1Hori;
        CentreY := CentreY + Joy1Vert;
      end;
      CentreX := CentreX DIV 10;
      CentreY := CentreY DIV 10;
      While (Joy1But1 OR Joy1But2) do  { Wait till button released }
      begin
        CheckBut
      end;
      Writeln('  -  ',CentreX,':',CentreY);
*)

      { Get minimum joystick values for X and Y }
      Write('Hold joystick in upper-left position and press a button');
      Repeat
        CheckBut
      Until (Joy1But1 OR Joy1But2);
      MinX := 0;
      MinY := 0;
      For n := 1 to 10 do  { Sample over time for accuracy }
      begin
        CheckJoy;
        { Bias the reading slightly to ensure }
        { we can always reach coord 1,1 }
        MinX := MinX + Word(Round(Joy1Hori * 1.1));
        MinY := MinY + Word(Round(Joy1Vert * 1.1))
      end;
      MinX := MinX DIV 10;
      MinY := MinY DIV 10;
      While (Joy1But1 OR Joy1But2) do  { Wait till button released }
      begin
        CheckBut
      end;
      Writeln('  -  ',MinX,':',MinY);

      { Get maximum joystick values for X and Y }
      Write('Hold joystick in bottom-right position and press a button');
      Repeat
        CheckBut
      Until (Joy1But1 OR Joy1But2);
      MaxX := 0;
      MaxY := 0;
      For n := 1 to 10 do   { Sample over time for accuracy }
      begin
        CheckJoy;
        { Bias the reading slightly to ensure }
        { we can always reach coord 80,25 }
        MaxX := MaxX + Word(Round(Joy1Hori * 0.95));
        MaxY := MaxY + Word(Round(Joy1Vert * 0.95))
      end;
      MaxX := MaxX DIV 10;
      MaxY := MaxY DIV 10;
      While (Joy1But1 OR Joy1But2) do  { Wait till button released }
      begin
        CheckBut
      end;
      Writeln('  -  ',MaxX,':',MaxY);

      { Important to note that the following calculations of kX and   }
      { kY is done linearly.  This is not really correct, as you'll   }
      { see by the fact that when centred, your screen coords are     }
      { NOT 40,13.  The reason is that the resistors in joysticks     }
      { work on a logarithmic scale.  My knowledge of logs is too     }
      { rusty to build this in properly, so I've skipped it.  What    }
      { you should do is derive the log that correctly passes through }
      { minimum, maximum AND centre.  This way, the joystick, centred }
      { will correctly position your screen coord dead centre, and    }
      { you can still reach the extremes as well.                     }

      kX := (MaxX - MinX) / 80;
      kY := (MaxY - MinY) / 25;
      Writeln('kX = ', kX:0:2,'     kY = ',kY:0:2);

    end;

[Continued]


--- Msged/sq
 * Origin: C&O Systems, Brisbane, AUSTRALIA (3:640/777)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: MATT CRILL                   Date: 01-05─92 (23:04)
From: DANIEL CHURCHMAN           Number: 4145   [101] PASCAL
Subj: JOYSTICK 2                 Status: Public
------------------------------------------------------------------------------
Procedure SetCoord;
    begin
      If Joy1Hori < MinX then NewX := 1 else
        NewX := Byte(Round((Joy1Hori - MinX) / kX));
      If Joy1Vert < MinY then NewY := 1 else
        NewY := Byte(Round((Joy1Vert - MinY) / kY));

      If NewX = 0 then NewX := 1;
      If NewX > 80 then NewX := 80;
      If NewY = 0 then NewY := 1;
      If NewY > 25 then NewY := 25;

    end;

Procedure MoveIndicator;
    begin

      { If the position has changed, clean up old indicator }
      If NOT ((OldX = NewX) AND (OldY = NewY)) then
      begin

        { Turn off indicator at old position }
        With Regs do
        begin
          { First, move cursor to old position }
          AH := 2;   { Set cursor position                }
          BH := 0;   { Assume page 0                      }
          DH := OldY - 1; { This value must be zero-based }
          DL := OldX - 1; { This one too                  }
          Intr($10,Regs);

          { Now change the attribute }
          AH := 8;   { Read what character is there now                  }
          BH := 0;   { I'm assuming page 0                               }
          Intr($10,Regs);  {AH now holds the attribute, AL the character }
          AH := 9;   { Write Character and Attribute, AL is ok, so...    }
          BL := 31;  { ...only change the attribute                      }
          BH := 0;   { Again, assume page 0                              }
          CX := 1;   { Number of characters to write                     }
          Intr($10,Regs)
        end
      end;
      { Always refresh the current position }

      With Regs do
      begin
        { Next, move cursor to new position }
        AH := 2;   { Set cursor position                }
        BH := 0;   { Assume page 0                      }
        DH := NewY - 1; { This value must be zero-based }
        DL := NewX - 1; { This one too                  }
        Intr($10,Regs);

        { Then, turn on indicator at NEW position }
        AH := 8;   { Read what character is there now                  }
        BH := 0;   { I'm assuming page 0                               }
        Intr($10,Regs);  {AH now holds the attribute, AL the character }
        AH := 9;   { Write Character and Attribute, AL is ok, so...    }
        BL := 112; { ...change the attribute to black on grey          }
        BH := 0;   { Again, assume page 0                              }
        CX := 1;   { Number of characters to write                     }
        Intr($10,Regs)

      end;

    end;

Procedure InitScreen;
    begin
      GotoXY(26,10);
      Write('Joystick 1        Joystick 2');
      GotoXY(20,12);
      Write('X :');
      GotoXY(20,13);
      Write('Y :');
      GotoXY(14,14);
      Write('Buttons :');
      GotoXY(16,16);
      Write('Error =');
      GotoXY(20,23);
      Write('Press "C" to reCalibrate your joystick');

      With Regs do
      begin      { First, save present cursor configuration }

        AH := 3; { Read cursor pos and config }
        BH := 0; { Assuming we are using page 0 }
        Intr($10,Regs);
        CStart := CH; { Starting line of cursor }
        CEnd   := CL; { Ending line of cursor }
        { DH holds cursor row }
        { DL holds cursor column }

        { Now turn the cursor off - we hope! }

        AH := 1;  { Set cursor type }
        CH := $20; { Should cause the cursor to disappear }
        Intr($10,Regs);

      end
    end;

Procedure GetKey;
    begin
      If KeyPressed then
      begin
        LastKey := ReadKey;  { Read the key in the buffer       }
        If LastKey = #0 then { The key is an extended character }
          LastKey := ReadKey { Read the extended value          }
      end else
        LastKey := #0
    end;

[Continued]

--- Msged/sq
 * Origin: C&O Systems, Brisbane, AUSTRALIA (3:640/777)
==============================================================================
 BBS: «« The Information and Technology Exchan
  To: MATT CRILL                   Date: 01-05─92 (23:05)
From: DANIEL CHURCHMAN           Number: 4146   [101] PASCAL
Subj: JOYSTICK 3                 Status: Public
------------------------------------------------------------------------------
begin
  TextAttr := 31;  { White on Blue - my favourite :-) }
  ClrScr;

  Calibrate;
  SetCoord;

  InitScreen;

  Repeat
    GetKey;  { Simply load the variable LastKey with }
             { a keystroke if one is available       }
    CheckJoy;
    CheckBut;
    OldX := NewX;
    OldY := NewY;
    SetCoord;
    GotoXY(24,12);
    Write(Joy1Hori:10);
    GotoXY(24,13);
    Write(Joy1Vert:10);
    GotoXY(31,14);
    Write((Joy1But1):5,':',(Joy1But2):5);

    GotoXY(44,12);
    Write(Joy2Hori:10);
    GotoXY(44,13);
    Write(Joy2Vert:10);
    GotoXY(51,14);
    Write(Byte(Joy2But1),':',Byte(Joy2But2));

    GotoXY(37,15);
    Write(NewX:2,':',NewY:2);

    GotoXY(24,16);
    Write(Error:5);

    Writeln;
    MoveIndicator;

    If UpCase(LastKey) = 'C' then
    begin
      ClrScr;
      Calibrate;
      InitScreen
    end;

  Until LastKey = #27;

  With Regs do
  begin      { Restore original cursor configuration }

    AH := 1;  { Set cursor type }
    CH := CStart; { Original cursor start line }
    CL := CEnd;   { Original cursor end line }
    Intr($10,Regs);
    GotoXY(1,24)
  end;

end.



[End of code]
--- Msged/sq
 * Origin: C&O Systems, Brisbane, AUSTRALIA (3:640/777)

