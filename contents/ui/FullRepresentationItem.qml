import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents

Item {
	id: root
    property string percentdone: "--%"
    property string eta: "--"
    property string timeRemaining: "--"
    property string description: "--"
    property string status: "--"
    property int projectId: 0
    property int run: 0
    property int clone: 0
    property int gen: 0
    property string creditEstimate: "--"
    property string projectDescription: "--"
    property string version: "--"
    property bool runsOnlyWhenIdle: false
	property int fontSizeTitle: 12
	property int fontSizeSubtitle: 8

	Layout.minimumWidth: Kirigami.Units.gridUnit * 30
	Layout.minimumHeight: Kirigami.Units.gridUnit * 20
	implicitWidth: Kirigami.Units.gridUnit * 30
	implicitHeight: Kirigami.Units.gridUnit * 20

	ColumnLayout {
		anchors.fill: parent
		
		PlasmaComponents.Label {
			text: i18n(percentdone)
			font.bold: true
			font.pointSize: 24
		}
		RowLayout {
			id: row1
			spacing: 30
			ColumnLayout {
				PlasmaComponents.Label {
					id: column1
					text: i18n(`${projectId} (${run}, ${clone}, ${gen})`)
					anchors.right: Layout.alignment.right
					font.pointSize: fontSizeTitle
				}
				PlasmaComponents.Label {
					text: i18n("Work Unit (PRCG)")
					font.pointSize: fontSizeSubtitle
				}
			}
			ColumnLayout {
				PlasmaComponents.Label {
					id: column2
					text: i18n(`${eta}`)
					anchors.right: Layout.alignment.right
					font.pointSize: fontSizeTitle
				}
				PlasmaComponents.Label {
					text: i18n("Work Unit (ETA)")
					font.pointSize: fontSizeSubtitle
				}
			}
			ColumnLayout {
				PlasmaComponents.Label {
					id: column3
					text: i18n(`${creditEstimate}`)
					anchors.right: Layout.alignment.right
					font.pointSize: fontSizeTitle
				}
				PlasmaComponents.Label {
					text: i18n("Estimated Points")
					font.pointSize: fontSizeSubtitle
				}
			}

		}
		PlasmaComponents.Label {
			text: i18n("I am contributing to")
			font.pointSize: fontSizeSubtitle
		}
		PlasmaComponents.Label {
			text: i18n(`Project ${projectId}`)
			font.pointSize: fontSizeTitle
		}
		// Rectangle {
		// 	color: "#ff0"
		// 	Layout.fillHeight: true
		// 	Layout.fillWidth: true
		// }
		PlasmaComponents.Label {
			text: i18n(projectDescription)
			wrapMode: Text.WordWrap
			Layout.fillHeight: true
			Layout.fillWidth: true
		}
	}
}