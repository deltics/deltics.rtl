
{$i deltics.rtl.inc}

  program tests;

uses
  Deltics.Smoketest,
  Deltics.Async in '..\src\Deltics.Async.pas',
  Deltics.Bitfield in '..\src\Deltics.Bitfield.pas',
  Deltics.Canvas in '..\src\Deltics.Canvas.pas',
  Deltics.Canvas.Stacks in '..\src\Deltics.Canvas.Stacks.pas',
  Deltics.Classes in '..\src\Deltics.Classes.pas',
  Deltics.CommandLine.Interfaces in '..\src\Deltics.CommandLine.Interfaces.pas',
  Deltics.CommandLine in '..\src\Deltics.CommandLine.pas',
  Deltics.CommandLine.Switches in '..\src\Deltics.CommandLine.Switches.pas',
  Deltics.CommandLine.Utils in '..\src\Deltics.CommandLine.Utils.pas',
  Deltics.Contracts in '..\src\Deltics.Contracts.pas',
  Deltics.CSV.StreamReader in '..\src\Deltics.CSV.StreamReader.pas',
  Deltics.DateUtils in '..\src\Deltics.DateUtils.pas',
  Deltics.Delphi.Versions in '..\src\Deltics.Delphi.Versions.pas',
  Deltics.Exceptions in '..\src\Deltics.Exceptions.pas',
  Deltics.FileSearch in '..\src\Deltics.FileSearch.pas',
  Deltics.FileSystem.FileList in '..\src\Deltics.FileSystem.FileList.pas',
  Deltics.FileSystem.SearchPath in '..\src\Deltics.FileSystem.SearchPath.pas',
  Deltics.FileSystem.Utils in '..\src\Deltics.FileSystem.Utils.pas',
  Deltics.Finalizer in '..\src\Deltics.Finalizer.pas',
  Deltics.Forms in '..\src\Deltics.Forms.pas',
  Deltics.GDI.Regions in '..\src\Deltics.GDI.Regions.pas',
  Deltics.GDI.Utils in '..\src\Deltics.GDI.Utils.pas',
  Deltics.Graphics in '..\src\Deltics.Graphics.pas',
  Deltics.GUIDs in '..\src\Deltics.GUIDs.pas',
  Deltics.HPC in '..\src\Deltics.HPC.pas',
  Deltics.Humanizer in '..\src\Deltics.Humanizer.pas',
  Deltics.ImageLists in '..\src\Deltics.ImageLists.pas',
  Deltics.JSON in '..\src\Deltics.JSON.pas',
  Deltics.KeyedValues in '..\src\Deltics.KeyedValues.pas',
  Deltics.Memento in '..\src\Deltics.Memento.pas',
  Deltics.Memory in '..\src\Deltics.Memory.pas',
  Deltics.MessageHandler in '..\src\Deltics.MessageHandler.pas',
  Deltics.MultiCast in '..\src\Deltics.MultiCast.pas',
  Deltics.Oscillator in '..\src\Deltics.Oscillator.pas',
  Deltics.Parser in '..\src\Deltics.Parser.pas',
  Deltics.Readers in '..\src\Deltics.Readers.pas',
  Deltics.RTTI in '..\src\Deltics.RTTI.pas',
  Deltics.SemVer in '..\src\Deltics.SemVer.pas',
  Deltics.Shell.API in '..\src\Deltics.Shell.API.pas',
  Deltics.Shell.Folders in '..\src\Deltics.Shell.Folders.pas',
  Deltics.Shell in '..\src\Deltics.Shell.pas',
  Deltics.SizeGrip in '..\src\Deltics.SizeGrip.pas',
  Deltics.SparseList in '..\src\Deltics.SparseList.pas',
  Deltics.SQLBuilder in '..\src\Deltics.SQLBuilder.pas',
  Deltics.StateList in '..\src\Deltics.StateList.pas',
  Deltics.Streams in '..\src\Deltics.Streams.pas',
  Deltics.Strings.ANSI in '..\src\Deltics.Strings.ANSI.pas',
  Deltics.Strings.Encoding.ASCII in '..\src\Deltics.Strings.Encoding.ASCII.pas',
  Deltics.Strings.Encoding in '..\src\Deltics.Strings.Encoding.pas',
  Deltics.Strings.Encoding.UTF8 in '..\src\Deltics.Strings.Encoding.UTF8.pas',
  Deltics.Strings.Encoding.UTF16 in '..\src\Deltics.Strings.Encoding.UTF16.pas',
  Deltics.Strings.Encoding.UTF32 in '..\src\Deltics.Strings.Encoding.UTF32.pas',
  Deltics.Strings.Parsers.ANSI.AsBoolean in '..\src\Deltics.Strings.Parsers.ANSI.AsBoolean.pas',
  Deltics.Strings.Parsers.ANSI.AsDatetime in '..\src\Deltics.Strings.Parsers.ANSI.AsDatetime.pas',
  Deltics.Strings.Parsers.ANSI.AsInteger in '..\src\Deltics.Strings.Parsers.ANSI.AsInteger.pas',
  Deltics.Strings.Parsers.ANSI in '..\src\Deltics.Strings.Parsers.ANSI.pas',
  Deltics.Strings.Parsers.WIDE.AsBoolean in '..\src\Deltics.Strings.Parsers.WIDE.AsBoolean.pas',
  Deltics.Strings.Parsers.WIDE.AsDatetime in '..\src\Deltics.Strings.Parsers.WIDE.AsDatetime.pas',
  Deltics.Strings.Parsers.WIDE.AsInteger in '..\src\Deltics.Strings.Parsers.WIDE.AsInteger.pas',
  Deltics.Strings.Parsers.WIDE in '..\src\Deltics.Strings.Parsers.WIDE.pas',
  Deltics.Strings in '..\src\Deltics.Strings.pas',
  Deltics.Strings.StringBuilder in '..\src\Deltics.Strings.StringBuilder.pas',
  Deltics.Strings.StringList in '..\src\Deltics.Strings.StringList.pas',
  Deltics.Strings.Types in '..\src\Deltics.Strings.Types.pas',
  Deltics.Strings.UTF8 in '..\src\Deltics.Strings.UTF8.pas',
  Deltics.Strings.Utils in '..\src\Deltics.Strings.Utils.pas',
  Deltics.Strings.WIDE in '..\src\Deltics.Strings.WIDE.pas',
  Deltics.StringTemplates in '..\src\Deltics.StringTemplates.pas',
  Deltics.StrUtils in '..\src\Deltics.StrUtils.pas',
  Deltics.SysUtils in '..\src\Deltics.SysUtils.pas',
  Deltics.Threads in '..\src\Deltics.Threads.pas',
  Deltics.Threads.Storage in '..\src\Deltics.Threads.Storage.pas',
  Deltics.Threads.Synchronize in '..\src\Deltics.Threads.Synchronize.pas',
  Deltics.Threads.Worker in '..\src\Deltics.Threads.Worker.pas',
  Deltics.Types in '..\src\Deltics.Types.pas',
  Deltics.Unicode in '..\src\Deltics.Unicode.pas',
  Deltics.Uri in '..\src\Deltics.Uri.pas',
  Deltics.VersionInfo in '..\src\Deltics.VersionInfo.pas',
{$ifdef __DELPHI2009}
  Deltics.VMT in '..\src\Deltics.VMT.pas',
{$endif}
{$ifdef DELPHIXE4__}
  Deltics.Windows.Canvas in '..\src\Deltics.Windows.Canvas.pas',
{$endif}
  Deltics.Windows in '..\src\Deltics.Windows.pas';

begin
end.
