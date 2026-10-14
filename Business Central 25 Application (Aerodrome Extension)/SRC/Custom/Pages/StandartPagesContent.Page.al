page 60040 "Standart Pages Content"
{
    PageType = CardPart;
    SourceTable = "Role Center Pages";
    SourceTableView = WHERE("Primary Key" = CONST('TEST'));

    layout
    {
        area(content)
        {
            group(Pages)
            {
                field("General Ledger Entries"; GeneralLedgerEntries)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(20);
                    end;
                }
                field("Vendor Ledger Entries"; VendorLedgerEntries)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(29);
                    end;
                }
                field("Customer Ledger Entries"; CustomerLedgerEntries)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(25);
                    end;
                }
                field("G/L Registers"; GLRegisters)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(116);
                    end;
                }
                field("Item Ledger Entries"; ItemLedgerEntries)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(38);
                    end;
                }
                field("Posted Purchase Invoices"; PostedPurchaseInvoices)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(146);
                    end;
                }
                field("Posted Sales Invoices"; PostedSalesInvoices)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        PAGE.Run(143);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    var
        GeneralLedgerEntries: Label 'General Ledger Entries';
        VendorLedgerEntries: Label 'Vendor Ledger Entries';
        CustomerLedgerEntries: Label 'Customer Ledger Entries';
        GLRegisters: Label 'G/L Registers';
        ItemLedgerEntries: Label 'Item Ledger Entries';
        PostedPurchaseInvoices: Label 'Posted Purchase Invoices';
        PostedSalesInvoices: Label 'Posted Sales Invoices';
}

