page 50110 "Check-In Journal"
{
    PageType = List;
    SourceTable = "Check-In Journal Line";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posted CheckIn No."; Rec."Posted CheckIn No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
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
                field("Person Code"; Rec."Person Code")
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
                field("Registration Time"; Rec."Registration Time")
                {
                    ApplicationArea = All;
                }
                field("Posting DateTime"; Rec."Posting DateTime")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
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
                    PostController: Codeunit "Check-In Posting";
                begin
                    PostController.CheckJournalLine();
                    PostController.PostJournalToLedger();
                end;
            }
        }
    }

    trigger OnClosePage()
    var
        JournalLine: Record "Check-In Journal Line";
    begin
        JournalLine.DELETEALL;
    end;
}

