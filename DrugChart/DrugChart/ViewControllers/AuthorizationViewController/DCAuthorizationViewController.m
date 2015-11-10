//
//  DCAuthorizationViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/05/15.
//
//

#import "DCAuthorizationViewController.h"
#import "DCLogOutWebService.h"
#import "HTMLParser.h"
#import "HTMLNode.h"
#import "DCKeyChainManager.h"
#import "DCAuthorizationManager.h"


#define INPUT_KEY @"input"
#define NAME_KEY @"name"
#define ACCESS_TOKEN @"access_token"
#define ID_TOKEN @"id_token"

#define WEBVIEW_JS_STRING @"document.documentElement.outerHTML"
#define LOGIN_URL_PARAMETERS @"client_id=drug_chart&response_type=code+id_token+token&scope=openid+BedManagement+roleprofiles&redirect_uri=emis%3A%2F%2Fidentity%2Fdrugchart&nonce=8a568d30-d160-43d0-bee5-9587c88f59f8&response_mode=form_post"


@interface DCAuthorizationViewController () {
    BOOL isAuthenticated;
    NSURLRequest *failedRequest;
    NSTimer *timeoutTimer;
}

@property (weak, nonatomic) IBOutlet UIWebView *authorizationWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;

@end

@implementation DCAuthorizationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    //self.navigationController.navigationBar.hidden = NO;
    self.title = @"Login";
    isAuthenticated = NO;
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [self loadWebViewInView];
    }
    _settingsButton.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkAvailable:) name:kNetworkAvailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(baseURLChanged) name:NSUserDefaultsDidChangeNotification object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    _authorizationWebView.frame = CGRectMake(0, 64, _authorizationWebView.fsw, _authorizationWebView.fsh);
}

#pragma mark - Private methods

- (void)loadWebViewInView {
    
    //load request url in web view
    [_activityIndicator startAnimating];
    NSMutableURLRequest *request = [self getAuthorizationUrlRequest];
    [self.authorizationWebView loadRequest:request];
}

- (NSMutableURLRequest *)getAuthorizationUrlRequest {
    
    //get request url
    DCAppDelegate *appDelegate = DCAPPDELEGATE;
    NSString *urlString = [NSString stringWithFormat:@"%@?%@",appDelegate.authorizeURL,LOGIN_URL_PARAMETERS];
    NSURL *authorizeUrl = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authorizeUrl
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
    [request setHTTPMethod:GET_HTTP_REQUEST];
    return request;
}

// check for the avilability of valid access token in the response.
// if access token is present, user is successfully logged in.
- (BOOL)isSuccessfulLogin:(NSString *)htmlString {
    
    NSError *error = nil;
    HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:nil];
    if (error) {
        return NO;
    }
    HTMLNode *bodyNode = [parser body];
    NSArray *inputNodes = [bodyNode findChildTags:INPUT_KEY];
    for (HTMLNode *inputNode in inputNodes) {
        NSString *inputNodeName = [inputNode getAttributeNamed:NAME_KEY];
        if ([inputNodeName isEqualToString:ACCESS_TOKEN]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - UIWebViewDelegate protocol implementation

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self invalidateTheTimer];
    [_activityIndicator stopAnimating];
    NSString *htmlString = [webView stringByEvaluatingJavaScriptFromString:WEBVIEW_JS_STRING];
    if ([self isSuccessfulLogin:htmlString]) {
        [webView stopLoading];
        [[DCAuthorizationManager sharedAuthorizationManager] extractAndSaveUserTokensFromResponseHtml:htmlString];
        [self gotoWardsScreenOnSuccessfulLogin];
    }
}

- (void)webView:(UIWebView *)webView
didFailLoadWithError:(NSError *)error {
    
    [self invalidateTheTimer];
    [_activityIndicator stopAnimating];
    if (error.code == WEBSERVICE_UNAVAILABLE) {
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
    } else if (error.code == NETWORK_NOT_REACHABLE) {
        [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
    }
}

//TODO:
// The method is implemented to skip the certificate error at present.
// Once the server side change is made, we just need to loadWebView and we can remove
// variables isAuthenticated, failedRequest and webView:shouldStartLoadWithRequest:,
// connection:willSendRequestForAuthenticationChallenge connection:didReceiveResponse: methods.
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request   navigationType:(UIWebViewNavigationType)navigationType {

    BOOL result = isAuthenticated;
    [_activityIndicator startAnimating];
    [self invalidateTheTimer];
    timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(cancelWebRequest) userInfo:nil repeats:NO];
    if (!isAuthenticated) {
        failedRequest = request;
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [urlConnection start];
    }
    return result;
}

#pragma NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        DCAppDelegate *appDelegate = DCAPPDELEGATE;
        NSURL* baseURL = [NSURL URLWithString:appDelegate.baseURL];
        if ([challenge.protectionSpace.host isEqualToString:baseURL.host]) {
            NSLog(@"trusting connection to host %@", challenge.protectionSpace.host);
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        } 
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)pResponse {
    isAuthenticated = YES;
    [self invalidateTheTimer];
    [connection cancel];
    [self.authorizationWebView loadRequest:failedRequest];
}

- (void)gotoWardsScreenOnSuccessfulLogin {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(successfulLoginAction)]) {
        [self.delegate successfulLoginAction];
    }
}

#pragma mark - Notification Methods

- (void)networkAvailable:(NSNotification *)notification {
    
    if ([DCAPPDELEGATE isNetworkReachable]) {
        
        [self loadWebViewInView];
    }
}

- (void)cancelWebRequest {
    
    [_activityIndicator stopAnimating];
    [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"REQUEST_TIME_OUT", @"")];
}

- (void)invalidateTheTimer {
    
    if (timeoutTimer) {
        
        [timeoutTimer invalidate];
        timeoutTimer = nil;
    }
}

- (void)baseURLChanged {
    
    [self loadWebViewInView];
}

@end
