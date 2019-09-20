

  unit Deltics.Humanizer;


interface

  type
    TDataSizeOption = (
                       dsBytes,       // Value in full as bytes
                       dsBinaryIEC,   // 1 KiB = 1024 bytes
                       dsBinarySI,    // 1 KB  = 1024 bytes
                       dsMetric       // 1 KB  = 1000 bytes
                      );

    Humanize = class
    public
      class function DataSize(aSize: Int64; aOpt: TDataSizeOption = dsBinarySI): String;
    end;



implementation

  uses
    SysUtils;

{ Humanize }

  class function Humanize.DataSize(aSize: Int64;
                                   aOpt: TDataSizeOption): String;
  const
    SUFFIX  : array[FALSE..TRUE, 0..8] of String = (
                                                    ('bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'),
                                                    ('bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB')
                                                   );
  var
//    base: Word;
    s: String;
  begin
    if aOpt = dsBytes then
    begin
      s       := IntToStr(aSize);
      result  := '';
      while Length(s) > 3 do
      begin
        result := Copy(s, Length(s) - 2, 3) + ',' + result;
        SetLength(s, Length(s) - 3);
      end;

      if Length(s) > 0 then
        result := s + ',' + result;

      if Length(result) > 3 then
        SetLength(result, Length(result) - 1);

      result := result + ' bytes';
      EXIT;
    end;

(*
    case aOpt of
      dsBinaryIEC,
      dsBinarySI  : base := 1024;

      dsMetric    : base := 1000;
    end;

    // TODO: ...
*)
  end;



end.
