unit fbvio;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

const
  FB_BAUD = 115200;
  FB_VIO_MIN_MV = 1200;
  FB_VIO_MAX_MV = 3300;
  FB_WAKE_SEQUENCE = '+++flashbridge' + #13;
  FB_CMD_VIO = 'vio' + #13;
  FB_CMD_EXIT = 'exit' + #13;
  FB_PROMPT = 'flashbridge>';

function ParseVIOStatus(const S: string; var V, Target, Duty: double;
  var ErrMsg: string): boolean;

implementation

function ExtractNumber(const S: string; const Marker: string;
  var Value: double): boolean;
var
  P: integer;
  NumStr: string;
  fs: TFormatSettings;
begin
  Result := false;
  P := Pos(Marker, S);
  if P = 0 then Exit;
  Inc(P, Length(Marker));
  while (P <= Length(S)) and (S[P] = ' ') do
    Inc(P);
  NumStr := '';
  while (P <= Length(S)) and (S[P] in ['0'..'9', '.', '-']) do
  begin
    NumStr := NumStr + S[P];
    Inc(P);
  end;
  fs := DefaultFormatSettings;
  fs.DecimalSeparator := '.';
  Result := TryStrToFloat(NumStr, Value, fs);
end;

function ParseVIOStatus(const S: string; var V, Target, Duty: double;
  var ErrMsg: string): boolean;
var
  P: integer;
begin
  Result := false;
  ErrMsg := '';

  P := Pos('ERR:', S);
  if P > 0 then
  begin
    ErrMsg := Trim(Copy(S, P + 4, Length(S)));
    Exit;
  end;

  if not ExtractNumber(S, 'VIO:', V) then Exit;
  if not ExtractNumber(S, 'duty:', Duty) then Exit;

  Target := -1;
  ExtractNumber(S, 'target:', Target); // 可选：失败则保持 -1

  Result := true;
end;

end.
