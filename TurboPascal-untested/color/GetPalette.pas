(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0005.PAS
  Description: Get Palette
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
> Is it Possible to find out what the colors are that are
> currently being used? I don't know how else to phrase it, I
> know you can find out the Values of the Various pixels on
> the screen. But how can I find out the Various red, green
> and blue Values that correspond to the specific color?

}

Procedure ReadPalette(Start,Finish:Byte;P:Pointer);
Var
  I,
  NumColors   :  Word;
  InByte      :  Byte;
begin
  P := Ptr (Seg(P^),Ofs(P^)+Start*3);
  NumColors := (Finish - Start + 1) * 3;

  Port [$03C7] := Start;

  For I := 0 to NumColors do begin
    InByte := Port [$03C9];
    Mem [Seg(P^):Ofs(P^)+I] := InByte;
    end;

end;

{
> But, how do I find out exactly what color #200 is? It must
> be held in memory some place. Can anyone supply a Procedure,
> Function or some insight into this?

     You would just supply the Start as 200, finish as 200, and Ptr P would
point to your data... You could easily Change this routine to Supply only one
color as Variables if needed.... Hope this helped..
}
