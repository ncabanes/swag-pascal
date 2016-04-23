
--------------------------------------------------------------------------------
By definition DLLs are dynamically loaded libraries of functions and sometimes
data. However, it's possible to either hard code the ability to "import"
functions from DLLs or dynamically "bind" a DLL during the run time --
which of course means that we don't necessarily need to know the name of
the DLL nor the name of the function we're about to call (to a certain extent)
during the time we code. Dynamically loading and unloading DLLs could not
only save memory, but also can help you write programs that are able to
"adjust" itself if certain DLLs are missing.Following "LoadAndRunDLLProcedure()"
function will let you pass the name of the DLL you want to connect to and
the name of the function you want to call. If everything goes well, it will
load the DLL, call the function, and then unload the DLL.

function LoadAndRunDLLProcedure(
  sDLL,
  sFunc : string )
  : boolean;
type
  // define the type of "function"
  // we're calling
  TFunc_Start = procedure;
var
  Func_Start : TFunc_Start;

  hDll       : THandle;
  FuncPtr    : TFarProc;
  sMsg       : string;
begin
  Result := False;
  hDll   := LoadLibrary(
              PChar( sDLL ) );
  if(hDll > 32)then
  begin
    FuncPtr :=
      GetProcAddress(
        hDll, PChar( sFunc ) );
    @Func_Start := FuncPtr;
    if(nil <> @Func_Start)then
    begin
      Func_Start;
      Result := True;
    end else
    begin
      sMsg := 'DLL entry point ' +
              sFunc + ' not found';
      MessageBox(
        0, PChar( sMsg ), 'Error',
        MB_OK );
    end;
    FreeLibrary( hDll );
  end else
  begin
    sMsg := 'File ' + sDLL +
            ' not found';
    MessageBox(
      0, PChar( sMsg ), 'Error',
      MB_OK );
  end;
end;


For example, let's say you want to call a procedure called "HelloWorld()"
in a DLL named "MyStuff.DLL:"

LoadAndRunDLLProcedure(
  'MyStuff.DLL',
  'HelloWorld' );


Please note that HelloWorld() must be a procedure, for example, declared as:
procedure HelloWorld;
or in C:
void HelloWorld();
