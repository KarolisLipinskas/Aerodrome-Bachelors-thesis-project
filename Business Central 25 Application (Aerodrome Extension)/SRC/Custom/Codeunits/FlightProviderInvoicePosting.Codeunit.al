codeunit 50070 "Flight Prov. Invoice Posting"
{

    trigger OnRun()
    begin
    end;

    procedure CheckInvoiceData(Invoice: Record "Flight Provider Invoice")
    begin
        if Invoice.Customer = '' then
            Error('Customer cannot be empty');

        if Invoice."Start Date" = 0D then
            Error('Start Date cannot be empty');

        if Invoice."End Date" = 0D then
            Error('End Date cannot be empty');
    end;

    procedure InvoicePosting(Invoice: Record "Flight Provider Invoice"): Code[20]
    var
        PostedInvoice: Record "Posted Flight Provider Invoice";
        JournalLine: Record "Flight Prov. Inv. Journal Line";
    begin
        CheckInvoiceData(Invoice);

        PostedInvoice.Init;
        PostedInvoice.TransferFields(Invoice);
        PostedInvoice."Posted No." := '';
        PostedInvoice.Insert(true);

        JournalLine.Init;
        JournalLine.TransferFields(PostedInvoice);
        JournalLine.Insert;

        Invoice.Delete;

        JournalToLedger();

        Message('Posting Completed Successfully');

        exit(PostedInvoice."Posted No.");
    end;

    procedure JournalToLedger()
    var
        JournalLine: Record "Flight Prov. Inv. Journal Line";
        Ledger: Record "Flight Prov. Inv. Ledger Entry";
    begin
        if not JournalLine.FindFirst then
            exit;

        repeat
            Ledger.Init;
            Ledger.TransferFields(JournalLine);
            Ledger.Insert(true);
        until JournalLine.Next = 0;

        JournalLine.DeleteAll;
    end;

    procedure CheckJournalData()
    var
        JournalLine: Record "Flight Prov. Inv. Journal Line";
    begin
        if not JournalLine.FindFirst then
            Error('Nothing to post');

        repeat
            if JournalLine."Posted No." = '' then
                Error('Posted No. cannot be empty');

            if JournalLine.Customer = '' then
                Error('Customer cannot be empty');

            if JournalLine."Start Date" = 0D then
                Error('Start Date cannot be empty');

            if JournalLine."End Date" = 0D then
                Error('End Date cannot be empty');

            if JournalLine."Start Date" >= JournalLine."End Date" then
                Error('Start Date cannot be later or equal to End Date');

            if JournalLine."Flight Count" < 0 then
                Error('Flight Count cannot be negative');

            if JournalLine."CheckedIn Passenger Count" < 0 then
                Error('CheckIn Passenger Count cannot be negative');

            if JournalLine."Boarded Passenger Count" < 0 then
                Error('Boarded PAssenger Count cannot be negative');
        until JournalLine.Next = 0;
    end;
}

