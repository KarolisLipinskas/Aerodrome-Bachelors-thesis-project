table 50160 "Ticket Sale/Purch Journal Line"
{

    fields
    {
        field(10; "Posted No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(15; Type; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Sale,Purchase;
        }
        field(20; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight No.";
        }
        field(30; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight Date" WHERE("Flight No." = FIELD("Flight No."));
        }
        field(40; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Departure Time" WHERE("Flight No." = FIELD("Flight No."),
                                                           "Flight Date" = FIELD("Flight Date"));
        }
        field(50; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(60; Vendor; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor WHERE(isFlightProvider = CONST(true));

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin
                Vend.Get(Vendor);
                "Vendor Name" := Vend.Name;
            end;
        }
        field(70; "Vendor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(80; Customer; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isPerson = CONST(true));

            trigger OnValidate()
            var
                Cust: Record Customer;
            begin
                Cust.Get(Customer);
                "Personal Code" := Cust."Person Code";
                Name := Cust.Name;
                Surname := Cust.Surname;
            end;
        }
        field(90; "Personal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(100; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(110; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(130; "Ticket Price"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(200; "Posting DateTime"; DateTime)
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

