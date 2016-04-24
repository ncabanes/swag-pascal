(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0229.PAS
  Description: Re: Rotating Text
  Author: DAVID S. BECKER
  Date: 03-04-97  13:18
*)


Try the following function.  I don't remember where I got it from, but it
works well!  The only thing to remember here is the parameter 'd' is in
tenths of a degree.  So, if you want to rotate the text 45 degrees, 'd'
should be 450.  Sorry for the funny wrapping, I'm sure you can figure it
out:

procedure CanvasTextOutAngle(c: TCanvas; x,y: Integer; d: Word; s: string);
var
  LogRec: TLOGFONT;     {* Storage area for font information *}
  OldFontHandle,        {* The old font handle *}
  NewFontHandle: HFONT; {* Temporary font handle *}
begin
  if Application.Terminated then Exit;
  {* Get the current font information. We only want to modify the angle *}
  GetObject(c.Font.Handle, SizeOf(LogRec), Addr(LogRec));
  {* Modify the angle. "The angle, in tenths of a degrees, between the base
     line of a character and the x-axis." (Windows API Help file.)*}
  LogRec.lfEscapement := d;
  {* Create a new font handle using the modified old font handle *}
  NewFontHandle := CreateFontIndirect(LogRec);
  {* Save the old font handle! We have to put it back when we are done! *}
  OldFontHandle := SelectObject(c.Handle,NewFontHandle);
  {* Finally. Output the text! *}
  c.Brush.Style := bsClear;
  c.TextOut(x,y,s);
  {* Put the font back the way we found it! *}
  NewFontHandle := SelectObject(c.Handle,OldFontHandle);
  {* Delete the temporary (NewFontHandle) that we created *}
  DeleteObject(NewFontHandle);
end; {* CanvasTextOutAngle *}

--
David S. Becker
ADP Dealer Services (Plaza R&D)
dsb@plaza.ds.adp.com
(503)402-3236

Stephen Gould <sgould@extro.ucc.su.OZ.AU> wrote in article
<59tup1$1i9@metro.ucc.su.OZ.AU>...
> Hi,
> 
> Does anyone know of a good way to rotate text and display it in a 
> PaintBox. At the moment I am creating a TCanvas object in memory, drawing

> the text on it, then rotating the whole canvas and dumping it in the 
> paintbox. Is there a better way? The text comes out looking pretty bad.
> 
> Steve.
> gouldy@mad.scientist.com
>
>
