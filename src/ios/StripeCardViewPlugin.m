//
//  StripeCardViewPlugin.m
//  Save Card Without Payment (ObjC)
//
//  Created by Pedro Alcobia on 22/04/2021.
//  Copyright © 2021 stripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StripeCardViewPlugin.h"
#import "CheckoutViewController.h"

@implementation StripeCardViewPlugin : CDVPlugin

-(void) openCardView:(UIViewController *) presentingViewController withcallbackId:(NSString*) callbackId andPlugin:(CDVPlugin *) plugin andCompletion:(void (^)(NSArray *))completion {
    
    
    CheckoutViewController *checkoutViewController = [[CheckoutViewController alloc] init];
//    checkoutViewController.callbackId = callbackId;
//    checkoutViewController.plugin = plugin;
    checkoutViewController.completion = completion;
    [presentingViewController presentViewController: checkoutViewController animated:YES completion:nil];
    
}

- (void) openCardViewCorodova:(CDVInvokedUrlCommand*) command {
    // enviar para view controller
    [self openCardView:self.viewController withcallbackId: command.callbackId andPlugin:self andCompletion:^(NSArray *response)  {
        
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsMultipart:response];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
//    CDVPluginResult* pluginResult = nil;
//    NSString* myarg = [command.arguments objectAtIndex:0];

//    if (myarg != nil) {
        
//    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//    [CDVPluginResult resultWithStatus:<#(CDVCommandStatus)#> messageAsMultipart:<#(NSArray *)#>]
//    } else {
//        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Must have first argument"];
//    }
//    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
