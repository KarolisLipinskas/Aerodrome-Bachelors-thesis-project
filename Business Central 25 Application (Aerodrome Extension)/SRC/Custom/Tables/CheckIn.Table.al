table 50020 "Check-In"
{

    fields
    {
        field(10; "No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Registration No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(30; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight No.";
        }
        field(40; "Ticket No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Flight Date"; Date)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Flight Date";
        }
        field(55; "Flight Time"; Time)
        {
            DataClassification = ToBeClassified;
            TableRelation = Flight."Departure Time";
        }
        field(60; "Registration Time"; Time)
        {
            DataClassification = ToBeClassified;
        }
        field(70; Name; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(80; Surname; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(90; "Personal Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(100; "Seat Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Seat Table"."Seat Code" WHERE("Flight No." = FIELD("Flight No."),
                                                            "Flight Date" = FIELD("Flight Date"),
                                                            "Flight Time" = FIELD("Flight Time"),
                                                            Available = CONST(true));

            trigger OnValidate()
            var
                SeatTable: Record "Seat Table";
            begin
                //IF "Seat Code" = '' THEN
                //  ERROR('Seat code cant be negative');

                if "Seat Code" = '' then begin
                    //Status := 1;
                    //"Registration No." := '';
                    //"Registration Time" := 0T;

                    if "Seat Code" <> xRec."Seat Code" then begin
                        SeatTable.Get(xRec."Flight No.", xRec."Flight Date", xRec."Flight Time", xRec."Seat Code");
                        SeatTable.Available := true;
                        SeatTable.Modify;
                    end;

                    exit;
                end;

                if "Seat Code" <> xRec."Seat Code" then begin
                    if xRec."Seat Code" <> '' then begin
                        SeatTable.Get(xRec."Flight No.", xRec."Flight Date", xRec."Flight Time", xRec."Seat Code");
                        SeatTable.Available := true;
                        SeatTable.Modify;
                    end;

                    SeatTable.Get("Flight No.", "Flight Date", "Flight Time", "Seat Code");
                    SeatTable.Available := false;
                    SeatTable.Modify;
                end;


                //Status := 2;
                //NoSeriesMgt.InitSeries('CI',xRec."No. Series",0D,"Registration No.","No. Series");
                //"Registration Time" := TIME;

                //MODIFY;
            end;
        }
        field(107; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(130; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = "Not Available","In Progress","Checked-In",Missed;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Flight No.", "Ticket No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if "No." = '' then begin
            "No. Series" := 'REG';
            if NoSeries.AreRelated('REG', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "No." := NoSeries.GetNextNo("No. Series");
        end;
    end;

    var
        NoSeries: Codeunit "No. Series";
}

