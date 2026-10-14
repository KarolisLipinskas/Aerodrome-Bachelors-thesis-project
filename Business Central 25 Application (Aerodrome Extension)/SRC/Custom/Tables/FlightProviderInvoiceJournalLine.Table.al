table 50230 "Flight Prov. Inv. Journal Line"
{

    fields
    {
        field(10; "Posted No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isFlightProvider = CONST(true));
        }
        field(30; "Start Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(40; "End Date"; Date)
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Flight Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(60; "CheckedIn Passenger Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Boarded Passenger Count"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Price For CheckedIn"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Price For Boarded"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(100; "Total Price"; Decimal)
        {
            DataClassification = ToBeClassified;
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

