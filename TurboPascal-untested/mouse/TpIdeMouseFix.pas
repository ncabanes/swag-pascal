(*
  Category: SWAG Title: RODENT MANAGMENT ROUTINES
  Original name: 0028.PAS
  Description: TP IDE Mouse Fix
  Author: DJ MURDOCH
  Date: 05-26-95  23:21
*)

{
> Are you the DJ Murdoch that has a mouse fix for the TP IDE?

I wrote a little program to work around some bugs in some mouse drivers that
showed up in TP 6.  You can find it as "MOUSEFIX.ZIP" in various places.
Here's the source in its entirety; you'll need TurboPower's Object Professional
library to recompile, or you can supply your own replacements for the various
TSR support routines.
}
  program mousefix;

  { Program to intercept mouse calls; make sure that hide/show mouse calls
    balance between saves/restores of the mouse state }

  { Usage:  Run MOUSEFIX after loading your mouse driver, before running
            the TP6 IDE. It's a 27K TSR; if you like it, you'll probably
            want to rewrite it in assembler.

    Written for the public domain by Duncan Murdoch.  Send comments to me
    at
      dmurdoch@mast.queensu.ca        (Internet)
      DJ Murdoch at 1:249/1.5         (Fidonet)
      71631,122                       (Compuserve)
  }

  uses
    opint,optsr;

  const
    mousehandle = 20;
  var
    hidecounter : integer;

  procedure hidemouse;
  var
    regs : intregisters;
  begin
    regs.ax := 2;
    emulateint(regs,israrray[mousehandle].origaddr);
  end;

  procedure showmouse;
  var
    regs : intregisters;
  begin
    regs.ax := 1;
    emulateint(regs,israrray[mousehandle].origaddr);
  end;

  procedure mouseservice(bp : word); interrupt;
  var
    regs : intregisters absolute bp;
    i : integer;
  begin
    with regs do
    begin
      if ah = 0 then
      begin
        case al of
        0,$16,$21 : hidecounter := 0;   { Reset, save state }
        1 : dec(hidecounter);       { show }
        2 : inc(hidecounter);       { hide }
        $17 : begin                 { restore state }
                if hidecounter > 0 then
                  for i:=1 to hidecounter do
                    showmouse
                else if hidecounter < 0 then
                  for i:=-1 downto hidecounter do
                    hidemouse;
                hidecounter := 0;
              end;
        end;
      end;
    end;
    chainint(regs,israrray[mousehandle].origaddr);
  end;

  begin
    if not initvector($33, MouseHandle, @Mouseservice) then
    begin
      writeln('Couldn''t get mouse vector!!!');
      halt(99);
    end;
    stayres(ParagraphsToKeep,0);
    writeln('Failed to go resident!!');
  end.


