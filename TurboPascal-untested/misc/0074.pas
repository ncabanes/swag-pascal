{
I've just "completed" (are programs *ever* completed?:) a rather
large programming project for a 3rd year uni subject.

We chose to use TechnoJock's Object Toolkit (currently available
version via Internet ftp) for much of the user interface (I'm
sorry we didn't look at TurboVision, but that's another story),
and I must admit that I was impressed with its overall
functionality (I counted 87 different objects along with many
useful non-object procedures), its ease of use and the generally
flawless results it produced.

However, there is a MAJOR point that I would like to share with
you all about this great toolkit that is NOT documented but
ESSENTIAL to know about if you use it.

The problem was that after a program that uses TOT was run, the
system became very unstable afterwards with memory problems,
usually locking up or something similar when subsequent programs
are run.

I solved this problem by calling all the destructor Done methods
of all the active TOT objects, then disposing of those on the
memory heap just before exiting the program.  Now the TOT docs
actually discourages this, but they don't mention that it does
indeed NEED to be done before termination of the program.

For example:
}

uses
  Crt, { Borland }
  totINPUT,
  totFAST,
  totDir,
  totIO1,
  totMSG,
  totKEY,
  totWIN,
  totLIST,
  totLINK,
  totLOOK,
  totSYS,
  totDATE;
  { TechnoJocks }
  { other units }

{ Then later... }

procedure TidyUpMess;
{ shutdown procedure }
begin
  { Tidy up after ourselves }
  dispose(myobjects, Done);
  { Tidy up after TechnoJocks }
  Mouse.Hide;                   { turn off the mouse }
  Screen.CursOn;                { vain attempt to get a cursor back in DOS }
  Screen.Done;                  { totFAST - the screen object is a variable}
  Key.Done;                     { totINPUT }
  Mouse.Done                    { totINPUT }
  Dispose(ALPHABETtot,Done);    { totINPUT }
  Dispose(LOOKtot,Done);        { totLOOK }
  Dispose(MONITOR,Done);        { totSYS }
  Dispose(IOtot,Done);          { totIO }
  Dispose(DATEtot,Done);        { totDATE }
  Dispose(SCROLLtot,Done);      { totFAST }
  Dispose(SHADOWtot,Done);      { totFAST }
end;

{
This does the job nicely... no more problems (that I could find,
anyway).  Note that the order of some of these calls is important.

The only problem that remains is that on dropping back to dos the
cursor is no longer there (but only with command.com - NOT if
4dos is installed - _strange_ indeed).

BTW, does anybody have a nice fix for this missing cursor?

Hopefully somebody will find this hard-found information useful.
If someone knows how to email or netmail the authors, then I'm
sure that they would like to know about this too; all I've got
about them is the following:

  TechnoJock Software, Inc.
  PO Box 820927
  Houston TX 77282
  Enquiries (713) 493-6354
  Compuserve ID: 74017,227
  Fax: (713) 493-5872
}
