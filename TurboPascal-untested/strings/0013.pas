{
Functions returning Strings are generally space wasters.  For example,
suppose you have :

Function UpCaseStr(s : String) : String;

if you're implementing it in plain Pascal, you'll need 1024 Bytes of data
at a minimum:
- 256 Bytes are allocated For "s", the Formal parameter
- 256 Bytes For a local copy of "s" since it was passed as a value parameter
- 256 Bytes For a local Variable of the Type String, working storage to build
      the Function result
- 256 Bytes For assigning the result to the Function result
      (as in: "UpCaseStr := Result").

You can cut this figure by 50% by taking the following steps:
- (Version 7) Change the parameter header into
  "Function UpCaseStr(Const s : String) : String".  Provided you don't
  change "s", no local copy of the String will be created.
- (Version 6) Implement the routine in Assembler.  Requires knowledge of
  Asm, of course - but it generally will do away With the need of allocating
  256 Bytes of working storage.

Now you have reduced data space to 512 Bytes: it has become a basic
input-output Function.  One question remains: it is necessary to load the
String to examine the result of such a Function.  Suppose we want to figure out
whether the user has entered a switch on the command line: do we need a
Variable of the Type String to acComplish this?  You don't.  The following
snippet of code will show how: using a 2 Bytes macro, we'll convert a String
into a Pointer to a String.  You only have to dereference the Pointer to get
the result - and save 256 Bytes of data space in the process.
}

Type
  PString      = ^String;

Function StrPtr(Const s : String) : PString;

InLine(
  $58/         { POP  AX }
  $5A);        { POP  DX }

Var
  i            : Integer;
  sp           : PString;
  QuietFlag    : Boolean;

begin
  For i := 1 to ParamCount Do
    begin
      sp := StrPtr(ParamStr(i));
      if (sp^[1] in ['/', '-']) and (UpCase(sp^[2]) = 'Q') then
        QuietFlag := True;
      { Et cetera }
    end;
end.
