

  unit Deltics.FileSearch;


interface

  uses
    Classes,
    Deltics.Strings;


  type
    TFileSearch = class;
    TFileSearchResult = class;


    TFileSearch = class
    private
      fChildRecursive: Boolean;
      fParentRecursive: Boolean;
      fPath: String;
      fPathInResult: Boolean;
      fPatterns: TStringArray;
      fResult: TFileSearchResult;
      function get_Patterns: String;
      procedure set_Path(const aValue: String);
      procedure set_Patterns(const aValue: String);
    function get_PathInResult: Boolean;
    public
      destructor Destroy; override;
      function Execute: Boolean; overload;
      function Execute(var aResult: TFileSearchResult): Boolean; overload;
      property ChildRecursive: Boolean read fChildRecursive write fChildRecursive;
      property ParentRecursive: Boolean read fParentRecursive write fParentRecursive;
      property Path: String read fPath write set_Path;
      property PathInResult: Boolean read get_PathInResult write fPathInResult;
      property Patterns: String read get_Patterns write set_Patterns;
      property Result: TFileSearchResult read fResult;
    end;


    TFileSearchResult = class
    private
      fFiles: TStringList;
      fFolders: TStringList;
      function get_Count: Integer;
    protected
      procedure AddFile(const aPath, aFile: String);
      procedure AddFolder(const aPath, aFolder: String);
      procedure Clear;
    public
      constructor Create;
      destructor Destroy; override;
      property Count: Integer read get_Count;
      property Files: TStringList read fFiles;
      property Folders: TStringList read fFolders;
    end;


implementation

  uses
    SysUtils,
    Deltics.FileSystem.Utils;



  destructor TFileSearch.Destroy;
  begin
    fResult.Free;

    inherited;
  end;


  function TFileSearch.get_PathInResult: Boolean;
  begin
    result := fPathInResult or fParentRecursive or fChildRecursive;
  end;


  function TFileSearch.get_Patterns: String;
  begin
    result := STR.Concat(fPatterns, ';');
  end;


  procedure TFileSearch.set_Path(const aValue: String);
  begin
    if fPath = aValue then
      EXIT;

    fPath := aValue;
  end;


  procedure TFileSearch.set_Patterns(const aValue: String);
  begin
    STR.Split(aValue, ';', fPatterns);
  end;


  function TFileSearch.Execute: Boolean;
  begin
    result := FALSE;

    try
      if NOT Assigned(fResult) then
        fResult := TFileSearchResult.Create;

      result := Execute(fResult);

    finally
      if NOT result then
        FreeAndNIL(fResult);
    end;
  end;



  function TFileSearch.Execute(var aResult: TFileSearchResult): Boolean;
  var
    results: TFileSearchResult;

    procedure Find(const aPath: String; const aPattern: String; const aRecursive: Boolean);
    var
      i: Integer;
      rec: TSearchRec;
      folders: TStringList;
      resultPath: String;
    begin
      if PathInResult then
        resultPath := aPath
      else
        resultPath := '';

      folders := TStringList.Create;
      try
        if FindFirst(aPath + '\' + aPattern, faAnyFile, rec) = 0 then
        try
          repeat
            if (rec.Name = '.') or (rec.Name = '..') then
              CONTINUE;

            if ((rec.Attr and faDirectory) <> 0) then
              results.AddFolder(resultPath, rec.Name)
            else
              results.AddFile(resultPath, rec.Name)

          until FindNext(rec) <> 0;

        finally
          FindClose(rec);
        end;

        if aRecursive and (FindFirst(aPath + '\*.*', faDirectory, rec) = 0) then
        begin
          try
            repeat
              if (rec.Name = '.') or (rec.Name = '..') then
                CONTINUE;

              if (rec.Attr and faDirectory) <> 0 then
                folders.Add(aPath + '\' + rec.Name)

            until FindNext(rec) <> 0;

          finally
            FindClose(rec);
        end;

        for i := 0 to Pred(folders.Count) do
          Find(folders[i], aPattern, TRUE);
      end;

      finally
        folders.Free;
      end;
    end;

  var
    i: Integer;
    dir: String;
  begin
    result := FALSE;

    if NOT Assigned(aResult) then
      aResult := TFileSearchResult.Create
    else
      aResult.Clear;

    results := aResult;

    if (fPath = '') or (Length(fPatterns) = 0) then
      EXIT;

    for i := 0 to High(fPatterns) do
      Find(fPath, fPatterns[i], ChildRecursive);

    if ParentRecursive then
    begin
      dir := Path;

      while TRUE do
      begin
        if ExtractFilePath(dir) <> dir then
        begin
          dir := ExtractFilePath(dir);

          if dir = '' then
            BREAK;

          dir := STR.TrimRight(dir, '\');

          for i := 0 to High(fPatterns) do
            Find(dir, fPatterns[i], FALSE);
        end
        else
          BREAK;
      end;
    end;

    result := results.Count > 0;
  end;


  procedure TFileSearchResult.AddFile(const aPath, aFile: String);
  begin
    if aPath <> '' then
      fFiles.Add(aPath + '\' + aFile)
    else
      fFiles.Add(aFile);
  end;


  procedure TFileSearchResult.AddFolder(const aPath, aFolder: String);
  begin
    if aPath <> '' then
      ffolders.Add(aPath + '\' + afolder)
    else
      fFolders.Add(aFolder);
  end;


  procedure TFileSearchResult.Clear;
  begin
    fFiles.Clear;
    fFolders.Clear;
  end;


  constructor TFileSearchResult.Create;
  begin
    inherited Create;

    fFiles    := TStringList.Create;
    fFolders  := TStringList.Create;
  end;


  destructor TFileSearchResult.Destroy;
  begin
    fFolders.Free;
    fFiles.Free;

    inherited;
  end;


  function TFileSearchResult.get_Count: Integer;
  begin
    result := fFolders.Count + fFiles.Count;
  end;







end.
