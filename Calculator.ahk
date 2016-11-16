IniRead,TreeRoot,Price.ini,配置,TreeRoot
ImageListID := IL_Create(5)
Loop 5 
    IL_Add(ImageListID, "shell32.dll", A_Index)
Gui,Add,ComboBox,ym w300 Section
Gui,Add,TreeView,xm w300 r30 ImageList%ImageListID% gview
Gui,Add,ListView,ym w1000 hp+ vMyListView,日期|文件名|材质|规格|单位|数量|面积|单价|金额|备注
ImageListID := IL_Create(10)
LV_SetImageList(ImageListID)
Loop 10
    IL_Add(ImageListID, "shell32.dll", A_Index) 
Gui,Show,,广告制作行业计算器
AddSubFoldersToTree(TreeRoot)
return
view:
if A_GuiEvent <> S
	return
TV_GetText(SelectedItemText, A_EventInfo)
ParentID := A_EventInfo
Loop{
    ParentID := TV_GetParent(ParentID)
    if not ParentID
        break
    TV_GetText(ParentText, ParentID)
    SelectedItemText = %ParentText%\%SelectedItemText%
}
SelectedFullPath = %TreeRoot%\%SelectedItemText%
Compute(SelectedFullPath)
return
Compute(Path){
	RegExMatch(FileFullPath,"大喷|写真|车贴|绳",Section)
	LV_Delete()
	GuiControl, -Redraw,MyListView
	Loop,%Path%\*.jpg, R
	{
		GetSize:=GetSize(A_LoopFileFullPath)
		SplitPath,A_LoopFileName,,,,FileName
		FormatTime,FileTime,%A_LoopFileTimeCreated%,yy-MM/dd
		LV_Add("Icon" . GetSize.Ico,FileTime,FileName,,GetSize.Width "x" GetSize.Height,,GetSize.Score,GetSize.Square,GetSize.Peice,GetSize.Money)
	}
	LV_ModifyCol()
	GuiControl, +Redraw,MyListView
}
AddSubFoldersToTree(Folder, ParentItemID = 0){
    Loop %Folder%\*.*, 2
        AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFileName, ParentItemID, "Icon4"))
}
Return
GetSize(FileFullPath){
	SetFormat,float,0.2
	objImage := ComObjCreate("WIA.ImageFile")
	objImage.LoadFile(FileFullPath)
	objImage.Width
	objImage.Height
	objImage.HorizontalResolution
	GetSize := Object()
	GetSize.Width := objImage.Width/objImage.HorizontalResolution*2.54
	GetSize.Height := objImage.Height/objImage.HorizontalResolution*2.54
	RegExMatch(FileFullPath,"\d+(?=个|份|块|面)",Score)
	if not Score
		Score=1
	GetSize.Score := Score
	Money:=0
	SetFormat,float,0.1
	GetSize.Square := GetSize.Width*GetSize.Height/10000*Score
	GetSize.ico:=2
	For key,var in RegExMatchAll(FileFullPath,"大喷|写真|车贴|绳"){
		IniRead,Peice,Price.ini,%var%,Price
		IniRead,Way,Price.ini,%var%,Way
		GetSize.Peice:=Peice
		Money:=%Way%(GetSize)+Money
		GetSize.ico:=1
	}
	GetSize.Money:=Money
	return GetSize
}
RegExMatchAll(ByRef Haystack, NeedleRegEx, SubPat="") {
	arr := [], startPos := 1
	while ( pos := RegExMatch(Haystack, NeedleRegEx, match, startPos) ) {
	arr.push(match%SubPat%)
	startPos := pos + StrLen(match)
}
return arr.MaxIndex() ? arr : ""
}
square(GetSize){
	return GetSize.Square*GetSize.Peice
}
Perimeter(GetSize){
	return (GetSize.Width+GetSize.Height)*2*GetSize.Peice//100
}
