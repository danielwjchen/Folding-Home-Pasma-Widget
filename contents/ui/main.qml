import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import "application.js" as App

PlasmoidItem {
    id: root
    Layout.minimumWidth: Kirigami.Units.gridUnit * 5
    Layout.minimumHeight: Kirigami.Units.gridUnit * 5

    implicitHeight: Kirigami.Units.gridUnit * 10
    implicitWidth: Kirigami.Units.gridUnit * 10

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

    Component.onCompleted: () => {
        App.createApp(timer).then((app) => {
            app.onUpdate((response) => {
                if (!response.json) {
                    return;
                }
                response.json.forEach(command => {
                    if (command[0] === "/api/slots") {
                        refreshButton.text = command[1][0].percentdone;
                    }
                });
            });
        });
    }

    PlasmaComponents.Button {
        id: refreshButton
        text: i18n("--%")
        onClicked: getUpdates()
    }

}
