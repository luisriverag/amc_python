//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("dcleltB3.res");
USEPACKAGE("vclx35.bpi");
USEPACKAGE("VCL35.bpi");
USEPACKAGE("eltreeb3.bpi");
USEFORMNS("Design\frmItemCol.pas", Frmitemcol, ItemColDlg);
USEFORMNS("Design\frmItemsProp.pas", frmItemsProp, TItemsPropDlg);
USEFORMNS("Design\frmSectEdit.pas", Frmsectedit, SectEdit);
USEFORMNS("Design\frmSectProp.pas", Frmsectprop, ElSectionsPropDlg);
USEUNIT("Design\TreeDsgn.pas");
USEUNIT("ElReg.pas");
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

