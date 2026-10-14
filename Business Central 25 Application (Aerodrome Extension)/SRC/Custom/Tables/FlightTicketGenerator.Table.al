table 50120 "Flight Ticket Generator"
{

    fields
    {
        field(10; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(40; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isFlightProvider = CONST(true));
        }
        field(50; PrefixLetter; Text[1])
        {
            DataClassification = ToBeClassified;
        }
        field(55; "Seat Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "Start No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "End No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Current No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Flight No.", "Flight Date", "Flight Time")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        FlightProvider: Record Customer;
        TicketGenTable: Record "Flight Ticket Generator";
        Flight: Record Flight;
    begin
        if not FlightProvider.Get(Customer) then
            exit;

        PrefixLetter := CopyStr(FlightProvider."Flight Provider Code", 1, 1);

        //finds the highest End No. with the first letter of Arline Code
        TicketGenTable.SetRange(PrefixLetter, PrefixLetter);
        TicketGenTable.SetCurrentKey("End No.");
        if TicketGenTable.FindLast then begin
            "Start No." := TicketGenTable."End No." + 1;
            "End No." := "Start No." + "Seat Count" - 1;
            "Current No." := "Start No.";
        end else begin
            "Start No." := 1;
            "End No." := "Start No." + "Seat Count" - 1;
            "Current No." := "Start No.";
        end;
    end;
}

