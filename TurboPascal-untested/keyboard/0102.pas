
{

  This program example can replace the ReadKey Function and can
  be used in the same way.  However it does require an AT extended
  keyboard and might be unpredictable if used with a non extended
  keyboard.  This code also requires that you define a global variable
  called ScanCode of type char.  This is important in determining
  whether the key is a standard or extended type.

  Borland Technical Support releases example code to help demonstrate
  common programming usage.  Since this is not a commercial product,
  Borland does not provide technical support for these demonstration
  programs or offer any warranty.

}

program ReadExtendedKey;

var
ScanCode:char;   { Make this a global variable }

function ReadExtKey:byte;
var C:byte;
begin
asm
	MOV	AL,ScanCode
	MOV	ScanCode,0
	OR	AL,AL
	JNE	@@1
	MOV	AH,$10
	INT	16H
	OR	AL,AL
	JNE	@@1
	MOV	ScanCode,AH
	OR	AH,AH
	JNE	@@1
	MOV	AL,'C'-64
@@1:    MOV     C, AL

end;
  ReadExtKey := C;
end;

var
  ch1:byte;
begin
  write('Please enter a key -> ');
  ch1:= ReadExtKey;
  if ch1=0 then  { Received an extended key }
  begin
    writeln(ch1);
    write('Extended Key -> ');
    ch1:= ReadExtKey; { Get the extended key }
  end;
  writeln(ch1);
end.
