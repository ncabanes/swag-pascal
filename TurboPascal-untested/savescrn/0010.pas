{
> Does anyone have any code that will go tsr and dump the pixel colors in a
> 320.256. whatever that mode is into a Text File in the format 200,5,0,0,0,4,
> etc?  just list every pixel followed by a comma?

The TSR part would be the hard part, the writing the screen to a File
would be easy.

I wrote this little prog just now, not incredibly great but might
actually work and probably will do the job...

Be careful as it doesn't check For Dos reentrancy and you might hang
your computer if you try to capture a screen While Dos is doing
something else...

by Sean Palmer,
public domain
}

Program capture;
Uses
  Dos;

Procedure WriteScrn2File;
Var
  f    : Text;
  x, y : Word;
begin
  assign(f,'CAPTURE.SCR');
  reWrite(f);
  For y := 0 to 199 do
    For x := 0 to 319 do
    begin
      Write(f, mem[$A000 : y * 320 + x], ',');
      if x mod 20 = 0 then
        Writeln(f);  {new line every 20 pixels}
    end;
  close(f);
end;

Var
  oldIntVec : Procedure;

{you need to put a Real check For Dos activity here}

Function DosActive : Boolean;
begin
  DosActive := False;
end; {assume no and keep fingers crossed! 8)}

Procedure keyHandler; interrupt;
begin
  if port[$60] = 114 then     {if print-screen pressed}
    if not DosActive then {better not press While Dos is doing something}
      WriteScrn2File;
  oldIntVec;  {call old handler}
end;

begin
  getIntVec(9, @oldIntVec);
  setIntVec(9, @newIntVec);
  keep(0);  {go TSR}
end.
