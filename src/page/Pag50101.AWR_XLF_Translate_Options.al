page 70097807 "AWR_XLF_Translate_Options"
{
    PageType = List;
    SourceTable = AWR_XLF_Translate_Options;
    Caption = 'XLF Translate Options';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Translation Service"; "Translation Service")
                {
                    ApplicationArea = All;
                }
                field("Yandex API Key"; "Yandex API Key")
                {
                    ApplicationArea = All;
                }
                field("Azure API Key"; "Azure API Key")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(false);
        end;
    end;
}