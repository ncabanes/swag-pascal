│I'm writing a Program that draws equations.  It's fairly easy if you put
│the equation in a pascal Variable like Y := (X+10) * 2, but I would like
│the user to enter the equation, but I don't see any possible way to do
│it.


      ...One way of doing it is by using an "expression trees". Suppose
you have the equation Y := 20 ÷ 2 + 3. In this equation, you can represent
the expression 20 ÷ 2 + 3 by using "full" binary trees as such:


figure 1                 a  ┌─┐
                            │+│    <----- root of your expression
                            └─┘
                    b     /     \
                      ┌─┐        ┌─┐ e
                      │÷│        │3│
                      └─┘        └─┘
                      /  \
                c ┌──┐    ┌─┐ d
                  │20│    │2│
                  └──┘    └─┘


(Note: a  "leaf" is a node With no left or right children - ie: a value )

...The above expression are called infix arithmetic expressions; the
operators are written in between the things on which they operate.

In our example, the nodes are visited in the order c, d, b, e, a,  and
their Labels in this order are 20, 2, ÷, 3, +.


Function Evaluate(p: node): Integer;
{ return value of the expression represented by the tree With root p }
{ p - points to the root of the expression tree                      }
Var
  T1, T2: Integer;
  op: Char;
begin
  if (p^.left = nil) and (p^.right = nil) then    { node is a "leaf" }
    Evaluate := (p^.Value)                        { simple Case      }
  else
    begin
      T1 := Evaluate(p^.Left);
      T2 := Evaluate(p^.Right);
      op := p^.Label;
      { apply operation }
      Case op of
        '+': Evaluate := (T1 + T2);
        '-': Evaluate := (T1 - T2);
        '÷': Evaluate := (T1 div T2);
        '*': Evaluate := (T1 * T2);
      end;
    end
end;


...Thus, using figure 1, we have:

              ┌──           ┌──
              │             │ Evaluate(c) = 20
              │ Evaluate(b) │ Evaluate(d) = 2
              │             │ ApplyOp('÷',20,2) = 10
   Evaluate(a)│             └──
              │ Evaluate(e) = 3
              │
              │ ApplyOp('+',10,3) = 13
              └─
