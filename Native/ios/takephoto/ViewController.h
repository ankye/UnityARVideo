//
//  ViewController.h
//  takephoto
//
//  Created by Ankye Sheng on 2019/1/10.
//  Copyright © 2019 Ankye Sheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(strong, nonatomic) UIButton *Btn;
@property(strong, nonatomic) UIButton *leftBtn;
@property(strong, nonatomic) UIButton *rightBtn;
@property(strong, nonatomic) UIImagePickerController* imagePicker;
@property (weak, nonatomic) IBOutlet UIStackView *lightView;

+(instancetype) sharedInstance;
- (void )unity:(NSString*) str;
- (IBAction)loadCharacter:(id)sender;

@property (nonatomic,assign)NSInteger mode;

@end

