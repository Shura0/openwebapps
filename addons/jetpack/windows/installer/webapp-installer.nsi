# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is an NSIS installer/uninstaller for Open Web Apps
#
# The Initial Developer of the Original Code is
# Mozilla Foundation.
# Portions created by the Initial Developer are Copyright (C) 2011
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#  Tim Abraldes <tabraldes@mozilla.com>
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****

!include "FileFunc.nsh"

SetCompressor /SOLID /FINAL lzma
CRCCheck on
RequestExecutionLevel user

Var PARAMETERS

Var ORIGIN_SCHEME
Var ORIGIN_HOST_AND_PORT
Var FIREFOX_PATH

Var SHORTCUT_NAME
Var SHORTCUT_COMMENT
Var ICON_PATH

Name "Mozilla App Installer"
OutFile ..\..\data\native-install\windows\installer\install.exe

Function .onInit
FunctionEnd

Function RealInit
  ClearErrors

  ${GetParameters} $PARAMETERS
  IfErrors 0 +2
    Abort "No command line arguments specified"
  DetailPrint "Command line: $PARAMETERS"

  ${GetOptions} $PARAMETERS "/FIREFOX_PATH= " $FIREFOX_PATH
  IfErrors 0 +2
    Abort "Path to firefox.exe not specified"
  DetailPrint "FIREFOX_PATH=$FIREFOX_PATH"

  ${GetOptions} $PARAMETERS "/ORIGIN_SCHEME= " $ORIGIN_SCHEME
  IfErrors 0 +2
    Abort "Origin URI scheme not specified"
  DetailPrint "ORIGIN_SCHEME=$ORIGIN_SCHEME"

  ${GetOptions} $PARAMETERS "/ORIGIN_HOST_AND_PORT= " $ORIGIN_HOST_AND_PORT
  IfErrors 0 +2
    Abort "Origin URI host not specified"
  DetailPrint "ORIGIN_HOST_AND_PORT=$ORIGIN_HOST_AND_PORT"

  ReadRegStr $INSTDIR \
             HKCU \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT" \
            "InstallLocation"
  IfErrors 0 +2
    Abort "Could not read install location from registry"
  DetailPrint "INSTDIR=$INSTDIR"
  SetOutPath $INSTDIR

  # Optional items
  ReadRegStr $SHORTCUT_NAME \
             HKCU \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT" \
            "DisplayName"
  IfErrors +2
    DetailPrint "SHORTCUT_NAME=$SHORTCUT_NAME"

  ReadRegStr $SHORTCUT_COMMENT \
             HKCU \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT" \
            "Comments"
  IfErrors +2
    DetailPrint "SHORTCUT_COMMENT=$SHORTCUT_COMMENT"

  ReadRegStr $ICON_PATH \
             HKCU \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT" \
            "DisplayIcon"
  IfErrors +2
    DetailPrint "ICON_PATH=$ICON_PATH"

  Return
FunctionEnd

Function CreateShortcuts
  ClearErrors
  Push $R0

  CreateShortcut $INSTDIR\$SHORTCUT_NAME.lnk \
                 $FIREFOX_PATH \
                 '-app "$OUTDIR\application.ini"' \
                 $ICON_PATH \
                 0 \
                 "" \
                 "" \
                 $SHORTCUT_COMMENT

  ${GetOptions} $PARAMETERS "/CreateDesktopShortcut" $R0
  IfErrors +2
  CreateShortcut $DESKTOP\$SHORTCUT_NAME.lnk \
                 $INSTDIR\$SHORTCUT_NAME.lnk \
                 "" \
                 $ICON_PATH \
                 0 \
                 "" \
                 "" \
                 $SHORTCUT_COMMENT

  ${GetOptions} $PARAMETERS "/CreateStartMenuShortcut" $R0
  IfErrors +2
  CreateShortcut $SMPROGRAMS\$SHORTCUT_NAME.lnk \
                 $INSTDIR\$SHORTCUT_NAME.lnk \
                 "" \
                 $ICON_PATH \
                 0 \
                 "" \
                 "" \
                 $SHORTCUT_COMMENT

  Pop $R0
FunctionEnd

Section Install
  Call RealInit
  Call CreateShortcuts
  WriteUninstaller $OUTDIR\uninstall.exe
SectionEnd

Function un.onInit
FunctionEnd

Section un.Install
  ${GetParameters} $PARAMETERS
  IfErrors 0 +2
    Abort "Please use the Windows Control Panel to remove this application"
  ${GetOptions} $PARAMETERS "/ORIGIN_SCHEME= " $ORIGIN_SCHEME
  IfErrors 0 +2
    Abort "Please use the Windows Control Panel to remove this application"
  ${GetOptions} $PARAMETERS "/ORIGIN_HOST_AND_PORT= " $ORIGIN_HOST_AND_PORT
  IfErrors 0 +2
    Abort "Please use the Windows Control Panel to remove this application"

  ReadRegStr $INSTDIR \
             HKCU \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT" \
            "InstallLocation"
  IfErrors 0 +2
    Abort "The installation appears to be corrupted; cannot continue with uninstall"
  SetOutPath $INSTDIR

  ReadRegStr $SHORTCUT_NAME \
             HKCU \
            "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT" \
            "DisplayName"

  Delete $SMPROGRAMS\$SHORTCUT_NAME.lnk
  Delete $DESKTOP\$SHORTCUT_NAME.lnk
  RMDir /r $OUTDIR
  RMDir $OUTDIR
  DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\$ORIGIN_SCHEME://$ORIGIN_HOST_AND_PORT"
SectionEnd
