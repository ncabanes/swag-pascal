(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0051.PAS
  Description: Fast and Useful Date routines
  Author: BJ�RN FELTEN
  Date: 02-28-95  09:55
*)

{
   Here you have my DayUtil, I'm sure you can use that instead. As a bonus you
get a function that returns the daynumber of Eastern Day a certain year (yes!
it's true! :) plus some other useful(?) related functions.

                           - = * = -
}

unit DayUtil;
{ some useful date&time related functions }
{ PD by Björn Felten @ 2:203/208 -- Nov 1994 }

{$g+} { three shift instructions need this }

interface

function dayNo(Ye,Mo,Da:word): word; {calculate the daynumber 1..366}
function easternDay(Ye:word): word;  {what day Eastern Day is that year}
function getYear:  word; inline($b4/$2a/$cd/$21/$89/$c8);
function getMonth: word; inline($b4/$2a/$cd/$21/$30/$e4/$88/$f0);
function getDay:   word; inline($b4/$2a/$cd/$21/$30/$e4/$88/$d0);
function getDow:   word; inline($b4/$2a/$cd/$21/$30/$e4);
function getHour:  word; inline($b4/$2c/$cd/$21/$30/$e4/$88/$e8);
function getMin:   word; inline($b4/$2c/$cd/$21/$30/$e4/$88/$c8);
function getSec:   word; inline($b4/$2c/$cd/$21/$30/$e4/$88/$f0);
function workDay(Ye,Mo,Da,Wd:word): boolean; {returns true if a working day}


implementation

function dayNo;assembler;
asm
    mov  bx,Ye
    mov  cx,Mo
    dec  cx      (* Month = 0..11 *)
    mov  di,Da

{   if Month>2 then  }
    cmp  cx,1
    jle  @janfeb

{      S := ((Year mod 4) + 3) div 4 + (4 * Month + 23) div 10 - 1  }
    and  bx,3
    add  bx,3
    shr  bx,2
    mov  ax,cx
    inc  ax
    shl  ax,2
    add  ax,23
    cwd
    push cx
    mov  cx,10
    div  cx
    pop  cx
    dec  ax
    add  bx,ax
    jmp  @eif

{   else  }
@janfeb:

{      S := 0;  }
    xor  bx,bx
@eif:

{   DayNo:= 31 * (Month - 1) + Day - S;  }
    mov  ax,cx
    mov  cx,31
    mul  cx
    add  ax,di
    sub  ax,bx
end;

function easternDay;assembler;
{ uses Gauss' Eastern formula to calculate Eastern Day }
{ you're not supposed to understand this... :) }
{ it took me quite some while to convert the "formula" from }
{ the look up tables, that I found in my encyclopaedia, into }
{ pure, working assembler, so enjoy... }
asm
    mov  ax,Ye
    cmp  ax,99
    jg   @noadd
    cmp  ax,80
    jg   @not2000
    add  ax,100
@not2000:
    add  ax,1900
@noadd:
    mov  bx,ax
    cwd
    mov  cx,19
    div  cx
    mov  ax,dx
    mul  cx
    add  ax,24
    mov  cx,30
    div  cx
    mov  si,dx
    mov  ax,bx
    and  ax,3
    shl  ax,1
    mov  di,ax
    mov  ax,bx
    cwd
    mov  cx,7
    div  cx
    mov  ax,dx
    shl  ax,2
    add  di,ax
    mov  ax,si
    shl  ax,1
    add  ax,si
    shl  ax,1
    add  ax,5
    add  ax,di
    cwd
    div  cx
    add  dx,si
    add  dx,81
    and  bx,3
    jne  @no29
    inc  dx
@no29:
    mov  ax,dx
end;


(*
   (In other countries than Sweden you may have other holidays
   than we have here. But you'll probably recognize Ascension Day,
   Whit-Monday and the other holidays below, so it shouldn't
   be that difficult to work out your own, country specific,
   modifications to get the workDay function working properly...)

   För svenska förhållanden gäller följande beträffande helgdagar:

       Sun:=(WeekDay='S') or   {Söndag}
      (ThisDate='01 Jan') or   {Nyårsdagen}
      (ThisDate='06 Jan') or   {Trettondedagen}
      (ThisDate='01 May') or   {1:sta maj}
      (ThisDate='25 Dec') or   {Juldagen}
      (ThisDate='26 Dec');     {Annandag jul}

       EFri:=EasternDay-2;     {Långfredag}
       EMon:=EFri+3;           {Annandag påsk}
       ADay:=EMon+38;          {Kristi himmelsfärdsdag}
       WMon:=ADay+11;          {Annandag pingst}
*)

function workDay;
var dn,ed:word;
begin
  dn:=dayNo(Ye,Mo,Da); ed:=easternDay(Ye);
  workDay:=not
       ((Wd= 0) or(Wd= 6)  or   {Söndag eller Lördag}
       ((Da= 1)and(Mo= 1)) or   {Nyårsdagen}
       ((Da= 6)and(Mo= 1)) or   {Trettondedagen}
       ((Da= 1)and(Mo= 5)) or   {1:sta maj}
       ((Da=25)and(Mo=12)) or   {Juldagen}
       ((Da=26)and(Mo=12)) or   {Annandag jul}
        (dn=ed- 2)         or   {Långfredag}
        (dn=ed+ 1)         or   {Annandag påsk}
        (dn=ed+39)         or   {Kristi himmelsfärdsdag}
        (dn=ed+50))             {Annandag pingst}
end;

end.

