import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var brightness: 0
    property QtObject colors: null

    // Queued step applied to the next fresh reading, so presses never use a stale base.
    property int pendingDelta: 0
    property bool pendingAdjust: false

    Component.onCompleted: {
        getBrightness();
    }

    Process {
        id: brightnessProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim();
                if (output) {
                    var current = parseInt(output);
                    if (isNaN(current)) {
                        root.flushPendingFallback();
                    } else {
                        maxBrightnessProcess.exec({
                            command: ["brightnessctl", "max"]
                        });
                        brightnessProcess.currentValue = current;
                    }
                } else {
                    root.flushPendingFallback();
                }
            }
        }
        property int currentValue: 0
    }

    Process {
        id: maxBrightnessProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var maxOutput = this.text.trim();
                if (maxOutput) {
                    var max = parseInt(maxOutput);
                    if (!isNaN(max) && max > 0) {
                        var fresh = Math.round((brightnessProcess.currentValue / max) * 100);
                        if (isNaN(fresh)) {
                            root.flushPendingFallback();
                        } else if (root.pendingAdjust) {
                            var adjusted = Math.max(0, Math.min(100, fresh + root.pendingDelta));
                            root.pendingAdjust = false;
                            root.pendingDelta = 0;
                            if (adjusted === fresh) {
                                root.brightness = fresh;
                            } else {
                                root.setBrightness(adjusted);
                            }
                        } else {
                            root.brightness = fresh;
                        }
                    } else {
                        root.flushPendingFallback();
                    }
                } else {
                    root.flushPendingFallback();
                }
            }
        }
    }

    function getBrightness() {
        if (root.pendingAdjust) {
            return brightness;
        }
        return refreshBrightness();
    }

    function refreshBrightness() {
        brightnessProcess.exec({
            command: ["brightnessctl", "get"]
        });
        return brightness;
    }

    function setBrightness(value) {
        var clampedValue = Math.max(0, Math.min(100, value));
        brightness = clampedValue;
        Quickshell.execDetached({
            command: ["brightnessctl", "set", clampedValue.toString() + "%"]
        });
    }

    // On re-read failure, apply the queued step to the cached value.
    function flushPendingFallback() {
        if (!pendingAdjust) {
            return;
        }
        var fallback = Math.max(0, Math.min(100, brightness + pendingDelta));
        pendingAdjust = false;
        pendingDelta = 0;
        if (fallback !== brightness) {
            setBrightness(fallback);
        }
    }

    function increase(step) {
        var stepValue = step || 5;
        if (pendingAdjust) {
            pendingDelta += stepValue;
        } else {
            pendingAdjust = true;
            pendingDelta = stepValue;
            refreshBrightness();
        }
    }

    function decrease(step) {
        var stepValue = step || 5;
        if (pendingAdjust) {
            pendingDelta -= stepValue;
        } else {
            pendingAdjust = true;
            pendingDelta = -stepValue;
            refreshBrightness();
        }
    }
}
