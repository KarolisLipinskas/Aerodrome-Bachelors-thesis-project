table 50130 "Flight Reference Table"
{
    LookupPageID = "Flight Reference List";

    fields
    {
        field(10; "Flight No."; Code[20])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                i: Integer;
                NumberPart: Text;
            begin
                if "Flight No." = '' then
                    Error('Flight No. cannot be empty');

                if CopyStr("Flight No.", 1, 2) = "Flight Provider Code" then begin
                    //MESSAGE('doing checks for 2 symbol flight provider code');
                    NumberPart := CopyStr("Flight No.", 3);
                    if StrLen(NumberPart) > 0 then begin
                        for i := 1 to StrLen(NumberPart) do begin
                            if not ((NumberPart[i] >= '0') and (NumberPart[i] <= '9')) then
                                Error('After flight provider code there needs to be only numbers');
                        end;
                        exit;
                    end else
                        Error('After flight provider code there needs to be at least 1 number');
                end;

                if CopyStr("Flight No.", 1, 3) = "Flight Provider Code" then begin
                    //MESSAGE('doing checks for 3 symbol flight provider code');
                    NumberPart := CopyStr("Flight No.", 4);
                    if StrLen(NumberPart) > 0 then begin
                        for i := 1 to StrLen(NumberPart) do begin
                            if not ((NumberPart[i] >= '0') and (NumberPart[i] <= '9')) then
                                Error('After flight provider code there needs to be only numbers');
                        end;
                        exit;
                    end else
                        Error('After flight provider code there needs to be at least 1 number');
                end;

                Error('First letters of Flight No. need to be Flight Provider Code');
            end;
        }
        field(20; Description; Text[100])
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Description = '' then
                    Error('Destination cannot be empty');
            end;
        }
        field(30; FlightProviderCust; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Customer WHERE(isFlightProvider = CONST(true));

            trigger OnValidate()
            var
                Customer: Record Customer;
                Vendor: Record Vendor;
            begin
                if Customer.Get(FlightProviderCust) then begin
                    "Flight Provider Name" := Customer.Name;
                    "Flight Provider Code" := Customer."Flight Provider Code";
                    if "Flight No." = '' then
                        "Flight No." := Customer."Flight Provider Code";
                end else
                    Error('Customer Flight Provider not found');

                Vendor.SetRange(isFlightProvider, true);
                Vendor.SetRange("Flight Provider Code", "Flight Provider Code");
                if Vendor.FindFirst then
                    FlightProviderVend := Vendor."No."
                else
                    Error('Vendor Flight Provider not found');
            end;
        }
        field(31; FlightProviderVend; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor WHERE(isFlightProvider = CONST(true));

            trigger OnValidate()
            var
                Vendor: Record Vendor;
                Customer: Record Customer;
            begin
                if Vendor.Get(FlightProviderVend) then begin
                    "Flight Provider Name" := Vendor.Name;
                    "Flight Provider Code" := Vendor."Flight Provider Code";
                    if "Flight No." = '' then
                        "Flight No." := Vendor."Flight Provider Code";
                end else
                    Error('Vendor Flight Provider not found');

                Customer.SetRange(isFlightProvider, true);
                Customer.SetRange("Flight Provider Code", "Flight Provider Code");
                if Customer.FindFirst then
                    FlightProviderCust := Customer."No."
                else
                    Error('Customer Flight Provider not found');
            end;
        }
        field(40; "Flight Provider Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50; "Flight Provider Code"; Code[3])
        {
            DataClassification = ToBeClassified;
        }
        field(60; Price; Decimal)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            begin
                if Price <= 0 then
                    Error('Price cannot be nagative or 0');
            end;
        }
        field(70; "Commision Percentage"; Decimal)
        {
            DecimalPlaces = 1 : 2;

            trigger OnValidate()
            begin
                if "Commision Percentage" < 0 then
                    Error('Commision Persentage cannot be negative');
            end;
        }
    }

    keys
    {
        key(Key1; "Flight No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Flight No.", Description, "Flight Provider Name")
        {
        }
    }

    trigger OnInsert()
    begin
        Message('insert');
        Validate("Flight No.", "Flight No.");
        Validate("Commision Percentage", 0.2);
    end;
}

