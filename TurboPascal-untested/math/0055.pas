{
> If I get  inspired, I will add simple perspective transform to these.
> There, got inspired. Made mistakes. Foley et al are not very good at
> tutoring perspective and I'm kinda ready to be done and post this.

>   line(round(x1)+200,round(y1)+200,
>        round(x2)+200,round(y2)+200);

try this for perspective (perspecitve is easy to calculate but hard to
explain... I worked it out with a pencil and paper using "similar
triangles, and a whole heap of other math I never thought I'd need, it
took me the best part of 30 minutes but when I saw how simple it really
is...)

 this code gives an approximation of perspective... it's pretty good
 when K is more than 3 times the size (maximum dimension) of the object

K is some constant... (any constant, about 3-10 times the size of the
object is good) (K is actually the displacement of the viewpoint down
the -Z axis. or something like) K=600 would be a good starting point
}

   line(round(x1/(K+z1)*K)+200,round(y1/(K/z1)*K)+200,
        round(x2/(K+z2)*K)+200,round(y2/(K/z2)*K)+200);

{ not computationally efficient but it shows how it works.
  Here's one that gives "real perspective"
}

   line(round(x1/sqrt(sqr(K+z1)+sqr(x1)+sqr(y1))*K,
        round(y1/sqrt(sqr(K+y1)+sqr(y1)+sqr(y1))*K,
        round(x2/sqrt(sqr(K+z2)+sqr(x2)+sqr(y2))*K,
        round(y2/sqrt(sqr(K+y2)+sqr(y2)+sqr(y2))*K);

