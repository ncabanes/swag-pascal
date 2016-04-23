YZ> Does anyone know how to "extract" the Foreground and
YZ> background colours from
YZ> TextAttr?

or, For simplicity, use:

  FC := TextAttr MOD 16;
  BC := TextAttr div 16;

