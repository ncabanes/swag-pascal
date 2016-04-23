
var
  Dummy : Integer;
begin
  SystemParametersInfo (97, Word (True), @Dummy, 0); {no alt-tab or
ctrl-alt-del any more}
  SystemParametersInfo (97, Word (False), @Dummy, 0); {Activate alt-tab or
ctrl-alt-del any more}
end;
