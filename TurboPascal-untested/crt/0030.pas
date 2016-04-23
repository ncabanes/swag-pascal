{
 IL>> Will it read the extended function keys?

 JS>  Nope, DOS doesn't read functions keys.. But it reads through piped
 JS> commands eg: echo hi | proggy

No, let me join this discussion and clear things abit. Actually, DOS *DOSE*
enable reading keyboard including extended keys like F10, Alt-X, cursor-left.
And it even reads F11, F12 keys so why not to use these routines? I am really
wondering, why i have never seen any BBS software that would react specifically
on extended keys, for example on arrow keys? That would allow users to use REAL
menus online! Little ANSI gfx plus extended key reading would be nice, but i
haven't seen any software that enables moving a menu item by pressing the
cursor keys...
Actually, the following is a ReadKey function that i use instead of standard
Crt.ReadKey:
}

const
  { sample standard key codes }
  keySpace         = $2000;
  keyEscape        = $1B00;
  { sample extendedd key codes }
  keyAltF1         = $0068;
  keyAltX          = $002D;

Function ReadKey : word; assembler;
{ Uses function 08h/Int 21h to read from keyboard }
Asm
  mov ah,08h
  int 21h
  xor dl,dl
  mov dh,al
  or  al,0 { extended keystroke? }
  jnz @@1  { no, get out }
  int 21h  { yes, read extended scan code, F11, F12 supported }
  mov dl,al
@@1:
  mov ax,dx
End; { ReadKey }
