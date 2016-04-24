(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0017.PAS
  Description: Background/Foreground
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

YZ> Does anyone know how to "extract" the Foreground and
YZ> background colours from
YZ> TextAttr?

or, For simplicity, use:

  FC := TextAttr MOD 16;
  BC := TextAttr div 16;


