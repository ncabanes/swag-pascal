{
I have not found this type of unit in the SWAG and thought you might
wish to include it. It has been useful to me.

Brent Herring
Systems Analyst
University of Central Arkansas
brenth@cc1.uca.edu
}

Unit RunTime;

{
  Including this unit in your program should replace all the runtime
  errors with messages that are a bit more helpful than "Runtime
  error 202". Especially helpful when trying to help someone else
  debug a program that you wrote (as if you would write a program
  with a mistake).
}

INTERFACE

Function Hex(Value:byte):string;

IMPLEMENTATION

var OldExit:pointer;

{====================================================================}
Function Hex(Value:byte):string;

const HexTable:array[0..15] of Char=('0','1','2','3','4','5','6','7',
                                     '8','9','A','B','C','D','E','F');

var HexStr : string;

begin
  HexStr[2]:=HexTable[Value and $0F];        { Convert low nibble }
  HexStr[1]:=HexTable[Value and $F0 div 16]; { Convert high nibble }
  HexStr[0]:=#2; { Set Stringlength }
  Hex:=HexStr;
end;
{====================================================================}
{ Try to handle all possible errors }

Procedure RunTimeExitProc;Far;

var Message : string;

begin
  if ErrorAddr<>Nil then { If error occurs }
    begin
        case ExitCode of { Pick the appropriate message }
            2:Message:='File not found ';
            3:Message:='Path not found ';
            4:Message:='Too many open files ';
            5:Message:='File access denied ';
            6:Message:='Invalid file handle ';
            8:Message:='Insufficient memory ';
           12:Message:='Invalid file access code ';
           15:Message:='Invalid drive number ';
           16:Message:='Cannot remove current directory ';
           17:Message:='Cannot rename across drives ';
          100:Message:='Disk read error ';
          100:Message:='Disk write error ';
          102:Message:='File not assigned ';
          103:Message:='File not open ';
          104:Message:='File not open for input ';
          105:Message:='File not open for output ';
          106:Message:='Invalid numeric format ';
          150:Message:='Disk is write-protected ';
          151:Message:='Unknown unit ';
          152:Message:='Drive not ready ';
          153:Message:='Unknown command ';
          154:Message:='CRC error in data ';
          155:Message:='Bad drive request structure length ';
          156:Message:='Disk seek error ';
          157:Message:='Unknown media type ';
          158:Message:='Sector not found ';
          159:Message:='Printer out of paper ';
          160:Message:='Device write fault ';
          161:Message:='Device read fault ';
          162:Message:='Hardware failure ';
          200:Message:='Division by zero ';
          201:Message:='Range check error ';
          202:Message:='Stack overflow error ';
          203:Message:='Heap overflow error ';
          204:Message:='Invalid pointer operation ';
          205:Message:='Floating-point overflow ';
          206:Message:='Floating-point underflow ';
          207:Message:='Invalid floating-point operation ';
          208:Message:='Overlay manager not installed ';
          209:Message:='Overlay file read error ';
          210:Message:='Object not initialized ';
          211:Message:='Call to abstract method ';
          212:Message:='Stream register error ';
          213:Message:='Collection index out of range ';
          214:Message:='Collection overflow error ';
        end;
      writeln('Error:',ExitCode,
              'Segment:',Hex(seg(ErrorAddr^)),
              ' Offset:',Hex(ofs(ErrorAddr^)),
              ' ',Message);
      ErrorAddr:=nil;
      ExitCode:=1;   { End program with errorlevel 1 }
    end;
  ExitProc:=OldExit; { Restore the original exit procedure }
end;
{====================================================================}
begin
  OldExit:=ExitProc;          { Save the original exit procedure }
  ExitProc:=@RunTimeExitProc; { Insert the RunTime exit procedure }
end.
