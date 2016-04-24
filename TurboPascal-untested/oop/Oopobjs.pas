(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0015.PAS
  Description: OOPOBJS.PAS
  Author: SCOTT RAMSAY
  Date: 05-28-93  13:53
*)

Unit OopObjs;

{ OOPOBJS.PAS  Version 1.1 Copyright 1992 Scott D. Ramsay }

{  OOPOBJS.PAS is free! Go crazy. }
{  When I was learning Linked-List in High School, I thought that I'd only  }
{ need it in boring stuff like database Programming.  Doubled linked-list,  }
{ is a great way to handle multiple Objects For games.  Throw in some OOP   }
{ design and Volia!  Easy managable sprites.                                }
{  I give this code to Public Domain.  Use it as you see fit.  Just include }
{ the first comment line when distributing the source code, Thanks.         }

{  Changes from 1.0:                                                        }
{    Added new parameter in method checkhit.                                }
{          Var item:pobj                                                    }
{      Is a Pointer to the Object which called the checkhit                 }

Interface

Type
  plist   = ^tlist;
  PObjs   = ^tobjs;
  tobjs   = Object
              nx,ny,                       { Sprite Position               }
              flp,                         { Sprite number (For animation) }
              nrx,                         { I Forget what this does       }
              num_sprite,                  { Num of sprites per Objects    }
              timeo,                       { How long this Object lasts    }
              pointage     : Integer;      { Score value (For gamers)      }
              mapcolor     : Byte;         { Color For radar display       }
              id,                          { I Forget this one too         }
              explo,                       { True if the Object is explodin}
              overshow     : Boolean;      { See: Procedure DRAWITEMS      }
              powner       : plist;        { The PLIST node which this     }
                                           {  Object belongs               }
              Constructor init(vx,vy:Integer);
              Procedure drawitemObject;Virtual;
              Procedure calcitemObject;Virtual;
              Function checkhit(hx,hy:Integer;Var item:pobjs):Boolean;Virtual;
              Destructor done; Virtual;
            end;
  PobjMov = ^tobjMov;
  tobjMov = Object(tobjs)
              ndx,ndy : Integer;
              Constructor init(vx,vy,vdx,vdy:Integer);
              Procedure calcitemObject; Virtual;
            end;
  tlist = Record
            item      : pobjs;
            prev,next : plist;
          end;
  pkill = ^tkill;
  tkill = Record
            tk   : plist;
            next : pkill;
          end;

Procedure addp(Var nkbeg,nkend,p:plist);
Procedure deletep(Var nkbeg,nkend,p:plist);
Procedure calcitems(Var nkbeg:plist);
Procedure drawitems(Var nkbeg:plist;over:Boolean);
Procedure add2kill_list(Var kill:pkill;Var i:plist);
Procedure cleankill_list(Var kill:pkill;Var nkbeg,nkend:plist);
Procedure clean_plist(Var nkbeg,nkend:plist);

Implementation

Procedure calcitems(Var nkbeg:plist);
Var
  p : plist;
begin
  p := nkbeg;
  While p<>nil do
    begin
      p^.item^.calcitemObject;
      p := p^.next;
    end;
end;


Procedure drawitems(Var nkbeg:plist;over:Boolean);
{
  This Procedure is usually called from:  (GMorPH.PAS)
     Tmorph.pre_map
     Tmorph.post_map
  The OVER flag tells when this Object should be drawn.  Behind
   geomorph or infront of the geomorph.
}
Var
  p : plist;
begin
  p := nkbeg;
  While p<>nil do
    begin
      if (p^.item^.overshow=over)
        then p^.item^.drawitemObject;
      p := p^.next;
    end;
end;


Procedure clean_plist(Var nkbeg,nkend:plist);
Var
  p,p2 : plist;
begin
  p := nkbeg;
  While p<>nil do
    begin
      p2 := p;
      p := p^.next;
      dispose(p2^.item,done);
      dispose(p2);
    end;
  nkbeg := nil;
  nkend := nil;
end;


Procedure addp(Var nkbeg,nkend,p:plist);
begin
  p^.next := nil;
  if nkend=nil
    then
      begin
        nkbeg := p;
        nkend := p;
        p^.prev := nil;
      end
    else
      begin
        p^.prev := nkend;
        nkend^.next := p;
        nkend := p;
      end;
end;


Procedure deletep(Var nkbeg,nkend,p:plist);
begin
  if nkbeg=nkend
    then
      begin
        nkbeg := nil;
        nkend := nil;
      end
    else
  if nkbeg=p
    then
      begin
        nkbeg := nkbeg^.next;
        nkbeg^.prev := nil;
      end
    else
  if nkend=p
    then
      begin
        nkend := nkend^.prev;
        nkend^.next := nil;
      end
    else
      begin
        p^.next^.prev := p^.prev;
        p^.prev^.next := p^.next;
      end;
  dispose(p^.item,done);
  dispose(p);
end;


Procedure cleankill_list(Var kill:pkill;Var nkbeg,nkend:plist);
Var
  p,p2 : pkill;
begin
  p := kill;
  While p<>nil do
    begin
      p2 := p;
      p := p^.next;
      deletep(nkbeg,nkend,p2^.tk);
      dispose(p2);
    end;
  kill := nil;
end;


Procedure add2kill_list(Var kill:pkill;Var i:plist);
Var
  p : pkill;
begin
  new(p);
  p^.tk := i;
  p^.next := kill;
  kill := p
end;

(**) { tobjs Methods }

Constructor tobjs.init(vx,vy:Integer);
begin
  nx := vx; ny := vy; num_sprite := 1;
  mapcolor := $fb; pointage := 0;
  flp := 0; overshow := False;
end;


Destructor tobjs.done;
begin
end;


Procedure tobjs.drawitemObject;
begin
  { i.e.
     fbitdraw(nx,ny,pic[flip]^);
  }
end;


Procedure tobjs.calcitemObject;
begin
end;


Function tobjs.checkhit(hx,hy:Integer;Var item:pobjs):Boolean;
begin
end;

(**) { tobjMov methods }

Constructor tobjMov.init(vx,vy,vdx,vdy:Integer);
begin
  nx := vx; ny := vy; ndx := vdx; ndy := vdy;
  mapcolor := $fb; pointage := 0;
  flp := 0; overshow := False;
end;


Procedure tobjMov.calcitemObject;
begin
 { These are just simple examples of what should go in the methods }
  inc(nx,ndx); inc(ny,ndy);
  flp := (flp+1)mod num_sprite;
end;

end.
