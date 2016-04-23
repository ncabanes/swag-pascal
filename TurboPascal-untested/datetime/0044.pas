(* Public domain

Author: Marius Ellen, Winsum, Groningen, The Netherlands
Fido 2:282/607.2

 After studying several DayOfWeeks i got sick.
 None of them worked really correctly and most
 had over 15 DIV'/MOD's or * in it.
 The Zeller's congruence was the best but the
 routine also contains some range errors. Years
 are only valid from 1..6300 and its really slow,
 so i wrote my own..


 About the routines..
 routine results valid if year in 0..65536
 month in 1..12, and day in 1..28/29/30/31
 there is absolute no range checking..
*)

function DayOfWeek(year,month,day:word):word;
{Returns the day of week, 0=Sun..6=Sat}
assembler; {See 1995}
const mtable:array[0..11] of byte=
  (0,3, 3,6, 1,4, 6,2, 5,0, 3,5);
asm
{(Y+(Y div 4)-(Y div 100)+(Y div 400)-Adjust)mod 7}
        mov    ax,year
        mov    di,ax
        xor    bx,bx
        xor    cx,cx
        mov    si,day
        dec    si
        shr    ax,1; adc cl,0 {si+=year div 4}
        shr    ax,1; adc cl,0
        add    si,ax
        mov    bx,25          {si+=year div 100}
        xor    dx,dx
        div    bx
        sub    si,ax
        shr    ax,1; adc ch,0 {si+=year div 400}
        shr    ax,1; adc ch,0
        add    si,ax
        add    si,di
{if leap-year then decrease days}
        mov    bx,month
        cmp    bx,2;  ja  @Noleap {do not adjust}
        and    cl,cl; jne @NoLeap {year mod 4=0?}
        and    dx,dx; jne @IsLeap {year mod 100=0?}
        and    di,di; je  @NoLeap {year=0?}
        and    ch,ch; jne @Noleap {year mod 400=0?}
@IsLeap:dec    si
@Noleap:xor    ah,ah
        mov    al,byte ptr mTable[bx-1]
        add    ax,si
        mov    bx,7
        xor    dx,dx
        div    bx
        xchg   ax,dx
end;

function GetDaysInMonth(Month:Byte;Year:Word):Word;
{Returns the total number of days in a month}
assembler;
asm
        mov    bl,Month
        {What about februari?}
        cmp    bl,2; jne @N
        mov    ax,Year
        shr    ax,1; jc @S
        shr    ax,1; jc @S
        {it's a leap-year}
        mov    cx,25; div cx
        and    dx,dx; jne @T
        {its a century}
        and    al,3;  jne @S
    @T: {leap}
        mov    ax,29; jmp @E
    @S: {noleap}
        mov    ax,28; jmp @E
    @N: {Nope, calc moth day's}
        mov    ax,15
        shr    bl,1; rcl ax,1
        cmp    bl,4; jb @E
        xor    ax,1
    @E:
end;

function GetDaysInYear(Year:Word):Word;
{Returns the total number of days in a year}
assembler;
asm
        mov    ax,2
        push   ax
        push   year
        call   GetDaysInMonth
        add    ax,(365-28)
end;

