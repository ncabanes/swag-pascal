(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0140.PAS
  Description: Gouraud Shading
  Author: JOHN HOWARD
  Date: 11-26-94  05:01
*)

{
Here is the GOURAUD shading include file that came with Surface Modeler 3.0:
}
procedure GOURAUD;
{ Make a surface model drawing of the object with Gouraud interpolation
  of surface shading }

var Node:                      word;          { node # }
    Surf:                      word;          { surface # }
    Shade:                     real;          { shade of surface }
    Shade2:                    real;          { shade of 2nd side of surface }
    Vert:                      integer;       { vertex # }
    Interp:                    boolean;       { flag interpolated shading }
    User_abort:                boolean;       { did the user abort? }
    ch:                        char;
{$ifndef BIGMEM}
    Shades: nodearray;
      { shade at each node }
    Surfmin, Surfmax: surfaces;
      { surface minimum & maximum (Ztran) }
    Nshades: array[1..MAXNODES] of integer;
      { # shades to average per node }
    Sshade: surfaces;
      { shade at each surface }
{$endif}
label ABORTTEXT,                              { text-mode abort }
      ABORTGRPH;                              { graphics-mode abort }

begin
{$ifdef BIGMEM}
with ptrh^ do with ptri^ do with ptrj^ do
with ptra^ do with ptrb^ do with ptrc^ do
with ptrd^ do with ptre^ do with ptrf^ do
with ptrh^ do with ptri^ do with ptrj^ do
with ptrk^ do with ptrl^ do with ptrm^ do with ptrn^ do
begin
{$endif}

  perf_start;
  User_abort := TRUE;
  if (checkey) then goto ABORTTEXT;
{$ifndef NOSHADOW}
  if (Shadowing) then begin
    shadows (Shades);
    for Node := 1 to Nnodes do
      Nshades[Node] := 0;
  end else
{$else}
  if (Shadowing) then
    writeln ('Error: Shadows not implemented in this version')
  else
{$endif}
    for Node := 1 to Nnodes do begin
      Shades[Node] := 0.0;
      Nshades[Node] := 0;
    end;

  if (Viewchanged) or (Shadowing) then begin
    if (checkey) then goto ABORTTEXT;
    menumsg ('Transforming to 2-D...');
{ Transform from 3-D to 2-D coordinates }
    setorigin;
    for Node := 1 to Nnodes do
      perspect (Xworld[Node], Yworld[Node], Zworld[Node],
                Xtran[Node],  Ytran[Node],  Ztran[Node]);

{ Set plotting limits and normalize transformed coords to screen coords }
    perspect (Xfocal, Yfocal, Zfocal, Xfotran, Yfotran, Zfotran);
    if (not setnormal (Xfotran, Yfotran, XYmax)) then begin
      menumsg ('Warning: Focal point outside data limits.');
      writeln;
      write   ('  Press any key ...');
      ch := readkey;
    { Erase the previous message }
      menumsg ('');
      writeln;
      write ('                          ');
    end;

    if (checkey) then goto ABORTTEXT;
{ Normalize all the nodes }
    for Node := 1 to Nnodes do
      normalize (Xtran[Node], Ytran[Node], Xfotran, Yfotran, XYmax);
    { Initialize all nodal shades to zero }

    if (checkey) then goto ABORTTEXT;
    menumsg ('Sorting surfaces...');
    minmax (Surfmin, Surfmax, Nsurf);
    shelsurf (Surfmin, Surfmax, Nsurf);
    Viewchanged := FALSE;
  end; { if Viewchanged }

  setshade;                            { Setup for shading calculations }

{ Compute the cumulative shading at every node (sum the shades due to
  all surrounding surfaces) }
  if (checkey) then goto ABORTTEXT;
  menumsg ('Computing shades...');
  for Surf := 1 to Nsurf do begin
    if (Nsides = 2) then begin
      { Use only the side of the surface with the brightest shade }
      Shade := Shading (Surf, 1);
      Shade2 := Shading (Surf, 2);
      if (Shade2 > Shade) then
        Shade := Shade2;
    end else
      Shade := Shading (Surf, 1);
    { Surface shade }
    Sshade[Surf] := Shade;
    { Nodal shade }
    for Vert := 1 to Nvert[Surf] do begin
      Node := konnec (Surf, Vert);
      if (Shade >= 0.0) and (Shades[Node] >= 0.0) then begin
        Shades[Node] := Shades[Node] + Shade;
        Nshades[Node] := Nshades[Node] + 1;
      end;
    end; { for Vert }
  end; { for Surf }

  if (checkey) then goto ABORTTEXT;
{ Now average out the nodal shading }
  for Node := 1 to Nnodes do
    if (Nshades[Node] > 0) then
      Shades[Node] := Shades[Node] / Nshades[Node];

{$ifdef USE_IFF}
  menumsg ('Plotting...');
{$endif}

{ Now plot all the surfaces, with Gouraud shading }
  setgmode (Nmatl);
  for Surf := 1 to Nsurf do begin
    if (Sshade[Surf] >= 0.0) then begin
      Interp := TRUE;
      { If any nodal shade varies from the average (surface) shade by more
        than Epsilon, then don't use interpolated shading (unless the node
        is in a shadow, in which case you should interpolate anyway) }
      for Vert := 1 to Nvert[Surf] do begin
        Node := konnec (Surf, Vert);
        if (abs(Shades[Node] - Sshade[Surf]) > Epsilon) and
           (Shades[Node] >= 0.0) then
          Interp := FALSE;
      end;
      if (Interp) then
        intrfill (Surf, Matl[Surf], Shades)
      else
        fillsurf (Surf, Matl[Surf], Sshade[Surf]);
      { Show border of surface, if requested }
      if (ShowAllBorders > 0) then
        border (Surf, Matl[Surf]);
    end; { if Sshade }
    if (grafstat) then goto ABORTGRPH;
  end; { for Surf }
  drawaxes (Xfotran, Yfotran, XYmax);

  perf_stop (5);

{$ifdef USE_IFF}
  menumsg ('Saving IFF...');
  saveiff (Filemask + '.IFF', VGApal);
{$else}
  { Wait for user keypress to continue }
  continue;
{$endif}
  User_abort := FALSE;

  ABORTGRPH:
  exgraphic;
  ABORTTEXT:
  if (User_abort) then
    perf_stop (0);
{$ifdef BIGMEM}
end; {with}
{$endif}
end; {procedure GOURAUD }

