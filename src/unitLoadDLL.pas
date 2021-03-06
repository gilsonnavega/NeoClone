unit unitLoadDLL;

interface

uses Windows, Dialogs, SysUtils;

type
  TShowme = procedure(); stdcall;
  TCloseme = procedure(); stdcall;
  TGethandle = function():integer; stdcall;

  TaddDisplayItem = procedure( index: integer; item: string ); stdcall;
  TrefreshDisplay = procedure( index: integer ); stdcall;
  TaddDisplay = function():integer; stdcall;
  TdelDisplay = procedure( index: integer ); stdcall;

var
  showme : TShowme = nil;
  closeme : TCloseme = nil;
  gethandle : TGethandle = nil;

  addDisplayItem : TaddDisplayItem = nil;
  refreshDisplay : TrefreshDisplay = nil;
  addDisplay : TaddDisplay = nil;
  delDisplay : TdelDisplay = nil;

  DllHandle : THandle;

  function LoadLib : Boolean;
  procedure UnloadLib;

implementation

function LoadLib : Boolean;
begin
  if DllHandle = 0 then begin

    DllHandle := LoadLibrary(PWideChar(ExtractFilePath(paramstr(0)) + '\huddll\Win32\Debug\huddll.dll'));
    if DllHandle > 0 then begin
      @showme := GetProcAddress(DllHandle,'showme');
      @closeme := GetProcAddress(DllHandle,'closeme');
      @gethandle := GetProcAddress(DllHandle,'gethandle');

      @addDisplayItem := GetProcAddress(DllHandle,'addDisplayItem');
      @refreshDisplay := GetProcAddress(DllHandle,'refreshDisplay');
      @addDisplay := GetProcAddress(DllHandle,'addDisplay');
      @delDisplay := GetProcAddress(DllHandle,'delDisplay');

    end
    else begin
      MessageDlg('HUD functionality is not available', mtInformation, [mbOK], 0);
    end;
  end;
  Result := DllHandle <> 0;
end;

procedure UnloadLib;
begin
  if DLLHandle <> 0 then begin
    FreeLibrary(DLLHandle);
    DllHandle := 0;
  end;
end;

initialization
  //LoadLib;

finalization
  UnloadLib;

end.
