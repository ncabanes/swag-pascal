(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0031.PAS
  Description: FASTMOVE.PAS
  Author: BRENT BEACH
  Date: 05-26-95  23:05
*)

{
  From: Kris Vandermotten                            Read: Yes    Replied: No

There has been some talk about fast moves to move temp screens to the
screen memory.

Here's my FastMove. It's demonstrated here with a color text screen, but
it can be used with mode $13 screens also. I guess that's where it is
most usefull.
It can be used for other things than screens, but remember:
 - the memory blocks must not overlap
 - the size of the memory block must be a multiple of 4 bytes
 - it works best if the memory blocks are aligned at 4 byte boundaries
All these are ok for screens.

Needs TP7.
}

program testmove;
{$G+,S-,R-}

procedure FastMove(var source, dest; count: word); assembler;
{count must be evenly dividible by 4 !}
asm
 cld
 mov cx,count

 lds si,source
 cmp cx,0
 les di,dest
 je @end

 cmp test8086,2
 jle @no386

 shr cx,2

 @loop:
 db $66; mov ax,[si]
 db $66; mov es:[di],ax
 dec cx
 add si,4
 add di,4
 cmp cx,0
 jne @loop
 jmp @end

@no386:
 shr cx,1
 rep movsw

@end:
 mov ax, seg @data
 mov ds,ax
end;

Type
 PScreen = ^TScreen;
 TScreen = array[0..24,0..79] of word;

Var
 Screen: TScreen absolute $B800:$0000; {$B000:$0000 for mono}
 Buf1,
 buf2: PScreen;
 i: word;

begin
 New(Buf1);
 New(Buf2);

 Buf1^ := Screen;
 FillChar(Buf2^,SizeOf(Buf2^),0);

 For i := 0 to 1000 do
  begin
   FastMove(Buf2^,Screen,SizeOf(Screen));
   FastMove(Buf1^,Screen,SizeOf(Screen));
  end;

 Dispose(buf1);
 Dispose(Buf2);
end.

{
That's it. If you use this in any commercial software, give me credit.
Tested. Normal disclaimer goes: use at your own risk.
}
