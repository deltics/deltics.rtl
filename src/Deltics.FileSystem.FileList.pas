

  unit Deltics.FileSystem.FileList;


interface

  uses
    Classes,
    Deltics.Strings;


  type
    TFileList = class
    private
      fFilenames: TStringList;
      fPath: String;
      fPatterns: TStringArray;
      fRecursive: Boolean;
      function get_Count: Integer;
      function get_Filename(const aIndex: Integer): String;
      function get_Pattern: String;
      procedure set_Path(const aValue: String);
      procedure set_Pattern(const aValue: String);
      procedure set_Recursive(const aValue: Boolean);
      procedure GetFiles;
    public
      constructor Create(aRecursive: Boolean = FALSE); overload;
      constructor Create(const aPath: String; aRecursive: Boolean = FALSE); overload;
      constructor Create(const aPath: String; const aPattern: String; aRecursive: Boolean = FALSE); overload;
      destructor Destroy; override;
      procedure Delete(aIndex: Integer);
      property Count: Integer read get_Count;
      property Filenames[const aIndex: Integer]: String read get_Filename; default;
      property Path: String read fPath write set_Path;
      property Pattern: String read get_Pattern write set_Pattern;
      property Recursive: Boolean read fRecursive write set_Recursive;
    end;


implementation

  uses
    SysUtils;



  constructor TFileList.Create(aRecursive: Boolean);
  begin
    Create('', '', aRecursive);
  end;

  constructor TFileList.Create(const aPath: String; aRecursive: Boolean);
  begin
    Create(aPath, '*.*', aRecursive);
  end;

  constructor TFileList.Create(const aPath: String;
                               const aPattern: String;
                                     aRecursive: Boolean);
  begin
    inherited Create;

    fFilenames  := TStringList.Create;
    fPath       := aPath;
    fRecursive  := aRecursive;

    set_Pattern(aPattern);
  end;


  destructor TFileList.Destroy;
  begin
    fFilenames.Free;

    inherited;
  end;


  function TFileList.get_Count: Integer;
  begin
    result := fFilenames.Count;
  end;


  function TFileList.get_Filename(const aIndex: Integer): String;
  begin
    result := fFilenames[aIndex];
  end;



  function TFileList.get_Pattern: String;
  begin
    result := STR.Concat(fPatterns, ';');
  end;


  procedure TFileList.set_Path(const aValue: String);
  begin
    if fPath = aValue then
      EXIT;

    fPath := aValue;

    GetFiles;
  end;


  procedure TFileList.set_Pattern(const aValue: String);
  begin
    STR.Split(aValue, ';', fPatterns);

    GetFiles;
  end;


  procedure TFileList.set_Recursive(const aValue: Boolean);
  begin
    if fRecursive = aValue then
      EXIT;

    fRecursive := aValue;
    GetFiles;
  end;


  procedure TFileList.GetFiles;

    procedure Find(const aPath: String; const aPattern: String);
    var
      i: Integer;
      rec: TSearchRec;
      folders: TStringList;
    begin
      folders := TStringList.Create;
      try
        if FindFirst(aPath + '\' + aPattern, faAnyFile, rec) = 0 then
        try
          repeat
            if (rec.Name = '.') or (rec.Name = '..') then
              CONTINUE;

            if Recursive then
            begin
              if ((rec.Attr and faDirectory) <> 0) then
                folders.Add(aPath + '\' + rec.Name)
              else
                fFilenames.Add(aPath + '\' + rec.Name)
            end
            else
              fFilenames.Add(rec.Name);

          until FindNext(rec) <> 0;

        finally
          FindClose(rec);
        end;

        if Recursive and (FindFirst(aPath + '\*.*', faDirectory, rec) = 0) then
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
          Find(folders[i], aPattern);

      finally
        folders.Free;
      end;
    end;

  var
    i: Integer;
  begin
    fFilenames.Clear;

    if (fPath = '') or (Length(fPatterns) = 0) then
      EXIT;

    for i := 0 to High(fPatterns) do
      Find(fPath, fPatterns[i]);
  end;


  procedure TFileList.Delete(aIndex: Integer);
  begin
    fFilenames.Delete(aIndex);
  end;



end.
