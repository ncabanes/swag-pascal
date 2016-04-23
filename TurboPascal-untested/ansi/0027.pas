{
From: GREG ESTABROOKS
Subj: ANS->BIN
---------------------------------------------------------------------------
DT>        I'm looking for some kinda code which will convert an ANSI file
DT> to a raw binary file (<-Or Something that can be directly written to
DT> the screen, without decoding). Something which converts an ansi file, say
DT>24-255 lines to an array which holds <CHAR>,<ATTRIBUTE>,<CHAR>,ect..just
DT>like video memory. Can anybody help me out here?

        Just feed the ansi into the CON and then dump the contents of
        video memory to a file. Heres a demo of how to do it.

        NOTE: this does not check file IO so if the file doesn't exist
              it'll cause a runtime error.

        Call it like this:
             ANSDUMP  AnsiFile DumpFile
}
{***********************************************************************}
PROGRAM AnsiDump;               { Dec 09/93, Greg Estabrooks.           }
USES CRT;                       { IMPORT Clrscr,Writeln                 }
VAR
   Con,                         { File handle to the Console.           }
   InFile :TEXT;                { File that contains ANSI info.         }
   OutFile:FILE;                { File to send new info to.             }
   BuffStr:STRING;              { Holds string read from Ansi File.     }

BEGIN
  Clrscr;                       { Clear any screen clutter.             }
  Assign(InFile,ParamStr(1));   { Open Ansi File.                       }
  Reset(InFile);
  Assign(Con,'');               { Assign Con to the Console.            }
  ReWrite(Con);                 { Set it for writing to.                }
  Assign(OutFile,ParamStr(2));  { Open file to send dump to.            }
  ReWrite(OutFile);
  WHILE NOT Eof(InFile) DO      { Loop through entire ansi file.        }
   BEGIN
     Readln(InFile,BuffStr);    { Read line from file.                  }
     Writeln(Con,BuffStr);      { Write line to console.                }
   END;
                                { Now block write entire contents of text}
                                { video memory to file.                 }
  BlockWrite(OutFile,MEM[$B800:0000],4000);
  Close(OutFile);               { Close dump file.                      }
  Close(Con);
  Close(InFile);                { Close ansi file.                      }
  Readln;
END.
