unit flashbridgehw;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, basehw, Synaser, ch347hw, fbvio;

type
  TFlashBridgeHardware = class(TBaseHardware)
  private
    FCH347: TCH347Hardware;
    FSerial: TBlockSerial;
    FVIOConnected: boolean;
    FVIOError: string;
    function ReadUntilPrompt(TimeoutMs: integer): string;
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
    function VIOSetMillivolts(mv: integer): boolean;
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
var
  S: string;
  Elapsed: integer;
begin
  Result := '';
  Elapsed := 0;
  while Elapsed < TimeoutMs do
  begin
    if FSerial.CanRead(50) then
    begin
      S := FSerial.RecvString(100);
      Result := Result + S;
      if Pos(FB_PROMPT, Result) > 0 then Exit;
    end
    else
      Sleep(20);
    Elapsed := Elapsed + 70;
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
var
  S, Err: string;
begin
  Result := false;
  FVIOError := '';
  if not FVIOConnected then Exit;
  FSerial.Purge;
  FSerial.SendString(FB_CMD_VIO);
  S := ReadUntilPrompt(700);
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

end.
