
  unit Deltics.Uri;

interface

  uses
    SysUtils,
    Deltics.Strings;

  type
    TUri = class
    private
      fScheme: String;
      fUserInfo: String;
      fPassword: String;
      fHost: String;
      fPort: Integer;
      fPath: String;
      fQuery: String;
      fFragment: String;
      function get_AsString: String;
      function get_Authority: String;
      procedure set_AsString(const aValue: String);
    public
      constructor Create; overload;
      constructor Create(const aUri: String); overload;
      property Scheme: String read fScheme write fScheme;
      property UserInfo: String read fUserInfo write fUserInfo;
      property Password: String read fPassword write fPassword;         // For completeness only.  NOT SUPPORTED.
      property Host: String read fHost write fHost;
      property Port: Integer read fPort write fPort;
      property Path: String read fPath write fPath;
      property Query: String read fQuery write fQuery;
      property Fragment: String read fFragment write fFragment;
      property Authority: String read get_Authority;
      property AsString: String read get_AsString write set_AsString;
    end;


implementation

  uses
    Deltics.StringTemplates;


{ TUri }

  constructor TUri.Create(const aUri: String);
  begin
    inherited Create;

    AsString := aUri;
  end;


  function TUri.get_Authority: String;
  begin
    result := '';

    if fUserInfo <> '' then
      result := result + fUserInfo + '@';

    if fHost <> '' then
      result := result + fHost;

    if fPort <> -1 then
      result := result + ':' + IntToStr(fPort);
  end;


  procedure TUri.set_AsString(const aValue: String);
  var
    uri: String;
    vars: TStringList;
  begin
    fScheme   := '';
    fUserInfo := '';
    fHost     := '';
    fPort     := -1;
    fPath     := '';
    fQuery    := '';
    fFragment := '';

    uri := aValue;

    if ((uri[2] = ':') and (uri[3] = '\')) then
      uri := 'file:///' + STR.ReplaceAll(aValue, '\', '/');

    vars := TStringList.Create;
    try
      if TStringTemplate.Match([
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]?[query]#[fragment]',
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]?[query]',
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]#[fragment]',
                                 '[scheme]://[userinfo]@[host]:[port:int]/[path]',
                                 '[scheme]://[userinfo]@[host]/[path]?[query]#[fragment]',
                                 '[scheme]://[userinfo]@[host]/[path]?[query]',
                                 '[scheme]://[userinfo]@[host]/[path]?#[fragment]',
                                 '[scheme]://[userinfo]@[host]/[path]',
                                 '[scheme]://[host]:[port:int]/[path]?[query]#[fragment]',
                                 '[scheme]://[host]:[port:int]/[path]?[query]',
                                 '[scheme]://[host]:[port:int]/[path]?#[fragment]',
                                 '[scheme]://[host]:[port:int]/[path]',
                                 '[scheme]:///[path]?[query]#[fragment]',
                                 '[scheme]:///[path]?[query]',
                                 '[scheme]:///[path]?#[fragment]',
                                 '[scheme]:///[path]',
                                 '[scheme]://[host]/[path]?[query]#[fragment]',
                                 '[scheme]://[host]/[path]?[query]',
                                 '[scheme]://[host]/[path]?#[fragment]',
                                 '[scheme]://[host]/[path]',
                                 '[scheme]://[host]/',
                                 '[scheme]://[host]'
                               ], uri, vars) then
      begin
        if vars.ContainsName('scheme')    then fScheme    := vars.Values['scheme'];
        if vars.ContainsName('userinfo')  then fUserInfo  := vars.Values['userinfo'];
        if vars.ContainsName('host')      then fHost      := vars.Values['host'];
        if vars.ContainsName('port')      then fPort      := STR.AsInteger(vars.Values['port']);
        if vars.ContainsName('path')      then fPath      := vars.Values['path'];
        if vars.ContainsName('query')     then fQuery     := vars.Values['query'];
        if vars.ContainsName('fragment')  then fFragment  := vars.Values['fragment'];
      end;

    finally
      vars.Free;
    end;
  end;


  constructor TUri.Create;
  begin
    inherited Create;

    fPort := -1;
  end;


  function TUri.get_AsString: String;
  var
    auth: String;
  begin
    auth    := Authority;
    result  := fScheme + '://';

    if auth <> '' then
      result := result + auth;

    if fPath <> '' then
      result := result + '/' + fPath;

    if fQuery <> '' then
      result := result + '?' + fQuery;

    if fFragment <> '' then
      result := result + '#' + fFragment;
  end;


end.
