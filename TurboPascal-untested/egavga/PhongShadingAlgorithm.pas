(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0221.PAS
  Description: Phong Shading Algorithm
  Author: JEROEN BOUWENS
  Date: 05-26-95  23:24
*)

{
Well, I finally managed to get my hands on this book describing an algorithm
for phong shading using only two additions. I'll use ∙ for the dot-product (I
assume you know how to calculate a dot-product :-)

Here goes:

For the intensity at a certain point in a triangle with normals N1, N2 and N3
at the vertices, and with a vector L pointing to the light-source:

                       ax+by+c
  I(x,y) = ────────────────────────────────────
           √(d*x² + e*x*y + f*y² + gx + hy + i)

where:
         a = Lu  ∙ N1
         b = Lu  ∙ N2
         c = Lu  ∙ N3
         d = N1  ∙ N1
         e = 2N1 ∙ N2
         f = N2  ∙ N2
         g = 2N1 ∙ N3
         h = 2N2 ∙ N3
         i = N3  ∙ N3
              L
        Lu = ───
             │L│

I hope the extended characters come thru :-).

This can be simplified (?) to:

  I(x,y) = Ω5*x² + Ω4*x*y + Ω3*y² + Ω2*x + Ω1*y + Ω0 

with:       c 
      Ω0 = ───
           √i

           2*b*i - c*h
      Ω1 = ───────────
             2*i*√i

           2*a*i - c*g
      Ω2 = ───────────
             2*i*√i

           3*c*h² - 4*c*f*i - 4*b*h*i
      Ω3 = ──────────────────────────
                   8*i²*√i 

           3*c*g*h - 2*c*e*i - 2*b*g*i - 2*a*h*i
      Ω4 = ─────────────────────────────────────
                         4*i²*√i

           3*i*g² - 4*c*d*i - 4*a*g*i
      Ω5 = ──────────────────────────
                   8*i²*√i


Which can be rewritten as:

  I(x,y) = Ω5*x² + x(Ω4*y + Ω2) + Ω3*y² + Ω1*y + Ω0

Thus needing only 2 additions per pixel.
}

