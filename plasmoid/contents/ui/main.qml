import QtQuick 2.2
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

//http://api.kde.org/frameworks-api/frameworks5-apidocs/plasma-framework/html/IconsPage_8qml_source.html

Item {
    id: main
    
    property bool vertical: false
    property string accessToken: plasmoid.configuration.apiToken
    property int updateInterval: plasmoid.configuration.updateInterval
    property int unreadsCount: 0
    
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
        repeat: false
        onTriggered: {
            //unreadsCount += 1
            var url = 'https://cloud.feedly.com/v3/markers/counts'
            var http = new XMLHttpRequest()
            http.onreadystatechange = function() {
                if (http.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                    //console.log("Headers -->\n" + http.getAllResponseHeaders ())
                    //console.log("Last modified -->\n" + http.getResponseHeader ("Last-Modified"))
                } else if (http.readyState == XMLHttpRequest.DONE) {
                    //console.log("Headers -->\n" + http.getAllResponseHeaders ())
                    //console.log("Last modified -->" + http.getResponseHeader ("Last-Modified"))
                    //console.log('responseText -->\n' + http.responseText)
                    var responseObject = eval('new Object(' + http.responseText + ')')
                    var newUnreadsCount = 0
                    for (var i = 0; i < responseObject.unreadcounts.length; i++)
                    {
                        var nextId = responseObject.unreadcounts[i].id
                        if (nextId.substring(0, 5) == 'feed/') {
                            newUnreadsCount += responseObject.unreadcounts[i].count
                        }
                    }
                    unreadsCount = newUnreadsCount
                }
            }
            http.open('GET', url, true)
            http.setRequestHeader('Authorization', accessToken)
            http.send('')
        }
    }

    function updateTooltip() {
        var toolTipSubText = ''
        toolTipSubText += '<font size="4">'
        if (unreadsCount > 0) {
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
