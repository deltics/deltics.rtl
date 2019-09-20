
  unit Deltics.CommandLine.Switches;

interface

  uses
    Deltics.Classes,
    Deltics.Strings,
    Deltics.CommandLine.Interfaces;


  type
    TCommandLineSwitch = class(TComInterfacedObject, ICommandLineSwitch)
    private
      fAlts: IStringList;
      fIsEnabled: Boolean;
      fName: String;
      fValues: IStringList;
    private
      constructor Detected(const aName: String; const aValues: IStringList); overload;
      constructor Create(const aName: String; const aValues: IStringList; const aEnabled: Boolean); overload;
    public
      constructor Create(const aName: String; const aValue: String); overload;
      constructor Create(const aName: String; const aValues: IStringList); overload;
    private
      function get_Alts: IStringList;
      function get_Name: String;
      function get_Value: String;
      function get_Values: IStringList;
    public
      function IsEnabled: Boolean; overload;
      function IsEnabled(var aValue: String): Boolean; overload;
      function IsEnabled(var aValues: TStringArray): Boolean; overload;
      function ValueOrDefault(const aDefault: String): String; overload;
      function ValueOrDefault(const aDefaults: TStringArray): IStringList; overload;
      function ValueOrDefault(const aDefaults: IStringList): IStringList; overload;
      property Name: String read get_Name;
      property Values: IStringList read get_Values;
    end;


    TCommandLineSwitches = class(TInterfaceList, ICommandLineSwitches,
                                                 ICommandLineSwitchesParser)
    private
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): ICommandLineSwitch;
      function Contains(const aString: String; var aSwitch: ICommandLineSwitch): Boolean; overload;
      function Contains(const aSwitch: String; var aValue: String): Boolean; overload;
      function Contains(const aSwitch: String; var aValues: IStringList): Boolean; overload;
    private
      procedure AddSwitch(const aSwitch: String; const aValues: IStringList);
    end;


implementation


  function CommandLineArgsAsStringList: IStringList;
  var
    i: Integer;
  begin
    result := TComInterfacedStringList.Create;

    for i := 1 to Pred(ParamCount) do
      result.Add(ParamStr(i));
  end;




{ TCommandLineValueSwitch }

  constructor TCommandLineSwitch.Create(const aName: String;
                                        const aValues: IStringList;
                                        const aEnabled: Boolean);
  begin
    inherited Create;

    fName       := aName;
    fValues     := aValues;
    fIsEnabled  := aEnabled;
  end;


  constructor TCommandLineSwitch.Detected(const aName: String;
                                          const aValues: IStringList);
  begin
    Create(aName, aValues.Clone, TRUE);
  end;


  constructor TCommandLineSwitch.Create(const aName, aValue: String);
  var
    values: IStringList;
  begin
    values := TComInterfacedStringList.Create;
    values.Add(aValue);

    Create(aName, values, FALSE);
  end;


  constructor TCommandLineSwitch.Create(const aName: String;
                                        const aValues: IStringList);
  begin
    Create(aName, aValues.Clone, FALSE);
  end;


  function TCommandLineSwitch.get_Alts: IStringList;
  begin
    result := fAlts;
  end;


  function TCommandLineSwitch.get_Name: String;
  begin
    result := fName;
  end;


  function TCommandLineSwitch.get_Value: String;
  begin
    if fValues.Count > 0 then
      result := fValues[0]
    else
      result := '';
  end;


  function TCommandLineSwitch.get_Values: IStringList;
  begin
    result := TComInterfacedStringList.Create;
    result.Add(fValues);
  end;


  function TCommandLineSwitch.IsEnabled: Boolean;
  begin
    result := fIsEnabled;
  end;


  function TCommandLineSwitch.IsEnabled(var aValue: String): Boolean;
  begin
    result := fIsEnabled;

    if result then
      aValue := get_Value;
  end;


  function TCommandLineSwitch.IsEnabled(var aValues: TStringArray): Boolean;
  begin
    result := fIsEnabled;

    if result then
      aValues := fValues.AsArray;
  end;


  function TCommandLineSwitch.ValueOrDefault(const aDefault: String): String;
  begin
    if IsEnabled then
      result := get_Value
    else
      result := aDefault;
  end;


  function TCommandLineSwitch.ValueOrDefault(const aDefaults: TStringArray): IStringList;
  begin
    if NOT IsEnabled then
    begin
      result := TComInterfacedStringList.Create;
      result.Add(aDefaults);
    end
    else
      result := get_Values;
  end;


  function TCommandLineSwitch.ValueOrDefault(const aDefaults: IStringList): IStringList;
  begin
    if NOT IsEnabled then
    begin
      result := TComInterfacedStringList.Create;
      result.Add(aDefaults);
    end
    else
      result := get_Values;
  end;




{ TCommandLineSwitchList }

  procedure TCommandLineSwitches.AddSwitch(const aSwitch: String; const aValues: IStringList);
  var
    switch: ICommandLineSwitch;
    values: IStringList;
  begin
    values := TComInterfacedStringList.Create;
    values.Add(aValues);

    switch := TCommandLineSwitch.Create(aSwitch, values, TRUE);

    inherited Add(switch);
  end;


  function TCommandLineSwitches.Contains(const aString: String;
                                         var   aSwitch: ICommandLineSwitch): Boolean;
  var
    i, j: Integer;
    alts: IStringList;
  begin
    for i := 0 to Pred(get_Count) do
    begin
      aSwitch := get_Item(i);
      result  := aSwitch.get_Name.EqualsText(aString);
      if result then
        EXIT;

      alts := aSwitch.get_Alts;
      if NOT Assigned(alts) then
        CONTINUE;

      for j := 0 to Pred(alts.Count) do
      begin
        result  := alts[j].EqualsText(aString);
        if result then
          EXIT;
      end;
    end;

    aSwitch := NIL;
    result  := FALSE;
  end;


  function TCommandLineSwitches.Contains(const aSwitch: String;
                                         var   aValue: String): Boolean;
  var
    switch: ICommandLineSwitch;
  begin
    result := Contains(aSwitch, switch);
    if result then
      aValue := switch.Value;
  end;


  function TCommandLineSwitches.Contains(const aSwitch: String;
                                         var aValues: IStringList): Boolean;
  var
    switch: ICommandLineSwitch;
  begin
    result := Contains(aSwitch, switch);
    if result then
      aValues := switch.Values.Clone;
  end;


  function TCommandLineSwitches.get_Count: Integer;
  begin
    result := inherited Count;
  end;


  function TCommandLineSwitches.get_Item(const aIndex: Integer): ICommandLineSwitch;
  begin
    result := (inherited Items[aIndex]) as ICommandLineSwitch;
  end;







end.
