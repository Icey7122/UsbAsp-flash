unit flashbridgehw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, Synaser, ch347hw, fbvio, Registry;

type
  TFlashBridgeHardware = class(TBaseHardware)
  private
    FCH347: TCH347Hardware;
    FSerial: TBlockSerial;
    FVIOConnected: boolean;
    FVIOError: string;
    function ReadUntilPrompt(TimeoutMs: integer): string;
    function ReadPromptFrom(ser: TBlockSerial; TimeoutMs: integer): string;
    function ProbePort(const Port: string): boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function GetLastError: string; override;
    function DevOpen: boolean; override;
    procedure DevClose; override;

    // SPI
    function SPIInit(speed: integer): boolean; override;
    procedure SPIDeinit; override;
    function SPIRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; override;
    function SPIWrite(CS: byte; BufferLen: integer; buffer: array of byte): integer; override;

    // I2C
    procedure I2CInit; override;
    procedure I2CDeinit; override;
    function I2CReadWrite(DevAddr: byte;
      WBufferLen: integer; WBuffer: array of byte;
      RBufferLen: integer; var RBuffer: array of byte): integer; override;
    procedure I2CStart; override;
    procedure I2CStop; override;
    function I2CReadByte(ack: boolean): byte; override;
    function I2CWriteByte(data: byte): boolean; override;

    // MICROWIRE
    function MWInit(speed: integer): boolean; override;
    procedure MWDeinit; override;
    function MWRead(CS: byte; BufferLen: integer; var buffer: array of byte): integer; override;
    function MWWrite(CS: byte; BitsWrite: byte; buffer: array of byte): integer; override;
    function MWIsBusy: boolean; override;

    // V002
    function VIOConnect(const Port: string): boolean;
    procedure VIODisconnect;
    function VIOGetStatus(var V, Target, Duty: double): boolean;
    function VIOGetStatusEx(var V, Target, Duty: double;
      TimeoutMs: integer): boolean;
    function VIOSetMillivolts(mv: integer): boolean;
    function VIOSetMillivoltsHold(mv, seconds: integer): boolean;
    function VIOWaitStable(TargetMV: integer; TimeoutMs: integer): boolean;
    function FindV002Port: string;
    property VIOConnected: boolean read FVIOConnected;
    property VIOError: string read FVIOError;
  end;

implementation

constructor TFlashBridgeHardware.Create;
begin
  FCH347 := TCH347Hardware.Create;
  FSerial := TBlockSerial.Create;
  FSerial.RaiseExcept := false;
  FHardwareName := 'FlashBridge';
  FHardwareID := CHW_FLASHBRIDGE;
end;

destructor TFlashBridgeHardware.Destroy;
begin
  VIODisconnect;
  FSerial.Free;
  FCH347.Free;
  inherited Destroy;
end;

function TFlashBridgeHardware.GetLastError: string;
begin
  if FVIOError <> '' then Result := FVIOError
  else Result := FCH347.GetLastError;
end;

function TFlashBridgeHardware.DevOpen: boolean;
begin
  Result := FCH347.DevOpen;
end;

procedure TFlashBridgeHardware.DevClose;
begin
  FCH347.DevClose;
end;

function TFlashBridgeHardware.SPIInit(speed: integer): boolean;
begin
  Result := FCH347.SPIInit(speed);
end;

procedure TFlashBridgeHardware.SPIDeinit;
begin
  FCH347.SPIDeinit;
end;

function TFlashBridgeHardware.SPIRead(CS: byte; BufferLen: integer;
  var buffer: array of byte): integer;
begin
  Result := FCH347.SPIRead(CS, BufferLen, buffer);
end;

function TFlashBridgeHardware.SPIWrite(CS: byte; BufferLen: integer;
  buffer: array of byte): integer;
begin
  Result := FCH347.SPIWrite(CS, BufferLen, buffer);
end;

procedure TFlashBridgeHardware.I2CInit;
begin
  FCH347.I2CInit;
end;

procedure TFlashBridgeHardware.I2CDeinit;
begin
  FCH347.I2CDeinit;
end;

function TFlashBridgeHardware.I2CReadWrite(DevAddr: byte;
  WBufferLen: integer; WBuffer: array of byte;
  RBufferLen: integer; var RBuffer: array of byte): integer;
begin
  Result := FCH347.I2CReadWrite(DevAddr, WBufferLen, WBuffer, RBufferLen, RBuffer);
end;

procedure TFlashBridgeHardware.I2CStart;
begin
  FCH347.I2CStart;
end;

procedure TFlashBridgeHardware.I2CStop;
begin
  FCH347.I2CStop;
end;

function TFlashBridgeHardware.I2CReadByte(ack: boolean): byte;
begin
  Result := FCH347.I2CReadByte(ack);
end;

function TFlashBridgeHardware.I2CWriteByte(data: byte): boolean;
begin
  Result := FCH347.I2CWriteByte(data);
end;

function TFlashBridgeHardware.MWInit(speed: integer): boolean;
begin
  Result := FCH347.MWInit(speed);
end;

procedure TFlashBridgeHardware.MWDeinit;
begin
  FCH347.MWDeinit;
end;

function TFlashBridgeHardware.MWRead(CS: byte; BufferLen: integer;
  var buffer: array of byte): integer;
begin
  Result := FCH347.MWRead(CS, BufferLen, buffer);
end;

function TFlashBridgeHardware.MWWrite(CS: byte; BitsWrite: byte;
  buffer: array of byte): integer;
begin
  Result := FCH347.MWWrite(CS, BitsWrite, buffer);
end;

function TFlashBridgeHardware.MWIsBusy: boolean;
begin
  Result := FCH347.MWIsBusy;
end;

function TFlashBridgeHardware.ReadUntilPrompt(TimeoutMs: integer): string;
begin
  Result := ReadPromptFrom(FSerial, TimeoutMs);
end;

function TFlashBridgeHardware.ReadPromptFrom(ser: TBlockSerial;
  TimeoutMs: integer): string;
var
  x, old: integer;
  buf: array[0..511] of byte;
  Elapsed: integer;
begin
  Result := '';
  Elapsed := 0;
  while Elapsed < TimeoutMs do
  begin
    x := ser.WaitingData;
    if x > 0 then
    begin
      if x > 512 then x := 512;
      x := ser.RecvBuffer(@buf[0], x);
      if x > 0 then
      begin
        old := Length(Result);
        SetLength(Result, old + x);
        Move(buf[0], Result[old + 1], x);
        if Pos(FB_PROMPT, Result) > 0 then Exit;
      end;
    end
    else
      Sleep(5);
    Elapsed := Elapsed + 5;
  end;
end;

function TFlashBridgeHardware.ProbePort(const Port: string): boolean;
var
  Probe: TBlockSerial;
  S: string;
begin
  Result := false;
  Probe := TBlockSerial.Create;
  Probe.RaiseExcept := false;
  try
    Probe.Connect(Port);
    if Probe.LastError <> 0 then Exit;
    Probe.Config(FB_BAUD, 8, 'N', SB1, false, false);
    Probe.Purge;
    Probe.SendString(FB_CMD_EXIT); // 若已唤醒则先回静默
    Sleep(150);
    Probe.Purge;
    Probe.SendString(FB_WAKE_SEQUENCE);
    S := ReadPromptFrom(Probe, 800);
    Result := Pos(FB_PROMPT, S) > 0;
  finally
    Probe.CloseSocket;
    Probe.Free;
  end;
end;

function TFlashBridgeHardware.FindV002Port: string;
var
  Reg: TRegistry;
  Names: TStringList;
  Ports: TStringList;
  i: integer;
begin
  Result := '';
  Ports := TStringList.Create;
  Reg := TRegistry.Create;
  Names := TStringList.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\HARDWARE\DEVICEMAP\SERIALCOMM') then
    begin
      Reg.GetValueNames(Names);
      for i := 0 to Names.Count - 1 do
        Ports.Add(Reg.ReadString(Names[i]));
      Reg.CloseKey;
    end;
    for i := 0 to Ports.Count - 1 do
      if ProbePort(Ports[i]) then
      begin
        Result := Ports[i];
        Exit;
      end;
  finally
    Names.Free;
    Reg.Free;
    Ports.Free;
  end;
end;

function TFlashBridgeHardware.VIOConnect(const Port: string): boolean;
var
  S: string;
begin
  Result := false;
  FVIOError := '';
  if FVIOConnected then VIODisconnect;

  FSerial.Connect(Port);
  if FSerial.LastError <> 0 then
  begin
    FVIOError := 'cannot open ' + Port;
    Exit;
  end;
  FSerial.Config(FB_BAUD, 8, 'N', SB1, false, false);
  FSerial.Purge;
  FSerial.SendString(FB_WAKE_SEQUENCE);
  S := ReadUntilPrompt(1500);
  if Pos(FB_PROMPT, S) = 0 then
  begin
    FVIOError := 'no FlashBridge response';
    FSerial.CloseSocket;
    Exit;
  end;
  FVIOConnected := true;
  Result := true;
end;

procedure TFlashBridgeHardware.VIODisconnect;
begin
  if FVIOConnected then
  begin
    FSerial.SendString(FB_CMD_EXIT);
    FSerial.CloseSocket;
    FVIOConnected := false;
  end;
end;

function TFlashBridgeHardware.VIOGetStatus(var V, Target, Duty: double): boolean;
begin
  Result := VIOGetStatusEx(V, Target, Duty, 700);
end;

function TFlashBridgeHardware.VIOGetStatusEx(var V, Target, Duty: double;
  TimeoutMs: integer): boolean;
var
  S, Err: string;
begin
  Result := false;
  FVIOError := '';
  if not FVIOConnected then Exit;
  FSerial.Purge;
  FSerial.SendString(FB_CMD_VIO);
  S := ReadUntilPrompt(TimeoutMs);
  Result := ParseVIOStatus(S, V, Target, Duty, Err);
  if not Result then FVIOError := Err;
end;

function TFlashBridgeHardware.VIOSetMillivolts(mv: integer): boolean;
var
  S, Err: string;
  V, T, D: double;
begin
  Result := false;
  FVIOError := '';
  if not FVIOConnected then Exit;
  if (mv < FB_VIO_MIN_MV) or (mv > FB_VIO_MAX_MV) then
  begin
    FVIOError := 'range 1200-3300';
    Exit;
  end;
  FSerial.Purge;
  FSerial.SendString('vio ' + IntToStr(mv) + #13);
  S := ReadUntilPrompt(700);
  Result := ParseVIOStatus(S, V, T, D, Err);
  if not Result then FVIOError := Err;
end;

function TFlashBridgeHardware.VIOSetMillivoltsHold(mv, seconds: integer): boolean;
var
  S, Err: string;
  V, T, D: double;
begin
  Result := false;
  FVIOError := '';
  if not FVIOConnected then Exit;
  if (mv < FB_VIO_MIN_MV) or (mv > FB_VIO_MAX_MV) then
  begin
    FVIOError := 'range 1200-3300';
    Exit;
  end;
  if seconds <= 0 then
  begin
    FVIOError := 'hold seconds > 0';
    Exit;
  end;
  FSerial.Purge;
  FSerial.SendString(Format('vio %d %d' + #13, [mv, seconds]));
  S := ReadUntilPrompt(700);
  Result := ParseVIOStatus(S, V, T, D, Err);
  if not Result then FVIOError := Err;
end;

function TFlashBridgeHardware.VIOWaitStable(TargetMV: integer;
  TimeoutMs: integer): boolean;
var
  V, T, D: double;
  Elapsed: integer;
  StableCount: integer;
begin
  Result := false;
  Elapsed := 0;
  StableCount := 0;
  while Elapsed < TimeoutMs do
  begin
    if VIOGetStatus(V, T, D) then
    begin
      if Abs(V * 1000 - TargetMV) < 20 then
        Inc(StableCount)
      else
        StableCount := 0;
      if StableCount >= 2 then
      begin
        Result := true;
        Exit;
      end;
    end;
    Sleep(50);
    Elapsed := Elapsed + 50;
  end;
end;

end.
