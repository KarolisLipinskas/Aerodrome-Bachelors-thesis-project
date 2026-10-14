codeunit 50000 "Auto Update Logic"
{

    trigger OnRun()
    begin
        Message('opapa');
        UpdateRegistrationStatus();
        UpdateBoardingStatus();
    end;

    var
        IsError: Boolean;

    local procedure TimeUntilFlight(Flight: Record Flight): Integer
    var
        RemainingTimeInSec: Integer;
    begin
        if Flight."Flight Date" = Today then begin
            RemainingTimeInSec := Round((Flight."Departure Time" - Time) / 1000, 1, '>');
            exit(RemainingTimeInSec);
        end;

        if (Flight."Flight Date" = (Today + 1)) and (Flight."Departure Time" < Time) then begin
            RemainingTimeInSec := Round((Time - Flight."Departure Time") / 1000, 1, '>');
            RemainingTimeInSec += 24 * 3600;
            exit(RemainingTimeInSec);
        end;

        if Flight."Flight Date" < Today then
            exit(-1);

        exit(120 * 60);
    end;

    procedure UpdateRegistrationStatus()
    var
        RemainingTimeInSec: Integer;
        Flight: Record Flight;
    begin
        Flight.SetFilter("Registration Status", '< 3');
        if not Flight.FindFirst then
            exit;

        repeat
            if Flight.IsAutomated then begin
                RemainingTimeInSec := TimeUntilFlight(Flight);
                if RemainingTimeInSec < (15 * 60) then begin
                    Flight."Registration Status" := 2;
                    SetStatusForCheckIn(Flight, 3);
                end else if (RemainingTimeInSec < 45 * 60) then begin
                    Flight."Registration Status" := 1;
                    SetStatusForCheckIn(Flight, 1);
                end else begin
                    Flight."Registration Status" := 0;
                    SetStatusForCheckIn(Flight, 0);
                end;

                Flight.Modify;
            end else begin
                if Flight."Registration Status" = 0 then
                    SetStatusForCheckIn(Flight, 0)
                else if Flight."Registration Status" = 1 then
                    SetStatusForCheckIn(Flight, 1)
                else if Flight."Registration Status" = 2 then
                    SetStatusForCheckIn(Flight, 3);
            end;
        until Flight.Next = 0
    end;

    local procedure SetStatusForCheckIn(Flight: Record Flight; Value: Integer)
    var
        CheckIn: Record "Check-In";
    begin
        CheckIn.SetRange("Flight No.", Flight."Flight No.");
        CheckIn.SetRange("Flight Date", Flight."Flight Date");
        CheckIn.SetRange("Flight Time", Flight."Departure Time");
        CheckIn.SetFilter(Status, '<> 2');

        CheckIn.ModifyAll(Status, Value);
    end;

    procedure UpdateBoardingStatus()
    var
        Flight: Record Flight;
        RemainingTimeInSec: Integer;
    begin
        Flight.SetFilter("Registration Status", '= 3');
        Flight.SetFilter(Flight."Boarding Status", '< 3');
        if not Flight.FindFirst then
            exit;

        repeat
            if Flight.IsAutomated then begin
                RemainingTimeInSec := TimeUntilFlight(Flight);
                if RemainingTimeInSec < 0 then begin
                    Flight."Boarding Status" := 2;
                end else
                    if (RemainingTimeInSec < 30 * 60) then begin
                        Flight."Boarding Status" := 1;
                    end else begin
                        Flight."Boarding Status" := 0;
                    end;

                Flight.Modify;
            end;
        until Flight.Next = 0
    end;
}

