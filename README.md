# Faseer
#####A debug tool to output the log to terminal and hide it in console.

In Farseer, the log is divided into five levels, Fatal, Error, Warning, Log and Minor. It will be outputted to the terminal or central device with different colors according to its own level. The log can be acquired wirelessly through Bluetooth in real-time. Farseer can only display the selected part filtered by level, file, method name or line number. Farseer can use central device to access the launching target application device, view the sandbox directory, get the target file in the sandbox. Central device will keep all other device’s logs, for compare and analyze between different time periods.

####Advantages:  
1. Get realtime log from the current running app, get running status and analyze anomalies.
2. Wirelessly transfer through Bluetooth, get the log and file in the sandbox without cable.
3. Save log history, for comparison and analyzing.
4. Can easily be deployed to your own project, only need to replace the macro definition.
5. Can only show the selected part with filter.
6. Support MacOS and iOS.

####Note:  
If Handoff is turned on in different devices under the same Apple ID, Central device may occur some linking problem while trying to connect to launching target application device. This may caused by a bug in Apple Bluetooth Framework, to solve this problem for now, you can use different Apple ID or turn off handoff.

####Integrate Farseer into your project:  
Import SLFarseer.xcodeproj, choose your own project xxx.xcodeproj, Choose General, Expand Embedded Binaries, Click “+”, choose the Framework. (Farseer_iOS.framework for Cocoa touch project, Farseer_Mac for cocoa project)  
There will be a detailed method usage in the header file of the framework.

####Functions:  
1. Output the log to terminal to keep the console clean and tidy, and display log in different colors according to log levels (Currently support Mac App) <br /> Usage：<br /> In the terminal:<br /> <code>tail -f -n +0 /Users/{UserName}/Library/Application\ Support/{bundleID}/Farseer/Log/current.log  </code>
2. Call openBLEDebug() to start remote debugging, and use closeBLEDebug() to turn off.
3. Use FSFatal(), FSError(), FSWarning(), FSLog(), FSMinor() to output Log to Terminal or remote device.

Try it yourself, Farseer will give you a different debugging experience.

#####License

Farseer is released under the MIT license. See LICENSE.md.

#####More Info

Have any questions? Please open an issue!