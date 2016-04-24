(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0103.PAS
  Description: RAW to WAV sound converter
  Author: ALEKSANDAR DLABAC
  Date: 03-05-97  06:02
*)

 Program RAW2WAV;
{
             ██████████████████████████████████████████████████
             ███▌▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██    RAW to WAV sound file converter   ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌██           Aleksandar Dlabac          ██▐███▒▒
             ███▌██    (C) 1995. Dlabac Bros. Company    ██▐███▒▒
             ███▌██    ------------------------------    ██▐███▒▒
             ███▌██      adlabac@urcpg.urc.cg.ac.yu      ██▐███▒▒
             ███▌██      adlabac@urcpg.pmf.cg.ac.yu      ██▐███▒▒
             ███▌██                                      ██▐███▒▒
             ███▌▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▐███▒▒
             ██████████████████████████████████████████████████▒▒
               ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
}
   Uses Dos;

   Var I, Br  : integer;
       Size   : longint;
       Readed : word;
       St     : string;
       S, D   : file;
       SRec   : SearchRec;
       Buffer : array [1..60000] of byte;

    Begin
      Writeln (' RAW2WAV - converts RAW sound file to WAV format (11025Hz, mono)');
      Writeln (' (C) Aleksandar Dlabac 1995.');
      Writeln (' Dlabac Brothers Company - DBC');
      Writeln;
      If ParamCount<>1 then
        Begin
          Writeln (' Usage: RAW2WAV RAW_file_name (without .RAW extension)');
          Halt
        End;
      St:=ParamStr (1);
      FindFirst (St+'.RAW',Archive,SRec);
      Br:=0;
      While DosError=0 do
        Begin
          Inc (Br);
          Write (SRec.Name);
          For I:=1 to 12-Length (SRec.Name) do
            Write (' ');
          Write (' ---> ',Copy (SRec.Name,1,Length (SRec.Name)-3)+'WAV',' ...');
          Assign (S,SRec.Name);
          Assign (D,Copy (SRec.Name,1,Length (SRec.Name)-3)+'WAV');
          Reset (S,1);
          Size:=FileSize (S);
          Inc (Size,36);
          Rewrite (D,1);
          St:='RIFF';
          BlockWrite (D,St [1],4);
          BlockWrite (D,Size,4);
          St:='WAVEfmt '#$10#$00#$00#$00#$01#$00#$01#$00#$11'+'#$00#$00#$11'+'#$00#$00#$01#$00#$08#$00'data';
          BlockWrite (D,St [1],Length (St));
          Dec (Size,36);
          BlockWrite (D,Size,4);
          While not Eof (S) do
            Begin
              BlockRead (S,Buffer [1],60000,Readed);
              BlockWrite (D,Buffer [1],Readed)
            End;
          Close (S);
          Close (D);
          Writeln (#$08#$08#$08'OK ');
          FindNext (SRec)
        End;
      Writeln;
      Writeln ('    ',Br,' files converted.')
    End.
