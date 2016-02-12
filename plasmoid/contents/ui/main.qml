import QtQuick 2.2
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: main
    
    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)
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
        interval: updateInterval * 60 * 1000
        running: true
        repeat: true
        onTriggered: {
            var url = 'https://cloud.feedly.com/v3/markers/counts'
            var http = new XMLHttpRequest()
            http.onreadystatechange = function() {
                if (http.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                    //console.log("Headers -->\n" + http.getAllResponseHeaders ())
                    //console.log("Last modified -->\n" + http.getResponseHeader ("Last-Modified"))
                } else if (http.readyState == XMLHttpRequest.DONE) {
                    var newUnreadsCount = 0
                    //console.log("Headers -->\n" + http.getAllResponseHeaders ())
                    //console.log("Last modified -->" + http.getResponseHeader ("Last-Modified"))
                    //console.log("Status -->" + http.status)
                    //console.log('responseText -->\n' + http.responseText)
                    if (http.status == 200) {
                        var responseObject = eval('new Object(' + http.responseText + ')')
                        for (var i = 0; i < responseObject.unreadcounts.length; i++)
                        {
                            var nextId = responseObject.unreadcounts[i].id
                            if (nextId.substring(0, 5) == 'feed/') {
                                newUnreadsCount += responseObject.unreadcounts[i].count
                            }
                        }
                    }
                    console.log('newUnreadsCount: ' + newUnreadsCount)
                    unreadsCount = newUnreadsCount
                }
            }
            http.open('GET', url, true)
            http.setRequestHeader('Authorization', accessToken)
            http.setRequestHeader('Authorization', tkn)
            http.send('')
        }
    }

    function updateTooltip() {
        var toolTipSubText = ''
        toolTipSubText += '<font size="4">'
        if (unreadsCount > 0) {
            toolTipSubText += 'You have ' + unreadsCount + (unreadsCount == 1 ? ' unread entry.' : ' unread entries.')
        } else {
            toolTipSubText += 'There are no new entries.' 
        }
        toolTipSubText += '</font>'
        toolTipSubText += '<br />'
        toolTipSubText += '<i>Click on icon to open Feedly in browser.</i>'
        Plasmoid.toolTipSubText = toolTipSubText       
    }
}
