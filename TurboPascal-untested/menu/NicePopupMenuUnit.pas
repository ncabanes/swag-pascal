(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0018.PAS
  Description: Nice popup menu unit
  Author: EMIL MIKULIC
  Date: 01-02-98  07:33
*)

unit menu;
{ Note: Specify target pascal version - or USE_STRING if unsure }
{$DEFINE USE_STRING}
{*DEFINE USE_PCHAR}

interface

{$IFDEF USE_PCHAR}
uses llist,crt,strings;
{$ELSE}
uses llist,crt;
{$ENDIF}

{ Change these for a different color scheme }
const selected=15+(2 shl 4);
      normal=10;
      corner=10;
      border=2;
{$IFDEF USE_STRING}
{ Maximum width of a menu item - this can save memory }
      maxwidth=80;
{$ENDIF}

{ TMenuItem object - based on TItem
  by Emil Mikulic }

type PMenuItem=^TMenuItem;
     TMenuItem=object(TItem)
{$IFDEF USE_PCHAR}
      caption:PChar;
      len:word;
{$ELSE}
      caption:string[maxwidth];
{$ENDIF}
      value:integer;
      constructor init(x:string; v:integer; nxt:PMenuItem);
      procedure custom; virtual;
      procedure foreach; virtual;
      function get:integer; virtual;
      destructor done;
     end;

{ TMenu object - Menu handler
  by Emil Mikulic }

type PMenu=^TMenu;
     TMenu=object
       menuitems:PMenuItem;
       current,number:integer;
       x,y,w:integer;
       constructor init(xx,yy,ww:integer);
       procedure additem(s:string; i:integer);
       procedure draw;
       function getchoice:integer;
       function getcurrent:integer;
       destructor done;
     end;

implementation

constructor TMenuItem.init(x:string; v:integer; nxt:PMenuItem);
begin
{$IFDEF USE_PCHAR}
 { Get the length }
 len:=length(x);
 { Allocate memory }
 getmem(caption,len+1);
 { Set the string }
 StrPCopy(caption,x);
{$ELSE}
 caption:=x;
{$ENDIF}
 { Set the integer }
 value:=v;
 { Initialise the TItem }
 inherited init(nxt);
end;

procedure TMenuItem.custom;
begin
 writeln(caption);
end;

procedure TMenuItem.foreach;
begin
 custom;
 if next<>nil then next^.foreach;
end;

function TMenuItem.get:integer;
begin
 get:=value;
end;

destructor TMenuItem.done;
begin
{$IFDEF USE_PCHAR}
 { Free up the string }
 freemem(caption,len+1);
{$ENDIF}
 { Just pass it on to TItem }
 inherited done;
end;


constructor TMenu.init(xx,yy,ww:integer);
begin
 number:=0;
 current:=1;
 menuitems:=nil;
 x:=xx;
 y:=yy;
 w:=ww;
end;

procedure TMenu.additem(s:string; i:integer);
begin
 if menuitems=nil then menuitems:=new(PMenuItem,init(s,i,nil))
 else menuitems^.add( new(PMenuItem,init(s,i,nil)) );
 number:=number+1;
end;

procedure TMenu.draw;
var i,j:integer;
  tmp:PItem;
begin
 textattr:=corner;
 gotoxy(x,y);
 write(#218);
 textattr:=border;
 for i:=1 to w do write(#196);
 textattr:=corner;
 write(#191);
 textattr:=border;
 for i:=1 to number do begin
   gotoxy(x,y+i);
   write(#179);
   gotoxy(x+w+1,y+i);
   write(#179);
   end;
 textattr:=corner;
 gotoxy(x,y+number+1);
 write(#192);
 textattr:=border;
 for i:=1 to w do write(#196);
 textattr:=corner;
 write(#217);

 i:=1;
 tmp:=menuitems;
 while (tmp<>nil) do begin
   gotoxy(x+1,y+i);
   if i=current then textattr:=selected else textattr:=normal;

   for j:=1 to w do write(' ');
   gotoxy(x+1,y+i);
   tmp^.custom;
   tmp:=tmp^.next;
   i:=i+1;
   end;
 textattr:=7;
end;

function TMenu.getcurrent:integer;
var i:integer;
  tmp:PItem;
begin
 if current=1 then getcurrent:=menuitems^.get else
 begin
   tmp:=menuitems;
   for i:=2 to current do tmp:=tmp^.next;
   getcurrent:=tmp^.get;
 end;
end;

  CONST
    KEnter = $000D;   KEsc   = $001B;
    KLeft  = $4B00;   KRight = $4D00;
    KDown  = $5000;   KUp    = $4800;

function TMenu.getchoice:integer;
var
  ok:Boolean;
  inc:char;
  inw:word;
begin
 ok:=false;
 repeat
   draw;
   inc:=readkey;
   if (inc=#0) and keypressed then begin
     inc:=readkey;
     inw:=word(inc) shl 8;
     end
   else
     inw:=ord(inc);

   case inw OF
    KLeft, KUp   : if current>1 then current:=current-1;
    KRight, KDown: if current<number then current:=current+1;
    KEsc         : begin
                     ok:=true;
                     getchoice:= 0;
                   end;
    KEnter       : begin
                     ok:=true;
                     getchoice:=getcurrent;
                   end;
   end;
 until ok;
end;

destructor TMenu.done;
begin
 dispose(menuitems,done);
end;

{
var x:PMenu;
begin
 x:=new(PMenu,init(5,5,10));

 x^.additem('1st',1);
 x^.additem('2nd',2);
 x^.additem('3rd',3);
 x^.additem('4th',5);

 clrscr;

 writeln(x^.getchoice);

 dispose(x,done);}
end.

{ ---------------------------------CUT------------------------------- }

MENU
Unit Documentation

by Emil Mikulic

I won't go into the details of this unit, instead I'll just show you
basically how to use it. If you want to know how it works, just look
through the code.

Here's a commented example (which you can cut out and compile!):

--- CUT --- CUT --- CUT --- CUT --- CUT --- CUT --- CUT --- CUT ---
uses crt,menu;

{ Set up a variable to use as the menu }
var x:PMenu;
begin
 { Allocate it on the heap - the syntax for PMenu.init is:
  PMenu.Init(x,y,width)

  X is the X coordinate of the upper-left corner
  Y is the Y coordinate of the upper-left corner
  Width is the width of the menu (make sure the width is at least
  1 bigger than the longest MenuItem string or you get weird results)
 }
 x:=new(PMenu,init(5,5,10));

 { Add items to its linked list. The syntax is:
  PMenu.AddItem(s:string; i:integer);

  S is the string that will be displayed
  I is the value that will be returned if the item is picked
 }
 x^.additem('1st',1);
 x^.additem('2nd',2);
 x^.additem('3rd',3);
 x^.additem('4th',4);

 clrscr;

 { PMenu.GetChoice displays the menu and waits for the user to pick
  an item. The user can use the arrow-keys, Escape and Enter.
  Enter makes GetChoice return the value of the selected
  item and Escape makes GetChoice return 0 }
 writeln(x^.getchoice);

 { Dismantle the menu, not only does it take up memory but you
   may get strange results and maybe a system crash if you fail
   to do this }
 dispose(x,done);
end.

--- CUT --- CUT --- CUT --- CUT --- CUT --- CUT --- CUT --- CUT ---

And that's about it!
Just one last thing -

MENU comes in two different versions
in the same file. If you have Borland Pascal or your
Pascal compiler supports the STRINGS unit then use the
{$DEFINE USE_PCHAR} because it's more memory-efficient.
If you're not sure or have Turbo Pascal 6.0 or 7.0 then
use {$DEFINE USE_STRING} and make sure that only one has the $
and the other one has a {*DEFINE ...} If you have another
pascal compiler or you're not sure then USE_STRING. :)

Emil Mikulic, 1997.



