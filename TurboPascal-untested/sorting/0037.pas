(*
From: ROLAND WODITSCH
Subj: QUICK SORT
*)

UNIT QSort5;

INTERFACE
TYPE OrdFunction = FUNCTION(VAR a,b):BOOLEAN;

PROCEDURE Sortiere(VAR SortArray; Elementgroesse,LoIndex,HiIndex: word;
                   SortKleiner: OrdFunction; von,bis:word);

{       SortArray  field to sort                                          }
{       LoIndex    the lowest,                                            }
{       HiIndex    the highest fieldindex like in the fielddeklarartion   }
{       OrdAdr     the funktion from typ OrdFunction (s.o.)               }
{       von, bis   the sortarea                                           }

{     befor calling (not befor bind!) your have to define a               }
{     asymmetric  order funktion :                                        }
{     function IrgendEinName(VAR x,y : TypDerFeldElemente):boolean        }
{     example: (*$F+*) function kleiner(VAR x,y: integer):boolean;        }
{                        begin kleiner:=x<y end;  (*$F-*)                 }
{               not:  kleiner:=x<=y  (not asymmetric!)                    }
{     attention: x and y must be VAR-parameters !!!                       }



IMPLEMENTATION

procedure Sortiere(VAR SortArray; ElementGroesse,LoIndex,HiIndex: word;
                       SortKleiner:OrdFunction; von,bis:word);
  type ArrayPtr = ^Byte;
  var Mitte, i0, j0, m0 : ArrayPtr;

  procedure Swap(VAR x,y; size : word);
    begin
     INLINE ($1E/$C4/$B6/X/$C5/$BE/Y/$8B/$8E/SIZE/$E3/$0C/$26/$8A/$04/
             $86/$05/$26/$88/$04/$46/$47/$E2/$F4/$1F)
    end;

  function Element(i : word) : ArrayPtr;
    begin
      Element:=ptr(seg(SortArray),ofs(SortArray)+i*ElementGroesse)
    end;

  procedure inc(var index : word; var pointer : ArrayPtr);
    begin
      index:=succ(index);
      pointer:=ptr(seg(pointer^),ofs(pointer^)+ElementGroesse)
    end;

  procedure dec(var index : word; var pointer : ArrayPtr);
    begin
      index:=pred(index);
      pointer:=ptr(seg(pointer^),ofs(pointer^)-ElementGroesse)
    end;

  procedure E_Sort(von, bis : word);
    label EXIT;
    var i, j : word;
    begin
      if bis<=von then goto EXIT;
      i:=von; i0:=Element(i);
      while i<bis do begin
        m0:=i0; j:=i; j0:=i0; inc(j,j0);
        while j<=bis do begin
          if SortKleiner(j0^,m0^) then m0:=j0;
          inc(j,j0)
        end; (* WHILE j *)
        if m0<>i0 then Swap(i0^,m0^,ElementGroesse);
        inc(i,i0)
      end; (* WHILE i *)
      EXIT:
    end; (* E_Sort *)

  procedure Sort(von, bis : word);  (* Rekursive Quicksort *)
    label EXIT;
    var i, j : word;
    begin
      if bis-von<6 then begin E_Sort(von,bis); goto EXIT end;
      i:=von; j:=bis; m0:=Element((i+j) SHR 1);
      move(m0^,Mitte^,ElementGroesse); i0:=Element(i); j0:=Element(j);
      while i<=j do begin
        while SortKleiner(i0^,Mitte^) do inc(i,i0);
        while SortKleiner(Mitte^,j0^) do dec(j,j0);
        if i<=j then begin
          if i<>j then Swap(i0^,j0^,ElementGroesse);
          inc(i,i0); dec(j,j0)
        end (* if i<=j *)
      end; (* while i<=j *)
      if bis-i<j-von then begin
                       if i<bis then Sort(i,bis);
                       if von<j then Sort(von,j)
                       end
                     else begin
                       if von<j then Sort(von,j);
                       if i<bis then Sort(i,bis)
                       end;
      EXIT:
    end; (* Sort *)

  begin
    getmem(Mitte,ElementGroesse);
    Sort(von-LoIndex,bis-LoIndex);
    freemem(Mitte,ElementGroesse)
  end; (* Sort *)

END. (* IMPLEMENTATION OF UNIT QSORT *)

