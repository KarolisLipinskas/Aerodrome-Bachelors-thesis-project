table 50100 "Boarding Journal Line"
{

    fields
    {
        field(10; "Posted Boarding No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                PostedBoarding: Record "Posted Passenger Boarding";
            begin
                PostedBoarding.SetRange("Registration No.", "Registration No.");
                if PostedBoarding.FindFirst then begin
                    "Seat Code" := PostedBoarding."Seat Code";
                    "Flight No." := PostedBoarding."Flight No.";
                    "Flight Date" := PostedBoarding."Flight Date";
                    "Flight Time" := PostedBoarding."Flight Time";
                    "Ticket No." := PostedBoarding."Ticket No.";
                    Name := PostedBoarding.Name;
                    Surname := PostedBoarding.Surname;
                    "Personal Code" := PostedBoarding."Personal Code";
                    "Is Present" := PostedBoarding."Is Present";
                    "Boarding Time" := PostedBoarding."Boarding Time";
                end;
            end;
        }
        field(21; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight No.";
        }
        field(31; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight Date" WHERE ("Flight No." = FIELD ("Flight No."));
        }
        field(32; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Departure Time" WHERE ("Flight No." = FIELD ("Flight No."),
                                                           "Flight Date" = FIELD ("Flight Date"));
        }
        field(40; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(60; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(70; "Personal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(80; "Is Present"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Boarding Time"; Time)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Posted Boarding No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

