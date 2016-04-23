
Function FileExists(FileName : string) : boolean; assembler;
{ Determines whether the given file exists. Returns true if the file was found,
  false - if there is no such file }
Asm
  PUSH DS
  LDS DX,FileName
  INC DX
  MOV AX,4300h  { get information through the GetAttr function }
  INT 21h
  MOV AL,False { emulate AL=0 }
  JC  @@1
  INC AL { emulate AL=AL+1=1 }
@@1:
  POP DS
End; { FileExists }

const Found : array[Boolean] of string[10] = ('not found', 'found');
var FileName : string;

Begin
  Write('Enter file name to search: ');
  ReadLn(FileName);
  WriteLn('File "', FileName, '" ', Found[FileExists(FileName)], '.');
End.
