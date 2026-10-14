codeunit 50050 "Passenger Logic"
{

    trigger OnRun()
    begin
    end;

    procedure CustomerToPassenger(PostedSale: Record "Posted Ticket Sale")
    var
        Passenger: Record Passenger;
    begin
        if Passenger.Get(PostedSale."Flight No.", PostedSale."Flight Date", PostedSale."Flight Time", PostedSale."Ticket No.") then
            Error('Passenger with this Ticket No.: %1, Already exist', Passenger."Ticket No.");

        Passenger.Init;
        Passenger."Flight No." := PostedSale."Flight No.";
        Passenger."Flight Date" := PostedSale."Flight Date";
        Passenger."Flight Time" := PostedSale."Flight Time";
        Passenger."Ticket No." := PostedSale."Ticket No.";
        Passenger."Personal Code" := PostedSale."Personal Code";
        Passenger.Name := PostedSale.Name;
        Passenger.Surname := PostedSale.Surname;
        Passenger.Status := 0;
        Passenger.Insert(true);

        PassengerToCheckIn(Passenger);
    end;

    procedure PassengerToCheckIn(Passenger: Record Passenger)
    var
        ChekInList: Record "Check-In";
        Number: Integer;
        LineNo: Integer;
    begin
        ChekInList.SetRange("Flight No.", Passenger."Flight No.");
        ChekInList.SetRange("Flight Date", Passenger."Flight Date");
        ChekInList.SetRange("Flight Time", Passenger."Flight Time");
        ChekInList.SetRange("Ticket No.", Passenger."Ticket No.");
        if ChekInList.FindFirst then
            Error('Passenger with Ticket No.: %1, is already in Check-In List', Passenger."Ticket No.");

        ChekInList.Init;
        ChekInList."Flight No." := Passenger."Flight No.";
        ChekInList."Ticket No." := Passenger."Ticket No.";
        ChekInList."Flight Date" := Passenger."Flight Date";
        ChekInList."Flight Time" := Passenger."Flight Time";
        ChekInList.Name := Passenger.Name;
        ChekInList.Surname := Passenger.Surname;
        ChekInList."Personal Code" := Passenger."Personal Code";
        ChekInList."Registration No." := Passenger."Registration No.";
        ChekInList."Seat Code" := Passenger."Seat Code";

        if Passenger."Registration No." <> '' then
            ChekInList.Status := 2
        else
            ChekInList.Status := 0;

        ChekInList.Insert(true);
    end;
}

