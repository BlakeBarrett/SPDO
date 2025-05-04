import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 6.4
import QtQuick.Controls.Material 2.15
import com.blakebarrett.spdo 2.0

Window {
    id: root
    width: 1024
    height: 1024
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
        source: SpeedReader.backgroundImagePath
        fillMode: Image.PreserveAspectCrop
        visible: SpeedReader.backgroundImagePath !== ""
    }

    // Digital gauge
    Text {
        id: digitalGauge
        anchors.centerIn: parent
        text: SpeedReader.displayText
        color: "white"
        font.pixelSize: 72
        font.bold: true
        style: Text.Outline
        styleColor: "black"
        visible: SpeedReader.showDigital
    }

    // Analog gauge components
    Item {
        id: analogGauge
        anchors.fill: parent
        visible: SpeedReader.showAnalog

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
            visible: SpeedReader.showTopSpeed && SpeedReader.topSpeed > 0

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
                rotation: ((SpeedReader.topSpeed / SpeedReader.maxSpeed) * 90)

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: parent.color
                    anchors.horizontalCenter: topSpeedLine.right
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
                // Use SpeedReader.speed directly, as it's always in KPH internally
                rotation: ((SpeedReader.speed / SpeedReader.maxSpeed) * 90)

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: parent.color
                    anchors.horizontalCenter: parent.right
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
                id: tickItem
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) // Ensure the item spans the full gauge width
                height: width
                
                // Apply the rotation to the whole item
                rotation: -90 + (index * 180) / 10
                
                // Tick mark
                Rectangle {
                    width: 2
                    height: 10
                    color: "white"
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height * 0.08 // Position from center to edge of the gauge
                }
                
                // Speed label
                // Text {
                //     visible: index % 2 === 0 // Only show at even intervals
                //     text: Math.round((index / 10) * SpeedReader.maxSpeed)
                //     color: "white"
                //     font.pixelSize: 12
                //     anchors.horizontalCenter: parent.horizontalCenter
                //     y: parent.height * 0.05 // Position above the tick marks
                //     rotation: -(-90 + (index * 180) / 10) // Counter-rotate to keep text upright
                // }
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
        opacity: 0.8 // Increased opacity for better visibility
        
        // Add a background for better visibility
        background: Rectangle {
            color: "#444444"
            radius: 5
            border.color: "#666666"
            border.width: 1
        }

        contentItem: Text {
            text: root.visibility === Window.FullScreen ? qsTr("⊙") : qsTr("□")
            color: "white"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        // Use a more compatible approach for fullscreen toggling on Linux
        onClicked: {
            if (root.visibility === Window.FullScreen) {
                // Exit fullscreen
                root.showNormal();
            } else {
                // Enter fullscreen with a more explicit method
                root.showFullScreen();
            }
        }
        
        // Add tooltip for clarity
        ToolTip.visible: hovered
        ToolTip.text: root.visibility === Window.FullScreen ? 
                      qsTr("Exit Fullscreen") : qsTr("Enter Fullscreen")
        ToolTip.delay: 500
    }

    // Settings button (bottom left)
    Button {
        id: settingsButton
        width: 48
        height: 48
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 8
        opacity: 0.8 // Increased opacity for better visibility
        
        // Add a background for better visibility
        background: Rectangle {
            color: "#444444"
            radius: 5
            border.color: "#666666"
            border.width: 1
        }

        contentItem: Text {
            text: qsTr("⚙")
            color: "white"
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        onClicked: {
            drawer.open();
        }
        
        // Add tooltip for clarity
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Open Settings")
        ToolTip.delay: 500
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
                        SpeedReader.setBackgroundImagePath("");
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
                    checked: SpeedReader.metric
                    onCheckedChanged: {
                        SpeedReader.setMetric(checked);
                    }
                }
            }

            // Digital display switch
            RowLayout {
                width: parent.width - 20

                Image {
                    source: "file:assets/numeric.svg"
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
                    checked: SpeedReader.showDigital
                    onCheckedChanged: {
                        SpeedReader.setShowDigital(checked);
                    }
                }
            }

            // Analog display switch
            RowLayout {
                width: parent.width - 20

                Image {
                    source: "file:assets/wiper.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Replace MultiEffect with a simple colored Rectangle
                    Rectangle {
                        anchors.fill: parent
                        color: "#F44336" // Red color
                        opacity: 0.5
                    }
                }

                Text {
                    text: qsTr("Analog Display")
                    Layout.fillWidth: true
                }

                Switch {
                    checked: SpeedReader.showAnalog
                    onCheckedChanged: {
                        SpeedReader.setShowAnalog(checked);
                    }
                }
            }

            // Max Speed setting (only visible when analog is enabled)
            RowLayout {
                width: parent.width - 20
                visible: SpeedReader.showAnalog

                Image {
                    source: "file:assets/max-speed.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Replace MultiEffect with a simple Rectangle overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "#F44336" // Red color
                        opacity: 0.5
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
                    value: SpeedReader.maxSpeed
                    onValueModified: {
                        SpeedReader.setMaxSpeed(value);
                    }
                }

                Text {
                    text: SpeedReader.metric ? "km/h" : "MPH"
                    font.bold: true
                }
            }

            // Top speed indicator switch
            RowLayout {
                width: parent.width - 20

                Image {
                    source: "file:assets/car-cruise-control.svg"
                    width: 24
                    height: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Replace MultiEffect with a Rectangle overlay
                    Rectangle {
                        anchors.fill: parent
                        color: "#4CAF50" // Green color
                        opacity: 0.5
                    }
                }

                Text {
                    text: qsTr("Show Top Speed")
                    Layout.fillWidth: true
                }

                Switch {
                    checked: SpeedReader.showTopSpeed
                    onCheckedChanged: {
                        SpeedReader.setShowTopSpeed(checked);
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
                        highlighted: !SpeedReader.gpsActive

                        onClicked: {
                            SpeedReader.startDemo();
                            drawer.close(); // Close drawer after selection
                        }
                    }

                    Button {
                        id: gpsModeButton
                        text: qsTr("GPS Mode")
                        Layout.fillWidth: true
                        highlighted: SpeedReader.gpsActive

                        onClicked: {
                            SpeedReader.startLocationUpdates();
                            drawer.close(); // Close drawer after selection
                        }
                    }
                }

                // GPS status indicator
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    color: SpeedReader.gpsActive ? "#4CAF50" : "#D32F2F"
                    radius: 4

                    Text {
                        id: gpsStatusText
                        anchors.centerIn: parent
                        text: SpeedReader.getGpsStatus()
                        color: "white"
                        font.pixelSize: 12
                    }

                    // Update the status text when the GPS state changes
                    Connections {
                        target: SpeedReader
                        function onGpsActiveChanged() {
                            gpsStatusText.text = SpeedReader.getGpsStatus();
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
                    source: "file:assets/icon.svg"
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
        id: mainMouseArea
        anchors.fill: parent
        z: -1  // Set to be behind UI controls so clicks reach them first
        
        // Add this to ensure buttons are clickable
        onPressed: mouse.accepted = !settingsButton.contains(Qt.point(mouseX, mouseY)) && 
                                   !fullscreenButton.contains(Qt.point(mouseX, mouseY)) && 
                                   !quickControlsRow.contains(Qt.point(mouseX, mouseY))
        
        onClicked: {
            // Only handle clicks in empty space (not on buttons)
            SpeedReader.resetTopSpeed();
        }
    }

    // Background image file dialog
    FileDialog {
        id: backgroundDialog
        title: qsTr("Choose a background image")
        nameFilters: [qsTr("Image files") + " (*.png *.jpg *.jpeg)"]
        onAccepted: {
            SpeedReader.setBackgroundImagePath(selectedFile);
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
                source: "file:assets/icon.svg"
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
        target: SpeedReader

        function onMetricChanged() {
            // Need to force update display text when units change
            // This ensures the digital display keeps updating after switching units
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
            // Always update the display text when speed changes
            // This ensures the digital display keeps updating even after switching units
            updateDisplayText();
        }

        function onTopSpeedChanged() {
        // Already handled by bindings
        }

        function onMaxSpeedChanged() {
            // The gauge scale might need updating
            // This forces a layout refresh for the tick marks
            analogGauge.visible = false;
            analogGauge.visible = SpeedReader.showAnalog;
        }

        // Force display update when any relevant setting changes
        function onDisplayTextChanged() {
        // Already handled by binding to text property
        }
    }

    // Helper function to ensure display updates
    function updateDisplayText() {
        // This forces a refresh of the display text
        digitalGauge.text = SpeedReader.displayText;
    }

    Component.onCompleted: {
        // Initialize the app state - start in demo mode
        SpeedReader.startDemo();
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
                source: "file:assets/numeric.svg"
                width: 24
                height: 24
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit
            }

            // Highlight if digital display is active
            background: Rectangle {
                radius: width / 2
                color: SpeedReader.showDigital ? "#3F51B5" : "#444444"
                opacity: 0.7
            }

            onClicked: {
                SpeedReader.setShowDigital(!SpeedReader.showDigital);
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
                source: "file:assets/wiper.svg"
                width: 24
                height: 24
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit

                // Replace MultiEffect with a simple colored Rectangle
                Rectangle {
                    anchors.fill: parent
                    color: "#F44336" // Red color
                    opacity: 0.5
                }
            }

            // Highlight if analog display is active
            background: Rectangle {
                radius: width / 2
                color: SpeedReader.showAnalog ? "#3F51B5" : "#444444"
                opacity: 0.7
            }

            onClicked: {
                SpeedReader.setShowAnalog(!SpeedReader.showAnalog);
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
                source: "file:assets/car-cruise-control.svg"
                width: 24
                height: 24
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit

                // Replace MultiEffect with a Rectangle overlay
                Rectangle {
                    anchors.fill: parent
                    color: "#4CAF50" // Green color
                    opacity: 0.5
                }
            }

            // Highlight if top speed display is active
            background: Rectangle {
                radius: width / 2
                color: SpeedReader.showTopSpeed ? "#3F51B5" : "#444444"
                opacity: 0.7
            }

            onClicked: {
                SpeedReader.setShowTopSpeed(!SpeedReader.showTopSpeed);
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
                SpeedReader.resetTopSpeed();
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
                text: SpeedReader.metric ? qsTr("km/h") : qsTr("MPH")
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
                SpeedReader.setMetric(!SpeedReader.metric);
            }

            // Tooltip
            ToolTip.visible: hovered
            ToolTip.text: qsTr("Toggle Units: ") + (SpeedReader.metric ? "km/h" : "MPH")
            ToolTip.delay: 1000
        }
    }
}
