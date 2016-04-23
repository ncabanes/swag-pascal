{
> I'd like to do left & right screen scrolling, like the INT 10 functions
> for up & down screen scrolling.
}

procedure scroll_left(x1,y1,x2,y2:byte); assembler; 
 
asm 
   mov al,[y1]     {put y1 coordinate in al} 
   xor ah,ah       {set ah to 0 so we can deal with ax} 
   mov bx,80       {set bx=80} 
   mul bl          {multiply by bl, which equals 80 by the previous statement} 
   mov bl,[x1]     {put x1 coordinate in bl} 
   add ax,bx       {add the x1 coord. to y1*80 since there are 80 cols in a row
   shl ax,1        {multiply by 2 because info is stored as words, attribute 
                    in the high byte and the ASCII code for the character in 
                    the low byte} 
   mov si,ax       {all this calculated the offset in video memory of the
upper}                    {left-hand corner, which is put in si for later use} 
   mov al,[x2]     {put x2 coord. in al} 
   xor ah,ah       {set ah=0 so we can deal with ax} 
   sub al,bl       {subtract bl, which still contains x1, from al} 
   mov dx,ax       {put this in dx, this is the number of cols to copy at 
                    to move} 
   mov bx,80       {put 80 in bx} 
   sub bx,ax       {subtract this from ax, this value is the number of columns 
                    we will skip over to get to the next value} 
   shl bx,1        {multiply by 2 since the data is stored as words} 
   mov di,si       {set di=si, di points to the offset in memory to move the 
                    characters to, in this case to the left} 
   inc si          {add one to si} 
   inc si          {add one to si, this places si one character ahead of di} 
   mov cl,[y2]     {put y2 coord. in cl} 
   mov ch,[y1]     {put y1 coord. in ch} 
   sub cl,ch       {subtract ch from cl, this value is the number of lines to 
                    scroll} 
   xor ch,ch       {set ch=0 since we don't need that anymore, and because the 
                    the CPU will use all of cx to calculate the number of
lines}    inc cx          {add one to cx because the subtraction only counts
one of                     the y-coords., this accounts for the other} 
   push ds         {save the ds register, which points to the data segment} 
   mov ax,0b800h   {put $b800, the video segment for 80x25 text mode on color 
                    monitors in ax, if the mode you are using has its video 
                    segment different from $b800, put the other value here} 
   mov es,ax       {put ax into es because one cannot move a value into a 
                    segment register, nor can one move one segment register 
                    into another} 
   mov ds,ax       {put ax in ds} 
   cld             {clear direction flag so we will write forward in memory} 
@copyloopl:        {this loops scrolls one line from x1 to x2 left one space}
   push cx         {save cx (number of lines to do)}
   mov cx,dx       {put dx (number of cols to scroll) in cx}
   rep movsw       {movsw moves a word from ds:si to es:di, the first register
                    being the segment in memory and the second the offset, rep
                    repeats the following instruction, in this case movsw, the
                    number of times in cx}
   mov [WORD PTR ds:si-2],0720h  {this puts a word with the value $0720 at
                                  ds:si-2, this puts a space with attribute
                                  lightgray on black at the beginning of the
                                  line, to change the character output,
                                  replace the 20 part with the hex number
                                  for the character, to change the color,
                                  change the 07 to the hex number for the
                                  attribute you want}
   pop cx          {restores cx from where we saved it earlier}
   add si,bx       {adds bx to si to make get ready to do the next line}
   add di,bx       {do the same for di}
   loop @copyloopl {loop loops to the label after it cx number of times}
   pop ds          {restore ds from where we saved it earlier}
end;


procedure scroll_right(x1,y1,x2,y2:byte); assembler; 
 
asm 
   mov al,[y1]     {put y1 into al} 
   xor ah,ah       {set ah to 0 so we can work with ax} 
   mov bx,80       {set bx=80} 
   mul bl          {mulitiply ax by bl} 
   mov bl,[x2]     {put x2 in bl} 
   add ax,bx       {add ax to bx} 
   shl ax,1        {multiply ax by 2 since data stored as words} 
   mov si,ax       {set si (source index) equal to ax} 
   mov al,[x1]     {put x1 into al} 
   xor ah,ah       {set ah=0} 
   sub bl,al       {subtract bl from al to get number of characters to scroll} 
   xchg ax,bx      {switch ax with bx} 
   mov dx,ax       {put ax (# of cols to scroll) in dx} 
   mov bx,ax       {put ax in bx} 
   shl bx,1        {multiply bx by 2 since dealing with words} 
   add bx,0a0h     {add $00A0 to bx, this is the number of bytes in one row 
                    of data, the reason being that in scroll_left we wrote 
                    forward in video memory, in scroll_right we have to write 
                    backward since otherwise we would destroy the data we were 
                    scrolling and fill the window with the first row of 
                    characters.  When we add this to si and di as in 
                    scroll_left, the # of cols part will take si and di back 
                    to where they started, and the $00a0 part will send them 
                    down one line} 
   mov di,si       {set di = si} 
   dec si          {decrement si because si needs to be behind di one 
                    character, since we are going backwards, si will be 
                    "ahead" of di which is how we keep from losing data} 
   dec si          {decrement si again since we are dealing with words} 
   mov cl,[y2]     {put y2 in cl} 
   mov ch,[y1]     {put y1 in ch} 
   sub cl,ch       {subtract ch (y1) from cl (y2) to get # or rows} 
   xor ch,ch       {clear ch since CPU uses all of cx} 
   inc cx          {increment cx to include both y-coords.} 
   push ds         {save ds so your program want lose its data segment, 
                    which would be REALLY bad} 
   mov ax,0b800h   {set ax = $B800, video memory segment} 
   mov es,ax       {set es = ax} 
   mov ds,ax       {set ds = ax} 
   std             {set direction flag since we want to go backwards in 
                    memory this time} 
@copyloopr:        {label for loop that scrolls one line right}
   push cx         {save cx}
   mov cx,dx       {put dx (#of cols) in cx so the rep instruction will
                    repeat the right number of times}
   rep movsw       {scroll one line right}
   mov [WORD PTR ds:si+2],0720h {Put a space in the character at col x1,
                                 ds:si points to col x1+1 at the end of the
                                 movsw stuff, so ds:si+2 = col x1}
   pop cx          {restore cx from where it was saved earlier}
   add si,bx       {add bx to si to send si to the next line}
   add di,bx       {ditto for di}
   loop @copyloopr {loop back to @copyloopr to do the next line until done}
   pop ds          {restore ds so your program will know where all its data
                    is}
end;

{
These procedures scroll the text in the window with the upper righthand
corner being (x1,y1) and the lower lefthand corner being (x1,y2).  The text
will not scroll outside of the window and the empty columns will be filled
with spaces with an attribute of lightgray on black.  To change what
character and color to put in the new columns, determine the hex number
for the character and color you want, then put the color byte in front of
the character byte and replace the 0720h with it.  For example, to select
character $20 with a color of $04, change the 0720h to 0420h like so:

   mov [WORD PTR ds:si+2],0420h  (in scroll_right)
      or
   mov [WORD PTR ds:si-2],0420h  (in scroll_left)

these procs simply copy chunks of video memory.  One thing that might help
understand the value for bx and other stuff: the movsw copys the word from
ds:si to es:di, then if the direction flag is clear, it adds 2 to si and to
di, if the direction flag is set, it subtracts 2 from si and di.
}