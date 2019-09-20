

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
      class procedure NotASurrogate(aValue: WIDEChar);
      class procedure NotEmpty(aValue: ANSIString; const aParamName: String = ''); overload;
      class procedure NotEmpty(aValue: ANSIString; var aLen: Integer); overload;
      class procedure NotEmpty(aValue: UnicodeString; const aParamName: String = ''); overload;
      class procedure NotEmpty(aValue: UnicodeString; var aLen: Integer); overload;
      class procedure Minimum(aValue, aFloor: Integer; const aParamName: String = '');
      class procedure NotNull(aValue: ANSIChar); overload;
      class procedure NotNull(aValue: WIDEChar); overload;
      class procedure NotSupported;
      class procedure ValidIndex(const aString: ANSIString; aIndex: Integer; const aMessage: String = ''); overload;
      class procedure ValidIndex(const aString: UnicodeString; aIndex: Integer; const aMessage: String = ''); overload;
    end;



implementation

  type
    EArgumentOutOfRangeException = class(EContractViolation);



{ Contract }

  class procedure Contract.Assigned(const aValue);
  var
    p: Pointer absolute aValue;
  begin
    if NOT System.Assigned(p) then
      raise EContractViolation.Create('Invalid NIL argument');
  end;


  class procedure Contract.NotASurrogate(aValue: WIDEChar);
  begin
    if WIDE.IsSurrogate(aValue) then
      raise EContractViolation.Create('Argument cannot be a hi/lo surrogate');
  end;


  class procedure Contract.NotEmpty(aValue: ANSIString; const aParamName: String);
  begin
    if aValue = '' then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.NotEmpty(aValue: ANSIString; var aLen: Integer);
  begin
    aLen := Length(aValue);
    if aLen = 0 then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.NotEmpty(aValue: UnicodeString; const aParamName: String);
  begin
    if aValue = '' then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.NotEmpty(aValue: UnicodeString; var aLen: Integer);
  begin
    aLen := Length(aValue);
    if aLen = 0 then
      raise EContractViolation.Create('Argument cannot be an empty string');
  end;


  class procedure Contract.Minimum(aValue, aFloor: Integer; const aParamName: String);
  begin
    if aValue < aFloor then
      raise EContractViolation.CreateFmt('Invalid argument (%d).  %d is the minimum allowed', [aValue, aFloor]);
  end;


  class procedure Contract.NotNull(aValue: ANSIChar);
  begin
    if aValue = #0 then
      raise EContractViolation.Create('Invalid NULL char argument');
  end;


  class procedure Contract.NotNull(aValue: WIDEChar);
  begin
    if aValue = #0 then
      raise EContractViolation.Create('Invalid NULL char argument');
  end;


  class procedure Contract.NotSupported;
  begin
    raise EContractViolation.Create('This is not supported');
  end;


  class procedure Contract.ValidIndex(const aString: ANSIString;
                                            aIndex: Integer;
                                      const aMessage: String);
  begin
    if (aIndex < 1) or (aIndex > Length(aString)) then
      raise EContractViolation.Create(STR.Coalesce(aMessage, 'Invalid string index'));
  end;


  class procedure Contract.ValidIndex(const aString: UnicodeString;
                                            aIndex: Integer;
                                      const aMessage: String);
  begin
    if (aIndex < 1) or (aIndex > Length(aString)) then
      raise EContractViolation.Create(STR.Coalesce(aMessage, 'Invalid string index'));
  end;


end.
