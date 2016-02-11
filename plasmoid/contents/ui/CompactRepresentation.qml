import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents


PlasmaComponents.Label {
    Layout.minimumWidth : formFactor == PlasmaCore.Types.Horizontal ? height : 1
    Layout. minimumHeight : formFactor == PlasmaCore.Types.Vertical ? width  : 1
    text: "Hello world in plasma5 ";
}
