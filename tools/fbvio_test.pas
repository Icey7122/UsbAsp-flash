program fbvio_test;

{$mode objfpc}{$H+}

uses
  SysUtils, fbvio;

var
  V, T, D: double;
  Err: string;
  ok: boolean;
  fails: integer;

procedure Check(cond: boolean; const msg: string);
begin
  if cond then Writeln('PASS: ', msg)
  else begin
    Inc(fails);
    Writeln('FAIL: ', msg);
  end;
end;

begin
  fails := 0;

  ok := ParseVIOStatus('VIO: 2.501 V, target: 2.500 V, duty: 61.7%', V, T, D, Err);
  Check(ok, 'normal line parses');
  Check(Abs(V - 2.501) < 0.0001, 'V = 2.501');
  Check(Abs(T - 2.500) < 0.0001, 'target = 2.500');
  Check(Abs(D - 61.7) < 0.0001, 'duty = 61.7');

  ok := ParseVIOStatus('VIO: 2.501 V, duty: 61.7%', V, T, D, Err);
  Check(ok, 'no-target line parses');
  Check(T = -1, 'target defaults to -1 when absent');

  ok := ParseVIOStatus('Target: 2.500 V' + #13#10 + 'VIO: 2.502 V, target: 2.500 V, duty: 61.7%', V, T, D, Err);
  Check(ok, 'set-response (two lines) parses');
  Check(Abs(V - 2.502) < 0.0001, 'V from set response = 2.502');

  ok := ParseVIOStatus('ERR: locked', V, T, D, Err);
  Check(not ok, 'ERR: locked rejected');
  Check(Err = 'locked', 'error message captured');

  ok := ParseVIOStatus('garbage', V, T, D, Err);
  Check(not ok, 'garbage rejected');

  if fails = 0 then Writeln('ALL PASS')
  else Writeln(fails, ' FAILURES');
  Halt(fails);
end.
