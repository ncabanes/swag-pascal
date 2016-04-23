Function LastDrive: Char; Assembler;
Asm
  mov   ah, 19h
  int   21h
  push  ax            { save default drive }
  mov   ah, 0Eh
  mov   dl, 19h
  int   21h
  mov   cl, al
  dec   cx
@@CheckDrive:
  mov   ah, 0Eh       { check if drive valid }
  mov   dl, cl
  int   21h
  mov   ah, 19h
  int   21h
  cmp   cl, al
  je    @@Valid
  dec   cl            { check next lovest drive number }
  jmp   @@CheckDrive
@@Valid:
  pop   ax
  mov   dl, al
  mov   ah, 0Eh
  int   21h           { restore default drive }
  mov   al, cl
  add   al, 'A'
end;


(*
LastDrive will return letter of the last valid drive. To check
if the drive letter entered is valid:

if Upcase(DriveLetter) <= LastDrive
   then {valid drive}
   else {bad drive};
*)