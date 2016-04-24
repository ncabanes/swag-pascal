(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0055.PAS
  Description: Inline code to warm boot
  Author: SWAG SUPPORT TEAM
  Date: 11-29-96  08:17
*)


procedure warme_start;

Begin
  Inline($BB/$00/$01/$B8/$40/$00/$8E/$D8/
         $89/$1E/$72/$00/$EA/$00/$00/$FF/$FF);
End;

