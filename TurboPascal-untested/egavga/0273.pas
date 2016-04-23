{
VMode
-----

Allows you to select your own mode to work in, could be very handy
if you can access the 132 x 25, 50 modes etc that SVGA supports.

Just imagine using DIR and seeing a whole directory on one page!


Usage:

VMODE <video mode>

Where video mode is a number in the range of 0 to 127.

}

Procedure Usage;
Begin
     Writeln;
     Writeln('VMODE, (C) 1995 Scott Tunstall.');
     Writeln;
     Writeln('Usage :');
     Writeln;
     Writeln('VMODE [FORCE] <Video Mode required>');
     Writeln;
     Writeln('Where Video Mode can be one of the following :');
     Writeln('      1 :  80 x 25');
     Writeln('      2 : 132 x 25 (8 x 16 character size)');
     Writeln('      3 : 132 x 43 (8 x 8 character size)');
     Writeln('      4 : 132 x 25 (8 x 14 character size)');
     Writeln;
     Writeln('If your favourite video mode is not here you may force');
     Writeln('it by using FORCE as the first parameter then the video');
     Writeln('mode number as the second. (A list of all video mode');
     Writeln('numbers should have come with your graphics card).');
     Writeln;
     Writeln('For example, to force graphics mode 93 which is the');
     Writeln('1024 x 768 x 16 colour mode, you would type :');
     Writeln;
     Writeln('VMODE FORCE 93');
     Writeln;
End;


{
I'm sorry for including the expletive, but if you have problems with
using this program then really you must be really stupid.
}

Procedure YouArecluckingStupid;
Begin
     Writeln;
     Writeln('Incorrect number of parameters ! Only 2 MAXIMUM allowed.');
     Writeln;
End;



{
This procedure is called if their are two parameters and the
first parameter is not FORCE.. This routine has to be here because
I'll probably add more command line parameters as time goes on.
}

Procedure ErrorInFirstParameter;
Begin
     Writeln;
     Writeln('Error in the first parameter .. FORCE expected !');
     Writeln;
End;



{
Set the desired video mode.

ModeWantedAsString is the string representation of the desired mode,
for example if you wanted mode 93 you pass in '93'. Easy eh? This
is here so that if I change the function of the parameters later
it'll still be easy to interface (?!!)

Oh, damn. Why do I bother ?
}

Procedure GoIntoVideoMode(ModeWantedAsString:String);
Var ModeNumber,
    ErrorPosition: Integer;

Begin
     Val(ModeWantedAsString,ModeNumber,ErrorPosition);
     If ErrorPosition = 0 Then
        Begin
        If (ModeNumber >-1) and (ModeNumber< 128) Then
           Asm
           MOV AX,ModeNumber    { Mode number is an integer }
           INT $10              { Video mode set by AL }
           End
        Else
            Begin
            Writeln;
            Writeln('Cannot set this video mode, video mode number');
            Writeln('MUST be in the range of 0-127 ! .');
            Writeln;
        End;
        End
     Else
         Begin
         Writeln('Cannot set video mode - second parameter is not numeric !');
         Writeln;
     End;
End;


{
A nice 'n' easy routine here. Pass in the video mode ya want
as a short integer and the computer'll set the video mode,
if it supports it that is.
}

Procedure UseVideoMode(VideoModeNumber: shortint); Assembler;
Asm
   XOR AH,AH                    { Function 0 = Set Video Mode }
   MOV AL, VideoModeNumber      { Load AL with mode wanted }
   INT $10                      { Execute Video interrupt }
End;


{
Convert a string to it's upper case equivalent. TheString is
a string of any length less than 256 characters, and on exit
the string var passed in is now entirely uppercase! Good eh?
}

Procedure ConvertToUpCase(Var TheString: String);
Var Count: byte;
Begin
     for Count := 1 to Length(TheString) do
         TheString[Count] := UpCase(TheString[Count]);
End;




{
Check what option the user has selected. (And of course, if
the option is valid)
}


Procedure CheckVideoModeOptions;
Var FirstParam: string;
    VideoModePresetNum: byte;
    ErrorPosition: integer;
Begin
     If ParamCount = 2 Then
        Begin
        FirstParam:=ParamStr(1);
        ConvertToUpCase(FirstParam);

        {
        I'll probably add extra parameters later.
        }

        If FirstParam = 'FORCE' Then
           GoIntoVideoMode(ParamStr(2))
        Else
            ErrorInFirstParameter;


        End
     Else
         Begin
         Val(ParamStr(1),VideoModePresetNum,ErrorPosition);
         Case VideoModePresetNum Of
              1 : UseVideoMode(3);
              2 : UseVideoMode(20);
              3 : UseVideoMode(84);
              4 : UseVideoMode(85);
         Else
             Begin
             Writeln;
             Writeln('Can''t set mode - Preset number is unsupported !');
             Writeln;
         End;

         End;
     End;
End;





{
The main program.

If no parameters are passed, then it is assumed that the user wants
to see the instructions for use.

If there is 1 parameter, then it is assumed that the user wants
to use a preset text mode in the range of 1 - 4 .

If there are two parameters, then the first parameter must be checked,
and acted on appropriately to determine an action. Currently only 1
option type exists, "FORCE". The second parameter, with FORCE,
specifies the video mode to set.

}

Begin
     If ParamCount = 0 Then
        Usage
     Else
         If ParamCount >2 Then
            YouArecluckingStupid
         Else
             CheckVideoModeOptions;
End.

