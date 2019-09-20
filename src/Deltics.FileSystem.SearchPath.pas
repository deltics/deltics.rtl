

  unit Deltics.FileSystem.SearchPath;


interface

  uses
    Classes;


  type
    TSearchPath = class
    private
      fPath: TStringList;
      fValue: String;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): String;
      procedure set_Value(const aValue: String);
    public
      constructor Create(const aValue: String);
      destructor Destroy; override;
      function FindFile(const aCurrDir: String; var aFilename: String): Boolean;
      procedure Add(const aDir: String);
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: String read get_Item; default;
      property Value: String read fValue write set_Value;
    end;


implementation

  uses
    SysUtils,
    Deltics.FileSystem.Utils;



  constructor TSearchPath.Create(const aValue: String);
  begin
    inherited Create;

    fPath := TStringList.Create;
    Value := aValue;
  end;


  destructor TSearchPath.Destroy;
  begin
    fPath.Free;

    inherited;
  end;


  function TSearchPath.get_Count: Integer;
  begin
    result := fPath.Count;
  end;


  function TSearchPath.get_Item(const aIndex: Integer): String;
  begin
    result := fPath[aIndex];
  end;


  procedure TSearchPath.set_Value(const aValue: String);
  var
    s: String;
  begin
    fValue := Trim(aValue);

    fPath.Clear;

    if Value = '' then
      EXIT;

    s := aValue;
    while Pos(';', s) <> 0 do
    begin
      Add(Copy(s, 1, Pos(';', s) - 1));
      Delete(s, 1, Pos(';', s));
    end;
    Add(s);
  end;


  procedure TSearchPath.Add(const aDir: String);

    procedure AddSubFolders(const aPath: String;
                            const aRecurse: Boolean);
    var
      rec: TSearchRec;
    begin
      Add(aPath);

      if FindFirst(aPath + '\*.*', faDirectory, rec) = 0 then
      try
        repeat
          if (rec.Name = '.') or (rec.Name = '..') or ((rec.Attr and faDirectory) = 0) then
            CONTINUE;

          if aRecurse then
            AddSubFolders(aPath + '\' + rec.Name, TRUE)
          else
            Add(aPath + '\' + rec.Name);

        until FindNext(rec) <> 0;

      finally
        FindClose(rec);
      end;
    end;

  begin
    if aDir[Length(aDir)] = '*' then
      AddSubFolders(Path.Branch(aDir), aDir[Length(aDir) - 1] = '*')
    else if (fPath.IndexOf(aDir) = -1) and DirectoryExists(aDir) then
      fPath.Add(aDir);
  end;


  function TSearchPath.FindFile(const aCurrDir: String; var aFilename: String): Boolean;
  var
    i: Integer;
    uri: String;
    cd: String;
  begin
    result := FALSE;

    if aFilename = '' then
      EXIT;

    try
      if ((aFileName[1] = '.') and (aFileName[2] = '.') and (aFileName[3] = '\'))
       or ((aFileName[1] = '.') and (aFileName[2] = '\')) then
      begin
        uri := Path.RelativeToAbsolute(aFilename, aCurrDir);
        if NOT FileExists(uri) then
          uri := '';

        EXIT;
      end;

      cd := aCurrDir;
      if cd[Length(cd)] <> '\' then
        cd := cd + '\';

      uri := cd + aFilename;
      if FileExists(uri) then
        EXIT;

      for i := 0 to Pred(fPath.Count) do
      begin
        uri := Path.RelativeToAbsolute(fPath[i] + '\' + aFilename, aCurrDir);
        if FileExists(uri) then
          EXIT;
      end;

      uri := '';

    finally
      result := (uri <> '');
      if result then
        aFilename := uri;
    end;
  end;




end.
