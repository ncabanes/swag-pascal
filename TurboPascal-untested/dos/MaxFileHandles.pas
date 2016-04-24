(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0093.PAS
  Description: Max File Handles
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:50
*)


{
DOS imposes a limit of 20 open files for any one program.  DOS, friendly

as it is, uses 5 of these file handles internally - leaving your
application with only 15 available file handles.  Fortunately, the 15-
file barrier is easily broken.  Just add the GetMoreHandles() function to
your application, and call it in the beginning of your program, passing it
the number of handles you would like your application to have available.
The number you pass must be in the range of 20 to 255, and it must not
exceed the number specified in the FILES= statement of your CONFIG.SYS.

}

uses DOS;

function GetMoreHandles(NumHandles: Word): Boolean;
{
  NumHandles is the number of file handles you want your application
  to have available.  If an error occurs, function will return False,
  and any DOS error will be reported in the DOSError global variable.
  NOTE: NumHandles must be less than or equal to the number specified
  in the FILES= statement in your CONFIG.SYS.
}
Var
  ReturnVal: Boolean;
begin
  ReturnVal := True;   { assume success }

  { Check to make sure DOS version is greater than 3.3 }
  if (((DOSVersion and $00FF) = 3) and ((DOSVersion and $FF00) < 3)) or
     ((DOSVersion and $00FF) < 3) then ReturnVal := False;
  { Can't allocate more than 255 or less than 20 handles }
  if (NumHandles > 255) or (NumHandles < 20) then ReturnVal := False;
  if ReturnVal then asm
    mov ax, 6700h           { function 67h }
    mov bx, NumHandles      { requested handles in bx }
    int 21h                 { DOS call }

    jae @@NotAnError        { CF set on error }
    mov ReturnVal, 00h      { return false on error }
    mov DOSError, ax        { ax contains the error code }
    @@NotAnError:
  end;
  GetMoreHandles := ReturnVal;
end;

