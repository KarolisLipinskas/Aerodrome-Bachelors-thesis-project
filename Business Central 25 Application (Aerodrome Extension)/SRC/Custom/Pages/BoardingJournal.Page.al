page 50230 "Boarding Journal"
{
    PageType = List;
    SourceTable = "Boarding Journal Line";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted Boarding No."; Rec."Posted Boarding No.")
                {
                    ApplicationArea = All;
                }
                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                }
                field("Flight Date"; Rec."Flight Date")
                {
                    ApplicationArea = All;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Personal Code"; Rec."Personal Code")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = All;
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Seat Code"; Rec."Seat Code")
                {
                    ApplicationArea = All;
                }
                field("Is Present"; Rec."Is Present")
                {
                    ApplicationArea = All;
                }
                field("Boarding Time"; Rec."Boarding Time")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = All;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PostController: Codeunit "Boarding Posting";
                begin
                    PostController.CheckJournalData(Rec);
                    PostController.PostJournalToLedger();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        JournalLine: Record "Boarding Journal Line";
    begin
        JournalLine.DELETEALL;
    end;
}

