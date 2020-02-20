codeunit 70097806 "AWR_XLF_Actions"
{
    procedure LoadXmlFromStreamWithoutNamespaces(xlfStream: InStream): XmlDocument;
    var
        xmlManager: Codeunit "XML DOM Management";

        root: XmlDocument;
        rootText: Text;
        rootLine: Text;
    begin
        while not xlfStream.EOS() do begin
            xlfStream.ReadText(rootLine);
            rootText += rootLine;
        end;

        rootText := xmlManager.RemoveNamespaces(rootText);
        XmlDocument.ReadFrom(rootText, root);

        exit(root);
    end;

    procedure ImportSource(var baseFileName: Text; merge: Boolean)
    var
        TempBlob: Codeunit "Temp Blob";
        xlfStream: InStream;
        fileName: Text;
    begin
        TempBlob.CreateInStream(xlfStream, TextEncoding::UTF8);

        if UploadIntoStream('Select source XLF file', '', 'XLF (*.xlf)|*.xlf', fileName, xlfStream) then begin
            if not fileName.EndsWith('.g.xlf') then
                Error(IncorrectSourceGeneral_Err);

            baseFileName := CopyStr(fileName, 1, StrLen(fileName) - 6);

            ParseSource(LoadXmlFromStreamWithoutNamespaces(xlfStream), merge);
        end else
            Error(CantUpload_Err);
    end;

    local procedure ParseSource(root: XmlDocument; merge: Boolean)
    var
        translation: Record AWR_XLF_Translations;

        transUnits: XmlNodeList;
        transUnit: XmlNode;
        transUnitElement: XmlElement;
        idAttribute: XmlAttribute;

        unitSourceNode: XmlNode;
    begin
        root.SelectNodes('//xliff/file/body/group/trans-unit', transUnits);

        if not merge then begin
            translation.Reset();
            translation.DeleteAll();
        end;

        foreach transUnit in transUnits do begin
            transUnitElement := transUnit.AsXmlElement();

            transUnitElement.Attributes().Get('id', idAttribute);
            translation.ID := CopyStr(idAttribute.Value(), 1, MaxStrLen(translation.ID));

            transUnitElement.SelectSingleNode('source', unitSourceNode);
            translation.Source := CopyStr(unitSourceNode.AsXmlElement().InnerText(), 1, MaxStrLen(translation.Source));

            // Ignore result cause its dont matter even merging or not
            translation.Insert(false);
        END;

        Message('Import successful!');
    end;

    procedure TranslateFromFile()
    var
        TempBlob: Codeunit "Temp Blob";
        xlfStream: InStream;
        fileName: Text;
    begin
        TempBlob.CreateInStream(xlfStream, TextEncoding::UTF8);

        if UploadIntoStream('Select translated XLF file', '', 'XLF (*.xlf)|*.xlf', fileName, xlfStream) then begin
            if not fileName.EndsWith('.xlf') then
                Error(IncorrectSource_Err);

            TranslateFromFileParse(LoadXmlFromStreamWithoutNamespaces(xlfStream));
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
        root.SelectNodes('//xliff/file/body/group/trans-unit', transUnits);

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
        service: Enum "AWR_XLF_Translation Service";
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

        tempBlob: Codeunit "Temp Blob";
        tempBlobInStream: InStream;
        tempBlobOutStream: OutStream;

        xmlDoc: XmlDocument;
        xliffNode: XmlElement;
        fileNode: XmlElement;
        groupNode: XmlElement;
        bodyNode: XmlElement;
        transUnitNode: XmlElement;
        sourceNode: XmlElement;
        targetNode: XmlElement;

        translatorComment: XmlComment;

        nameSpace: Text;

        commentText: Text;
        service: Enum "AWR_XLF_Translation Service";
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

        nameSpace := 'urn:oasis:names:tc:xliff:document:1.2';

        xliffNode := XmlElement.Create('xliff', nameSpace);
        fileNode := XmlElement.Create('file', nameSpace);
        groupNode := XmlElement.Create('group', nameSpace);
        bodyNode := XmlElement.Create('body', nameSpace);

        groupNode.SetAttribute('id', 'body');

        if translation.FindFirst() then
            REPEAT
                transUnitNode := XmlElement.Create('trans-unit', nameSpace);

                sourceNode := XmlElement.Create('source', nameSpace);
                sourceNode.Add(translation.Source);

                targetNode := XmlElement.Create('target', nameSpace);
                targetNode.Add(translation.Target);

                transUnitNode.Add(sourceNode);
                transUnitNode.Add(targetNode);

                transUnitNode.SetAttribute('id', translation.ID);
                transUnitNode.SetAttribute('translate', 'yes');
                groupNode.Add(transUnitNode);
            UNTIL translation.Next() = 0;

        bodyNode.Add(groupNode);

        fileNode.SetAttribute('source-language', 'en-US');
        fileNode.SetAttribute('target-language', language.Lang);
        fileNode.Add(bodyNode);

        xliffNode.SetAttribute('version', '1.2');
        xliffNode.Add(fileNode);

        xmlDoc.Add(xliffNode);

        translatorComment := XmlComment.Create(commentText);
        xmlDoc.Add(translatorComment);

        tempBlob.CreateOutStream(tempBlobOutStream);
        xmlDoc.WriteTo(tempBlobOutStream);
        tempBlob.CreateInStream(tempBlobInStream);

        DownloadFromStream(tempBlobInStream, 'Export XLF', '', '', fileName);
    end;

    var
        IncorrectSourceGeneral_Err: Label 'File name doesnt ends with .g.xlf';
        IncorrectSource_Err: Label 'File name doesnt ends with .xlf';
        CantUpload_Err: Label 'Cant upload file';
}