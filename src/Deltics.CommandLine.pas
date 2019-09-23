{
  * X11 (MIT) LICENSE *

  Copyright © 2011 Jolyon Smith

  Permission is hereby granted, free of charge, to any person obtaining a copy of
   this software and associated documentation files (the "Software"), to deal in
   the Software without restriction, including without limitation the rights to
   use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
   of the Software, and to permit persons to whom the Software is furnished to do
   so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
   copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.


  * GPL and Other Licenses *

  The FSF deem this license to be compatible with version 3 of the GPL.
   Compatability with other licenses should be verified by reference to those
   other license terms.


  * Contact Details *

  Original author : Jolyon Smith
  skype           : deltics
  e-mail          : <EXTLINK mailto: jsmith@deltics.co.nz>jsmith@deltics.co.nz</EXTLINK>
  website         : <EXTLINK http://www.deltics.co.nz>www.deltics.co.nz</EXTLINK>
}

{$i deltics.rtl.inc}

{.$ifdef deltics_commandline}
  {$debuginfo ON}
{.$else}
  {.$debuginfo OFF}
{.$endif}

  unit Deltics.CommandLine;


interface

  uses
  { vcl: }
    Classes,
    SysUtils,
  { deltics: }
    Deltics.Classes,
    Deltics.Strings,
    Deltics.Types,
    Deltics.CommandLine.Interfaces,
    Deltics.CommandLine.Utils;


  type
    ICommandLine          = Deltics.CommandLine.Interfaces.ICommandLine;
    ICommandLineSwitch    = Deltics.CommandLine.Interfaces.ICommandLineSwitch;
    ICommandLineSwitches  = Deltics.CommandLine.Interfaces.ICommandLineSwitches;


    EInvalidCommandLine = Deltics.CommandLine.Interfaces.EInvalidCommandLine;


    CommandLineUtils = Deltics.CommandLine.Utils.CommandLineUtils;


    TCommandLine = class(TComInterfacedObject, ICommandLine)
    private
      fArguments: IStringList;                // The list of params that are not switches or switch values
      fCommandLine: String;
      fExeFilename: String;
      fParams: IStringList;                   // The list of ALL command line params
      fSwitches: ICommandLineSwitches;
      function get_Arguments: IStringList;
      function get_AsString: String;
      function get_ExeFilename: String;
      function get_Params: IStringList;
      function get_Switches: ICommandLineSwitches;
    public
      constructor Create(const aCommand: String = ''; const aParams: String = '');
      procedure Parse;
    end;


    function CommandLine: ICommandLine; overload;
    function CommandLine(const aForcedCommandLine: String): ICommandLine; overload;


implementation

  uses
    Deltics.CommandLine.Switches;


  var
    _CommandLine: ICommandLine;


  function CommandLine: ICommandLine;
  begin
    if NOT Assigned(_CommandLine) then
      _CommandLine := TCommandLine.Create;

    result := _CommandLine;
  end;


  function CommandLine(const aForcedCommandLine: String): ICommandLine; overload;
  begin
    result := TCommandLine.Create(aForcedCommandLine);
  end;



{ TCommandLine ----------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TCommandLine.Create(const aCommand: String;
                                  const aParams: String);
  var
    cmd: ICommandLine;
  begin
    inherited Create;

    cmd := self as ICommandLine;

    fArguments  := TComInterfacedStringList.Create;
    fSwitches   := TCommandLineSwitches.Create(cmd);

    if fCommandLine <> '' then
    begin
      fCommandLine := STR.Enquote(STR.Unquote(aCommand));
      if aParams <> '' then
        fCommandLine := fCommandLine + ' ' + aParams;
    end
    else
      fCommandLine := CmdLine;

    fParams := CommandLineUtils.CommandLineToArgs(fCommandLine);

    fExeFilename  := fParams[0];

    Parse;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCommandLine.get_ExeFilename: String;
  begin
    result := fExeFilename;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCommandLine.get_Params: IStringList;
  begin
    result := fParams;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCommandLine.get_Switches: ICommandLineSwitches;
  begin
    result := fSwitches;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCommandLine.get_Arguments: IStringList;
  begin
    result := fArguments;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCommandLine.get_AsString: String;
  begin
    result := fCommandLine;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TCommandLine.Parse;
  {
    app.exe param1 param2 -s1 s1value1;s2value2 -s2 s2value1 s2value2 -s3
  }
  var
    i: Integer;
    paramCount: Integer;
    s: String;
    v: String;
    switchString: String;
    switchValues: IStringList;
  begin
    i           := 1;
    paramCount  := fParams.Count;
    while i < paramCount do
    begin
      s := fParams[i];

      if CommandLineUtils.IsSwitch(s, switchString, v) then
      begin
        switchValues := TComInterfacedStringList.Create;

        while (v <> '') do
          switchValues.Add(STR.Unquote(STR.ExtractQuotedValue(v, ';')));

        while (i < Pred(paramCount)) and NOT CommandLineUtils.IsSwitch(fParams[i + 1]) do
        begin
          switchValues.Add(STR.Unquote(fParams[i + 1]));
          Inc(i);
        end;

        (fSwitches as ICommandLineSwitchesParser).AddSwitch(switchString, switchValues);
      end
      else
        fArguments.Add(s);

      Inc(i);
    end;
  end;





end.
