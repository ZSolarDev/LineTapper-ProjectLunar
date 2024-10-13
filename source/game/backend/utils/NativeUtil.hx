package game.backend.utils;

#if cpp
import game.native.NativeFunctions;
import cpp.Int32;
#else
#if hl
import hlwnative.HLNativeWindow;
import hlwnative.HLExternal;
import hlwnative.HLApplicationStatus;
import hlwnative.HLDriveStatus;
#end
#end

/**
 * Native helper class for Windows.
 * - CoreCat :]
 * 
 * This is meant to be used indirectly to call windows native functions.
 * It is indirect in order to further to help with Cross-Platform support.
 * - ZSolarDev :D
 */
 #if cpp
class NativeUtil {
    /**
     * Returns current used memory in bytes for current platform.
     * If the platform is unsupported, it will return Garbage Collector memory.
     */
    public static function getUsedMemory():Float {
        #if windows
        return NativeFunctions.getCurrentUsedMemory();
        #else
        return openfl.system.System.totalMemory;
        #end
    }

    /**
     * Returns current free drive size in bytes.
     */
    public static function getCurrentDriveSize():Float {
        #if windows
        return NativeFunctions.getCurrentDriveSize();
        #else
        return 1.0;
        #end
    }

    /**
     * Returns current process CPU Usage.
     */
    public static function getCurrentCPUUsage():Float {
        #if windows
        return NativeFunctions.getCurrentCPUUsage();
        #else
        return 1.0;
        #end
    }



    /**
     * Creates a Toast Notification.
     * @param title Toast title.
     * @param body Toast body / description.
     * @param res Icon res
     */
    public static function toast(title:String = "", body:String = "", res:Int = 0):Int
    {
        #if windows
        return NativeFunctions.toast(title, body, res);
        #else
        return 1;
        #end
    }

    /**
     * Allows the user to set the window title bar color. (WINDOWS 11 ONLY)
     * @param title Window title, do something like `lime.app.Application.current.window.title`.
     * @param targetColor This is a hex code that is in 0x00BBGGRR. Not RGB, but BGR.
     */
    public static function setWindowColor(title:String, #if cpp targetColor:Int32 #else targetColor:Int #end) {
        #if windows
        NativeFunctions.setWindowColor(title, targetColor);
        #else
        trace("Unsupported platform! The window bars color remains unchanged.");
        #end
    }

    /**
     * Allows the user to switch between Dark Mode or Light Mode in the window.
     * @param title Window title, do something like `lime.app.Application.current.window.title`.
     * @param enable Whether to enable / disable Dark Mode.
     */
    public static function setWindowDarkMode(title:String, enable:Bool) {
        #if windows
        NativeFunctions.setWindowDarkMode(title, enable);
        #else
        trace("Unsupported platform! Dark mode property remains unchanged.");
        #end
    }

    /**
	 * Makes the process DPI Aware.
	 */
    public static function setDPIAware() {
        #if windows
        NativeFunctions.setDPIAware();
        #else
        trace("Unsupported platform! DPI Aware mode remains unchanged.");
        #end
    }
}
#else
#if hl
class NativeUtil {
    /**
     * Returns current used memory for current platform.
     * If the platform is unsupported, it will return Garbage Collector memory.
     */
    public static function getUsedMemory():Float {
        #if windows
        return Common.float(HLApplicationStatus.getMemoryUsage());
        #else
        return openfl.system.System.totalMemory;
        #end
    }

    /**
     * Returns current free drive size in bytes.
     */
    public static function getCurrentDriveSize():Float {
        #if windows
        return HLDriveStatus.getFreeDriveSize()*1000000000; // oml why is this in bytes??
        #else
        return 1.0;
        #end
    }

    /**
     * Returns current process CPU Usage.
     */
    public static function getCurrentCPUUsage():Float {
        #if windows
        return HLApplicationStatus.getCPULoad();
        #else
        return 1.0;
        #end
    }

    /**
     * Creates a Toast Notification.
     * Currently non-functional on HashLink builds.
     * @param title Toast title.
     * @param body Toast body / description.
     * @param res Useless on HashLink, kept so things meant to be compiled with cpp running on hl won't break.
     */
    public static function toast(title:String = "", body:String = "", res:Int = 0):Int
    {
        #if windows
        return Common.intFromBool(HLExternal.toastNotification(title, body), true);
        #else
        return 1;
        #end
    }

    /**
     * Allows the user to set the window title bar color. (WINDOWS 11 ONLY)
     * @param title Useless on HashLink, kept so things meant to be compiled with cpp running on hl won't break.
     * @param targetColor This is a hex code in RGB.
     */
    public static function setWindowColor(title:String, targetColor:Int) {
        #if windows
        HLNativeWindow.setWindowTitlebarColor(targetColor);
        #else
        trace("Unsupported platform! The window bars color remains unchanged.");
        #end
    }

    /**
     * Allows the user to switch between Dark Mode or Light Mode in the window.
     * @param title Useless on HashLink, kept so things meant to be compiled with cpp running on hl won't break.
     * @param enable Whether to enable / disable Dark Mode.
     */
    public static function setWindowDarkMode(title:String, enable:Bool) {
        #if windows
        HLNativeWindow.setWindowDarkMode(enable);
        #else
        trace("Unsupported platform! Dark mode property remains unchanged.");
        #end
    }

    /**
	 * Currently not supported for HashLink.
	 */
    public static function setDPIAware() {
        trace("DPI Awareness is unsupported for HashLink builds! DPI Aware mode remains unchanged.");
    }
}
#else
class NativeUtil {
    /**
     * Returns current used memory for current platform.
     * Your build type is unsupported if your looking at this in vscode btw.
     */
    public static function getUsedMemory():Float {
        return openfl.system.System.totalMemory;
    }

    /**
     * Returns current free drive size in bytes.
     * Your build type is unsupported if your looking at this in vscode btw.
     */
    public static function getCurrentDriveSize():Float {
        return 1.0;
    }

    /**
     * Returns current process CPU Usage.
     * Your build type is unsupported if your looking at this in vscode btw.
     */
    public static function getCurrentCPUUsage():Float {
        return 1.0;
    }

    /**
     * Creates a Toast Notification.
     * Your build type is unsupported if your looking at this in vscode btw.
     */
    public static function toast(title:String = "", body:String = "", res:Int = 0):Int
    {
        return 1;
    }

    /**
     * Allows the user to set the window title bar color. (WINDOWS 11 ONLY)
     * Your build type is unsupported if your looking at this in vscode btw.
     */
    public static function setWindowColor(title:String, targetColor:Int) {
        trace("Unsupported build type! The window bars color remains unchanged.");
    }

    /**
     * Allows the user to switch between Dark Mode or Light Mode in the window.
     * Your build type is unsupported if your looking at this in vscode btw.
     */
    public static function setWindowDarkMode(title:String, enable:Bool) {
        trace("Unsupported build type! Dark mode property remains unchanged.");
    }

    /**
     * Makes the process DPI Aware.
	 * Your build type is unsupported if your looking at this in vscode btw.
	 */
    public static function setDPIAware() {
        trace("Unsupported build type! DPI Aware mode remains unchanged.");
    }
}
#end
#end