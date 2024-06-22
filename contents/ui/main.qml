import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import "application.js" as App

PlasmoidItem {
    id: root
    property string sid: ""
    property string percentdone: "--%"

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
    }

    compactRepresentation: Item {
        id: refreshButton
        anchors.fill: parent
        PlasmaComponents.Label {
            text: i18n(percentdone)
        }
    }

    toolTipItem: FullRepresentationItem {
        id: fullItem
        visible: false
        percentdone: root.percentdone
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
                response.json.forEach(command => {
                    if (command[0] === "/api/slots") {
                        percentdone = command[1][0].percentdone;
                    }
                });
            })
        });
    }

}
