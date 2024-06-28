import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "application.js" as App

PlasmoidItem {
    id: root
    property string sid: ""
    property string percentdone: "--%"
    property string eta: "--"
    property string timeRemaining: "--"
    property string description: "--"
    property string status: "--"
    property int projectId: 0
    property int run: 0
    property int clone: 0
    property int gen: 0
    property real iconImageOpacity: 0.5
    property string creditEstimate: "--"
    property string projectDescription: "--"
    property string version: "--"
    property bool runsOnlyWhenIdle: false
    property bool isDesktopContainment: plasmoid.location == PlasmaCore.Types.Floating

    // preferredRepresentation: isDesktopContainment ? fullRepresentation : compactRepresentation
    preferredRepresentation: compactRepresentation

    Timer {
        id: timer
        // @see https://stackoverflow.com/a/50224584
        function setTimeout(cb, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            timer.triggered.connect(cb);
            timer.triggered.connect(function release () {
                timer.triggered.disconnect(cb); // This is important
                timer.triggered.disconnect(release); // This is important as well
            });
            timer.start();
        }
    }

    fullRepresentation: FullRepresentationItem {
        percentdone: root.percentdone
        eta: root.eta
        timeRemaining: root.timeRemaining
        description: root.description
        status: root.status
        projectId: root.projectId
        run: root.run
        clone: root.clone
        gen: root.gen
        projectDescription: root.projectDescription
        version: root.version
        runsOnlyWhenIdle: root.runsOnlyWhenIdle
        creditEstimate: root.creditEstimate
    }

    compactRepresentation: RowLayout {
        anchors.fill: parent
        Image {
            id: iconImage
            source: "../images/icon"
            opacity: iconImageOpacity
        }
        PlasmaComponents.Label {
            id: compactRepresentationLabel
            text: i18n(percentdone)
            leftPadding: Kirigami.Units.gridUnit 
            rightPadding: Kirigami.Units.gridUnit 
        }
    }

    toolTipItem: FullRepresentationItem {
        id: fullItem
        visible: false
        percentdone: root.percentdone
        eta: root.eta
        timeRemaining: root.timeRemaining
        description: root.description
        status: root.status
        projectId: root.projectId
        run: root.run
        clone: root.clone
        gen: root.gen
        projectDescription: root.projectDescription
        creditEstimate: root.creditEstimate
        version: root.version
        runsOnlyWhenIdle: root.runsOnlyWhenIdle
    }

    Component.onCompleted: () => {
        App.createSession().then((response) => {
            if (response.status !== 200) {
                console.error("Unable to start session");
                return null;
            }
            sid = response.content;
            App.getUpdates(timer, sid, (response) => {
                if (!response.json) {
                    return;
                }
                root.iconImageOpacity = 1;
                response.json.forEach(command => {
                    if (command[0] === "/api/basic") {
                        root.version = command[1].version;
                    } else if (command[0] === "/api/slots") {
                        root.percentdone = command[1][0].percentdone;
                        root.runsOnlyWhenIdle = command[1][0].idle;
                        root.eta = command[1][0].eta;
                        root.timeRemaining = command[1][0].timeremaining;
                        root.description = command[1][0].description;
                        root.status = command[1][0].status;
                        root.run = command[1][0].run;
                        root.clone = command[1][0].clone;
                        root.gen = command[1][0].gen;
                        root.creditEstimate = command[1][0].creditestimate
                        if (root.projectId !== command[1][0].project && root.version) {
                            App.getProjectInfo(command[1][0].project, root.version, (response) => {
                                root.projectDescription = response.json[0][1].pdesc
                            });
                        }
                        root.projectId = command[1][0].project;
                    }
                });
            })
        });
    }

}
