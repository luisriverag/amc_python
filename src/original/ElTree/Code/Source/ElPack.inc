(*

These conditional defines turn on or off some rarely used features of
different elpack controls. Turning those features off reduces size of
generatede executable.

To turn the feature off place "." before "$" in the directive

*)

// comment this if you don't use inplace editors at all
// saves about 300K of space
{.$DEFINE ELTREE_USE_INPLACE_EDITORS}

// comment this if you don't use styles
{$DEFINE ELTREE_USE_STYLES}

// comment this to remove drag'n'drop
{.$DEFINE ELTREE_USE_OLE_DRAGDROP}

// comment this to prevent use of extended inplace editors
// (currency editor, boolean editor, date time picker etc.)
{.$DEFINE ELTREE_USE_EXT_EDITORS}

// comment this to remove Storage and linkage with ElIniFile
{.$DEFINE SUPPORT_STORAGE}

// comment this if you don't use SoundMap
{.$DEFINE USE_SOUND_MAP}

// comment this if you don't use HTML formating
{.$DEFINE HAS_HTML_RENDER}

// comment this to disable popup calendar in ElDateTimePicker
{.$DEFINE DATETIMEPICKER_SUPPORT_CALENDAR}

// uncomment this to replace ElPack calendar in popup calendar (in ElCalendarDlg)
// and ElDateTimePicker popup calendar
{.$DEFINE CALENDAR_USE_WINDOWS_CALENDAR}

// comment this if you compile the module, that uses ElIniFile, but does not
// use VCL
{$DEFINE ELINI_USE_GRAPHICS}

(*

The following overrides will help you turn the features off for particular projects

*)

{$IFDEF NO_ELTREE_USE_INPLACE_EDITORS}
{$UNDEF ELTREE_USE_INPLACE_EDITORS}
{$DEFINE NO_ELTREE_USE_EXT_EDITORS}
{$ENDIF}

{$IFDEF NO_ELTREE_USE_STYLES}
{$UNDEF ELTREE_USE_STYLES}
{$ENDIF}

{$IFDEF NO_ELTREE_USE_OLE_DRAGDROP}
{$UNDEF ELTREE_USE_OLE_DRAGDROP}
{$ENDIF}

{$IFDEF NO_ELTREE_USE_EXT_EDITORS}
{$UNDEF ELTREE_USE_EXT_EDITORS}
{$ENDIF}

{$IFDEF NO_SUPPORT_STORAGE}
{$UNDEF SUPPORT_STORAGE}
{$ENDIF}

{$IFDEF NO_USE_SOUND_MAP}
{$UNDEF USE_SOUND_MAP}
{$ENDIF}

(*

Different internal directives. Do not modify them.

*)

{.$DEFINE ELPACK_COMPLETE}
{.$DEFINE EL_DEMO}
{$DEFINE LITE}

{$IFNDEF ELPACK_COMPLETE}
  {$UNDEF SUPPORT_STORAGE}
  {$UNDEF ELTREE_USE_EXT_EDITORS}
  {$UNDEF USE_SOUND_MAP}
  {$UNDEF DATETIMEPICKER_SUPPORT_CALENDAR}
  {$UNDEF ELINI_USE_GRAPHICS}
{$ENDIF}

{$IFDEF LITE}
  {$UNDEF HAS_HTML_RENDER}
{$ENDIF}

{$DEFINE MANUAL_BUTTONS}

{$R-}

{$IFDEF VER100}
  {$DEFINE D_3_UP}
{$ENDIF}

{$IFDEF VER110}
  {$DEFINE B_3_UP}
  {$DEFINE B_3}
  {$DEFINE BUILDER_USED}
{$ENDIF}

{$IFDEF VER120}
  {$DEFINE D_3_UP}
  {$DEFINE D_4_UP}
  {$DEFINE VCL_4_USED}
{$ENDIF}

{$IFDEF VER125}
  {$DEFINE B_3_UP}
  {$DEFINE B_4_UP}
  {$DEFINE B_4}
  {$DEFINE VCL_4_USED}
  {$DEFINE BUILDER_USED}
{$ENDIF}

{$IFDEF VER130}
	{$IFDEF BCB}
		{$DEFINE B_3_UP}
		{$DEFINE B_4_UP}
		{$DEFINE B_5_UP}
		{$DEFINE B_5}
		{$DEFINE VCL_4_USED}
		{$DEFINE VCL_5_USED}
		{$DEFINE BUILDER_USED}
    {$ELSE}
		{$DEFINE D_3_UP}
		{$DEFINE D_4_UP}
		{$DEFINE D_5_UP}
		{$DEFINE VCL_4_USED}
		{$DEFINE VCL_5_USED}
		{.DEFINE USEADO}
    {$ENDIF}
{$ENDIF}

{$IFDEF VER140}
	{$IFDEF BCB}
		{$DEFINE B_3_UP}
		{$DEFINE B_4_UP}
		{$DEFINE B_5_UP}
		{$DEFINE B_6_UP}
		{$DEFINE B_6}
		{$DEFINE VCL_4_USED}
		{$DEFINE VCL_5_USED}
		{$DEFINE VCL_6_USED}
		{$DEFINE BUILDER_USED}
    {$ELSE}
		{$DEFINE D_3_UP}
		{$DEFINE D_4_UP}
		{$DEFINE D_5_UP}
		{$DEFINE D_6_UP}
		{$DEFINE D_6}
		{$DEFINE VCL_4_USED}
		{$DEFINE VCL_5_USED}
		{$DEFINE VCL_6_USED}
		{.DEFINE USEADO}
    {$ENDIF}
{$ENDIF}

{$IFDEF VER150}
	{$IFDEF BCB}
		{$DEFINE B_3_UP}
		{$DEFINE B_4_UP}
		{$DEFINE B_5_UP}
		{$DEFINE B_6_UP}
		{$DEFINE B_6}
		{$DEFINE VCL_4_USED}
		{$DEFINE VCL_5_USED}
		{$DEFINE VCL_6_USED}
		{$DEFINE BUILDER_USED}
    {$ELSE}
		{$DEFINE D_3_UP}
		{$DEFINE D_4_UP}
		{$DEFINE D_5_UP}
		{$DEFINE D_6_UP}
		{$DEFINE D_7_UP}
		{$DEFINE D_6}
		{$DEFINE VCL_4_USED}
		{$DEFINE VCL_5_USED}
		{$DEFINE VCL_6_USED}
		{$DEFINE VCL_7_USED}
		{.DEFINE USEADO}
    {$ENDIF}
{$ENDIF}

{$ifdef LINUX}
{$define KYLIX_USED}
{$endif}

{$IFDEF BUILDER_USED}
	{$ObjExportAll On}
{$ENDIF}
