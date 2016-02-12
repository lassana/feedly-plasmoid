import QtQuick 2.0

import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
         name: 'General'
         icon: Qt.resolvedUrl('../images/feedly-logo.svg')
         source: 'config/ConfigGeneral.qml'
    }
}