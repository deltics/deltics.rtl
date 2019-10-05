

  unit Deltics.Strings.Parsers.ANSI.AsBoolean;

{$i deltics.inc}

interface

  function CheckBoolean(aBuffer: PANSIChar; aLen: Integer): Boolean;
  function ParseBoolean(aBuffer: PANSIChar; aLen: Integer; var aValue: Boolean): Boolean;

implementation

  uses
    Deltics.Strings;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function Init(var aBuffer: PANSIChar;
                var aLen: Integer): Boolean; {$ifdef DELPHI2006__} inline; {$endif}
  begin
    while (aLen > 0) and (aBuffer[0] = ' ') do
    begin
      Inc(aBuffer);
      Dec(aLen);
    end;

    while (aLen > 0) and (aBuffer[aLen - 1] = ' ') do
      Dec(aLen);

    case aLen of

      0 : result := FALSE;

      1 : case aBuffer[0] of
            '0', 'n', 'N',
            '1', 'y', 'Y': result := TRUE;
          else
            result := FALSE;
          end;

    else
      case aBuffer[0] of

        '-'           : result := aBuffer[1] = '1';
        'o', 'O'      : result := aLen = 2;
        'n', 'N'      : result := aLen = 2;
        'f', 'F'      : result := aLen = 5;
        'y', 'Y'      : result := aLen = 3;
        't', 'T'      : result := aLen = 4;

      else
        result := FALSE;
      end;
    end;
  end;









  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function CheckBoolean(aBuffer: PANSIChar;
                        aLen: Integer): Boolean;
  begin
    result := Init(aBuffer, aLen);
    if NOT result then
      EXIT;

    case aLen of

      1 : case aBuffer[0] of
            '0', 'n', 'N',
            '1', 'y', 'Y': { NO-OP };
          else
            result := FALSE;
          end;

      2 : case aBuffer[0] of
            '-'       : result := aBuffer[1] = '1';
            'n', 'N'  : result := ANSI.SameText(ANSI(aBuffer, aLen), 'no');
            'o', 'O'  : result := ANSI.SameText(ANSI(aBuffer, aLen), 'ok');
          else
            result := FALSE;
          end;

      3 : result := ANSI.SameText(ANSI(aBuffer, aLen), 'yes');

      4 : result := ANSI.SameText(ANSI(aBuffer, aLen), 'true');

      5 : result := ANSI.SameText(ANSI(aBuffer, aLen), 'false');

    else
      result := FALSE;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function ParseBoolean(    aBuffer: PANSIChar;
                            aLen: Integer;
                        var aValue: Boolean): Boolean;
  begin
    result := Init(aBuffer, aLen);
    if NOT result then
      EXIT;

    aValue := FALSE;
    result := TRUE;

    case aLen of

      1 : case aBuffer[0] of
            '0', 'n', 'N': aValue := FALSE;
            '1', 'y', 'Y': aValue := TRUE;
          else
            result := FALSE;
          end;

      2 : case aBuffer[0] of
            '-'       : begin
                          aValue := aBuffer[1] = '1';
                          result := aValue;
                        end;

            'n', 'N'  : result := ANSI.SameText(ANSI(aBuffer, aLen), 'no');

            'o', 'O'  : begin
                          aValue := ANSI.SameText(ANSI(aBuffer, aLen), 'ok');
                          result := aValue;
                        end;
          else
            result := FALSE;
          end;

      3 : if ANSI.SameText(ANSI(aBuffer, aLen), 'yes') then
            aValue := TRUE
          else
            result := FALSE;

      4 : if ANSI.SameText(ANSI(aBuffer, aLen), 'true') then
            aValue := TRUE
          else
            result := FALSE;

      5 : result := ANSI.SameText(ANSI(aBuffer, aLen), 'false');

    else
      result := FALSE;
    end;
  end;







end.