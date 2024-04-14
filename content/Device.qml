/*
 Copyright (c) 2024 glaumar <glaumar@geekgo.tech>

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import DeviceManager
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import VrpManager
import org.kde.kirigami as Kirigami

RowLayout {
    Item {
        id: device_info

        Layout.fillHeight: true
        Layout.bottomMargin: 10
        Layout.rightMargin: 5
        width: 310

        Kirigami.Card {
            anchors.fill: parent

            Connections {
                function onSpaceUsageChanged(total_space, free_space) {
                    if (!isNaN(total_space) && !isNaN(free_space) && free_space > 0 && free_space <= total_space) {
                        space_usage_text.text = ((total_space - free_space) / 1024 / 1024).toFixed(2) + " GB / " + (total_space / 1024 / 1024).toFixed(2) + " GB";
                        space_usage_bar.value = (total_space - free_space) / total_space;
                    } else {
                        space_usage_text.text = "0.00 GB / 0.00 GB";
                        space_usage_bar.value = 0;
                    }
                }

                function onDeviceNameChanged(name) {
                    device_name.text = name === "" ? qsTr("No device connected") : name;
                }

                function onDeviceIpChanged(ip) {
                    device_ip.text = ip;
                }

                function onBatteryLevelChanged(level) {
                    battery_level.text = level > 0 ? level + "%" : "0%";
                }

                function onOculusOsVersionChanged(version) {
                    if (version.length > 20)
                        oculus_os_version.text = version.substr(0, 17) + "...";
                    else
                        oculus_os_version.text = version;
                    oculus_os_version.visible = !(version === "");
                }

                function onOculusVersionChanged(version) {
                    oculus_version.text = version;
                    oculus_version.visible = !(version === "");
                }

                function onOculusRuntimeVersionChanged(version) {
                    oculus_runtime_version.text = version;
                    oculus_runtime_version.visible = !(version === "");
                }

                function onAndroidVersionChanged(version) {
                    android_version.text = version;
                    android_version.visible = version > 0;
                }

                function onAndroidSdkVersionChanged(version) {
                    android_sdk_version.text = version;
                    android_sdk_version.visible = version > 0;
                }

                target: app.deviceManager
            }

            contentItem: ColumnLayout {
                Layout.fillWidth: true

                Column {
                    spacing: 10
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    Label {
                        id: space_usage_text

                        width: parent.width
                        text: "0.00 GB / 0.00 GB"
                    }

                    ProgressBar {
                        id: space_usage_bar

                        width: parent.width
                        value: 0
                    }

                    ComboBox {
                        id: device_selector

                        width: parent.width
                        model: app.deviceManager.devicesList
                        onActivated: (index) => {
                            app.deviceManager.connectToDevice(textAt(index));
                        }
                    }

                }

                Kirigami.FormLayout {
                    id: device_info_layout

                    Layout.alignment: Qt.AlignBottom
                    Layout.fillWidth: true
                    visible: app.deviceManager.hasConnectedDevice

                    Label {
                        id: device_ip

                        Kirigami.FormData.label: qsTr("IP:")
                    }

                    Label {
                        id: battery_level

                        Kirigami.FormData.label: qsTr("Battery Level:")
                    }

                    Label {
                        id: android_version

                        Kirigami.FormData.label: qsTr("Android Version:")
                    }

                    Label {
                        id: android_sdk_version

                        Kirigami.FormData.label: qsTr("Android SDK Version:")
                    }

                    Label {
                        id: oculus_os_version

                        Kirigami.FormData.label: qsTr("OS Version:")
                        text: ""
                    }

                    Label {
                        id: oculus_version

                        Kirigami.FormData.label: qsTr("Oculus Version:")
                    }

                    Label {
                        id: oculus_runtime_version

                        Kirigami.FormData.label: qsTr("Oculus Runtime Version:")
                    }

                }

            }

            header: Label {
                id: device_name

                text: qsTr("No device connected")
                font.bold: true
                font.pointSize: Qt.application.font.pointSize * 2
            }

        }

    }

    GridView {
        id: apps_info

        Layout.fillHeight: true
        Layout.fillWidth: true
        snapMode: GridView.SnapToRow
        clip: true
        cellWidth: 310
        cellHeight: 220
        model: app.deviceManager.appListModel()

        ScrollBar.vertical: ScrollBar {
            visible: true
        }

        delegate: ApplicationDelegate {
            width: apps_info.cellWidth - 10
            height: apps_info.cellHeight - 10
            name: model.package_name
            thumbnailPath: {
                let path = app.vrp.getGameThumbnailPath(model.package_name);
                if (path === "")
                    return "qrc:/qt/qml/content/Image/matrix.png";
                else
                    return "file://" + path;
            }
            onUninstallButtonClicked: {
                let package_name = model.package_name;
                apps_info.model.remove(index);
                app.deviceManager.uninstallApkQml(package_name);
            }
        }

    }

}
