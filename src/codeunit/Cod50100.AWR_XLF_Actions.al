codeunit 70097806 "AWR_XLF_Actions"
{

    procedure ImportSource(var baseFileName: Text; merge: Boolean)
    var
        xlfStream: InStream;
        fileName: Text;
        root: XmlDocument;
    begin
        if UploadIntoStream('Select source XLF file', '', 'XLF (*.xlf)|*.xlf', fileName, xlfStream) then begin
            if not fileName.EndsWith('.g.xlf') then
                Error(IncorrectSource_Err);

            baseFileName := CopyStr(fileName, 1, StrLen(fileName) - 6);

            XmlDocument.ReadFrom(xlfStream, root);
            ParseSource(root, merge);
        end else
            Error(CantUpload_Err);
    end;

    local procedure ParseSource(root: XmlDocument; merge: Boolean)
    var
        translation: Record AWR_XLF_Translations;

        transUnits: XmlNodeList;
        transUnit: XmlNode;
        transUnitElement: XmlElement;
        nsManager: XmlNamespaceManager;
        idAttribute: XmlAttribute;

        unitSourceNode: XmlNode;
    begin
        nsManager.NameTable(root.NameTable());
        nsManager.AddNamespace('a', 'urn:oasis:names:tc:xliff:document:1.2');

        root.SelectNodes('//a:xliff/a:file/a:body/a:group/a:trans-unit', nsManager, transUnits);

        if not merge then begin
            translation.Reset();
            translation.DeleteAll();
        end;

        foreach transUnit in transUnits do begin
            transUnitElement := transUnit.AsXmlElement();

            transUnitElement.Attributes().Get('id', idAttribute);
            translation.ID := CopyStr(idAttribute.Value(), 1, MaxStrLen(translation.ID));

            transUnitElement.SelectSingleNode('a:source', nsManager, unitSourceNode);
            translation.Source := CopyStr(unitSourceNode.AsXmlElement().InnerText(), 1, MaxStrLen(translation.Source));

            // Ignore result cause its dont matter even merging or not
            translation.Insert(false);
        END;

        Message('Import successful!');
    end;

    procedure TranslateFromFile()
    var
        xlfStream: InStream;
        fileName: Text;
        root: XmlDocument;
    begin
        if UploadIntoStream('Select translated XLF file', '', 'XLF (*.xlf)|*.xlf', fileName, xlfStream) then begin
            if not fileName.EndsWith('.g.xlf') then
                Error(IncorrectSource_Err);

            XmlDocument.ReadFrom(xlfStream, root);
            TranslateFromFileParse(root);
        end else
            Error(CantUpload_Err);
    end;

    local procedure TranslateFromFileParse(root: XmlDocument)
    var
        translation: Record AWR_XLF_Translations;

        transUnits: XmlNodeList;
        transUnit: XmlNode;
        transUnitElement: XmlElement;
        idAttribute: XmlAttribute;

        unitSourceNode: XmlNode;
    begin
        root.SelectNodes('//xliff/file/body/trans-unit', transUnits);

        foreach transUnit in transUnits do begin
            transUnitElement := transUnit.AsXmlElement();

            transUnitElement.Attributes().Get('id', idAttribute);
            if translation.Get(CopyStr(idAttribute.Value(), 1, MaxStrLen(translation.ID))) then begin
                transUnitElement.SelectSingleNode('target', unitSourceNode);
                translation.Target := CopyStr(unitSourceNode.AsXmlElement().InnerText(), 1, MaxStrLen(translation.Target));

                // Ignore result cause its dont matter even merging or not
                translation.Modify(false);
            end;
        END;

        Message('Translation successful!');
    end;

    procedure Translate(languageID: Text; translateNotEmpty: Boolean)
    var
        language: Record AWR_XLF_Languages;

        translation: Record AWR_XLF_Translations;
        options: Record AWR_XLF_Translate_Options;

        debug: Codeunit AWR_XLF_Translation_Debug;
        yandex: Codeunit AWR_XLF_Translation_Yandex;
        azure: Codeunit AWR_XLF_Translation_Azure;

        parameters: Text;
        service: Enum "Translation Service";
    begin
        language.Get(languageID);

        options.Get();
        service := options."Translation Service";

        if not translateNotEmpty then
            translation.SetFilter(Target, '=%1', '');

        case service of
            service::"Debug Translator":
                if translation.FindFirst() then begin
                    parameters := debug.MakeParameters(language."Lang Type");

                    REPEAT
                        translation.Target := CopyStr(debug.Translate(parameters, translation.Source), 1, MaxStrLen(translation.Target));
                        translation.Modify(false);
                    UNTIL translation.Next() = 0;
                end;
            service::Yandex:
                if translation.FindFirst() then begin
                    parameters := yandex.MakeParameters(options."Yandex API Key", language."Lang Type");

                    REPEAT
                        translation.Target := CopyStr(yandex.Translate(parameters, translation.Source), 1, MaxStrLen(translation.Target));
                        translation.Modify(false);
                    UNTIL translation.Next() = 0;
                end;
            service::Azure:
                if translation.FindFirst() then begin
                    parameters := azure.MakeParameters(language."Lang Type");

                    REPEAT
                        translation.Target := CopyStr(azure.Translate(parameters, options."Azure API Key", translation.Source), 1, MaxStrLen(translation.Target));
                        translation.Modify(false);
                    UNTIL translation.Next() = 0;
                end;
        end;

        Message('Translation successful!');
    end;

    procedure Export(languageID: Text; fileName: Text)
    var
        language: Record AWR_XLF_Languages;
        translation: Record AWR_XLF_Translations;
        options: Record AWR_XLF_Translate_Options;

        tempBlob: Record TempBlob temporary;
        tempBlobInStream: InStream;
        tempBlobOutStream: OutStream;

        xmlDoc: XmlDocument;
        xliffNode: XmlElement;
        fileNode: XmlElement;
        bodyNode: XmlElement;
        transUnitNode: XmlElement;
        sourceNode: XmlElement;
        targetNode: XmlElement;

        translatorComment: XmlComment;

        commentText: Text;
        service: Enum "Translation Service";
    begin
        options.Get();
        service := options."Translation Service";

        case service of
            service::"Debug Translator":
                commentText := 'Translated by Debug Translator';
            service::Yandex:
                commentText := 'Переведено сервисом «Яндекс.Переводчик»: http://translate.yandex.ru/';
            service::Azure:
                commentText := 'Translated by Azure';
        end;

        language.Get(languageID);
        fileName := fileName + '.' + language.Lang + '.xlf';

        xmlDoc := XmlDocument.Create();

        xliffNode := XmlElement.Create('xliff');
        fileNode := XmlElement.Create('file');
        bodyNode := XmlElement.Create('body');

        if translation.FindFirst() then
            REPEAT
                transUnitNode := XmlElement.Create('trans-unit');

                sourceNode := XmlElement.Create('source');
                sourceNode.Add(translation.Source);

                targetNode := XmlElement.Create('target');
                targetNode.Add(translation.Target);

                transUnitNode.Add(sourceNode);
                transUnitNode.Add(targetNode);

                transUnitNode.SetAttribute('id', translation.ID);
                bodyNode.Add(transUnitNode);
            UNTIL translation.Next() = 0;

        fileNode.SetAttribute('source-language', 'en-US');
        fileNode.Add(bodyNode);

        xliffNode.SetAttribute('version', '1.2');
        // xliffNode.SetAttribute('xmlns', 'urn:oasis:names:tc:xliff:document:1.2');
        xliffNode.Add(fileNode);

        xmlDoc.Add(xliffNode);

        translatorComment := XmlComment.Create(commentText);
        xmlDoc.Add(translatorComment);

        tempBlob.blob.CreateOutStream(tempBlobOutStream);
        xmlDoc.WriteTo(tempBlobOutStream);
        tempBlob.blob.CreateInStream(tempBlobInStream);

        DownloadFromStream(tempBlobInStream, 'Export XLF', '', '', fileName);
    end;

    var
        IncorrectSource_Err: Label 'File name doesnt ends with .g.xlf';
        CantUpload_Err: Label 'Cant upload file';
}