function displayName(value, fallback) {
  return value !== null && value !== undefined && value !== ""
    ? value
    : fallback;
}

function getWindowIcon(windowIcons, key) {
  if (
    key &&
    windowIcons &&
    Object.prototype.hasOwnProperty.call(windowIcons, key)
  ) {
    return windowIcons[key];
  }

  return "󰘔";
}

function parseEnvironmentSnapshot(output) {
  const env = {
    NIRI_SOCKET: "",
    HYPRLAND_INSTANCE_SIGNATURE: "",
    XDG_CURRENT_DESKTOP: "",
    XDG_SESSION_DESKTOP: "",
  };

  const lines = (output || "").split("\n");
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (!line) continue;

    const separator = line.indexOf("=");
    if (separator === -1) continue;

    const key = line.slice(0, separator);
    env[key] = line.slice(separator + 1).trim();
  }

  return env;
}

function detectCompositor(env) {
  if (env.NIRI_SOCKET) return "niri";

  if (env.HYPRLAND_INSTANCE_SIGNATURE) return "hyprland";

  const desktops = (
    (env.XDG_CURRENT_DESKTOP || "") +
    " " +
    (env.XDG_SESSION_DESKTOP || "")
  ).toLowerCase();
  if (desktops.indexOf("niri") !== -1) return "niri";

  if (desktops.indexOf("hyprland") !== -1) return "hyprland";

  return "";
}

function shouldEnableHyprlandGlobalShortcuts(compositorName) {
  return compositorName === "hyprland";
}

function normalizeHyprland(
  outputName,
  workspaces,
  clients,
  monitors,
  ignoreClasses,
  windowIcons,
) {
  const requestedOutput = displayName(outputName, "");
  if (!requestedOutput) return [];

  const monitor = findHyprlandMonitor(outputName, monitors);
  const activeWorkspace = monitor ? monitor.activeWorkspace || {} : {};
  const activeWorkspaceId = activeWorkspace.id;
  const sortedWorkspaces = (workspaces || []).filter(function (workspace) {
    return workspace.monitor === requestedOutput;
  }).sort(function (a, b) {
    return a.id - b.id;
  });
  const ignored = ignoreClasses || [];
  const workspaceIds = {};
  const result = [];

  for (let i = 0; i < sortedWorkspaces.length; i++) {
    workspaceIds[sortedWorkspaces[i].id] = true;
  }

  for (let i = 0; i < sortedWorkspaces.length; i++) {
    const workspace = sortedWorkspaces[i];
    const icons = [];

    for (let j = 0; j < (clients || []).length; j++) {
      const client = clients[j];
      const workspaceRef = client.workspace || {};
      const className = client.class || client.initialClass || "";

      if (!Object.prototype.hasOwnProperty.call(workspaceIds, workspaceRef.id))
        continue;

      if (workspaceRef.id !== workspace.id) continue;

      if (ignored.indexOf(className) !== -1) continue;

      icons.push({
        icon: getWindowIcon(windowIcons, className),
        focused: client.focusHistoryID === 0,
      });
    }

    result.push({
      id: workspace.id,
      name: displayName(workspace.name, workspace.id.toString()),
      switchTarget: workspace.id.toString(),
      active: workspace.id === activeWorkspaceId,
      windowIcons: icons,
    });
  }

  return result;
}

function normalizeNiri(outputName, workspaces, windows, ignoreClasses, windowIcons) {
  const requestedOutput = displayName(outputName, "");
  if (!requestedOutput) return [];

  const sortedWorkspaces = (workspaces || []).filter(function (workspace) {
    return workspace.output === requestedOutput;
  }).sort(function (a, b) {
    return a.idx - b.idx;
  });
  const ignored = ignoreClasses || [];
  const workspaceIds = {};
  const result = [];

  for (let i = 0; i < sortedWorkspaces.length; i++) {
    workspaceIds[sortedWorkspaces[i].id] = true;
  }

  for (let i = 0; i < sortedWorkspaces.length; i++) {
    const workspace = sortedWorkspaces[i];
    const display = displayName(workspace.name, workspace.idx.toString());
    const icons = [];
    const workspaceWindows = [];

    for (let j = 0; j < (windows || []).length; j++) {
      const window = windows[j];
      const appId = window.app_id || window.appId || "";

      if (!Object.prototype.hasOwnProperty.call(workspaceIds, window.workspace_id))
        continue;

      if (window.workspace_id !== workspace.id) continue;

      if (ignored.indexOf(appId) !== -1) continue;

      workspaceWindows.push(window);
    }

    workspaceWindows.sort(function (a, b) {
      const aPos =
        a.layout && a.layout.pos_in_scrolling_layout
          ? a.layout.pos_in_scrolling_layout
          : [Number.MAX_SAFE_INTEGER, Number.MAX_SAFE_INTEGER];
      const bPos =
        b.layout && b.layout.pos_in_scrolling_layout
          ? b.layout.pos_in_scrolling_layout
          : [Number.MAX_SAFE_INTEGER, Number.MAX_SAFE_INTEGER];

      if (aPos[0] !== bPos[0]) return aPos[0] - bPos[0];

      return aPos[1] - bPos[1];
    });

    for (let j = 0; j < workspaceWindows.length; j++) {
      const window = workspaceWindows[j];
      const appId = window.app_id || window.appId || "";

      icons.push({
        icon: getWindowIcon(windowIcons, appId),
        focused:
          (workspace.active_window_id !== null &&
            workspace.active_window_id !== undefined &&
            window.id === workspace.active_window_id) ||
          !!window.is_focused,
      });
    }

    result.push({
      id: workspace.id,
      name: display,
      switchTarget: display,
      active: !!workspace.is_active,
      windowIcons: icons,
    });
  }

  return result;
}

function activeNiriWindowTitleForOutput(outputName, workspaces, windows) {
  const requestedOutput = displayName(outputName, "");
  if (!requestedOutput) return "";

  const windowsById = {};

  for (let i = 0; i < (windows || []).length; i++) {
    const window = windows[i];
    if (window.id === null || window.id === undefined) continue;

    windowsById[window.id] = window;
  }

  for (let i = 0; i < (workspaces || []).length; i++) {
    const workspace = workspaces[i];
    const output = displayName(workspace.output, "");

    if (output !== requestedOutput || !workspace.is_active) continue;

    const window = windowsById[workspace.active_window_id];
    return window
      ? displayName(window.title, displayName(window.app_id || window.appId, ""))
      : "";
  }

  return "";
}

function findHyprlandMonitor(outputName, monitors) {
  const requestedOutput = displayName(outputName, "");
  if (!requestedOutput) return null;

  for (let i = 0; i < (monitors || []).length; i++) {
    const monitor = monitors[i];
    if (monitor && monitor.name === requestedOutput) return monitor;
  }

  return null;
}

function activeHyprlandWindowTitleForOutput(outputName, monitors) {
  const monitor = findHyprlandMonitor(outputName, monitors);
  if (!monitor || !monitor.activeWorkspace) return "";

  return displayName(monitor.activeWorkspace.lastwindowtitle, "");
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    activeHyprlandWindowTitleForOutput,
    activeNiriWindowTitleForOutput,
    detectCompositor,
    normalizeHyprland,
    normalizeNiri,
    parseEnvironmentSnapshot,
    shouldEnableHyprlandGlobalShortcuts,
  };
}
