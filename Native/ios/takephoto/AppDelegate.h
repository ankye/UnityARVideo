//
//  AppDelegate.h
//  takephoto
//
//  Created by Ankye Sheng on 2019/1/10.
//  Copyright © 2019 Ankye Sheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UnityAppController *unityController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIWindow *unityWindow;

-(void) updateUnityFrame:(CGRect)rect;

-(void)showUnityWindow;
-(void)hideUnityWindow;
-(UIView*) unityView ;

@end

