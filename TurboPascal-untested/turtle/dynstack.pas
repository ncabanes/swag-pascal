(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Unit - define dynamical Ostack             │
   └───────────────────────────────────────────────────────────┘ *)

{ This program just modify Ostack.pas. This program work absolutly
  universal. This program can work with general item. Principe is
  DDS (dynamical data structure) and work with poiters. Last 'record'
  prvok is at the present Component, which define general item. It
  is easy to undestand.

}


Unit DynStack;

Interface

Const maxstack=100;

Type Component=Record p:pointer;
                      dl:word;
                      End;

     Stack=Object
             st: Array[1..maxstack] of Component;
             vrch: 0..maxstack;
             Procedure init;
             Function  full:boolean;
             Function  empty:boolean;
             Procedure push(Var v;d:word);
             Procedure pop(Var v);
           End;

Implementation

Procedure Error(s:string);      {Chyba = error}
Begin
writeln(s);
halt;
End;

Procedure Stack.init;
Begin
vrch:=0;
End;

Function Stack.full:boolean;
Begin
full:=vrch=maxstack
End;

Function Stack.empty:boolean;
Begin
Empty:=vrch=0
End;

Procedure Stack.push(Var v;d:word);
Begin
  if full Then Error('Full stack!')
  Else
    Begin
      inc(vrch);
      With st[vrch] do Begin
                       Dl:=d;
                       Getmem(p,dl);
                       Move(v,p^,dl);
                       End;
    End
End;

Procedure Stack.pop(Var v);
Begin
  if empty Then Error('Empty stack')
  Else
    Begin
      With St[vrch] do Begin
                       Move(p^,v,dl);
                       Freemem(p,dl);
                       End;
           Dec(vrch);

    End
End;

End.
