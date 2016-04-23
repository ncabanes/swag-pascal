Unit LongJump;

{ This Unit permits a long jump from deeply nested Procedures/Functions back }
{ to a predetermined starting point.                                         }

{ Whilst the purists may shudder at such a practice there are times when such}
{ an ability can be exceedingly useful.  An example of such a time is in a   }
{ BBS Program when the carrier may be lost unexpectedly whilst a user is on  }
{ line and the requirement is to "back out" to the initialisation reoutines  }
{ at the start of the Program.                                               }

{ to use the facility, it is required that a call be made to the SetJump     }
{ Function at the point to where you wish the execution to resume after a    }
{ long jump. When the time comes to return to that point call FarJump.       }

{ if you are an inexperienced Programmer, I do not recommend that this Unit  }
{ be used For other than experimentation.  Usually there are better ways to  }
{ achieve what you want to do by proper planning and structuring.  It is     }
{ rare to find a well written Program that will need such and ability.       }

Interface

Const
  normal = -1;                         { return was not from a LongJump call }
Type
  jumpType = Record                        { the data need For a return jump }
                bp,sp,cs,ip : Word;
             end;

Function  SetJump(Var JumpData : jumpType): Integer;
Procedure FarJump(JumpData : jumpType; IDInfo : Integer);

Implementation

Type
  WordPtr = ^Word;

Function SetJump(Var JumpData : jumpType): Integer;
  begin                     { store the return address (the old bp register) }
    JumpData.bp := WordPtr(ptr(SSeg,SPtr+2))^;
    JumpData.ip := WordPtr(ptr(SSeg,SPtr+4))^;
    JumpData.cs := WordPtr(ptr(SSeg,SPtr+6))^;
    JumpData.SP := SPtr;
    SetJump := normal;                { show that this is not a FarJump call }
  end;  { SetJump }

Procedure FarJump(JumpData : jumpType; IDInfo : Integer );
  begin
    { change the return address of the calling routine of the stack so that  }
    { a return can be made to the caller of SetJump                          }
    { Use IDInfo as an identifier of the routine the jump occurred from      }
    WordPtr(ptr(SSeg,JumpData.SP))^   := JumpData.bp;
    WordPtr(ptr(SSeg,JumpData.SP+2))^ := JumpData.ip;
    WordPtr(ptr(SSeg,JumpData.SP+4))^ := JumpData.cs;
    Inline($8b/$46/$06);                                     { mov ax,[bp+6] }
    Inline($8b/$ae/$fa/$ff);                                 { mov bp,[bp-6] }
  end;  { FarJump }

end.  { LongJump }


