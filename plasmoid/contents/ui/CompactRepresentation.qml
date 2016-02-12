import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import '../code/FeedlyUtils.js' as FeedlyUtils

Item {
    id: compactRepresentation
    
    property double itemWidth: parent === null ? 0 : vertical ? parent.width : parent.height
    property double itemHeight: itemWidth
    
    Layout.preferredWidth: itemWidth
    Layout.preferredHeight: itemHeight
    
    property bool textColorLight: ((theme.textColor.r + theme.textColor.g + theme.textColor.b) / 3) > 0.5
    property double fontPixelSize: itemWidth * 0.72

    property double iconWidth: itemWidth * 0.72
    property double iconHeight: itemHeight * 0.72
    
    /*
    PlasmaComponents.Label {
        id: feedIconLabel
        anchors.centerIn: parent
        text: '\uf09e'
        color: unreadsCount > 0 ? theme.textColor // '#2bb24c'
                                : (textColorLight ? Qt.tint(theme.textColor, '#80000000') : Qt.tint(theme.textColor, '#80FFFFFF'))
        font.family: 'FontAwesome'
        font.pixelSize: fontPixelSize
        font.pointSize: -1
    }
    */
    
    Image {
        id: feedIconImage
        
        source: '../images/feedly-logo.svg'
        anchors.centerIn: parent
        
        height: iconHeight
        width: iconWidth
    }
    
    ColorOverlay {
        anchors.fill: feedIconImage
        source: feedIconImage
        color: unreadsCount > 0 ? 'transparent' //'#2bb24c'
                                : (textColorLight ? Qt.tint(theme.textColor, '#80000000') : Qt.tint(theme.textColor, '#80FFFFFF'))
    }
    
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onClicked: {
            Qt.openUrlExternally(FeedlyUtils.feedlySiteUrl(useHttps))
        }
    }
}