{There are basically two ways of retrieving the command line. One way is to use
the ParamStr Variable: ParamStr(1) contains the first paramter, ParamStr(2)
contains the second parameter etc. Another way is to fetch the entire command
line String from your environment. This can be done as follows:
}

Program GetCommandLine;

Type

  PCommandLine = ^TCommandLine;
  TCommandLine = String;

Var

  CommandLine : PCommandLine;

begin
  CommandLine := Ptr ( PrefixSeg, $80 );
end.
