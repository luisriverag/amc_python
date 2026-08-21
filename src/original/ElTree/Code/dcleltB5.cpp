//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("dcleltB5.res");
USEFORMNS("Design\frmItemCol.pas", Frmitemcol, ItemColDlg);
USEFORMNS("Design\frmItemsProp.pas", Frmitemsprop, TItemsPropDlg);
USEFORMNS("Design\frmSectEdit.pas", Frmsectedit, SectEdit);
USEFORMNS("Design\frmSectProp.pas", Frmsectprop, ElSectionsPropDlg);
USEUNIT("Design\TreeDsgn.pas");
USEUNIT("ElReg.pas");
USEPACKAGE("vclx50.bpi");
USEPACKAGE("VCL50.bpi");
USEPACKAGE("eltreeB5.bpi");
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

