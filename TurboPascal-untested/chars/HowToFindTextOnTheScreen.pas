(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0011.PAS
  Description: How to find text on the screen
  Author: GEORGE ROBERTS
  Date: 05-31-96  09:16
*)

{----------------------------------------------------------------------------}
{ CCHAR Character Detection unit                                             }
{                                                                            }
{ All material contained herein is (c) Copyright 1995-96 Intuitive Vision    }
{ Software.  All Rights Reserved.                                            }
{                                                                            }
{ MODULE     :  CCHAR.PAS                                                    }
{ AUTHOR     :  George A. Roberts IV                                         }
{                                                                            }
{----------------------------------------------------------------------------}
{ Intuitive Vision Software is a Division of Intuitive Vision Computer       }
{ Services.                                                                  }
{----------------------------------------------------------------------------}
{ This source is copyrighted material of Intuitive Vision Software.  It may  }
{ be used freely in any non-commercial software package without any          }
{ royalties, providing that mention is given in the documentation of the fact}
{ that this source code has been used.  The notice should be placed in the   }
{ following manner:                                                          }
{                                                                            }
{ This software package uses the CCHAR Character Detection Unit which is     }
{ (c) Copyright 1995-96 Intuitive Vision Software.  All Rights Reserved.     }
{ Used by permission.                                                        }
{                                                                            }
{ This source code may be reproduced in tutorials and help files, such as    }
{ the SWAG archives, providing that it is reproduced in its entirety,        }
{ including the above copyrights and notices.                                }
{----------------------------------------------------------------------------}

UNIT CCHAR;

uses crt;

CONST vidseg:word=$B800;

var c:char;

procedure checkvidseg;
begin
  if (mem[$0000:$0449]=7) then vidseg:=$B000 else vidseg:=$B800;
end;

function currentchar:char;
begin
      checkvidseg;
      inline($FA);
      currentchar:=chr(mem[vidseg:(160*(wherey-1)+2*(wherex-1))]);
      inline($FB);
end;

end.

