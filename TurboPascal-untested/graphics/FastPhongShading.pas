(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0277.PAS
  Description: Fast Phong Shading
  Author: TOM HAMMERSLEY
  Date: 08-30-97  10:08
*)


 Fast Phong Shading, Theory and Practive
 Introduction

<I> Fast phong shading is always a goal of anyone writing a 3D engine.
Despite some of its failings, Phong shading is still common in 3D systems,
and people are always looking for faster and easier ways to approximate it.
In this page, I'll discuss firstly <I> real </I> phong shading, then some of
the approximations of it. I'll also explain why the document OTMPHONG.DOC
is utter nonsense, and should be avoided at all costs.

 Real </I> phong shading
<P> Real phong shading is done by interpolating the vertex normals across the
surface of a polygon, or triangle, and illuminating the pixel at each point,
usually using the phong lighting model. At each pixel, you need to
re-normalize the normal vector, and also calculate the reflection vector.
The reflection vector is calculated by:

R = 2.0*(N.L)*N - L

I found this vector also needs to be normalized. Then, we feed these vectors
into the illumination equation for the phong lighting model, which is

I = Ia*ka*Oda + fatt*Ip[kd*Od(N.L) + ks(R.V)^n]

Here, the variables are:
Ia is the ambient intensity
ka is the ambient co-efficient
Oda is the colour for the ambient
fatt is the atmospheric attenuation factor, ie depth shading
Ip is the intensity of the point light source
kd is the diffuse co-efficient
Od is the objects colour
ks is the specular co-efficient
n is the objects shinyness
N is the normal vector
L is the lighting vector
R is the reflection vector
V is the viewing vector



To do multiple light sources, you sum the term
fatt*Ip[kd*Od(N.L) + ks(R.V)^n] for each light source. Also,
you need to repeat this equation for each colour band you are interested in.

Such shading is incredibly expensive, and cannot be done in realtime on
common hardware. So, people have been looking into optimizations and
approximations of this for a long time.



Angular Interpolation

One idea is to avoid the expensive dot-product and normalization operations
by interpolating the angles. This sounds good in theory, but has a couple of
problems:

Choosing a function to do the interpolation
Perspective problems

In the file OTMPHONG.DOC, the idea was to interpolate the angle, or cosine of
the angle (I can't remember which) across the surface of the polygon. This
doesn't work, because:

Cosine is NOT linear
Using linear interpolation you cannot get a value outside of your start
value, and end value. So no highlight is possible.

OTMPHONG.DOC just re-invented Gouraud shading, and tried to turn it into
Phong shading. It doesn't really work very well. Yes, I have tried it, I've
tried a great deal of methods of implementing it, but it just doesn't work!

Another way I've heard of is using a Taylor series approximation.
Admittedly, I haven't tried this yet; from what I gather, the idea here is to
use a polynomial to approximate the cosine. People have used this in the past
to generate sin tables, in 4k intros and what have you, so it should be
possible. Again, I haven't tried it yet, if I ever do, I'll tell you what I
find.

A halfway-house is the highlight test. Here, a polygon is tested, to
see if the highlight falls on the polygon. If it doesn't, then you just use
plain gouraud shading. If it does, you use your phong shader. The test follows:

For any vertex, is N*H >= t (threshold) ? If so, highlight = TRUE
For any edge, is N*H >= t at any point on that edge? If so, highlight = TRUE
For all edge, does N*H exhibit a maximum? If so, highlight = TRUE
If none of the above conditions, highlight = FALSE

H is the halfway vector, (L + V) / 2. I found this algorithmn in the book
"3D Computer Graphics" by Alan Watt. I have yet to try this one, but it
sounds workable. The only problem might be slight discontinuities in the
shading. Again, this is guesswork, you'd have to implement it to see.

The Fake Method

Now I'll describe a method that is a bit odd, yet works very well in
practice. Its the method most demos use to do their 'phong' shading, and is
very fast.

First, we need to generate a 'highlight map'. This is a texture, which
consists of concentric circles, the brightest in the middle, decreasing in
brightness as they go outwards. So it looks like a highlight. This is easy
enough to generate, a simple way being to take the distance from the centre,
and get it into the range 0..256. Also, this map should be 256x256, for
efficiency reasons.

Now we need to map the highlight onto the object. Again, this is easy to do.
Take your vertex normal X value, multiply it by 128, and add 127 to it. Do
the same for Y. Call these values P, Q (save confusion with U,V - texture
co-ords). These are our texture co-ordinates! Now simply map the texture to
the object, and hey presto, one nicely shaded object. As you rotate the
object, the highlights will also move. Its a very handy algorithmn I think,
if a little odd. Its based on a trick called environment mapping, which you
will find described elsewhere in these pages. You'll also notice that if you
go behind your object, the lighting is the same. Another problem with the
algorithm. Take is an extra light source for free. Also, as this method is
based on environment mapping, its only correct for parallel projection.
But don't let that spoil your fun!

Extending this to multiple light sources shouldn't be too hard. For 2 light
sources, you would have 2 maps, each having values in the range 0..128. You
would then add them together, to get a colour value. Moving the light source
around involves changing the P and Q values; using the normals sort of works,
but after about 90 degrees, weird things start to happen.

Also one other thought. The phong map is basically a bunch of
circles:

So, it is symmetrical about the centre. Why not just use one quadrant
of the map, then use sign and quadrant information to convert the u,v
co-ordinates? Would say some memory... Like so:

Well, I hope I helped to demistify Phong shading, and disprove some of the
myths surrounding the subject. So please, don't come onto #coders, asking
how to implement phong shading, or asking about that gibberish otmphong.doc
file, you have all the information you need right here.

Tom Hammersley, <A HREF="mailto:tomh@globalnet.co.uk"> tomh@globalnet.co.uk</A>

Please don't call the fake phong shading method phong shading. It gets
us all confused. Can someone please think up a good name for that method,
and use that instead? After all, fools gold is not gold, no matter how much
it glitters




