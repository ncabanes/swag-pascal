
{

   I've been puzzling over Share myself the last week. Here's some
   tips from what I've found:

   1. Remember, if you are trying to write to the same region from
   both processes, you will *still* get a sharing violation with
   access denied to the last one to ask ! There is a subfunc, (440Bh
   I think) for changing the default number of tries that share will
   retry for access. You might want to look into that. Otherwise you
   could use something like the OpenTxtFile routine below, modified
   for use on non-text files, or both. (You aren't trying to share
   text files are you? If so, there IS a way to do it, let me know).

   2. Also note that you set the filemode AFTER assignment, and
   BEFORE a reset, rewrite or append.

   3. The following are 2 functions I've put together to handle my
   stuff. Note that the first is for non-text files, the second is
   for text files. The text file routine uses an external TFDD unit
   to set up the filemode variable so it works with text files.
   Holler if you want the unit also.........

           (* Call this to lock or unlock the ENTIRE file
****** use lock =$00 & unlock = $01 constants for action *********
              ***** SHARE.EXE MUST be loaded ! *******
             Do NOT use on Text Files ! will NOT work !
You could modify this to only lock certain regions by passing values
for a start and stop region. Load CX/DX and DI/SI as done below. *)
}

Function LockFile(var f; action:byte):boolean;
Var
   fsize : longint;
Begin
 if GotShare then                         (* Share loaded ? *)
   begin
     fsize := longint(filesize(file(f)));   (* Get filesize *)
     Regs.AH := $5C;                             (* Subfunc *)
     Regs.AL := Action;           (* $00=Lock or $01=unlock *)
     Regs.BX := FileRec(f).Handle;        (* Git the handle *)
     Regs.CX := Hi($00);                   (* Start of file *)
     Regs.DX := Lo($00);
     Regs.DI := Lo(fsize);           (* Compute end of file *)
     Regs.SI := Hi(fsize);
     Intr($21, Regs);
     if ((Regs.FLAGS and $01) = 0) then LockFile := true
     else
       begin
         IORes := regs.AX;      (* If fails, errcode is in AX *)
         LockFile := false;    (* IORes is a global that gets *)
       end;                   (* used in IOReport if an error *)
   end;
End;

(*-------------------------------------------------------------*)
  (* Share compatable  Will retry if access denied, tries times
           5 Tries is equivilent to a 1/2 second wait

                                  ----- Sharing Method -----
 Access         Compatibility   Deny   Deny    Deny   Deny
 Method            Mode         Both   Write   Read   None
 ---------------------------------------------------------
 Read Only           0           16     32      48     64
 Write Only          1           17     33      49     65
 Read/Write          2*          18     34      50     66
                        * = default                        *)

FUNCTION OpenTxtFile(var f; fname:string; tries:word):boolean;
VAR
   i  : word;
Begin
  i := 0;
 if GotShare then                       (* Share loaded ? *)
   begin
     AssignText(text(f),Fname);         (* From TxtShare unit *)
     FileMode := 34;            (* Open in r/w-deny write mode *)
   end
 else  Assign(text(f),Fname);
 Repeat
  {$I-} Reset(text(f));
  IORes := IoResult; {$I+}
  if IORes = 5 then              (* Only repeat if denied access *)
    begin
      wait(100);                (* Wait 1/10 second before retry *)
      INC(i);                 (* Use your own delay routine here *)
    end
  else i := tries;                (*  Quit if not a sharing deny *)
 Until (IORes = 0) OR (i >= tries);
 if GotShare then FileMode := 2;      (* Set FileMode to default *)
 OpenTxtFile := IORes = 0;
End;

{    ****** Here's a quick SHARE detect routine ********* }

Function ShareInstalled : boolean; assembler;
asm
  mov ax,$1000
  int $2f
end;

