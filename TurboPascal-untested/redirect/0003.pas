{
All these solutions of using a shell to redirect output.

There are two Dos interrupts that allow Filehandles to be duplicated.

Redirec and unredirec allow easy access to dup and dup2 For standard in
and out (input and output are reserved TP Words) to a Text File that you
have previously opened (reset/reWrite/append as appropriate). It must be
opened - this allocates a File handle (a Byte - you declare this, you'll
need it later to get your output back). if you don't unredirec to the
right handle you could loose all your output to the File or a black hole -
be warned.

You could make similar Procedures to redirec/unredirec For redirection of
other standard handles (3 is Printer (LST), 4 I think is STDERR  and 5
is AUX aren't they?)

Here's the Unit:
}

{$O+ $F+}

Unit ReDIRECt;

Interface

Function dup (hand : Byte; Var error : Boolean) : Byte;
   { provides a new handle For an already opened device or File.
     if error, then the return is the error code - 4 no handles available or
     6, invalid handle.}

Procedure dup2 (source, destination : Byte;  Var err : Byte);
   { Makes two File handles refer to the same opened File at the same
     location. The destination is closed first.
     Err returns 0 if no error or error code as For dup.
     to redirect then return to normal - do as follows:
     1. Use DUP to save the handle to be directed (the source).
     2. Assign and reWrite/reset the destination.
     3. Redirect the handle using DUP2.
     4. Do the exec
     5. Use dup2 again restoring the saved handle.
     6. reset/reWrite the redirected items & close the destination}

Function Redirec (op : Boolean; Var f:Text; Var hand : Byte) : Boolean;
  {redirects standard out to (if op True) or standard in from File fn.
   returns handle in handle to be used by undirec, below, and True if
   successful.}

Procedure Undirec (op : Boolean; hand : Byte);
   {undoes the redirection from the previous redirec. Assumes File closed
    by caller.}

Function getFilehandle(Filename : String; Var error : Boolean) : Integer;

{////////////////////////////////////////////////////////////////////////}
Implementation

Uses
  Dos;

Function dup (hand : Byte; Var error : Boolean) : Byte;
Var
  regs : Registers;
begin
  With regs do
  begin
    AH := $45;
    BX := hand;

    MsDos (regs);

    error := flags and fcarry <> 0;  {error if carry set}

    dup := AX;
  end;
end;

Procedure dup2 (source, destination : Byte;  Var err : Byte);
Var
  regs : Registers;
begin
  With regs do
  begin
    AH := $46;
    BX := source;
    CX := destination ;

    MsDos (regs);

    if flags and fcarry <> 0 then {error if carry set}
      err := AX
    else
      err := 0;
  end;
end;

Function Redirec (op : Boolean; Var f:Text; Var hand : Byte) : Boolean;
  {redirects standard out to (if op True) or standard in from File fn.
   returns handle in handle to be used by undirec, below, and True if
   successful.}
Var
  err     : Byte;
  error   : Boolean;
begin
  redirec := False;
  err := 0;
  if op then
  begin
    flush (output);
    hand := dup (Textrec(output).handle, error)
  end
  else
  begin
    flush (input);
    hand := dup (Textrec(input).handle, error)
  end;
  if error then
    Exit;
  {$i-}
  if op then
    reWrite (f)
  else
    reset (f);
  {$i+}
  if ioresult <> 0 then
    Exit;
  if op then
    dup2 (Textrec(f).handle, Textrec(output).handle,err)
  else
    dup2 (Textrec(f).handle, Textrec(input).handle,err);

  redirec := (err = 0);
end;

Procedure Undirec (op : Boolean; hand : Byte);
   {undoes the redirection from the previous redirec. Assumes File closed
    by caller.}
Var
  err : Byte;
begin
  if op then
  begin
    dup2 (hand, Textrec(output).handle, err);
    reWrite (output)
  end
  else
  begin
    dup2 (hand, Textrec(input).handle, err);
    reset (input)
  end
end; {undirec}


Function getFilehandle( Filename : String; Var error : Boolean) : Integer;
Var
  regs : Registers;
  i : Integer;
begin
  Filename := Filename + #0;
  fillChar(regs, sizeof(regs), 0);

  With regs do
  begin
    ah := $3D;
    AL := $00;
    ds := seg(Filename);
    dx := ofs(Filename) + 1;
  end;

  MsDos(Regs);

  I := regs.ax;

  if (lo(regs.flags) and $01) > 0 then
  begin
    error := True;
    getFilehandle := 0;
    Exit
  end;

  getFilehandle := i;
end;

end.

{ Here's a demo }

Program dupdemo;

{$M 2000,0,0}
Uses
  Direc, Dos;


Var
  arcname : String;
  tempFile : Text;
  op : Boolean;
  handle : Byte;
  Handle2 : Byte;
  err : Boolean;
  Error : Byte;
  InFile : File;

begin
  Handle := 0;

  Handle2 := Dup(Handle,Err);

  if Err then
  begin
     Writeln('Error getting another handle');
     halt;
  end;

  arcname := 'C:\qmpro\download\qmpro102.ZIP';
  assign (tempFile, 'C:\qmpro\download\TEMP.FIL');
  ReWrite(TempFile);

  Dup2(Handle, Handle2, Error);
  if Error <> 0 then
  begin
     Writeln('ERRor: ',Error);
     Halt;
  end;


  if redirec(op, tempFile, handle2) then
  begin
    SwapVectors;
    Writeln('Running ZIP!');
    Exec('PKUNZIP',' -V ' + ArcName);
    SwapVectors;
    close (tempFile);
    undirec (op, handle2);
  end
  else
    Writeln('Error!');
end.

{
I wrote the DUPDEMO Program, but the Unit is the brainchild of an author that I
can't remember, but I use this regularly.  It will work up to TP 7.0, I've
never tested it With TP 7.0 because I don't own it.
}

