Unit ExecPath;

Interface

PROCEDURE ExecInPath(line : STRING);

FUNCTION FindInPath(cmd : STRING): STRING;

FUNCTION Exist(fn : STRING): BOOLEAN;

Implementation

Uses
  Dos;

FUNCTION Exist(fn : STRING): BOOLEAN;
VAR
  f : FILE;
  a : WORD;
BEGIN
  Assign(f,fn);
  GetFAttr(f,a);
  Exist := DosError = 0;
END;

FUNCTION FindInPath(cmd : STRING): STRING;
VAR
  path : STRING;
  Dir : DirStr;
  Name : NameStr;
  Ext : ExtStr;
  p : WORD;
BEGIN
  FSplit(cmd,Dir,Name,Ext);
  IF Dir <> '' THEN BEGIN
    IF Ext <> '' THEN BEGIN
      cmd := Dir + Name + Ext;
      IF NOT Exist(cmd) THEN cmd := '';
    END
    ELSE BEGIN
      cmd := Dir + Name + '.COM';
      IF NOT Exist(cmd) THEN BEGIN
        cmd := Dir + Name + '.EXE';
        IF NOT Exist(cmd) THEN BEGIN
          cmd := Dir + Name + '.BAT';
          IF NOT Exist(cmd) THEN
            cmd := '';
        END;
      END;
    END;
    FindInPath := cmd;
    Exit;
  END;

  path := '.;'+GetEnv('PATH');

  REPEAT
    p := Pos(';',path);
    IF p = 0 THEN p := Length(path)+1;

    Dir := Copy(path,1,p-1);
    Delete(path,1,p);

    IF Dir[Length(Dir)] <> '\' THEN
      Insert('\',Dir,Length(Dir)+1);

    IF Ext <> '' THEN BEGIN
      cmd := Dir + Name + Ext;
      IF NOT Exist(cmd) THEN
        cmd := '';
    END
    ELSE BEGIN
      cmd := Dir + Name + '.COM';
      IF NOT Exist(cmd) THEN BEGIN
        cmd := Dir + Name + '.EXE';
        IF NOT Exist(cmd) THEN BEGIN
          cmd := Dir + Name + '.BAT';
          IF NOT Exist(cmd) THEN
            cmd := '';
        END;
      END;
    END;
  UNTIL (cmd <> '') OR (path = '');

  FindInPath := cmd;
END;

PROCEDURE ExecInPath(line : STRING);
VAR
  command : PathStr;
  space : WORD;
BEGIN
  WHILE (Length(line) > 0) AND (line[1] <= ' ') DO Delete(line,1,1);
  IF Length(line) = 0 THEN Exit;
  space := Pos(' ',line);
  IF space = 0 THEN BEGIN
    command := line;
    line := '';
  END
  ELSE BEGIN
    command := Copy(line,1,space-1);
    Delete(line,1,space-1);
  END;

  command := FindInPath(command);

  IF command = '' THEN
    DosError := 123
  ELSE IF Copy(command,Length(command)-3,4) = '.BAT' THEN BEGIN
    SwapVectors;
    Exec(GetEnv('COMSPEC'),'/C '+command+line);
    SwapVectors;
  END
  ELSE BEGIN
    SwapVectors;
    Exec(command,line);
    SwapVectors;
  END;
END;

END.
