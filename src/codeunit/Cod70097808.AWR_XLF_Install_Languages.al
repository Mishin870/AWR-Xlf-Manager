codeunit 70097808 "AWR_XLF_Install_Languages"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
        language: Record AWR_XLF_Languages;
    begin
        language.DeleteAll();

        language.Init();
        language.Lang := 'en-US';
        language."Lang Type" := 'en';
        language.Insert(false);

        language.Init();
        language.Lang := 'en-GB';
        language."Lang Type" := 'en';
        language.Insert(false);

        language.Init();
        language.Lang := 'it-CH';
        language."Lang Type" := 'it';
        language.Insert(false);

        language.Init();
        language.Lang := 'sv-SE';
        language."Lang Type" := 'sv';
        language.Insert(false);

        language.Init();
        language.Lang := 'ru-RU';
        language."Lang Type" := 'ru';
        language.Insert(false);

        language.Init();
        language.Lang := 'nb-NO';
        language."Lang Type" := 'nb';
        language.Insert(false);

        language.Init();
        language.Lang := 'en-NZ';
        language."Lang Type" := 'en';
        language.Insert(false);

        language.Init();
        language.Lang := 'nl-NL';
        language."Lang Type" := 'nl';
        language.Insert(false);

        language.Init();
        language.Lang := 'es-MX';
        language."Lang Type" := 'es';
        language.Insert(false);

        language.Init();
        language.Lang := 'it-IT';
        language."Lang Type" := 'it';
        language.Insert(false);

        language.Init();
        language.Lang := 'is-IS';
        language."Lang Type" := 'is';
        language.Insert(false);

        language.Init();
        language.Lang := 'fr-FR';
        language."Lang Type" := 'fr';
        language.Insert(false);

        language.Init();
        language.Lang := 'fi-FI';
        language."Lang Type" := 'fi';
        language.Insert(false);

        language.Init();
        language.Lang := 'es-ES';
        language."Lang Type" := 'es';
        language.Insert(false);

        language.Init();
        language.Lang := 'de-AT';
        language."Lang Type" := 'de';
        language.Insert(false);

        language.Init();
        language.Lang := 'en-AU';
        language."Lang Type" := 'en';
        language.Insert(false);

        language.Init();
        language.Lang := 'fr-BE';
        language."Lang Type" := 'fr';
        language.Insert(false);

        language.Init();
        language.Lang := 'nl-BE';
        language."Lang Type" := 'nl';
        language.Insert(false);

        language.Init();
        language.Lang := 'en-CA';
        language."Lang Type" := 'en';
        language.Insert(false);

        language.Init();
        language.Lang := 'fr-CA';
        language."Lang Type" := 'fr';
        language.Insert(false);

        language.Init();
        language.Lang := 'de-CH';
        language."Lang Type" := 'de';
        language.Insert(false);

        language.Init();
        language.Lang := 'cs-CZ';
        language."Lang Type" := 'cs';
        language.Insert(false);

        language.Init();
        language.Lang := 'de-DE';
        language."Lang Type" := 'de';
        language.Insert(false);

        language.Init();
        language.Lang := 'da-DK';
        language."Lang Type" := 'da';
        language.Insert(false);

        language.Init();
        language.Lang := 'fr-CH';
        language."Lang Type" := 'fr';
        language.Insert(false);
    end;
}