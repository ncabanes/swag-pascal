
Q:  How do I use one of the cursor files in the c:\delphi\images\cursors?

A:  Use the image editor to load the cursor into a RES file.
    The following example assumes that you saved the cursor in the RES file
    as "cursor_1", and you save the RES file as MYFILE.RES.
    
(*** BEGIN CODE ***)
{$R c:\programs\delphi\MyFile.res}   { This is your RES file }

const PutTheCursorHere_Dude = 1;     { arbitrary positive number }

procedure stuff;
begin
  screen.cursors[PutTheCursorHere_Dude] := LoadCursor(hInstance, 

                                                      PChar('cursor_1'));
  screen.cursor := PutTheCursorHere_Dude;
end;




