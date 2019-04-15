//
//  AppDelegate.m
//  Tt
//
//  Created by Mory on 16/8/11.
//  Copyright © 2016年 Mory. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "VuforiaNativeRendererController.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


-(UIWindow *)unityWindow{
    
    return  UnityGetMainWindow();
}

-(void)updateUnityFrame:(CGRect)rect{
    UnityGetGLView().frame = rect;
}
- (void)showUnityWindow {
    [self.unityWindow makeKeyAndVisible];
    UnityPause(false);
}

- (void)hideUnityWindow {
    UnityPause(true);
    [self.window makeKeyAndVisible];
}

- (UnityAppController *)unityVC
{
    if(_unityController == NULL){
        _unityController = [[VuforiaNativeRendererController alloc] init];
    }
    return _unityController;
}

-(UnityView*) unityView {
    return _unityController.unityView;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _unityController = [self unityVC]; // [[UnityAppController alloc] init];
    [_unityController application:application didFinishLaunchingWithOptions:launchOptions];
    
//    self.window = [[UIWindow alloc] initWithFrame:SCREEN_FRAME];
//    self.window.backgroundColor = [UIColor blackColor];
//    
//    
////    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
//   // self.window.rootViewController = nav;
//    ViewController* vc = [ViewController sharedInstance];  //[[ViewController alloc] init];
//    
//    self.window.rootViewController = vc;
//    
//    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [[self unityVC] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[self unityVC] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[self unityVC] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[self unityVC] applicationDidBecomeActive:application];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[self unityVC] applicationWillTerminate:application];
}

@end
