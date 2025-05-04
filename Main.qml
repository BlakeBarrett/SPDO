import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 1.3
import QtQuick.Controls.Material 2.15
import QtQuick.Effects 1.0

Window {
    id: root
    width: 800
    height: 400
    visible: true
    title: SpeedReader.appName
    color: "#000000"

    // Handle close events to prevent accidental closing
    onClosing: function (close) {
        if (!confirmCloseDialog.visible) {
            close.accepted = false;
            confirmCloseDialog.open();
        }
    }

    // Animation for initial loading
    SequentialAnimation {
        running: true
        ScaleAnimator {
            target: analogNeedle
            from: 0
            to: 1
            duration: 500
            easing.type: Easing.OutBack
        }
    }

    // Background image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: speedReader.backgroundImagePath
        fillMode: Image.PreserveAspectCrop
        visible: speedReader.backgroundImagePath !== ""
    }

    // Digital gauge
    Text {
        id: digitalGauge
        anchors.centerIn: parent
        text: speedReader.displayText
        color: "white"
        font.pixelSize: 72
        font.bold: true
        style: Text.Outline
        styleColor: "black"
        visible: speedReader.showDigital
    }

    // Analog gauge components
    Item {
        id: analogGauge
        anchors.fill: parent
        visible: speedReader.showAnalog

        // Add a gauge background/plate for better visual reference
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.9
            height: width / 2  // Semi-circle for the top half
            radius: width / 2
            y: height  // Position to show only top half
            color: "#333333"
            opacity: 0.3
        }

        // Top speed indicator (green needle)
        Item {
            id: topSpeedNeedle
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            visible: speedReader.showTopSpeed && speedReader.topSpeed > 0

            Rectangle {
                id: topSpeedLine
                width: Math.min(parent.width, parent.height) * 0.45
                height: 8
                color: "#4CAF50" // green
                anchors.right: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                transformOrigin: Item.Right
                // Rotate from -90 (left/0 speed) to +90 (right/max speed)
                // Use topSpeed directly, as it's always in KPH internally
                rotation: -90 + (speedReader.topSpeed * 180) / speedReader.maxSpeed

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: parent.color
                    anchors.right: topSpeedLine.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Current speed indicator (red needle)
        Item {
            id: analogNeedle
            anchors.centerIn: parent
            width: parent.width
            height: parent.height

            Rectangle {
                id: needleLine
                width: Math.min(parent.width, parent.height) * 0.45
                height: 8
                color: "#F44336" // red
                anchors.right: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                transformOrigin: Item.Right
                // Rotate from -90 (left/0 speed) to +90 (right/max speed)
                // Use speedReader.speed directly, as it's always in KPH internally
                rotation: -90 + (speedReader.speed * 180) / speedReader.maxSpeed

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: parent.color
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Center dot
        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: "#FFFFFF"
            anchors.centerIn: parent
        }

        // Speed markings (tick marks)
        Repeater {
            model: 11 // 0 to max speed in 10 increments

            Item {
                anchors.centerIn: parent

                Rectangle {
                    width: 2
                    height: 10
                    color: "white"
                    y: -Math.min(analogGauge.width, analogGauge.height) * 0.42
                    // Position ticks from -90 to +90 degrees
                    transform: Rotation {
                        origin.x: 0
                        origin.y: 0
                        angle: -90 + (index * 180) / 10
                    }
                }

                // Add speed labels
                Text {
                    visible: index % 2 === 0 // Only show at even intervals
                    text: Math.round((index / 10) * speedReader.maxSpeed)
                    color: "white"
                    font.pixelSize: 12
                    y: -Math.min(analogGauge.width, analogGauge.height) * 0.45
                    horizontalAlignment: Text.AlignHCenter
                    // Position labels from -90 to +90 degrees
                    transform: Rotation {
                        origin.x: 0
                        origin.y: 0
                        angle: -90 + (index * 180) / 10
                    }
                }
            }
        }
    }

    // Fullscreen button (bottom right)
    Button {
        id: fullscreenButton
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        text: root.visibility === Window.FullScreen ? qsTr("⊙") : qsTr("□")
        font.pixelSize: 24
        opacity: 0.3

        onClicked: {
            if (root.visibility === Window.FullScreen) {
                root.visibility = Window.Windowed;
            } else {
                root.visibility = Window.FullScreen;
            }
        }
    }

    // Settings button (bottom left)
    Button {
        id: settingsButton
        width: 48
        height: 48
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        text: qsTr("⚙")
        font.pixelSize: 24
        opacity: 0.3

        onClicked: {
            drawer.open();
        }
    }

    // Settings drawer
    Drawer {
        id: drawer
        width: 300
        height: parent.height
        edge: Qt.LeftEdge

        Column {
            anchors.fill: parent
            spacing: 10
            padding: 10

            Text {
                text: qsTr("Settings")
                font.pixelSize: 24
                font.bold: true
            }

            Rectangle {
                width: parent.width - 20
                height: 1
                color: "#CCCCCC"
            }

            // Background image chooser
            RowLayout {
                width: parent.width - 20

                Button {
                    text: "\ue3b6" // Material Icon: photo
                    font.family: "Material Icons"
                    flat: true
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40

                    // Material style
                    Material.foreground: "#888888"
                    background: Rectangle {
                        color: "transparent"
                    }

                    onClicked: {
                        backgroundDialog.open();
                    }
                }

                Button {
                    text: qsTr("Choose Background")
                    Layout.fillWidth: true
                    onClicked: {
                        backgroundDialog.open();
                    }
                }

                Button {
                    text: qsTr("Clear")
                    onClicked: {
                        speedReader.setBackgroundImagePath("");
                    }
                }
            }

            Rectangle {
                width: parent.width - 20
                height: 1
                color: "#CCCCCC"
            }

            // Units switch
            RowLayout {
                width: parent.width - 20
                Text {
                    text: qsTr("Units: MPH | km/h")
                    font.bold: true
                    Layout.fillWidth: true
                }
                Switch {
                    checked: speedReader.metric
                    onCheckedChanged: {
                        speedReader.setMetric(checked);
                    }
                }
            }

            // Digital display switch
            RowLayout {
                width: parent.width - 20

                Image {
                    source: "qrc:///assets/numeric.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24
                }

                Text {
                    text: qsTr("Digital Display")
                    Layout.fillWidth: true
                }

                Switch {
                    checked: speedReader.showDigital
                    onCheckedChanged: {
                        speedReader.setShowDigital(checked);
                    }
                }
            }

            // Analog display switch
            RowLayout {
                width: parent.width - 20

                Image {
                    source: "qrc:///assets/wiper.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Apply red color to the SVG using MultiEffect instead of ColorOverlay
                    MultiEffect {
                        anchors.fill: parent
                        source: parent
                        colorization: 1.0
                        colorizationColor: "#F44336" // Red color
                    }
                }

                Text {
                    text: qsTr("Analog Display")
                    Layout.fillWidth: true
                }

                Switch {
                    checked: speedReader.showAnalog
                    onCheckedChanged: {
                        speedReader.setShowAnalog(checked);
                    }
                }
            }

            // Max Speed setting (only visible when analog is enabled)
            RowLayout {
                width: parent.width - 20
                visible: speedReader.showAnalog

                Image {
                    source: "qrc:///assets/max-speed.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Apply red color using MultiEffect instead of ColorOverlay
                    MultiEffect {
                        anchors.fill: parent
                        source: parent
                        colorization: 1.0
                        colorizationColor: "#F44336" // Red color
                    }
                }

                Text {
                    text: qsTr("Max Speed")
                    font.bold: true
                    Layout.fillWidth: true
                }

                SpinBox {
                    from: 10
                    to: 200
                    value: speedReader.maxSpeed
                    onValueModified: {
                        speedReader.setMaxSpeed(value);
                    }
                }

                Text {
                    text: speedReader.metric ? "km/h" : "MPH"
                    font.bold: true
                }
            }

            // Top speed indicator switch
            RowLayout {
                width: parent.width - 20

                Image {
                    source: "qrc:///assets/car-cruise-control.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Apply green color using MultiEffect instead of ColorOverlay
                    MultiEffect {
                        anchors.fill: parent
                        source: parent
                        colorization: 1.0
                        colorizationColor: "#4CAF50" // Green color
                    }
                }

                Text {
                    text: qsTr("Show Top Speed")
                    Layout.fillWidth: true
                }

                Switch {
                    checked: speedReader.showTopSpeed
                    onCheckedChanged: {
                        speedReader.setShowTopSpeed(checked);
                    }
                }
            }

            Item {
                height: 20
            } // spacer

            // Mode selection
            Rectangle {
                width: parent.width - 20
                height: 1
                color: "#CCCCCC"
            }

            ColumnLayout {
                width: parent.width - 20
                spacing: 8

                RowLayout {
                    width: parent.width

                    Button {
                        id: demoModeButton
                        text: qsTr("Demo Mode")
                        Layout.fillWidth: true
                        highlighted: !speedReader.gpsActive

                        onClicked: {
                            speedReader.startDemo();
                            drawer.close(); // Close drawer after selection
                        }
                    }

                    Button {
                        id: gpsModeButton
                        text: qsTr("GPS Mode")
                        Layout.fillWidth: true
                        highlighted: speedReader.gpsActive

                        onClicked: {
                            speedReader.startLocationUpdates();
                            drawer.close(); // Close drawer after selection
                        }
                    }
                }

                // GPS status indicator
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: speedReader.gpsActive ? "#4CAF50" : "#D32F2F"
                    radius: 4

                    Text {
                        id: gpsStatusText
                        anchors.centerIn: parent
                        text: speedReader.getGpsStatus()
                        color: "white"
                        font.pixelSize: 12
                    }

                    // Update the status text when the GPS state changes
                    Connections {
                        target: speedReader
                        function onGpsActiveChanged() {
                            gpsStatusText.text = speedReader.getGpsStatus();
                        }
                    }
                }
            }

            // About section
            Rectangle {
                width: parent.width - 20
                height: 1
                color: "#CCCCCC"
            }

            RowLayout {
                width: parent.width - 20

                Image {
                    source: "qrc:///assets/icon.svg"
                    width: 48
                    height: 48
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 48
                    sourceSize.height: 48
                }

                Button {
                    text: qsTr("About %1").arg(SpeedReader.appName)
                    Layout.fillWidth: true
                    onClicked: {
                        aboutDialog.open();
                    }
                }
            }
        }
    }

    // Reset top speed when tapping on screen
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Don't process clicks if they're on any UI controls
            if (!drawer.opened && !settingsButton.contains(Qt.point(mouseX, mouseY)) && !fullscreenButton.contains(Qt.point(mouseX, mouseY)) && !quickControlsRow.contains(Qt.point(mouseX, mouseY))) {
                speedReader.resetTopSpeed();
            }
        }
    }

    // Background image file dialog
    FileDialog {
        id: backgroundDialog
        title: qsTr("Choose a background image")
        nameFilters: [qsTr("Image files") + " (*.png *.jpg *.jpeg)"]
        onAccepted: {
            speedReader.setBackgroundImagePath(selectedFile);
        }
    }

    // Confirm exit dialog
    Dialog {
        id: confirmCloseDialog
        title: qsTr("Exit %1?").arg(SpeedReader.appName)
        modal: true
        standardButtons: Dialog.Yes | Dialog.No
        closePolicy: Popup.CloseOnEscape
        anchors.centerIn: Overlay.overlay
        width: Math.min(root.width * 0.7, 400)

        onAccepted: {
            Qt.quit();
        }

        Text {
            width: parent.width
            text: qsTr("Are you sure you want to exit the application?")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // About dialog
    Dialog {
        id: aboutDialog
        title: qsTr("About SPDO")
        standardButtons: Dialog.Ok
        anchors.centerIn: Overlay.overlay
        width: Math.min(root.width * 0.7, 400)

        ColumnLayout {
            spacing: 10
            width: parent.width

            Image {
                source: "qrc:///assets/icon.svg"
                width: 64
                height: 64
                Layout.alignment: Qt.AlignHCenter
                sourceSize.width: 64
                sourceSize.height: 64
            }

            Text {
                text: qsTr("%1 v%2").arg(SpeedReader.appName).arg(SpeedReader.appVersion)
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: qsTr("It's a speedometer.")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Connections to ensure UI stays in sync with SpeedReader state
    Connections {
        target: speedReader

        function onMetricChanged() {
            // Update unit display when metric changes
            updateDisplayText();
        }

        function onShowDigitalChanged() {
        // Already handled by the visibility binding on digitalGauge
        }

        function onShowAnalogChanged() {
        // Already handled by the visibility binding on analogGauge
        }

        function onShowTopSpeedChanged() {
        // Already handled by the visibility binding on topSpeedNeedle
        }

        function onSpeedChanged() {
        // Already handled by bindings
        }

        function onTopSpeedChanged() {
        // Already handled by bindings
        }

        function onMaxSpeedChanged() {
            // The gauge scale might need updating
            // This forces a layout refresh for the tick marks
            analogGauge.visible = false;
            analogGauge.visible = speedReader.showAnalog;
        }

        // Force display update when any relevant setting changes
        function onDisplayTextChanged() {
        // Already handled by binding to text property
        }
    }

    // Helper function to ensure display updates
    function updateDisplayText() {
        // This forces a refresh of the display text
        digitalGauge.text = speedReader.displayText;
    }

    Component.onCompleted: {
        // Initialize the app state - start in demo mode
        speedReader.startDemo();
    }

    // Top row shortcut buttons
    Row {
        id: quickControlsRow
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 10
        spacing: 10
        z: 10 // Make sure these are above other elements

        // Toggle Digital Display
        RoundButton {
            id: digitalToggleButton
            width: 40
            height: 40

            // Use the numeric icon from assets
            contentItem: Image {
                source: "qrc:///assets/numeric.svg"
                width: 24
                height: 24
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit
            }

            // Highlight if digital display is active
            background: Rectangle {
                radius: width / 2
                color: speedReader.showDigital ? "#3F51B5" : "#444444"
                opacity: 0.7
            }

            onClicked: {
                speedReader.setShowDigital(!speedReader.showDigital);
            }

            // Tooltip
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Toggle Digital Display")
            ToolTip.delay: 1000
        }

        // Toggle Analog Display
        RoundButton {
            id: analogToggleButton
            width: 40
            height: 40

            // Use the wiper icon from assets
            contentItem: Image {
                source: "qrc:///assets/wiper.svg"
                width: 24
                height: 24
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit

                // Apply red color to the SVG
                MultiEffect {
                    anchors.fill: parent
                    source: parent
                    colorization: 1.0
                    colorizationColor: "#F44336" // Red color
                }
            }

            // Highlight if analog display is active
            background: Rectangle {
                radius: width / 2
                color: speedReader.showAnalog ? "#3F51B5" : "#444444"
                opacity: 0.7
            }

            onClicked: {
                speedReader.setShowAnalog(!speedReader.showAnalog);
            }

            // Tooltip
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Toggle Analog Display")
            ToolTip.delay: 1000
        }

        // Toggle Top Speed
        RoundButton {
            id: topSpeedToggleButton
            width: 40
            height: 40

            // Use the cruise control icon from assets
            contentItem: Image {
                source: "qrc:///assets/car-cruise-control.svg"
                width: 24
                height: 24
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit

                // Apply green color to the SVG
                MultiEffect {
                    anchors.fill: parent
                    source: parent
                    colorization: 1.0
                    colorizationColor: "#4CAF50" // Green color
                }
            }

            // Highlight if top speed display is active
            background: Rectangle {
                radius: width / 2
                color: speedReader.showTopSpeed ? "#3F51B5" : "#444444"
                opacity: 0.7
            }

            onClicked: {
                speedReader.setShowTopSpeed(!speedReader.showTopSpeed);
            }

            // Tooltip
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Toggle Top Speed Indicator")
            ToolTip.delay: 1000
        }

        // Reset Top Speed
        RoundButton {
            id: resetTopSpeedButton
            width: 40
            height: 40

            // Show an X icon for reset
            contentItem: Text {
                text: qsTr("↺")
                font.pixelSize: 24
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: width / 2
                color: "#444444"
                opacity: 0.7
            }

            onClicked: {
                speedReader.resetTopSpeed();
            }

            // Tooltip
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Reset Top Speed")
            ToolTip.delay: 1000
        }

        // Toggle Units
        RoundButton {
            id: unitsToggleButton
            width: 40
            height: 40

            // Show text label for units
            contentItem: Text {
                text: speedReader.metric ? qsTr("km/h") : qsTr("MPH")
                font.pixelSize: 10
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: width / 2
                color: "#444444"
                opacity: 0.7
            }

            onClicked: {
                speedReader.setMetric(!speedReader.metric);
            }

            // Tooltip
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Toggle Units: ") + (speedReader.metric ? "km/h" : "MPH")
            ToolTip.delay: 1000
        }
    }
}
