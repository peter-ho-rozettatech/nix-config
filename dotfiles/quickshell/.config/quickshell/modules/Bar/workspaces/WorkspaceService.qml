pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "workspaceHelpers.js" as WorkspaceHelpers

Item {
    id: root
    width: 0
    height: 0
    visible: false

    property string compositorName: ""
    property var ignoreClasses: []
    property var windowIcons: ({})
    property int updateInterval: 200
    property int activeUpdateInterval: 100
    property bool unsupportedCompositorLogged: false

    property var cachedHyprlandWorkspaces: []
    property var cachedHyprlandClients: []
    property var cachedHyprlandMonitors: []
    property var cachedNiriWorkspaces: []
    property var cachedNiriWindows: []

    function workspacesForOutput(outputName) {
        if (root.compositorName === "hyprland")
            return WorkspaceHelpers.normalizeHyprland(outputName, root.cachedHyprlandWorkspaces, root.cachedHyprlandClients, root.cachedHyprlandMonitors, root.ignoreClasses, root.windowIcons || ({}));

        if (root.compositorName === "niri")
            return WorkspaceHelpers.normalizeNiri(outputName, root.cachedNiriWorkspaces, root.cachedNiriWindows, root.ignoreClasses, root.windowIcons || ({}));

        return [];
    }

    function activeWindowTitleForOutput(outputName) {
        if (root.compositorName === "hyprland")
            return WorkspaceHelpers.activeHyprlandWindowTitleForOutput(outputName, root.cachedHyprlandMonitors);

        if (root.compositorName === "niri")
            return WorkspaceHelpers.activeNiriWindowTitleForOutput(outputName, root.cachedNiriWorkspaces, root.cachedNiriWindows);

        return "";
    }

    function logUnsupportedCompositor() {
        if (root.unsupportedCompositorLogged)
            return;

        root.unsupportedCompositorLogged = true;
        console.log("WorkspaceService: unsupported compositor");
    }

    function parseJson(label, output, onSuccess) {
        if (!output)
            return;

        try {
            onSuccess(JSON.parse(output));
        } catch (e) {
            console.log("WorkspaceService " + label + " parse error:", e);
        }
    }

    function refresh() {
        if (root.compositorName === "hyprland") {
            hyprlandWorkspacesProcess.exec({
                command: ["hyprctl", "workspaces", "-j"]
            });
            hyprlandClientsProcess.exec({
                command: ["hyprctl", "clients", "-j"]
            });
            hyprlandMonitorsProcess.exec({
                command: ["hyprctl", "monitors", "-j"]
            });
        } else if (root.compositorName === "niri") {
            niriWorkspacesProcess.exec({
                command: ["niri", "msg", "-j", "workspaces"]
            });
            niriWindowsProcess.exec({
                command: ["niri", "msg", "-j", "windows"]
            });
        }
    }

    function refreshActive() {
        if (root.compositorName === "hyprland") {
            hyprlandMonitorsProcess.exec({
                command: ["hyprctl", "monitors", "-j"]
            });
        } else if (root.compositorName === "niri") {
            niriWorkspacesProcess.exec({
                command: ["niri", "msg", "-j", "workspaces"]
            });
        }
    }

    function switchWorkspace(target) {
        if (!target)
            return;

        if (root.compositorName === "hyprland") {
            switchWorkspaceProcess.exec({
                command: ["hyprctl", "dispatch", "workspace", target]
            });
        } else if (root.compositorName === "niri") {
            switchWorkspaceProcess.exec({
                command: ["niri", "msg", "action", "focus-workspace", target]
            });
        }
    }

    Component.onCompleted: {
        detectCompositorProcess.exec({
            command: ["sh", "-lc", "env"]
        });
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval
        repeat: true
        running: root.compositorName.length > 0
        onTriggered: root.refresh()
    }

    Timer {
        id: activeWorkspaceTimer
        interval: root.activeUpdateInterval
        repeat: true
        running: root.compositorName.length > 0
        onTriggered: root.refreshActive()
    }

    Process {
        id: detectCompositorProcess
        stdout: StdioCollector {
            onStreamFinished: {
                const env = WorkspaceHelpers.parseEnvironmentSnapshot(this.text.trim());
                root.compositorName = WorkspaceHelpers.detectCompositor(env);

                if (!root.compositorName) {
                    root.logUnsupportedCompositor();
                    return;
                }

                root.refresh();
                root.refreshActive();
            }
        }
    }

    Process {
        id: hyprlandWorkspacesProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseJson("hyprland workspaces", this.text.trim(), function (data) {
                    root.cachedHyprlandWorkspaces = data;
                });
            }
        }
    }

    Process {
        id: hyprlandClientsProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseJson("hyprland clients", this.text.trim(), function (data) {
                    root.cachedHyprlandClients = data;
                });
            }
        }
    }

    Process {
        id: hyprlandMonitorsProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseJson("hyprland monitors", this.text.trim(), function (data) {
                    root.cachedHyprlandMonitors = data;
                });
            }
        }
    }

    Process {
        id: niriWorkspacesProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseJson("niri workspaces", this.text.trim(), function (data) {
                    root.cachedNiriWorkspaces = data;
                });
            }
        }
    }

    Process {
        id: niriWindowsProcess
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseJson("niri windows", this.text.trim(), function (data) {
                    root.cachedNiriWindows = data;
                });
            }
        }
    }

    Process {
        id: switchWorkspaceProcess
    }
}
