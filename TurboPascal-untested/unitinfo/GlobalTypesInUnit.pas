(*
  Category: SWAG Title: UNIT INFORMATION ROUTINES
  Original name: 0003.PAS
  Description: Global Types In UNIT
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  14:09
*)

{
I am wondering if it is possible to pass a Record Type and File Type to
a Procedure in a Unit where the Record or File Type has not
been declared.  if it can be done I will need a little sample
to get me going.  Thanks in advance.

Yes, as long as the Unit With the Procedure Uses the Unit in which the Types
are declared.  That's why it's frequently a good idea to move all your global
Types and Variables to their own little Unit:
}

Unit Globals;

Interface

Type
  tMyRecord = Record
    Name,Address : String[40];
    Zip : String[5];
    { etc.}
  end;

Implementation

end.  { of Unit Globals }


Unit LowLevels;

Interface

Uses Globals;

Procedure GetMyRecord(Var ThisRecord : tMyRecord);

Implementation

Procedure GetMyRecord(Var ThisRecord : tMyRecord); begin
  { whatever }
end;

end. { of Unit LowLevels }


Program  WhatEver;

Uses Globals, LowLevels;

Var
  MainRecord : tMyRecord;
  { depending on a lot of things, you might want to declare this
    Variable in the Unit Globals, rather than here }

begin
  GetMyRecord(MainRecord);
end.


