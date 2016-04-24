(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0102.PAS
  Description: Direct DOS File Functions
  Author: VIKTOR OSTASHEV
  Date: 05-31-96  09:16
*)

{$x+}

unit dosfile;

interface

var
     ferror              : word;
{
DOS error
}


function fopen(name : string; mode : char) : word;
{
name - filename (with path), mode - r - read, w - write, + - r/w,
a - append.
return: handle or $ffff if error
If file opened for write or append and don't exist, then create it
If file opened for write, truncated it to pos 0
}

function fclose(handle : word) : boolean;
{
Close file. If error then return FALSE
}

function fseek(handle : word; offset : longint; mode : byte) : boolean;
{
Seek file pointer to offset bytes
mode 0 - from begin 1 - from current 2 - from end
}

function fread(handle, count : word; dest : pointer) : boolean;
{
Read count bytes to dest buffer
}

function fwrite(handle, count : word; sourc : pointer) : boolean;
{
Write count bytes from sourc buffer
}

function fflush(handle : word) : boolean;
{
Flush file
}

implementation

     function fopen;
     var
          asciiz              : array[0..255] of char;
          i, acs              : byte;
          nptr                : pointer;
          hnd                 : word;
     begin
          for i := 0 to ord(name[0]) do asciiz[i] := name[i+1];
          asciiz[ord(name[0])] := #0;
          nptr := @asciiz;
          ferror := 0;
          case mode of
               'r' : acs := 0;
               'w' : acs := 1;
               '+' : acs := 2;
               'a' : acs := 1;
          end;
          asm
               cmp  mode, 'w'
               je   @trunc
               push ds
               push dx
               mov  ah, 3Dh
               mov  al, acs
               lds  dx, nptr
               int  21h
               pop  dx
               pop  ds
               jnc  @noerr
               cmp  mode, 'a'
               jne  @err
               cmp  ax, 0002h
               jne  @err
               @trunc:
               push ds
               push dx
               push cx
               xor  cx, cx
               mov  ah, 3Ch
               lds  dx, nptr
               int  21h
               pop  cx
               pop  dx
               pop  ds
               jnc  @noerr
               @err:
               mov  ferror, ax
               mov  ax, 0FFFFh
               @noerr:
               mov  hnd, ax
          end;
          if (mode = 'a') and (ferror = 0) then fseek(hnd, 0, 2);
          fopen := hnd;
     end;

     function fclose; assembler;
     asm
          push bx
          mov  ferror, 0
          mov  bx, handle
          mov  ah, 3Eh
          int  21h
          mov  bx, ax
          mov  ax, 01h
          jnc  @noerr
          mov  ferror, bx
          xor  ax, ax
          @noerr:
          pop  bx
     end;

     function fseek;
     type
          tlong = record
                       case boolean of
                            true : (long : longint);
                            false : (lword, hword : word);
                  end;
     var
          offs                : tlong;
     begin
          offs.long := offset;
          ferror := 0;
          asm
               push bx
               push cx
               push dx
               mov  ah, 42h
               mov  al, mode
               mov  bx, handle
               mov  cx, offs.hword
               mov  dx, offs.lword
               int  21h
               jnc  @noerr
               mov  ferror, ax
               @noerr:
               pop  dx
               pop  cx
               pop  bx
          end;
          if ferror = 0 then fseek := true
                        else fseek := false;
     end;

     function fread; assembler;
     asm
          push bx
          push cx
          push dx
          push ds
          mov  ferror, 0
          mov  ah, 3Fh
          mov  bx, handle
          mov  cx, count
          lds  dx, dest
          int  21h
          pop  ds
          jnc  @noerr
          mov  ferror, ax
          xor  ax, ax
          @noerr:
          pop  dx
          pop  cx
          pop  bx
     end;

     function fwrite; assembler;
     asm
          push bx
          push cx
          push dx
          push ds
          mov  ferror, 0
          mov  ah, 40h
          mov  bx, handle
          mov  cx, count
          lds  dx, sourc
          int  21h
          pop  ds
          jnc  @noerr
          mov  ferror, ax
          xor  ax, ax
          @noerr:
          pop  dx
          pop  cx
          pop  bx
     end;

     function fflush; assembler;
     asm
          push bx
          mov  ferror, 0
          mov  ah, 68h
          mov  bx, handle
          int  21h
          mov  bx, ax
          mov  ax, 0001h
          jnc  @noerr
          mov  ferror, bx
          xor  ax, ax
          @noerr:
          pop  bx
     end;
end.

