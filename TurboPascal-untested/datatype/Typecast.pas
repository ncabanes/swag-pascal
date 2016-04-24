(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0008.PAS
  Description: TYPECAST.PAS
  Author: GREG VIGNEAULT
  Date: 05-28-93  13:37
*)

(*
> Hi, I am a begginer Programer (I taught myself) and I am writing a
> sort of "matching Program" my problem is: is there a way to give to
> Variable two values of diffent Types (a Variable called X1 would
> have one Char Type and hold a Integer value at the same time)?

 Yes.  There is more than one way to do this, using Turbo Pascal.

 The most familiar way is by using the "Type-transfer" Functions:

            orD()           { transfer Char value to Word|Integer   }
            CHR()           { transfer Word|Integer to Char         "

 Similar to this, there is also "Type-casting."  to use this method
 you just put the Variable to be changed inside of brackets that
 specify the Type wanted (see example below).

 A third way is to use "free unions," which look like Records. Again,
 the example code, below, is the best way to show you.

 Experiment With this example code.  if you still have problems
 after, show me an example of what you are trying to do ...
*)

(*******************************************************************)
 Program Example;               { Compiler: Turbo & Quick Pascal    }
                                { Feb.17.1993, Greg Vigneault       }

 { Examples of Type-transfer, Type-cast, and free unions ...        }

 Type   CharInt = Record                        { the free union    }
                    Case Word of
                        0   : ( Ch  : Char );
                        1   : ( Int : Integer );
                  end;

 Var    myVar   :CharInt;                       { a free union Var  }
        bVar    :Byte;                          { unsigned 8-bit    }
        cVar    :Char;                          { a Character       }
        iVar    :Integer;                       { signed 16-bit     }
        wVar    :Word;                          { unsigned 16-bit   }
 begin
 {  examples using "Type-transfer" Functions ...                    }

    bVar := 65;           WriteLn( bVar );      { Byte value        }
    cVar := CHR( bVar );  WriteLn( cVar );      { displays 'A'      }
    iVar := orD( cVar );  WriteLn( iVar );      { Char to Integer   }

 {  examples using "Type-casting" ...                               }

    cVar := Char( bVar );  WriteLn( cVar );     { cast Char to Byte }
    bVar := Byte( cVar );  WriteLn( bVar );     { cast Byte to Char }
    iVar := Integer( cVar );  WriteLn( iVar );  { Char to Integer   }

 { examples using a "free union" ...                                }

    myVar.Ch := 'A';                            { assign as Char    }
    WriteLn( myVar.Int );                       { display Integer   }
    myVar.Int := 48;                            { assign Integer    }
    WriteLn( myVar.Ch );                        { display Char '0'  }

 end {Example}.
(*******************************************************************)

