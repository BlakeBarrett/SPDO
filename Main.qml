import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs 6.4
import QtQuick.Controls.Material 2.15
import com.blakebarrett.spdo 2.0

Window {
    id: root
    width: 1200
    height: 600
    visible: true
    title: SpeedReader.appName
    color: "#000000"

    // Handle close events to prevent accidental closing
    onClosing: function (close) {
        if (!confirmCloseDialog.visible) {
            close.accepted = false
            confirmCloseDialog.open()
        }
    }

    // Animation for initial loading
    SequentialAnimation {
        running: true
        ScaleAnimator {
            target: speedNeedle
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

    // Classic car speedometer - styled after 1977 GMC Sprint dashboard
    Item {
        id: classicSpeedometer
        anchors.fill: parent
        visible: SpeedReader.showAnalog

        // Gauge backlight/glow effect
        Rectangle {
            id: gaugeBacklight
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            color: "#000000"
            opacity: 0.2
            radius: 8

            // Subtle backlight effect
            Rectangle {
                anchors.fill: parent
                color: "#000000"
                radius: 8

                // Subtle blue gradient for backlight - classic 70s dashboard look
                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: "#000000"
                        }
                        GradientStop {
                            position: 0.5
                            color: "#101825"
                        }
                        GradientStop {
                            position: 1.0
                            color: "#000000"
                        }
                    }

                    // Add a subtle animation to the glow
                    SequentialAnimation {
                        running: true
                        loops: Animation.Infinite
                        NumberAnimation {
                            target: gaugeBacklight
                            property: "opacity"
                            from: 0.9
                            to: 1.0
                            duration: 3000
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: gaugeBacklight
                            property: "opacity"
                            from: 1.0
                            to: 0.9
                            duration: 3000
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }

            // Main speedometer scale background - long horizontal design
            Rectangle {
                id: scaleBackground
                anchors.centerIn: parent
                width: parent.width * 0.95
                height: parent.height * 0.8
                color: "#000000"
                opacity: 0.8
                radius: 8

                // Speed markings container
                Item {
                    id: speedScale
                    anchors.fill: parent
                    // anchors.topMargin: parent.height * 0.1
                    // anchors.bottomMargin: parent.height * 0.35

                    // Generate the speed markings horizontally instead of in a semi-circle
                    Repeater {
                        model: 11 // 0-100 mph in steps of 10

                        Item {
                            property int speedValue: index * 10
                            property real position: index / 10

                            // Position along the horizontal gauge
                            x: parent.width * 0.05 + (parent.width * 0.9 * position)
                            y: 0
                            width: 2
                            height: parent.height

                            // Speed value text - MPH
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: 0
                                text: speedValue
                                color: "white"
                                font.pixelSize: 18
                                font.bold: true
                            }

                            // Second km/h scale below (in blue/teal like vintage dash)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: parent.height * 0.6
                                text: Math.round(
                                          speedValue * 1.60934) // Convert mph to km/h
                                color: "#5CCFE6" // Light blue/teal color for km/h
                                font.pixelSize: 14
                            }

                            // Main tick mark
                            Rectangle {
                                width: 2
                                height: parent.height * 0.3
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: parent.height * 0.25
                                color: "white"
                            }
                        }
                    }

                    // Minor tick marks between the major ones
                    Repeater {
                        model: 100 // 0-100 mph in steps of 1

                        Rectangle {
                            property int speedValue: index
                            property real position: index / 100
                            visible: index % 10 !== 0
                                     && index % 5 === 0 // Only show at 5, 15, 25, etc.

                            // Position along the horizontal gauge
                            x: parent.width * 0.05 + (parent.width * 0.9 * position)
                            y: parent.height * 0.25
                            width: 1
                            height: parent.height * 0.15
                            color: "white"
                        }
                    }

                    // Smallest tick marks
                    Repeater {
                        model: 100 // 0-100 mph in steps of 1

                        Rectangle {
                            property int speedValue: index
                            property real position: index / 100
                            visible: index % 5 !== 0 // Show at 1,2,3,4, 6,7,8,9, etc.

                            // Position along the horizontal gauge
                            x: parent.width * 0.05 + (parent.width * 0.9 * position)
                            y: parent.height * 0.25
                            width: 1
                            height: parent.height * 0.1
                            color: "white"
                            opacity: 0.7
                        }
                    }
                }
            }
        }

        // Needle pivot point (the round center where the needle rotates)
        Rectangle {
            id: needlePivot
            width: 20
            height: 20
            radius: 10
            color: "#333333"
            border.color: "#888888"
            border.width: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.15
            anchors.horizontalCenter: parent.horizontalCenter
            z: 10 // Make sure it's above the needle
        }

        // Speed needle (colored red like in the image)
        Item {
            id: speedNeedle
            anchors.bottom: needlePivot.verticalCenter
            anchors.horizontalCenter: needlePivot.horizontalCenter
            width: 4
            height: classicSpeedometer.height
            transformOrigin: Item.Bottom

            // Use speed to calculate position on horizontal scale
            // 0 MPH = -90 degrees, 100 MPH = +90 degrees
            rotation: -90 + ((SpeedReader.speed / SpeedReader.maxSpeed) * 180)

            // Add smooth animation to needle movement
            Behavior on rotation {
                NumberAnimation {
                    duration: 100 // 1/10th of a second
                    easing.type: Easing.Linear
                }
            }

            Rectangle {
                id: needleBody
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.height
                color: "#F44336" // Red color as in the image
            }

            // Needle arrow point
            Canvas {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                width: 12
                height: 12

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.fillStyle = "#F44336"
                    ctx.beginPath()
                    ctx.moveTo(width / 2, 0)
                    ctx.lineTo(width, height)
                    ctx.lineTo(0, height)
                    ctx.closePath()
                    ctx.fill()
                }
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
        opacity: 0.8

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
            drawer.open()
        }

        // Add tooltip for clarity
        ToolTip {
            visible: parent.hovered
            text: qsTr("Open Settings")
            delay: 500
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
        opacity: 0.8

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

        onClicked: {
            if (root.visibility === Window.FullScreen) {
                // Exit fullscreen
                root.showNormal()
            } else {
                // Enter fullscreen
                root.showFullScreen()
            }
        }

        // Add tooltip for clarity
        ToolTip {
            visible: parent.hovered
            text: root.visibility === Window.FullScreen ? qsTr("Exit Fullscreen") : qsTr(
                                                              "Enter Fullscreen")
            delay: 500
        }
    }

    // Settings drawer
    Drawer {
        id: drawer
        width: 300
        height: parent.height
        edge: Qt.LeftEdge

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            anchors.margins: 10

            Text {
                text: qsTr("Settings")
                font.pixelSize: 24
                font.bold: true
            }

            Rectangle {
                Layout.preferredWidth: parent.width - 20
                Layout.preferredHeight: 1
                color: "#CCCCCC"
            }

            // Background image chooser
            RowLayout {
                Layout.preferredWidth: parent.width - 20

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
                        backgroundDialog.open()
                    }
                }

                Button {
                    text: qsTr("Choose Background")
                    Layout.fillWidth: true
                    onClicked: {
                        backgroundDialog.open()
                    }
                }

                Button {
                    text: qsTr("Clear")
                    onClicked: {
                        SpeedReader.setBackgroundImagePath("")
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: parent.width - 20
                Layout.preferredHeight: 1
                color: "#CCCCCC"
            }

            // Units switch
            RowLayout {
                Layout.preferredWidth: parent.width - 20
                Text {
                    text: qsTr("Units: MPH | km/h")
                    font.bold: true
                    Layout.fillWidth: true
                }
                Switch {
                    checked: SpeedReader.metric
                    onCheckedChanged: {
                        SpeedReader.setMetric(checked)
                    }
                }
            }

            // Digital display switch
            RowLayout {
                Layout.preferredWidth: parent.width - 20

                Image {
                    source: "file:assets/numeric.svg"
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
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
                        SpeedReader.setShowDigital(checked)
                    }
                }
            }

            // Analog display switch
            RowLayout {
                Layout.preferredWidth: parent.width - 20

                Image {
                    source: "file:assets/wiper.svg"
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Simple colored Rectangle overlay
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
                        SpeedReader.setShowAnalog(checked)
                    }
                }
            }

            // Max Speed setting
            RowLayout {
                Layout.preferredWidth: parent.width - 20
                visible: SpeedReader.showAnalog

                Image {
                    source: "file:assets/max-speed.svg"
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Simple Rectangle overlay
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
                        SpeedReader.setMaxSpeed(value)
                    }
                }

                Text {
                    text: SpeedReader.metric ? "km/h" : "MPH"
                    font.bold: true
                }
            }

            // Top speed indicator switch
            RowLayout {
                Layout.preferredWidth: parent.width - 20

                Image {
                    source: "file:assets/car-cruise-control.svg"
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 24
                    sourceSize.height: 24

                    // Rectangle overlay
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
                        SpeedReader.setShowTopSpeed(checked)
                    }
                }
            }

            Item {
                Layout.preferredHeight: 20
            } // spacer

            // Mode selection
            Rectangle {
                Layout.preferredWidth: parent.width - 20
                Layout.preferredHeight: 1
                color: "#CCCCCC"
            }

            ColumnLayout {
                Layout.preferredWidth: parent.width - 20
                spacing: 8

                RowLayout {
                    Layout.preferredWidth: parent.width

                    Button {
                        id: demoModeButton
                        text: qsTr("Demo Mode")
                        Layout.fillWidth: true
                        highlighted: !SpeedReader.gpsActive

                        onClicked: {
                            SpeedReader.startDemo()
                            drawer.close() // Close drawer after selection
                        }
                    }

                    Button {
                        id: gpsModeButton
                        text: qsTr("GPS Mode")
                        Layout.fillWidth: true
                        highlighted: SpeedReader.gpsActive

                        onClicked: {
                            SpeedReader.startLocationUpdates()
                            drawer.close() // Close drawer after selection
                        }
                    }
                }
            }

            // GPS status indicator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
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
                        gpsStatusText.text = SpeedReader.getGpsStatus()
                    }
                }
            }

            // About section
            Rectangle {
                Layout.preferredWidth: parent.width - 20
                Layout.preferredHeight: 1
                color: "#CCCCCC"
            }

            RowLayout {
                Layout.preferredWidth: parent.width - 20

                Image {
                    source: "file:assets/icon.svg"
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    Layout.alignment: Qt.AlignVCenter
                    sourceSize.width: 48
                    sourceSize.height: 48
                }

                Button {
                    text: qsTr("About %1").arg(SpeedReader.appName)
                    Layout.fillWidth: true
                    onClicked: {
                        aboutDialog.open()
                    }
                }
            }
        }
    }

    // Reset top speed when tapping on screen
    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        z: -1 // Set to be behind UI controls so clicks reach buttons first

        onClicked: {
            // Only handle clicks in empty space (not on buttons)
            // First check if any control is under the mouse
            var mousePoint = Qt.point(mouseX, mouseY)
            if (!settingsButton.contains(settingsButton.mapFromItem(mainMouseArea, mousePoint)) &&
                !fullscreenButton.contains(fullscreenButton.mapFromItem(mainMouseArea, mousePoint)) &&
                !quickControlsRow.contains(quickControlsRow.mapFromItem(mainMouseArea, mousePoint))) {
                
                // No controls under the mouse, so reset top speed
                SpeedReader.resetTopSpeed()
            }
        }
    }

    // Background image file dialog
    FileDialog {
        id: backgroundDialog
        title: qsTr("Choose a background image")
        nameFilters: [qsTr("Image files") + " (*.png *.jpg *.jpeg)"]
        onAccepted: {
            SpeedReader.setBackgroundImagePath(selectedFile)
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
            Qt.quit()
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
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignHCenter
                sourceSize.width: 64
                sourceSize.height: 64
            }

            Text {
                text: qsTr("%1 v%2").arg(SpeedReader.appName).arg(
                          SpeedReader.appVersion)
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: qsTr("It's a speedometer.")
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    // Indicator Light dialog
    Dialog {
        id: indicatorDialog
        property string message: ""
        standardButtons: Dialog.Ok
        anchors.centerIn: Overlay.overlay
        width: Math.min(root.width * 0.7, 400)

        Text {
            width: parent.width
            text: indicatorDialog.message
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Quick control buttons - moved to bottom center for better access
    Row {
        id: quickControlsRow
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
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
                SpeedReader.setShowDigital(!SpeedReader.showDigital)
            }

            ToolTip {
                visible: parent.hovered
                text: qsTr("Toggle Digital Display")
                delay: 1000
            }
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
                SpeedReader.setMetric(!SpeedReader.metric)
            }

            ToolTip {
                visible: parent.hovered
                text: qsTr("Toggle Units: ") + (SpeedReader.metric ? "km/h" : "MPH")
                delay: 1000
            }
        }

        // Reset Top Speed
        RoundButton {
            id: resetTopSpeedButton
            width: 40
            height: 40

            // Show an reset icon
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
                SpeedReader.resetTopSpeed()
            }

            ToolTip {
                visible: parent.hovered
                text: qsTr("Reset Top Speed")
                delay: 1000
            }
        }
    }

    // Helper function to ensure display updates
    function updateDisplayText() {
        // This forces a refresh of the display text
        digitalGauge.text = SpeedReader.displayText
    }

    // Connections to ensure UI stays in sync with SpeedReader state
    Connections {
        target: SpeedReader

        function onMetricChanged() {
            // Need to force update display text when units change
            updateDisplayText()
        }

        function onSpeedChanged() {
            // Always update the display text when speed changes
            updateDisplayText()
        }

        function onMaxSpeedChanged() {
            // The gauge scale might need updating
            // Force a refresh of the analog gauge
            classicSpeedometer.visible = false
            classicSpeedometer.visible = SpeedReader.showAnalog
        }
    }

    Component.onCompleted: {
        // Initialize the app state - start in demo mode
        SpeedReader.startDemo()
    }
}
