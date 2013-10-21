//
//  AppDelegate.mm
//  FreeTheMice
//
//  Created by karthik gopal on 23/01/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "IntroLayer.h"
#import "Utilities.h"
#import "InAppUtils.h"
#import "FTMUtil.h"
@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	soundEffect=[[sound alloc] init];
    [soundEffect initSound];
//	[InAppUtils sharedInstance];
    [Utilities createEditableCopyOfDatabaseIfNeeded];
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	// Enable multiple touches
	[glView setMultipleTouchEnabled:NO];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
	
	director_.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF by Kamran
	[director_ setDisplayStats:YES];
	
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];
	
	// attach the openglView to the director
	[director_ setView:glView];
	
	// for rotation and other messages
	[director_ setDelegate:self];
	
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
	//	[director setProjection:kCCDirectorProjection3D];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:NO]) //kamran
		CCLOG(@"Retina Display Not supported");
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	int cheese = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentCheese"];
    int firstTutorial = [[NSUserDefaults standardUserDefaults] integerForKey:@"firstTutorial"];
    int secondTutorial = [[NSUserDefaults standardUserDefaults] integerForKey:@"secondTutorial"];
    int soundTrigger = [[NSUserDefaults standardUserDefaults] integerForKey:@"soundTrigger"];
    
    if (soundTrigger == 0) {
        [FTMUtil sharedInstance].isGameSoundOn = YES;
        NSDictionary *appDefaults = [NSDictionary
                                     dictionaryWithObject:[NSNumber numberWithInt:soundTrigger] forKey:@"soundTrigger"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        
    }else{
        [FTMUtil sharedInstance].isGameSoundOn = NO;
    }
    
    if (firstTutorial == 0) {
        [FTMUtil sharedInstance].isFirstTutorial = YES;
        NSDictionary *appDefaults = [NSDictionary
                                     dictionaryWithObject:[NSNumber numberWithInt:firstTutorial] forKey:@"firstTutorial"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        
    }else{
        [FTMUtil sharedInstance].isFirstTutorial = NO;
    }
    if (secondTutorial == 0) {
        [FTMUtil sharedInstance].isSecondTutorial = YES;
        NSDictionary *appDefaults = [NSDictionary
                                     dictionaryWithObject:[NSNumber numberWithInt:secondTutorial] forKey:@"secondTutorial"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    }else{
        [FTMUtil sharedInstance].isSecondTutorial = NO;
    }
    if (cheese == 0) {
        NSDictionary *appDefaults = [NSDictionary
                                     dictionaryWithObject:[NSNumber numberWithInt:cheese] forKey:@"currentCheese"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    }
      
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]]; 
	
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
    // make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];
	
	[super dealloc];
}
@end

