import QtQuick 2.2
import QtQuick.Layouts 1.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import '../code/FeedlyUtils.js' as FeedlyUtils

Item {
    id: main
    
    property bool vertical: (Plasmoid.formFactor == PlasmaCore.Types.Vertical)
    property bool useHttps: Plasmoid.configuration.useHttps
    property string accessToken: Plasmoid.configuration.accessToken
    property int updateInterval: Plasmoid.configuration.updateInterval
    property int unreadsCount: 0
    
    property string mostPopularEngagement
    property string mostPopularTitle
    property string mostPopularUrl
    property string mostPopularImage
    property string mostPopularFrom
    property string mostPopularDate
    
    onUnreadsCountChanged: updateTooltip()
    
    //Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: CompactRepresentation {}
    Plasmoid.fullRepresentation: FullRepresentation { }
    
    FontLoader {
        source: '../fonts/fontawesome-webfont-4.3.0.ttf'
    }
    
    Component.onCompleted: {
        updateTooltip()
        Plasmoid.setAction('reload', 'Refresh', 'view-refresh')
        updateUnreadCounts()
        updateTimer.start()
    }
    
    Timer {
        id: updateTimer
        interval: updateInterval * 60 * 1000
        running: true
        repeat: true
        onTriggered: updateUnreadCounts()
    }

    function action_reload() {
        updateUnreadCounts()
    }
    
    function updateUnreadCounts() {
        var tkn = accessToken
        FeedlyUtils.getUnreadCounts(tkn, useHttps, function(newUnreadsCount, mostPopular) {
            unreadsCount = newUnreadsCount
            mostPopularEngagement = mostPopular.engagement
            mostPopularTitle = mostPopular.title
            mostPopularUrl = mostPopular.url
            mostPopularImage = mostPopular.image
            mostPopularFrom = mostPopular.from
            mostPopularDate = mostPopular.date
        })
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
        toolTipSubText += '<i>Use middle button click to open Feedly in browser.</i>'
        Plasmoid.toolTipSubText = toolTipSubText       
    }
}
