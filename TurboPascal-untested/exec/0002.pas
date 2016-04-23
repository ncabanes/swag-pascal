{$M 4096,0,4096}

Uses
  Dos, Prompt;

begin
  ChangeShellPrompt('Hi There');
  SwapVectors;
  Exec(GetEnv('COMSPEC'),'');
  SwapVectors;
end.