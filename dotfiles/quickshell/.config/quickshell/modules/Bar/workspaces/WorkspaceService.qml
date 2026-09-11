pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
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
    // Live updates are event-driven; these are slow fallbacks (overridden from config.qml).
    property int updateInterval: 5000
    property int activeUpdateInterval: 2000
    property bool unsupportedCompositorLogged: false

    property var cachedHyprlandWorkspaces: []
    property var cachedHyprlandClients: []
    property var cachedHyprlandMonitors: []
    property var cachedNiriWorkspaces: []
    property var cachedNiriWindows: []
    property int niriStreamFailures: 0

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

    // Focus deltas carry no arrays: patch caches in place, refresh on anything else.
    function niriStreamBackoffInterval() {
        if (root.niriStreamFailures >= 4)
            return 30000;
        if (root.niriStreamFailures === 3)
            return 15000;
        if (root.niriStreamFailures === 2)
            return 5000;
        return 2000;
    }

    function handleNiriEvent(line) {
        if (!line)
            return;
        try {
            var ev = JSON.parse(line);
            if (root.niriStreamFailures > 0) {
                root.niriStreamFailures = 0;
                niriStreamRestart.interval = 2000;
            }
            var payload = (ev && ev.Event) ? ev.Event : ev;
            if (!payload || typeof payload !== "object") {
                niriDebounce.restart();
                return;
            }
            if (payload.WorkspacesChanged && payload.WorkspacesChanged.workspaces) {
                root.cachedNiriWorkspaces = payload.WorkspacesChanged.workspaces;
                return;
            }
            if (payload.WindowsChanged && payload.WindowsChanged.windows) {
                root.cachedNiriWindows = payload.WindowsChanged.windows;
                return;
            }
            if (payload.WorkspaceActivated) {
                var activatedId = payload.WorkspaceActivated.id;
                var focused = payload.WorkspaceActivated.focused !== false;
                var workspaces = root.cachedNiriWorkspaces.slice();
                var targetOutput = "";
                var i = 0;
                for (i = 0; i < workspaces.length; i++) {
                    if (workspaces[i] && workspaces[i].id === activatedId) {
                        targetOutput = workspaces[i].output;
                        break;
                    }
                }
                for (i = 0; i < workspaces.length; i++) {
                    if (!workspaces[i])
                        continue;
                    if (workspaces[i].id === activatedId)
                        workspaces[i].is_active = focused;
                    else if (focused && targetOutput !== "" && workspaces[i].output === targetOutput)
                        workspaces[i].is_active = false;
                }
                root.cachedNiriWorkspaces = workspaces;
                return;
            }
            if (payload.WorkspaceActiveWindowChanged) {
                var wsId = payload.WorkspaceActiveWindowChanged.workspace_id;
                var activeWindowId = payload.WorkspaceActiveWindowChanged.active_window_id;
                var cached = root.cachedNiriWorkspaces.slice();
                for (var k = 0; k < cached.length; k++) {
                    if (cached[k] && cached[k].id === wsId)
                        cached[k].active_window_id = activeWindowId;
                }
                root.cachedNiriWorkspaces = cached;
                return;
            }
            if (payload.WindowFocusChanged) {
                var focusedId = payload.WindowFocusChanged.id;
                var windows = root.cachedNiriWindows.slice();
                for (var m = 0; m < windows.length; m++) {
                    if (windows[m])
                        windows[m].is_focused = (focusedId !== null && focusedId !== undefined && windows[m].id === focusedId);
                }
                root.cachedNiriWindows = windows;
                return;
            }
            if (payload.WindowOpenedOrChanged && payload.WindowOpenedOrChanged.window) {
                var changed = payload.WindowOpenedOrChanged.window;
                var current = root.cachedNiriWindows.slice();
                var replaced = false;
                for (var n = 0; n < current.length; n++) {
                    if (current[n] && changed && current[n].id === changed.id) {
                        current[n] = changed;
                        replaced = true;
                        break;
                    }
                }
                if (!replaced)
                    current.push(changed);
                root.cachedNiriWindows = current;
                return;
            }
            if (payload.WindowClosed) {
                var closedId = payload.WindowClosed.id;
                root.cachedNiriWindows = root.cachedNiriWindows.slice().filter(function (w) {
                    return !w || w.id !== closedId;
                });
                return;
            }
            niriDebounce.restart();
        } catch (e) {
            console.log("WorkspaceService niri event parse error:", e);
        }
    }

    // Socket events burst; coalesce into one refresh.
    function onHyprlandEvent() {
        if (root.compositorName !== "hyprland")
            return;
        hyprlandDebounce.restart();
    }

    Component.onCompleted: {
        const env = {
            "NIRI_SOCKET": Quickshell.env("NIRI_SOCKET"),
            "HYPRLAND_INSTANCE_SIGNATURE": Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
        };
        root.compositorName = WorkspaceHelpers.detectCompositor(env);

        if (!root.compositorName) {
            root.logUnsupportedCompositor();
            return;
        }

        root.refresh();
        root.refreshActive();
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval
        repeat: true
        running: root.compositorName.length > 0 && (root.compositorName !== "niri" || !niriEventStream.running)
        onTriggered: root.refresh()
    }

    Timer {
        id: activeWorkspaceTimer
        interval: root.activeUpdateInterval
        repeat: true
        running: root.compositorName.length > 0 && (root.compositorName !== "niri" || !niriEventStream.running)
        onTriggered: root.refreshActive()
    }

    Timer {
        id: hyprlandDebounce
        interval: 250
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: niriDebounce
        interval: 250
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: niriStreamRestart
        interval: 2000
        repeat: false
        onTriggered: {
            if (root.compositorName === "niri" && !niriEventStream.running)
                niriEventStream.running = true;
        }
    }

    Connections {
        target: root.compositorName === "hyprland" ? Hyprland : null
        function onRawEvent(event) {
            root.onHyprlandEvent();
        }
    }

    Process {
        id: niriEventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: root.compositorName === "niri"
        stdout: SplitParser {
            onRead: data => root.handleNiriEvent(data)
        }
        onExited: {
            if (root.compositorName !== "niri")
                return;
            root.niriStreamFailures += 1;
            var nextInterval = root.niriStreamBackoffInterval();
            if (root.niriStreamFailures === 1 || nextInterval !== niriStreamRestart.interval)
                console.log("WorkspaceService: niri event-stream exited, restarting in " + nextInterval + "ms");
            niriStreamRestart.interval = nextInterval;
            niriStreamRestart.restart();
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
