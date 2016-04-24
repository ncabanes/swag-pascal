(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0056.PAS
  Description: Is String in File
  Author: JOHN HOWARD
  Date: 08-24-94  13:44
*)


PROGRAM HI_There;
(*   Syntax:  there  textfile  number  /quotedstring
   where textfile is filename, number is a line offset, & quotedstring is a
   group of characters without embedded control codes.  Purpose is to go to a
   given line offset in the text file, search that line for the string, and
   report via DOS error 1=True or 0=False depending upon if it was there.

Example:  there.exe  there.pas  0  /'program'
   would return error level 1 (True) since 'program' is on the first line.

Author:  John Howard                                   Date:  January 5, 1994
Copyright 1994  Howard International,  P.O. Box 34633, NKC, MO 64116

Restrictions:  You are free to use this program but I retain commercial
               ownership.  You may not charge someone to use this program.
Note:          Case sensitive.  Front or Back quote is removed.  No trailing
               whitespace is removed from the string.  Zero-based line offset.
               Returns DOS error level values: 0 thru 4 ******* *)
{$DEFINE debug}
VAR
   F: text;          (* CHAIN.TXT dropfile used by WWIV BBS *)
   LineNo: word;     (* Line Number from 0..65535 *)
   S: string;        (* Substring of 1..255 characters *)
   CmdLine: string;  (* string[127] command-line string *)

   Test: string;     (* temporary search line *)
   Code: integer;    (* temporary result of VAL conversion *)
   I: word;          (* temporary index of current line *)
   B: byte;          (* temporary index of command-line string *)
BEGIN { MAIN }
      {$I-}  (* Turn OFF input/output checking to prevent run-time error *)
      (* Open an existing text file *)
      Assign(F, ParamStr(1));
      Reset(F);
      {$I+}  (* Turn ON I/O *)
      if (IOResult <> 0) then Halt(2); {writeln('File not found');}
      (* Get text from command line and convert into a number *)
      Val(ParamStr(2), LineNo, Code);
      if Code <> 0 then Halt(3); {writeln('Bad number at position: ', Code);}
      (* Get quoted string or un-broken string. NO end whitespace removed! *)
      Move(Mem[PrefixSeg:$80], CmdLine, Mem[PrefixSeg:$80] + 1);
      S := CmdLine;
{$IFDEF debug}                  writeln(S);  {$ENDIF}
      B := Pos( '/', S);
{$IFDEF debug}                  writeln('CmdLine pos ', B);  {$ENDIF}
      Delete(S, 1, B);
      if S[1] = #39 then Delete(S, 1, 1);                   (* start quote *)
      if S[Length(S)] = #39 then Delete(S, Length(S), 1);   (* end quote *)
      if S = '' then Halt(4); {writeln('Empty string not allowed');}
{$IFDEF debug}                  writeln('Line: ', LineNo);  {$ENDIF}
{$IFDEF debug}                  writeln(S);  {$ENDIF}
      (* Go to specified line within text file *)
      I := 0;
      while not Eof(F) do
          begin
          Readln(F, Test);
{$IFDEF debug}                  writeln(Test);  {$ENDIF}
          if (I = LineNo) then
             begin
             if Pos(S, Test) > 0 then
             (* String S matched substr Test at position *)
                begin
                Close(F);
{$IFDEF debug}                  writeln('True ', I);  {$ENDIF}
                Halt(1);   (* Return True *)
                end
             else
             (* Search string not found *)
                begin
                Close(F);
{$IFDEF debug}                  writeln('False ', I);  {$ENDIF}
                Halt(0);   (* Return False *)
                end;
             end;
          (* Move to the next line *)
          if (I < 65535) then
             INC(I)               {I := I + 1}
          else
             begin
             Close(F);
             Halt(0);
             end;
          end;  {while}
      (* Close the existing text file *)
      Close(F);
      Halt(0);     (* Return False *)
END.  { MAIN }


