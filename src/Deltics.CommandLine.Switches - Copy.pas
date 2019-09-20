
  unit Deltics.CommandLine.Switches;

interface

  uses
    Deltics.Classes,
    Deltics.Strings;


  type
    ICommandLineSwitch = interface
    ['{C5DE71C0-567A-4A2B-BE30-85EBBD3D22F3}']
      function get_Name: String;
      function get_ShortName: String;
      function get_Value: String;
      function get_Values: IStringList;
      function IsEnabled: Boolean; overload;
      function IsEnabled(var aValue: String): Boolean; overload;
      function IsEnabled(var aValues: TStringArray): Boolean; overload;
      function ValueOrDefault(const aDefault: String): String; overload;
      function ValueOrDefault(const aDefaults: TStringArray): IStringList; overload;
      function ValueOrDefault(const aDefaults: IStringList): IStringList; overload;
      property Value: String read get_Value;
      property Values: IStringList read get_Values;
    end;


    TCommandLineSwitchList = class(TInterfacedObjectList)
    private
      function get_Items(const aIndex: Integer): ICommandLineSwitch;
    public
      procedure Parse; overload;
      procedure Parse(const aArgs: IStringList); overload;
      function Register(const aName: String; const aShortName: String = ''; const aDefaultValue: String = ''; const aValueDelimiter: Char = #0): ICommandLineSwitch;
      property Items[const aIndex: Integer]: ICommandLineSwitch read get_Items;
    end;


  function CommandLineSwitch(const aSwitch: String): ICommandLineSwitch; overload;
  function CommandLineSwitch(const aSwitch: String; const aDefaultValue: String): ICommandLineSwitch; overload;
  function CommandLineSwitch(const aSwitch: String; const aValueDelimiter: Char): ICommandLineSwitch; overload;
  function CommandLineSwitch(const aSwitch: String; const aDefaultValue: String; const aValueDelimiter: Char): ICommandLineSwitch; overload;

  function CommandLineSwitch(const aSwitches: TStringArray): ICommandLineSwitch; overload;
  function CommandLineSwitch(const aSwitches: TStringArray; const aDefaultValue: String): ICommandLineSwitch; overload;
  function CommandLineSwitch(const aSwitches: TStringArray; const aValueDelimiter: Char): ICommandLineSwitch; overload;
  function CommandLineSwitch(const aSwitches: TStringArray; const aDefaultValue: String; const aValueDelimiter: Char): ICommandLineSwitch; overload;


implementation


  function CommandLineArgsAsStringList: IStringList;
  var
    i: Integer;
  begin
    result := TComInterfacedStringList.Create;

    for i := 1 to Pred(ParamCount) do
      result.Add(ParamStr(i));
  end;


  type
    TCommandLineSwitch = class(TComInterfacedObject, ICommandLineSwitch)
    private
      fIsEnabled: Boolean;
      fName: String;
      fShortName: String;
      fValue: String;
      fValueDelimiter: Char;
    public
      constructor Create(const aName: String; const aShortName: String; const aDefaultValue: String; const aValueDelimiter: Char; const aEnabled: Boolean = FALSE);
    private
      function get_Name: String;
      function get_ShortName: String;
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
      property ShortName: String read get_ShortName;
      property ValueDelimiter: Char read fValueDelimiter;
      property Value: String read get_Value;
      property Values: IStringList read get_Values;
    end;



{ TCommandLineValueSwitch }

  constructor TCommandLineSwitch.Create(const aName: String;
                                        const aShortName: String;
                                        const aDefaultValue: String;
                                        const aValueDelimiter: Char;
                                        const aEnabled: Boolean);
  begin
    inherited Create;

    fIsEnabled      := aEnabled;
    fName           := aName;
    fShortName      := aShortName;
    fValue          := aDefaultValue;
    fValueDelimiter := aValueDelimiter;
  end;


  function TCommandLineSwitch.get_Name: String;
  begin
    result := fName;
  end;


  function TCommandLineSwitch.get_ShortName: String;
  begin
    result := fShortName;
  end;


  function TCommandLineSwitch.get_Value: String;
  begin
    result := fValue;
  end;


  function TCommandLineSwitch.get_Values: IStringList;
  var
    values: TStringArray;
  begin
    result := TComInterfacedStringList.Create;

    if (fValueDelimiter <> #0) then
    begin
      STR.Split(fValue, fValueDelimiter, values);
      result.Add(values);
    end
    else
      result.Add(Value);
  end;


  function TCommandLineSwitch.IsEnabled: Boolean;
  begin
    result := fIsEnabled;
  end;


  function TCommandLineSwitch.IsEnabled(var aValue: String): Boolean;
  begin
    result := fIsEnabled;

    if result then
      aValue := fValue;
  end;


  function TCommandLineSwitch.IsEnabled(var aValues: TStringArray): Boolean;
  begin
    result := fIsEnabled;

    if result then
      aValues := Values.AsArray;
  end;


  function TCommandLineSwitch.ValueOrDefault(const aDefault: String): String;
  begin
    if IsEnabled then
      result := Value
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
      result := Values;
  end;


  function TCommandLineSwitch.ValueOrDefault(const aDefaults: IStringList): IStringList;
  begin
    if NOT IsEnabled then
    begin
      result := TComInterfacedStringList.Create;
      result.Add(aDefaults);
    end
    else
      result := Values;
  end;




{ TCommandLineSwitchList }

  function TCommandLineSwitchList.get_Items(const aIndex: Integer): ICommandLineSwitch;
  begin
    result := (inherited Items[aIndex]) as ICommandLineSwitch;
  end;



  procedure TCommandLineSwitchList.Parse;
  begin
    Parse(CommandLineArgsAsStringList);
  end;


  procedure TCommandLineSwitchList.Parse(const aArgs: IStringList);

    function Parse(const aSwitch: TCommandLineSwitch;
                   const aIndex: Integer): Boolean;
    var
      arg: String;
    begin
      arg := aArgs[aIndex];

      result := STR.ConsumeLeft(arg, aSwitch.Name)
              or ((aSwitch.ShortName <> '') and STR.ConsumeLeft(arg, aSwitch.ShortName));

      if result then
      begin
        aSwitch.fIsEnabled := result;

        if (arg <> '') then
        begin
          if ANSIChar(arg[1]) in [':', '='] then
            arg := STR.LTrim(arg, 1);

          aSwitch.fValue := arg;
        end
        else if (aIndex < Pred(aArgs.Count)) then
        begin
          aSwitch.fValue := aArgs[aIndex + 1];
          aArgs.Delete(aIndex + 1);
        end;

        aArgs.Delete(aIndex);
      end;
    end;

  var
    i, j: Integer;
    switch: TCommandLineSwitch;
  begin
    for i := Pred(aArgs.Count) downto 0 do
    begin
      for j := 0 to Pred(Count) do
      begin
        switch := TCommandLineSwitch(Items[j]);

        if (ANSI(switch.Name[1]) in ['-', '/']) and Parse(switch, i) then
          BREAK;
      end;
    end;
  end;


  function TCommandLineSwitchList.Register(const aName: String;
                                           const aShortName: String;
                                           const aDefaultValue: String;
                                           const aValueDelimiter: Char): ICommandLineSwitch;
  var
    switch: TCommandLineSwitch;
  begin
    switch := TCommandLineSwitch.Create(aName, aShortName, aDefaultValue, aValueDelimiter);
    Add(switch);

    result := switch;
  end;


  function CommandLineSwitch(const aSwitch: String): ICommandLineSwitch;
  begin
    result := CommandLineSwitch(aSwitch, '', #0);
  end;


  function CommandLineSwitch(const aSwitch: String;
                             const aDefaultValue: String): ICommandLineSwitch;
  begin
    result := CommandLineSwitch(aSwitch, aDefaultValue, #0);
  end;


  function CommandLineSwitch(const aSwitch: String;
                             const aValueDelimiter: Char): ICommandLineSwitch;
  begin
    result := CommandLineSwitch(aSwitch, '', aValueDelimiter);
  end;


  function CommandLineSwitch(const aSwitch: String;
                             const aDefaultValue: String;
                             const aValueDelimiter: Char): ICommandLineSwitch;
  var
    i: Integer;
    found: Boolean;
    arg: String;
    nextArg: String;
    args: IStringList;
    value: String;
  begin
    args  := CommandLineArgsAsStringList;
    found := FALSE;

    for i := 0 to Pred(args.Count) do
    begin
      arg   := args[i];
      value := '';

      if NOT arg.BeginsWithText(aSwitch) then
        CONTINUE;

      value := aDefaultValue;

      STR.DeleteLeftText(arg, aSwitch);

      if arg.IsEmpty then
      begin
        if (i < Pred(args.Count)) then
        begin
          nextArg := args[i + 1];
          if NOT (ANSI(nextArg[1]) in ['-', '/']) then
            value := nextArg;
        end;
      end
      else if arg.BeginsWith(':') or arg.BeginsWith('=') then
      begin
        STR.DeleteLeft(arg, 1);

        value := arg;
      end
      else
        CONTINUE; // Not aSwitch or aSwitch VALUE or aSwitch:VALUE or aSwitch=VALUE

      found := TRUE;
      BREAK;
    end;

    result := TCommandLineSwitch.Create(aSwitch, '', value, aValueDelimiter, found);
  end;


  function CommandLineSwitch(const aSwitches: TStringArray): ICommandLineSwitch;
  begin
    result := CommandLineSwitch(aSwitches, '', #0);
  end;


  function CommandLineSwitch(const aSwitches: TStringArray;
                             const aDefaultValue: String): ICommandLineSwitch;
  begin
    result := CommandLineSwitch(aSwitches, aDefaultValue, #0);
  end;


  function CommandLineSwitch(const aSwitches: TStringArray;
                             const aValueDelimiter: Char): ICommandLineSwitch;
  begin
    result := CommandLineSwitch(aSwitches, '', aValueDelimiter);
  end;


  function CommandLineSwitch(const aSwitches: TStringArray;
                             const aDefaultValue: String;
                             const aValueDelimiter: Char): ICommandLineSwitch;
  var
    i: Integer;
  begin
    for i := 0 to High(aSwitches) do
    begin
      result := CommandLineSwitch(aSwitches[i], aDefaultValue, aValueDelimiter);
      if Assigned(result) then
        EXIT;
    end;
  end;



end.
