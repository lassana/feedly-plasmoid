import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.2
import QtWebKit 3.0
import QtWebKit.experimental 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import '../../code/FeedlyUtils.js' as FeedlyUtils

Item {
    
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_useHttps: httpsCheckbox.checked

    ColumnLayout {
        GridLayout {
            rows: 2
            columns: 3        
            Label {
                text: 'Update interval (minutes):'
                Layout.row: 0
                Layout.column: 0
            }
            SpinBox {
                id: updateIntervalSpinBox
                decimals: 0
                stepSize: 1
                minimumValue: 1
                maximumValue: 180
                Layout.row: 0
                Layout.column: 1
            }        
            Label {
                text: 'API token: (' 
                        + (plasmoid.configuration.accessToken == ''
                            ? 'no one' 
                            : (plasmoid.configuration.accessToken.substring(0,5) + '...'))
                        + ')'
                Layout.row: 1
                Layout.column: 0
            }
            Button {
                id: loginButton
                text: plasmoid.configuration.accessToken == '' ? 'Get new one' : 'Remove'
                iconName: 'feed-subscribe'
                Layout.row: 1
                Layout.column: 1
                onClicked: {
                    if (plasmoid.configuration.accessToken == '') {
                        loginButton.enabled = false
                        webView.visible = true
                        FeedlyUtils.getHtmlAuth(cfg_useHttps, function(html) {
                            webView.loadHtml(html, FeedlyUtils.feedlyBaseApiUrl(cfg_useHttps), FeedlyUtils.feedlyRedirectUrl())
                        })
                    } else {
                        plasmoid.configuration.accessToken = ''
                        plasmoid.configuration.refreshToken = ''
                        plasmoid.configuration.tokenExpires = ''
                    }
                }
            }        
            CheckBox {
                id: httpsCheckbox
                text: 'Use secure connection'
                Layout.row: 2
                Layout.column: 0
            }
        }
        WebView {
            id: webView
            width: 470
            height: 270
            experimental.preferences.privateBrowsingEnabled: true
            visible: false
            onNavigationRequested: {
                var array = FeedlyUtils.FEEDLY_API_ENDPOINT_REGEX.exec(request.url)
                if (array != null && array.length == 2) {
                    var code = array[1]
                    FeedlyUtils.getTokens(code, cfg_useHttps, function(argAccessToken, argRefreshToken, argExpiresIn) {
                        //console.log('argAccessToken  = ' + argAccessToken)
                        //console.log('argRefreshToken = ' + argRefreshToken)
                        //console.log('argExpiresIn    = ' + argExpiresIn)
                        plasmoid.configuration.accessToken = argAccessToken
                        plasmoid.configuration.refreshToken = argRefreshToken
                        plasmoid.configuration.tokenExpires = (Date.now() + argExpiresIn)
                        webView.visible = false
                        loginButton.enabled = true
                    })
                }
            }
        }
    }
}