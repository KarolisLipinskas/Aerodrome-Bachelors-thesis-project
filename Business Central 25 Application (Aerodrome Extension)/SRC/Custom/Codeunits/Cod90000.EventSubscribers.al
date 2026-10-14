namespace SPLNAirport.SPLNAirport;
using Microsoft.Sales.Posting;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Purchases.Posting;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 90000 "Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    local procedure Codeunit81_OnBeforeConfirmSalesPost_Subscriber(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer; var PostAndSend: Boolean)
    begin
        HideDialog := true;
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post (Yes/No)", 'OnBeforeConfirmPost', '', false, false)]
    local procedure Codeunit91_OnBeforeConfirmPost_Subscriber(var PurchaseHeader: Record "Purchase Header"; var HideDialog: Boolean; var IsHandled: Boolean; var DefaultOption: Integer)
    begin
        HideDialog := true;
        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure Codeunit231_OnBeforeCode_Subscriber(var GenJournalLine: Record "Gen. Journal Line"; var HideDialog: Boolean)
    begin
        HideDialog := true;
    end;
}
