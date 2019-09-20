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

{$ifdef ddx_classes}
  {$debuginfo ON}
{$endif}

  unit Deltics.Classes;


interface

  uses
  { vcl:}
    Classes,
    Contnrs,
    Types,
  { deltics: }
    Deltics.MultiCast;


  type
    IAsObject       = interface;
    IInterfaceList  = Classes.IInterfaceList;

    TList           = Classes.TList;
    TInterfaceList  = Classes.TInterfaceList;
    TObjectList     = Contnrs.TObjectList;
    TStream         = Classes.TStream;

    TListDuplicatesOption = (doAllow, doIgnore, doError);

    PUnknown = ^IUnknown;


    TNamedNotifyEvent = procedure(const aSender: TObject; const aName: String) of object;


    TInterfacedObject = class(TObject, IUnknown,
                                       IOn_Destroy)
      // IUnknown
      protected
        function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;

      // IOn_Destroy
      private
        fOn_Destroy: IOn_Destroy;
        function get_On_Destroy: IOn_Destroy;
      public
        property On_Destroy: IOn_Destroy read get_On_Destroy implements IOn_Destroy;
    end;


    TInterfacedPersistent = class(TPersistent, IUnknown,
                                               IOn_Destroy)
      // IUnknown
      protected
        function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;

      // IOn_Destroy
      private
        fOn_Destroy: IOn_Destroy;
        function get_On_Destroy: IOn_Destroy;
      public
        property On_Destroy: IOn_Destroy read get_On_Destroy implements IOn_Destroy;
    end;


    TComInterfacedObject = class(TObject, IUnknown,
                                          IOn_Destroy)
      // IOn_Destroy
      private
        fDestroying: Boolean;
        fRefCount: Integer;
        fOn_Destroy: IOn_Destroy;
        function get_On_Destroy: IOn_Destroy;

      public // IUnknown
        function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;

      public
        class function NewInstance: TObject; override;
        procedure AfterConstruction; override;
        procedure BeforeDestruction; override;
        property RefCount: Integer read fRefCount;
        property On_Destroy: IOn_Destroy read get_On_Destroy implements IOn_Destroy;
    end;


    TComInterfacedPersistent = class(Classes.TInterfacedPersistent, IOn_Destroy)
      // IOn_Destroy
      private
        fOn_Destroy: IOn_Destroy;
        function get_On_Destroy: IOn_Destroy;
      public
        property On_Destroy: IOn_Destroy read get_On_Destroy implements IOn_Destroy;
    end;


    TFlexInterfacedObject = class(TObject, IUnknown,
                                           IOn_Destroy)
      private
        fRefCount: Integer;
        fRefCountDisabled: Boolean;
      public
        procedure AfterConstruction; override;
        procedure BeforeDestruction; override;
        class function NewInstance: TObject; override;

      public
        procedure DisableRefCount;
        property RefCount: Integer read fRefCount;

      // IUnknown
      protected
        function QueryInterface(const aIID: TGUID; out aObj): HResult; stdcall;
        function _AddRef: Integer; stdcall;
        function _Release: Integer; stdcall;

      // IOn_Destroy
      private
        fOn_Destroy: IOn_Destroy;
        function get_On_Destroy: IOn_Destroy;
      public
        property On_Destroy: IOn_Destroy read get_On_Destroy implements IOn_Destroy;
    end;


    TTypedList = class(TInterfacedObject)
    private
      fList: TList;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): TObject;
      function get_OwnsObjects: Boolean;
      procedure set_Item(const aIndex: Integer; const aValue: TObject);
    protected
      procedure Add(const aItem: TObject);
      function IndexOf(const aItem: TObject): Integer;
      procedure Insert(const aIndex: Integer; const aItem: TObject);
      procedure Remove(const aItem: TObject);
      property Items[const aIndex: Integer]: TObject read get_Item write set_Item;
      property List: TList read fList;
    public
      constructor Create(const aOwnsObjects: Boolean = FALSE);
      destructor Destroy; override;
      procedure Clear;
      procedure Delete(const aIndex: Integer);
      property Count: Integer read get_Count;
      property OwnsObjects: Boolean read get_OwnsObjects;
    end;


    TInterface = class(TObject, IUnknown)
    private
      fRef: IUnknown;
    protected // IUnknown
      {
        IUnknown is delegated to the contained reference using "implements"
         ALL methods of IUnknown are delegated to the fRef, meaning that
         TInterface does not need to worry about being reference counted
         itself (it won't be).
      }
      property Ref: IUnknown read fRef implements IUnknown;
    public
      constructor Create(const aRef: IUnknown);
      function IsEqual(const aOther: IUnknown): Boolean;
    end;


    TWeakInterface = class(TObject, IUnknown)
    private
      fRef: Pointer;
      function get_Ref: IUnknown;
    protected // IUnknown
      {
        IUnknown is delegated to the contained reference using "implements"
         ALL methods of IUnknown are delegated to the fRef, meaning that
         TWeakInterface does not need to worry about being reference counted
         itself (it won't be).
      }
      property Ref: IUnknown read get_Ref implements IUnknown;
    public
      constructor Create(const aRef: IUnknown);
      procedure Update(const aRef: IUnknown);
    end;


    TInterfaceDelegate = class(TObject, IUnknown)
    protected
      fOwner: TObject;
      fRefCount: Integer;
      fRefCountEnabled: Boolean;
      function QueryInterface(const aIID: TGUID; out aObj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
    public
      constructor Create(const aOwner: TObject);
      procedure DisableRefCount;
      procedure EnableRefCount;
    end;


    TGUIDList = class
    private
      fCount: Integer;
      fIsSorted: Boolean;
      fItems: array of TGUID;
      fSorted: Boolean;
      function get_Capacity: Integer;
      function get_Item(const aIndex: Integer): TGUID;
      procedure set_Capacity(const aValue: Integer);
      procedure set_Item(const aIndex: Integer; const aValue: TGUID);
      procedure set_Sorted(const aValue: Boolean);
    protected
      procedure IncreaseCapacity;
    public
      procedure Add(const aGUID: TGUID);
      procedure Clear;
      function Contains(const aGUID: TGUID): Boolean;
      procedure Delete(const aGUID: TGUID);
      function IndexOf(const aGUID: TGUID): Integer;
      procedure Sort;
      property Capacity: Integer read get_Capacity write set_Capacity;
      property Count: Integer read fCount;
      property Items[const aIndex: Integer]: TGUID read get_Item write set_Item; default;
      property Sorted: Boolean read fSorted write set_Sorted;
    end;


    TListAddMethod = function(aValue: Integer): Integer of object;

    {$WARNINGS OFF}
    TIntegerList = class(TList)
    private
      fAddMethod: TListAddMethod;
      fDuplicates: TListDuplicatesOption;
      function get_IsEmpty: Boolean;
      function get_Item(const aIndex: Integer): Integer;
      procedure set_Duplicates(const aValue: TListDuplicatesOption);
      procedure set_Item(const aIndex: Integer; const aValue: Integer);
      function AddAllowingDuplicates(aValue: Integer): Integer;
      function AddIgnoringDuplicates(aValue: Integer): Integer;
      function AddRejectingDuplicates(aValue: Integer): Integer;
    public
      constructor Create;
      function Contains(const aValue: Integer): Boolean;
      procedure Remove(const aValue: Integer);
      function IndexOf(const aValue: Integer): Integer;
      property Add: TListAddMethod read fAddMethod;
      property Duplicates: TListDuplicatesOption read fDuplicates write set_Duplicates;
      property IsEmpty: Boolean read get_IsEmpty;
      property Items[const aIndex: Integer]: Integer read get_Item write set_Item; default;
    end;
    {$ifNdef NoWarnings}
      {$WARNINGS ON}
    {$endif}


    TInterfacedObjectList = class(TComInterfacedObject)
    private
      fItems: TObjectList;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): IUnknown;
    public
      constructor Create;
      destructor Destroy; override;
      function Add(const aObject: TObject): Integer;
      procedure Delete(const aIndex: Integer);
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: IUnknown read get_Item; default;
    end;


    IList = interface
    ['{59FF3E4A-6D82-41F5-A772-4BBD449DB367}']
      function get_Count: Integer;
      procedure Clear;
      procedure Delete(const aIndex: Integer); overload;
      property Count: Integer read get_Count;
    end;


(*
    IObjectList = interface(IList)
    ['{4A82702E-8278-4B58-AB8F-042708809797}']
      function get_Item(const aIndex: Integer): TObject;
      function Add(const aObject: TObject): Integer;
      function Contains(const aObject: TObject): Boolean;
      procedure Delete(const aObject: TObject); overload;
      procedure Insert(const aIndex: Integer; const aObject: TObject);
      property Count: Integer read get_Count;
      property Items[const aIndex: Integer]: TObject read get_Item; default;
    end;


    TComInterfacedObjectList = class(TComInterfacedObject, IObjectList)
    private
      fItems: TObjectList;
      function get_Count: Integer;
      function get_Item(const aIndex: Integer): TObject;
      function Add(const aObject: TObject): Integer;
      function Contains(const aObject: TObject): Boolean;
      procedure Delete(const aIndex: Integer); overload;
      procedure Delete(const aObject: TObject); overload;
      procedure Insert(const aIndex: Integer; const aObject: TObject);
    public
      constructor Create(const aOwnsObject: Boolean = FALSE);
      destructor Destroy;
    end;
*)

    IAsObject = interface
    ['{668F826E-A31B-4CB3-B5F9-BF91967A5716}']
      function get_AsObject: TObject;
      property AsObject: TObject read get_AsObject;
    end;

    TNotifyingCollection = class;

    TCollectionItemEvent = procedure(const aSender: TNotifyingCollection; const aItem: TCollectionItem) of object;

    TNotifyingCollection = class(TOwnedCollection)
    private
      fOnChanged: TNotifyEvent;
      fOnItemAdded: TCollectionItemEvent;
      fOnItemDeleted: TCollectionItemEvent;
    protected
      constructor Create(const aOwner: TPersistent; const aItemClass: TCollectionItemClass; const aOnChange: TNotifyEvent); reintroduce; overload;
      constructor Create(const aOwner: TPersistent; const aItemClass: TCollectionItemClass; const aOnAdd, aOnDelete: TCollectionItemEvent); reintroduce; overload;
      procedure DoChanged;
      procedure DoItemAdded(const aItem: TCollectionItem); virtual;
      procedure DoItemDeleted(const aItem: TCollectionItem); virtual;
      procedure Notify(aItem: TCollectionItem; aAction: TCollectionNotification); override;
    end;


    function ImplementationExists(const aUnknown: IUnknown; const aIID: TGuid): Boolean;




//    TList = class(Classes.TList)
//    public
//      constructor Create(const aSource: Classes.TList; const aFilter: TFilterFn); overload;
//    end;



implementation

  uses
  { vcl: }
    SysUtils,
    Windows,
    Deltics.GUIDs;


{ TInterfacedObject ------------------------------------------------------------------------------ }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObject.QueryInterface(const IID: TGUID;
                                            out Obj): HResult;
  begin
    if GetInterface(IID, Obj) then
      Result := 0
    else
      Result := E_NOINTERFACE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObject._AddRef: Integer;
  begin
    result := 1; { NO-OP }
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObject._Release: Integer;
  begin
    result := 1; { NO-OP }
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObject.get_On_Destroy: IOn_Destroy;
  // Create the multi-cast event on demand, since we cannot
  //  guarantee any particular constructor call order and there
  //  may be dependencies created during construction (e.g. if
  //  multi-cast event handlers are added before/after any call
  //  to a particular inherited constructor etc etc)
  begin
    if NOT Assigned(fOn_Destroy) then
      fOn_Destroy := TOnDestroy.Create(self);

    result := fOn_Destroy;
  end;







{ TInterfacedPersistent -------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedPersistent.QueryInterface(const IID: TGUID;
                                                out Obj): HResult;
  begin
    if GetInterface(IID, Obj) then
      Result := 0
    else
      Result := E_NOINTERFACE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedPersistent._AddRef: Integer;
  begin
    result := 1; { NO-OP }
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedPersistent._Release: Integer;
  begin
    result := 1; { NO-OP }
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedPersistent.get_On_Destroy: IOn_Destroy;
  // Create the multi-cast event on demand, since we cannot
  //  guarantee any particular constructor call order and there
  //  may be dependencies created during construction (e.g. if
  //  multi-cast event handlers are added before/after any call
  //  to a particular inherited constructor etc etc)
  begin
    if NOT Assigned(fOn_Destroy) then
      fOn_Destroy := TOnDestroy.Create(self);

    result := fOn_Destroy;
  end;








{ TComInterfacedObject --------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TComInterfacedObject._AddRef: Integer;
  begin
    if NOT (fDestroying) then
      result := InterlockedIncrement(fRefCount)
    else
      result := 1;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TComInterfacedObject._Release: Integer;
  begin
    if NOT (fDestroying) then
    begin
      result := InterlockedDecrement(fRefCount);
      if (result = 0) then
        Destroy;
    end
    else
      result := 1;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TComInterfacedObject.AfterConstruction;
  begin
    inherited;
    InterlockedDecrement(fRefCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TComInterfacedObject.BeforeDestruction;
  begin
    fDestroying := TRUE;
    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TComInterfacedObject.get_On_Destroy: IOn_Destroy;
  begin
    if NOT Assigned(fOn_Destroy) then
      fOn_Destroy := TOnDestroy.Create(self);

    result := fOn_Destroy;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TComInterfacedObject.NewInstance: TObject;
  begin
    result := inherited NewInstance;
    InterlockedIncrement(TComInterfacedObject(result).fRefCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TComInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
  begin
    if GetInterface(IID, Obj) then
      result := 0
    else
      result := E_NOINTERFACE;
  end;







{ TComInterfacedPersistent ----------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TComInterfacedPersistent.get_On_Destroy: IOn_Destroy;
  begin
    if NOT Assigned(fOn_Destroy) then
      fOn_Destroy := TOnDestroy.Create(self);

    result := fOn_Destroy;
  end;




{ TTypedList ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TTypedList.Create(const aOwnsObjects: Boolean);
  begin
    inherited Create;

    if aOwnsObjects then
      fList := TObjectList.Create(TRUE)
    else
      fList := TList.Create;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TTypedList.Destroy;
  begin
    FreeAndNIL(fList);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTypedList.get_Count: Integer;
  begin
    result := fList.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTypedList.get_Item(const aIndex: Integer): TObject;
  begin
    result := TObject(fList[aIndex]);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTypedList.get_OwnsObjects: Boolean;
  begin
    result := (fList is TObjectList);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TTypedList.set_Item(const aIndex: Integer; const aValue: TObject);
  begin
    fList[aIndex] := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TTypedList.Add(const aItem: TObject);
  begin
    fList.Add(aItem)
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TTypedList.Clear;
  begin
    fList.Clear;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TTypedList.Delete(const aIndex: Integer);
  begin
    fList.Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TTypedList.IndexOf(const aItem: TObject): Integer;
  begin
    result := fList.IndexOf(aItem);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TTypedList.Insert(const aIndex: Integer; const aItem: TObject);
  begin
    fList.Insert(aIndex, aItem);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TTypedList.Remove(const aItem: TObject);
  begin
    fList.Remove(aItem);
  end;







{ TInterface ------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TInterface.Create(const aRef: IInterface);
  begin
    inherited Create;

    fRef := aRef as IUnknown;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterface.IsEqual(const aOther: IInterface): Boolean;
  begin
    if Assigned(self) then
      result := (aOther as IUnknown) = fRef
    else
      result := (aOther = NIL);
  end;








{ TWeakInterface --------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TWeakInterface.Create(const aRef: IInterface);
  begin
    inherited Create;

    fRef := Pointer(aRef);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TWeakInterface.get_Ref: IUnknown;
  begin
    result := IUnknown(fRef);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TWeakInterface.Update(const aRef: IInterface);
  begin
    fRef := Pointer(aRef);
  end;








{ TInterfaceDelegate ----------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TInterfaceDelegate.Create(const aOwner: TObject);
  begin
    inherited Create;

    fOwner := aOwner;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TInterfaceDelegate.DisableRefCount;
  begin
    fRefCountEnabled := FALSE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TInterfaceDelegate.EnableRefCount;
  begin
    fRefCountEnabled := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfaceDelegate.QueryInterface(const aIID: TGUID; out aObj): HResult;
  const
    SUCCESS = 0;
  begin
    if fOwner.GetInterface(aIID, aObj) then
      result := SUCCESS
    else
      result := E_NOINTERFACE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfaceDelegate._AddRef: Integer;
  begin
    result := InterlockedIncrement(fRefCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfaceDelegate._Release: Integer;
  begin
    result := InterlockedDecrement(fRefCount);

    if fRefCountEnabled and (fRefCount = 0) then
      fOwner.Free;
  end;







{ TFlexInterfacedObject - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TFlexInterfacedObject.AfterConstruction;
  begin
    if fRefCountDisabled then
      EXIT;

    // Release the constructor's implicit refcount
    InterlockedDecrement(fRefCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TFlexInterfacedObject.BeforeDestruction;
  begin
    if NOT fRefCountDisabled and (fRefCount <> 0) then
      System.Error(reInvalidPtr);

    DisableRefCount;  // To avoid problems if we reference ourselves (or are
                      //  referenced by others) using an interface during
                      //  execution of the destructor chain
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TFlexInterfacedObject.DisableRefCount;
  begin
    fRefCountDisabled := TRUE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TFlexInterfacedObject.get_On_Destroy: IOn_Destroy;
  begin
    if NOT Assigned(fOn_Destroy) then
      fOn_Destroy := TOnDestroy.Create(self);

    result := fOn_Destroy;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  class function TFlexInterfacedObject.NewInstance: TObject;
  begin
    result := inherited NewInstance;
    TFlexInterfacedObject(result).fRefCount := 1;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TFlexInterfacedObject.QueryInterface(const aIID: TGUID; out aObj): HResult;
  begin
    if GetInterface(aIID, aObj) then
      result := 0
    else
      result := E_NOINTERFACE;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TFlexInterfacedObject._AddRef: Integer;
  begin
    if fRefCountDisabled then
      result := 1
    else
      result := InterlockedIncrement(fRefCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TFlexInterfacedObject._Release: Integer;
  begin
    if fRefCountDisabled then
      result := 1
    else
    begin
      result := InterlockedDecrement(fRefCount);
      if (result = 0) then
        Destroy;
    end;
  end;







{ TGUIDList -------------------------------------------------------------------------------------- }

  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.Add(const aGUID: TGUID);
  begin
    if (fCount = Capacity) then
      IncreaseCapacity;

    fItems[fCount] := aGUID;

    Inc(fCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.Clear;
  begin
    fCount := 0;
    SetLength(fItems, 0);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TGUIDList.Contains(const aGUID: TGUID): Boolean;
  begin
    result := (IndexOf(aGUID) <> -1);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.Delete(const aGUID: TGUID);
  var
    i: Integer;
  begin
    i := IndexOf(aGUID);

    if i = -1 then
      EXIT;

    while (i < Pred(Count)) do
      fItems[i] := fItems[i + 1];

    Dec(fCount);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TGUIDList.get_Capacity: Integer;
  begin
    result := Length(fItems);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TGUIDList.get_Item(const aIndex: Integer): TGUID;
  begin
    result := fItems[aIndex];
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.IncreaseCapacity;
  var
    i: Integer;
  begin
    case Capacity of
      0     : i := 4;
      1..64 : i := Capacity * 2
    else
      i := Capacity div 4;
    end;

    SetLength(fItems, i);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TGUIDList.IndexOf(const aGUID: TGUID): Integer;
  begin
    if fIsSorted then
    begin
      // TODO: Binary search algorithm
    end
    else
      for result := 0 to Pred(Count) do
        if GUIDs.AreEqual(aGUID, fItems[result]) then
          EXIT;

    result := -1;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.set_Capacity(const aValue: Integer);
  begin
    SetLength(fItems, aValue);
    if (Capacity < fCount) then
      fCount := Capacity;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.set_Item(const aIndex: Integer; const aValue: TGUID);
  begin
    fItems[aIndex] := aValue;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.set_Sorted(const aValue: Boolean);
  begin
    if fSorted = aValue then
      EXIT;

    fSorted := aValue;

    if fSorted and NOT fIsSorted then
      Sort;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TGUIDList.Sort;
  begin
    ASSERT(FALSE, 'Oops, hasn''t been implemented yet!');

    fIsSorted := TRUE;
  end;











{ TIntegerList }

  function TIntegerList.AddAllowingDuplicates(aValue: Integer): Integer;
  begin
    result := inherited Add(Pointer(aValue));
  end;


  function TIntegerList.AddIgnoringDuplicates(aValue: Integer): Integer;
  begin
    result := IndexOf(aValue);
    if result = -1 then
      result := inherited Add(Pointer(aValue));
  end;


  function TIntegerList.AddRejectingDuplicates(aValue: Integer): Integer;
  begin
    result := IndexOf(aValue);
    if result = -1 then
      result := inherited Add(Pointer(aValue))
    else
      raise EListError.CreateFmt('List already contains value (%d)', [aValue]);
  end;


  function TIntegerList.Contains(const aValue: Integer): Boolean;
  begin
    result := (inherited IndexOf(Pointer(aValue))) <> -1;
  end;


  constructor TIntegerList.Create;
  begin
    inherited Create;

    Duplicates := doAllow;
  end;


  procedure TIntegerList.Remove(const aValue: Integer);
  begin
    inherited Remove(Pointer(aValue));
  end;


  function TIntegerList.get_IsEmpty: Boolean;
  begin
    result := (Count = 0);
  end;


  function TIntegerList.get_Item(const aIndex: Integer): Integer;
  begin
    result := Integer(inherited Items[aIndex]);
  end;


  function TIntegerList.IndexOf(const aValue: Integer): Integer;
  begin
    result := inherited IndexOf(Pointer(aValue));
  end;


  procedure TIntegerList.set_Duplicates(const aValue: TListDuplicatesOption);
  begin
    fDuplicates := aValue;

    case Duplicates of
      doAllow   : fAddMethod := AddAllowingDuplicates;
      doError   : fAddMethod := AddRejectingDuplicates;
      doIgnore  : fAddMethod := AddIgnoringDuplicates;
    end;
  end;


  procedure TIntegerList.set_Item(const aIndex, aValue: Integer);
  var
    idx: Integer;
  begin
    case Duplicates of
      doAllow   : inherited Items[aIndex] := Pointer(aValue);

      doError   : begin
                    idx := IndexOf(aValue);
                    if idx = -1 then
                      inherited Items[aIndex] := Pointer(aValue)
                    else
                      raise EListError.CreateFmt('List already contains value (%d)', [aValue]);
                  end;

      doIgnore  : begin
                    idx := IndexOf(aValue);
                    if idx = -1 then
                      inherited Items[aIndex] := Pointer(aValue)
                    else
                      Delete(aIndex);
                  end;
    end;
  end;












{ TInterfacedObjectList -------------------------------------------------------------------------- }

  type
    TInterfacedObjectListItem = class
      ItemObject: TObject;
      ItemInterface: IUnknown;
    end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  constructor TInterfacedObjectList.Create;
  begin
    inherited Create;

    fItems := TObjectList.Create(TRUE);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  destructor TInterfacedObjectList.Destroy;
  begin
    FreeAndNIL(fItems);

    inherited;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObjectList.Add(const aObject: TObject): Integer;
  var
    item: TInterfacedObjectListItem;
  begin
    item := TInterfacedObjectListItem.Create;
    item.ItemObject := aObject;

    if Assigned(aObject) then
      aObject.GetInterface(IUnknown, item.ItemInterface);

    result := fItems.Add(item);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  procedure TInterfacedObjectList.Delete(const aIndex: Integer);
  begin
    fItems.Delete(aIndex);
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObjectList.get_Count: Integer;
  begin
    result := fItems.Count;
  end;


  { - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }
  function TInterfacedObjectList.get_Item(const aIndex: Integer): IUnknown;
  begin
    result := TInterfacedObjectListItem(fItems[aIndex]).ItemInterface;
  end;







{ TNotifyingCollection --------------------------------------------------------------------------- }

  constructor TNotifyingCollection.Create(const aOwner: TPersistent;
                                          const aItemClass: TCollectionItemClass;
                                          const aOnChange: TNotifyEvent);
  begin
    inherited Create(aOwner, aItemClass);

    fOnChanged  := aOnChange;
  end;


  constructor TNotifyingCollection.Create(const aOwner: TPersistent;
                                          const aItemClass: TCollectionItemClass;
                                          const aOnAdd: TCollectionItemEvent;
                                          const aOnDelete: TCollectionItemEvent);
  begin
    inherited Create(aOwner, aItemClass);

    fOnItemAdded    := aOnAdd;
    fOnItemDeleted  := aOnDelete;
  end;


  procedure TNotifyingCollection.DoChanged;
  begin
    if Assigned(fOnChanged) then
      fOnChanged(self);
  end;


  procedure TNotifyingCollection.DoItemAdded(const aItem: TCollectionItem);
  begin
    if Assigned(fOnItemAdded) then
      fOnItemAdded(self, aItem);
  end;


  procedure TNotifyingCollection.DoItemDeleted(const aItem: TCollectionItem);
  begin
    if Assigned(fOnItemDeleted) then
      fOnItemDeleted(self, aItem);
  end;


  procedure TNotifyingCollection.Notify(aItem: TCollectionItem; aAction: TCollectionNotification);
  {$ifdef DELPHIXE2__}
    const
      cnAdded     = TCollectionNotification.cnAdded;
      cnDeleting  = TCollectionNotification.cnAdded;
  {$endif}
  begin
    inherited;

    case aAction of
      cnAdded:
      begin
        DoItemAdded(aItem);
        DoChanged;
      end;

      cnDeleting:
      begin
        DoItemDeleted(aItem);
        DoChanged;
      end;
    end;
  end;











  function ImplementationExists(const aUnknown: IUnknown;
                                const aIID: TGuid): Boolean;
  var
    notUsed: IUnknown;
  begin
    result := aUnknown.QueryInterface(aIID, notUsed) = S_OK;
  end;




{ TList }

(*
  constructor TList.Create(const aSource: Classes.TList;
                           const aFilter: TFilterFn);
  begin
    inherited Create;
    FilterList(aSource, self, aFilter);
  end;
*)





end.


