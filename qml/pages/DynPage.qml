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
import Nemo.KeepAlive 1.2
import harbour.obdfish 1.0
import "OBDDataObject.js" as OBDDataObject

Page
{
    allowedOrientations: Orientation.All
    id: id_page_dyn
    property int pageIndex: 0
    property bool bInitPage: true
    property int iWaitForCommand: 0
    property int iCommandSequence: 0
    property variant arPIDPageArray : []
    property string sCycleTime : "0"
    property double iStartTime : 0
    property double iNowTime : 0

    onStatusChanged:
    {
        if (status === PageStatus.Active && !canNavigateForward && pageIndex < 2)
        {
            pageStack.pushAttached(Qt.resolvedUrl("DynPage.qml"), { "pageIndex": pageIndex + 1 });
        }

        if (status === PageStatus.Active)
        {
            bInitPage = true;

            iCommandSequence = 0;
            sCycleTime = 0;
            iStartTime = 0;
            iNowTime = 0;

            //Fill PID's for this Page into an array. Empty spaces between two PID's should be avoided.
            var arPIDsPage = arPIDsPagesArray[pageIndex].split(",");
            var arPIDPageArrayTemp = [];
            for (var i = 0; i < arPIDsPage.length; i++)
            {
                if (arPIDsPage[i] !== "0000")
                    arPIDPageArrayTemp.push(arPIDsPage[i]);
            }
            arPIDPageArray = arPIDPageArrayTemp;

            id_PlotWidget.reset();
            parameters.clear();

            bInitPage = false;
        }
    }

    DisplayBlanking {
        id: display
        preventBlanking: id_page_dyn.status === PageStatus.Active
    }

    ListModel {
        id: parameters
    }

    Timer
    {
        //This timer is called cyclically to query ELM
        id: timQueryELMParameters
        interval: 55
        running: ((status === PageStatus.Active) && !bInitPage && display.status !== DisplayBlanking.Off)
        repeat: true
        onTriggered:
        {
            //Check if ELM has answered correctly to current AT command
            if (bCommandRunning == false)
            {
                iWaitForCommand = 0;

                //console.log("timQueryELMParameters step: " + iCommandSequence.toString());

                if (iCommandSequence == 0)
                {
                    //If a start time was saved before, calculate cycle time.
                    if (iStartTime !== 0)
                    {
                        iNowTime = new Date().getTime();

                        sCycleTime = (iNowTime - iStartTime).toString();
                    }

                    //Save current time in order to calculate the cycle time.
                    iStartTime = new Date().getTime();
                }

                var idx = 0;
                if (iCommandSequence % 2 == 0) {
                    idx = (iCommandSequence) / 2;
                    if (arPIDPageArray.length > idx && fncStartCommand(arPIDPageArray[idx] + "1")) {
                        iCommandSequence++;
                    } else
                    {
                        switch (idx) {
                        case 0:
                            sCoverValue1 = "";
                            break;
                        case 1:
                            sCoverValue2 = "";
                            break;
                        case 2:
                            sCoverValue3 = "";
                            break;
                        }
                        parameters.set(idx, {"label": qsTr("Empty"), "value": ""});
                        iCommandSequence += 2;
                    }

                } else {
                    idx = (iCommandSequence - 1) / 2
                    var label = OBDDataObject.arrayLookupPID[arPIDPageArray[idx]].labeltext;
                    var value = OBDDataObject.fncEvaluatePIDQuery(sReceiveBuffer, arPIDPageArray[idx].toUpperCase()) +
                        OBDDataObject.arrayLookupPID[arPIDPageArray[idx]].unittext
                    parameters.set(idx, {"label": label, "value": value});

                    switch (idx) {
                    case 0:
                        sCoverValue1 = value;
                        break;
                    case 1:
                        sCoverValue2 = value;
                        break;
                    case 2:
                        sCoverValue3 = value;
                        break;
                    }

                    if (idx == 0)
                    {
                        id_PlotWidget.addValue(value);
                        id_PlotWidget.update();
                    }

                    iCommandSequence++;
                }

                if (iCommandSequence >= arPIDPageArray.length * 2)
                    iCommandSequence = 0
            }
            else
            {
                //ELM has not yet answered. Or the answer is not complete.
                //Check if wait time is over.
                if (iWaitForCommand == 20)
                {
                    //Skip now.
                    bCommandRunning = false;
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

        PullDownMenu
        {
            MenuItem
            {
                text: qsTr("Settings")
                onClicked: {pageStack.push(Qt.resolvedUrl("SettingsPage.qml"), {iPIDPageIndex: pageIndex})}
            }
        }
        Column
        {
            id: id_Column_FirstCol

            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader { title: qsTr("Dynamic Values %1").arg(pageIndex) }

            Row
            {
                IconButton
                {
                    icon.source: "image://theme/icon-m-question"
                    onClicked:
                    {
                        fncShowMessage(1,qsTr("The more parameters are requested, the higher the cycle time.<br>To get a more responsive cycle time, go to settings and reduce amount of parameters for this page."), 20000);
                    }
                }
                Label
                {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMedium
                    text: qsTr("Cycle time: ") + sCycleTime + "ms";
                }
            }
            Separator
            {
                color: Theme.highlightColor
                width: parent.width
            }

            Repeater{
                model: parameters

                Component {
                    id: smallDisplay
                    DetailItem {
                        label: model.label
                        value: model.value
                    }
                }


                Component {
                    id: bigDisplay
                    Label {
                        text: model.value
                        font.pixelSize: Theme.fontSizeHuge * 2
                        truncationMode: TruncationMode.Elide
                        horizontalAlignment: Label.AlignHCenter
                        width: id_page_dyn.width
                    }
                }

                delegate: pagesDisplayStyle[pageIndex] === "small" ? smallDisplay : bigDisplay
            }

            PlotWidget
            {
                id: id_PlotWidget
                visible: (arPIDPageArray.length == 1) && pagesDisplayStyle[pageIndex] === "small"
                width: parent.width
                height: 150
                plotColor: Theme.highlightColor
                scaleColor: Theme.secondaryHighlightColor
            }
        }
    }
}
