(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0013.PAS
  Description: Dealing with TSR's
  Author: LOU DUCHEZ
  Date: 11-02-93  06:32
*)

(*
LOU DUCHEZ

>I need to write a TSR, but the books I have really don't go into much detail
>about them.  Anyone know any good books that explain about them?

My recommendation:

"Turbo Pascal 6.0: The Complete Reference" by Stephen O'Brien

Taught me about TSRs.  The basic deal with a TSR is these things:

1)  A $M directive to reduce the amount of memory used.
2)  A "Keep" procedure to make it TSR.
3)  (the tricky part) A new interrupt handler.  Actually it's not so tricky.
    What your handler should do is react to the hardware, then call the old
    interrupt handler.  In parts here:

    A)  Determine old handler address with getintvec.  Assign it to a
        "procedure" variable like so:

        var oldkbdhandler: procedure;   { for a keyboard handler }

        getintvec($09, @oldkbdhandler);


    B)  Create a new handler that reads the hardware: like so:

        var port60h: byte;              { global variable }


        procedure newkeyboardhandler; interrupt;
        begin
          port60h := port[$60];  { store keyboard port status }
          asm
            pushf     { PUSHF instruction is crucial before calling old ISR }
            end;
          oldkbdhandler;    { run the old keyboard handler }
          end;


    C)  To hook up the new handler, it's:

        setintvec($09, @newkeyboardhandler);

*)

