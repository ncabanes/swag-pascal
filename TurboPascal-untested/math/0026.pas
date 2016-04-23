{
DJ MURDOCH

>The solution I use For dynamic Objects (I don't have any Complex code) is
>to keep a counter in each matrix Record; every Function decrements the
>counter, and when it reaches 0, disposes of the Object.  if you need to
>use an Object twice, you increment the counter once before using it.

> if you allocate an Object twice, how do you get the first address back into
> the Pointer Variable so it can be disposed?   I must not understand the
> problem.  if I do:

> new(p); new(p);

> Unless I save the value of the first p, how can I dispose it?  And if I
> save it, why not use two Pointer Variables, p1 and p2, instead?

You're right, there's no way to dispose of the first p^.  What I meant is
something like this:  Suppose X and Y are Pointers to matrix Objects.  if I
want to calculate Z as their product, and don't have any need For them any
more, then it's fine if MatMul disposes of them in

  Z := MatMul(X,Y);

In fact, it's Really handy, because it lets me calculate X Y Z as

  W := MatMul(X, MatMul(Y,Z));

The problem comes up when I try to calculate something like X^2, because MatMul
would get in trouble trying to dispose of X twice in

 Y := MatMul(X, X);

The solution I use is to keep a counter in every Object, and to follow a rigid
discipline:

 1.  Newly created Objects (Function results) always have the counter set to
     zero.

 2.  Every Function which takes a Pointer to one of these Objects as an
     argument is sure to "touch" the Pointer, by passing it exactly once to
     another Function.  (There's an exception below that lets you pass it more
     than once if you need to.)

3.   if a Function doesn't need to pass the Object to another Function, then
     it passes it to the special Function "Touch()", to satisfy rule 2.
     Touch checks the counter; if it's zero, it disposes of the Object,
     otherwise, it decrements it by one.

4.   The way to get around the "exactly once" rule 2 is to call the "Protect"
     Function before you pass the Object.  This just increments the counter.

5.   Functions should never change Objects being passed to them as arguments;
     there's a Function called "Local" which makes a local copy to work on if
     you need it.  What Local does is to check the counter; if it's zero,
     Local just returns the original Object, otherwise it asks the Object to
     make a copy of itself.

For example, to do the line above safely, I'd code it as

  Y := MatMul(X, Protect(X));

MatMul would look something like this:
}

Function MatMul(Y, Z : PMatrix) : PMatrix;
Var
  result : PMatrix;
begin
  { Allocate result, fill in the values appropriately, then }
  Touch(Y);
  Touch(Z);
  MatMul := result;
end;

{
The first Touch would just decrement the counter in X, and the second would
dispose of it (assuming it wasn't already protected before the creation of Y).

I've found that this system works Really well, and I can sleep at night,
knowing that I never leave dangling Pointers even though I'm doing lots of
allocations and deallocations.

Here, in Case you're interested, is the Real matrix multiplier:
}

Function MProd(x, y : PMatrix) : PMatrix;
{ Calculate the matrix product of x and y }
Var
  result  : PMatrix;
  i, j, k : Word;
  mp      : PFloat;
begin
  if (x = nil) or (y = nil) or (x^.cols <> y^.rows) then
    MProd := nil
  else
  begin
    result := Matrix(x^.rows, y^.cols, nil, True);
    if result <> nil then
      With result^ do
      begin
        For i := 1 to rows do
          With x^.r^[i]^ do
            For j := 1 to cols do
            begin
              mp := pval(i,j);
              mp^ := 0;
              For k := 1 to x^.cols do
                mp^ := mp^ + c[k] * y^.r^[k]^.c[j];
            end;
      end;
    MProd := result;
    Touch(x);
    Touch(y);
  end;
end;

{
As you can see, the memory allocation is a pretty minor part of it.  The
dynamic indexing is Really ugly (I'd like to use "y[k,j]", but I'm stuck using
"y^.r^[k]^.c[j]"), but I haven't found any way around that.
}

