table 70097806 "AWR_XLF_Translations"
{
    DataClassification = ToBeClassified;
    Caption = 'XLF Translations';
    Scope = Cloud;

    fields
    {
        field(1; "ID"; Text[300])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Source"; Text[1024])
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Target"; Text[1024])
        {
            Caption = 'Target';
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