Var MSG
Var Dialog

Var BGImage
Var MiddleImage         
Var ImageHandle
Var Btn_Next
Var Btn_Cancel
Var Btn_Agreement
Var Bool_License
Var Txt_License

;---------------------------全局编译脚本预定义的常量-----------------------------------------------------
!define  EM_BrandingText "testtest"
; MUI 预定义常量
!define MUI_ABORTWARNING
;安装图标的路径名字
!define MUI_ICON "images\fav.ico"
;卸载图标的路径名字
!define MUI_UNICON "images\fav.ico"
;产品协议书的路径名字
;!define MUI_PAGE_LICENSE_RTY "license\license.rtf"
!define EM_OUTFILE_NAME "test.exe"

;---------------------------设置软件压缩类型（也可以通过外面编译脚本控制）------------------------------------
SetCompressor lzma
BrandingText "${EM_BrandingText}"
SetCompress force
XPStyle on
; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"
!include "WinCore.nsh"
;引用文件函数头文件
!include "FileFunc.nsh"
!include "nsWindows.nsh"
!include "LoadRTF.nsh"
!include "WinMessages.nsh"

!define MUI_CUSTOMFUNCTION_GUIINIT onGUIInit

;自定义页面
Page custom WelcomePage

; 许可协议页面
!define MUI_LICENSEPAGE_CHECKBOX

; 安装目录选择页面
!insertmacro MUI_PAGE_DIRECTORY
; 安装过程页面
!insertmacro MUI_PAGE_INSTFILES
; 安装完成页面
!insertmacro MUI_PAGE_FINISH
; 安装卸载过程页面
!insertmacro MUI_UNPAGE_INSTFILES
; 安装界面包含的语言设置
!insertmacro MUI_LANGUAGE "SimpChinese"

;------------------------------------------------------MUI 现代界面定义以及函数结束------------------------
;应用程序显示名字
Name "test"
;应用程序输出路径
OutFile "${EM_OUTFILE_NAME}"
InstallDir "$PROGRAMFILES\test"

Function .onInit
    InitPluginsDir
    File `/ONAME=$PLUGINSDIR\bg.bmp` `images\bg.bmp`
    File `/ONAME=$PLUGINSDIR\welcome.bmp` `images\welcome.bmp`
		File `/ONAME=$PLUGINSDIR\btn_next.bmp` `images\btn_next.bmp`
		File `/oname=$PLUGINSDIR\btn_agreement1.bmp` `images\btn_agreement1.bmp`
    File `/oname=$PLUGINSDIR\btn_agreement2.bmp` `images\btn_agreement2.bmp`
    File `/oname=$PLUGINSDIR\license.rtf` `license\license.rtf`
    
		SkinBtn::Init "$PLUGINSDIR\btn_next.bmp"
		SkinBtn::Init "$PLUGINSDIR\btn_agreement1.bmp"
		SkinBtn::Init "$PLUGINSDIR\btn_agreement2.bmp"
FunctionEnd

Function onGUIInit
    ;消除边框
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;隐藏一些既有控件
    GetDlgItem $0 $HWNDPARENT 1034
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1036
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}
FunctionEnd

;处理无边框移动
Function onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd

;下一步按钮事件
Function onClickNext
  MessageBox MB_OK "下一步"
  Abort
FunctionEnd

;协议按钮事件
Function onClickAgreement
	${IF} $Bool_License == 1
		ShowWindow $Txt_License ${SW_HIDE}
		ShowWindow $MiddleImage ${SW_SHOW}
		IntOp $Bool_License $Bool_License - 1
		StrCpy $1 $Btn_Agreement
		Call SkinBtn_Agreement1
	${ELSE}
	  ShowWindow $Txt_License ${SW_SHOW}
	  ShowWindow $MiddleImage ${SW_HIDE}
		IntOp $Bool_License $Bool_License + 1
		StrCpy $1 $Btn_Agreement
		Call SkinBtn_Agreement2
	${EndIf}
FunctionEnd

;-----------------------------------------皮肤贴图方法----------------------------------------------------
Function SkinBtn_Next
  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_next.bmp $1
FunctionEnd

Function SkinBtn_Agreement1
  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_agreement1.bmp $1
FunctionEnd

Function SkinBtn_Agreement2
  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_agreement2.bmp $1
FunctionEnd



Function WelcomePage
    GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}

    nsDialogs::Create 1044
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    SetCtlColors $0 ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $HWNDPARENT 513 354 ;改变窗体大小
    ${NSW_SetWindowSize} $0 513 354 ;改变Page大小
    
    ;读取RTF的文本框
		nsDialogs::CreateControl "RichEdit20A" \
    ${ES_READONLY}|${WS_VISIBLE}|${WS_CHILD}|${WS_TABSTOP}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_WANTRETURN} \
		${WS_EX_STATICEDGE}  5 35 501 216 ''
    Pop $Txt_License
		${LoadRTF} '$PLUGINSDIR\license.rtf' $Txt_License
    ShowWindow $Txt_License ${SW_HIDE}

    
    ;下一步
    ${NSD_CreateButton} 330 315 88 25 ""
		Pop $Btn_Next
		StrCpy $1 $Btn_Next
		Call SkinBtn_Next
		GetFunctionAddress $3 onClickNext
    SkinBtn::onClick $1 $3
    
    ;用户协议
		${NSD_CreateButton} 181 273 95 15 ""
		Pop $Btn_Agreement
		StrCpy $1 $Btn_Agreement
		Call SkinBtn_Agreement1
	  GetFunctionAddress $3 onClickAgreement
	  SkinBtn::onClick $1 $3
 		StrCpy $Bool_License 0 ;初始化值为0

    ;贴小图
    ${NSD_CreateBitmap} 1 31 511 226 ""
    Pop $MiddleImage
    ${NSD_SetImage} $MiddleImage $PLUGINSDIR\welcome.bmp $ImageHandle
    ;ShowWindow $MiddleImage ${SW_HIDE}
    
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg.bmp $ImageHandle

	GetFunctionAddress $0 onGUICallback
	WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
	nsDialogs::Show
	${NSD_FreeImage} $ImageHandle
FunctionEnd

Section MainSetup
SectionEnd
