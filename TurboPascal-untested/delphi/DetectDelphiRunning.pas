(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0378.PAS
  Description: Detect Delphi Running?
  Author: EDDIE SHIPMAN
  Date: 01-02-98  07:33
*)


function DelphiIsRunning : boolean;
var
  H1, H2, H3, H4 : Hwnd;
const
  A1 : array[0..12] of char = 'TApplication'#0;
  A2 : array[0..15] of char = 'TAlignPalette'#0;
  A3 : array[0..18] of char = 'TPropertyInspector'#0;
  A4 : array[0..11] of char = 'TAppBuilder'#0;
  T1 : array[0..6] of char = 'Delphi'#0;
begin
  H1 := FindWindow(A1, T1);
  H2 := FindWindow(A2, nil);
  H3 := FindWindow(A3, nil);
  H4 := FindWindow(A4, nil);
  Result := (H1 <> 0) and (H2 <> 0) and
            (H3 <> 0) and (H4 <> 0);
end;

initialization
  if DelphiIsRunning then
  begin
     {Do what you want......}
  end;
end.

