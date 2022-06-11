unit Main;

{$mode objfpc}{$H+}

interface

uses
  Windows, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Grids, ComCtrls, Types, Zipper, LazFileUtils, strutils;

type
  aTStringDynArray = array of String;
  aTBoolDynArray = array of Boolean;
  aTIntDynArray = array of Integer;
  aTNameFileDynArray = array of Record sName, sFile: String; end;

  { TForm1 }

  TForm1 = class(TForm)
    Button_GroupJumpTo: TButton;
    Button_GroupSave: TButton;
    Button_GroupUp: TButton;
    Button_GroupDown: TButton;
    Button_GroupSub: TButton;
    Button_GroupDelete: TButton;
    Button_GroupNew: TButton;
    Button_Distribute: TButton;
    Button_New: TButton;
    Button_ChangeAll: TButton;
    Button_Delete: TButton;
    Button_Find: TButton;
    Button_Save: TButton;
    Button_Load: TButton;
    CheckBox_GroupHidden: TCheckBox;
    CheckBox_ShowUntranslatedOnly: TCheckBox;
    CheckBox_IgnoreTranslated: TCheckBox;
    CheckBox_ChangeAll: TCheckBox;
    CheckBox_ChangeAllIgnoreTransl: TCheckBox;
    CheckBox_Case: TCheckBox;
    CheckBox_SearchSize: TCheckBox;
    ImageList1: TImageList;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabeledEdit_Group: TLabeledEdit;
    LabeledEdit_Line: TLabeledEdit;
    LabeledEdit_GroupFrom: TLabeledEdit;
    LabeledEdit_GroupTo: TLabeledEdit;
    LabeledEdit_GroupName: TLabeledEdit;
    LabeledEdit_Find_What: TLabeledEdit;
    LabeledEdit_LineOrig: TLabeledEdit;
    LabeledEdit_LineTransl: TLabeledEdit;
    LabeledEdit_LangName: TLabeledEdit;
    LabeledEdit_LangFile: TLabeledEdit;
    PageControl1: TPageControl;
    Panel_Groups: TPanel;
    Panel_Lines: TPanel;
    RadioGroup_Find_Where: TRadioGroup;
    RadioGroup_Find_Direction: TRadioGroup;
    ScrollBox1: TScrollBox;
    Shape_Separator2: TShape;
    Shape_Separator: TShape;
    StaticText1: TStaticText;
    StringGrid_Languages: TStringGrid;
    StringGrid_Lines: TStringGrid;
    TabSheet_Groups: TTabSheet;
    TabSheet_Lines: TTabSheet;
    TreeView_Groups: TTreeView;

    procedure dDlg_Button_DoneClick(Sender: TObject);
    procedure dDlg_Button_AbortClick(Sender: TObject);
    procedure dDlg_FormResize(Sender: TObject);
    procedure dDlg_TreeViewSelectionChanged(Sender: TObject);

    procedure aLoadTemplate();
    procedure aLoadLanguage(sFile: String);
    procedure Button_ChangeAllClick(Sender: TObject);
    procedure Button_DeleteClick(Sender: TObject);
    procedure Button_DistributeClick(Sender: TObject);
    procedure Button_FindClick(Sender: TObject);
    procedure Button_GroupDeleteClick(Sender: TObject);
    procedure Button_GroupDownClick(Sender: TObject);
    procedure Button_GroupJumpToClick(Sender: TObject);
    procedure Button_GroupNewClick(Sender: TObject);
    procedure Button_GroupSaveClick(Sender: TObject);
    procedure Button_GroupSubClick(Sender: TObject);
    procedure Button_GroupUpClick(Sender: TObject);
    procedure Button_LoadClick(Sender: TObject);
    procedure Button_NewClick(Sender: TObject);
    procedure Button_SaveClick(Sender: TObject);
    procedure CheckBox_ShowUntranslatedOnlyChange(Sender: TObject);
    procedure CheckBox_ChangeAllChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LabeledEdit_GroupEditingDone(Sender: TObject);
    procedure LabeledEdit_LineTranslEditingDone(Sender: TObject);
    procedure LabeledEdit_LineTranslKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PageControl1Change(Sender: TObject);
    procedure StringGrid_LanguagesAfterSelection(Sender: TObject; aCol,
      aRow: Integer);
    procedure StringGrid_LinesAfterSelection(Sender: TObject; aCol,
      aRow: Integer);
    procedure StringGrid_LinesDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure TreeView_GroupsSelectionChanged(Sender: TObject);

  private

  public

  end;

const
  cVersion = 'Translation manager for Pokemon Reborn - v1.14';

var
  Form1: TForm1;
  gNotSelecting_Group: Boolean;

implementation

{$R *.lfm}

{ dDlg }
procedure TForm1.dDlg_Button_DoneClick(Sender: TObject);
begin
  TForm(TButton(Sender).Parent).Close;
end;
procedure TForm1.dDlg_Button_AbortClick(Sender: TObject);
var
  i, i2: Integer;
begin
  for i := 0 to TForm(TButton(Sender).Parent).ControlCount-1 do if TForm(TButton(Sender).Parent).Controls[i] is TTreeView then begin
    TTreeView(TForm(TButton(Sender).Parent).Controls[i]).BeginUpdate;
    for i2 := 0 to TTreeView(TForm(TButton(Sender).Parent).Controls[i]).Items.Count-1 do begin
      TTreeView(TForm(TButton(Sender).Parent).Controls[i]).Items.Item[i2].ImageIndex := 1;
    end;
    TTreeView(TForm(TButton(Sender).Parent).Controls[i]).EndUpdate;
  end;

  TForm(TButton(Sender).Parent).Close;
end;
procedure TForm1.dDlg_FormResize(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to TForm(Sender).ControlCount-1 do if TForm(Sender).Controls[i] is TTreeView then begin
    TForm(Sender).Controls[i].Width := TForm(Sender).Width-TForm(Sender).Controls[i].Left;
    TForm(Sender).Controls[i].Height := TForm(Sender).Height;
  end;
end;
procedure TForm1.dDlg_TreeViewSelectionChanged(Sender: TObject);

  procedure aToggleIndex(nNode: TTreeNode; iNewIndex: Integer);
  var
    i, iFirst, iLast: Integer;
  begin
    nNode.ImageIndex := iNewIndex;
    nNode.SelectedIndex := iNewIndex;
    nNode.StateIndex := iNewIndex;

    if nNode.HasChildren then begin
      iFirst := nNode.GetFirstChild.Index;
      iLast := nNode.GetLastChild.Index;

      for i := iFirst to iLast do begin
        aToggleIndex(nNode.Items[i], iNewIndex);
      end;
    end;
  end;

begin
  if not (TTreeView(Sender).Selected = nil) then begin
    aToggleIndex(TTreeView(Sender).Selected, 1-TTreeView(Sender).Selected.ImageIndex);
    TTreeView(Sender).Selected := nil;
  end;
end;

{ TForm1 }

//This one actually auto-finds the groups :3
{procedure TForm1.aLoadTemplate();

  function aNormalize(sString: String): String;
  var
    i: Integer;
  begin
    result := '';
    for i := 1 to Length(sString) do begin
      if not (sString[i] = ' ') then result := result+sString[i];
    end;
  end;

var
  i, iFrom, iTo: Integer;
  sSL, sSL2: TStringList;
  sLastTitle: String;
  bDo: Boolean;
begin
  sSL := tStringList.Create;
  sSL2 := tStringList.Create;
  try
    sSL.LoadFromFile(ExpandFileName(ExtractFileDir(Application.ExeName)+'\intl.txt'));

    iFrom := 0;
    iTo := 0;
    sLastTitle := '[Map0]';
    for i := 1 to sSL.Count-1 do if aNormalize(sSL.Strings[i]) = aNormalize(sSL.Strings[i-1]) then begin
      iTo := i+1;
    end else begin
      if i = sSL.Count-1 then bDo := false
      else bDo := (not (aNormalize(sSL.Strings[i]) = aNormalize(sSL.Strings[i+1])));

      if bDo AND (iFrom >= 0) then begin
        sSL2.Add('1'+sLastTitle+' '+IntToStr(iFrom)+'-'+IntToStr(iTo));

        sLastTitle := sSL.Strings[i];
        iFrom := i+1;
        iTo := i+1;
      end;
    end;

    sSL2.SaveToFile('1.txt');

  finally
    sSL.Free;
    sSL2.Free;
  end;
end;}

procedure TForm1.aLoadTemplate();

  function aNormalize(sString: String): String;
  var
    i: Integer;
  begin
    result := '';
    for i := 1 to Length(sString) do begin
      if not (sString[i] = ' ') then result := result+sString[i];
    end;
  end;

var
  i: Integer;
  sSL: TStringList;
  aLines: aTIntDynArray;
begin
  sSL := tStringList.Create;
  try
    sSL.LoadFromFile(ExpandFileName(ExtractFileDir(Application.ExeName)+'\intl.txt'));

    SetLength(aLines, 0);
    for i := 1 to sSL.Count-1 do if aNormalize(sSL.Strings[i]) = aNormalize(sSL.Strings[i-1]) then begin
      SetLength(aLines, Length(aLines)+1);
      aLines[Length(aLines)-1] := i;
    end;

    StringGrid_Lines.RowCount := Length(aLines)+1;

    StringGrid_Lines.Cells[0, 0] := 'Original';
    StringGrid_Lines.Cells[1, 0] := 'Translated';
    StringGrid_Lines.Cells[2, 0] := 'Line';
    StringGrid_Lines.Cells[3, 0] := 'Group';

    for i := 0 to Length(aLines)-1 do begin
      StringGrid_Lines.Cells[0, i+1] := sSL.Strings[aLines[i]-1];
      StringGrid_Lines.Cells[1, i+1] := sSL.Strings[aLines[i]-1];
      StringGrid_Lines.Cells[2, i+1] := IntToStr(aLines[i]);
      StringGrid_Lines.Cells[3, i+1] := '';
    end;
  finally
    sSL.Free;
  end;
end;

procedure TForm1.aLoadLanguage(sFile: String);
var
  i: Integer;
  sSL: TStringList;
begin
  StringGrid_Lines.BeginUpdate;
  aLoadTemplate();

  if FileExists(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Translations\'+sFile+'.txt')) then begin
    sSL := tStringList.Create;
    try
      sSL.LoadFromFile(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Translations\'+sFile+'.txt'));
      for i := 1 to StringGrid_Lines.RowCount-1 do begin
        if i mod 1000 = 0 then begin
          Form1.Caption := 'Loading row '+IntToStr(i)+' of '+IntToStr(StringGrid_Lines.RowCount-1);
          Form1.Update;
        end;

        StringGrid_Lines.Cells[1, i] := sSL.Strings[StrToInt(StringGrid_Lines.Cells[2, i])];
      end;
      Form1.Caption := cVersion;
    finally
      sSL.Free;
    end;
  end;

  StringGrid_Lines.EndUpdate(true);
end;

procedure TForm1.Button_ChangeAllClick(Sender: TObject);
var
  i: Integer;
  sLine: String;
begin
  sLine := StringGrid_Lines.Cells[0, StringGrid_Lines.Row];

  Form1.Color := clBlue;
  Form1.Update;

  if CheckBox_ChangeAllIgnoreTransl.checked then begin
    for i := 1 to StringGrid_Lines.RowCount-1 do begin
      if (StringGrid_Lines.Cells[0, i] = sLine) then begin
        if StringGrid_Lines.Cells[0, i] = StringGrid_Lines.Cells[1, i] then StringGrid_Lines.Cells[1, i] := LabeledEdit_LineTransl.Text;
      end;
    end;
  end else begin
    for i := 1 to StringGrid_Lines.RowCount-1 do begin
      if (StringGrid_Lines.Cells[0, i] = sLine) then begin
        StringGrid_Lines.Cells[1, i] := LabeledEdit_LineTransl.Text;
      end;
    end;
  end;

  Form1.Color := clBtnFace;
end;

procedure TForm1.Button_DeleteClick(Sender: TObject);

  procedure DeleteFile(sFile: String);
  begin
    if FileExists(sFile) then begin
      SysUtils.DeleteFile(sFile);
    end;
  end;

var
  i: Integer;
  sPath, sFile: String;
  sSL: tStringList;
  bSaveSuccess: Boolean;
begin
  PageControl1.TabIndex := 1;

  if StringGrid_Languages.RowCount < 4 then MessageDlg('Warning', 'Warning: Reborn will not allow a language change if there are fewer than 2 languages', mtWarning, [mbOK], 0);
  if MessageDlg('Remove?', Format('Are you sure that you want to remove the language %s (%s)?', [StringGrid_Languages.Cells[0, StringGrid_Languages.Row], StringGrid_Languages.Cells[1, StringGrid_Languages.Row]]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
    if MessageDlg('Delete its files too?', Format('Do you also want to permanently delete the files for the language %s (%s)?', [StringGrid_Languages.Cells[0, StringGrid_Languages.Row], StringGrid_Languages.Cells[1, StringGrid_Languages.Row]]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then begin
      sPath := ExpandFileName(ExtractFileDir(Application.ExeName));
      sFile := StringGrid_Languages.Cells[1, StringGrid_Languages.Row];
      DeleteFile(sPath+'\Translations\'+sFile+'.temp');
      DeleteFile(sPath+'\Translations\'+sFile+'.txt.temp');
      DeleteFile(sPath+'\Translations\'+sFile+'.txt');
      DeleteFile(sPath+'\Data\'+sFile);
    end;

    StringGrid_Languages.DeleteRow(StringGrid_Languages.Row);

    sSL := tStringList.Create;
    try
      sSL.Add('LANGUAGES = [  ');
      for i := 1 to StringGrid_Languages.RowCount-1 do begin

        if i < StringGrid_Languages.RowCount-1 then begin
          sSL.Add(Format('  ["%s","%s"],', [StringGrid_Languages.Cells[0, i], StringGrid_Languages.Cells[1, i]]));
        end else begin
          sSL.Add(Format('  ["%s","%s"]', [StringGrid_Languages.Cells[0, i], StringGrid_Languages.Cells[1, i]]));
        end;
      end;
      sSL.Add(']');

      bSaveSuccess := true;
      try
        sSL.SaveToFile(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Translations\Languages.rb.temp'));
      except
        bSaveSuccess := false;
      end;

      if bSaveSuccess then sSL.SaveToFile(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Data\Mods\Languages.rb'));
    finally
      sSL.Free;
      StringGrid_Languages.Row := 1;
      StringGrid_LinesAfterSelection(nil, 0, 1);
    end;
  end;

  StringGrid_Lines.RowCount := 1;
  LabeledEdit_LangName.Text := '';
  LabeledEdit_LangFile.Text := '';
  LabeledEdit_LineOrig.Text := '';
  LabeledEdit_LineTransl.Text := '';

  Button_Delete.Enabled := false;
  Button_Save.Enabled := false;
  LabeledEdit_LangName.Enabled := false;
  LabeledEdit_LangFile.Enabled := false;
end;

procedure TForm1.Button_DistributeClick(Sender: TObject);

  function aZipFiles(sFileName, sDir: String; aFiles: aTStringDynArray): Boolean;
  var
    AZipper: TZipper;
    szPathEntry:String;
    i:Integer;
    ZEntries : TZipFileEntries;
    TheFileList:TStringList;
    RelativeDirectory:String;
  begin
    AZipper := TZipper.Create;
    try
      try
        AZipper.Filename := sFileName;
        RelativeDirectory:=sDir;
        AZipper.Clear;
        ZEntries := TZipFileEntries.Create(TZipFileEntry);
        // Verify valid directory
        If DirPathExists(RelativeDirectory) then
        begin
          // Construct the path to the directory BELOW RelativeDirectory
          // If user specifies 'C:\MyFolder\Subfolder' it returns 'C:\MyFolder\'
          // If user specifies 'C:\MyFolder' it returns 'C:\'
          // If user specifies 'C:\' it returns 'C:\'
          i:=RPos(PathDelim,ChompPathDelim(RelativeDirectory));
          szPathEntry:=LeftStr(RelativeDirectory,i);

          // Use the FileUtils.FindAllFiles function to get everything (files and folders) recursively
          TheFileList:=TstringList.Create;
          try
            //FindAllFiles(TheFileList, RelativeDirectory);
            for i := 0 to Length(aFiles)-1 do begin
              TheFileList.Add(aFiles[i]);
            end;

            for i:=0 to TheFileList.Count -1 do
            begin
              // Make sure the RelativeDirectory files are not in the root of the ZipFile
              ZEntries.AddFileEntry(TheFileList[i],CreateRelativePath(TheFileList[i],szPathEntry));
            end;
          finally
            TheFileList.Free;
          end;
        end;
        if (ZEntries.Count > 0) then
          AZipper.ZipFiles(ZEntries);
        except
          On E: EZipError do
            E.CreateFmt('Zipfile could not be created%sReason: %s', [LineEnding, E.Message])
        end;
      result := True;
    finally
      FreeAndNil(ZEntries);
      AZipper.Free;
    end;
  end;

var
  i: Integer;
  sDir: String;
  aFiles: aTStringDynArray;
  dDialog: TSaveDialog;
begin
  PageControl1.TabIndex := 1;

  sDir := ExtractFileDir(Application.ExeName);

  SetLength(aFiles, 2);
  aFiles[0] := sDir+'\Data\Mods\Languages.rb';
  aFiles[1] := sDir+'\Data\Mods\Languages_ScriptsFix.rb';

  for i := 1 to StringGrid_Languages.RowCount-1 do begin
    SetLength(aFiles, Length(aFiles)+2);
    aFiles[Length(aFiles)-2] := sDir+'\Data\'+StringGrid_Languages.Cells[1, i];
    aFiles[Length(aFiles)-1] := sDir+'\Translations\'+StringGrid_Languages.Cells[1, i]+'.txt';

    if FileExists(ExpandFileName(sDir+'\Translations\'+StringGrid_Languages.Cells[1, i]+'.temp')) then begin
      MessageDlg('Error', Format('Cannot distribute: %s (%s) has not been compiled yet.'#13#10'Please restart the game in order to compile it.', [StringGrid_Languages.Cells[0, i], StringGrid_Languages.Cells[1, i]]), mtError, [mbOK], 0);
      exit;
    end;
  end;

  dDialog := TSaveDialog.Create(self);
  dDialog.InitialDir := GetCurrentDir;
  dDialog.Filter := 'Any file|*.*|Zip file|*.zip';
  if LabeledEdit_LangFile.Text = '' then dDialog.FileName := 'Translations'
  else dDialog.FileName := String(LabeledEdit_LangFile.Text).SubString(0, Length(LabeledEdit_LangFile.Text)-4);
  dDialog.FilterIndex := 1;
  dDialog.DefaultExt := 'zip';

  Form1.Color := clBlue;
  Form1.Update;

  if dDialog.Execute then begin
    if aZipFiles(dDialog.FileName, sDir+'\Data\', aFiles) then MessageDlg('Success', 'Archive created successfuly!', mtConfirmation, [mbOK], 0)
    else MessageDlg('Error', 'Task failed :(', mtError, [mbOK], 0);
  end else begin
    MessageDlg('Aborted', 'Task failed successfully', mtError, [mbOK], 0);
  end;

  dDialog.Free;

  Form1.Color := clBtnFace;
end;

procedure TForm1.Button_FindClick(Sender: TObject);

  function aGetNextRow(iCurr: Integer): Integer;
  begin
    if RadioGroup_Find_Direction.Itemindex = 1 then begin
      result := iCurr-1;
      if result < 0 then result := StringGrid_Lines.RowCount-1;
    end else begin
      result := iCurr+1;
      if result > (StringGrid_Lines.RowCount-1) then result := 0;
    end;
  end;

  function aContains(sString, sQuery: String): Boolean;
  var
    i, i2: Integer;
    bRetVal: Boolean;
  begin
    result := false;

    if CheckBox_SearchSize.Checked then
      if Length(sString) <> Length(sQuery) then Exit;

    for i := 1 to (Length(sString)-Length(sQuery)+1) do begin
      bRetVal := true;
      for i2 := 1 to Length(sQuery) do begin
        if not (sString[i+i2-1] = sQuery[i2]) then begin
          bRetVal := false;
          break;
        end;
      end;
      if bRetVal then begin
        result := true;
        Exit;
      end;
    end;
  end;

  function aIsSearchMatch(sString, sQuery: String): Boolean;
  begin
    if CheckBox_Case.checked then result := aContains(sString, sQuery)
    else result := aContains(LowerCase(sString), sQuery);
  end;

var
  i, iCol, iCurr: Integer;
  sQuery: String;
  bNotFound: Boolean;
begin
  if LabeledEdit_Find_What.Text = '' then exit;

  Form1.Color := clBlue;
  Form1.Update;

  bNotFound := true;

  iCol := RadioGroup_Find_Where.Itemindex;
  if CheckBox_Case.checked then sQuery := LabeledEdit_Find_What.Text
  else sQuery := LowerCase(LabeledEdit_Find_What.Text);

  if RadioGroup_Find_Direction.Itemindex = 0 then iCurr := -1
  else iCurr := StringGrid_Lines.Row;

  if CheckBox_IgnoreTranslated.Checked then begin
    for i := 0 to StringGrid_Lines.RowCount-1 do begin
      iCurr := aGetNextRow(iCurr);

      if StringGrid_Lines.Cells[0, iCurr] = StringGrid_Lines.Cells[1, iCurr] then begin
        if aIsSearchMatch(StringGrid_Lines.Cells[iCol, iCurr], sQuery) then begin
          StringGrid_Lines.RowHeights[iCurr] := StringGrid_Lines.DefaultRowHeight;
          StringGrid_Lines.Row := iCurr;
          if RadioGroup_Find_Direction.Itemindex = 0 then RadioGroup_Find_Direction.Itemindex := 2;
          bNotFound := false;
          break;
        end;
      end;
    end;
  end else begin
    for i := 0 to StringGrid_Lines.RowCount-1 do begin
      iCurr := aGetNextRow(iCurr);

      if aIsSearchMatch(StringGrid_Lines.Cells[iCol, iCurr], sQuery) then begin
        StringGrid_Lines.RowHeights[iCurr] := StringGrid_Lines.DefaultRowHeight;
        StringGrid_Lines.Row := iCurr;
        if RadioGroup_Find_Direction.Itemindex = 0 then RadioGroup_Find_Direction.Itemindex := 2;
        bNotFound := false;
        break;
      end;
    end;
  end;

  Form1.Color := clBtnFace;

  if bNotFound then MessageDlg(':(', 'No result found', mtWarning, [mbOK], 0);
end;

procedure TForm1.Button_GroupDeleteClick(Sender: TObject);
var
  i, iParent: Integer;
  sString, sRange: String;
  bHide, bHadChildren: Boolean;
begin
  if gNotSelecting_Group AND (not (TreeView_Groups.Selected= nil)) then begin
    gNotSelecting_Group := false;

    bHadChildren := TreeView_Groups.Selected.HasChildren;
    if bHadChildren then sRange := '0-0'
    else begin
      if TryStrToint(LabeledEdit_GroupFrom.Text, i) AND TryStrToint(LabeledEdit_GroupTo.Text, i) then sRange := LabeledEdit_GroupFrom.Text+'-'+LabeledEdit_GroupTo.Text
      else sRange := '0-0';
    end;

    iParent := -1;
    bHide := false;
    if not (TreeView_Groups.Selected.Parent = nil) then begin
      sString := TreeView_Groups.Selected.Parent.Text;

      bHide := ((sString[1] = '(') AND (sString[Length(sString)] = ')'));
      if bHide then sString := sString.SubString(1, Length(sString)-2);

      iParent := TreeView_Groups.Selected.Parent.AbsoluteIndex;
    end;

    TreeView_Groups.Items.Delete(TreeView_Groups.Selected);

    if iParent >= 0 then begin
      if not TreeView_Groups.Items.Item[iParent].HasChildren then begin
        if bHide then TreeView_Groups.Items.Item[iParent].Text := '('+sString+' '+sRange+')'
        else TreeView_Groups.Items.Item[iParent].Text := sString+' '+sRange;
      end;
    end;

    LabeledEdit_GroupName.Text := '';
    LabeledEdit_GroupFrom.Text := '';
    LabeledEdit_GroupTo.Text := '';

    LabeledEdit_GroupName.Color := clDefault;
    LabeledEdit_GroupFrom.Color := clDefault;
    LabeledEdit_GroupTo.Color := clDefault;

    CheckBox_GroupHidden.Checked := false;

    gNotSelecting_Group := true;
  end;
end;

procedure TForm1.Button_GroupDownClick(Sender: TObject);
begin
  if TreeView_Groups.Selected.GetNextSibling = nil then begin
    if TreeView_Groups.Selected.Parent = nil then begin
      if not (TreeView_Groups.Items.Item[0] = nil) then
        TreeView_Groups.Selected.MoveTo(TreeView_Groups.Items.Item[0], naInsert);
    end else begin
      if not (TreeView_Groups.Selected.Parent.GetFirstChild = nil) then
        TreeView_Groups.Selected.MoveTo(TreeView_Groups.Selected.Parent.GetFirstChild, naInsert);
    end;
  end else begin
    TreeView_Groups.Selected.MoveTo(TreeView_Groups.Selected.GetNextSibling, naInsertBehind);
  end;
end;

procedure TForm1.Button_GroupJumpToClick(Sender: TObject);
var
  i, i2, iTarget, iRow, iDec: Integer;
  sString: String;
  nNode: TTreeNode;
  bFound: Boolean;
begin
  iRow := -1;
  if TreeView_Groups.Selected = nil then begin
    if StringGrid_Lines.RowCount > 1 then iRow := 1;
  end else begin
    nNode := TreeView_Groups.Selected;
    while nNode.HasChildren do nNode := nNode.GetFirstChild;
    sString := nNode.Text;

    iTarget := 0;
    iDec := 1;
    bFound := false;
    for i := Length(sString) downto 1 do begin
      if TryStrToInt(sString[i], i2) then begin
        if bFound then begin
          iTarget := i2*iDec+iTarget;
          iDec := iDec*10;
        end;
      end else begin
        if sString[i] = '-' then bFound := true;
        if sString[i] = ' ' then break;
      end;
    end;

    for i := 1 to StringGrid_Lines.RowCount-1 do begin
      if TryStrToint(StringGrid_Lines.Cells[2, i], i2) then if (i2 = iTarget) OR (i2 = (iTarget+1)) then begin
        iRow := i;
      end;
    end;
  end;

  if iRow > 0 then begin
    PageControl1.TabIndex := 1;
    StringGrid_Lines.RowHeights[iRow] := StringGrid_Lines.DefaultRowHeight;
    StringGrid_Lines.Row := iRow;
  end else begin
    MessageDlg('Unable to can', 'Cannot find a line to jump to.', mtError, [mbOK], 0);
  end;
end;

procedure TForm1.Button_GroupNewClick(Sender: TObject);
var
  sString: String;
begin
  if TreeView_Groups.Selected = nil then begin
    sString := '  ';
  end else begin
    if TreeView_Groups.Selected.Parent = nil then sString := '  '
    else sString := TreeView_Groups.Selected.Parent.Text;
  end;

  if ((sString[1] = '(') AND (sString[Length(sString)] = ')')) then TreeView_Groups.Selected := TreeView_Groups.Items.Add(TreeView_Groups.Selected, '(New group 0-0)')
  else TreeView_Groups.Selected := TreeView_Groups.Items.Add(TreeView_Groups.Selected, 'New group 0-0');
end;

procedure TForm1.Button_GroupSaveClick(Sender: TObject);

  procedure aAddNode(nNode: TTreeNode; sLevel: String; var sSL: tStringList);
  var
    i, iFirst, iLast: Integer;
  begin
    sSL.Add(sLevel+nNode.Text);

    if nNode.HasChildren then begin
      iFirst := nNode.GetFirstChild.Index;
      iLast := nNode.GetLastChild.Index;

      for i := iFirst to iLast do begin
          aAddNode(nNode.Items[i], sLevel+#9, sSL);
      end;
    end;
  end;

var
  i: Integer;
  sFile: String;
  sSL: tStringList;
  bSaveSuccess: Boolean;
begin
  sFile := ExtractFileDir(Application.ExeName)+'\Translations\Groups.txt';

  Form1.Color := clBlue;
  Form1.Update;

  sSL := tStringList.Create;
  try
    for i := 0 to TreeView_Groups.Items.Count-1 do begin
      if TreeView_Groups.Items.Item[i].Parent = nil then aAddNode(TreeView_Groups.Items.Item[i], '', sSL);
    end;

    bSaveSuccess := true;
    try
      sSL.SaveToFile(ExpandFileName(sFile+'.temp'));
    except
      bSaveSuccess := false;
    end;

    if bSaveSuccess then sSL.SaveToFile(ExpandFileName(sFile));
  finally
    sSL.Free;
  end;

  Form1.Color := clBtnFace;
end;

procedure TForm1.Button_GroupSubClick(Sender: TObject);
var
  sFrom, sTo: String;
begin
  sFrom := '0';
  sTo := '0';

  if not (TreeView_Groups.Selected = nil) then if not TreeView_Groups.Selected.HasChildren then begin
    TreeView_GroupsSelectionChanged(Sender);

    sFrom := LabeledEdit_GroupFrom.Text;
    sTo := LabeledEdit_GroupTo.Text;

    if CheckBox_GroupHidden.Checked then TreeView_Groups.Selected.Text := '('+LabeledEdit_GroupName.Text+')'
    else TreeView_Groups.Selected.Text := LabeledEdit_GroupName.Text;
  end;

  if CheckBox_GroupHidden.Checked then TreeView_Groups.Selected := TreeView_Groups.Items.AddChild(TreeView_Groups.Selected, '(New group '+sFrom+'-'+sTo+')')
  else TreeView_Groups.Selected := TreeView_Groups.Items.AddChild(TreeView_Groups.Selected, 'New group '+sFrom+'-'+sTo);
end;

procedure TForm1.Button_GroupUpClick(Sender: TObject);
begin
  if TreeView_Groups.Selected.GetPrevSibling = nil then begin
    if not (TreeView_Groups.Selected.GetLastSibling = nil) then
      TreeView_Groups.Selected.MoveTo(TreeView_Groups.Selected.GetLastSibling, naInsertBehind);
  end else begin
    TreeView_Groups.Selected.MoveTo(TreeView_Groups.Selected.GetPrevSibling, naInsert);
  end;
end;

procedure TForm1.Button_LoadClick(Sender: TObject);

  function aMessageDlg(const sMsg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons; Caption: array of String; dlgcaption: string): Integer;
  var
    aMsgdlg: TForm;
    i: Integer;
    Captionindex: Integer;
  begin
    aMsgdlg := createMessageDialog(sMsg, DlgTypt, button);
    aMsgdlg.Caption := dlgcaption;
    aMsgdlg.BiDiMode := bdLeftToRight;
    Captionindex := 0;
    for i := 0 to aMsgdlg.componentcount - 1 do begin
        if Captionindex <= High(Caption) then
          Tbutton(aMsgdlg.components[i]).Caption := Caption[Captionindex];
        inc(Captionindex);
    end;
    Result := aMsgdlg.Showmodal;
  end;

  function aNormalize(sString: String): String;
  var
    i: Integer;
  begin
    result := '';
    for i := 1 to Length(sString) do begin
      if not (sString[i] = ' ') then result := result+sString[i];
    end;
  end;

  procedure aLoadFile(sFile: String);
  var
    i, i2, iCount, iMax: Integer;
    sSL: TStringList;
    aTempl, aArr: aTStringDynArray;
    aArrN: aTIntDynArray;
  begin
    PageControl1.TabIndex := 1;
    StringGrid_Lines.BeginUpdate;

    //Template lines
    SetLength(aTempl, StringGrid_Lines.RowCount-1);
    for i := 0 to Length(aTempl)-1 do begin
      aTempl[i] := aNormalize(StringGrid_Lines.Cells[0, i+1]);
    end;

    sSL := tStringList.Create;
    try
      sSL.LoadFromFile(sFile);

      //Lines to import
      SetLength(aArr, sSL.Count);
      SetLength(aArrN, sSL.Count);
      for i := 0 to sSL.Count-1 do begin
        aArr[i] := aNormalize(sSL.Strings[i]);
        aArrN[i] := i;
      end;

      //Now compare them
      iCount := 0;
      for i := 0 to Length(aTempl)-1 do begin
        if i mod 100 = 0 then begin
          Form1.Caption := 'Importing row '+IntToStr(i+1)+' of '+IntToStr(Length(aTempl));
          Form1.Update;
        end;

        iMax := Length(aArr)-1-iCount;
        for i2 := 0 to iMax-1 do begin
          if aTempl[i] = aArr[i2] then begin
            StringGrid_Lines.Cells[1, i+1] := sSL.Strings[aArrN[i2+1]];

            aArr[i2] := aArr[iMax-1];
            aArr[i2+1] := aArr[iMax];

            aArrN[i2] := aArrN[iMax-1];
            aArrN[i2+1] := aArrN[iMax];

            iCount := iCount+2;

            break;
          end;
        end;
      end;
    finally
      sSL.Free;
    end;

    StringGrid_Lines.EndUpdate(true);
    Form1.Caption := cVersion;
  end;

  procedure aMergeFile(sFile: String; iStart, iEnd: Integer);
  var
    i, iLine: Integer;
    sSL: TStringList;
  begin
    PageControl1.TabIndex := 1;
    StringGrid_Lines.BeginUpdate;

    sSL := tStringList.Create;
    try
      sSL.LoadFromFile(sFile);
      for i := 1 to StringGrid_Lines.RowCount-1 do begin
        iLine := StrToInt(StringGrid_Lines.Cells[2, i]);
        if (iLine >= iStart) AND (iLine <= iEnd) then begin
           StringGrid_Lines.Cells[1, i] := sSL.Strings[iLine];
        end;
      end;
    finally
      sSL.Free;
    end;

    StringGrid_Lines.EndUpdate(true);
  end;

  procedure aRangeToBools(sString: String; var aImport: aTBoolDynArray);
  var
    i, i2, iFrom, iTo, iDec: Integer;
    bFound: Boolean;
  begin
    iFrom := 0;
    iTo := 0;

    bFound := false;
    iDec := 1;

    for i := Length(sString) downto 1 do begin
      if TryStrToInt(sString[i], i2) then begin
        if bFound then iFrom := iFrom+i2*iDec
        else iTo := iTo+i2*iDec;

        iDec := iDec*10;
      end else begin
        if sString[i] = '-' then begin
          bFound := true;
          iDec := 1;
        end;
        if sString[i] = ' ' then break;
      end;
    end;

    if iTo >= Length(aImport) then begin
      i2 := Length(aImport);
      SetLength(aImport, iTo+1);
      for i := i2 to Length(aImport)-1 do aImport[i] := false;
    end;

    for i := iFrom to iTo do aImport[i] := true;
  end;

  function aMergeFileGroups(sFile: String): Integer;
  var
    i, iCount, iLine: Integer;
    aGroups, aImport: aTBoolDynArray;
    sSL: tStringList;
    dDlg: TForm;
    Button_Done, Button_Abort: TButton;
    aTreeView: TTreeView;
  begin
    iCount := 0;

    dDlg := TForm.Create(nil);
    try
      dDlg.SetBounds(((Form1.Left+Form1.Width) div 2)-250, ((Form1.Top+Form1.Height) div 2)-150, 500, 300);
      dDlg.Caption:='Select groups';
      dDlg.BorderIcons := [];
      dDlg.OnResize := @dDlg_FormResize;

      Button_Done := TButton.Create(dDlg);
      Button_Done.Caption := 'Done';
      Button_Done.SetBounds(0, 0, 75, 25);
      Button_Done.Parent := dDlg;
      Button_Done.OnClick := @dDlg_Button_DoneClick;

      Button_Abort := TButton.Create(dDlg);
      Button_Abort.Caption := 'Abort';
      Button_Abort.SetBounds(0, 30, 75, 25);
      Button_Abort.Parent := dDlg;
      Button_Abort.OnClick := @dDlg_Button_AbortClick;

      aTreeView := TTreeView.Create(dDlg);
      aTreeView.SetBounds(80, 0, dDlg.Width-80, dDlg.Height);
      aTreeView.Items := TreeView_Groups.Items;
      aTreeView.Parent := dDlg;
      aTreeView.ReadOnly := true;
      aTreeView.Images := ImageList1;
      aTreeView.OnSelectionChanged := @dDlg_TreeViewSelectionChanged;

      for i := 0 to aTreeView.Items.Count-1 do begin
        aTreeView.Items.Item[i].ImageIndex := 1;
        aTreeView.Items.Item[i].SelectedIndex := 1;
        aTreeView.Items.Item[i].StateIndex := 1;
      end;

      dDlg.ShowModal;

      SetLength(aGroups, aTreeView.Items.Count);
      for i := 0 to aTreeView.Items.Count-1 do begin
        aGroups[i] := (aTreeView.Items.Item[i].ImageIndex = 0);
        if aGroups[i] then iCount := iCount+1;
      end;
    finally
      FreeAndNil(dDlg);
    end;

    result := iCount;

    if iCount > 0 then begin
      SetLength(aImport, 0);

      for i := 0 to TreeView_Groups.Items.Count-1 do begin
        if aGroups[i] then if not TreeView_Groups.Items.Item[i].HasChildren then begin
          aRangeToBools(TreeView_Groups.Items.Item[i].Text, aImport)
        end;
      end;

      PageControl1.TabIndex := 1;
      StringGrid_Lines.BeginUpdate;

      sSL := tStringList.Create;
      try
        sSL.LoadFromFile(sFile);
        for i := 1 to StringGrid_Lines.RowCount-1 do begin
          iLine := StrToInt(StringGrid_Lines.Cells[2, i]);

          if iLine < Length(aImport) then if aImport[iLine] then StringGrid_Lines.Cells[1, i] := sSL.Strings[iLine];
        end;
      finally
        sSL.Free;
      end;

      StringGrid_Lines.EndUpdate(true);
    end;
  end;

var
  dDialog: tOpenDialog;
  iCount, iBut, iBut2, iStart, iEnd: Integer;
  sName, sFile, sString: String;
  bNewFile: Boolean;
begin
  iBut := aMessageDlg('Do you want to import the translation from a previous episode or to merge a translation into the currently selected one?', mtConfirmation, [mbYes, mbOK, mbCancel], ['Import', 'Merge', 'Abort'], 'Import/merge?');

  if iBut = mrCancel then begin
    MessageDlg('Aborted', 'Task failed successfully', mtError, [mbOK], 0);
  end else begin
    if (iBut = mrYes) OR (LabeledEdit_LangName.Text = '') OR (LabeledEdit_LangFile.Text = '') OR (StringGrid_Lines.RowCount < 2) then begin
      sName := InputBox('Name', 'Please type the language name for this translation (leave empty to abort)', '');
      sFile := LowerCase(sName)+'.dat';

      if FileExists(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Translations\'+sFile+'.txt')) then begin
        MessageDlg('Error', Format('The file \Translations\%s.txt already exists', [sFile]), mtError, [mbOK], 0);
        Exit;
      end;
      if sName = '' then begin
        MessageDlg('Aborted', 'Task failed successfully', mtError, [mbOK], 0);
        Exit;
      end;

      bNewFile := true;
    end else begin
      sName := LabeledEdit_LangName.Text;
      sFile := LabeledEdit_LangFile.Text;

      bNewFile := false;
    end;

    dDialog := TOpenDialog.Create(self);
    dDialog.InitialDir := GetCurrentDir;
    dDialog.Options := [ofFileMustExist];
    dDialog.Filter := 'Text files only|*.txt';

    if dDialog.Execute then begin
      if not (dDialog.FileName = '') then begin
        if bNewFile then begin
          PageControl1.TabIndex := 1;

          StringGrid_Languages.RowCount := StringGrid_Languages.RowCount+1;
          StringGrid_Languages.Cells[0, StringGrid_Languages.RowCount-1] := sName;
          StringGrid_Languages.Cells[1, StringGrid_Languages.RowCount-1] := sFile;

          StringGrid_Languages.Row := StringGrid_Languages.RowCount-1;

          Button_Delete.Enabled := true;
          Button_Save.Enabled := true;
          LabeledEdit_LangName.Enabled := true;
          LabeledEdit_LangFile.Enabled := true;

          aLoadTemplate();
          CheckBox_ShowUntranslatedOnlyChange(Sender);
        end;

        if iBut = mrYes then begin
          Form1.Color := clBlue;
          Form1.Update;

          aLoadFile(dDialog.FileName);
          if aMessageDlg('Task completed', mtConfirmation, [mbYes, mbOK], ['Save', 'Done'], 'Success') = mrYes then begin
            Button_SaveClick(Sender);
          end;

          LabeledEdit_LangName.Text := sName;
          LabeledEdit_LangFile.Text := sFile;

          PageControl1.TabIndex := 1;
          PageControl1Change(Sender);
          StringGrid_LinesAfterSelection(nil, 0, 1);
        end else begin
          iBut2 := aMessageDlg('Do you prefer to choose the section to merge by lines or by groups?', mtConfirmation, [mbYes, mbOK, mbCancel], ['Lines', 'Groups', 'Abort'], 'Merge how?');

          if iBut2 = mrYes then begin
            sString := '';
            while not TryStrToInt(sString, iStart) do begin
              sString := InputBox('Start', Format('First line number to be copied? (from the file %s)', [ExtractFileName(dDialog.FileName)]), '');

              if sString = '' then break;
            end;

            if not (sString = '') then begin
              sString := '';
              while not TryStrToInt(sString, iEnd) do begin
                sString := InputBox('End', Format('Last line number to be copied? (from the file %s)', [ExtractFileName(dDialog.FileName)]), '');

                if sString = '' then break;
              end;
            end;

            Form1.Color := clBlue;
            Form1.Update;

            if not (sString = '') then begin
              aMergeFile(dDialog.FileName, iStart, iEnd);
              if aMessageDlg('Task completed', mtConfirmation, [mbYes, mbOK], ['Save', 'Done'], 'Success') = mrYes then begin
                Button_SaveClick(Sender);
              end;
            end;
          end;

          if iBut2 = mrOk then begin
            Form1.Color := clBlue;
            Form1.Update;

            iCount := aMergeFileGroups(dDialog.FileName);
            if iCount > 0 then begin
              if iCount > 1 then begin
                if aMessageDlg(Format('Task completed; merged %s groups', [IntToStr(iCount)]), mtConfirmation, [mbYes, mbOK], ['Save', 'Done'], 'Success') = mrYes then begin
                  Button_SaveClick(Sender);
                end;
              end else begin
                if aMessageDlg('Task completed; merged 1 group', mtConfirmation, [mbYes, mbOK], ['Save', 'Done'], 'Success') = mrYes then begin
                  Button_SaveClick(Sender);
                end;
              end;
            end else begin
              MessageDlg('Aborted', 'No groups were merged.', mtError, [mbOK], 0);
            end;
          end;

          PageControl1.TabIndex := 1;
          PageControl1Change(Sender);
          StringGrid_LinesAfterSelection(nil, 0, 1);

          LabeledEdit_LangName.Text := sName;
          LabeledEdit_LangFile.Text := sFile;
        end;

        Form1.Color := clBtnFace;
      end;
    end else begin
      MessageDlg('Aborted', 'Task failed successfully', mtError, [mbOK], 0);
    end;

    dDialog.Free;
  end;
end;

procedure TForm1.Button_NewClick(Sender: TObject);

  function aMessageDlg(const sMsg: string; DlgTypt: TmsgDlgType; button: TMsgDlgButtons; Caption: array of String; dlgcaption: string): Integer;
  var
    aMsgdlg: TForm;
    i: Integer;
    Captionindex: Integer;
  begin
    aMsgdlg := createMessageDialog(sMsg, DlgTypt, button);
    aMsgdlg.Caption := dlgcaption;
    aMsgdlg.BiDiMode := bdLeftToRight;
    Captionindex := 0;
    for i := 0 to aMsgdlg.componentcount - 1 do begin
        if Captionindex <= High(Caption) then
          Tbutton(aMsgdlg.components[i]).Caption := Caption[Captionindex];
        inc(Captionindex);
    end;
    Result := aMsgdlg.Showmodal;
  end;

var
  sName, sFile: String;
begin
  PageControl1.TabIndex := 1;

  sName := InputBox('Name', 'Please type the language name for this translation (leave empty to abort)', '');
  sFile := LowerCase(sName)+'.dat';

  if FileExists(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Translations\'+sFile+'.txt')) then begin
    MessageDlg('Error', Format('The file \Translations\%s.txt already exists', [sFile]), mtError, [mbOK], 0);
    sName := '';
  end;

  if sName = '' then begin
    MessageDlg('Aborted', 'Task failed successfully', mtError, [mbOK], 0);
  end else begin
    Form1.Color := clBlue;
    Form1.Update;

    LabeledEdit_LangName.Text := sName;
    LabeledEdit_LangFile.Text := sFile;

    StringGrid_Languages.RowCount := StringGrid_Languages.RowCount+1;
    StringGrid_Languages.Cells[0, StringGrid_Languages.RowCount-1] := sName;
    StringGrid_Languages.Cells[1, StringGrid_Languages.RowCount-1] := sFile;

    StringGrid_Languages.Row := StringGrid_Languages.RowCount-1;

    Button_Delete.Enabled := true;
    Button_Save.Enabled := true;
    LabeledEdit_LangName.Enabled := true;
    LabeledEdit_LangFile.Enabled := true;

    aLoadTemplate();

    StringGrid_Lines.Row := 1;
    StringGrid_LinesAfterSelection(nil, 0, 1);

    Form1.Color := clBtnFace;
    Form1.Update;

    if aMessageDlg('Task completed', mtConfirmation, [mbYes, mbOK], ['Save', 'Done'], 'Success') = mrYes then begin
      Button_SaveClick(Sender);
    end;
  end;
end;

procedure TForm1.Button_SaveClick(Sender: TObject);
var
  i: Integer;
  aArr: aTNameFileDynArray;
  sSL: TStringList;
  bSaveSuccess: Boolean;
  sDir: String;
begin
  PageControl1.TabIndex := 1;

  if (LabeledEdit_LangName.Text = '') OR (LabeledEdit_LangFile.Text = '') then begin
    MessageDlg('Error: name not valid', 'Cannot save without both a file name and a language name', mtError, [mbOK], 0);
    exit;
  end;

  sDir := ExtractFileDir(Application.ExeName);

  Form1.Color := clBlue;
  Form1.Update;

  //Update the translations list
  SetLength(aArr, 0);
  for i := 1 to StringGrid_Languages.RowCount-1 do begin
    if i = StringGrid_Languages.Row then begin
      SetLength(aArr, Length(aArr)+1);
      aArr[Length(aArr)-1].sFile := LabeledEdit_LangFile.Text;
      aArr[Length(aArr)-1].sName := LabeledEdit_LangName.Text;
    end else begin
      if LowerCase(LabeledEdit_LangFile.Text) = LowerCase(StringGrid_Languages.Cells[1, i]) then begin
        if not (MessageDlg('Overwrite?', Format('This language file already exists; overwrite %s (%s)?', [StringGrid_Languages.Cells[0, i], StringGrid_Languages.Cells[1, i]]), mtConfirmation, mbOKCANCEL, 0) = mrOK) then begin
          MessageDlg('Aborted', 'The translation was not saved', mtError, [mbOK], 0);
          Form1.Color := clBtnFace;
          exit;
        end;
      end else begin
        SetLength(aArr, Length(aArr)+1);
        aArr[Length(aArr)-1].sFile := StringGrid_Languages.Cells[1, i];
        aArr[Length(aArr)-1].sName := StringGrid_Languages.Cells[0, i];
      end;
    end;
  end;

  StringGrid_Languages.Cells[0, StringGrid_Languages.Row] := LabeledEdit_LangName.Text;
  StringGrid_Languages.Cells[1, StringGrid_Languages.Row] := LabeledEdit_LangFile.Text;

  sSL := tStringList.Create;
  try
    sSL.Add('LANGUAGES = [  ');
    for i := 0 to Length(aArr)-1 do begin
      if i < Length(aArr)-1 then begin
        sSL.Add(Format('  ["%s","%s"],', [aArr[i].sName, aArr[i].sFile]));
      end else begin
        sSL.Add(Format('  ["%s","%s"]', [aArr[i].sName, aArr[i].sFile]));
      end;
    end;
    sSL.Add(']');

    bSaveSuccess := true;
    try
      sSL.SaveToFile(ExpandFileName(sDir+'\Translations\Languages.rb.temp'));
    except
      bSaveSuccess := false;
    end;

    if bSaveSuccess then sSL.SaveToFile(ExpandFileName(sDir+'\Data\Mods\Languages.rb'));
  finally
    sSL.Free;
  end;

  //Save
  sSL := tStringList.Create;
  try
    //Placeholder, will tell the game that this needs to be compiled
    sSL.SaveToFile(ExpandFileName(sDir+'\Translations\'+LabeledEdit_LangFile.Text+'.temp'));

    //Now actually save the translation
    sSL.LoadFromFile(ExpandFileName(sDir+'\intl.txt'));

    for i := 1 to StringGrid_Lines.RowCount-1 do begin
      sSL.Strings[StrToInt(StringGrid_Lines.Cells[2, i])] := StringGrid_Lines.Cells[1, i];
    end;

    bSaveSuccess := true;
    try
      sSL.SaveToFile(ExpandFileName(sDir+'\Translations\'+LabeledEdit_LangFile.Text+'.txt.temp'));
    except
      bSaveSuccess := false;
    end;

    if bSaveSuccess then sSL.SaveToFile(ExpandFileName(sDir+'\Translations\'+LabeledEdit_LangFile.Text+'.txt'));
  finally
    sSL.Free;
  end;

  Form1.Color := clBtnFace;
end;

procedure TForm1.CheckBox_ShowUntranslatedOnlyChange(Sender: TObject);
var
  i, iHeight: Integer;
  sString: String;
begin
  Form1.Color := clBlue;
  Form1.Update;

  StringGrid_Lines.BeginUpdate;
  for i := 1 to StringGrid_Lines.RowCount-1 do begin
    if i = StringGrid_Lines.Row then iHeight := StringGrid_Lines.DefaultRowHeight
    else begin
      sString := StringGrid_Lines.Cells[3, i];
      if Length(sString) < 1 then sString := '5';
      if (sString[1] = '(') AND (sString[Length(sString)] = ')') then iHeight := 0
      else begin
        if CheckBox_ShowUntranslatedOnly.Checked then begin
          if StringGrid_Lines.Cells[0, i] = StringGrid_Lines.Cells[1, i] then begin
            iHeight := StringGrid_Lines.DefaultRowHeight;
          end else begin
            iHeight := 0;
          end;
        end else iHeight := StringGrid_Lines.DefaultRowHeight;
      end;

      if StringGrid_Lines.RowHeights[i] <> iHeight then StringGrid_Lines.RowHeights[i] := iHeight;
    end;
  end;
  StringGrid_Lines.EndUpdate(true);

  Form1.Color := clBtnFace;
end;

procedure TForm1.CheckBox_ChangeAllChange(Sender: TObject);
begin
  Button_ChangeAll.enabled := not CheckBox_ChangeAll.checked;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  sSL: tStringList;
  sFile: String;
  bSaveSuccess: Boolean;
begin
  if Form1.Caption = cVersion then begin //Prevent saving when never shown or while working
    sFile := ExtractFileDir(Application.ExeName)+'\Translations\GUI.txt';

    sSL := tStringList.Create;
    try
      sSL.Add(IntToStr(StringGrid_Languages.Row));
      sSL.Add(IntToStr(StringGrid_Lines.Row));
      sSL.Add(IntToStr(PageControl1.TabIndex));
      sSL.Add(BoolToStr(CheckBox_ShowUntranslatedOnly.Checked));
      sSL.Add(BoolToStr(CheckBox_ChangeAll.Checked));
      sSL.Add(BoolToStr(CheckBox_ChangeAllIgnoreTransl.Checked));

      bSaveSuccess := true;
      try
        sSL.SaveToFile(ExpandFileName(sFile+'.temp'));
      except
        bSaveSuccess := false;
      end;

      if bSaveSuccess then sSL.SaveToFile(ExpandFileName(sFile));
    finally
      sSL.Free;
    end;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
var
  i, idX, iOldX, iOldX2: Integer;
begin
  //Update the scrollbox
  ScrollBox1.Width := Form1.Width;
  ScrollBox1.Height := Form1.Height;

  //Get the old coordinates
  iOldX := Button_New.Left;
  iOldX2 := LabeledEdit_LineTransl.Left;

  //Resize the language grid
  i := Form1.Width-24-LabeledEdit_LangName.Width-24-Button_Save.Width-32-16;
  if i < 116 then i := 116;
  StringGrid_Languages.Width := i;
  StringGrid_Lines.Width := i-8;

  //Move everything
  idX := 16+StringGrid_Languages.Width+24-iOldX;
  for i := 0 to ScrollBox1.ControlCount-1 do ScrollBox1.Controls[i].Left := ScrollBox1.Controls[i].Left+idX;

  idX := StringGrid_Lines.Width+8-iOldX2;
  for i := 0 to Panel_Lines.ControlCount-1 do Panel_Lines.Controls[i].Left := Panel_Lines.Controls[i].Left+idX;

  //Resize the tabs
  i := Form1.Width-16-32;
  idX := LabeledEdit_LangName.Left+LabeledEdit_LangName.Width-PageControl1.Left;
  if i < idX then i := idX;
  PageControl1.Width := i;
  Panel_Lines.Width := i;
  Panel_Groups.Width := i;
  TreeView_Groups.Width := i-8-TreeView_Groups.Left;

  //Finish the X movement
  Label1.Left := 16;
  StringGrid_Languages.Left := 16;
  PageControl1.Left := 16;
  StringGrid_Lines.Left := 0;

  //Separator
  Shape_Separator.Left := 16;
  Shape_Separator.Width := LabeledEdit_LangName.Left+LabeledEdit_LangName.Width-Shape_Separator.Left;

  //Resize Y
  i := Form1.Height-PageControl1.Top-32;
  idX := 16+CheckBox_SearchSize.Top+CheckBox_SearchSize.Height+16;
  if i < idX then i := idX;
  PageControl1.Height := i;
  Panel_Lines.Height := i;
  Panel_Groups.Height := i;
  StringGrid_Lines.Height := i-28;
  TreeView_Groups.Height := i-28;
end;

procedure TForm1.FormShow(Sender: TObject);

  function aGetLanguageName(sString: String): string;
  var
    i: Integer;
    bFound: Boolean;
  begin
    bFound := false;
    result := '';

    for i := 1 to Length(sString) do begin
      if sString[i] = '"' then begin
        if bFound then Exit
        else bFound := true;
      end else begin
        if bFound then result := result+sString[i];
      end;
    end;
  end;

  function aGetFileName(sString: String): string;
  var
    i, iFound: Integer;
  begin
    iFound := 0;
    result := '';

    for i := 1 to Length(sString) do begin
      if sString[i] = '"' then begin
        iFound := iFound+1;
        if iFound > 3 then Exit;
      end else begin
        if iFound = 3 then result := result+sString[i];
      end;
    end;
  end;

  procedure aCheckCompileMod(sFile: String);
  var
    sSL: TStringList;
  begin
    if not FileExists(sFile) then begin
      sSL := tStringList.Create;
      try
        sSL.Add('def aaapbCompileTextLanguages');
        sSL.Add('  for i in 0...LANGUAGES.length');
        sSL.Add('    if safeExists?("./Translations/"+LANGUAGES[i][1]+".temp")');
        sSL.Add('      aaapbCompileTextLanguages_One(LANGUAGES[i][1])');
        sSL.Add('      File.delete("./Translations/"+LANGUAGES[i][1]+".temp")');
        sSL.Add('    end');
        sSL.Add('  end');
        sSL.Add('end');
        sSL.Add('');
        sSL.Add('def aaapbCompileTextLanguages_One(sFile)');
        sSL.Add('  outfile=File.open("./Data/"+sFile,"wb")');
        sSL.Add('  begin');
        sSL.Add('    intldat=pbGetText("./Translations/"+sFile+".txt")');
        sSL.Add('    Marshal.dump(intldat,outfile)');
        sSL.Add('  rescue');
        sSL.Add('    raise');
        sSL.Add('  ensure');
        sSL.Add('    outfile.close');
        sSL.Add('  end');
        sSL.Add('end');
        sSL.Add('');
        sSL.Add('aaapbCompileTextLanguages');

        sSL.SaveToFile(sFile);
      finally
        sSL.Free;
      end;
    end;
  end;

  procedure aCheckScriptsFixMod(sFile: String);
  var
    sSL: TStringList;
  begin
    if not FileExists(sFile) then begin
      sSL := tStringList.Create;
      try
        sSL.Add('def pbChooseLanguage');
        sSL.Add('  commands=[]');
        sSL.Add('  for lang in LANGUAGES');
        sSL.Add('    commands.push(lang[0])');
        sSL.Add('  end');
        sSL.Add('  return aaaSaveLanguage(Kernel.pbShowCommands(nil,commands)) #####MODDED, was return Kernel.pbShowCommands(nil,commands)');
        sSL.Add('end');
        sSL.Add('');
        sSL.Add('#####MODDED');
        sSL.Add('def aaaSaveLanguage(iLang)');
        sSL.Add('  file = File.open(RTP.getSaveFileName("Default_Language.rxdata"),"wb")');
        sSL.Add('  file.seek(0)');
        sSL.Add('  file.write(iLang)');
        sSL.Add('  file.close');
        sSL.Add('  ');
        sSL.Add('  return iLang');
        sSL.Add('end');
        sSL.Add('');
        sSL.Add('def aaaLoadLanguage');
        sSL.Add('  if safeExists?(RTP.getSaveFileName("Default_Language.rxdata"))');
        sSL.Add('    file = File.open(RTP.getSaveFileName("Default_Language.rxdata"))');
        sSL.Add('    file.seek(0)');
        sSL.Add('    sLang = file.readline');
        sSL.Add('    iLang = sLang.to_i');
        sSL.Add('    file.close');
        sSL.Add('    ');
        sSL.Add('    if iLang < LANGUAGES.length');
        sSL.Add('      $PokemonSystem.language = iLang');
        sSL.Add('      pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])');
        sSL.Add('    end');
        sSL.Add('  end');
        sSL.Add('end');
        sSL.Add('');
        sSL.Add('aaaLoadLanguage');
        sSL.Add('#####/MODDED');
        sSL.Add('');
        sSL.Add('#Fix an issue with translated keybindings; just remove _INTL');
        sSL.Add('module Keys  ');
        sSL.Add('  # Available keys');
        sSL.Add('  CONTROLSLIST = {');
        sSL.Add('    # Mouse buttons');
        sSL.Add('    "Backspace" => 0x08,');
        sSL.Add('    "Tab" => 0x09,');
        sSL.Add('    "Clear" => 0x0C,');
        sSL.Add('    "Enter" => 0x0D,');
        sSL.Add('    "Shift" => 0x10,');
        sSL.Add('    "Ctrl" => 0x11,');
        sSL.Add('    "Alt" => 0x12,');
        sSL.Add('    "Pause" => 0x13,');
        sSL.Add('    "Caps Lock" => 0x14,');
        sSL.Add('    # IME keys');
        sSL.Add('    "Esc" => 0x1B,');
        sSL.Add('    # More IME keys');
        sSL.Add('    "Space" => 0x20,');
        sSL.Add('    "Page Up" => 0x21,');
        sSL.Add('    "Page Down" => 0x22,');
        sSL.Add('    "End" => 0x23,');
        sSL.Add('    "Home" => 0x24,');
        sSL.Add('    "Left" => 0x25,');
        sSL.Add('    "Up" => 0x26,');
        sSL.Add('    "Right" => 0x27,');
        sSL.Add('    "Down" => 0x28,');
        sSL.Add('    "Select" => 0x29,');
        sSL.Add('    "Print" => 0x2A,');
        sSL.Add('    "Execute" => 0x2B,');
        sSL.Add('    "Print Screen" => 0x2C,');
        sSL.Add('    "Insert" => 0x2D,');
        sSL.Add('    "Delete" => 0x2E,');
        sSL.Add('    "Help" => 0x2F,');
        sSL.Add('    "0" => 0x30,');
        sSL.Add('    "1" => 0x31,');
        sSL.Add('    "2" => 0x32,');
        sSL.Add('    "3" => 0x33,');
        sSL.Add('    "4" => 0x34,');
        sSL.Add('    "5" => 0x35,');
        sSL.Add('    "6" => 0x36,');
        sSL.Add('    "7" => 0x37,');
        sSL.Add('    "8" => 0x38,');
        sSL.Add('    "9" => 0x39,');
        sSL.Add('    "A" => 0x41,');
        sSL.Add('    "B" => 0x42,');
        sSL.Add('    "C" => 0x43,');
        sSL.Add('    "D" => 0x44,');
        sSL.Add('    "E" => 0x45,');
        sSL.Add('    "F" => 0x46,');
        sSL.Add('    "G" => 0x47,');
        sSL.Add('    "H" => 0x48,');
        sSL.Add('    "I" => 0x49,');
        sSL.Add('    "J" => 0x4A,');
        sSL.Add('    "K" => 0x4B,');
        sSL.Add('    "L" => 0x4C,');
        sSL.Add('    "M" => 0x4D,');
        sSL.Add('    "N" => 0x4E,');
        sSL.Add('    "O" => 0x4F,');
        sSL.Add('    "P" => 0x50,');
        sSL.Add('    "Q" => 0x51,');
        sSL.Add('    "R" => 0x52,');
        sSL.Add('    "S" => 0x53,');
        sSL.Add('    "T" => 0x54,');
        sSL.Add('    "U" => 0x55,');
        sSL.Add('    "V" => 0x56,');
        sSL.Add('    "W" => 0x57,');
        sSL.Add('    "X" => 0x58,');
        sSL.Add('    "Y" => 0x59,');
        sSL.Add('    "Z" => 0x5A,');
        sSL.Add('    # Windows keys');
        sSL.Add('    "Numpad 0" => 0x60,');
        sSL.Add('    "Numpad 1" => 0x61,');
        sSL.Add('    "Numpad 2" => 0x62,');
        sSL.Add('    "Numpad 3" => 0x63,');
        sSL.Add('    "Numpad 4" => 0x64,');
        sSL.Add('    "Numpad 5" => 0x65,');
        sSL.Add('    "Numpad 6" => 0x66,');
        sSL.Add('    "Numpad 7" => 0x67,');
        sSL.Add('    "Numpad 8" => 0x68,');
        sSL.Add('    "Numpad 9" => 0x69,');
        sSL.Add('    "Multiply" => 0x6A,');
        sSL.Add('    "Add" => 0x6B,');
        sSL.Add('    "Separator" => 0x6C,');
        sSL.Add('    "Subtract" => 0x6D,');
        sSL.Add('    "Decimal" => 0x6E,');
        sSL.Add('    "Divide" => 0x6F,');
        sSL.Add('    "F1" => 0x70,');
        sSL.Add('    "F2" => 0x71,');
        sSL.Add('    "F3" => 0x72,');
        sSL.Add('    "F4" => 0x73,');
        sSL.Add('    "F5" => 0x74,');
        sSL.Add('    "F6" => 0x75,');
        sSL.Add('    "F7" => 0x76,');
        sSL.Add('    "F8" => 0x77,');
        sSL.Add('    "F9" => 0x78,');
        sSL.Add('    "F10" => 0x79,');
        sSL.Add('    "F11" => 0x7A,');
        sSL.Add('    "F12" => 0x7B,');
        sSL.Add('    "F13" => 0x7C,');
        sSL.Add('    "F14" => 0x7D,');
        sSL.Add('    "F15" => 0x7E,');
        sSL.Add('    "F16" => 0x7F,');
        sSL.Add('    "F17" => 0x80,');
        sSL.Add('    "F18" => 0x81,');
        sSL.Add('    "F19" => 0x82,');
        sSL.Add('    "F20" => 0x83,');
        sSL.Add('    "F21" => 0x84,');
        sSL.Add('    "F22" => 0x85,');
        sSL.Add('    "F23" => 0x86,');
        sSL.Add('    "F24" => 0x87,');
        sSL.Add('    "Num Lock" => 0x90,');
        sSL.Add('    "Scroll Lock" => 0x91,');
        sSL.Add('    # Multiple position Shift, Ctrl and Menu keys');
        sSL.Add('    ";:" => 0xBA,');
        sSL.Add('    "+" => 0xBB,');
        sSL.Add('    "," => 0xBC,');
        sSL.Add('    "-" => 0xBD,');
        sSL.Add('    "." => 0xBE,');
        sSL.Add('    "/?" => 0xBF,');
        sSL.Add('    "`~" => 0xC0,');
        sSL.Add('    "{" => 0xDB,');
        sSL.Add('    "\|" => 0xDC,');
        sSL.Add('    "}" => 0xDD,');
        sSL.Add('    "''\"" => 0xDE,');
        sSL.Add('    "AX" => 0xE1, # Japan only');
        sSL.Add('    "\|" => 0xE2');
        sSL.Add('    # Disc keys');
        sSL.Add('  }');
        sSL.Add('  ');
        sSL.Add('  # Here you can change the number of keys for each action and the');
        sSL.Add('  # default values');
        sSL.Add('  def self.defaultControls');
        sSL.Add('    return [');
        sSL.Add('      ControlConfig.new("Down","Down"),');
        sSL.Add('      ControlConfig.new("Left","Left"),');
        sSL.Add('      ControlConfig.new("Right","Right"),');
        sSL.Add('      ControlConfig.new("Up","Up"),');
        sSL.Add('      ControlConfig.new("Action","Z"),');
        sSL.Add('      ControlConfig.new("Action","C"),');
        sSL.Add('      ControlConfig.new("Action","Enter"),');
        sSL.Add('      ControlConfig.new("Action","Space"),');
        sSL.Add('      ControlConfig.new("Cancel/Menu","X"),');
        sSL.Add('      ControlConfig.new("Cancel/Menu","Esc"),');
        sSL.Add('      ControlConfig.new("Run","Space"),');
        sSL.Add('      ControlConfig.new("Scroll down","Page Down"),');
        sSL.Add('      ControlConfig.new("Scroll up","Page Up"),');
        sSL.Add('      ControlConfig.new("Registered","F5"),');
        sSL.Add('      ControlConfig.new("Registered","Shift"),');
        sSL.Add('      ControlConfig.new("Autorun","S"),');
        sSL.Add('      ControlConfig.new("Quicksave","D"),');
        sSL.Add('      ControlConfig.new("Fast-Forward","Alt"),');
        sSL.Add('      ControlConfig.new("Special/Autosort","A"),');
        sSL.Add('    ]');
        sSL.Add('  end  ');
        sSL.Add('  ');
        sSL.Add('  def self.getKeyName(keyCode)');
        sSL.Add('    ret  = CONTROLSLIST.index(keyCode) ');
        sSL.Add('    return ret ? ret : (keyCode==0 ? "None" : "?")');
        sSL.Add('  end ');
        sSL.Add('end');
        sSL.Add('');
        sSL.Add(' module Input');
        sSL.Add('  class << self');
        sSL.Add('    def buttonToKey(button)');
        sSL.Add('      $PokemonSystem = PokemonSystem.new if !$PokemonSystem');
        sSL.Add('      case button');
        sSL.Add('        when Input::DOWN');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Down")');
        sSL.Add('        when Input::LEFT');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Left")');
        sSL.Add('        when Input::RIGHT');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Right")');
        sSL.Add('        when Input::UP');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Up")');
        sSL.Add('        when Input::A # Z, Shift');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Run")');
        sSL.Add('        when Input::B # X, ESC ');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Cancel/Menu")');
        sSL.Add('        when Input::C # C, ENTER, Space');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Action")');
        sSL.Add('        when Input::L # Page Up');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Scroll up")');
        sSL.Add('        when Input::R # Page Down');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Scroll down")');
        sSL.Add(' #       when Input::SHIFT');
        sSL.Add(' #         return [0x10] # Shift');
        sSL.Add(' #       when Input::CTRL');
        sSL.Add(' #         return [0x11] # Ctrl');
        sSL.Add(' #       when Input::ALT');
        sSL.Add(' #         return [0x12] # Alt');
        sSL.Add('        when Input::F5 # F5');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Registered")');
        sSL.Add('        when Input::Y # S');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Autorun")   ');
        sSL.Add('        when Input::Z # D');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Quicksave")             ');
        sSL.Add('        when Input::ALT # Alt');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Fast-Forward")     ');
        sSL.Add('        when Input::X # A');
        sSL.Add('          return $PokemonSystem.getGameControlCodes("Special/Autosort")        ');
        sSL.Add(' #       when Input::F6');
        sSL.Add(' #         return [0x75] # F6');
        sSL.Add(' #       when Input::F7');
        sSL.Add(' #         return [0x76] # F7');
        sSL.Add(' #       when Input::F8');
        sSL.Add(' #         return [0x77] # F8');
        sSL.Add(' #       when Input::F9');
        sSL.Add(' #         return [0x78] # F9');
        sSL.Add('        else');
        sSL.Add('          return buttonToKeyOldFL(button)');
        sSL.Add('      end');
        sSL.Add('    end');
        sSL.Add('  end');
        sSL.Add('end');
        sSL.Add('');

        sSL.SaveToFile(sFile);
      finally
        sSL.Free;
      end;
    end;
  end;

  procedure aGetLevelNode(sLine: String; var sString: String; var iLevel: Integer);
  var
    i: Integer;
    bFound: Boolean;
  begin
    sString := '';
    iLevel := 0;

    bFound := false;
    for i := 1 to Length(sLine) do begin
      if bFound then begin
        sString := sString+sLine[i];
      end else begin
        if sLine[i] = #9 then iLevel := iLevel+1
        else begin
          bFound := true;
          sString := sLine[i];
        end;
      end;
    end;
  end;

  procedure aLoadGroups(sFile: String);
  var
    i, iLastLevel, iLevel: Integer;
    sSL: TStringList;
    sString: String;
    nNode: TTreeNode;
  begin
    if FileExists(sFile) then begin
      TreeView_Groups.Items.Delete(TreeView_Groups.Items.Item[0]);

      sSL := tStringList.Create;
      try
        sSL.LoadFromFile(sFile);

        iLastLevel := 0;
        nNode := nil;
        for i := 0 to sSL.Count-1 do begin
          aGetLevelNode(sSL.Strings[i], sString, iLevel);

          if iLevel = iLastLevel then begin
            nNode := TreeView_Groups.Items.Add(nNode, sString);
          end else begin
            while iLevel > iLastLevel do begin
              iLastLevel := iLastLevel+1;
              nNode := TreeView_Groups.Items.AddChild(nNode, sString);
            end;

            if iLevel < iLastLevel then begin
              while (iLevel < iLastLevel) AND (not (nNode = nil)) do begin
                iLastLevel := iLastLevel-1;
                nNode := nNode.Parent;
              end;

              nNode :=TreeView_Groups.Items.Add(nNode, sString);
            end;
          end;
        end;
      finally
        sSL.Free;
      end;

      //Collapse the tree
      for i := 0 to TreeView_Groups.Items.Count-1 do begin
        if TreeView_Groups.Items.Item[i].HasChildren then begin
          TreeView_Groups.Items.Item[i].Collapse(false);
        end;
      end;
    end;
  end;

  procedure aLoadGUIState();
  var
    iLang, iLine, iTab: Integer;
    sSL: TStringList;
    sFile: String;
    bBool: Boolean;
  begin
    sFile := ExtractFileDir(Application.ExeName)+'\Translations\GUI.txt';
    if FileExists(sFile) then begin
      sSL := tStringList.Create;
      try
        sSL.LoadFromFile(sFile);

        if TryStrToInt(sSL.Strings[0], iLang) AND TryStrToInt(sSL.Strings[1], iLine) AND TryStrToInt(sSL.Strings[2], iTab) then begin
          if StringGrid_Languages.RowCount > iLang then begin
            StringGrid_Languages.Row := iLang;
            StringGrid_LanguagesAfterSelection(nil, 0, 0);

            if StringGrid_Lines.RowCount > iLine then begin
              StringGrid_Lines.Row := iLine;
            end;
          end;

          PageControl1.TabIndex := 1;
          PageControl1Change(nil);

          if TryStrToBool(sSL.Strings[3], bBool) then CheckBox_ShowUntranslatedOnly.Checked := bBool;
          if TryStrToBool(sSL.Strings[4], bBool) then CheckBox_ChangeAll.Checked := bBool;
          if TryStrToBool(sSL.Strings[5], bBool) then CheckBox_ChangeAllIgnoreTransl.Checked := bBool;

          CheckBox_ShowUntranslatedOnlyChange(Sender);
          CheckBox_ChangeAllChange(Sender);

          if PageControl1.ControlCount > iTab then begin
            PageControl1.TabIndex := iTab;
          end;
        end;
      finally
        sSL.Free;
      end;
    end;
  end;

var
  i: Integer;
  sFile: String;
  aArr: aTNameFileDynArray;
  sSL: TStringList;
begin
  if not FileExists(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Game.exe')) then begin
    MessageDlg('Error: game not found', 'Please put the translation manager in the same folder as Game.exe', mtError, [mbOK], 0);
    Application.Terminate;
  end;

  Form1.Caption := cVersion;
  Button_Delete.Enabled := false;
  Button_Save.Enabled := false;
  LabeledEdit_LangName.Enabled := false;
  LabeledEdit_LangFile.Enabled := false;

  aCheckCompileMod(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Data\Mods\Languages_Compile.rb'));
  aCheckScriptsFixMod(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Data\Mods\Languages_ScriptsFix.rb'));

  StringGrid_Lines.RowCount := 0;
  StringGrid_Lines.ColCount := 4;

  StringGrid_Languages.RowCount := 0;
  StringGrid_Languages.ColCount := 2;

  StringGrid_Lines.Cells[0, 0] := 'Original';
  StringGrid_Lines.Cells[1, 0] := 'Translated';
  StringGrid_Lines.Cells[2, 0] := 'Line';
  StringGrid_Lines.Cells[3, 0] := 'Group';

  SetLength(aArr, 0);

  sFile := ExpandFileName(ExtractFileDir(Application.ExeName)+'\Data\Mods\Languages.rb');

  sSL := tStringList.Create;
  if FileExists(sFile) then begin
    try
      sSL.LoadFromFile(sFile);

      for i := 1 to sSL.Count-2 do begin
        SetLength(aArr, Length(aArr)+1);

        aArr[Length(aArr)-1].sName := aGetLanguageName(sSL.Strings[i]);
        aArr[Length(aArr)-1].sFile := aGetFileName(sSL.Strings[i]);
      end;
    finally
      sSL.Free;
    end;
  end else begin
    try
      sSL.Add('LANGUAGES = [  ');
      sSL.Add('  ["English","english.dat"],');
      sSL.Add(']');

      sSL.SaveToFile(sFile);

      SetLength(aArr, 1);
      aArr[0].sName := 'English';
      aArr[0].sFile := 'english.dat';
    finally
      sSL.Free;
    end;
  end;

  StringGrid_Languages.RowCount := Length(aArr)+1;
  StringGrid_Languages.Cells[0, 0] := 'Language';
  StringGrid_Languages.Cells[1, 0] := 'File';
  for i := 0 to Length(aArr)-1 do begin
    StringGrid_Languages.Cells[0, i+1] := aArr[i].sName;
    StringGrid_Languages.Cells[1, i+1] := aArr[i].sFile;
  end;

  gNotSelecting_Group := true;
  aLoadGroups(ExpandFileName(ExtractFileDir(Application.ExeName)+'\Translations\Groups.txt'));
  PageControl1Change(nil);

  aLoadGUIState();
end;

procedure TForm1.LabeledEdit_GroupEditingDone(Sender: TObject);

  procedure aHideChildren(nNode: TTreeNode; bHide: Boolean);
  var
    i, iChild, iLast: integer;
    sString: String;
    bHidden: Boolean;
  begin
    iChild := nNode.GetFirstChild.Index;
    iLast := nNode.GetLastChild.Index;

    for i := iChild to iLast do begin
      sString := nNode.Items[i].Text;
      bHidden := ((sString[1] = '(') AND (sString[Length(sString)] = ')'));

      if bHidden then begin
        if not bHide then nNode.Items[i].Text := sString.SubString(1, Length(sString)-2);
      end else begin
        if bHide then nNode.Items[i].Text := '('+sString+')';
      end;

      if nNode.Items[i].HasChildren then aHideChildren(nNode.Items[i], bHide);
    end;
  end;

var
  i: Integer;
  sTemp: String;
  bSuccess: Boolean;
begin
  if gNotSelecting_Group AND (not (TreeView_Groups.Selected = nil)) then begin
    gNotSelecting_Group := false;

    bSuccess := true;

    //Rebuild the text
    if LabeledEdit_GroupName.Text = '' then begin
      LabeledEdit_GroupName.Color := clYellow;
      bSuccess := false;
    end else begin
      LabeledEdit_GroupName.Color := clDefault;
      sTemp := LabeledEdit_GroupName.Text;
    end;

    if TreeView_Groups.Selected.HasChildren then begin
      if Sender = CheckBox_GroupHidden then aHideChildren(TreeView_Groups.Selected, CheckBox_GroupHidden.Checked);
    end else begin
      if TryStrToInt(LabeledEdit_GroupFrom.Text, i) then begin
        LabeledEdit_GroupFrom.Color := clDefault;
      end else begin
        LabeledEdit_GroupFrom.Color := clYellow;
        bSuccess := false;
      end;
      if TryStrToInt(LabeledEdit_GroupTo.Text, i) then begin
        LabeledEdit_GroupTo.Color := clDefault;
      end else begin
        LabeledEdit_GroupTo.Color := clYellow;
        bSuccess := false;
      end;

      sTemp := sTemp+' '+LabeledEdit_GroupFrom.Text+'-'+LabeledEdit_GroupTo.Text;
    end;

    if bSuccess then begin
      if CheckBox_GroupHidden.Checked then TreeView_Groups.Selected.Text := '('+sTemp+')'
      else TreeView_Groups.Selected.Text := sTemp;
    end;

    gNotSelecting_Group := true;
  end;
end;

procedure TForm1.LabeledEdit_LineTranslEditingDone(Sender: TObject);
begin
  if not (StringGrid_Lines.Cells[1, StringGrid_Lines.Row] = LabeledEdit_LineTransl.Text) then begin
    StringGrid_Lines.Cells[1, StringGrid_Lines.Row] := LabeledEdit_LineTransl.Text;

    if CheckBox_ChangeAll.checked then begin
      Button_ChangeAllClick(nil);
    end;
  end;
end;

procedure TForm1.LabeledEdit_LineTranslKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i, iNext: Integer;
  aRect: TRect;
  aState: TGridDrawState;
begin
  if LabeledEdit_LineTransl.Focused then begin
    if Key = VK_UP then begin
      LabeledEdit_LineTranslEditingDone(Sender);

      iNext := StringGrid_Lines.Row;

      for i := 1 to StringGrid_Lines.RowCount-1 do begin
        if iNext > 1 then begin
          iNext := iNext-1;
        end else begin
          iNext := StringGrid_Lines.RowCount-1;
        end;

        StringGrid_LinesDrawCell(Sender, StringGrid_Lines.LeftCol, iNext, aRect, aState);

        if StringGrid_Lines.RowHeights[iNext] > 1 then break;
      end;

      StringGrid_Lines.Row := iNext;

      LabeledEdit_LineTransl.SelectAll;
    end else if Key = VK_DOWN then begin
      LabeledEdit_LineTranslEditingDone(Sender);

      iNext := StringGrid_Lines.Row;

      for i := 1 to StringGrid_Lines.RowCount-1 do begin
        if iNext < (StringGrid_Lines.RowCount-1) then begin
          iNext := iNext+1;
        end else begin
          iNext := 1;
        end;

        StringGrid_LinesDrawCell(Sender, StringGrid_Lines.LeftCol, iNext, aRect, aState);

        if StringGrid_Lines.RowHeights[iNext] > 1 then break;
      end;

      StringGrid_Lines.Row := iNext;

      LabeledEdit_LineTransl.SelectAll;
    end;
  end;
end;

procedure TForm1.PageControl1Change(Sender: TObject);
var
  i, i2, i3, iDec, iFrom, iTo: Integer;
  sString, sStringFull: String;
  aArr: aTStringDynArray;
  bHide, bFound: Boolean;
  nNode: TTreeNode;
begin
  if PageControl1.TabIndex = 1 then begin
    Form1.Color := clBlue;
    Form1.Update;

    SetLength(aArr, 0);

    for i := 0 to TreeView_Groups.Items.Count-1 do begin
      if not TreeView_Groups.Items.Item[i].HasChildren then begin
        sString := TreeView_Groups.Items.Item[i].Text;

        bHide := ((sString[1] = '(') AND (sString[Length(sString)] = ')'));

        iTo := 0;
        iFrom := 0;
        bFound := false;
        iDec := 1;
        for i3 := Length(sString) downto 1 do begin
          if TryStrToInt(sString[i3], i2) then begin
            if bFound then iFrom := iFrom+i2*iDec
            else iTo := iTo+i2*iDec;

            iDec := iDec*10;
          end else begin
            if (i3 < Length(sString)) OR (not bHide) then begin
              if bFound then begin
                break;
              end else begin
                bFound := true;
                iDec := 1;
              end;
            end;
          end;
        end;

        //Get and save the full path
        nNode := TreeView_Groups.Items.Item[i].Parent;
        if nNode = nil then begin
          sStringFull := sString;
        end else begin
          if bHide then sStringFull := sString+')'
          else sStringFull := sString;

          while not (nNode = nil) do begin
            sStringFull := nNode.Text+' / '+sStringFull;
            nNode := nNode.Parent;
          end;

          if bHide then sStringFull := '('+sStringFull;
        end;

        if Length(aArr) <= iTo then begin
          i2 := Length(aArr);
          SetLength(aArr, iTo+1);
          for i3 := i2 to Length(aArr)-1 do aArr[i3] := '';
        end;
        for i3 := iFrom to iTo do aArr[i3] := sStringFull;
      end;
    end;

    StringGrid_Lines.BeginUpdate;
    for i := 1 to StringGrid_Lines.RowCount-1 do begin
      i2 := StrToInt(StringGrid_Lines.Cells[2, i]);

      if i2 < Length(aArr) then begin
        StringGrid_Lines.Cells[3, i] := aArr[i2];
      end else begin
        StringGrid_Lines.Cells[3, i] := '';
      end;
    end;
    StringGrid_Lines.EndUpdate(true);

    CheckBox_ShowUntranslatedOnlyChange(Sender);

    StringGrid_LinesAfterSelection(nil, 0, 0);

    Form1.Color := clBtnFace;
  end;
end;

procedure TForm1.StringGrid_LanguagesAfterSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
  PageControl1.TabIndex := 1;

  Form1.Color := clBlue;
  Form1.Update;

  Button_Delete.Enabled := true;
  Button_Save.Enabled := true;
  LabeledEdit_LangName.Enabled := true;
  LabeledEdit_LangFile.Enabled := true;

  LabeledEdit_LangName.Text := StringGrid_Languages.Cells[0, StringGrid_Languages.Row];
  LabeledEdit_LangFile.Text := StringGrid_Languages.Cells[1, StringGrid_Languages.Row];

  aLoadLanguage(LabeledEdit_LangFile.Text);

  PageControl1Change(Sender);

  StringGrid_LinesAfterSelection(nil, 0, 1);

  Form1.Color := clBtnFace;
end;

procedure TForm1.StringGrid_LinesAfterSelection(Sender: TObject; aCol,
  aRow: Integer);
begin
   LabeledEdit_LineOrig.Text := StringGrid_Lines.Cells[0, StringGrid_Lines.Row];
   LabeledEdit_LineTransl.Text := StringGrid_Lines.Cells[1, StringGrid_Lines.Row];
   LabeledEdit_Line.Text := StringGrid_Lines.Cells[2, StringGrid_Lines.Row];
   LabeledEdit_Group.Text := StringGrid_Lines.Cells[3, StringGrid_Lines.Row];

   LabeledEdit_LineTransl.SetFocus;
   LabeledEdit_LineTransl.SelectAll;
end;

procedure TForm1.StringGrid_LinesDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);

  function aIsHiddenGroup(sString: String): Boolean;
  begin
    if Length(sString) > 1 then result := ((sString[1] = '(') AND (sString[Length(sString)] = ')'))
    else result := false;
  end;

begin
  if aCol = StringGrid_Lines.LeftCol then begin
    if aRow > 0 then begin
      if aRow = StringGrid_Lines.Row then begin
        if StringGrid_Lines.RowHeights[aRow] <> StringGrid_Lines.DefaultRowHeight then StringGrid_Lines.RowHeights[aRow] := StringGrid_Lines.DefaultRowHeight;
      end else begin
        if aIsHiddenGroup(StringGrid_Lines.Cells[3, aRow]) then begin
          if StringGrid_Lines.RowHeights[aRow] <> 0 then StringGrid_Lines.RowHeights[aRow] := 0;
        end else begin
          if CheckBox_ShowUntranslatedOnly.Checked then begin
            if StringGrid_Lines.Cells[0, aRow] = StringGrid_Lines.Cells[1, aRow] then begin
              if StringGrid_Lines.RowHeights[aRow] <> StringGrid_Lines.DefaultRowHeight then StringGrid_Lines.RowHeights[aRow] := StringGrid_Lines.DefaultRowHeight;
            end else begin
              if StringGrid_Lines.RowHeights[aRow] <> 0 then StringGrid_Lines.RowHeights[aRow] := 0;
            end;
          end else begin
            if StringGrid_Lines.RowHeights[aRow] <> StringGrid_Lines.DefaultRowHeight then StringGrid_Lines.RowHeights[aRow] := StringGrid_Lines.DefaultRowHeight;
          end;
        end;
      end;
    end;
  end;
end;

procedure TForm1.TreeView_GroupsSelectionChanged(Sender: TObject);
var
  i, i2, iPart: Integer;
  sString, sTemp: String;
begin
  if gNotSelecting_Group then begin
    gNotSelecting_Group := false;

    LabeledEdit_GroupName.Color := clDefault;
    LabeledEdit_GroupFrom.Color := clDefault;
    LabeledEdit_GroupTo.Color := clDefault;

    sString := TreeView_Groups.Selected.Text;

    if TreeView_Groups.Selected.HasChildren then iPart := 2
    else iPart := 0;
    //0 is the to line
    //1 is the from line
    //2 is the group name

    CheckBox_GroupHidden.Checked := ((sString[1] = '(') AND (sString[Length(sString)] = ')'));
    LabeledEdit_GroupTo.Text := '';
    LabeledEdit_GroupFrom.Text := '';

    sTemp := '';
    for i := Length(sString) downto 1 do begin
      if iPart = 0 then begin
        if TryStrToInt(sString[i], i2) then begin
          sTemp := sString[i]+sTemp;
        end else begin
          if (i < Length(sString)) OR (not CheckBox_GroupHidden.Checked) then begin
            iPart := 1;
            LabeledEdit_GroupTo.Text := sTemp;
            sTemp := '';
          end;
        end;
      end else if iPart = 1 then begin
        if TryStrToInt(sString[i], i2) then begin
          sTemp := sString[i]+sTemp;
        end else begin
          iPart := 2;
          LabeledEdit_GroupFrom.Text := sTemp;
          sTemp := '';
        end;
      end else if iPart = 2 then begin
        if ((i > 1) AND (i < Length(sString))) OR (not CheckBox_GroupHidden.Checked) then sTemp := sString[i]+sTemp;
      end;
    end;
    LabeledEdit_GroupName.Text := sTemp;

    gNotSelecting_Group := true;
  end;
end;

end.

