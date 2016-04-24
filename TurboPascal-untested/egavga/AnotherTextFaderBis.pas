(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0035.PAS
  Description: Another Text Fader
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
I attempted to Write a Unit For Text FADING, but I don't have it all down
right...  If any one wants to play With the Unit and perfect it I would not
mind!  My problem is that I do not know the correct values to change in the
color register For the affect of a fade.  Once all the values are 0 the screen
is black, but on the way there the screen gets some strange colors... Also, if
you know how to change the colors, you can implement your own custom colors for
Text mode.  I think 256 different colors, but only 16 at a time. (I am only
guessing at that last part).   The FADEOUT and FADEIN does work here, but it
goes through some strange colors on the way!

Robert
}

Unit TextFade; {attempt For implementing Text fading}
{ only works For VGA or SVGA as Far as I know! }

Interface

Uses Dos, Crt;

Type
  ColorRegister =
  Record
    Red      : Byte;
    Green    : Byte;
    Blue     : Byte;
  end;

  ColorRegisterArray    = Array[0..255] of ColorRegister;
  ColorRegisterArrayPtr = ^ColorRegisterArray;

Var
  SaveCRAp      : ColorRegisterArrayPtr;

Procedure SaveColorRegister(Var CRAp : ColorRegisterArrayPtr);
{ given a color register Array ptr, this will save the current }
{ values so you can restore from them later...                 }

Procedure SetColorRegister(Var CRAp : ColorRegisterArrayPtr);
{ when you adjust the values of a color register set, this     }
{ Procedure will make put the new values into memory           }

Procedure FadeOut(MS_Delay : Integer);
{ using the global Variable 'SaveCRAp', this will fade the Text}
{ screen out till all the values in the color register Array   }
{ ptr are 0                                                    }

Procedure FadeIn(MS_Delay : Integer);
{ once again using the global Variable 'SaveCRAp', this will   }
{ fade the screen back in till all values of the current color }
{ register Array ptr are equal to 'SaveCRAp'                   }

Implementation

Procedure Abort(Msg : String);
begin
  Writeln(Msg);
  Halt(1);
end;

Procedure SaveColorRegister(Var CRAp : ColorRegisterArrayPtr);
Var
  R : Registers;
begin
  With R Do
  begin
    ah := $10;
    al := $17;
    bx := $00;
    cx := 256;
    es := Seg(crap^);
    dx := Ofs(crap^);
  end;
  Intr($10,r);
end;

Procedure SetColorRegister(Var CRAp : ColorREgisterArrayPtr);
Var
  R : Registers;
begin
  With R Do
  begin
    ah := $10;
    al := $12;
    bx := $00;
    cx := 256;
    es := Seg(crap^);
    dx := Ofs(crap^);
  end;
  Intr($10,r);
end;

Procedure FadeOut(MS_Delay : Integer);
Var
  NewCRAp : ColorRegisterArrayPtr;
  W       : Word;
  T       : Word;
begin
  New(NewCRAp);
  If NewCRAp = NIL Then
    Abort('Not Enough Memory');
  NewCrap^ := SaveCrap^;
  For T := 1 to 63 Do
  begin
    For W := 0 to 255 Do
    With NewCRAp^[w] Do
    If Red + Green + Blue > 0 Then
    begin
      Dec(Red);
      Dec(Green);
      Dec(Blue);
    end;
    SetColorRegister(NewCRAp);
    Delay(MS_Delay);
  end;
end;

Procedure FadeIn(MS_Delay : Integer);
Var
  NewCRAp : ColorRegisterArrayPtr;
  W       : Word;
  T       : Word;
begin
  New(NewCRAp);
  If NewCRAp = Nil Then
    Abort('Not Enough Memory');
  FillChar(NewCRAp^,SizeOf(NewCRAp^),0);
  For T := 1 to 63 Do
  { The values in the color register are not higher than 63 }
  begin
    For W := 0 to 255 Do
    If SaveCRAp^[w].Red + SaveCRAp^[w].Green + SaveCRAp^[w].Red > 0 Then
    begin
      If NewCRAp^[w].Red   < SaveCRAp^[w].Red Then
        Inc(NewCRAp^[w].Red);
      If NewCRAp^[w].Green < SaveCRAp^[w].Green Then
        Inc(NewCRAp^[w].Green);
      If NewCRAp^[w].Blue  < SaveCRAp^[w].Blue Then
        Inc(NewCRAp^[w].Blue);
    end;
    SetColorRegister(NewCRAp);
    Delay(MS_Delay);
  end;
end;


begin
  New(SaveCRAp);
  {get memory For the Pointer}
  If SaveCRAp = Nil Then Abort('Not Enough Memory');
  {make sure it actually got some memory}
  SaveColorRegister(SaveCRAp);
  {save the current values into SaveCRAp}
end.

---------------8<-----cut here------>8---------

Here is a demo of how to use it...


Uses TextFADE;

begin
   FADEOUT(10);
   WriteLN(' HOW DOES THIS LOOK');
   FADEIN(10);
   Dispose(SaveCRAp);
   {I just Realized I never got rid of this Pointer before!}
end.

