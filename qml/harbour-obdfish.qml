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
import "pages"
import Nemo.Notifications 1.0
import harbour.obdfish 1.0
import QtSensors 5.0 as Sensors
import "tools"
import "pages/OBDDataObject.js" as OBDDataObject
import org.kde.bluezqt 1.0 as BluezQt

ApplicationWindow
{
    //Define global variables
    property bool bConnecting: false;
    property bool bCommandRunning: false;
    property string sReceiveBuffer: "";
    property string sELMVersion: "";
    property bool bSaveDataToDebugFile: false;
    property var arPIDsPagesArray : [ "010d,0000,0000,0000,0000,0000", "0104,0105,010c,010d,010e,0111", "0104,0105,010c,010d,010e,0111" ]
    property var pagesDisplayStyle: ["small", "small", "big"]
    property bool bDoNotShowDTCWarning : false;
    property string sCoverValue1 : "";
    property string sCoverValue2 : "";
    property string sCoverValue3 : "";

    //Init C++ classes, libraries
    FileWriter{ id: id_FileWriter }
    ProjectSettings{ id: id_ProjectSettings }
    Notification { id: mainPageNotification }

    property QtObject btManager: BluezQt.Manager
    property int devicesCount: btManager.devices.length
    property int adaptersCount: btManager.adapters.length

    Component.onCompleted: {
        console.log("Manager operational:", btManager.operational)
    }

    Connections {
        target: btManager
        onOperationalChanged: console.log("Manager operational2:", btManager.operational)
    }

    Connections
    {
        target: obdConnection
        onDataReady:     //This is called from C++ if there is data via bluetooth
        {
            //Check received data
            fncGetData(sData);
        }
    }

    //Define global functions
    function fncViewMessage(sCategory, sMessage)
    {
        mainPageNotification.category = (sCategory === "error")
            ? "x-sailfish.sailfish-utilities.error"
            : "x-sailfish.sailfish-utilities.info";
        mainPageNotification.previewBody = "OBDFish";
        mainPageNotification.previewSummary = sMessage;
        mainPageNotification.close();
        mainPageNotification.publish();
    }

    //This function accepts an AT command to be send to the ELM
    function fncStartCommand(sCommand)
    {
        console.log("fncStartCommand, sCommand: " + sCommand);

        //Don't do anything if there is already an active command.
        if (bCommandRunning)
        {
            console.log("fncStartCommand, bCommandRunning is true!");
            return false;
        }

        //Cleare receive buffer
        sReceiveBuffer = "";

        //Here we have to check if this is PID request, e.g. 011C1.
        //If this is the case, check if the PID is in the PID table and is supported.
        //If it is not supported, don't send the command and return with false.
        var sPID = sCommand.substr(0, 4);

        console.log("fncStartCommand, sPID: " + sPID);

        if (OBDDataObject.arrayLookupPID[sPID] !== undefined)
        {
            var bSupported = OBDDataObject.arrayLookupPID[sPID.toLowerCase()].supported;

            console.log("fncStartCommand, PID supported: " + bSupported.toString());

            if (bSupported === false)
                return false;
        }                

        //Set active command bit
        bCommandRunning = true;

        //There is one special case, this is the request for battery voltage.
        //In order to do this generically on the dynamic pages, battery voltage request is treated like a PID request.
        //Fake PID for th9is is 1234. If this is the case here, send AT command for voltage request: ATRV
        if (sCommand === "12341")
        {
            sCommand = "ATRV";
        }

        //Save command to debug file
        if (bSaveDataToDebugFile) id_FileWriter.vWriteData("Send: " + sCommand + "\r\n");

        //Send the AT command via bluetooth
        obdConnection.sendHex(sCommand);

        return true;
    }

    //Data which is received via bluetooth is passed into this function
    function fncGetData(sData)
    {        
        //WARNING: Don't trim here. ELM might send leading/trailing spaces/carriage returns.
        //They might get lost but are needed!!!

        //Fill in new data into buffer
        sReceiveBuffer = sReceiveBuffer + sData;

        console.log("fncGetData, sReceiveBuffer: " + sReceiveBuffer);

        //If the ELM is ready with sending a command, it always sends the same end characters.
        //These are three characters: two carriage returns (\r) followed by >
        //Check if the end characters are already in the buffer.
        if (sReceiveBuffer.search(/\r>/g) !== -1 || sReceiveBuffer.search(/\n>/g) !== -1)
        {
            //The ELM has completely answered the command.
            //Received data is now in sReceiveBuffer.

            //There are spaces in the answer, we have to get rid of them. Hopefully it is that easy...
            //sReceiveBuffer = sReceiveBuffer.replace(/ /g, "");

            //Save received data to debug file
            if (bSaveDataToDebugFile) id_FileWriter.vWriteData("Receive: " + sReceiveBuffer + "\r\n");

            //Cut off the end characters
            if (sReceiveBuffer.search(/\r>/g) !== -1)
                sReceiveBuffer = sReceiveBuffer.substring(0, sReceiveBuffer.search(/\r>/g));
            else if (sReceiveBuffer.search(/\n>/g) !== -1)
                sReceiveBuffer = sReceiveBuffer.substring(0, sReceiveBuffer.search(/\n>/g));

            sReceiveBuffer = sReceiveBuffer.trim();

            //Set ready bit
            bCommandRunning = false;
        }
    }

    function fncShowMessage(iType ,sMessage, iTime)
    {
        messagebox.showMessage(iType, sMessage, iTime);
    }

    Sensors.OrientationSensor
    {
        id: rotationSensor
        active: true
        property int angle: reading.orientation ? _getOrientation(reading.orientation) : 0
        function _getOrientation(value)
        {
            switch (value)
            {
                case 2:
                    return 180
                case 3:
                    return -90
                case 4:
                    return 90
                default:
                    return 0
            }
        }
    }

    Messagebox
    {
        id: messagebox
        rotation: rotationSensor.angle
        width: Math.abs(rotationSensor.angle) == 90 ? parent.height : parent.width
        Behavior on rotation { SmoothedAnimation { duration: 500 } }
        Behavior on width { SmoothedAnimation { duration: 500 } }
    }        

    initialPage: Component { MainPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All
}


