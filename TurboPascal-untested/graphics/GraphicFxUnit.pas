(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0019.PAS
  Description: Graphic FX Unit
  Author: ANDRE JAKOBS
  Date: 08-27-93  21:25
*)

{
I hope you can do something With these listings
I downloaded from a BBS near me....
This File contains:  Program VGA3d
                     Unit DDFigs
                     Unit DDVars
                     Unit DDVideo
                     Unit DDProcs
Just break it in pieces on the cut here signs......

if you need some Units or Programs (or TxtFiles) on Programming the Adlib/
Sound-Blaster or Roland MPU-401, just let me know, and i see if i can dig
up some good listings.....
But , will your game also have Soundblaster/adlib fm support and Sound
Blaster Digitized Sound support, maybe even MPU/MT32? support....
And try to make it as bloody as you can (Heads exploding etc..)(JOKE)

I hope i you can complete your game (i haven't completed any of my games yet)
And i like a copy of it when it's ready......

Please leave a message if you received this File.

  Andre Jakobs
    MicroBrain Technologies Inc.
        GelderlandLaan 9
          5691 KL   Son en Breugel
            The Netherlands............
}


Program animatie_van_3d_vector_grafics;

Uses
  Crt,
  ddvideo,
  ddfigs,
  ddprocs,
  ddVars;

Var
  Opal : paletteType;

Procedure wireframe(pro : vertex2Array);
{ Teken een lijnen diagram van gesloten voorwerpen met vlakken }
Var
  i, j, k,
  v1, v2  : Integer;
begin
  For i :=  1 to ntf DO
  begin
    j := nfac[i];
    if j <> 0 then
    begin
      v1 := faclist[ facfront[j] + size[j] ];
      For k :=  1 to size[j] DO
      begin
        v2 := faclist[facfront[j] + k];
        if (v1<v2) or (super[i] <> 0 ) then
          linepto(colour[j], pro[v1], pro[v2])
        v1 := v2;
      end;
    end;
  end;
end;

Procedure hidden(pro : vertex2Array);
{ Display van Objecten als geheel van de projectiepunten van pro }
{ b is een masker voor de kleuren }
Var
  i,  col : Integer;

  Function signe( n : Real) : Integer;
  begin
    if n >0 then
      signe := -1
    else
    if n <0 then
      signe := 1
    else
      signe := 0;
  end;

  Function orient(f : Integer; v : vertex2Array) : Integer;
  Var
    i, ind1,
    ind2, ind3 : Integer;
    dv1, dv2   : vector2;
  begin
    i := nfac[f];
    if i = 0 then
      orient := 0
    else
    begin
      ind1   := faclist[facfront[i] + 1];
      ind2   := faclist[facfront[i] + 2];
      ind3   := faclist[facfront[i] + 3];
      dv1.x  := v[ind2].x - v[ind1].x;
      dv1.y  := v[ind2].y - v[ind1].y;
      dv2.x  := v[ind3].x - v[ind2].x;
      dv2.y  := v[ind3].y - v[ind2].y;
      orient := signe(dv1.x * dv2.y - dv2.x * dv1.y);
    end;
  end;

  Procedure facetfill(k : Integer);
  Var
    v           : vector2Array;
    i, index, j : Integer;
  begin
    j := nfac[k];
    For i :=  1 to size[j] DO
    begin
      index := faclist[facfront[j] + i];
      v[i]  := pro[index];
    end;
    fillpoly(colour[k], size[j], v);
    polydraw(colour[k] - 1, size[j], v);
  end;

  Procedure seefacet(k : Integer);
  Var
    ipt, supk : Integer;
  begin
    facetfill(k);
    ipt := firstsup[k];
    While ipt <> 0 DO
    begin
      supk := facetinfacet[ipt].info;
       facetfill(supk);
      ipt := facetinfacet[ipt].Pointer;
    end;
  end;

{ hidden Programmacode }
begin
  For i := 1 to nof DO
  if super[i] = 0 then
    if orient(i, pro) = 1 then
      seefacet(i);
end;

Procedure display;
Var
  i : Integer;
begin
  {observe}
  For i := 1 to nov DO
    transform(act[i], Q, obs[i]);

  {project}
  ntv := nov;
  ntf := nof;
  For i := 1 to ntv DO
  begin
    pro[i].x := obs[i].x;
    pro[i].y := obs[i].y;
  end;

  {drawit}
  switch := switch xor 1;
  hidden(pro);
  Scherm_actief(switch);
  Virscherm_actief(switch xor 1);
  wisscherm(prevpoints, $a000, $8a00);
  wis_hline(prevhline, $8a00);
  prevpoints := points;prevhline := hline;
  points[0]  := 0;
  hline[0]   := 0;
end;

Procedure anim3d;
Var
  A, B, C, D, E, F,
  G, H, I, J, QE, P    : matrix4x4;
  zoom, inz, inzplus   : Real;
  angle, angleinc,
  beta, betainc, frame : Integer;
  huidigpalette        : paletteType;

  { Kubus Animatie : Roterende kubus }
  Procedure kubus;
  begin
    angle    := 0;
    angleinc := 9;
    beta     := 0;
    betainc  := 2;
    direct.x := 9;
    direct.y := 2;
    direct.z := -3;
    findQ;
    cubesetup(104);
    frame := 0;

    While (NOT (KeyPressed)) and (frame < 91) do
    begin
      frame   := frame + 1;
      xyscale := zoom * 2 * sinus(beta);
      rot3(1, trunc(angle/2), Qe);
      rot3(2, angle, P);
      mult3(P, Qe, P);
      cube(P);
      display;
      angle := angle + angleinc;
      beta  := beta + betainc;
      nov   := 0;
    end;
  end;

  {Piramides Animatie : Scene opgebouwd uit twee Piramides en 1 Kubus }
  Procedure Piramides;
  begin
    frame   := 0;
    angle   := 0;
    beta    := 0;
    betainc := 2;
    scale3(4.0, 0.2, 4.0, C);
    cubesetup(90);
    cube(P);

    scale3(2.5, 4.0, 2.5, D);
    tran3(2.0, -0.2, 2.0, E);
    mult3(E, D, F);
    pirasetup(34);
    piramid(P);

    scale3(2.0, 4.0, 2.0, G);
    tran3(-3.0, -0.2, 0.0, H);
    mult3(H, G, I);
    pirasetup(42);
    piramid(P);

    E := Q;
    nov := 0;

    While (NOT (KeyPressed)) and (frame < 18) do
    begin
      frame   := frame + 1;
      xyscale := zoom * 2 * sinus(beta);

      rot3(2, angle, B);

      mult3(B, C, P);
      cube(P);

      mult3(B, F, P);
      piramid(P);

      mult3(B, I, P);
      piramid(P);

      display;

      angle := angle + angleinc;
      beta  := beta + betainc;
      nov   := 0;
     end;

     frame := 0;
     angleinc := 7;

     While (NOT (KeyPressed)) and (frame < 75) do
     begin
       frame := frame + 1;

       rot3(2, angle, B);

       mult3(B, C, P);
       cube(P);

       mult3(B, F, P);
       piramid(P);

       mult3(B, I, P);
       piramid(P);

       display;

       angle := angle + angleinc;
       nov   := 0;
     end;

     frame := 0;
     beta := 180-beta;

     While (NOT (KeyPressed)) and (frame < 19) do
     begin

       frame := frame + 1;

       xyscale := zoom * 2 * sinus(beta);
       rot3(2, angle, B);

       mult3(C, B, P);
       cube(P);

       mult3(B, F, P);
       piramid(P);

       mult3(B, I, P);
       piramid(P);

       display;

       angle := angle + angleinc;
       beta  := beta  + betainc;
       nov   := 0;
    end;
  end;

  { Huis_animatie4 : Figuur huis roteert en "komt uit de lucht vallen" }
  Procedure huisval;
  begin
    xyscale  := zoom;
    nof      := 0;
    nov      := 0;
    last     := 0;
    angle    := 1355;
    angleinc := -7;
    frame    := 0;

    huissetup;

    zoom     := 0.02;
    Direct.x := 30;
    direct.y := -2;
    direct.z := 30;
    findQ;

    While (NOT (KeyPressed)) and (frame < 40) do
    begin
      frame := frame + 1;
      zoom  := zoom + 0.01;
      Scale3(zoom, zoom, zoom, Qe);
      tran3(0, (-7 / zoom) + frame / 1.8, 0, A);
      mult3(Qe, A, C);
      rot3(2, angle, B);
      mult3(C, B, P);
      huis(P);
      display;
      angle := angle + angleinc;
      nov   := 0;
    end;

    frame   := 0;
    beta    := angle;
    betainc := angleinc;

    While (NOT (KeyPressed)) and (frame < 15) do
    begin
      frame := frame + 1;

      rot3(2, beta, B);
      mult3(B, Qe, P);
      mult3(P, A, P);
      huis(P);

      display;

      beta    := beta + betainc;
      betainc := trunc(betainc + (7 / 15));
      nov     := 0;
    end;

    frame := 0;

    While (NOT (KeyPressed)) and (frame < 30) do
    begin
      frame    := frame + 1;
      direct.z := direct.z - (frame * (20 / 70));
      findQ;
      huis(P);
      display;
      nov := 0;
    end;

    frame := 0;
    zoom  := 1;

    While (NOT (KeyPressed)) and (frame < 31) do
    begin
      frame := frame + 1;
      mult3(B, Qe, P);
      scale3(zoom, zoom, zoom, C);
      mult3(P, A, P);
      mult3(P, C, P);
      huis(P);
      display;
      zoom := zoom - 1 / 30;
      nov  := 0;
    end;

    zoom := xyscale;
  end;

  { Ster Animatie : Roterende ster als kubus met 4 piramides }
  Procedure Sterrot;
  begin
    xyscale  := zoom;
    frame    := 0;
    angle    := 0;
    angleinc := 9;
    beta     := 0;
    betainc  := 2;
    nof      := 0;
    last     := 0;
    nov      := 0;

    stersetup(140);
    scale3(0, 0, 0, P);
    ster(P, 4);

    Direct.x := 30;
    direct.y := -2;
    direct.z := 30;
    findQ;
    E := Q;

    While (NOT (KeyPressed)) and (frame < 90) do
    begin
      frame   := frame + 1;
      xyscale := zoom * 1.7 * sinus(beta);
      rot3(1, Round(angle/5), A);
      mult3(A, E, Q);
      rot3(2, angle, P);
      ster(P, 4);
      display;
      angle := angle + angleinc;
      beta  := beta  + betainc;
      nov   := 0;
    end;
  end;

begin
  eye.x := 0;
  eye.y := 0;
  eye.z :=  0;
  zoom  := xyscale;
  Repeat
    nov  := 0;
    nof  := 0;
    last := 0;
    Kubus;
    Piramides;
    Huisval;
    Sterrot;
  Until KeyPressed;
end;

{ _______________Hoofd Programma --------------------- }

begin
  nov  := 0;
  nof  := 0;
  last := 0;
  start('pira', 15,  Opal);

  points[0]     := 0;
  prevpoints[0] := 0;
  hline[0]      := 0;
  prevhline[0]  := 0;

  anim3D;

  finish(Opal);
  Writeln('Coded by ...... " De Vectorman "');
  Writeln;
end.


{ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ }

Unit ddfigs;

Interface

Uses
  DDprocs, DDVars;

Const
  cubevert : Array [1..8] of vector3 =
    ((x :  1; y :  1; z :  1),
     (x :  1; y : -1; z :  1),
     (x :  1; y : -1; z : -1),
     (x :  1; y :  1; z : -1),
     (x : -1; y :  1; z :  1),
     (x : -1; y : -1; z :  1),
     (x : -1; y : -1; z : -1),
     (x : -1; y :  1; z : -1));

  cubefacet : Array [1..6, 1..4] of Integer =
    ((1, 2, 3, 4),
     (1, 4, 8, 5),
     (1, 5, 6, 2),
     (3, 7, 8, 4),
     (2, 6, 7, 3),
     (5, 8, 7, 6));

  piravert  : Array [1..5] of vector3 =
    ((x :  0; y :  1; z :  0),
     (x :  1; y :  0; z : -1),
     (x : -1; y :  0; z : -1),
     (x : -1; y :  0; z :  1),
     (x :  1; y :  0; z :  1));

  pirafacet : Array [1..5, 1..3] of Integer =
    ((1, 2, 3),
     (1, 3, 4),
     (1, 4, 5),
     (1, 5, 2),
     (5, 4, 3));

  huisvert  : Array[1..59] of vector3 =
    ((x : -6; y :  0; z :  4), (x :  6; y : 0; z :  4),
     (x :  6; y :  0; z : -4),
     (x : -6; y :  0; z : -4), (x : -6; y : 8; z :  4), (x :  6; y : 8; z :  4),
     (x :  6; y : 11; z :  0), (x :  6; y : 8; z : -4), (x : -6; y : 8; z : -4),
     (x : -6; y : 11; z :  0), (x : -4; y : 1; z :  4), (x : -1; y : 1; z :  4),
     (x : -1; y :  3; z :  4), (x : -4; y : 3; z :  4), (x : -4; y : 5; z :  4),
     (x : -1; y :  5; z :  4), (x : -1; y : 7; z :  4), (x : -4; y : 7; z :  4),
     (x :  0; y :  0; z :  4), (x :  5; y : 0; z :  4), (x :  5; y : 4; z :  4),
     (x :  0; y :  4; z :  4), (x :  1; y : 5; z :  4), (x :  4; y : 5; z :  4),
     (x :  4; y :  7; z :  4), (x :  1; y : 7; z :  4), (x :  6; y : 5; z : -1),
     (x :  6; y :  5; z : -3), (x :  6; y : 7; z : -3), (x :  6; y : 7; z : -1),
     (x :  5; y :  1; z : -4), (x :  2; y : 1; z : -4), (x :  2; y : 3; z : -4),
     (x :  5; y :  3; z : -4), (x :  5; y : 5; z : -4), (x :  2; y : 5; z : -4),
     (x :  2; y :  7; z : -4), (x :  5; y : 7; z : -4), (x :  1; y : 0; z : -4),
     (x : -1; y :  0; z : -4), (x : -1; y : 3; z : -4), (x :  0; y : 4; z : -4),
     (x :  1; y :  3; z : -4), (x : -2; y : 1; z : -4), (x : -5; y : 1; z : -4),
     (x : -5; y :  3; z : -4), (x : -2; y : 3; z : -4), (x : -2; y : 5; z : -4),
     (x : -5; y :  5; z : -4), (x : -5; y : 7; z : -4), (x : -2; y : 7; z : -4),
     (x : -6; y :  0; z :  1), (x : -6; y : 0; z :  3), (x : -6; y : 3; z :  3),
     (x : -6; y :  3; z :  1), (x : -6; y : 5; z :  1), (x : -6; y : 5; z :  3),
     (x : -6; y :  7; z :  3), (x : -6; y : 7; z :  1));

  huissize  : Array [1..19] of Integer =
    (4, 4, 5, 4, 4, 5, 4, 4, 4, 4, 4, 4, 4, 4, 5, 4, 4, 4, 4);

  huissuper : Array [1..19] of Integer =
    (0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 3, 4, 4, 4, 4, 4, 6, 6);

  huisfacet : Array [1..79] of Integer =
    ( 1,  2,  6,  5,
      5,  6,  7, 10,
      2,  3,  8,  7,
      6,  3,  4,  9,
      8,  8,  9, 10,
      7,  4,  1,  5,
     10,  9,  4,  3,
      2,  1, 11, 12,
     13, 14, 15, 16,
     17, 18, 19, 20,
     21, 22, 23, 24,
     25, 26, 27, 28,
     29, 30, 31, 32,
     33, 34, 35, 36,
     37, 38, 39, 40,
     41, 42, 43, 44,
     45, 46, 47, 48,
     49, 50, 51, 52,
     53, 54, 55, 56,
     57, 58, 59);

  stervert : Array [1..6] of vector3 =
    ((x :  1; y :  0; z :  0),
     (x :  0; y :  1; z :  0),
     (x :  0; y :  0; z :  1),
     (x :  0; y :  0; z : -1),
     (x :  0; y : -1; z :  0),
     (x : -1; y :  0; z :  0));

Procedure cubesetup(c : Integer);
Procedure cube(P : matrix4x4);
Procedure pirasetup(c : Integer);
Procedure piramid(P : matrix4x4);
Procedure huissetup;
Procedure huis(P : matrix4x4);
Procedure hollow(P1 : matrix4x4);
Procedure stersetup(col : Integer);
Procedure ster(P : matrix4x4; d : Real);
Procedure ellips(P : matrix4x4; col : Integer);
Procedure goblet(P : matrix4x4; col : Integer);

Implementation

Procedure cubesetup(c : Integer);
{ zet kubusdata in facetlist van de scene}
Var
  i, j : Integer;
begin
  For i :=  1 to 6 DO
  begin
    For j := 1 to 4 DO
      faclist[last + j] := cubefacet[i, j] + nov;
    nof := nof + 1;
    facfront[nof] := last;
    colour[nof]   := c;
    nfac[nof]     := nof;
    super[nof]    := 0;
    firstsup[nof] := 0;
    size[nof]     := 4;
    last := last + size[nof];
  end;
end;

Procedure cube(P : matrix4x4);
Var
  i, j : Integer;
begin
  For i :=  1 to 8 DO
  begin
    nov := nov + 1;
    transform(cubevert[i], P, act[nov]);
  end;
end;

Procedure pirasetup(c : Integer);
Var
  i, j : Integer;
begin
  For i :=  1 to 5 DO
  begin
    For j := 1 to 3 DO
      faclist[last + j] := pirafacet[i, j] + nov;
    nof := nof + 1;
    facfront[nof] := last;
    size[nof]     := 3;
    last          := last + size[nof];
    colour[nof]   := c;
    nfac[nof]     := nof;
    super[nof]    := 0;
    firstsup[nof] := 0;
  end;

  size[nof] := 4;
  faclist[facfront[nof] + 4] := 2 + nov;
  last := last + 1;
end;

Procedure piramid(P : matrix4x4);
Var
  i, j : Integer;
begin
  For i :=  1 to 5 DO
  begin
    nov := nov + 1;
    transform(piravert[i], P, act[nov]);
  end;
end;


Procedure huissetup;
Var
  i, j,
  host,
  nofstore : Integer;
begin
  For i := 1 to 79 DO
    faclist[last + i] := huisfacet[i] + nov;

  nofstore := nof;

  For i := 1 to 19 DO
  begin
    nof           := nof + 1;
    facfront[nof] := last;
    size[nof]     := huissize[i];
    last          := last + size[nof];
    nfac[nof]     := nof;

    if (i = 2) or (i = 5) then
      colour[nof] := 111
    else
    if i = 7 then
      colour[nof] := 20
    else
    if i < 8 then
      colour[nof] := 42
    else
      colour[nof] := 25;

    super[nof] := huissuper[i];
    firstsup[nof] := 0;

    if super[nof] <> 0 then
    begin
      host := super[nof] + nofstore;
      super[nof] := host;
      pushfacet(firstsup[host], nof);
    end;
  end;
  For i  :=  1 to 59 DO
    setup[i] := huisvert[i];
end;

Procedure huis(P : matrix4x4);
Var
  i : Integer;
begin
  For i := 1 to 59 DO
  begin
    nov := nov + 1;
    transform(setup[i], P, act[nov]);
  end;
end;


Procedure hollow(P1 : matrix4x4);
Var
  A, B,
  P, P2 : matrix4x4;
  i     : Integer;
begin
  For i := 1 to 8 DO
  begin
    tran3(4.0 * cubevert[i].x, 4.0 * cubevert[i].y, 4.0 * cubevert[i].z, P2);
    mult3(P1, P2, P);
    cube(P);
  end;

  For i := 1 to 4 DO
  begin
    scale3(3.0, 1.0, 1.0, A);
    tran3(0.0, 4.0 * cubevert[i].y, 4.0 * cubevert[i].z, B);
    mult3(A, B, P2);mult3(P1, P2, P);
    cube(P);
    scale3(1.0, 3.0, 1.0, A);
    tran3(4.0 * cubevert[i].y, 0.0, 4.0 * cubevert[i].z, B);
    mult3(A, B, P2);mult3(P1, P2, P);
    cube(P);
    scale3(1.0, 1.0, 3.0, A);
    tran3(4.0 * cubevert[i].z, 4.0 * cubevert[i].y, 0.0, B);
    mult3(A, B, P2);mult3(P1, P2, P);
    cube(P);
  end;
end;

Procedure stersetup(col : Integer);
Var
  i, j,
  v1, v2 : Integer;
begin
  For i := 1 to 6 DO
  begin
    v1 := cubefacet[i, 4] + nov;
    For j := 1 to 4 DO
    begin
      v2  := cubefacet[i, j] + nov;
      nof := nof + 1;
      faclist[last + 1] := v1;
      faclist[last + 2] := v2;
      faclist[last + 3] := nov + 8 + i;
      facfront[nof]     := last;
      size[nof] := 3;

      last := last + size[nof];
      colour[nof] := col;
      nfac[nof]   := nof;
      super[nof]  := 0;
      firstsup[nof] := 0;
      v1 := v2;
    end;
  end;
end;

Procedure ster(P : matrix4x4; d : Real);
Var
  i, j,
  v1, v2 : Integer;
  A, S   : matrix4x4;
begin
  For i :=  1 to 8 DO
  begin
    nov := nov + 1;
    transform(cubevert[i], P, act[nov]);
  end;

  scale3(D, D, D, A);
  mult3(A, P, S);

  For i := 1 to 6 DO
  begin
    nov := nov + 1;
    transform(stervert[i], S, act[nov]);
  end;
end;

Procedure ellips(P : matrix4x4; col : Integer);
Var
  v : vector2Array;
  theta,
  thetadiff,
  i : Integer;
begin
  theta := -90;
  thetadiff := -9;
  For i :=  1 to 21 DO
  begin
    v[i].x := cosin(theta);
    v[i].y := sinus(theta);
    theta  := theta + thetadiff;
  end;
  bodyofrev(P, col, 21, 20, v);
end;

Procedure goblet(P : matrix4x4; col : Integer);
Const
  gobletdat : Array [1..12] of vector2 =
    ((x :  0; y : -16),
     (x :  8; y : -16),
     (x :  8; y : -15),
     (x :  1; y : -15),
     (x :  1; y :  -2),
     (x :  6; y :  -1),
     (x :  8; y :   2),
     (x : 14; y :  14),
     (x : 13; y :  14),
     (x :  7; y :   2),
     (x :  5; y :   0),
     (x :  0; y :   0));

Var
  gobl : vector2Array;
  i    : Integer;
begin
  For i := 1 to 12 DO
    gobl[i] := gobletdat[i];
  bodyofrev(P, col, 12, 20, gobl)
end;

begin;
end.


{ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ }

Unit ddprocs;

Interface

Uses
  DDVars;

Const
  maxv = 200;
  maxf = 400;
  maxlist = 1000;
  vectorArraysize  = 32;
  sizeofpixelArray = 3200;
  sizeofhlineArray = 320 * 4;

Type
  vector2      = Record x, y : Real; end;
  vector3      = Record x, y, z : Real; end;
  pixelvector  = Record x, y : Integer; end;
  pixelArray   = Array [0..sizeofpixelArray] of Integer;
  hlineArray   = Array [0..sizeofhlineArray] of Integer;
  vector3Array = Array [1..vectorArraysize] of vector3;
  matrix3x3    = Array [1..3, 1..3] of Real;
  matrix4x4    = Array [1..4, 1..4] of Real;
  vertex3Array = Array [1..maxv] of vector3;
  vertex2Array = Array [1..maxv] of vector2;
  vector2Array = Array [1..vectorArraysize ] of vector2;
  facetArray   = Array [1..maxf] of Integer;
  facetlist    = Array [1..maxlist] of Integer;

Const
  EenheidsM : matrix4x4 =
    ((1, 0, 0, 0),
     (0, 1, 0, 0),
     (0, 0, 1, 0),
     (0, 0, 0, 1));
Var
  Q           : matrix4x4;
  eye, direct : vector3;
  nov, ntv,
  ntf, nof,
  last        : Integer;
  setup,
  act, obs    : vertex3Array;
  pro         : vertex2Array;
  faclist     : facetlist;
  colour,
  size,
  facfront,
  nfac,
  super,
  firstsup    : facetArray;
  points,
  prevpoints  : pixelArray;
  hline,
  prevhline   : hlineArray;

Procedure tran3(tx, ty, tz : Real; Var A : matrix4x4);
Procedure scale3(sx, sy, sz : Real; Var A : matrix4x4);
Procedure rot3(m : Integer; theta : Integer; Var A : matrix4x4);
Procedure mult3(A, B : matrix4x4; Var C : matrix4x4);
Procedure findQ;
Procedure genrot(phi : Integer; b, d : vector3; Var A : matrix4x4);
Procedure transform(v : vector3; A : matrix4x4; Var w : vector3);
Procedure extrude(P : matrix4x4; d : Real; col, n : Integer;
                  v : vector2Array);
Procedure bodyofrev(P : matrix4x4; col, nvert, nhoriz : Integer;
                    v : vector2Array);
Procedure polydraw(c, n : Integer; poly : vector2Array);
Procedure linepto(c : Integer; pt1, pt2 : vector2);
Procedure WisScherm(punten : pixelArray; SchermSeg, VirSeg : Word);
Procedure fillpoly(c, n : Integer; poly : vector2Array);
Procedure Wis_Hline(hline_ar : hlineArray; virseg : Word);

Implementation

Procedure tran3(tx, ty, tz : Real; Var A : matrix4x4);
{ zet matrix A op punt tx, ty, tz }
begin
  A := EenheidsM;
  A[1, 4] := -tx;
  A[2, 4] := -ty;
  A[3, 4] := -tz;
end;

Procedure scale3(sx, sy, sz : Real; Var A : matrix4x4);
{ zet matrix A om in schaal van sx, sy, sz }
begin
  A := EenheidsM;
  A[1, 1] := sx;
  A[2, 2] := sy;
  A[3, 3] := sz;
end;

Procedure rot3(m : Integer; theta : Integer; Var A : matrix4x4);
{ roteer matrix A om m: 1=x-as; 2=y-as; 3=z-as met hoek theta (in graden)}
Var
  m1, m2 : Integer;
  c, s   : Real;
begin
  A  := EenheidsM;
  m1 := (m MOD 3) + 1;
  m2 := (m1 MOD 3) + 1;
  c  := cosin(theta);
  s  := sinus(theta);
  A[m1, m1] := c;
  A[m2, m2] := c;
  A[m1, m2] := s;
  A[m2, m1] := -s;
end;

Procedure mult3(A, B : matrix4x4; Var C : matrix4x4);
{ vermenigvuldigd matrix A en B naar matrix C }
Var
  i, j, k : Integer;
  ab      : Real;
begin
  For i := 1 to 4 do
    For j :=  1 to 4 do
    begin
      ab := 0;
      For k := 1 to 4 do
        ab := ab + A[i, k] * B[k, j];
      C[i, j] := ab;
    end;
end;

Procedure findQ;
{ Bereken de Observatie-matrix 'Q' voor een punt in de ruimte }
Var
  E, F, G,
  H, U    : matrix4x4;
  alpha,
  beta,
  gamma   : Integer;
  v, w    : Real;
begin
  tran3(eye.x, eye.y, eye.z, F);

  alpha := angle(-direct.x, -direct.y);
  rot3(3, alpha, G);

  v :=  sqrt( (direct.x * direct.x) + (direct.y * direct.y));
  beta := angle(-direct.z, v);
  rot3(2, beta, H);

  w :=  sqrt( (v * v) + (direct.z * direct.z));
  gamma := angle( -direct.x * w,  direct.y * direct.z);
  rot3(3, gamma, U);

  mult3(G, F, Q);
  mult3(H, Q, E);
  mult3(U, E, Q);
end;

Procedure genrot (phi : Integer; b, d : vector3; Var A : matrix4x4);
Var
  F, G, H,
  W, FI, GI,
  HI, S, T  : matrix4x4;
  v         : Real;
  beta,
  theta     : Integer;
begin
  tran3(b.x, b.y, b.z, F);
  tran3(-b.x, -b.y, -b.z, FI);
  theta := angle(d.x, d.y);
  rot3(3, theta, G);
  rot3(3, -theta, GI);
  v := sqrt(d.x * d.x + d.y * d.y);
  beta := angle(d.z, v);
  rot3(2, beta, H);
  rot3(2, -beta, HI);
  rot3(2, beta, H);
  rot3(2, -beta, HI);
  rot3(3, phi, W);
  mult3(G, F, S);
  mult3(H, S, T);
  mult3(W, S, T);
  mult3(HI, S, T);
  mult3(GI, T, S);
  mult3(FI, S, A);
end;

Procedure transform(v : vector3; A : matrix4x4; Var w : vector3);
{ transformeer colomvector 'v' uit A in colomvector 'w'}
begin
  w.x := A[1, 1] * v.x + A[1, 2] * v.y + A[1, 3] * v.z + A[1, 4];
  w.y := A[2, 1] * v.x + A[2, 2] * v.y + A[2, 3] * v.z + A[2, 4];
  w.z := A[3, 1] * v.x + A[3, 2] * v.y + A[3, 3] * v.z + A[3, 4];
end;

Procedure extrude(P : matrix4x4; d : Real; col, n : Integer;
                  v : vector2Array);
{ Maakt van een 2d-figuur een 3d-figuur }
{ vb: converteert 2d-letters naar 3d-letters }
Var
  i, j,
  lasti : Integer;
  v3    : vector3;
begin
  For i := 1 to n DO
  begin
    faclist[last + i] := nov + i;
    faclist[last + n + i] := nov + 2 * n + 1 - i;
  end;
  facfront[nof + 1] := last;
  facfront[nof + 2] := last + n;
  size[nof + 1] := n;
  size[nof + 2] := n;
  nfac[nof + 1] := nof + 1;
  nfac[nof + 2] := nof + 2;
  super[nof + 1] := 0;
  super[nof + 2] := 0;
  firstsup[nof + 1] := 0;
  firstsup[nof + 2] := 0;
  colour[nof + 1] := col;
  colour[nof + 2] := col;
  last  := last + 2 * n;
  nof   := nof + 2;
  lasti := n;

  For i := 1 to n DO
  begin
    faclist[last + 1] := nov + i;
    faclist[last + 2] := nov + lasti;
    faclist[last + 3] := nov + n + lasti;
    faclist[last + 4] := nov + n + i;
    nof := nof + 1 ;
    facfront[nof] := last;
    size[nof]     := 4;
    nfac[nof]     := nof;
    super[nof]    := 0;
    firstsup[nof] := 0;
    colour[nof]   := col;
    last  := last + 4;
    lasti := i;
  end;
  For i :=  1 To n DO
  begin
    v3.x := v[i].x;
    v3.y := v[i].y;
    v3.z := 0.0;
    nov  := nov + 1;
    transform(v3, P, act[nov]);
    v3.z := -d;
    transform(v3, P, act[nov + n]);
  end;
  nov := nov + n;
end;

Procedure bodyofrev(P : matrix4x4; col, nvert, nhoriz : Integer;
                    v : vector2Array);
{ maakt een "rond" figuur van een 2-dimensionale omlijning van het figuur }
Var
  theta,
  thetadiff,
  i, j, newnov : Integer;
  c, s         : Array [1 .. 100] of Real;
  index1,
  index2       : Array [1 .. 101] of Integer;
begin
  theta := 0;
  thetadiff := trunc(360 / nhoriz);

  For i := 1 to nhoriz DO
  begin
    c[i]  := cosin(theta);
    s[i]  := sinus(theta);
    theta := theta + thetadiff;
  end;
  newnov := nov;

  if abs(v[1].x) < epsilon  then
  begin
    newnov := newnov + 1;
    setup[newnov].x := 0.0;
    setup[newnov].y := v[1].y;
    setup[newnov].z := 0.0;
    For i := 1 to nhoriz + 1 DO
      index1[i] := newnov;
  end
  else
  begin
    For i := 1 to nhoriz DO
    begin
      newnov := newnov + 1;
      setup[newnov].x := v[1].x * c[i];
      setup[newnov].y := v[1].y;
      setup[newnov].z := -v[1].x * s[i];
      index1[i] := newnov;
    end;
    index1[nhoriz + 1] := index1[i];
  end;

  For j :=  2 to nvert DO
  begin
    if abs(v[j].x) < epsilon then
    begin
      newnov := newnov + 1;
      setup[newnov].x := 0.0;
      setup[newnov].y := v[j].y;
      setup[newnov].z := 0.0;
      For i := 1 to nhoriz + 1 DO
        index2[i] := newnov;
    end
    else
    begin
      For i := 1 To nhoriz DO
      begin
        newnov := newnov + 1;
        setup[newnov].x :=  v[j].x * c[i];
        setup[newnov].y :=  v[j].y;
        setup[newnov].z := -v[j].x * s[i];
        index2[i] := newnov;
      end;
      index2[nhoriz + 1] := index2[1];
    end;

    if index1[1] <> index1[2] then
      if index2[1] = index2[2] then
      begin
        For i := 1 to nhoriz DO
        begin
          nof := nof + 1; size[nof] := 3;
          facfront[nof] := last;
          faclist[last + 1] := index1[i + 1];
          faclist[last + 2] := index2[i];
          faclist[last + 3] := index1[i];
          last := last + size[nof];
          nfac[nof]     := nof;
          colour[nof]   := col;
          super[nof]    := 0;
          firstsup[nof] := 0;
        end;
      end
      else
      begin
        For i := 1 to nhoriz DO
        begin
          nof := nof + 1;
          size[nof] := 4;
          facfront[nof] := last;
          faclist[last + 1] := index1[i + 1];
          faclist[last + 2] := index2[i + 2];
          faclist[last + 3] := index2[i];
          faclist[last + 4] := index1[i];
          last := last + size[nof];
          nfac[nof]     := nof;
          colour[nof]   := col;
          super[nof]    := 0;
          firstsup[nof] := 0;
        end;
      end
      else
      if index2[1] <> index2[2] then
        For i := 1 to nhoriz DO
        begin
          nof := nof + 1;
          size[nof] := 3;
          facfront[nof] := last;
          faclist[last + 1] := index2[i + 1];
          faclist[last + 2] := index2[i];
          faclist[last + 3] := index1[i];
          last := last + size[nof];
          nfac[nof]     := nof;
          colour[nof]   := col;
          super[nof]    := 0;
          firstsup[nof] := 0;
        end;

        For i :=  1 to nhoriz + 1 DO
          index1[i] := index2[i];
  end;

  For i :=  nov + 1 to newnov DO
    transform(setup[i], P, act[i]);

  nov := newnov;

end;

Procedure BressenHam( Virseg : Word;          { Adres-> VIRSEG:0 }
                      pnts   : pixelArray;
                      c      : Byte;          { c->     kleur    }
                      p1, p2 : pixelvector);  { vector           } Assembler;
Var
  x, y, error,
  s1,  s2,
  deltax,
  deltay, i   : Integer;
  interchange : Boolean;
  dcolor      : Word;
Asm
{  initialize Variables  }
  PUSH   ds
  LDS    si, pnts
  MOV    ax, virseg
  MOV    es, ax
  MOV    cx, 320
  MOV    ax, p1.x
  MOV    x,  ax
  MOV    ax, p1.y
  MOV    y, ax
  MOV    dcolor, ax

  MOV    ax, p2.x                { deltax := abs(x2 - x1) }
  SUB    ax, p1.x                { s1 := sign(x2 - x1) }
  PUSH   ax
  PUSH   ax
  CALL   ddVars.sign
  MOV    s1, ax;
  POP    ax
  TEST   ax, $8000
  JZ     @@GeenSIGN1
  NEG    ax
 @@GeenSign1:
  MOV    deltax, ax
  MOV    ax, p2.y
  SUB    ax, p1.y
  PUSH   ax
  PUSH   ax
  CALL   ddVars.sign
  MOV    s2, ax
  POP    ax
  TEST   ax, $8000
  JZ     @@GeenSign2
  NEG    ax
 @@GeenSign2:
  MOV    deltay, ax

 { Interchange DeltaX and DeltaY depending on the slope of the line }

  MOV    interchange, False
  CMP    ax, deltax
  JNG    @@NO_INTERCHANGE
  XCHG   ax, deltax
  XCHG   ax, deltay
  MOV    interchange, True

 @@NO_INTERCHANGE:

  { Initialize the error term to compensate For a nonzero intercept }

  MOV    ax, deltaY
  SHL    ax, 1
  SUB    ax, deltaX
  MOV    error, ax

  { Main loop }
  MOV    ax, 1
  MOV    i, ax
 @@FOR_begin:
  CMP    ax, deltaX
  JG     @@EINDE_FOR_LOOP

  { Plot punt! }
  MOV   bx, x
  MOV   ax, y
  MUL   cx
  ADD   bx, ax
  MOV   al, c
  MOV   Byte PTR [es:bx], al
  INC   [Word ptr ds:si]     { aantal verhogen }
  MOV   ax, [si]
  SHL   ax, 1                { offset berekenen }
  PUSH  si
  ADD   si, ax
  MOV   [si], bx
  POP   si

  { While Loop }
 @@W1_begin:
  CMP    error, 0
  JL     @@EINDE_WHILE

  { if interchange then }

  CMP    interchange, True
  JE     @@i_is_t
  MOV    ax, s2
  ADD    y, ax
  JMP    @@w1_eruit

 @@i_is_t:
  MOV    ax, s1
  ADD    x, ax

 @@w1_eruit:
  MOV    ax, deltax
  SHL    ax, 1
  SUB    error, ax
  JMP    @@w1_begin

 @@EINDE_WHILE:
  CMP    interchange, True
  JE     @@i_is_t_1
  MOV    ax, s1
  ADD    x, ax
  JMP    @@if_2_eruit

 @@i_is_t_1:
  MOV    ax, s2
  ADD    y, ax

 @@if_2_eruit:
  MOV    ax, deltay
  SHL    ax, 1
  ADD    error, ax
  INC    i
  MOV    ax, i
  JMP    @@FOR_begin
 @@Einde_for_loop:
  POP    ds
end;

Procedure linepto(c : Integer; pt1, pt2 : vector2);
Var
  p1, p2 : pixelvector;
begin
  p1.x := fx(pt1.x);
  p1.y := fy(pt1.y);
  p2.x := fx(pt2.x);
  p2.y := fy(pt2.y);
  BressenHam($a000, points, c,  p1,  p2);
end;

Procedure WisScherm(punten : pixelArray; SchermSeg , Virseg : Word); Assembler;
Asm
  PUSH      ds
  MOV       ax, SchermSeg
  MOV       es, ax
  LDS       bx, punten
  MOV       cx, [bx]
  JCXZ      @@NietTekenen
 @@Wis:
  INC       bx
  INC       bx
  MOV       si, [bx]
  MOV       di, si
  PUSH      ds
  MOV       ax, virseg
  MOV       ds, ax
  MOVSB
  POP       ds
  LOOP      @@Wis
 @@NietTekenen:
  POP       ds
end;

Procedure polydraw(c, n : Integer; poly : vector2Array);
Var
  i : Integer;
begin
  For i :=  1 to n - 1 do
    linepto(c, poly[i], poly[i + 1]);
  linepto(c, poly[n], poly[1]);
end;

Procedure fillpoly(c, n : Integer; poly : vector2Array);
Var
  scan_table : tabel;
  scanline,
  line,
  offsetx    : Integer;

  Procedure Draw_horiz_line(hline_ar  : hlineArray;
                            color     : Byte;
                            lijn      : Word;
                            begin_p   : Word;
                            linelen   : Word); Assembler;
  Asm
    PUSH  ds
    MOV   cx, 320
    MOV   ax, 0a000h
    MOV   es, ax
    MOV   di, begin_p
    MOV   ax, lijn
    MUL   cx
    ADD   di, ax
    PUSH  di
    MOV   al, color
    MOV   cx, linelen
    PUSH  cx
    REP   STOSB
    LDS   si, hline_ar
    INC   [Word ptr ds:si]
    MOV   ax, [si]
    SHL   ax, 1
    SHL   ax, 1
    ADD   si, ax
    POP   bx
    POP   dx
    MOV   [si], dx
    MOV   [si + 2], bx
    POP   ds
  end;

  Procedure swap(Var x, y : Integer);
  begin
    x := x + y;
    y := x - y;
    x := x - y;
  end;

{
Procedure Calc_x(x1, y1, x2, y2 : Word; Var scan_table : tabel);
Var
  m_inv,
  xReal : Real;
begin
  Asm
    LDS     dx, scan_table
    MOV     ax, y1
    MOV     bx, y2
    CMP     ax, bx
    JNE     @@NotHorizLine
    MOV     bx, x1
    SHL     ax, 1
    ADD     ax, dx
    CMP     bx, [dx]
    JGE     @@Notstorexmin
    MOV     [dx], bx

   @@Notstorexmin:
    INC     dx
    MOV     bx, x2
    CMP     bx, [dx]
    JLE     @@Klaar
    MOV     [dx], bx
    JMP     @@Klaar

   @@NotHorizLine:
}

  Procedure Calc_x(x1, y1, x2, y2 : Integer; Var scan_table : tabel);
  Var
    m_inv, xReal : Real;
    i, y, temp   : Integer;
  begin
    if y1 = y2 then
    begin
      if x2 < x1 then
        swap(x1, x2)
      else
      begin
        if x1 < scan_table[y1].xmin then
          scan_table[y1].xmin := x1;
        if x2 > scan_table[y2].xmax then
          scan_table[y2].xmax := x2;
      end;
    end
    else
    begin
      m_inv := (x2 - x1) / (y2 - y1);

      if y1 > y2 then {swap}
      begin
        swap(y1, y2);
        swap(x1, x2);
      end;

      if x1 < scan_table[y1].xmin then
        scan_table[y1].xmin := x1;
      if x2 > scan_table[y2].xmax then
        scan_table[y2].xmax := x2;
      xReal := x1; y := y1;

      While y < y2 do
      begin
        y := y + 1;
        xReal := xReal + m_inv;
        offsetx := round(xReal);
        if xReal < scan_table[y].xmin then
          scan_table[y].xmin := offsetx;
        if xReal > scan_table[y].xmax then
          scan_table[y].xmax := offsetx;
      end;
    end;
  end;

begin
  scan_table := emptytabel;
  For line := 1 to n - 1 do
    calc_x(fx(poly[line].x), fy(poly[line].y),
           fx(poly[line + 1].x), fy(poly[line + 1].y), scan_table);

  calc_x(fx(poly[n].x), fy(poly[n].y),
         fx(poly[1].x), fy(poly[1].y), scan_table);

  scanline := 0;

  While scanline < nypix - 1 do
  begin
    With Scan_table[scanline] DO
      if xmax > xmin then
        draw_horiz_line(hline, c,  scanline,  xmin,  xmax - xmin + 1);
      scanline := scanline + 1;
  end;
end;

Procedure  Wis_Hline(hline_ar : hlineArray; virseg : Word); Assembler;
Asm
  PUSH      ds
  MOV       ax, 0a000h
  MOV       es, ax
  LDS       bx, hline_ar
  MOV       cx, [bx]
  JCXZ      @@Niet_tekenen
  ADD       bx, 4
 @@Wis:
  XCHG      cx, dx
  MOV       si, [bx]
  MOV       cx, [bx + 2]
  MOV       di, si
  PUSH      ds
  MOV       ax, virseg
  MOV       ds, ax
  CLD
  REP       MOVSB
  POP       ds
  XCHG      cx, dx
  ADD       bx, 4
  LOOP      @@Wis
 @@Niet_tekenen:
  POP       ds
end;

begin
end.


{ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ }

Unit
  ddVars;

Interface

Const
  pi      = 3.1415926535;
  epsilon = 0.000001;
  rad     = pi / 180;
  nxpix   = 320; { scherm resolutie }
  nypix   = 200;
  maxfinf = 200;

Type
  xmaxymax  = Record xmin, xmax : Integer; end;
  facetinfo = Record info, Pointer : Integer; end;
  tabel     = Array [1..nypix - 1] of xmaxymax;
  sincos    = Array [0..359] of Real;

Var
  sinusArray   : sincos;
  cosinusArray : sincos;
  facetinfacet : Array [1..maxfinf] of facetinfo;
  facetfree    : Integer;
  xyscale      : Real;
  emptytabel   : tabel;

Function  fx(x : Real) : Integer;
Function  fy(y : Real) : Integer;
Function  Sign(I : Integer) : Integer;
Function  macht(a, n : Real) : Real;
Function  angle(x, y : Real) : Integer;
Function  sinus(hoek : Integer) : Real;
Function  cosin(hoek : Integer) : Real;
Procedure pushfacet(Var stackname : Integer; value : Integer);

Implementation

Function fx(x : Real) : Integer;
begin
  fx := nxpix - trunc(x * xyscale + nxpix * 0.5 - 0.5);
end;

Function fy(y : Real) : Integer;
begin
  fy := nypix - trunc(y * xyscale + nypix * 0.5 - 0.5);
end;

Function Sign(I : Integer) : Integer; Assembler;
Asm
  MOV  ax, i
  CMP  ax, 0
  JGE  @@Zero_or_one
  MOV  ax, -1
  JMP  @@Exit

 @@Zero_or_One:
  JE   @@Nul
  MOV  ax, 1
  JMP  @@Exit

 @@Nul:
  xor  ax, ax

 @@Exit:
end;

Function macht(a, n : Real) : Real;
begin
  if a > 0 then
    macht :=  exp(n * (ln(a)))
  else
  if a < 0 then
    macht := -exp(n * (ln(-a)))
  else
    macht := a;
end;

Function angle(x, y : Real) : Integer;
begin
  if abs(x) < epsilon then
    if abs(y) < epsilon then
      angle := 0
    else
    if y > 0.0 then
      angle := 90
    else
      angle := 270
  else
  if x < 0.0 then
    angle := round(arctan(y / x) / rad) + 180
  else
    angle := round(arctan(y / x) / rad);
end;

Function sinus(hoek : Integer) : Real;
begin
  hoek  := hoek mod 360;
  sinus := sinusArray[hoek];
end;

Function cosin(hoek : Integer) : Real;
begin
  hoek  := hoek mod 360 ;
  cosin := cosinusArray[hoek];
end;

Procedure pushfacet(Var stackname : Integer; value : Integer);
Var
  location : Integer;
begin
  if facetfree = 0 then
  begin
    Write('Cannot hold more facets');
    HALT;
  end
  else
  begin
    location  := facetfree;
    facetfree := facetinfacet[facetfree].Pointer;
    facetinfacet[location].info := value;
    facetinfacet[location].Pointer := stackname;
    stackname := location;
  end;
end;

Var
  i : Integer;
begin
  { vul sinus- en cosinusArray met waarden }
  For i := 0 to 359 DO
  begin
    sinusArray[i]   := sin(i * rad);
    cosinusArray[i] := cos(i * rad);
  end;
  { Init facetinfacet }
  facetfree := 1;
  For i :=  1 to maxfinf - 1 DO
    facetinfacet[i].Pointer := i + 1;

  facetinfacet[maxfinf].Pointer := 0;

  { Init EmptyTabel }
  For i := 0 to nypix - 1 DO
  begin
    Emptytabel[i].xmin := 319;
    Emptytabel[i].xmax := 0;
  end;
end.


{ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ }

Unit ddvideo;

Interface

Uses
  Dos, DDVars;

Type
  schermPointer = ^schermType;
  schermType    = Array [0..nypix - 1, 0..nxpix - 1] of Byte;
  color         = Record  R, G, B : Byte; end;
  paletteType   = Array [0..255] of color;
  WordArray     = Array [0..3] of Word;
  palFile       = File of paletteType;
  picFile       = File of schermType;

Var
  scherm    : schermType Absolute $8A00 : $0000;
  schermptr : schermPointer;
  switch    : Integer;

Procedure start(Filenaam : String; horiz : Real; Var Oldpal : paletteType);
Procedure finish(Oldpal : paletteType);
Procedure VirScherm_actief(switch : Word);
Procedure Scherm_actief(switch : Word);

Implementation

Procedure Virscherm_actief(switch : Word); Assembler;
Asm
  MOV     dx, 3cch
  MOV     cx, switch
  JCXZ    @@volgende
  in      al, dx             { switch=1 }
  and     al, 0dfh
  MOV     dx, 3c2h
  OUT     dx, al             { set even mode }
  JMP     @@Klaar

 @@Volgende:
  in      al, dx             { switch=0 }
  or      al, 20h
  MOV     dx, 3c2h
  OUT     dx, al             { set odd mode }

 @@Klaar:
  MOV     dx, 3dah           { Wacht op Vert-retrace }
  in      al, dx             { Zodat virscherm = invisible }
  TEST    al, 08h
  JZ      @@Klaar
end;

Procedure Scherm_actief(switch : Word);
begin
  Asm
   @@Wacht:
    MOV  dx, 3dah
    in   al, dx
    TEST al, 01h
    JNZ  @@Wacht
  end;
  port[$3d4] := $c;
  port[$3d5] := switch * $80;
end;

Procedure SetVgaPalette(Var p : paletteType);
Var
  regs : Registers;
begin
  With regs do
  begin
    ax := $1012;
    bx := 0;
    cx := 256;
    es := seg(p);
    dx := ofs(p);
  end;
  intr ($10, regs);
end;


Procedure start(Filenaam : String; horiz : Real; Var Oldpal : paletteType);

  Procedure readimage(Filenaam : String; Var pal : paletteType);

    Function FileExists(FileName : String) : Boolean;
    Var
      f : File;
    begin
      {$I-}
      Assign(f,  FileName);
      Reset(f);
      Close(f);
      {$I + }
      FileExists := (IOResult = 0) and (FileName <> '');
    end;

  Var
    pFile : picFile;
    lFile : palFile;
    a     : Integer;
  begin
    if (FileExists(Filenaam + '.pal')) and
       (FileExists(Filenaam + '.dwg')) then
    begin
      assign(lFile, Filenaam + '.pal');
      reset(lFile);
      read(lFile, pal);
      close(lFile);
      assign(pFile, Filenaam + '.dwg');
      reset(pFile);
      read(pFile, schermptr^);
      close(pFile);
    end
    else
    begin
      Writeln('Palette en Picture bestanden niet gevonden....');
      Halt;
    end;
  end;

  Procedure SetVgaMode; Assembler;
  Asm
    mov  ah, 0
    mov  al, 13h
    int  $10
  end;

  Procedure GetVgaPalette(Var p : paletteType);
  Var
    regs : Registers;
  begin
    With regs do
    begin
      ax := $1017;
      bx := 0;
      cx := 256;
      es := seg(p);
      dx := ofs(p);
    end;
    intr ($10, regs);
  end;

Var
  pal : paletteType;

begin
  getmem(schermptr, sizeof(schermType));
  readimage(Filenaam, pal);
  GetVgaPalette(OldPal);
  SetVgaPalette(pal);
  SetVgaMode;
  move(schermptr^, scherm, nypix * nxpix);
  Virscherm_actief(0);
  move(schermptr^, mem[$A000 : 0], nypix * nxpix);     { blanko scherm }
  VirScherm_actief(1);
  move(schermptr^, mem[$A000 : 0], nypix * nxpix);     { blanko scherm }
  Scherm_actief(1);
  switch  := 0;
  xyscale := (nypix - 1) / horiz;
end;

Procedure finish(Oldpal : paletteType);

  Procedure SetNormalMode; Assembler;
  Asm
    mov  ah,  0
    mov  al,  3
    int  $10
  end;

begin
  SetVgaPalette(Oldpal);
  SetNormalMode;
  Virscherm_actief(0);
  Freemem(schermptr, sizeof(schermType));
end;

begin
end.

