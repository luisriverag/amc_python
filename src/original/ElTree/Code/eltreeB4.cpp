//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("eltreeB4.res");
USEPACKAGE("vclx40.bpi");
USEPACKAGE("VCL40.bpi");
USEUNIT("Source\ElContBase.pas");
USEUNIT("Source\ElHeader.pas");
USEUNIT("Source\ElHintWnd.pas");
USEUNIT("Source\ElList.pas");
USEUNIT("Source\ElScrollBar.pas");
USEUNIT("Source\ElStack.pas");
USEUNIT("Source\ElStrUtils.pas");
USEUNIT("Source\ElTools.pas");
USEUNIT("Source\ElTree.pas");
USEUNIT("Source\ElVCLUtils.pas");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
    return 1;
}
//---------------------------------------------------------------------------

