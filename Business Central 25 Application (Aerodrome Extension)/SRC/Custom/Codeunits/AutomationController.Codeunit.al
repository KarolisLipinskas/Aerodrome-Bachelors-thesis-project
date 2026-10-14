codeunit 50010 "Automation Controller"
{
    SingleInstance = true;

    trigger OnRun()
    begin
    end;

    var
        IsOpen: Boolean;
        IsOpenSubpage: Boolean;
        IsOpenCheckIn: Boolean;

    procedure SetIsOpenOtherPage(newValue: Boolean)
    begin
        IsOpen := newValue;
    end;

    procedure GetIsOpenOtherPage(): Boolean
    begin
        exit(IsOpen);
    end;

    procedure SetIsOpenSubpage(newValue: Boolean)
    begin
        IsOpenSubpage := newValue;
    end;

    procedure GetIsOpenSubpage(): Boolean
    begin
        exit(IsOpenSubpage);
    end;

    procedure SetIsOpenCheckInPage(newValue: Boolean)
    begin
        IsOpenCheckIn := newValue;
    end;

    procedure GetIsOpenCheckInPage(): Boolean
    begin
        exit(IsOpenCheckIn);
    end;
}

