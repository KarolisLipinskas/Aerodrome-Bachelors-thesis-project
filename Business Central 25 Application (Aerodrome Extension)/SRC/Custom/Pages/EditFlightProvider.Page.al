page 50201 "Edit Flight Provider"
{
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    Caption = 'Flight Provider No.';
                    TableRelation = Customer."No." WHERE(isFlightProvider = CONST(true));

                    trigger OnValidate()
                    begin
                        if "No." = '' then begin
                            Name := '';
                            "Flight Provider Code" := '';
                            "Default Price CheckIn" := 0;
                            "Default Price Boarding" := 0;
                            exit;
                        end;

                        if CustomerRec.Get("No.") then begin
                            Name := CustomerRec.Name;
                            "Flight Provider Code" := CustomerRec."Flight Provider Code";
                            "Default Price CheckIn" := CustomerRec."Default Price CheckIn";
                            "Default Price Boarding" := CustomerRec."Default Price Boarding";
                        end else
                            Error('Flight Provider not found');
                    end;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    Caption = 'Flight Provider Name';
                    Editable = false;
                }
                field("Flight Provider Code"; "Flight Provider Code")
                {
                    ApplicationArea = All;
                    Caption = 'Flight Provider Code';
                    Editable = false;
                }
                field("Default Price CheckIn"; "Default Price CheckIn")
                {
                    ApplicationArea = All;
                    Caption = 'Default Price for Check-In, €';

                    trigger OnValidate()
                    begin
                        if "Default Price CheckIn" < 0 then
                            Error('Default Price for Check-In cannot be negative');

                        CustomerRec."Default Price CheckIn" := "Default Price CheckIn";
                        CustomerRec.Modify(true);
                    end;
                }
                field("Default Price Boarding"; "Default Price Boarding")
                {
                    ApplicationArea = All;
                    Caption = 'Default Price for Boarding, €';

                    trigger OnValidate()
                    begin
                        if "Default Price Boarding" < 0 then
                            Error('Default Price for Boarding cannot be negative');

                        CustomerRec."Default Price Boarding" := "Default Price Boarding";
                        CustomerRec.Modify(true);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Delete Flight Provider")
            {
                ApplicationArea = All;
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                    Customer: Record Customer;
                    FlightReference: Record "Flight Reference Table";
                begin
                    Vendor.SetRange(isFlightProvider, true);
                    Vendor.SetRange(Name, Name);
                    Vendor.SetRange("Flight Provider Code", "Flight Provider Code");
                    if Vendor.FindFirst then
                        Vendor.Delete(true);

                    if Customer.Get("No.") then begin
                        FlightReference.SetRange(FlightProviderCust, Customer."No.");
                        FlightReference.DeleteAll(true);

                        Customer.Delete(true);
                    end;

                    "No." := '';
                    Name := '';
                    "Flight Provider Code" := '';
                    "Default Price CheckIn" := 0;
                    "Default Price Boarding" := 0;

                    Message('Flight Provider deleted successfully');
                end;
            }
        }
    }

    var
        "No.": Code[20];
        Name: Text[100];
        "Flight Provider Code": Code[3];
        "Default Price CheckIn": Decimal;
        "Default Price Boarding": Decimal;
        CustomerRec: Record Customer;
}

