(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0030.PAS
  Description: Compression Signatures
  Author: IAN LIN
  Date: 05-26-95  22:58
*)


{ Updated ARCHIVES.SWG on May 26, 1995 }


{ Updated ANSI.SWG on May 26, 1995 }

{
> What I need to know is if there is a simple method to
> determine which archiving program was used to compress a file(s)?  I am

You can check signatures. Strings at certain offsets give them away. From
my BBS program, I can tell you some.

Each starts at an offset and then has a string. These offsets and strings
are as follows and are in hexadecimal:

ARC: 0,1a
ZIP: 0,504b0304 (old)
LH113: 2,2d6c68
LHarc: 2,2d6c68
ZOO: 0,5a4f4f
ARJ: 0,60ea

> If it is possible to read the file directly could some one
> please tell me how, or post some algorithm to show me what I should
> be doing.  Also is it possible to read a self-extracting file to

Use var f:file. Reset(f,1). Seek(f,offset). Blockread(f,somevar,bytecount).
}

