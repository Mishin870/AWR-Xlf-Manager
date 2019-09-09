table 70097807 "AWR_XLF_Translate_Options"
{
    DataClassification = ToBeClassified;
    Caption = 'XLF Translate Options';
    Scope = Extension;

    fields
    {
        field(1; "ID"; Integer)
        {
            Caption = 'ID (Ignored)';
            DataClassification = CustomerContent;
        }
        field(2; "Translation Service"; Enum "Translation Service")
        {
            Caption = 'Translation Service';
            DataClassification = CustomerContent;
        }
        field(3; "Yandex API Key"; Text[200])
        {
            Caption = 'Yandex API Key';
            DataClassification = CustomerContent;
        }
        field(4; "Azure API Key"; Text[200])
        {
            Caption = 'Azure API Key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

}