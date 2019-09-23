

  unit Deltics.Async;


interface

  uses
    Deltics.Classes,
    Deltics.Threads;


  type
    IAsyncTask = interface
    ['{6E70EF8C-76CB-4BA5-8221-3C93726EB5D4}']
      procedure Await;
      procedure Cancel(aWait: Boolean = FALSE);
    end;

    TSynchronizedMethod = procedure of object;

    TAsyncTask = class(TCOMInterfacedObject, IAsyncTask)
    private
      fCancelled: Boolean;
      fThread: TMotile;
    protected
      procedure Execute; virtual; abstract;
    public
      procedure AfterConstruction; override;

    protected
      procedure Synchronize(aMethod: TSynchronizedMethod);
    public
      property Cancelled: Boolean read fCancelled;

    public // IAsyncTask
      procedure Await;
      procedure Cancel(aWait: Boolean = FALSE);
    end;


implementation

  uses
    Forms,
    SysUtils,
    Windows,
    Deltics.Threads.Synchronize;


  type
    TAsyncTaskThread = class(TMotile)
    private
      fTask: TAsyncTask;
      fTaskInterface: IAsyncTask;
    protected
      procedure Execute; override;
    public
      constructor Create(aTask: TAsyncTask); reintroduce;
    end;



{ TAsyncTaskThread }

  constructor TAsyncTaskThread.Create(aTask: TAsyncTask);
  begin
    // Hold a reference to the Task so that the thread can update
    //  properties on the Task as and when required.
    //
    // We also hold a reference to the IAsyncTask interface.  This
    //  ensures that the Task is retained (ref count > 0) even if
    //  the creator of the task does not itself maintain a reference
    //  to it (fire and forget).

    fTask           := aTask;
    fTaskInterface  := aTask;

    inherited Create(weRunOnce, tpNormal, 2, TRUE, TRUE);
  end;


  procedure TAsyncTaskThread.Execute;
  begin
    try
      try
        fTask.Execute;

      except
        // TODO:
      end;

    finally
      // Now that the task thread has completed, one way or the other
      //  it no longer needs to guarantee the existence of the Task
      //  since it will not now be referred to by the thread, so we can
      //  release the interface reference.  If this is the ONLY interface
      //  reference to the Task then the Task is destroyed at this point.

      fTask           := NIL;
      fTaskInterface  := NIL;
    end;
  end;





{ TAsyncTask }

  procedure TAsyncTask.AfterConstruction;
  begin
    inherited;

    fThread := TAsyncTaskThread.Create(self);
  end;


  procedure TAsyncTask.Await;
  begin
    if InVCLThread then
    begin
      while fThread.Running do
        Application.ProcessMessages;
    end
    else
      fThread.WaitFor;
  end;


  procedure TAsyncTask.Cancel(aWait: Boolean);
  begin
    fCancelled := Assigned(fThread) and fThread.Running;
    if fCancelled and aWait then
      self.Await;
  end;


  procedure TAsyncTask.Synchronize(aMethod: TSynchronizedMethod);
  begin
    if NOT fCancelled then
      Deltics.Threads.Synchronize.Synchronize(aMethod);
  end;







end.
