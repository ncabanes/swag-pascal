(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0065.PAS
  Description: File Attribute (BASM)
  Author: ANDREW EIGUS
  Date: 08-24-94  13:37
*)

{
 EH> I am looking for a way to determine a filehandles' attributes, like is
 EH> possible in OS/2.

 EH> The attributes I like to query (and maybe set), are the standard-file
 EH> attribs. Still I cannot find a way to get to them except with the
 EH> filename, and a dos interrupt. What I am looking for is a dos interrupt
 EH> that does exactly the same, but uses a filehandle instead of a filename.

No no no, file attributes can be returned/set only via DOS function 43h that
assumes DS:DX point to a ASCIIZ file name. :(

  { File attributes (combine these when setting) }

  faNormal         = $0000;
  faReadOnly       = $0001;
  faHidden         = $0002;
  faSysFile        = $0004;
  faVolumeID       = $0008;
  faDirectory      = $0010;
  faArchive        = $0020;
  faAnyFile        = $003F;

Function GetFileAttr(FileName : PChar) : integer; assembler;
{ Retrieves the attribute of a given file. The result is returned by DosError }
Asm
  MOV DosError,0
  PUSH DS
  LDS DX,FileName
  MOV AX,4300h
  INT 21h
  POP DS
  JNC @@noerror
  MOV DosError,AX { save error code in DOS global variable }
@@noerror:
  MOV AX,CX
End; { GetFileAttr }

Procedure SetFileAttr(FileName : PChar; Attr : word); assembler;
{ Sets the new attribute to a given file. The result is returned by DosError }
Asm
  MOV DosError,0
  PUSH DS
  LDS DX,FileName
  MOV CX,Attr
  MOV AX,4301h
  INT 21h
  POP DS
  JC  @@noerror
  MOV DosError,AX
@@noerror:
End; { SetFileAttr }

