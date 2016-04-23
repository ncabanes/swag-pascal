{
To change the cursor do the following:

set ah=1
set up ch as follows
    bit 7 = 0
    bits 6,5 = cursor blink :
                  00 = normal
                  01 = invisible
                  10 = erratic
                  11 = slow
                  * On EGA/VGA, anything other than 00 = invisible
    bits 0-4 = top scan line for cursor
setup cl as follows:
    bits 0-4 = bottom scan line
call  int $10

A normal underline cursor starts at scan line 6 and ends at line 7, so for
that:
}
procedure underline_cursor; assembler;

asm
   mov ah,1    {Set ah=1}
   mov ch,6    {Set ch=6}
   mov cl,7    {Set cl=7}
   int 10h     {Call int $10} 
end; 
 
For an invisible cursor simply set the 5th bit of ch: 
 
procedure cursor_off; assembler; 
 
asm 
   mov ah,1    {Set ah=1} 
   mov ch,26h  {Set ch=$26 or 00100110 in binary} 
   mov cl,7    {Set cl=7} 
   int 10h     {Call int $10}
end; 

