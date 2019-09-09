page 70097806 "AWR_XLF_Tools"
{
    PageType = NavigatePage;
    Caption = 'XLF Tools';
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            field("Target language"; language)
            {
                ApplicationArea = All;
                TableRelation = AWR_XLF_Languages;
                Caption = 'Target language';
                Description = 'Target translation language';
            }
            field("Base file name"; fileName)
            {
                ApplicationArea = All;
                Caption = 'Base file name';
                Description = 'Base file name without postfix';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportSource)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Import XLF (Clear)';
                Description = 'Imports source strings and settings from XLF file';
                Image = AboutNav;

                trigger OnAction()
                begin
                    actionsUnit.ImportSource(fileName, false);
                end;
            }
            action(ImportSourceMerge)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Import XLF (Merge)';
                Description = 'Imports source strings and settings from XLF file';
                Image = AboutNav;

                trigger OnAction()
                begin
                    actionsUnit.ImportSource(fileName, true);
                end;
            }
            action(TranslateTo)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Translate (Untranslated)';
                Description = 'Uses language code from Translate language code field';
                Image = AboutNav;

                trigger OnAction()
                begin
                    actionsUnit.Translate(language, false);
                end;
            }
            action(TranslateFromFile)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Translate (From file, Overwrite)';
                Description = 'Fills translations from already translated target file';
                Image = AboutNav;

                trigger OnAction()
                begin
                    actionsUnit.TranslateFromFile();
                end;
            }
            action(TranslateToAll)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Translate (ALL)';
                Description = 'Uses language code from Translate language code field. Translates rows even if Target is not empty';
                Image = AboutNav;

                trigger OnAction()
                begin
                    actionsUnit.Translate(language, true);
                end;
            }
            action(ExportAs)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Export XLF';
                Description = 'Exports translated strings as XLF with postfix from Export language postfix field';
                Image = AboutNav;

                trigger OnAction()
                begin
                    actionsUnit.Export(language, fileName);
                end;
            }
            action(OptionsPage)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Options';
                Image = AboutNav;

                trigger OnAction()
                var
                    options: Page AWR_XLF_Translate_Options;
                begin
                    options.Run();
                end;
            }
            action(TranslationsPage)
            {
                ApplicationArea = All;
                InFooterBar = true;
                Caption = 'Translations';
                Image = AboutNav;

                trigger OnAction()
                var
                    translations: Page AWR_XLF_Translations;
                begin
                    translations.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        fileName := '';
    end;

    var
        actionsUnit: Codeunit AWR_XLF_Actions;
        language: Text;
        fileName: Text;
}