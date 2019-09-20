

  unit Deltics.GUIDs;

{$i deltics.rtl.inc}

interface

  const
    NullGUID: TGUID = '{00000000-0000-0000-0000-000000000000}';

  type
    TGUIDFormat = (
                   gfDefault,
                   gfNoBraces,
                   gfNoHyphens,
                   gfDigitsOnly
                  );

    GUID = class
      class function ToString(const aGUID: TGUID; const aFormat: TGUIDFormat = gfDefault): String; reintroduce;
      class function FromString(const aString: String): TGUID; overload;
      class function FromString(const aString: String; var aGUID: TGUID): Boolean; overload;

      class function IsNull(const aValue: TGUID): Boolean;
      class function New: TGUID;
    end;

    GUIDs = class
      class function AreEqual(const A, B: TGUID): Boolean; {$ifdef InlineMethodsSupported} inline; {$endif}
    end;


  {$ifdef TypeHelpersSupported}

    GUIDHelper = record helper for TGUID
    public
      function Equals(const aGUID: TGUID): Boolean; inline;
    end;

  {$endif}



implementation

  uses
    SysUtils;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GUID.ToString(const aGUID: TGUID;
                               const aFormat: TGUIDFormat): String;
  begin
    result := SysUtils.GUIDToString(aGUID);

    case aFormat of
      gfDefault     : EXIT;

      gfNoBraces    : result := Copy(result, 2, Length(result) - 2);

      gfNoHyphens   : result := StringReplace(result, '-', '', [rfReplaceAll]);

      gfDigitsOnly  : begin
                        result := Copy(result, 2, Length(result) - 2);
                        result := StringReplace(result, '-', '', [rfReplaceAll]);
                      end;
    end;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GUID.FromString(const aString: String): TGUID;
  begin
    if NOT FromString(aString, result) then
      raise EConvertError.CreateFmt('''%s'' is not a valid GUID', [aString]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GUID.FromString(const aString: String;
                                 var   aGUID: TGUID): Boolean;
  var
    s: String;
    src: PChar absolute s;

    function HexByte(MSN: Integer): Byte;
    var
      LSN: Integer;
    begin
      result  := 0;
      LSN     := MSN + 1;

      case src[MSN] of
        '0'..'9':  result := Byte(src[MSN]) - Byte('0');
        'a'..'f':  result := Byte(src[MSN]) - Byte('a') + 10;
        'A'..'F':  result := Byte(src[MSN]) - Byte('A') + 10;
      end;

      case src[LSN] of
        '0'..'9':  result := (Byte(result) shl 4) or (Byte(src[LSN]) - Byte('0'));
        'a'..'f':  result := (Byte(result) shl 4) or ((Byte(src[LSN]) - Byte('a')) + 10);
        'A'..'F':  result := (Byte(result) shl 4) or ((Byte(src[LSN]) - Byte('A')) + 10);
      end;
    end;

  var
    dest: array[0..15] of Byte absolute aGUID;
  begin
    s       := '';
    result  := FALSE;

    case Length(aString) of
      32  : s := Copy(aString, 1, 8)  + '-'
               + Copy(aString, 10, 4) + '-'
               + Copy(aString, 14, 4) + '-'
               + Copy(aString, 18, 4) + '-'
               + Copy(aString, 22, 12);

      36  : s := aString;

      38  : if (aString[1] = '{') and (aString[38] = '}') then
              s := Copy(aString, 2, 36);
    end;

    if (s = '') then
      EXIT;

    if (s[9] <> '-') or (s[14] <> '-') or (s[19] <> '-') or (s[24] <> '-') then
      EXIT;

    //            1  1 1  1 2  2 2 2 3 3 3
    // 0 2 4 6 -9 1 -4 6 -9 1 -4 6 8 0 2 4
    // ..XX..XX ..XX ..XX ..XX ..XX..XX..XX

    dest[0] := HexByte(6);
    dest[1] := HexByte(4);
    dest[2] := HexByte(2);
    dest[3] := HexByte(0);

    dest[4] := HexByte(11);
    dest[5] := HexByte(9);

    dest[6] := HexByte(16);
    dest[7] := HexByte(14);

    dest[8] := HexByte(19);
    dest[9] := HexByte(21);

    dest[10]  := HexByte(24);
    dest[11]  := HexByte(26);
    dest[12]  := HexByte(28);
    dest[13]  := HexByte(30);
    dest[14]  := HexByte(32);
    dest[15]  := HexByte(34);

    result := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GUID.IsNull(const aValue: TGUID): Boolean;
  begin
    result := CompareMem(@aValue, @NullGUID, sizeof(TGUID));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GUID.New: TGUID;
  begin
    CreateGUID(result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function GUIDs.AreEqual(const A, B: TGUID): Boolean;
  begin
    result := CompareMem(@A, @B, sizeof(TGUID));
  end;


{$ifdef TypeHelpersSupported}

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function GUIDHelper.Equals(const aGUID: TGUID): Boolean;
  begin
    result := CompareMem(@self, @aGUID, sizeof(TGUID));
  end;

{$endif}


end.
