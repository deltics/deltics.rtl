

  unit Deltics.Strings.Parsers.ANSI;


interface

  uses
    Deltics.Strings.Types;


  type
    ANSIParser = class
    public
      class function AsBoolean(aBuffer: PANSIChar; aLen: Integer): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsBoolean(aBuffer: PANSIChar; aLen: Integer; aDefault: Boolean): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsBoolean(const aString: UnicodeString): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsBoolean(const aString: UnicodeString; aDefault: Boolean): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsInteger(aBuffer: PANSIChar; aLen: Integer): Integer; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsInteger(aBuffer: PANSIChar; aLen: Integer; aDefault: Integer): Integer; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsInteger(const aString: UnicodeString): Integer; overload; {$ifdef InlineMethods} inline; {$endif}
      class function AsInteger(const aString: UnicodeString; aDefault: Integer): Integer; overload; {$ifdef InlineMethods} inline; {$endif}

      class function IsBoolean(aBuffer: PANSIChar; aLen: Integer): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsBoolean(aBuffer: PANSIChar; aLen: Integer; var aValue: Boolean): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsBoolean(const aString: UnicodeString): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsBoolean(const aString: UnicodeString; var aValue: Boolean): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsInteger(aBuffer: PANSIChar; aLen: Integer): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsInteger(aBuffer: PANSIChar; aLen: Integer; var aValue: Integer): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsInteger(const aString: UnicodeString): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
      class function IsInteger(const aString: UnicodeString; var aValue: Integer): Boolean; overload; {$ifdef InlineMethods} inline; {$endif}
    end;
    ANSIParserClass = class of ANSIParser;




implementation

  uses
    SysUtils,
    Deltics.Strings,
    Deltics.Strings.Parsers.ANSI.AsBoolean,
    Deltics.Strings.Parsers.ANSI.AsInteger;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsInteger(aBuffer: PANSIChar;
                                      aLen: Integer): Integer;
  begin
    if NOT ParseInteger(aBuffer, aLen, result) then
      raise EConvertError.CreateFmt('''%s'' is not a valid integer expression', [ANSI.FromBuffer(aBuffer, aLen)]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsInteger(aBuffer: PANSIChar;
                                      aLen: Integer;
                                      aDefault: Integer): Integer;
  begin
    if NOT ParseInteger(aBuffer, aLen, result) then
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsInteger(const aString: UnicodeString): Integer;
  begin
    if NOT ParseInteger(PANSIChar(aString), Length(aString), result) then
      raise EConvertError.CreateFmt('''%s'' is not a valid integer expression', [aString]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsInteger(const aString: UnicodeString;
                                            aDefault: Integer): Integer;
  begin
    if NOT ParseInteger(PANSIChar(aString), Length(aString), result) then
      result := aDefault;
  end;







  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsBoolean(aBuffer: PANSIChar;
                                      aLen: Integer): Boolean;
  begin
    if NOT ParseBoolean(aBuffer, aLen, result) then
      raise EConvertError.CreateFmt('''%s'' is not a valid boolean expression', [ANSI.FromBuffer(aBuffer, aLen)]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsBoolean(aBuffer: PANSIChar;
                                      aLen: Integer;
                                      aDefault: Boolean): Boolean;
  begin
    if NOT ParseBoolean(aBuffer, aLen, result) then
      result := aDefault;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsBoolean(const aString: UnicodeString): Boolean;
  begin
    if NOT ParseBoolean(PANSIChar(aString), Length(aString), result) then
      raise EConvertError.CreateFmt('''%s'' is not a valid boolean expression', [aString]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.AsBoolean(const aString: UnicodeString;
                                            aDefault: Boolean): Boolean;
  begin
    if NOT ParseBoolean(PANSIChar(aString), Length(aString), result) then
      result := aDefault;
  end;








  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsBoolean(aBuffer: PANSIChar;
                                      aLen: Integer): Boolean;
  begin
    result := CheckBoolean(aBuffer, aLen);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsBoolean(    aBuffer: PANSIChar;
                                          aLen: Integer;
                                      var aValue: Boolean): Boolean;
  begin
    result := ParseBoolean(aBuffer, aLen, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsBoolean(const aString: UnicodeString): Boolean;
  begin
    result := CheckBoolean(PANSIChar(aString), Length(aString));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsBoolean(const aString: UnicodeString;
                                      var   aValue: Boolean): Boolean;
  begin
    result := ParseBoolean(PANSIChar(aString), Length(aString), aValue);
  end;








  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsInteger(aBuffer: PANSIChar; aLen: Integer): Boolean;
  begin
    result := CheckInteger(aBuffer, aLen);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsInteger(    aBuffer: PANSIChar;
                                          aLen: Integer;
                                      var aValue: Integer): Boolean;
  begin
    result := ParseInteger(aBuffer, aLen, aValue);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsInteger(const aString: UnicodeString): Boolean;
  begin
    result := CheckInteger(PANSIChar(aString), Length(aString));
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function ANSIParser.IsInteger(const aString: UnicodeString;
                                      var   aValue: Integer): Boolean;
  begin
    result := ParseInteger(PANSIChar(aString), Length(aString), aValue);
  end;





end.
