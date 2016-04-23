So I'm using a common include file, which I'll add to the end of this message,
and I've noticed something very strange.  I used the Object browser to find
all the units, and I have triple checked to ensure they all include the
include file and this is what I've found:

With DEBUGGING set my file compiles to 115K
Without DEBUGGING set 81K

When I look at the file there is still loads of symbol information there.
After TDStrip of the above file, it's down to 55K (81-55=26).  That's a 26K
difference.  Where is it coming from?  Sure I'm using CRT and DOS, and
obviously the include file doesn't work for them, but after looking at the
remaining symbol information, it's alot of stuff from my various units
aswell as CRT and DOS.

What's the deal with the symbols coming from my units when I tell them
not to?  I say symbols as it's all declarations from my interface
sections like variables and procedure names, etc.

Anyways, I wasn't interested in using multiple configuration files, but
I guess I'll have to as I forgot about Borland units, and I guess everyone
else did aswell.

----------------------------- OPTIONS.INC --------------------------------
{
Turbo Pascal Compiler Directives
}

{$DEFINE i286}
{$DEFINE DEBUGGING}

{$A+}                   { Data Alignment........Word                  }
{$I-}                   { I/O Checking..........Off                   }
{$X-}                   { Enhanced Syntax.......Off                   }
{$V-}                   { String Type Checking..Relaxed               }
{$P-}                   { Open Strings..........Off                   }
{$T-}                   { @ Pointers............UnTyped               }

{$IFDEF i286}
{$G+}                   { 286 OpCodes...........On                    }
{$ELSE}
{$G-}                   { 286 OpCodes...........Off                   }
{$ENDIF}

{$IFDEF OVERLAYS}
{$F+}                   { Far Calls.............On                    }
{$O+}                   { Overlays Allowed......Yes                   }
{$ELSE}
{$F-}                   { Far Calls.............Off                   }
{$O-}                   { Overlays Allowed......No                    }
{$ENDIF}

{$IFDEF DEBUGGING}
{$B+}                   { Boolean Evaluation....Complete              }
{$D+}                   { Debugging Info........On                    }
{$L+}                   { Line Numbers..........On                    }
{$Y+}                   { Symbol Information....On                    }
{$R+}                   { Range Checking........On                    }
{$S+}                   { Stack Checking........On                    }
{$Q+}                   { Overflow Checking.....On                    }
{$ELSE}
{$B-}                   { Boolean Evaluation....Short Circuit         }
{$D-}                   { Debugging Info........Off                   }
{$L-}                   { Line Numbers..........Off                   }
{$Y-}                   { Symbol Information....Off                   }
{$R-}                   { Range Checking........Off                   }
{$S-}                   { Stack Checking........Off                   }
{$Q-}                   { Overflow Checking.....On                    }
{$ENDIF}

{
Program Memory Requirements
}
{$M 32000,0,0}          { Stack Size............32000   Heap.....0     }

.----------------------------------------------------.
| Colin Buckley                                      |
| Toronto, Ontario, Canada                           |
| InterNet: colin.buckley@rose.com                   |
|                                                    |
| So Eager to Play, So Relunctant to Admit it...     |
`----------------------------------------------------'

---
 ■ RoseReader 2.10ß P003288 Entered at [ROSE]
 * Rose Media, Toronto, Canada : 416-733-2285
 * PostLink(tm) v1.04  ROSE (#1047) : RelayNet(tm)

