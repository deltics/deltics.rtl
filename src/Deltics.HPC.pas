{
  * X11 (MIT) LICENSE *

  Copyright © 2008 Jolyon Smith

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

{$ifdef deltics_hpc}
  {$debuginfo ON}
{$else}
  {$debuginfo OFF}
{$endif}

  unit Deltics.HPC;


interface

  uses
  { deltics: }
    Deltics.Classes;


  type
    ITimerMark = interface
    ['{BA752749-BC3C-4789-88DA-9BE77EA08707}']
      function get_ElapsedMilliseconds: Integer;
      function get_ElapsedTime: TDateTime;
      function get_ElapsedTimeAsString: String;

      property ElapsedMilliseconds: Integer read get_ElapsedMilliseconds;
      property ElapsedTime: TDateTime read get_ElapsedTime;
      property ElapsedTimeAsString: String read get_ElapsedTimeAsString;
    end;


    IPerformanceCounter = interface
    ['{A460C917-4B3D-4FDD-9EC1-FA2BD14297DC}']
      function get_Frequency: Int64;
      function get_Tick: Int64;
      function get_Value: Int64;
      function Mark: ITimerMark;

      property Frequency: Int64 read get_Frequency;
      property Tick: Int64 read get_Tick;
      property Value: Int64 read get_Value;
    end;


  function HPC: IPerformanceCounter;


implementation

  uses
  { vcl: }
    SysUtils,
    Windows;


  var
    _HPC: IPerformanceCounter;


  function HPC: IPerformanceCounter;
  begin
    result := _HPC;
  end;


  type
    TCounter = class(TCOMInterfacedObject)
    protected
      function get_Tick: Int64; virtual; abstract;
      function Mark: ITimerMark;
    end;


    TPerformanceCounter = class(TCounter, IPerformanceCounter)
    private
      fFrequency: Int64;
    public
      constructor Create;

    protected // IPerformanceCounter
      function get_Frequency: Int64;
      function get_Tick: Int64; override;
      function get_Value: Int64;
    end;


    TTickCounter = class(TCounter, IPerformanceCounter)
    protected // IPerformanceCounter
      function get_Frequency: Int64;
      function get_Tick: Int64; override;
      function get_Value: Int64;
    end;


    TTimerMark = class(TCOMInterfacedObject, ITimerMark)
    private
      fMark: Int64;
      constructor Create(aMark: Int64);
    protected // ITimerMark
      function get_ElapsedMilliseconds: Integer;
      function get_ElapsedTime: TDateTime;
      function get_ElapsedTimeAsString: String;
    end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCounter.Mark: ITimerMark;
  begin
    result := TTimerMark.Create(get_Tick);
  end;



{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 GetHPCTime and GetHPCFreq implement required counter operations using the hardware high
  performance counter API.

 This mechanism is only available where a hardware high performance counter is present.

 If used, these functions are called via the GetTime and GetFreq function type variables.

 GetHPCTime is also called directly during initialization to determine whether or not the
  high performance counter API is available (returns 0 if not).
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TPerformanceCounter.Create;
  begin
    inherited Create;

    QueryPerformanceFrequency(fFrequency);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TPerformanceCounter.get_Frequency: Int64;
  begin
    result := fFrequency;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TPerformanceCounter.get_Tick: Int64;
  begin
    QueryPerformanceCounter(result);

    if fFrequency <> 1000 then
      result := (result * 1000) div fFrequency;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TPerformanceCounter.get_Value: Int64;
  begin
    QueryPerformanceCounter(result);
  end;






{- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 GetTCTime and GetTCFreq implement required counter operations using the GetTickCount API.

 This mechanism is provided as a fall-back mechanism for the situation where a high
  performance hardware counter is not available.

 The frequency of the GetTickCount API is nominally 1000 ticks per second.  The actual
  resolution of timer values may not be this accurate, but this is how values are
  reported.
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTickCounter.get_Frequency: Int64;
  begin
    result := 1000;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTickCounter.get_Tick: Int64;
  begin
    result := GetTickCount;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTickCounter.get_Value: Int64;
  begin
    result := GetTickCount;
  end;





{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

  function IsPerformanceCounterSupported: Boolean;
  var
    testValue: Int64;
  begin
    QueryPerformanceCounter(testValue);
    result := (testValue <> 0);
  end;






{ TTimerMark }

  constructor TTimerMark.Create(aMark: Int64);
  begin
    inherited Create;

    fMark := aMark;
  end;


  function TTimerMark.get_ElapsedMilliseconds: Integer;
  begin
    result := HPC.Tick - fMark;
  end;


  function TTimerMark.get_ElapsedTime: TDateTime;
  begin
    result  := (24 * 60 * 60 * 1000) / (HPC.Tick - fMark);
  end;


  function TTimerMark.get_ElapsedTimeAsString: String;
  const
    MS_PERDAY     = 24 * 60 * 60 * 1000;
    MS_PERHOUR    = 60 * 60 * 1000;
    MS_PERMINUTE  = 60 * 1000;
    MS_PERSECOND  = 1000;
  var
    elapsed: Int64;
    duration: Int64;
  begin
    elapsed := (HPC.Tick - fMark);
    result  := '';

    if elapsed > MS_PERDAY then
    begin
      duration  := elapsed div MS_PERDAY;
      result    := IntToStr(duration) + ' days, ';
      elapsed   := elapsed - (duration * MS_PERDAY);
    end;

    if elapsed > MS_PERHOUR then
    begin
      duration  := elapsed div MS_PERHOUR;
      result    := result + IntToStr(duration) + ':';
      elapsed   := elapsed - (duration * MS_PERHOUR);
    end;

    if elapsed > MS_PERMINUTE then
    begin
      duration  := elapsed div MS_PERMINUTE;
      result    := result + Format('%.2d:', [duration]);
      elapsed   := elapsed - (duration * MS_PERMINUTE);
    end;

    if elapsed > MS_PERSECOND then
    begin
      duration  := elapsed div MS_PERSECOND;
      result    := result + Format('%.2d', [duration]);
      elapsed   := elapsed - (duration * MS_PERSECOND);
    end
    else
      result := '0';

    result := result + Format('.%.3ds', [elapsed]);
  end;






initialization
  if IsPerformanceCounterSupported then
    _HPC := TPerformanceCounter.Create
  else
    _HPC := TTickCounter.Create;

end.
