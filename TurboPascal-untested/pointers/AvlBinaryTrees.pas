(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0011.PAS
  Description: AVL Binary Trees
  Author: SWAG SUPPORT TEAM
  Date: 08-27-93  20:11
*)

{
> Does anyone have code(preferably TP) the implements AVL trees?
> I'm having trouble With the insertion part of it.  I'm writing a small
> parts inventory Program For work(although I'm not employed as a
> Programmer) and the AVL tree would be very fast For it.
}


Program avl;

Type
  nodeptr = ^node;
  node    = Record
    key   : Char;
    bal   : -1..+1; { bal = h(right) - h(left) }
    left,
    right : nodeptr
  end;

  tree = nodeptr;

Var
  t : tree;
  h : Boolean; { insert & delete parameter }


Procedure maketree(Var t : tree);
begin
  t := nil;
end;

Function member(k : Char; t : tree) : Boolean;
begin { member }
  if t = nil then
    member := False
  else
  if k = t^.key then
    member := True
  else
  if k < t^.key then
    member := member(k, t^.left)
  else
    member := member(k, t^.right);
end;

Procedure ll(Var t : tree);
Var
  p : tree;
begin
  p := t^.left;
  t^.left  := p^.right;
  p^.right := t;
  t := p;
end;

Procedure rr(Var t : tree);
Var
   p : tree;
begin
  p := t^.right;
  t^.right := p^.left;
  p^.left  := t;
  t := p;
end

Procedure lr(Var t : tree);
begin
  rr(t^.left);
  ll(t);
end;

Procedure rl(Var t : tree);
begin
  ll(t^.right);
  rr(t);
end;

Procedure insert(k : Char; Var t : tree; Var h : Boolean);

  Procedure balanceleft(Var t : tree; Var h : Boolean);
  begin
    Writeln('balance left');
    Case t^.bal of
      +1 :
        begin
          t^.bal := 0;
          h := False;
        end;
       0 : t^.bal := -1;
      -1 :
        begin { rebalance }
          if t^.left^.bal = -1 then
          begin { single ll rotation }
            Writeln('single ll rotation');
            ll(t);
            t^.right^.bal := 0;
          end
          else { t^.left^.bal  = +1 }
          begin  { double lr rotation }
            Writeln('double lr rotation');
            lr(t);
            if t^.bal = -1 then
              t^.right^.bal := +1
            else
              t^.right^.bal := 0;
            if t^.bal = +1 then
              t^.left^.bal := -1
            else
              t^.left^.bal := 0;
          end;
          t^.bal := 0;
          h := False;
        end;
    end;
  end;

  Procedure balanceright(Var t : tree; Var h : Boolean);
  begin
    Writeln('balance right');
    Case t^.bal of
      -1 :
        begin
          t^.bal := 0;
          h := False;
        end;
       0 : t^.bal := +1;
      +1 :
        begin { rebalance }
          if t^.right^.bal = +1 then
          begin { single rr rotation }
            Writeln('single rr rotation');
            rr(t);
            t^.left^.bal := 0
          end
          else { t^.right^.bal  = -1 }
          begin  { double rl rotation }
            Writeln('double rl rotation');
            rl(t);
            if t^.bal = -1 then
              t^.right^.bal := +1
            else
              t^.right^.bal := 0;
            if t^.bal = +1 then
              t^.left^.bal := -1
            else
              t^.left^.bal := 0;
          end;
          t^.bal := 0;
          h := False;
        end;
    end;
  end;

begin { insert }
  if t = nil then
  begin
    new(t);
    t^.key   := k;
    t^.bal   := 0;
    t^.left  := nil;
    t^.right := nil;
          h := True;
  end
  else
  if k < t^.key then
  begin
    insert(k, t^.left, h);
          if h then
      balanceleft(t, h);
  end
  else
  if k > t^.key then
  begin
    insert(k, t^.right, h);
    if h then
      balanceright(t, h);
  end;
end;

Procedure delete(k : Char; Var t : tree; Var h : Boolean);

  Procedure balanceleft(Var t : tree; Var h : Boolean);
  begin
    Writeln('balance left');
    Case t^.bal of
      -1 :
        begin
          t^.bal := 0;
          h := True;
        end;
       0 :
         begin
                 t^.bal := +1;
                 h := False;
               end;
      +1 :
        begin { rebalance }
          if t^.right^.bal >= 0 then
          begin
            Writeln('single rr rotation'); { single rr rotation }
                        if t^.right^.bal = 0 then
            begin
              rr(t);
                          t^.bal := -1;
                          h := False;
                        end
                        else
            begin
              rr(t);
                          t^.left^.bal := 0;
                          t^.bal := 0;
                          h := True;
                        end;
          end
          else { t^.right^.bal  = -1 }
          begin
                        Writeln('double rl rotation');
                   rl(t);
                        t^.left^.bal := 0;
            t^.right^.bal := 0;
                        h := True;
                      end;
        end;
    end;
  end;

  Procedure balanceright(Var t : tree; Var h : Boolean);
  begin
    Writeln('balance right');
    Case t^.bal of
      +1 :
        begin
          t^.bal := 0;
          h := True;
        end;
       0 :
         begin
                 t^.bal := -1;
                 h := False;
               end;
      -1 :
        begin { rebalance }
          if t^.left^.bal <= 0 then
          begin { single ll rotation }
            Writeln('single ll rotation');
                        if t^.left^.bal = 0 then
            begin
              ll(t);
                          t^.bal := +1;
                          h := False;
                        end
                        else
            begin
              ll(t);
                          t^.left^.bal := 0;
                          t^.bal := 0;
                          h := True;
                        end;
          end
          else { t^.left^.bal  = +1 }
          begin  { double lr rotation }
            Writeln('double lr rotation');
            lr(t);
                        t^.left^.bal := 0;
                        t^.right^.bal := 0;
                        h := True;
          end;
        end;
    end;
  end;

  Function deletemin(Var t : tree; Var h : Boolean) : Char;
  begin { deletemin }
    if t^.left = nil then
    begin
      deletemin := t^.key;
      t := t^.right;
            h := True;
    end
    else
    begin
      deletemin := deletemin(t^.left, h);
            if h then
        balanceleft(t, h);
    end;
  end;

begin { delete }
  if t <> nil then
  begin
    if k < t^.key then
    begin
      delete(k, t^.left, h);
            if h then
        balanceleft(t, h);
    end
    else
    if k > t^.key then
    begin
      delete(k, t^.right, h);
            if h then
        balanceright(t, h);
    end
    else
    if (t^.left = nil) and (t^.right = nil) then
    begin
      t := nil;
            h := True;
    end
    else
    if t^.left = nil then
    begin
      t := t^.right;
            h := True;
    end
    else
    if t^.right = nil then
    begin
      t := t^.left;
            h := True;
    end
    else
    begin
      t^.key := deletemin(t^.right, h);
            if h then
              balanceright(t, h);
    end;
  end;
end;

begin
end.

