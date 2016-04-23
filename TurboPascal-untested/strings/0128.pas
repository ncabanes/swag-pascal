{
I think your function goes about the speed of mine. This function
will check if the two strings are larger than 255, and will skip
either the first or second string if either of them are null. I think
I've whittled it down enough to post it here:
}
function strcont(s1,s2:string):string; assembler;
asm
 push ds
 cld
 lds si,s1         {Load addresses of s1}
 les di,s2         {Load addresses of s2}
 xor ah,ah         {Clear ah & bh}
 xor bh,bh         {     ""      }
 mov al,ds:[si]    {Get the length of first string, copy into al}
 mov bl,es:[di]    {Get the length of second string, copy into bl}
 add ax,bx         {Add length of s1 to length s2}
 cmp ax,255        {Compare}
 ja @toolarge      {Jump to @toolarge if length(s1)+length(s2)>255}
 les di,@result    {Copy location of @result into es:di}
 mov cl,1          {Make sure at least one byte of beginning string}
 xor ch,ch         {is transferred to @result.}
 add cl,ds:[si]    {Add length of string to cl.}
 rep movsb         {Copy first string into @result}
 lds si,s2         {Get address of second string}
 mov cl,ds:[si]    {Get length of second string, copy into cl}
 cmp cl,0          {If second string is blank, skip adding it.}
 je @end           {Jump to end if length of second string is zero.}
 inc si            {Move pointer (si) to start of second string}
 mov al,cl         {Save length of second string in al}
 rep movsb         {Copy second string into @result}
 lds si,@result    {Get location of @result}
 add ds:[si],al    {Add lengths together}
 jmp @end          {Skip to @end}
@toolarge:         {If added strings total larger than 255, this sub}
 les di,@result    {is called.}
 xor al,al         {Make sure al is a zero.}
 mov es:[di],al    {Move a "0" into the beginning of @result, making it}
@end:               {a null string.}
 pop ds            {Return DS to normal so Pascal doesn't screw up.}
end;

