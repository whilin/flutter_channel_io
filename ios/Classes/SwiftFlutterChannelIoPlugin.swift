import Flutter
import UIKit
import ChannelIO

public class SwiftFlutterChannelIoPlugin: NSObject, FlutterPlugin , ChannelPluginDelegate{
    
    public static var eventChannel: FlutterEventChannel?
    public static var bagdeEvents: FlutterEventSink?
    public static var badgeCount : Int = 0;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let instance = SwiftFlutterChannelIoPlugin()
        
        let channel = FlutterMethodChannel(name: "GwonHyeok/flutter_channel_io", binaryMessenger: registrar.messenger())
        
        SwiftFlutterChannelIoPlugin.eventChannel = FlutterEventChannel(name: "GwonHyeok/flutter_channel_io_event", binaryMessenger: registrar.messenger())
        SwiftFlutterChannelIoPlugin.eventChannel!.setStreamHandler(StreamHandler())
        
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        ChannelIO.initialize(application)
        ChannelIO.delegate = self
        
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        ChannelIO.initPushToken(deviceToken: deviceToken)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if ChannelIO.isChannelPushNotification(userInfo) == true {
            ChannelIO.handlePushNotification(userInfo, completion: completionHandler)
        }
    }
    
    public func onBadgeChanged(count: Int) {
        if let _bageEvents = SwiftFlutterChannelIoPlugin.bagdeEvents {
           // let eventData = ["name": "onBadgeChanged", "count": count] as [String: Any?]
           SwiftFlutterChannelIoPlugin.badgeCount = count
            _bageEvents(count);
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            
        case "boot":
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            
            guard let pluginKey: String = args["pluginKey"] as? String else {
                result(FlutterError(
                    code: "ARGUMENT_ERROR",
                    message: "plugin key is not set",
                    details: "플리그인 키가 설정되어있지 않습니다."
                ))
                return
            }
            
            var profile: Profile? = nil
            if let profileArgs = args["profile"] as? [String: Any] {
                let defaultProperties = ["name", "email", "avatarUrl", "mobileNumber"]
                profile = Profile()
                
                if let name = profileArgs["name"] as? String {
                    profile?.set(name: name)
                }
                if let email = profileArgs["email"] as? String {
                    profile?.set(email: email)
                }
                if let avatarUrl = profileArgs["avatarUrl"] as? String {
                    profile?.set(avatarUrl: avatarUrl)
                }
                if let mobileNumber = profileArgs["mobileNumber"] as? String {
                    profile?.set(mobileNumber: mobileNumber)
                }
                
                profileArgs.keys.forEach { (key) in
                    if defaultProperties.contains(key) == false {
                        profile?.set(propertyKey: key, value: profileArgs[key] as AnyObject)
                    }
                }
            }
            
            ChannelIO.boot(with: ChannelPluginSettings(
                pluginKey: pluginKey,
                memberId: args["memberId"] as? String,
                memberHash: args["memberHash"] as? String
            ), profile: profile) { (status, user) in
                if status == .success {
                    result(true)
                } else {
                    result(false)
                }
            }
            
            break
            
        case "initPushToken":
            guard let args = call.arguments as? [String: Any] else {
                result(false)
                return
            }
            
            guard let token: String = args["token"] as? String else {
                result(FlutterError(
                    code: "ARGUMENT_ERROR",
                    message: "token is not set",
                    details: "토큰이 설정되어있지 않습니다."
                ))
                return
            }
            
            ChannelIO.initPushToken(tokenString: token)
            result(true)
            break
            
        case "open":
            ChannelIO.open(animated: true)
            result(true)
            break
            
        case "show":
            ChannelIO.show(animated: true)
            result(true)
            break
            
        case "hide":
            ChannelIO.hide(animated: true)
            result(true)
            break
            
        case "shutdown":
            ChannelIO.shutdown()
            result(true)
            break
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    
    class StreamHandler: NSObject, FlutterStreamHandler {
        
       // public var _events: FlutterEventSink?
        
        public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftFlutterChannelIoPlugin.bagdeEvents = events;
            SwiftFlutterChannelIoPlugin.bagdeEvents!(SwiftFlutterChannelIoPlugin.badgeCount);
            return nil
        }

        public func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftFlutterChannelIoPlugin.bagdeEvents = nil;
            return nil
        }
    }
   
}

