import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
	id: root
	Layout.minimumWidth: Kirigami.Units.gridUnit * 5
	Layout.minimumHeight: Kirigami.Units.gridUnit * 5
    property string percentdone: "--%"

	implicitHeight: Kirigami.Units.gridUnit * 10
	implicitWidth: Kirigami.Units.gridUnit * 10

	PlasmaComponents.Label {
		text: i18n(percentdone)
	}
}