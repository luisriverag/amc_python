{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2000, EldoS                   }
{                                                    }
{====================================================}

{$I 'Design\ElPack.inc'}

{$R 'Design\ElHeader.dcr'}
{$R 'Design\ElTree.dcr'}

unit ElReg;

interface

procedure Register;

implementation

uses
  Classes, Controls, SysUtils,
{$ifdef D_6_UP}
  DesignIntf, DesignEditors, DesignWindows, DsnConst
{$else}
  DsgnIntf
{$endif}
  , ElHeader, TreeDsgn, ElTree,
  frmItemsProp, frmSectProp;

procedure Register;
begin
  RegisterComponents('EldoS', [TElHeader, TElTree]);
  RegisterPropertyEditor(TypeInfo(TElTreeItems), TCustomElTree, 'Items',
    TElTreeItemsProperty);
  RegisterPropertyEditor(TypeInfo(TElHeaderSections), nil, 'Items',
    TElSectionsProperty);
  RegisterComponentEditor(TElTree, TElTreeEditor);
end;

end.
