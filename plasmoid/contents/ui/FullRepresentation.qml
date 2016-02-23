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

    property double representationWidth: 300 * 0.75
    property double representationHeight: 300 * 0.75
    property double titleHeight: 50
    property bool textColorLight: ((theme.textColor.r + theme.textColor.g + theme.textColor.b) / 3) > 0.5
    
    Layout.minimumWidth: representationWidth
    Layout.preferredWidth: representationWidth
    Layout.minimumHeight: representationHeight
    Layout.preferredHeight: representationHeight
    
    RowLayout {
        id: unreadsLayout
        anchors.left: parent.left
        anchors.top: parent.top
        
        Image {
            id: feedIconImage
            source: '../images/feedly-logo.svg'
            Layout.preferredHeight: 18
            Layout.preferredWidth: 18
            ColorOverlay {
                id: feedIconImageColorOverlay
                anchors.fill: feedIconImage
                source: feedIconImage
                color: textColorLight ? Qt.tint(theme.textColor, '#80000000') : Qt.tint(theme.textColor, '#80FFFFFF')
            }
        }
        PlasmaComponents.Label {
            id: unreadsCountLabel
            text: unreadsCount + (unreadsCount == 1 ? ' unread entry.' : ' unread entries.')
            color: theme.textColor
        }
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: unreadsLayout
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
                githubLabel.color = '#467cc1'
            }
            onExited: {
                githubLabel.color = theme.textColor
            }
        }
    }
    
    Image {
        id: mainArticleImage
        anchors.top: unreadsLayout.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        //source: 'http://f.fastcompany.net/multisite_files/fastcompany/imagecache/620x350/poster/2016/02/3056628-poster-p-2-how-scientists-rediscovered-graffiti-scratched-by-astronauts-inside-apollo-11.jpg'
        source: mostPopularImage
        fillMode: Image.PreserveAspectCrop
    }
   
    Rectangle {
        id: mainArticleBackground
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: titleHeight
        color: '#90000000'
        visible: mostPopularTitle != ''
        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: mainArticleBackground
            hoverEnabled: true
            onClicked: {
                Qt.openUrlExternally(FeedlyUtils.feedlySiteUrl(useHttps))
            }
            onEntered: {
                mainArticleBackground.color = '#C0000000'
            }
            onExited: {
                mainArticleBackground.color = '#90000000'
            }
        }
    }
   
    Item {
        id: mainArticleLayout
        height: titleHeight - 3*2 // minus margins
        width: parent.width
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 3
        visible: mostPopularTitle != ''

        Label {
            id: mainLayoutLabel
            //text: 'Scientists Rediscover Astronaut Graffiti Scratched Inside Apollo 11'
            text: mostPopularTitle
            color: 'white'
            elide: Text.ElideRight
            font.bold : true
            anchors.top: parent.verticalCenter
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            verticalAlignment: Text.AlignBottom
        }
        
        Label {
            id: mainIconFires
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.verticalCenter
            text: '\uf06d'
            color: '#ff960b'
            font.family: 'FontAwesome'
        }
        
        Label {
            id: mainIconFireCounts
            anchors.left: mainIconFires.right
            anchors.top: parent.top
            anchors.bottom: parent.verticalCenter
            //text: '5K'
            text: mostPopularEngagement
            color: '#ff960b'
        }
        
        Label {
            //text: '<b>Fubiz</b> 5 days ago'
            text: '<b>'+ mostPopularFrom + '</b> ' + dateToFuzzyDate(mostPopularDate)
            color: 'white'
            elide: Text.ElideRight
            anchors.top: parent.top
            anchors.bottom: parent.verticalCenter
            anchors.left: mainIconFireCounts.right
            anchors.right: parent.right
            horizontalAlignment: Text.AlignRight
        }
    }

    function dateToFuzzyDate(date){
        var timeDiff = Date.now() - date // in milliseconds
        if (timeDiff < (60 * 60 * 1000)) {
            return Math.floor(timeDiff/(60*1000)) + ' minute(s) ago'
        } else if (timeDiff < (24 * 60 * 60 * 1000)) {
            return Math.floor(timeDiff/(60*60*1000)) + ' hour(s) ago'
        } else if (timeDiff < (7*24 * 60 * 60 * 1000)) {
            return Math.floor(timeDiff/(24*60*60*1000)) + ' day(s) ago'
        } else {
            return Math.floor(timeDiff/(7*24*60*60*1000)) + ' week(s) ago'
        }
    }
}