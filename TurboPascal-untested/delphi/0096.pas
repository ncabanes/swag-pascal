{
You can very simply play WAV files using the sndPlaySound
function in the MMSYSTEM.DLL library. The tricky bit is in
passing the filename to the function, which requires a
null-terminated string. The little routine below converts
the filename to an array of characters, which sndPlaySound
is happy with.

Freeware, have fun!
}

Add 'MMSystem' to Uses.

Add 'procedure PlaySound(WavFileName: String);' to declarations.

Add the code below to Implementation.

procedure MyForm.PlaySound(WavFileName: String);
var
   s: Array[0..79] of char;
begin
{Convert filename to a null-terminated string}
StrPCopy(s, WavFileName);
{Play the sound asynchronously}
sndPlaySound(s, 0); {see mmsystem.hlp for other values}
end;
