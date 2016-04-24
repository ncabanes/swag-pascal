(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0150.PAS
  Description: Setting properties of all components
  Author: MICHAEL VINCZE
  Date: 08-30-96  09:35
*)

(*
In article 3A77@popalex1.linknet.net, Bill Taylor <btaylor@popalex1.linknet.net> () writes:
>How can you loop through and set properties of components without
>manually setting each component seperately. For example, I am writing a
>program which uses 16 TPanels and 16 TImages. Currently, I am setting the
>tag and color properties of these components as follows.
>
>Loc1.Tag := 0; Pos1.color := clBlack;
>Loc2.Tag := 0; Pos2.color := clBlack;
>Loc3.Tag := 0; Pos3.color := clBlack;
>Loc4.Tag := 0; Pos4.color := clBlack;
>Loc5.Tag := 0; Pos5.color := clBlack;
>Loc6.Tag := 0; Pos6.color := clBlack;
>Loc7.Tag := 0; Pos7.color := clBlack;
>Loc8.Tag := 0; Pos8.color := clBlack;
>Loc9.Tag := 0; Pos9.color := clBlack;
>Loc10.Tag := 0; Pos10.color := clBlack;
>Loc11.Tag := 0; Pos11.color := clBlack;
>Loc12.Tag := 0; Pos12.color := clBlack;
>Loc13.Tag := 0; Pos13.color := clBlack;
>Loc14.Tag := 0; Pos14.color := clBlack;
>Loc15.Tag := 0; Pos15.color := clBlack;
>Loc16.Tag := 0; Pos16.color := clBlack;
>
>This works, but doesn't look to good. I would like to do a for loop to
>set these properties.
*)

Try something of the following flavor:
  for I := 0 to ComponentCount - 1 do
    if (Components[I] is TLabel) or (Components[I] is TImage) then
      with Components[I] as TLabel, Components[I] as TImage do
        begin
        Tag := 0;
        Color := clBlack;
        end;


