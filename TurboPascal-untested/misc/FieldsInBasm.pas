(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0122.PAS
  Description: Fields in BASM
  Author: CHARLIE CALVERT
  Date: 11-26-94  05:07
*)

==============================================================
                  PASCAL ARTICLE FOR PAPER
                     by Charlie Calvert
==============================================================

        When Pascal programmers are using BASM, they are often
baffled when it comes time to address a field of an object. The
issue is that the field is usually located at an offset from the
segment of the pointer to that object, not from the data segment of
the program. As a result, a viable way to address a field of the
object is to first load its object's segment and offset into ES:DI.
You can use the following line of code to do this:
    [--]
    les di, Self
    [--]
   Once you are properly addressing the object itself, then all you
need do is calculate the offset of the field from the beginning of
the object. This can be done by adding the proper number of bytes
to ES:DI. For instance, if an object has three fields, all two bytes in
size, then the offset of the third field would be four:
    [--]
    mov ax, word [es:di + 4]
    [--]
    If these kinds of calculations bother you, you can avoid them by
loading the segment and offset of the object directly into the data
segement, but you should be sure to save its original value on the
stack, with a push and a pop.
    A simple illustration of the above principlese would be an object
with 3 fields, the last being an integer called M. This example
simply moves the value of that field into the AX register:

==============================================================
                        PASCAL EXAMPLE
==============================================================
program AsmObj;

type
  PMyObject = ^TMyObject;
  TMyObject = Object
    i,j: Word;
    M: Integer;
    procedure Foo;
    procedure Foo1;
  end;

procedure TMyObject.Foo;
begin
  asm
    les di, Self
    mov ax, word [es:di + 4]
  end;
end;

procedure TMyObject.Foo1;
begin
  asm
    push ds
    lds di, Self
    mov ax, word ptr [di + M]
    pop ds
  end;
end;

var
  O: PMyObject;

begin
  New(O);
  O^.M := 10;
  O^.Foo;
  O^.Foo1;
  Dispose(O);
end.
