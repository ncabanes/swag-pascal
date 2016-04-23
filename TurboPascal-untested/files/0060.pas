{
> In my program I create some temporary files, but I like to delete them
> before my program is finished.

Here, the assembly code:
}

Function DeleteFile(FileName : string) : integer; assembler;
{ Deletes an external file.
    Returns: 0 if successful, non-zero DOS error code otherwise. }
Asm
  push ds
  lds si,FileName
  inc byte ptr [si]
  mov bl,byte ptr [si]
  xor bh,bh
  mov dx,si
  inc dx
  mov byte ptr [si+bx],0
  mov ah,41h
  int 21h
  jc  @error
  xor ax,ax
@error:
  dec byte ptr [si]
  pop ds
End; { DeleteFile }

var
  Result : integer;
  Path : string;

Begin
  Path := 'C:\AUTOEXEC.BAK';
  Write('Attempting to delete ', Path, '... ');
  Result := DeleteFile(Path);
  if Result = 0 then
    WriteLn(#13, Path, ' successfully deleted.  ')
  else
    WriteLn(#13'Unable to delete ', Path, '. DOS error ', Result, ' occured.')
End.
