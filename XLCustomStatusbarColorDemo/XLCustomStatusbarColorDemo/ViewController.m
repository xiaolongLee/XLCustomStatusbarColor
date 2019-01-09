//
//  ViewController.m
//  XLCustomStatusbarColorDemo
//
//  Created by Mac-Qke on 2019/1/9.
//  Copyright © 2019 Mac-Qke. All rights reserved.
//

#import "ViewController.h"
#import "XLCustomStatusbarColor.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *changeColorBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _changeColorBtn.layer.borderColor = [UIColor blackColor].CGColor;
    _changeColorBtn.layer.borderWidth = 1;
}

- (IBAction)changeColor:(id)sender {
    UIColor *color = [UIColor colorWithRed:arc4random() % 255 /255.0 green:arc4random() % 255 /255.0 blue:arc4random() % 255 /255.0 alpha:1];
    [XLCustomStatusbarColor updateStatusbarIconColor:color];
}

@end
