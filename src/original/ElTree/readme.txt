                     EldoS ElTree Lite for Delphi and C++Builder. 


1. INSTALLATION           
2. LICENSING AND PURCHASE
3. DISCLAIMER            
4. CONTACT INFO          
5. THANKS                


                              INSTALLATION

ElTree  Lite  package is not compatible with ElPack or ElTree Standard. I.e. you
can't have ElPack and ElTree Lite installed in Delphi/C++Builder IDE at the same
time.  However  you can have them both on your disk and build applications using
both of them.

First   run  the included executable file named "ElTreeLite.exe" and install the
pack  contents    to   your   hard   drive.   Then   follow  the instructions to
install the package in your development tool (either Delphi or C++ Builder).


      INSTALLING SOURCE CODE: 

To   install  ElTree Lite,  different sets of packages for different development
tools are provided.

Each set consists of 2 packages:

eltreeXY.?pk - ElTree Lite run-time package
dcleltXY.?pk - ElTree Lite design-time package

Where
  X stands for the development tool (D - Delphi, B - C++Builder), and 
  Y stands for the version of the development tool (3, 4, 5 for Delphi and
    C++Builder).

Step-by-step installation instructions for all sets:

1. Tune-up global pathes in your development tool.

You have to set 
a)  the output pathes to the folder, where the packages are located. Usually you
will  need  to add two folders to the path -- one folder with run-time packages,
and one folder with design-time packages.
b)   source  path  (or include and library pathes for C++Builder) to the folder,
where   code  files are located. Usually you will need to add two folders to the
path  --  one  folder  with  run-time code, and one folder with design-time code
(always in source code).

2.

(C++Builder  3  only). Go  to the LIB subfolder of the C++Builder 3 base folder.
There  can  dclstd35.lib  file  exist.  If  it  doesn't  exist,  copy  the  file
named  dclstd35.bpi  to  the dclstd35.lib. This  is  need  to  compile  projects
that   will  use  ElTree  Lite,  and  sometimes  needed even to make ElTree Lite
packages.

(C++Builder  4  only). Go  to the LIB subfolder of the C++Builder 4 base folder.
There  can  dclstd40.lib  file  exist.  If  it  doesn't  exist,  copy  the  file
named  dclstd40.bpi  to  the dclstd40.lib. This  is  need  to  compile  projects
that    will   use  ElTree  Lite,  and sometimes needed even to make ElTree Lite
packages.


3. Open eltreeXY.?pk package. 
4.  Repeat  step  1 for the package private pathes. To set the package's pathes,
use Options button in Delphi and Project\Properties menu for C++Builder.
5. Compile the opened package (press Compile Package button in Delphi or Make in
C++Builder).
6. Copy the compiled package (eltreeXY.?pl)to your Windows system folder. 

7. Open dcleltXY.?pk package. 
8.  Repeat  step  1 for the package private pathes. To set the package's pathes,
use Options button in Delphi and Project\Properties menu for C++Builder.
9.  Install  the  opened  package. In Delphi you will need just to press Install
Package  button. In C++Builder you have to "Make" the package first, then select
Component\Installed  packages  and  add the package you've just compiled, to the
list of loaded packages.


      INSTALLING HELP FILES:


DELPHI 3:

Help   files   are  located  in the HELP subfolder of the ElTree base folder and
should  have  been  integrated  into  Delphi help system by ElTree Setup. If you
can't  access  help,  you  will need to manually add ElTree help files to Delphi
help system. To do this add the following lines to Delphi3.cfg:

:Link elpack.hlp
:Include elpack.cnt

Note  that if you have other :include statements in the delphi3.cfg, you have to 
add all :Link statements before any :Include statements.        


DELPHI 4:

Help   files   are  located  in the HELP subfolder of the ElTree base folder and
should  have  been  integrated  into  Delphi help system by ElTree Setup. If you
can't  access  help,  you  will need to manually add ElTree help files to Delphi
help system. To do this add the following lines to Delphi4.cfg:

:Link elpack.hlp
:Include elpack.cnt

Note  that if you have other :include statements in the delphi3.cfg, you have to
add all :Link statements before any :Include statements.


DELPHI 5:

Help   files   are   located in the HELP subfolder of the ElTree base folder and
should  have  been integrated into Delphi help system by ElTree  Setup.  If  you
can't  access  help,  you  will need to manually add ElTree help files to Delphi
help system. To do this add the following lines to Delphi5.cnt:

:Include ElPack.cnt



C++BUILDER 3:

Help    files   are  located in the HELP subfolder of the ElTree base folder and
should   have   been integrated into C++Builder help system by ElTree  Setup. If
you  can't   access   help,  you  will need to manually add ElTree help files to
C++Builder help system. To do this add the following lines to bcb3.cnt:

:Include ElPack.cnt



C++BUILDER 4:

Help    files   are  located in the HELP subfolder of the ElTree base folder and
should   have   been integrated into C++Builder help system by ElTree  Setup. If
you  can't   access   help,  you  will need to manually add ElTree help files to
C++Builder help system as follows:

1) Add the following lines to bcb4.ohc:
:Include ElPack.toc

2) Add the following lines to bcb4.ohi:
:Index EldoS ElTree=elpack.hlp

3)Add the following lines to bcb4.ohl:
:Link ElPack.hlp



C++BUILDER 5:

Help    files   are  located in the HELP subfolder of the ElTree base folder and
should   have   been integrated into C++Builder help system by ElTree  Setup. If
you  can't   access   help,  you  will need to manually add ElTree help files to
C++Builder help system as follows:

1) Add the following lines to bcb5.ohc:
:Include ElPack.toc

2) Add the following lines to bcb5.ohi:
:Index EldoS ElTree=elpack.hlp

3)Add the following lines to bcb5.ohl:
:Link ElPack.hlp



                           LICENSING AND PURCHASE

ElTree Lite is freeware under conditions stated in license.txt. 
       

                                DISCLAIMER

IN  NO  EVENT  SHALL  ElTREE  LIBRARY  AUTHORS,  OR ANY OTHER PARTY WHO MAY HAVE
DISTRIBUTED  THE  SOFTWARE  AS  PERMITTED,  BE LIABLE FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
INABILITY TO USE THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA
BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR FAILURE
OF  THE  SOFTWARE  TO  OPERATE  WITH ANY OTHER PRODUCTS), EVEN IF SUCH HOLDER OR
OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 

                               CONTACT INFO

ElTree Lite is the product of EldoS. 

The official ElTree Lite homepage is http://www.eldos.org/eltree/eltree.html
You   can  send  bug-reports  and  suggestions  by  e-mail  to  the  authors  to
ElTree@eldos.org