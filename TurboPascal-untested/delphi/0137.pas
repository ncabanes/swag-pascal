{
>>
>> DELPHI EQUIVALENT TO VB SHELL COMMAND
>>
[Trimmed]
>
>> 3: Will I have a method of monitoring the DOS program/shell to I
>>    know when it has terminated?
>>
>

You have to dig about a bit in the API to do this, but the answer is
basically to keep enumerating the task list until the task that you
started is no longer present. Do something like this to get the
Hinstance of your new task (The API call used to enumerate the task list
needs a Hinstance):
}
    {Execute batch file}
    StrPCopy(Templine, 'temp.bat');
    TaskHandle := ShellExecute(frmMain.Handle, NIL, 'command.com',
                  templine,
                  Tempdir,
                  SW_MINIMIZE);

and monitor it with a function like this:

<------------------------------------------------->

    function CheckTask(hInstance: WORD): Boolean;
    var
        TaskInfo: TTASKENTRY;
        RetVal: Boolean;
    begin
        TaskInfo.dwSize := SizeOf(TTASKENTRY);
        RetVal := FALSE;
        if(TaskFirst(@TaskInfo)) then
        begin
            repeat
                if(TaskInfo.hInst = hInstance) then
                begin
                    RetVal := TRUE;
                    Break;
                end;
            until (TaskNext(@TaskInfo) = FALSE);
        end;
        CheckTask := RetVal;
    end;
<-------------------------------------------------->

This runs down the task list, trying to find the task with the specified
Hinstance, returning true if it is still there. To use this function,
simply call it in a loop like this

    while CheckTask(TaskHandle) do
    begin
        Application.ProcessMessages;
    end;

Hope this helps.

---------------------------------------------------------------------
Marc Evans                      marc@leviathn.demon.co.uk
