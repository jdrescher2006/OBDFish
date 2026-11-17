/*
 * Copyright (C) 2016 Jens Drescher, Germany
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page
{
    allowedOrientations: Orientation.All

    property bool bStartGeneralSettingsPage: true
    property bool bInitPage: true

    onStatusChanged:
    {
        //If dialog is started, set project values to dialog
        if (status == PageStatus.Active && bStartGeneralSettingsPage)
        {
            bInitPage = true;
            bStartGeneralSettingsPage = false;

            id_TextSwitch_DebugFile.checked = bSaveDataToDebugFile;

            bInitPage = false;
        }

        //Save values to project data when page is closed
        if (status === PageStatus.Deactivating && !bInitPage)
        {
            //Check if fields are valid and have changed            
            if (bSaveDataToDebugFile != id_TextSwitch_DebugFile.checked)
            {
                bSaveDataToDebugFile = id_TextSwitch_DebugFile.checked;
                id_ProjectSettings.vSaveProjectData("WriteDebugFile", id_TextSwitch_DebugFile.checked.toString());
            }
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: id_Column_Main.height
        VerticalScrollDecorator {}

        Column
        {
            id: id_Column_Main
            spacing: Theme.paddingSmall
            width: parent.width

            PageHeader
            {
                title: qsTr("General settings")
            }

            TextSwitch
            {
                id: id_TextSwitch_DebugFile
                text: qsTr("Write debug file")
                description: qsTr("Communication with vehicle is saved to a file: Documents/obd_log.txt")
            }
        }
    }
}

