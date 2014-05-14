//
//  AR_ViewController.m
//  BoxTutorial
//
//  Created by Sandip Saha on 14/05/14.
//  Copyright (c) 2014 innofied.com. All rights reserved.
//

#import "AR_ViewController.h"

#import "BoxAuthorizationNavigationController.h"


#import <BoxSDK/BoxSDK.h>

@interface AR_ViewController ()

@end

@implementation AR_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidSucceed:)
                                                 name:BoxOAuth2SessionDidBecomeAuthenticatedNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(boxAPIAuthenticationDidFail:)
                                                 name:BoxOAuth2SessionDidReceiveAuthenticationErrorNotification
                                               object:[BoxSDK sharedSDK].OAuth2Session];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)callbox:(id)sender {
    
    BoxAuthorizationViewController *authorizationViewController = [[BoxAuthorizationViewController alloc] initWithAuthorizationURL:[[BoxSDK sharedSDK].OAuth2Session authorizeURL] redirectURI:nil];
    
    BoxAuthorizationNavigationController *loginNavigation = [[BoxAuthorizationNavigationController alloc] initWithRootViewController:authorizationViewController];
    authorizationViewController.delegate = loginNavigation;
    
    loginNavigation.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:loginNavigation animated:YES completion:nil];
}

-(void)boxAPIAuthenticationDidSucceed:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 successfully authenticated notification");
    BoxOAuth2Session *session = (BoxOAuth2Session *) [notification object];
    NSLog(@"Access token  (%@) expires at %@", session.accessToken, session.accessTokenExpiration);
    NSLog(@"Refresh token (%@)", session.refreshToken);
    
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"isAuthorized"];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [self accessBoxForFiles];
        }];
    });
}

- (void)boxAPIAuthenticationDidFail:(NSNotification *)notification
{
    NSLog(@"Received OAuth2 failed authenticated notification");
    NSString *oauth2Error = [[notification userInfo] valueForKey:BoxOAuth2AuthenticationErrorKey];
    NSLog(@"Authentication error  (%@)", oauth2Error);
    
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"isAuthorized"];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void)accessBoxForFiles
{
    UIStoryboard *settingsStoryBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *initialViewController  = [settingsStoryBoard instantiateViewControllerWithIdentifier:@"FolderTableView"];
    
    
    initialViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:initialViewController animated:YES completion:nil];
}

@end
