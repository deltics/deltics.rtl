

  unit Deltics.Contracts;


interface

  uses
    SysUtils,
    Deltics.Strings;


  type
    EContractViolation = class(Exception);


    Contract = class
    public
      class procedure Assigned(const aValue);
      class procedure NotASurrogate(aValue: WideChar);
      class procedure NotEmpty(aValue: AnsiString); overload;
      class procedure NotEmpty(aValue: AnsiString; var aLen: Integer); overload;
      class procedure NotEmpty(aValue: UnicodeString); overload;
      class procedure NotEmpty(aValue: UnicodeString; var aLen: Integer); overload;
      class procedure Minimum(aValue, aMinimum: Integer);
      class procedure NotNull(aValue: AnsiChar); overload;
      class procedure NotNull(aValue: WideChar); overload;
      class procedure NotSupported;
      class procedure ValidIndex(const aString: AnsiString; aIndex: Integer); overload;
      class procedure ValidIndex(const aString: UnicodeString; aIndex: Integer); overload;
    end;



implementation

{ Contract --------------------------------------------------------------------------------------- }

  class procedure Contract.Assigned(const aValue);
  var
    p: Pointer absolute aValue;
  begin
    if NOT System.Assigned(p) then
      raise EContractViolation.Create('Invalid NIL argument');
  end;


  class procedure Contract.NotASurrogate(aValue: WideChar);
  begin
    if Wide.IsSurrogate(aValue) then
      raise EContractViolation.Create('Argument cannot be a hi/lo surrogate');
  end;


  class procedure Contract.NotEmpty(aValue: AnsiString);
  begin
    if aValue = '' then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.NotEmpty(    aValue: AnsiString;
                                    var aLen: Integer);
  begin
    aLen := Length(aValue);
    if aLen = 0 then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.NotEmpty(aValue: UnicodeString);
  begin
    if aValue = '' then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.NotEmpty(  aValue: UnicodeString;
                                    var aLen: Integer);
  begin
    aLen := Length(aValue);
    if aLen = 0 then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.Minimum(aValue, aMinimum: Integer);
  begin
    if aValue < aMinimum then
      raise EContractViolation.CreateFmt('Argument value (%d) cannot be less than %d', [aValue, aMinimum]);
  end;


  class procedure Contract.NotNull(aValue: AnsiChar);
  begin
    if aValue = #0 then
      raise EContractViolation.Create('Argument cannot be null (#0)');
  end;


  class procedure Contract.NotNull(aValue: WideChar);
  begin
    if aValue = #0 then
      raise EContractViolation.Create('Argument cannot be null (#0)');
  end;


  class procedure Contract.NotSupported;
  begin
    raise EContractViolation.Create('This is not supported');
  end;


  class procedure Contract.ValidIndex(const aString: AnsiString;
                                            aIndex: Integer);
  begin
    if (aIndex < 1) or (aIndex > Length(aString)) then
      raise EContractViolation.CreateFmt('Argument %d is not a valid index into string', [aIndex]);
  end;


  class procedure Contract.ValidIndex(const aString: UnicodeString;
                                            aIndex: Integer);
  begin
    if (aIndex < 1) or (aIndex > Length(aString)) then
      raise EContractViolation.CreateFmt('Argument %d is not a valid index into string', [aIndex]);
  end;


end.
