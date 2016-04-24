(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0099.PAS
  Description: Finding the Video Segment
  Author: BRAD ZAVITSKY
  Date: 11-22-95  13:33
*)


function VidSeg: Word;
var
  VidM: ^Byte;
begin
  {$iFDEF VER70}
  VidM := Ptr(Seg0040,$0049);
  if VidM^ = 7 then VidSeg := SegB000 else VidSeg := SegB800;
  {$ELSE}
  VidM := Ptr($0040,$0049);
  if VidM^ = 7 then VidSeg := $B000 else VidSeg := $B800;
  {$ENDiF}
end;

