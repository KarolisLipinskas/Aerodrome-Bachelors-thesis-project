table 50060 "Check-In Journal Line"
{

    fields
    {
        field(10; "Posted CheckIn No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Person Code"; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Customer.SetRange("Person Code", "Person Code");
                if Customer.FindFirst then begin
                    Name := Customer.Name;
                    Surname := Customer.Surname;
                end;
            end;
        }
        field(22; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(23; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight No." WHERE("Registration Status" = CONST(Completed),
                                                       "Boarding Status" = CONST(Completed));
        }
        field(80; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight Date" WHERE("Flight No." = FIELD("Flight No."),
                                                        "Registration Status" = CONST(Completed));
        }
        field(100; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Departure Time" WHERE("Flight No." = FIELD("Flight No."),
                                                           "Flight Date" = FIELD("Flight Date"),
                                                           "Registration Status" = CONST(Completed));
        }
        field(110; "Registration Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(120; "Posting DateTime"; DateTime)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(130; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Available","In Progress","Checked-In",Missed;
        }
    }

    keys
    {
        key(Key1; "Posted CheckIn No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

