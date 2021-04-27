//
//  CheckoutViewController.m
//  app
//
//  Created by Ben Guo on 9/29/19.
//  Copyright © 2019 stripe-samples. All rights reserved.
//

#import "CheckoutViewController.h"
@import Stripe;

/**
* To run this app, you'll need to first run the sample server locally.
* Follow the "How to run locally" instructions in the root directory's README.md to get started.
* Once you've started the server, open http://localhost:4242 in your browser to check that the
* server is running locally.
* After verifying the sample server is running locally, build and run the app using the iOS simulator.
*/
//NSString *const BackendUrl = @"http://127.0.0.1:4242/";
@interface CheckoutViewController ()  <STPAuthenticationContext>

@property (nonatomic, weak) STPPaymentCardTextField *cardTextField;
@property (nonatomic, weak) UIButton *payButton;
@property (nonatomic, weak) UIButton *cancelButton;
//@property (nonatomic, weak) UITextField *emailTextField;
@property (nonatomic, copy) NSString *setupIntentClientSecret;

@end


@implementation CheckoutViewController

NSString *BackendUrl = @"http://127.0.0.1:4242/";
void (^completion)(NSArray *) = nil;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UITextField *emailTextField = [UITextField new];
//    emailTextField.borderStyle = UITextBorderStyleRoundedRect;
//    emailTextField.placeholder = @"Enter your email";
//    self.emailTextField = emailTextField;

    STPPaymentCardTextField *cardTextField = [[STPPaymentCardTextField alloc] init];
    self.cardTextField = cardTextField;

    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton.layer.cornerRadius = 5;
    payButton.backgroundColor = [UIColor systemBlueColor];
    payButton.titleLabel.font = [UIFont systemFontOfSize:22];
    [payButton setTitle:@"Save" forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    self.payButton = payButton;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.backgroundColor = [UIColor systemBlueColor];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:22];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelPay) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton = cancelButton;

    UILabel *mandateLabel = [UILabel new];
    // Collect permission to reuse the customer's card:
    // In your app, add terms on how you plan to process payments and
    // reference the terms of the payment in the checkout flow
    // See https://stripe.com/docs/strong-customer-authentication/faqs#mandates
    mandateLabel.text = @"I authorise Stripe Samples to send instructions to the financial institution that issued my card to take payments from my card account in accordance with the terms of my agreement with you.";
    mandateLabel.numberOfLines = 0;
    mandateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    mandateLabel.textColor = UIColor.systemGrayColor;
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[cardTextField, payButton, cancelButton, mandateLabel]];
//    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[emailTextField, cardTextField, button, mandateLabel]];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.spacing = 20;
    [self.view addSubview:stackView];

    [NSLayoutConstraint activateConstraints:@[
        [stackView.leftAnchor constraintEqualToSystemSpacingAfterAnchor:self.view.leftAnchor multiplier:2],
        [self.view.rightAnchor constraintEqualToSystemSpacingAfterAnchor:stackView.rightAnchor multiplier:2],
        [stackView.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.view.topAnchor multiplier:2],
    ]];
    
    if (self.args.count == 0) {
        [self startCheckout];
    } else {
        self.setupIntentClientSecret = self.args[0];
    }
}

- (void)startCheckout {
    // Create a SetupIntent by calling the sample server's /create-setup-intent endpoint.
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@create-setup-intent", BackendUrl]];
    NSMutableURLRequest *request = [[NSURLRequest requestWithURL:url] mutableCopy];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *requestError) {
        NSError *error = requestError;
        if(data == nil) {
            NSString *message = @"no data from server";
            // print error and get out
            [self alertError:message];
            return;
        }
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil || httpResponse.statusCode != 200 || json[@"publishableKey"] == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *message = error.localizedDescription ?: @"";
                [self alertError:message];
            });
        }
        else {
            self.setupIntentClientSecret = json[@"clientSecret"];
            //NSString *stripePublishableKey = json[@"publishableKey"];
            // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
            //[StripeAPI setDefaultPublishableKey:stripePublishableKey];
        }
    }];
    [task resume];
}

- (void)alertError:(NSString*) message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error loading page" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    if([NSThread isMainThread]) {
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

- (void)cancelPay {
    [self dismissViewControllerAnimated:YES completion:^{
        [self returnFromCordova:nil];
    }];
}

- (void)pay {
    if (!self.setupIntentClientSecret) {
        NSLog(@"SetupIntent hasn't been created");
        return;
    }

    // Collect card details
    STPPaymentMethodCardParams *cardParams = self.cardTextField.cardParams;
    
    // Later, you will need to attach the PaymentMethod to the Customer it belongs to.
    // This example collects the customer's email to know which customer the PaymentMethod belongs to, but your app might use an account id, session cookie, etc.
//    STPPaymentMethodBillingDetails *billingDetails = [STPPaymentMethodBillingDetails new];
//    billingDetails.email = self.emailTextField.text;
    
    // Create SetupIntent confirm parameters with the above
    STPPaymentMethodParams *paymentMethodParams = [STPPaymentMethodParams paramsWithCard:cardParams billingDetails:nil metadata:nil];
    STPSetupIntentConfirmParams *setupIntentParams = [[STPSetupIntentConfirmParams alloc] initWithClientSecret:self.setupIntentClientSecret];
    setupIntentParams.paymentMethodParams = paymentMethodParams;

    // Complete the setup
    STPPaymentHandler *paymentHandler = [STPPaymentHandler sharedHandler];
    [paymentHandler confirmSetupIntent:setupIntentParams withAuthenticationContext:self completion:^(STPPaymentHandlerActionStatus status, STPSetupIntent *setupIntent, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case STPPaymentHandlerActionStatusFailed: {
                    NSString *message = error.localizedDescription ?: @"";
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Setup failed" message:message preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case STPPaymentHandlerActionStatusCanceled: {
                    NSString *message = error.localizedDescription ?: @"";
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Setup canceled" message:message preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case STPPaymentHandlerActionStatusSucceeded: {
//                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Setup succeeded" message:setupIntent.description preferredStyle:UIAlertControllerStyleAlert];
//                    [alert addAction:[UIAlertAction actionWithTitle:@"Restart demo" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//                        [self.cardTextField clear];
//                        self.emailTextField.text = nil;
//                        [self startCheckout];
//                    }]];
//                    [self presentViewController:alert animated:YES completion:nil];
                    
                    // execute return ok from cordova
                    NSArray *payment = @[[setupIntent paymentMethodID], [cardParams last4], [[cardParams expMonth] stringValue], [[cardParams expYear] stringValue]];
                    [self returnFromCordova:payment];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
//                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: eventInfo[@"name"]];
//                    pluginResult.keepCallback = @YES;
//                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    
                    break;
                }
                default:
                    break;
            }
        });
    }];
}

# pragma mark STPAuthenticationContext
- (UIViewController *)authenticationPresentingViewController {
    return self;
}

- (void) returnFromCordova:(NSArray* ) response {
//    if (self.plugin != nil && self.callbackId != nil) {
//        CDVPluginResult* pluginResult = nil;
//        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK messageAsMultipart:response];
//        [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
//        [self.plugin.commandDelegate
//            sendPluginResult:pluginResult
//            callbackId: self.callbackId];
//    }
    self.completion(response);
}

@end
