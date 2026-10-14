codeunit 50020 "Check-In Posting"
{

    trigger OnRun()
    begin
    end;

    procedure CheckData(CheckIn: Record "Check-In")
    begin
        if CheckIn."No." = '' then
            Error('Check-In identifiaction number "No.", cannot be empty');

        if CheckIn."Seat Code" = '' then
            Error('Check-In with No.: %1\Seat cannot be empty', CheckIn."No.");

        if CheckIn."Registration No." = '' then
            Error('Check-In with No.: %1\Registration No. cannot be empty', CheckIn."No.");

        //IF CheckIn."Registration Time" = 0T THEN
        //  ERROR('Check-In with No.: %1\Registration Time cannot be empty',CheckIn."No.");
    end;

    procedure PostCheckIn(CheckIn: Record "Check-In"): Code[20]
    var
        PostedCheckIn: Record "Posted Check-In";
        JournalLine: Record "Check-In Journal Line";
        Passenger: Record Passenger;
    begin
        PostedCheckIn.Init;
        PostedCheckIn.TransferFields(CheckIn);
        PostedCheckIn."Posted CheckIn No." := '';
        PostedCheckIn.Insert(true);

        if not Passenger.Get(PostedCheckIn."Flight No.", PostedCheckIn."Flight Date", PostedCheckIn."Flight Time", PostedCheckIn."Ticket No.") then
            Error('Passenger with Ticket No.: %1, is not in Passenger List', PostedCheckIn."Ticket No.");

        if PostedCheckIn.Status = 2 then begin
            Passenger.Status := 1;
            Passenger."Seat Code" := PostedCheckIn."Seat Code";
            Passenger."Registration No." := PostedCheckIn."Registration No.";
        end else
            Passenger.Status := 3;
        Passenger.Modify(true);

        PostJournalToLedger();

        exit(PostedCheckIn."Posted CheckIn No.");
    end;

    procedure CheckAllData(Flight: Record Flight)
    var
        CheckIn: Record "Check-In";
    begin
        if Flight."Registration Status" <> 2 then
            Error('Flights registration status needs to be "Awaiting Completion"');

        CheckIn.SetRange("Flight No.", Flight."Flight No.");
        CheckIn.SetRange("Flight Date", Flight."Flight Date");
        CheckIn.SetRange("Flight Time", Flight."Departure Time");

        if not CheckIn.FindFirst then
            Error('Check-In List cannot be empty');

        repeat
            if CheckIn."No." = '' then
                Error('Check-In identifiaction number "No.", cannot be empty');

            if CheckIn.Status < 2 then
                Error('Check-In with No.: %1\Status needs to be "Checked-In" or "Missed"', CheckIn."No.");

            if CheckIn.Status = 2 then
                CheckData(CheckIn);

        until CheckIn.Next = 0
    end;

    procedure PostAllCheckIns(Flight: Record Flight): Boolean
    var
        CheckIn: Record "Check-In";
        PostedCheckIn: Record "Posted Check-In";
        JournalLine: Record "Check-In Journal Line";
        Passenger: Record Passenger;
    begin
        CheckAllData(Flight);
        if not Confirm('Flight: %1 - %2 - %3\All data successfully validated!\Do you want to Complete Check-In?', true, Flight."Flight No.", Flight."Flight Date", Flight."Departure Time") then
            exit(false);

        CheckIn.SetRange("Flight No.", Flight."Flight No.");
        CheckIn.SetRange("Flight Date", Flight."Flight Date");
        CheckIn.SetRange("Flight Time", Flight."Departure Time");
        CheckIn.FindFirst;

        repeat
            if CopyStr(CheckIn."No.", 1, 1) <> 'P' then
                PostCheckIn(CheckIn);

            CheckIn.Delete(true);
        until CheckIn.Next = 0;

        Flight."Registration Status" := 3;
        Flight.Modify;

        InsertBoardingList(Flight);

        Message('Check-In completed successfully');
        exit(true);
    end;

    procedure PostJournalToLedger()
    var
        JournalLine: Record "Check-In Journal Line";
        Ledger: Record "Check-In Ledger Entry";
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

    procedure CheckJournalLine()
    var
        JournalLine: Record "Check-In Journal Line";
        Line: Integer;
    begin
        if not JournalLine.FindFirst then
            Error('Nothing to post');

        Line := 1;
        repeat
            if JournalLine."Posted CheckIn No." = '' then
                Error('Line: %1, Posted CheckIn No. cannot be empty', Line);

            if JournalLine."Flight No." = '' then
                Error('Line: %1, Flight No. cannot be empty', Line);

            if JournalLine."Person Code" = '' then
                Error('Line: %1, Person Code cannot be empty', Line);

            if JournalLine.Name = '' then
                Error('Line: %1, Name cannot be empty', Line);

            if JournalLine.Surname = '' then
                Error('Line: %1, Surname cannot be empty', Line);

            if JournalLine."Ticket No." = '' then
                Error('Line: %1, Ticket No. cannot be empty', Line);

            if JournalLine."Flight Date" = 0D then
                Error('Line: %1, Flight Date cannot be empty', Line);

            if JournalLine."Flight Time" = 0T then
                Error('Line: %1, Flight Time cannot be empty', Line);

        until JournalLine.Next = 0;
    end;

    procedure InsertBoardingList(Flight: Record Flight)
    var
        PostedCheckIn: Record "Posted Check-In";
        Boarding: Record "Passenger Boarding";
    begin
        PostedCheckIn.SetRange("Flight No.", Flight."Flight No.");
        PostedCheckIn.SetRange("Flight Date", Flight."Flight Date");
        PostedCheckIn.SetRange("Flight Time", Flight."Departure Time");
        PostedCheckIn.SetFilter(PostedCheckIn.Status, '= 2');

        if not PostedCheckIn.FindFirst then
            exit;

        repeat
            Boarding.Init;
            Boarding."Boarding No." := '';
            Boarding."Registration No." := PostedCheckIn."Registration No.";
            Boarding."Seat Code" := PostedCheckIn."Seat Code";
            Boarding."Flight No." := Flight."Flight No.";
            Boarding."Flight Date" := Flight."Flight Date";
            Boarding."Flight Time" := Flight."Departure Time";
            Boarding."Ticket No." := PostedCheckIn."Ticket No.";
            Boarding.Name := PostedCheckIn.Name;
            Boarding.Surname := PostedCheckIn.Surname;
            Boarding."Personal Code" := PostedCheckIn."Personal Code";
            Boarding."Is Present" := false;
            Boarding.Insert(true);

        //MESSAGE('inserted boarding: %1, reg: %2',Boarding."Boarding No.",Boarding."Registration No.");

        until PostedCheckIn.Next = 0;
    end;
}

