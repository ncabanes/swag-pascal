(*
  Category: SWAG Title: Borland DELPHI
  Original name: 0388.PAS
  Description: Re: intercepting Ctrl-Alt-Del
  Author: BIFF
  Date: 01-02-98  07:34
*)


var
  Dummy : Integer;
begin
  SystemParametersInfo (97, Word (True), @Dummy, 0); {no alt-tab or
ctrl-alt-del any more}
  SystemParametersInfo (97, Word (False), @Dummy, 0); {Activate alt-tab or
ctrl-alt-del any more}
end;

