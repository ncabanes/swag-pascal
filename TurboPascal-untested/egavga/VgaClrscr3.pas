(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0047.PAS
  Description: VGA ClrScr #3
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
I also wanted to put a picture bigger than the screen to scroll over
For the intro.  --  ANIVGA  --
}

Program ScrollExample;
{Demonstrates how to use the VGA's hardware scroll to do some nice opening}
{sequence: the Program loads 3 Graphic pages With data and then scrolls   }
{them by. note that this erases the contents of the background page and   }
{thus shouldn't be used While animating sprites in parallel!}

Uses
  ANIVGA, Crt;

Procedure IntroScroll(n,wait:Word);
{ in: n    = # rows to scroll up using hardware zoom}
{     wait = time (in ms) to wait after each row    }
{rem: Scrolling *always* starts at page 0 (=$A000:0000)   }
{     Thus, issuing "Screen(1-page)" afterwards is a must!}
{     if you put the routine into ANIVGA.PAS, you should delete all the}
{     Constants following this line}
Const
  StartIndex=0;
  endIndex=StartIndex+3;
  {offsetadressen der Grafikseiten (in Segment $A000):}
  offset_Adr:Array[StartIndex..endIndex] of Word=($0000,$3E80,$7D00,$BB80);
  CrtAddress=$3D4; {if monochrome: $3B4}
  StatusReg =$3DA; {if monochrome: $3BA}
begin
  Screen(0);                  {position at $A000:0000}
  Asm
    xor SI,SI                {use page address 0 }
    and SI,3
    SHL SI,1
    ADD SI,ofFSET offset_Adr-StartIndex*2 {call this "defensive Programming"..}
    LODSW
    MOV BX,AX
    MOV CX,n
    MOV SI,wait
  @oneline:
    ADD BX,LinESIZE
    CLI                      {no inTs please!}
    MOV DX,StatusReg
    @WaitnotHSyncLoop:
      in   al,dx
      and  al,1
      jz  @WaitnotHSyncLoop
    @WaitHSyncLoop:
      in   al,dx
      and  al,1
      jz   @WaitHSyncLoop
    MOV DX,CrtAddress        {Crt-controller}
    MOV AL,$0D               {LB-startaddress-register}
    OUT DX,AL
    inC DX

    MOV AL,BL
    OUT DX,AL                {set new LB of starting address}
    DEC DX
    MOV AL,$0C
    OUT DX,AL
    inC DX
    MOV AL,BH                {dto., HB}
    OUT DX,AL
    STI

    PUSH BX
    PUSH CX
    PUSH SI
    PUSH SI
    CALL Crt.Delay
    POP SI
    POP CX
    POP BX
    LOOP @oneline
  end;
end;

begin
 InitGraph; {Program VGA into Graphic mode, clear all pages}

 {--- Start of Intro ---}
 Screen(0); {or SCROLLPAGE, just an aesthetic question...}
 {Load 3 pages With pics, or draw them:}
 LoadPage('1st.PIC',0);
 LoadPage('2nd.PIC',1);
 LoadPage('3rd.PIC',BackgndPage);
 IntroScroll(3*200,20); {scroll up 3 pages, wait 20ms}
 Delay(3000); {wait a few seconds}
 Screen(1-page); {restore correct mode}
 {--- end of Intro ---}

 {now do your animations as usual}
 {...}
 CloseRoutines;
end.

{
if you adjust LoadPage() to allow loading into Graphic page 3 (=SCROLLPAGE),
too, you may easily do a 4 screen hardware scroll!
}

