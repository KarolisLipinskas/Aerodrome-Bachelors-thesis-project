table 50240 "Flight Prov. Inv. Ledger Entry"
{

    fields
    {
        field(10; "Posted No."; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(20; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Customer WHERE(isFlightProvider = CONST(true));
        }
        field(30; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(40; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50; "Flight Count"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(60; "CheckedIn Passenger Count"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(70; "Boarded Passenger Count"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(80; "Price For CheckedIn"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(90; "Price For Boarded"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(100; "Total Price"; Decimal)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Posted No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

