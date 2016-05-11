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
import "OBDDataObject.js" as OBDDataObject

Page
{
    allowedOrientations: Orientation.All
    id: id_page_generalinfo
    property bool bPushGeneralInfoPage: true
    property int iCommandSequence: 0
    property bool bWaitForCommandSequenceEnd: false
    property int iWaitForCommand: 0
    property string sOBDStandard: "Not supported"
    property string sVIN: "Not supported"

    onStatusChanged:
    {
        if (status === PageStatus.Active && bPushGeneralInfoPage)
        {
            bPushGeneralInfoPage = false;
            pageStack.pushAttached(Qt.resolvedUrl("Dyn1Page.qml"));

            //Now start with reading static data from ELM
            iCommandSequence = 1;
            iWaitForCommand = 0;
            bWaitForCommandSequenceEnd = true;
        }
    }

    Timer
    {
        //This is called, everytime an AT command is send.
        //The timer waits for ELM to answer the command.
        id: timWaitForCommandSequenceEnd
        interval: 250
        running: bWaitForCommandSequenceEnd
        repeat: true
        onTriggered:
        {
            var sReadValue = "";

            //Check if ELM has answered correctly to current AT command
            if (bCommandRunning == false)
            {
                iWaitForCommand = 0;

                console.log("timWaitForCommandSequenceEnd step: " + iCommandSequence);

                if (iCommandSequence == 1)
                {
                    iCommandSequence = 2;
                    fncStartCommand("011C1");
                }
                else if (iCommandSequence == 2)
                {                                        
                    //Evaluate answer from ELM
                    sReadValue = OBDDataObject.fncEvaluatePIDQuery(sReceiveBuffer, "011C");
                    if (sReadValue !== null)
                        sOBDStandard = sReadValue;

                    iCommandSequence = 3;
                    fncStartCommand("09011");
                }
                else if (iCommandSequence == 3)
                {
                    //Evaluate answer from ELM
                    sReadValue = OBDDataObject.fncEvaluatePIDQuery(sReceiveBuffer, "0901");
                    console.log("sReadValue: " + sReadValue);

                    iCommandSequence = 4;
                    fncStartCommand("09021");
                }
                else if (iCommandSequence == 4)
                {
                    sReadValue = OBDDataObject.fncEvaluatePIDQuery(sReceiveBuffer, "0902");
                    console.log("sReadValue: " + sReadValue);                    

                    //Finish for now
                    bWaitForCommandSequenceEnd = false;
                }
            }            
            else
            {
                //ELM has not yet answered. Or the answer is not complete.
                //Check if wait time is over.
                if (iWaitForCommand == 40)
                {
                    iCommandSequence = 0;
                    bWaitForCommandSequenceEnd = false;
                    fncViewMessage("error", "Communication timeout!!!");
                }
                else
                    iWaitForCommand++;
            }
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: id_Column_FirstCol.height + Theme.paddingLarge;

        VerticalScrollDecorator {}

        Column
        {
            id: id_Column_FirstCol

            spacing: Theme.paddingSmall
            width: parent.width

            PageHeader { title: qsTr("General Informations") }

            Label
            {
                width: parent.width
                text: qsTr("OBD Adapter: ELM327 ") + sELMVersion;
            }            
            Label
            {
                width: parent.width
                text: qsTr("OBD Standard: ") + sOBDStandard;
            }
            Label
            {
                width: parent.width
                text: qsTr("Vehicle Identification Number: <br>") + sVIN;
            }
            Label
            {
                width: parent.width
                text: qsTr("Supported PID's, Mode 01:");
            }
            Label
            {
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.WordWrap
                text: OBDDataObject.sSupportedPIDs0100;
            }
        }
    }
}
