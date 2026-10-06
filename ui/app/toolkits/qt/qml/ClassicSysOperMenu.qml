// ClassicSysOperMenu.qml — Gtk-style system-operation control for the classic
// break windows. A single available operation renders as a plain button; with
// several available it becomes a "Lock..." dropdown, like the Gtk combobox.

import QtQuick

Item {
    id: opRoot

    PrefTokens { id: tok }

    property bool lockable: false
    property bool shutdownable: false
    property bool sleepable: false

    signal lockRequested()
    signal shutdownRequested()
    signal sleepRequested()

    // Available operations, in Gtk order (historical Gtk msgids).
    readonly property var ops: {
        var l = [];
        if (lockable)     l.push({ label: qsTr("Lock"),     act: "lock" });
        if (shutdownable) l.push({ label: qsTr("Shutdown"), act: "shutdown" });
        if (sleepable)    l.push({ label: qsTr("Suspend"),  act: "sleep" });
        return l;
    }
    readonly property bool multi: ops.length > 1
    property bool menuOpen: false

    visible: ops.length > 0
    width: button.width
    height: button.height

    function trigger(act) {
        menuOpen = false;
        if (act === "lock")          lockRequested();
        else if (act === "shutdown") shutdownRequested();
        else if (act === "sleep")    sleepRequested();
    }

    Rectangle {
        id: button
        height: 28
        width: Math.max(btnLbl.implicitWidth + 24, 88)
        radius: 8
        color: btnArea.containsMouse ? tok.sageSoft : tok.actionBg
        border.color: tok.actionEdge; border.width: 1

        Text {
            id: btnLbl
            anchors.centerIn: parent
            text: opRoot.multi ? qsTr("Lock...") + "  ▾"
                               : (opRoot.ops.length > 0 ? opRoot.ops[0].label : "")
            font.pixelSize: 12
            color: tok.ink
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (opRoot.multi) {
                    opRoot.menuOpen = !opRoot.menuOpen;
                } else if (opRoot.ops.length > 0) {
                    opRoot.trigger(opRoot.ops[0].act);
                }
            }
        }
    }

    Rectangle {
        id: popup
        visible: opRoot.menuOpen
        z: 100
        y: button.height + 2
        width: Math.max(button.width, 132)
        height: itemsCol.implicitHeight + 2
        color: tok.card
        border.color: tok.actionEdge; border.width: 1

        Column {
            id: itemsCol
            anchors { fill: parent; margins: 1 }

            Repeater {
                model: opRoot.ops
                delegate: Rectangle {
                    id: opItem
                    required property var modelData
                    width: itemsCol.width
                    height: 26
                    color: itemArea.containsMouse ? tok.sageSoft : "transparent"

                    Text {
                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                        text: opItem.modelData.label
                        font.pixelSize: 12
                        color: tok.ink
                    }

                    MouseArea {
                        id: itemArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: opRoot.trigger(opItem.modelData.act)
                    }
                }
            }
        }
    }
}
