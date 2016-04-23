{
From: GUY MCLOUGHLIN
Subj: Checking file open

I'm looking for a way of detecting if a file is currently open,
so my ExitProc can close it when open and not fail when trying
to close a file that is not open.

              (* Public-domain demo to check a file variable's        *)
              (* current file mode. Guy McLoughlin - Oct '93.         *)
}

program Test_FileMode_Demo;
uses
 dos;

  (**** Display current filemode for a file variable.                 *)
  (*                                                                  *)
  procedure DisplayFileMode({input } const fi_IN);
  begin
    case textrec(fi_IN).mode of
      FMclosed : writeln('* File closed');
      FMinput  : writeln('* File open in read-only  mode');
      FMoutput : writeln('* File open in write-only mode');
      FMinout  : writeln('* File open in read/write mode')
    else
      writeln('* File not assigned')
    end
  end;        (* DisplayFileMode.                                     *)


  (**** Check for IO file errors.                                     *)
  (*                                                                  *)
  procedure CheckForIOerror;
  var
    in_Error : integer;
  begin
    in_Error := ioresult;
    if (ioresult <> 0) then
      begin
        writeln('Error creating file');
        halt(1)
      end
  end;        (* CheckForIOerror.                                     *)


var
  fi_Temp1 : text;
  fi_Temp2 : file;

BEGIN
              (* Demo filemodes for a TEXT file variable.             *)
  writeln('TEXT file variable test');
  DisplayFileMode(fi_Temp1);
  assign(fi_Temp1, 'TEST.DAT');
  DisplayFileMode(fi_Temp1);
  {$I-} rewrite(fi_Temp1); {$I+}
  CheckForIOerror;
  DisplayFileMode(fi_Temp1);
  {$I-} close(fi_Temp1); {$I+}
  CheckForIOerror;
  DisplayFileMode(fi_Temp1);

              (* Demo filemodes for an UNTYPED file variable.         *)
  writeln;
  writeln('UNTYPED file variable test');
  DisplayFileMode(fi_Temp2);
  assign(fi_Temp2, 'TEST.DAT');
  DisplayFileMode(fi_Temp2);
  {$I-} rewrite(fi_Temp2); {$I+}
  CheckForIOerror;
  DisplayFileMode(fi_Temp2);
  {$I-} close(fi_Temp2); {$I+}
  CheckForIOerror;
  DisplayFileMode(fi_Temp2)
END.

  *** NOTE: If you are not using version 7 of Turbo Pascal, change
            the input parameter of the DisplayFileMode routine from
            a CONSTANT parameter to a VAR parameter.

              ie: TP7+ : DisplayFileMode({input } const fi_IN);

                  TP4+ : DisplayFileMode({input } var fi_IN);

                               - Guy
