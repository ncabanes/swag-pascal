(*
  Category: SWAG Title: TEXT FILE MANAGEMENT ROUTINES
  Original name: 0078.PAS
  Description: Example of reading a file backwards
  Author: GAYLE DAVIS
  Date: 11-29-96  08:17
*)

{$S+,R-,V-,I-,N-,B-,F-}
{$M 20000,0,655360}

    { example of reversing a text file }

USES Dos, Crt, Readback;
                   { note: READBACK is found in TEXTFILE.SWG }
VAR
    Outf   : TEXT;      { using Standard TP filetype to write this file }
    WorkF  : TEXT;
    InF    : BACKTEXT;  { using Readback filetype to read the file !! }
    OFname : STRING;
    IFname : STRING;
    St     : STRING;

BEGIN
         { open the text file containing original data for reading }
         IFName := 'ANYFILE.TXT'; { change this to your file name }
         AssignBack(InF, IFName);
         ResetBack(InF, 1024);

         { open the NEW text file that will be reversed for writing }
         IFName := 'OUTFILE.TXT'; { change this to your file name }
         ASSIGN (OutF, OFName);
         REWRITE (Outf);

         { now, read each line from the input and write to output }
         WHILE NOT BOF(InF) DO
               BEGIN
               ReadLnBack(Inf, St);
               WriteLn(OutF, St);
               END;

        CloseBack(Inf);
        Close(OutF);

        { now we have our reversed text in OUTFILE.TXT, so we need to
          put it into our original file.  This procedure is optional.
          It WILL DESTROY your original file !! }

         { open our reversed file in Standard TP mode for reading }
         ASSIGN (WorkF, OFName);  { our reversed file !! }
         RESET (Workf);

         { open our original file in Std TP mode for writing }
         ASSIGN (OutF, IFName);  { our original file !! }
         REWRITE (Outf);

         WHILE NOT EOF(WorkF) DO
               BEGIN
               ReadLn(WorkF, St);
               WriteLn(OutF, St);
               END;

         { close the two files }
         Close(WorkF);
         Close(Outf);

         { Now, our original file has the data REVERSED !! }

         { Here you could also erase the OUTFILE.TXT if you wanted to }

END.
