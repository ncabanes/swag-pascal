(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0039.PAS
  Description: VGA-PTR.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{    Make a Pointer, make a Type of the data Type you are dealing with, make as
many Pointers as you will need data segments (or as commonly practiced amongst
the Programming elite, make an linked list of the data items), and call the
GETMEM Procedure using the Pointer in the Array... Here is an example I use to
copy VGA (320x200x256) screens...
}

Type
    ScreenSaveType = Array[0..TheSize] of Byte;
Var
   TheScreen                    : ScreenSaveType Absolute $A000:0000;
   Screen                       : Array[1..100] of ^ScreenSaveType;

begin
     InitGraphics;
     Count := 0;

     Repeat
           Count := Count + 1;
           GetMem(Screen[Count],Sizeof(ScreenSaveType));
           WriteLn('Memory at Screen ',Count,' : ',MemAvail); {THIS MAKES
                                                               THE PAGES}
     Until MemAvail < 70000;
     For X := 1 to Count do
         For A := 1 to TheSize do                   {THE MAKES A SCREEN}
             Screen[X]^[A] := Random(255);
     E := C;
     X := 0;
     GetTime(A,B,C,D);
     C2 := 0;

     Repeat
           X := X + 1;
           GetTime(A,B,C,D);
           if C <> E then
              begin
              C2 := C2 + 1;
              testresults[C2] := X;
              X := 1;
              E := C;
              end;
     TheScreen := Screen[X mod Count + 1]^;
     Move(Scroll2,Scroll1,Sizeof(Scroll2));
     Until KeyPressed;
     WriteLn(Test,'Number of Screens :',Count);
     For X := 1 to C2 do
         WriteLn(Test,'Number of flips, second #',X,':',testresults[x]);
     Close(Test);
end.

{    I didn't try and Compile that, I also edited out the Procedure
initGraphics because you aren't Really interested in that end. However where
it says "THIS MAKES THE PAGES" is what you want to do.. In this particular
version I made 4 Graphics pages under pascal and 5 outside of pascal, I could
have fit more but I have too many TSRS. Using Extended memory I can fit about
20 Graphics pages (I got about 2 megs ram), but you can extend that as Far as
ram may go. The MOVE command isn't a bad command either to know. I got when
running a Text mode, 213 Text pages per second. I was even impressed (PS
Graphics people, I got 16 Graphics pages per second in 320x200x256 mode!)...
}

