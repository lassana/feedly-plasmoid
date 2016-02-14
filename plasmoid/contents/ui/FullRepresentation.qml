import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import '../code/FeedlyUtils.js' as FeedlyUtils

Item {
    id: fullRepresentation
    
    property int targetWidth: 300
    property int targetHeight: 300

    property bool textColorLight: ((theme.textColor.r + theme.textColor.g + theme.textColor.b) / 3) > 0.5
    Layout.minimumWidth: targetWidth
    Layout.preferredWidth: targetWidth
    Layout.preferredHeight: targetHeight

    RowLayout {
        id: unreadsLayout
        anchors.left: parent.left
        anchors.top: parent.top
        
        Image {
            id: feedIconImage
            source: '../images/feedly-logo.svg'
            Layout.preferredHeight: 18
            Layout.preferredWidth: 18
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: feedIconImage
                hoverEnabled: true
                onClicked: {
                    Qt.openUrlExternally(FeedlyUtils.feedlySiteUrl(useHttps))
                }
                onEntered: {
                    feedIconImageColorOverlay.color = 'transparent'
                }
                onExited: {
                    feedIconImageColorOverlay.color = textColorLight ? Qt.tint(theme.textColor, '#80000000') : Qt.tint(theme.textColor, '#80FFFFFF')
                }
            }
            ColorOverlay {
                id: feedIconImageColorOverlay
                anchors.fill: feedIconImage
                source: feedIconImage
                color: textColorLight ? Qt.tint(theme.textColor, '#80000000') : Qt.tint(theme.textColor, '#80FFFFFF')
            }
        }
        PlasmaComponents.Label {
            text: unreadsCount + (unreadsCount == 1 ? ' unread entry.' : ' unread entries.')
            color: theme.textColor
        }
    }

    PlasmaComponents.Label {
        id: githubLabel
        anchors.right: parent.right
        anchors.top: parent.top
        text: '\uf09b'
        color: theme.textColor
        font.family: 'FontAwesome'
        verticalAlignment: Text.AlignTop
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: githubLabel
            hoverEnabled: true
            onClicked: {
                Qt.openUrlExternally('https://github.com/lassana/feedly-plasmoid')
            }
            onEntered: {
                githubLabel.color = '#1a0dab'
            }
            onExited: {
                githubLabel.color = theme.textColor
            }
        }
    }
    
    Rectangle {
        anchors.top: unreadsLayout.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: 'red'
        height: 33
    }
}