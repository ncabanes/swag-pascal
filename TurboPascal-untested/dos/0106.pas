(*
>          Hi, I am trying to write a program the writes to Standard output,
> and reads from Standard input from windows console (win95 dosprmpt, winnt
>  dosprmpt)... so the io can be redirected.  The program must be a windows
> program for the project to work:
>                  Using the program as a script for Microsoft Internet
> Information Server on Winnt 3.51, the web server will not execute dos based stdio
> programs.  I have tried using program script(input,output) which reports file not
> open  for write, I have added rewrite(output) which causes an error because output
not assigned.  I have assigned output to '' which outputs nothing to the
console or the redirected file.
>
>                  If anyone understands my problem, and has an idea or
> solution,
>  please help me.  Thank you.
>
>
Ok, here is the solution to your prob : you need to write a text file device
driver. I just happen to have code. You want the StdOut things, i can't
remember how it works =(
p.s. the file's attached.
(*)

unit SimultIO;
{$D-,F+,R-}
(* Unit for simultaneous I/O.
   This will be useful for redirection - when you write to a
   file assigned to by AssignSimult, data written to it will write to
   the file AND the screen. *)
interface
{$F+} procedure AssignSimult(var f : text;n : string); far; {$F-}
implementation
uses Dos,CRT;
var  R : Registers;
    OP : Text;
{$F+} function WriteByteToFile(FileHandle : Word;var value) : integer;far; {$F-}
var r : registers;
begin
 r.ah := $40;
 r.bx := FileHandle;
 r.cx := 1;
 r.ds := seg(value);
 r.dx := ofs(value);
 MsDos(R);
 if (r.flags and fcarry)<>0 then
  begin
   r.ah := $59; (* Get extended error info *)
   msdos(R);
   WriteByteToFile := r.ax; (* IOResult returns the value in InOutRes *)
  end
 else WriteByteToFile := 0;
end;
(*
            INT 21,40 - Write To File or Device Using Handle
        AH =  40h
        BX =  file handle
        CX =  number of bytes to write, a zero value truncates/extends
             the file to the current file position
        DS:DX =  pointer to write buffer

        on return:
        AX =  number of bytes written if CF not set
           =  error code if CF set  (see DOS ERROR CODES)

        - if AX is not equal to CX on return, a partial write occurred
        - this function can be used to truncate a file to the current
          file position by writing zero bytes                         *)
{$F+} function StdOut(var f: textrec) : integer; far;  {$F-}
var
  p,err : integer;
  r : registers;
begin
 if f.mode=fmclosed then
  begin
   StdOut := 103;
   exit;
  end;
  with F do
   begin
    for P := 0 to bufpos-1 do
     begin
      r.ah := $02;
      r.dl := ord(bufptr^[p]);
      msdos(R);
     end;
   BufPos:=0;
  end;
  StdOut:=0;
end;
{$F+} function SimultWrite(var f: textrec): integer; far;  {$F-}
var
  p,err : integer;
begin
 if f.mode=fmclosed then
  begin
   SimultWrite := 103;
   exit;
  end;
  with F do
   begin
    for P := 0 to bufpos-1 do
     begin
      err := WriteByteToFile(Handle,BufPtr^[p]);
      if err<>0 then
       begin
        SimultWrite := Err;
        BufPos := P+1;
        exit;
       end;
      Write(OP,BufPtr^[p]);
     end;
   BufPos:=0;
  end;
  SimultWrite:=0;
end;
{$F+} function SimultOpen(var f: textrec): integer; far;  {$F-}
var
  P: integer;
begin;
  case F.Mode of
   FMOutput : begin (* Rewrite *)
               if f.name[0]= #0 then
                begin
                F.InOutFunc:= @StdOut;
                F.FlushFunc:= @StdOut;
              end else begin
               r.ah :=  $3C;
               r.cx :=  $0000;
               r.ds :=  Seg(F.Name);
               r.dx :=  Ofs(F.Name);
               MsDos(R);
               if (R.flags and FCarry)<>0 then
                begin
                 R.AH :=  $59;
                 MsDos(R);
                 SimultOpen :=  R.AX;
                 exit;
                end;
               F.Handle :=  r.ax;
               (*
                  INT 21,3C - Create File Using Handle

        AH =  3C
        CX =  file attribute  (see FILE ATTRIBUTES)
        DS:DX =  pointer to ASCIIZ path name

        on return:
        CF =  0 if successful
           =  1 if error
        AX =  files handle if successful
           =  error code if failure  (see DOS ERROR CODES)

        - if file already exists, it is truncated to zero bytes on opening
*)
                F.InOutFunc:= @SimultWrite;
                F.FlushFunc:= @SimultWrite;
               end;
               F.BufPos:= 0;
               SimultOpen:= 0;
              end;
   FMInOut  : begin (* Append *)
               f.mode :=  fmOutput;
               r.ah :=  $3d ;
               r.al :=  $01;
               r.cx :=  $0000;
               r.ds :=  Seg(F.Name);
               r.dx :=  Ofs(F.Name);
               MsDos(R);
               if (R.flags and FCarry)<>0 then
                begin
                 R.AH :=  $59;
                 MsDos(R);
                 SimultOpen :=  R.ax;
                 exit;
                end;
               F.Handle :=  r.ax;
               r.bx :=  r.ax;
               r.al :=  $02;
               R.ah :=  $42;
               r.cx :=  $0000;
               r.dx :=  $0001; (* Seek past EOF *)
               MsDos(R);
               if (r.flags and fcarry)<>0 then
                begin
                 r.ah :=  $59;
                 msdos(R);
                 SimultOpen :=  R.AX;
                 exit;
                end;
               (*
               INT 21,42 - Move File Pointer Using Handle

        AH =  42h
        AL =  origin of move:
             00 =  beginning of file plus offset  (SEEK_SET)
             01 =  current location plus offset  (SEEK_CUR)
             02 =  end of file plus offset  (SEEK_END)
        BX =  file handle
        CX =  high order word of number of bytes to move
        DX =  low order word of number of bytes to move

        on return:
        AX =  error code if CF set  (see DOS ERROR CODES)
        DX:AX =  new pointer location if CF not set

        - seeks to specified location in file
                   INT 21,  - Open File Using Handle
        AH =
        AL =  open access mode
             00  read only
             01  write only
             02  read/write
        DS:DX =  pointer to an ASCIIZ file name
 =

        on return:
        AX =  file handle if CF not set
           =  error code if CF set  (see DOS ERROR CODES)
        Access modes in AL:

        =B37=B36=B35=B34=B33=B32=B31=B30=B3  AL
         =B3 =B3 =B3 =B3 =B3 =C0=C4=C1=C4=C1=C4=C4=C4=C4 read/write/updat=
e access mode
         =B3 =B3 =B3 =B3 =C0=C4=C4=C4=C4=C4=C4=C4=C4=C4 reserved, always =
0
         =B3 =C0=C4=C1=C4=C1=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4 sharing mode (=
see below) (DOS 3.1+)
         =C0=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4=C4 1 =  private, =
0 =  inheritable (DOS 3.1+)
=0D
        Sharing mode bits (DOS 3.1+):          Access mode bits:
        654                                    210
        000  compatibility mode (exclusive)    000  read access
        001  deny others read/write access     001  write access
        010  deny others write access          010  read/write access
        011  deny others read access
        100  full access permitted to all
*)
               F.InOutFunc :=  @SimultWrite;
               F.FlushFunc :=  @SimultWrite;
               F.BufPos:= 0;
               SimultOpen:= 0;
              end;
  else
   SimultOpen :=  12; (* Invalid file access code - you can only Rewrite=
 or Append this *)
  end;
end;

{$F+}function SimultClose(var F: textrec): integer; far;  {$F-}
var
  P: integer;
begin;
 if f.mode= fmclosed then
  begin
   SimultClose :=  103;
   exit;
  end;
(*
                  INT 21,3E - Close File Using Handle

        AH =  3E
        BX =  file handle to close

        on return:
        AX =  error code if CF set  (see DOS ERROR CODES)

        - if file is opened for update, file time and date stamp
          as well as file size are updated in the directory
        - handle is freed
=0D
 *)
  r.ah :=  $3E;
  r.bx :=  f.handle;
  MsDos(R);
  if (R.flags and fcarry)<>0 then
   begin
    r.ah :=  $59;
    MsDos(R);
    SimultClose :=  R.AX;
    exit;
   end;
  F.Mode :=  FMClosed;
  SimultClose:= 0;
end;

{$F+} procedure AssignSimult(var f : text;n : string); {$F-}
begin
  with textrec(f) do begin
    Mode     :=  fmClosed;
    Handle   :=  $FFFF;
    Bufsize  :=  SizeOf(Buffer);
    Bufpos   :=  0;
    Bufptr   :=  @Buffer;
    OpenFunc :=  @SimultOpen;
    CloseFunc:=  @SimultClose;
    if n[0]>#79 then n[0] :=  #79; (* Truncate the name down to 79 chars=
 *)
    Move(N[1],Name[0],79);
    Name[Length(N)] := #0; (* Name is null-terminated *)
  end;
end;
begin
 AssignCRT(OP);
 Rewrite(OP);
end.
