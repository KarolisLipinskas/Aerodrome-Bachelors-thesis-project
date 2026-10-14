codeunit 50040 "Ticket Sale/Purchase Posting"
{

    trigger OnRun()
    begin
    end;

    procedure CheckSaleData(TicketSale: Record "Ticket Sale")
    var
        Flight: Record Flight;
    begin
        if TicketSale."Flight No." = '' then
            Error('Flight No. cannot be empty');

        if TicketSale."Flight Date" = 0D then
            Error('Flight Date cannot be empty');

        if TicketSale."Flight Time" = 0T then
            Error('Flight Time cannot be empty');

        if TicketSale."Ticket Price" <= 0 then
            Error('Ticket Price cannot be equal to 0 or negative');

        if TicketSale."Person Code" = '' then
            Error('Person Code cannot be empty');

        if TicketSale.Name = '' then
            Error('Name cannot be empty');

        if TicketSale.Surname = '' then
            Error('Surname cannot be empty');

        if not Flight.Get(TicketSale."Flight Date", TicketSale."Flight Time", TicketSale."Flight No.") then
            Error('Flight: %1 - %2 - %3, not found', TicketSale."Flight No.", TicketSale."Flight Date", TicketSale."Flight Time");

        if (Flight."Registration Status" <> 0) or (Flight."Boarding Status" <> 0) then
            Error('Flight: %1 - %2 - %3, is passed the time when ticket sales are available', TicketSale."Flight No.", TicketSale."Flight Date", TicketSale."Flight Time");
    end;

    procedure SalePosting(TicketSale: Record "Ticket Sale"): Code[20]
    var
        PostedTicketSale: Record "Posted Ticket Sale";
        JournalLine: Record "Ticket Sale/Purch Journal Line";
        FlightTicketGen: Record "Flight Ticket Generator";
    begin
        //posts sale to posted sale
        PostedTicketSale.Init;
        PostedTicketSale.TransferFields(TicketSale);
        PostedTicketSale."Posted No." := '';
        PostedTicketSale.Insert(true);

        //adds journal line with type sale
        JournalLine.Init;
        //JournalLine."Baggage Count" := FORMAT(PostedTicketSale."Baggage Count");
        JournalLine.TransferFields(PostedTicketSale);
        JournalLine.Type := 0;
        JournalLine."Posting DateTime" := CurrentDateTime;
        JournalLine.Insert(true);

        if not FlightTicketGen.Get(TicketSale."Flight No.", TicketSale."Flight Date", TicketSale."Flight Time") then
            Error('Ticket Number Generator not found');
        FlightTicketGen."Current No." += 1;
        FlightTicketGen.Modify;

        TicketSale.Delete(true);

        exit(PostedTicketSale."Posted No.");
    end;

    procedure PurchasePosting(TicketPurchase: Record "Ticket Purchase"): Code[20]
    var
        PostedTicketPurch: Record "Posted Ticket Purchase";
        JournalLine: Record "Ticket Sale/Purch Journal Line";
    begin
        //posts purchase to posted purchase
        PostedTicketPurch.Init;
        PostedTicketPurch.TransferFields(TicketPurchase);
        PostedTicketPurch."Posted No." := '';
        PostedTicketPurch.Insert(true);

        //adds journal line with type purchase
        JournalLine.Init;
        JournalLine."Posted No." := PostedTicketPurch."Posted No.";
        JournalLine.Type := 1;
        JournalLine."Flight No." := PostedTicketPurch."Flight No.";
        JournalLine."Flight Date" := PostedTicketPurch."Flight Date";
        JournalLine."Flight Time" := PostedTicketPurch."Flight Time";
        JournalLine."Ticket No." := PostedTicketPurch."Ticket No.";
        JournalLine.Vendor := PostedTicketPurch.Vendor;
        JournalLine."Vendor Name" := PostedTicketPurch."Vendor Name";
        JournalLine."Ticket Price" := PostedTicketPurch."Ticket Price" * (-1);
        JournalLine."Posting DateTime" := CurrentDateTime;
        JournalLine.Insert(true);

        exit(PostedTicketPurch."Posted No.");
    end;

    procedure JournalToLedger()
    var
        JournalLine: Record "Ticket Sale/Purch Journal Line";
        Ledger: Record "Ticket Sale/Purch Ledger Entry";
    begin
        if not JournalLine.FindFirst then
            exit;

        if JournalLine."Posting DateTime" = 0DT then
            JournalLine."Posting DateTime" := CurrentDateTime;

        repeat
            Ledger.Init;
            Ledger.TransferFields(JournalLine);
            Ledger.Insert(true);
        until JournalLine.Next = 0;

        JournalLine.DeleteAll;
    end;

    procedure CheckJournalData()
    var
        JournalLine: Record "Ticket Sale/Purch Journal Line";
        "Integer": Integer;
    begin
        if not JournalLine.FindFirst then
            Error('Nothing to post');

        repeat
            if JournalLine."Posted No." = '' then
                Error('Posted No. cannot be empty');

            if JournalLine."Flight No." = '' then
                Error('Flight No. cannot be empty');

            if JournalLine."Flight Date" = 0D then
                Error('Flight Date cannot be empty');

            if JournalLine."Flight Time" = 0T then
                Error('Flight Time cannot be empty');

            if JournalLine."Ticket No." = '' then
                Error('Ticket No. cannot be empty');

            if JournalLine.Vendor = '' then
                Error('Vendor Code cannot be empty');

            if JournalLine."Vendor Name" = '' then
                Error('Vendor Name cannot be empty');

            if JournalLine.Customer = '' then
                Error('Customer Code cannot be empty');

            if JournalLine."Personal Code" = '' then
                Error('Personal Code cannot be empty');

            if JournalLine.Name = '' then
                Error('Name cannot be empty');

            if JournalLine.Surname = '' then
                Error('Surname cannot be empty');

        until JournalLine.Next = 0;
    end;
}

