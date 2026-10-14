table 50220 "Posted Flight Provider Invoice"
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
        field(107; "No. Series"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(110; SalesHeaderDocType; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(111; SalesHeaderNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(112; SalesHeaderLastPostingNo; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(120; Status; Option)
        {
            DataClassification = ToBeClassified;
            OptionMembers = Unpaid," Paid";
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

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Posted No." = '' then begin
            "No. Series" := 'PI';
            if NoSeries.AreRelated('PI', xRec."No. Series") then
                "No. Series" := xRec."No. Series";
            "Posted No." := NoSeries.GetNextNo("No. Series");
        end;
    end;
}

