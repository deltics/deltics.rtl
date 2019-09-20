

  unit Deltics.Memory;


interface

  type
    Memory = class
      class procedure CopyBytes(aBuffer: Pointer; aSourceOffset, aDestOffset, aCount: Integer); overload;
      class procedure CopyWIDEChars(aBuffer: Pointer; aSourceOffset, aDestOffset, aCount: Integer); overload;
    end;

implementation

  uses
    Windows,
    Deltics.SysUtils;


  class procedure Memory.CopyBytes(aBuffer: Pointer;
                                   aSourceOffset: Integer;
                                   aDestOffset: Integer;
                                   aCount: Integer);
  var
    src: Pointer;
    dest: Pointer;
  begin
    src   := ByteOffset(aBuffer, aSourceOffset);
    dest  := ByteOffset(aBuffer, aDestOffset);

    CopyMemory(dest, src, aCount);
  end;


  class procedure Memory.CopyWIDEChars(aBuffer: Pointer;
                                       aSourceOffset: Integer;
                                       aDestOffset: Integer;
                                       aCount: Integer);
  var
    src: Pointer;
    dest: Pointer;
  begin
    src   := ByteOffset(aBuffer, aSourceOffset * 2);
    dest  := ByteOffset(aBuffer, aDestOffset * 2);

    CopyMemory(dest, src, aCount * 2);
  end;




end.
