import QtQuick 2.2
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

//http://api.kde.org/frameworks-api/frameworks5-apidocs/plasma-framework/html/IconsPage_8qml_source.html

Item {
    id: main
    
    property int updateInterval: 1//plasmoid.configuration.updateInterval
    property int unreadsCount: 0
    property bool hasUnreads: unreadsCount > 0
    
    onUnreadsCountChanged: updateTooltip()
    
    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: CompactRepresentation { }
    
    FontLoader {
        source: '../fonts/fontawesome-webfont-4.3.0.ttf'
    }
    
    Component.onCompleted: {
        updateTooltip()
        updateTimer.start()
    }
    
    Timer {
        id: updateTimer
        interval: 1000 //updateInterval * 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            unreadsCount += 1
        }
    }
    
    function updateTooltip() {
        var toolTipSubText = ''
        toolTipSubText += '<font size="4">'
        if (hasUnreads) {
            toolTipSubText += 'You have ' + unreadsCount + (unreadsCount == 1 ? ' unread entry.' : ' unreads entries.')
        } else {
            toolTipSubText += 'There are no new entries.' 
        }
        toolTipSubText += '</font>'
        toolTipSubText += '<br />'
        toolTipSubText += '<i>Click on icon to open Feedly site in browser.</i>'
        Plasmoid.toolTipSubText = toolTipSubText       
    }
}
