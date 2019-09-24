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


  unit Deltics.SparseList;


interface

  uses
    Classes,
    Contnrs,
    Deltics.Strings;


  type
    TCustomSparseList = class;
    TSparseListItem = class;
    TSparseList = class;
    TSparseListItemClass = class of TSparseListItem;

    TSparseListVoids = (slAccept, slIgnore, slError);


    TCustomSparseList = class
    private
      fAutoInsert: Boolean;
      fItemClass: TSparseListItemClass;
      fItems: TObjectList;
      function get_Count: Integer;
      function get_Item(const aKey: Int64): TSparseListItem;
      function get_ItemByIndex(const aIndex: Integer): TSparseListItem;
      function get_Key(const aIndex: Integer): Int64;
    protected
      procedure DoGetItemClass(var aClass: TSparseListItemClass); virtual;
      function Add(const aKey: Int64): TSparseListItem;
      function Find(const aKey: Int64; var aIndex: Integer): Boolean;
      function Floor(const aKey: Int64): TSparseListItem; overload;
      function Get(const aKey: Int64): TSparseListItem; overload;
      function Get(const aKey: Int64; var aItem): Boolean; overload;
      property ItemByIndex[const aIndex: Integer]: TSparseListItem read get_ItemByIndex;
      property Items[const aKey: Int64]: TSparseListItem read get_Item;
    public
      constructor Create(const aAutoInsert: Boolean = FALSE);
      destructor Destroy; override;
      procedure AfterConstruction; override;
      procedure Clear;
      procedure Delete(const aKey: Int64);
      property AutoInsert: Boolean read fAutoInsert write fAutoInsert;
      property Count: Integer read get_Count;
      property Keys[const aIndex: Integer]: Int64 read get_Key;
    end;


    TSparseListItem = class
    private
      fKey: Int64;
    public
      property Key: Int64 read fKey;
    end;



    TSparseList = class(TCustomSparseList)
    private
      function get_Item(const aKey: Int64): Pointer;
      procedure set_Item(const aKey: Int64; const aValue: Pointer);
    protected
      procedure DoGetItemClass(var aClass: TSparseListItemClass); override;
    public
      procedure Add(const aKey: Int64; const aData: Pointer);
      property Items[const aKey: Int64]: Pointer read get_Item write set_Item; default;
    end;


    TSparseStringList = class(TCustomSparseList)
    private
      function get_Item(const aKey: Int64): UnicodeString;
      procedure set_Item(const aKey: Int64; const aValue: UnicodeString);
    protected
      procedure DoGetItemClass(var aClass: TSparseListItemClass); override;
    public
      procedure Add(const aKey: Int64; const aValue: UnicodeString);
      property Items[const aKey: Int64]: UnicodeString read get_Item write set_Item; default;
    end;






implementation

  uses
    SysUtils,
    Deltics.SysUtils;



  type
    TPointerListItem = class(TSparseListItem)
    private
      fValue: Pointer;
    public
      property Value: Pointer read fValue write fValue;
    end;


    TStringListItem = class(TSparseListItem)
    private
      fValue: UnicodeString;
    public
      property Value: UnicodeString read fValue write fValue;
    end;







{ TCustomSparseList ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TCustomSparseList.Create(const aAutoInsert: Boolean);
  begin
    inherited Create;

    fAutoInsert := aAutoInsert;
    fItems      := TObjectList.Create(TRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TCustomSparseList.Destroy;
  begin
    FreeAndNIL(fItems);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TCustomSparseList.DoGetItemClass(var aClass: TSparseListItemClass);
  begin
    raise ENotImplemented.Create(ClassName + ' does not provide an implementation of DoGetItemClass');
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TCustomSparseList.AfterConstruction;
  begin
    inherited;

    DoGetItemClass(fItemClass);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.Find(const aKey: Int64;
                                  var   aIndex: Integer): Boolean;
  var
    L, H, I, C: Integer;
  begin
    result := FALSE;

    L := 0;
    H := Count - 1;

    while L <= H do
    begin
      I := (L + H) shr 1;
      C := TSparseListItem(fItems[I]).Key - aKey;

      if C >= 0 then
      begin
        H := I - 1;
        if C = 0 then
        begin
          result := TRUE;
          L      := I;
          BREAK;
        end;
      end
      else
        L := I + 1;
    end;

    aIndex := L;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.Floor(const aKey: Int64): TSparseListItem;
  var
    i: Integer;
    idx: Integer;
  begin
    if NOT Find(aKey, idx) then
      for i := 0 to Pred(Count) do    // TODO: Can we do this more efficiently with an alternate "Find()" (binary search)
        if Keys[i] > aKey then
        begin
          idx := i - 1;
          BREAK;
        end;

    if idx > -1 then
      result := ItemByIndex[idx]
    else
      result := NIL;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.Get(const aKey: Int64;
                                 var   aItem): Boolean;
  var
    item: TSparseListItem absolute aItem;
    idx: Integer;
  begin
    result := Find(aKey, idx);

    if result then
      item := ItemByIndex[idx]
    else
      item := NIL;
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.Get(const aKey: Int64): TSparseListItem;
  var
    idx: Integer;
  begin
    if Find(aKey, idx) then
      result := ItemByIndex[idx]
    else if AutoInsert then
      result := Add(aKey)
    else
      raise EListError.CreateFmt('No item in the list with key 0x%16x', [aKey]);
  end;



  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.Add(const aKey: Int64): TSparseListItem;
  var
    idx: Integer;
  begin
    if Find(aKey, idx) then
      raise EListError.CreateFmt('An item already exists in the list with key 0x%16x', [aKey]);

    result := fItemClass.Create;
    result.fKey := aKey;

    fItems.Insert(idx, result);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TCustomSparseList.Clear;
  begin
    fItems.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TCustomSparseList.Delete(const aKey: Int64);
  var
    idx: Integer;
  begin
    if Find(aKey, idx) then
      fItems.Delete(idx);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.get_Item(const aKey: Int64): TSparseListItem;
  begin
    result := Get(aKey);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.get_ItemByIndex(const aIndex: Integer): TSparseListItem;
  begin
    result := TSparseListItem(fItems[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TCustomSparseList.get_Key(const aIndex: Integer): Int64;
  begin
    result := TSparseListItem(fItems[aIndex]).Key;
  end;







{ TSparseList ------------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSparseList.DoGetItemClass(var aClass: TSparseListItemClass);
  begin
    aClass := TPointerListItem;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSparseList.Add(const aKey: Int64;
                            const aData: Pointer);
  begin
    TPointerListItem(inherited Add(aKey)).Value := aData;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TSparseList.get_Item(const aKey: Int64): Pointer;
  begin
    result := TPointerListItem(Get(aKey)).Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSparseList.set_Item(const aKey: Int64;
                                 const aValue: Pointer);
  begin
    TPointerListItem(Get(aKey)).Value := aValue;
  end;














{ TSparseStringList ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSparseStringList.DoGetItemClass(var aClass: TSparseListItemClass);
  begin
    aClass := TStringListItem;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSparseStringList.Add(const aKey: Int64;
                                  const aValue: UnicodeString);
  begin
    TStringListItem(inherited Add(aKey)).Value := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TSparseStringList.get_Item(const aKey: Int64): UnicodeString;
  begin
    result := TStringListItem(Get(aKey)).Value;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TSparseStringList.set_Item(const aKey: Int64;
                                       const aValue: UnicodeString);
  begin
    TStringListItem(Get(aKey)).Value := aValue;
  end;







end.
