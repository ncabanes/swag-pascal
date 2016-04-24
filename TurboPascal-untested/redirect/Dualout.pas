(*
  Category: SWAG Title: DOS REDIRECTION ROUTINES
  Original name: 0002.PAS
  Description: DUALOUT.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

Unit dualout;

{ This Unit is designed to demonstrate directing all screen output to a File }
{ in addition to the normal display.  This means that any Write or Writeln   }
{ will display normally on the screen and also be Recorded in a Text File.   }
{ The File name For the output can be supplied by a command line parameter   }
{ in the Format -  dual=c:\test\output.dat or you can provide an environment }
{ Variable named dual that supplies the File name or it will default to the  }
{ current directory and output.dat.                                          }

Interface

Uses
  globals,  { contains the Function exist, which tests For the existence of  }
            { a File.  It also defines the Type str80 as String[80]          }
  Dos,
  tpString; { from TPro. Needed For StUpCase Function in Procedure initialise}

Const 
  DualOn   : Boolean = False;
  DualOK   : Boolean = False;
  fname    : str80   = 'output.dat';  { The default File name For the output }
  
Type
  DriverFunc = Function(Var f: TextRec): Integer;

Var
  OldExitProc    : Pointer;                  { For saving old Exit Procedure }
  OldInOutOutput,                            { The old output InOut Function }
  OldFlushOutput : DriverFunc;               { The old output Flush Function }
  dualf          : Text;

Procedure  dual(status: Boolean);

{===========================================================================}
Implementation

Var
  cmdline : String;
  
Procedure DualWrite(Var f: TextRec);
  { Writes the output from stdout to a File }
  Var
    x : Word;
  begin
    For x := 0 to pred(f.BufPos) do
      Write(dualf, f.BufPtr^[x]);
  end;  { DualWrite }

{$F+}
Function InOutOutput(Var f: TextRec): Integer;
  begin
    DualWrite(f);                                        { Write to the File }
    InOutOutput := OldInOutOutput(f);                { Call the old Function }
  end; { InOutOutput }

Function FlushOutput(Var f: TextRec): Integer;
  begin
    DualWrite(f);                                        { Write to the File }
    FlushOutput := OldFlushOutput(f);                { Call the old Function }
  end; { FlushOutput }

Procedure DualExitProc;
  begin
    close(dualf);
    ExitProc := OldExitProc;                { Restore the old Exit Procedure }
    With TextRec(output) do begin
      InOutFunc := @OldInOutOutput;          { Restore the old output Record }
      FlushFunc := @OldFlushOutput;           { Restore the old flush Record }
    end; { With }
  end; { DualExitProc }

{$F-,I-}
Procedure dual(status: Boolean);
  Var
    ErrorCode : Integer;
  begin
    if status then begin
      assign(dualf,fname);
      if Exist(fname) then { open For writing }
        append(dualf)
      else { start new File }
        reWrite(dualf);
      ErrorCode := Ioresult;   
      if ErrorCode <> 0 then 
        halt(ErrorCode);
      With TextRec(output) do begin
        { This is where the old output Functions are rerouted }
        OldInOutOutput := DriverFunc(InOutFunc);
        OldFlushOutput := DriverFunc(FlushFunc);
        InOutFunc := @InOutOutput;
        FlushFunc := @FlushOutput;
      end; { With }
      OldExitProc := ExitProc;            { Save the current Exit Procedure }
      ExitProc    := @DualExitProc;            { Install new Exit Procedure }
      DualOn      := True;
    end { if status }  
    else { switch dual output off } begin  
      if DualOn then begin
        close(dualf);  if Ioresult = 0 then;                   { dummy call }
        ExitProc := OldExitProc;           { Restore the old Exit Procedure }
        OldExitProc := nil;
        With TextRec(output) do begin
          InOutFunc := @OldInOutOutput;     { Restore the old output Record }
          FlushFunc := @OldFlushOutput;      { Restore the old flush Record }
        end; { With }
      end; { if DualOn }
    end; { else }
  end; { dual }
{$I+}  


Procedure Initialise;
  { Determines if a File name For the output has been provided. }
  begin
    if GetEnv('DUAL') <> '' then
      fname := GetEnv('DUAL')
    else begin
      if ParamCount <> 0 then begin
        cmdline := String(ptr(PrefixSeg,$80)^);
        cmdline := StUpCase(cmdline);
        if pos('DUAL=',cmdline) <> 0 then begin
          fname := copy(cmdline,pos('DUAL=',cmdline)+5,80);
          if pos(' ',fname) <> 0 then
            fname := copy(fname,1,pos(' ',fname)-1);
        end; { if pos('Dual... }
      end;  { if ParamCount... }
    end; { else }
  end; { Initialise }
  
begin
  Initialise;
end.  


