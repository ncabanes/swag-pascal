
Unit ICheck; {Installation Checks}

{Author: Salvatore Meschini - WWW: http://www.ermes.it/pws/mesk -
E-Mail: smeschini@ermes.it - INFORMATION SOURCE := RALF BROWN INT. LIST R51}
{tHIS uniT Is FReeWARe}

Interface

Function Is4Dos : Boolean;      {4DOS Shell Replacement}
Function IsAnsiSys : Boolean;   {Ansi.sys}
Function IsAppend : Boolean;    {Append.exe}
Function IsAssign : Boolean;    {Assign.com}
Function IsCritError : Boolean; {Critical Error Handler}
Function IsDblSpace : Boolean;  {Dblspace.Bin}
Function IsDesqView : Boolean;  {Desqview}
Function IsDos4G : Boolean;     {Dos/4G PMode}
Function IsDoskey : Boolean;    {Doskey.com}
Function IsDoubleDos : Boolean; {DoubleDos}
Function IsDriverSys : Boolean; {Driver.sys}
Function IsEmm386 : Boolean;    {Emm386}
Function IsEms : Boolean;       {EMS Driver loaded?}
Function IsGrafTabl : Boolean;  {Graftabl.com}
Function IsKeyb : Boolean;      {Keyb.com}
Function IsMouse : Boolean;     {Mouse driver present?}
Function IsNG : Boolean;        {Norton Guides}
Function IsNlsFunc : Boolean;   {Nlsfunc.exe}
Function IsShare : Boolean;     {Share.exe}
Function IsSmartDrv : Boolean;  {Smartdrive}
Function IsSrdisk : Boolean;    {Srdisk ramdisk driver 1.30+}
Function IsTHelp : Boolean;     {Thelp.com}
Function IsXms : Boolean;       {XMS driver loaded?}
Function IsWinEnh : Boolean;      {Windows Enhanced}

implementation

Function  Is4dos : Boolean;Assembler;
 asm
    MOV AX, 0D44DH
    XOR BX,BX
    INT 2FH
    CMP AX,44DDH
    JE  @OK
    MOV AL,0
    JMP @END
    @OK: MOV AL,1
    @END:
 end;

Function  IsAnsiSys : Boolean;Assembler;
 asm
  MOV AX,1A00H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsAppend : Boolean;Assembler;
 asm
  MOV AX,0B700H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsAssign : Boolean;Assembler;
 asm
   MOV AX,0600H
   INT 2FH
   CMP AL,0FFH
   JE  @OK
   MOV AL,0
   JMP @END
   @OK: MOV AL,1
   @END:
 end;

Function  IsCritError : Boolean;Assembler;
 asm
  MOV AX,0500H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsDblSpace : Boolean;Assembler;
 asm
  MOV AX,4A11H
  XOR BX,BX
  INT 2FH
  CMP AX,0
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsDesqView : Boolean;Assembler;
 asm
  MOV AH,2BH
  MOV CX,4445H
  MOV DX,5351H
  MOV AL,1
  INT 21H
  CMP AL,0FFH
  JE  @NOTINST
  MOV AL,1
  JMP @END
  @NOTINST: MOV AL,0
  @END:
 end;

Function  IsDos4G : Boolean;Assembler;
 asm
  MOV AX, 0FF00H
  MOV DX,0078H
  INT 21H
  CMP AL,0
  JNE @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsDosKey : Boolean;Assembler;
 asm
  MOV AX,4800H
  INT 2FH
  CMP AL,0
  JNE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsDoubleDos : Boolean;Assembler;
 asm
  MOV AX,0E400H
  INT 21H
  CMP AL,0
  JNE @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsDriverSys : Boolean;Assembler;
 asm
  MOV AX,0800H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsEmm386 : Boolean;Assembler;
 asm
  MOV AX,0FFA5H
  INT 67H
  CMP AX,845AH
  JNE @SECCMP
  @OK:
  MOV AL,1
  JMP @END
  @SECCMP:
  CMP AX,84A5H
  JE @OK
  XOR AL,AL
  @END:
 end;

Function  IsEMS : Boolean;Assembler;
 asm
  MOV AH,46H
  INT 67H
  CMP AH,00H
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsGrafTabl : Boolean;Assembler;
 asm
  MOV AX,0B000H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsKeyb : Boolean;Assembler;
 asm
  MOV AX,0AD80H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsMouse : Boolean;Assembler;
 asm
  XOR AX,AX
  INT 33H
  CMP AX,0FFFFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsNG : Boolean;Assembler;
 asm
  MOV AX,0F398H
  INT 16H
  CMP AX,6A73H
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsNlsFunc : Boolean;Assembler;
 asm
  MOV AX,1400H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsShare : Boolean;Assembler;
 asm
  MOV AX,1000H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsSmartDrv : Boolean;Assembler;
 asm
  MOV AX,4A10H
  MOV BX,0
  MOV CX,0EBABH
  INT 2FH
  CMP AX,0BABEH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsSrdisk : Boolean;Assembler;
 asm
  MOV AX,7200H
  INT 2FH
  CMP AL,0FFH
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsThelp : Boolean;Assembler;
 asm
  MOV AX,0CAFEH
  XOR BX,BX
  INT 2FH
  CMP BX,0
  JNE @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsXMS: Boolean;Assembler;
 asm
  MOV AX, 4300H
  INT 2FH
  CMP AL,80H
  JE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

Function  IsWinEnh : Boolean;Assembler;
 asm
  MOV AX,1600H
  INT 2FH
  CMP AL,0
  JnE  @OK
  MOV AL,0
  JMP @END
  @OK: MOV AL,1
  @END:
 end;

end.

{------------------------------- DEMO --------------------------------}

Program TestICheck; {WARNING: I DON'T KNOW IF ALL CHECKS WORKS CORRECTLY!!!}

uses Icheck;

procedure ClrScr; assembler;
asm
 mov ah,0Fh
 int 10h
 xor ah,ah
 int 10h;
end;

Function Readkey : Char;

var AsciiK:byte;

begin
asm
 xor ah,ah
 int 16h
 mov asciik,al
end;
 readkey:=chr(asciik);
end;


Procedure Present;
 begin
  writeln(#251);
 end;

Procedure NotPresent;
 begin
  writeln('-');
 end;

begin
clrscr;
write('4DOS '); if is4dos then present else notpresent;
write('ANSI.SYS '); if isansisys then present else notpresent;
write('APPEND.EXE '); if isappend then present else notpresent;
write('ASSIGN.COM '); if isassign then present else notpresent;
write('CRITICAL ERROR HANDLER '); if iscriterror then present else notpresent;
write('DBLSPACE '); if isdblspace then present else notpresent;
write('DESQVIEW '); if isdesqview then present else notpresent;
write('DOS/4G '); if isdos4g then present else notpresent;
write('DOSKEY '); if isdoskey then present else notpresent;
write('DOUBLEDOS '); if isdoubledos then present else notpresent;
write('DRIVER.SYS '); if isdriversys then present else notpresent;
write('EMM386 '); if isemm386 then present else notpresent;
write('EMS ');if isems then present else notpresent;
write('GRAFTABL '); if isgraftabl then present else notpresent;
write('KEYB.COM '); if iskeyb then present else notpresent;
write('MOUSE '); if ismouse then present else notpresent;
write('NORTON GUIDES '); if isng then present else notpresent;
write('NLSFUNC.EXE '); if isnlsfunc then present else notpresent;
write('SHARE.EXE '); if isshare then present else notpresent;
write('SMARDRIVE '); if issmartdrv then present else notpresent;
write('SRDISK '); if issrdisk then present else notpresent;
write('THELP '); if isthelp then present else notpresent;
write('XMX '); if isxms then present else notpresent;
write('WINDOWS ENHANCED ');if iswinenh then present else notpresent;
readkey;
end.

