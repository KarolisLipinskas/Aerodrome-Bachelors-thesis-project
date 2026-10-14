codeunit 50030 "Boarding Posting"
{

    trigger OnRun()
    begin
    end;

    local procedure CheckBoardingData(Flight: Record Flight): Boolean
    var
        BoardingList: Record "Passenger Boarding";
    begin
        BoardingList.SetRange("Flight No.", Flight."Flight No.");
        BoardingList.SetRange("Flight Date", Flight."Flight Date");
        BoardingList.SetRange("Flight Time", Flight."Departure Time");

        if not BoardingList.FindFirst then
            Error('You cannot post Passenger Boarding list with no passengers Checked-In');

        BoardingList.SetRange("Is Present", true);

        if not BoardingList.FindFirst then
            if not Confirm('WARNING!\You are posting Boarding List with no passengers present\Do you wish to continue', false) then
                exit(false);

        exit(true);
    end;

    procedure PostBoarding(Flight: Record Flight): Boolean
    var
        BoardingList: Record "Passenger Boarding";
        PostedBoardingList: Record "Posted Passenger Boarding";
        JournalLine: Record "Boarding Journal Line";
        Passenger: Record Passenger;
    begin
        if not CheckBoardingData(Flight) then
            exit(false);
        if not Confirm('Flight: %1 - %2 - %3\Do you want to post Boarding List?', true, Flight."Flight No.", Flight."Flight Date", Flight."Departure Time") then
            exit(false);

        BoardingList.SetRange("Flight No.", Flight."Flight No.");
        BoardingList.SetRange("Flight Date", Flight."Flight Date");
        BoardingList.SetRange("Flight Time", Flight."Departure Time");
        if BoardingList.FindFirst then begin
            repeat
                PostedBoardingList.Init;
                PostedBoardingList.TransferFields(BoardingList);
                PostedBoardingList."Posted Boarding No." := '';
                PostedBoardingList.Insert(true);

                if not Passenger.Get(PostedBoardingList."Flight No.", PostedBoardingList."Flight Date", PostedBoardingList."Flight Time", PostedBoardingList."Ticket No.") then
                    Error('Passenger with Ticket No.: %1, is not in Passenger List', PostedBoardingList."Ticket No.");
                if PostedBoardingList."Is Present" then
                    Passenger.Status := 2;
                //ELSE
                //  Passenger.Status := 3;
                Passenger.Modify(true);

                JournalLine.Init;
                JournalLine.TransferFields(PostedBoardingList);
                JournalLine.Insert;

                BoardingList.Delete;
            until BoardingList.Next = 0;
        end;

        Flight."Boarding Status" := 3;
        Flight.Modify;


        PostJournalToLedger();
        Message('Posting completed successfully');
        exit(true);
    end;

    procedure PostJournalToLedger()
    var
        JournalLine: Record "Boarding Journal Line";
        Ledger: Record "Boarding Ledger Entry";
    begin
        if not JournalLine.FindFirst then
            exit;

        repeat
            Ledger.Init;
            Ledger.TransferFields(JournalLine);
            Ledger.Insert;
        until JournalLine.Next = 0;

        JournalLine.DeleteAll;
    end;

    procedure CheckJournalData(JournalLine: Record "Boarding Journal Line")
    begin
        if not JournalLine.FindFirst then
            Error('Nothing to post');

        repeat
            if JournalLine."Posted Boarding No." = '' then
                Error('Posted Boarding No. cannot be empty');

            if JournalLine."Registration No." = '' then
                Error('Registration No. cannot be empty');

            if JournalLine."Seat Code" = '' then
                Error('Seat Code cannot be empty');

            if JournalLine."Flight No." = '' then
                Error('Flight No. cannot be empty');

            if JournalLine."Flight Date" = 0D then
                Error('Flight Date cannot be empty');

            if JournalLine."Flight Time" = 0T then
                Error('Flight Time cannot be empty');

            if JournalLine."Ticket No." = '' then
                Error('Ticket No. cannot be empty');

            if JournalLine.Name = '' then
                Error('Name cannot be empty');

            if JournalLine.Surname = '' then
                Error('Surname cannot be empty');

            if JournalLine."Personal Code" = '' then
                Error('Personal Code cannot be empty');
        until JournalLine.Next = 0;
    end;
}

