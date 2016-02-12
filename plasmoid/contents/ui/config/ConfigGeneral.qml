import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    
    property alias cfg_apiToken: accessTokenTextField.text
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_useHttps: httpsCheckbox.checked

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
            text: 'Developer token:'
            Layout.row: 1
            Layout.column: 0
        }
        
        TextField {
            id: accessTokenTextField
            placeholderText: 'FzWPqb-g4j3xA...'
            Layout.row: 1
            Layout.column: 1
        }
        
        Button {
            id: loginButton
            text: 'Get new one'
            iconName: 'feed-subscribe'
            Layout.row: 1
            Layout.column: 2
            onClicked: {
                Qt.openUrlExternally('https://feedly.com/v3/auth/dev')
            }
        }
        
        CheckBox {
            id: httpsCheckbox
            text: 'Use secure connection'
            Layout.row: 2
            Layout.column: 0
        }
    } 
}