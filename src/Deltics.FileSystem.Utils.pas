

  unit Deltics.FileSystem.Utils;

{$i deltics.rtl.inc}

interface

  uses
    SysUtils,
    Deltics.Exceptions,
    Deltics.Strings,
    Deltics.Uri;


  type
    Path = class
      class function Absolute(const aPath: String; const aRootPath: String = ''): String;
      class function Append(const aBase, aExtension: String): String;
      class function Branch(const aPath: String): String;
      class function CurrentDir: UnicodeString;
      class function Exists(const aPath: UnicodeString): Boolean;
      class function IsAbsolute(const aPath: String): Boolean;
      class function Leaf(const aPath: String): String;
      class function AbsoluteToRelative(const aPath: String; const aBasePath: String = ''): String;
      class function RelativeToAbsolute(const aRelativePath: String; const aRootPath: String = ''): String;
      class function Volume(const aAbsolutePath: String): String;
      class function MakePath(const aElements: array of const): String;
      class function PathFromUri(const aUri: TUri): String; overload;
      class function PathFromUri(const aUri: String): String; overload;
    end;


  procedure CopyFile(const aFilename: String; const aDestPath: String);


implementation

  uses
    ShellApi,
    Deltics.StringTemplates;


  function ConstArgAsString(aValue: TVarRec): String;

    {$ifdef __DELPHIXE}
      {$ifdef CPU32BITS}
        function IntPtr(aPointer: Pointer): Integer;
        begin
          result := Integer(aPointer);
        end;
      {$else}
        function IntPtr(aPointer: Pointer): Int64;
        begin
          result := Int64(aPointer);
        end;
      {$endif}
    {$endif}

  begin
    case aValue.VType of
      vtBoolean,
      vtObject,
      vtClass,
      vtInterface:
        raise ENotSupportedException.Create('Unable to render const array value as string');

      vtInteger:
        result := IntToStr(aValue.VInteger);

      vtWideChar,
      vtChar:
        if aValue.VType = vtChar then
          result := STR.FromANSI(ANSIChar(aValue.VChar))
        else
          result := STR.FromWIDE(WIDEChar(aValue.VWideChar));

      vtExtended, vtCurrency:
        raise ENotSupportedException.Create('Unable to render const array value as string');

      vtPointer:
        result := IntToHex(IntPtr(aValue.VPointer), SizeOf(Pointer) * 2);

      vtPChar:
        result := STR.FromANSI(AnsiString(aValue.VPChar));

      vtPWideChar:
        result := STR.FromBuffer(aValue.VPWideChar);

    {$IFNDEF NEXTGEN}
      vtString:
        result := UnicodeString(PShortString(aValue.VAnsiString)^);

      vtAnsiString:
        result := STR.FromANSI(ANSIString(aValue.VAnsiString^));

      vtWideString:
        result := STR.FromBuffer(PWIDEChar(aValue.VWideString));
    {$ENDIF !NEXTGEN}

    {$ifdef DELPHI 2009__}
      vtVariant:
        if Assigned(System.VarToUStrProc) then
        begin
          System.VarToUStrProc(s, TVarData(aValue.VVariant^));
          result := s;
        end;

      vtUnicodeString:
        result := UnicodeString(aValue.VUnicodeString);
    {$endif}

      vtInt64:
        result := IntToStr(aValue.VInt64^);
    end;
  end;


  function ConstArgsAsStringArray(aArgs: array of const): TStringArray;
  var
    i: Integer;
  begin
    SetLength(result, Length(aArgs));

    for i := 0 to High(aArgs) do
      result[i] := ConstArgAsString(aArgs[i]);
  end;



{ TFileSystem }

  class function Path.Absolute(const aPath, aRootPath: String): String;
  begin
    if IsAbsolute(aPath) then
      result := aPath
    else
      result := RelativeToAbsolute(aPath, aRootPath);
  end;


  class function Path.AbsoluteToRelative(const aPath, aBasePath: String): String;
  var
    base: String;
    stem: String;
    nav: String;
  begin
    result := aPath;

    base := aBasePath;
    if base = '' then
      base := Path.CurrentDir;

    // If it is a sub-directory of the base path then we can just remove the base path
    if STR.BeginsWithText(aPath, base) then
    begin
      result := Copy(aPath, Length(base) + 2, Length(aPath) - Length(base));
      EXIT;
    end;

    // Otherwise, let's try progressively jumping up to parent directories and
    //  if we eventually find a common root we can add directory navigation to
    //  the relative path
    stem  := base;
    nav   := '';
    while (stem <> '') do
    begin
      stem := Branch(stem);
      if nav <> '' then
        nav  := '..\' + nav
      else
        nav := '..';

      if STR.BeginsWithText(aPath, stem) then
      begin
        result := nav + '\' + Copy(aPath, Length(stem) + 2, Length(aPath) - Length(stem) + 1);
        BREAK;
      end;
    end;
  end;


  class function Path.Append(const aBase, aExtension: String): String;
  begin
    if aBase = '' then
      result := aExtension
    else if aExtension = '' then
      result := aBase
    else
    begin
      result := aBase;

      if aExtension[1] = '\' then
      begin
        if result[Length(result)] = '\' then
          SetLength(result, Length(result) - 1);
      end
      else if result[Length(result)] <> '\' then
        result := result + '\';

      result := result + aExtension;
    end;
  end;


  class function Path.Leaf(const aPath: String): String;
  {
    Returns the file or folder identified by the specified path.

    Examples:

        Leaf( 'abc\def\ghi' )  ==> 'ghi'
  }
  begin
    result := ExtractFilename(aPath);
  end;


  class function Path.MakePath(const aElements: array of const): String;
  var
    i: Integer;
    strs: TStringArray;
  begin
    result := '';
    SetLength(strs, 0);
    if Length(aElements) = 0 then
      EXIT;

    strs := ConstArgsAsStringArray(aElements);
    result := strs[0];
    for i := 1 to High(strs) do
      result := Path.Append(result, strs[i]);
  end;


  class function Path.PathFromUri(const aUri: String): String;
  var
    uri: TUri;
  begin
    uri := TUri.Create(aUri);
    try
      result := PathFromUri(uri);

    finally
      uri.Free;
    end;
  end;


  class function Path.PathFromUri(const aUri: TUri): String;
  begin
    if aUri.Host <> '' then
      result := '//' + aUri.Host + '/' + aUri.Path
    else
      result := aUri.Path;
  end;


  class function Path.IsAbsolute(const aPath: String): Boolean;
  begin
    result := (Copy(aPath, 1, 2) = '\\')
           or (Copy(aPath, 2, 2) = ':\');
  end;


  class function Path.Branch(const aPath: String): String;
  {
    Returns the path containing the specified path or an empty
     string if the specified path has no identifiable branch.

    Examples:

        Branch( 'abc\def\ghi' )  ==> 'abc\def'
        Branch( 'abc' )          ==> ''
  }
  begin
    if Pos('\', aPath) <> 0 then
    begin
      result := ExtractFilePath(aPath);
      SetLength(result, Length(result) - 1);
    end
    else
      result := '';
  end;


  class function Path.CurrentDir: UnicodeString;
  begin
    result := GetCurrentDir;
  end;


  class function Path.Exists(const aPath: UnicodeString): Boolean;
  var
    target: UnicodeString;
  begin
    target := aPath;

    if NOT Path.IsAbsolute(target) then
      target := RelativeToAbsolute(target);

    result := DirectoryExists(target);
  end;


  class function Path.RelativeToAbsolute(const aRelativePath: String;
                                         const aRootPath: String): String;
  var
    cd: String;
  begin
    result := aRelativePath;
    try
      if IsAbsolute(aRelativePath) then
        EXIT;

      if aRootPath = '' then
        cd := GetCurrentDir
      else
        cd := aRootPath;

      if NOT IsAbsolute(cd) then
        raise Exception.Create('Specified root for relative path must be a fully qualified path (UNC or drive letter)');

      if cd[Length(cd)] = '\' then
        SetLength(cd, Length(cd) - 1);

      if (aRelativePath = '.') or (aRelativePath = '.\')  then
      begin
        result := cd;
        EXIT;
      end;

      if aRelativePath = '..' then
      begin
        result := Branch(cd);
        EXIT;
      end;

      if aRelativePath[1] = '\' then
      begin
        result := Path.Volume(cd) + aRelativePath;
      end
      else if Copy(aRelativePath, 1, 3) = '..\' then
      begin
        result := aRelativePath;
        repeat
          Delete(result, 1, 3);
          cd := Branch(cd)
        until Copy(result, 1, 2) <> '..';

        result := cd + '\' + result;
      end
      else if Copy(aRelativePath, 1, 2) = '.\' then
      begin
        result := aRelativePath;
        Delete(result, 1, 2);
        result := cd + '\' + result;
      end
      else
        result := cd + '\' + aRelativePath;

    finally
      if (Length(result) > 0) and STR.EndsWith(result, '\') then
        STR.DeleteRight(result, 1);
    end;
  end;


  class function Path.Volume(const aAbsolutePath: String): String;
  var
    i: Integer;
    target: String;
  begin
    target := aAbsolutePath;

    if NOT Path.IsAbsolute(target) then
      raise Exception.Create('Specified path must be a fully qualified path (UNC or driver letter)');

    if target[2] = ':' then
    begin
      result := Copy(target, 1, 2);
      EXIT;
    end;

    if Copy(target, 1, 2) = '\\' then
    begin
      Delete(target, 1, 2);
      result := '\\';
    end;

    i := Pos(target, '\');
    if i > 0 then
    begin
      result := result + Copy(target, 1, i - 1);
      Delete(target, 1, i - 1);
    end
    else
    begin
      result := result + target;
      EXIT;
    end;

    i := Pos(target, '\');
    if i > 0 then
    begin
      result := result + Copy(target, 1, i - 1);
      Delete(target, 1, i - 1);
    end;
  end;




  procedure CopyFile(const aFilename: String; const aDestPath: String);
  var
    fileOp: TSHFileOpStruct;
    srcFile: String;
    srcFileDnt: String;
    destFile: String;
    destFileDnt: String;
    copyResult: Integer;
  begin
    srcFile   := aFilename;
    destFile  := Path.Append(aDestPath, ExtractFilename(aFilename));

    // Shell Api operation filenames must be DOUBLE null-terminated!

    srcFileDnt  := srcFile + #0;
    destFileDnt := destFile + #0;

    fileOp.Wnd    := 0;
    fileOp.wFunc  := FO_COPY;
    fileOp.pFrom  := PChar(srcFileDnt);
    fileOp.pTo    := PChar(destFileDnt);
    fileOp.fFlags := FOF_SILENT;
    fileOp.lpszProgressTitle  := NIL;

    copyResult := ShFileOperation(fileOp);
    if copyResult <> 0 then
      raise EInOutError.Create(SysErrorMessage(copyResult));
  end;


end.
