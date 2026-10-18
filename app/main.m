// SwarmChaser.app — a native macOS window around dashboard/index.html.
//
// The page is served from a private, read-only swarm:// scheme rooted at the data folder
// (SWARMCHASER_ROOT, else the sample data bundled in the app), so no server is needed.
// Web links go through a host policy to the default browser. Nothing is written or sent anywhere.
//
// Debug: SwarmChaser --snapshot out.png [--tab interp] [--size 1480x920]
//        renders one tab to a PNG and quits.
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

static NSString *const kScheme = @"swarm";

#pragma mark - read-only file scheme, confined to its roots

@interface LocalScheme : NSObject <WKURLSchemeHandler>
@property (nonatomic, copy) NSArray<NSURL *> *roots;
@property (nonatomic, copy) NSString *samplePath;  // the bundled sample data; files served from it are marked so the page can say so
@end

@implementation LocalScheme
- (instancetype)initWithRoots:(NSArray<NSURL *> *)roots {
    if ((self = [super init])) {
        NSMutableArray *rs = [NSMutableArray array];
        for (NSURL *u in roots) [rs addObject:u.URLByStandardizingPath.URLByResolvingSymlinksInPath];
        _roots = rs;
    }
    return self;
}
+ (NSString *)typeFor:(NSString *)ext {
    static NSDictionary *t;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        t = @{@"html": @"text/html; charset=utf-8", @"js": @"text/javascript; charset=utf-8", @"css": @"text/css; charset=utf-8",
              @"json": @"application/json; charset=utf-8", @"jsonl": @"text/plain; charset=utf-8", @"md": @"text/plain; charset=utf-8",
              @"txt": @"text/plain; charset=utf-8", @"png": @"image/png", @"jpg": @"image/jpeg", @"svg": @"image/svg+xml", @"pdf": @"application/pdf"};
    });
    return t[ext.lowercaseString] ?: @"application/octet-stream";
}
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id<WKURLSchemeTask>)task {
    NSURL *url = task.request.URL;
    NSString *rel = url.path.stringByRemovingPercentEncoding ?: url.path;
    if (rel.length == 0 || [rel isEqualToString:@"/"]) rel = @"/dashboard/index.html";
    if ([rel hasSuffix:@"/"]) rel = [rel stringByAppendingString:@"index.html"];
    while ([rel hasPrefix:@"/"]) rel = [rel substringFromIndex:1];
    for (NSURL *root in self.roots) {
        NSURL *file = [root URLByAppendingPathComponent:rel].URLByStandardizingPath.URLByResolvingSymlinksInPath;
        if (![file.path hasPrefix:[root.path stringByAppendingString:@"/"]]) continue;  // no escaping the root
        BOOL dir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:file.path isDirectory:&dir] || dir) continue;
        NSData *data = [NSData dataWithContentsOfURL:file];
        if (!data) continue;
        BOOL sample = [root.path isEqualToString:self.samplePath] && ![rel hasPrefix:@"dashboard/"];
        [self respond:task url:url status:200 type:[LocalScheme typeFor:file.pathExtension] data:data sample:sample];
        return;
    }
    [self respond:task url:url status:404 type:@"text/plain" data:[@"not found" dataUsingEncoding:NSUTF8StringEncoding] sample:NO];
}
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id<WKURLSchemeTask>)task {}
- (void)respond:(id<WKURLSchemeTask>)task url:(NSURL *)url status:(NSInteger)status type:(NSString *)type data:(NSData *)data sample:(BOOL)sample {
    NSMutableDictionary *h = [@{@"Content-Type": type, @"Content-Length": [@(data.length) stringValue], @"Cache-Control": @"no-store"} mutableCopy];
    if (sample) h[@"X-SwarmChaser-Data"] = @"sample";
    NSHTTPURLResponse *resp = [[NSHTTPURLResponse alloc] initWithURL:url statusCode:status HTTPVersion:@"HTTP/1.1" headerFields:h];
    [task didReceiveResponse:resp];
    [task didReceiveData:data];
    [task didFinish];
}
@end

#pragma mark - the top strip doubles as the window's drag handle (title bar is transparent)

@interface DragStrip : NSView
@end
@implementation DragStrip
- (BOOL)mouseDownCanMoveWindow { return YES; }
- (void)mouseDown:(NSEvent *)event {
    if (event.clickCount == 2) {
        NSString *action = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppleActionOnDoubleClick"];
        if ([action isEqualToString:@"Minimize"]) [self.window performMiniaturize:nil];
        else if (![action isEqualToString:@"None"]) [self.window performZoom:nil];
        return;
    }
    [self.window performWindowDragWithEvent:event];
}
@end

#pragma mark - app

@interface AppDelegate : NSObject <NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
@property (strong) NSWindow *window;
@property (strong) WKWebView *web;
@property (strong) LocalScheme *scheme;
@property (copy) NSURL *projectRoot;
@property (copy) NSString *snapshotPath, *snapshotTab, *snapshotTheme, *snapshotDetail;
@property NSSize snapshotSize;
@end

@implementation AppDelegate

- (instancetype)init {
    if ((self = [super init])) {
        NSString *root = NSProcessInfo.processInfo.environment[@"SWARMCHASER_ROOT"]
                      ?: [NSBundle.mainBundle objectForInfoDictionaryKey:@"SCProjectRoot"]
                      ?: [[NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"web" isDirectory:YES] path];  // standalone default: the sample data bundled inside the app
        _projectRoot = [NSURL fileURLWithPath:root isDirectory:YES];
        NSArray<NSString *> *args = NSProcessInfo.processInfo.arguments;
        for (NSUInteger i = 1; i + 1 < args.count; i++) {
            if ([args[i] isEqualToString:@"--snapshot"]) _snapshotPath = args[i + 1];
            if ([args[i] isEqualToString:@"--tab"]) _snapshotTab = args[i + 1];
            if ([args[i] isEqualToString:@"--theme"]) _snapshotTheme = args[i + 1];    // snapshot only: system|light|dark
            if ([args[i] isEqualToString:@"--detail"]) _snapshotDetail = args[i + 1];  // snapshot only: less|more
            if ([args[i] isEqualToString:@"--size"]) {
                NSArray *wh = [args[i + 1] componentsSeparatedByString:@"x"];
                if (wh.count == 2) _snapshotSize = NSMakeSize([wh[0] doubleValue], [wh[1] doubleValue]);
            }
        }
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    NSApp.mainMenu = [self buildMenu];

    WKWebViewConfiguration *cfg = [WKWebViewConfiguration new];
    NSMutableArray *roots = [NSMutableArray arrayWithObject:self.projectRoot];
    NSURL *bundled = [NSBundle.mainBundle.resourceURL URLByAppendingPathComponent:@"web" isDirectory:YES];
    if (bundled) [roots addObject:bundled];  // fallback copy of the UI if the project folder moves
    self.scheme = [[LocalScheme alloc] initWithRoots:roots];
    self.scheme.samplePath = bundled.URLByStandardizingPath.URLByResolvingSymlinksInPath.path;
    [cfg setURLSchemeHandler:self.scheme forURLScheme:kScheme];
    WKUserContentController *ucc = cfg.userContentController;
    [ucc addScriptMessageHandler:self name:@"swarm"];
    // hand the page its saved settings before any script runs (see the 'store' message)
    NSDictionary *saved = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SCStore"] ?: @{};
    NSData *savedJSON = [NSJSONSerialization dataWithJSONObject:saved options:0 error:nil] ?: [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *storeJS = [NSString stringWithFormat:@"window.__SC_STORE=%@;", [[NSString alloc] initWithData:savedJSON encoding:NSUTF8StringEncoding]];
    [ucc addUserScript:[[WKUserScript alloc] initWithSource:storeJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
    // snapshot-only test overrides (--theme, --detail): win over saved settings, never written back
    NSMutableDictionary *force = [NSMutableDictionary dictionary];
    if (self.snapshotPath && self.snapshotTheme) force[@"sc.theme"] = self.snapshotTheme;
    if (self.snapshotPath && self.snapshotDetail) force[@"sc.detail"] = self.snapshotDetail;
    if (force.count) {
        NSData *fj = [NSJSONSerialization dataWithJSONObject:force options:0 error:nil];
        NSString *forceJS = [NSString stringWithFormat:@"window.__SC_FORCE=%@;", [[NSString alloc] initWithData:fj encoding:NSUTF8StringEncoding]];
        [ucc addUserScript:[[WKUserScript alloc] initWithSource:forceJS injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];
    }
    [ucc addUserScript:[[WKUserScript alloc] initWithSource:
        @"document.documentElement.classList.add('shell-mac');"
         "window.addEventListener('error',function(e){try{webkit.messageHandlers.swarm.postMessage({cmd:'log',level:'error',msg:String(e.message)+' @'+e.lineno})}catch(_){}});"
         "window.addEventListener('unhandledrejection',function(e){try{var r=e.reason;webkit.messageHandlers.swarm.postMessage({cmd:'log',level:'reject',msg:String(r&&r.stack||r)})}catch(_){}});"
        injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]];

    NSSize size = self.snapshotPath && self.snapshotSize.width > 0 ? self.snapshotSize : NSMakeSize(1480, 940);
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, size.width, size.height)
                                              styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable |
                                                        NSWindowStyleMaskResizable | NSWindowStyleMaskFullSizeContentView
                                                backing:NSBackingStoreBuffered defer:NO];
    self.window.title = @"SwarmChaser";
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    // matches --bg in the dashboard for whichever appearance is in effect
    self.window.backgroundColor = [NSColor colorWithName:nil dynamicProvider:^NSColor *(NSAppearance *a) {
        BOOL dark = [[a bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]] isEqualToString:NSAppearanceNameDarkAqua];
        return dark ? [NSColor colorWithSRGBRed:5 / 255.0 green:7 / 255.0 blue:10 / 255.0 alpha:1]
                    : [NSColor colorWithSRGBRed:243 / 255.0 green:244 / 255.0 blue:246 / 255.0 alpha:1];
    }];
    NSString *themePref = self.snapshotPath && self.snapshotTheme ? self.snapshotTheme : saved[@"sc.theme"];
    [self applyThemePref:[themePref isKindOfClass:[NSString class]] ? themePref : @"system"];
    self.window.minSize = NSMakeSize(1100, 700);
    self.window.releasedWhenClosed = NO;
    self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;

    NSView *content = self.window.contentView;
    self.web = [[WKWebView alloc] initWithFrame:content.bounds configuration:cfg];
    self.web.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.web setValue:@NO forKey:@"drawsBackground"];  // no white flash before the page paints
    self.web.navigationDelegate = self;
    self.web.UIDelegate = self;
    self.web.inspectable = YES;
    double zoom = [[NSUserDefaults standardUserDefaults] doubleForKey:@"SCZoom"];
    if (zoom >= 0.7 && zoom <= 1.8) self.web.pageZoom = zoom;
    [content addSubview:self.web];
    DragStrip *strip = [[DragStrip alloc] initWithFrame:NSMakeRect(0, NSHeight(content.bounds) - 30, NSWidth(content.bounds), 30)];
    strip.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    [content addSubview:strip];

    if (self.snapshotPath) [self.window center];
    else {
        if (![self.window setFrameUsingName:@"SwarmChaserMain"]) [self.window center];
        [self.window setFrameAutosaveName:@"SwarmChaserMain"];
    }
    NSString *start = [NSString stringWithFormat:@"%@://local/dashboard/index.html%@", kScheme,
                       self.snapshotTab ? [@"#" stringByAppendingString:self.snapshotTab] : @""];
    [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:start]]];
    if (self.snapshotPath) {
        // headless check: stay visible (an occluded web view stops rendering) but never take focus or clicks
        self.window.ignoresMouseEvents = YES;
        [self.window orderFrontRegardless];
        return;
    }
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark link safety (mirrors linkPolicy() in dashboard/index.html)

// Trusted research sites open directly; known agent carriers/relays never open; anything else asks first.
typedef NS_ENUM(NSInteger, SCLinkPolicy) { SCLinkOpen, SCLinkAsk, SCLinkBlock };
+ (SCLinkPolicy)policyForURL:(NSURL *)url {
    NSString *scheme = url.scheme.lowercaseString, *host = url.host.lowercaseString;
    if (!([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) || host.length == 0) return SCLinkBlock;
    static NSArray<NSString *> *trusted, *blocked;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        trusted = @[@"urlquery.net", @"urlscan.io", @"web.archive.org", @"archive.org", @"swarmcha.se", @"metr.org", @"collusion.wiki", @"x.com",
                    @"twitter.com", @"anthropic.com", @"arxiv.org", @"huggingface.co", @"abuse.ch", @"storage.googleapis.com"];
        blocked = @[@"pastehtml.dev", @"catbox.moe", @"bytebin.lucko.me", @"httpbin.org", @"httpbun.com", @"webhook.site", @"livecodes.io", @"r.jina.ai",
                    @"cors.lol", @"allorigins.win", @"workers.dev", @"trycloudflare.com", @"ngrok.io", @"ngrok-free.app", @"ngrok.app", @"localhost.run",
                    @"lhr.life", @"loca.lt", @"tinyurl.com", @"is.gd", @"v.gd", @"rentry.co", @"telegra.ph", @"dpaste.org", @"dpaste.com", @"0x0.st",
                    @"file.io", @"tmpfiles.org", @"pipedream.net", @"requestbin.com", @"beeceptor.com", @"smee.io", @"ntfy.sh", @"mailinator.com",
                    @"yopmail.com", @"maildrop.cc", @"dontpad.com", @"notepad.pw", @"hackmd.io", @"ipfs.io", @"dweb.link", @"jsonbin.io", @"npoint.io",
                    @"kvdb.io", @"getpantry.cloud", @"hc-ping.com", @"image.thum.io", @"xss-game.appspot.com", @"raw.githubusercontent.com",
                    @"gist.githubusercontent.com", @"cdn.jsdelivr.net", @"deno.dev", @"val.run", @"mybinder.org", @"corsproxy.io", @"thingproxy.freeboard.io",
                    // 2026-10-16: relays, wrappers and carriers found by decoding scan reports and the DSEWiki archive
                    @"jqp.vercel.app", @"jqp-git-main-sighrobot.vercel.app", @"magic-html-api.vercel.app", @"vercel-cors-proxy.vercel.app",
                    @"vercel-cors-proxy-lokal.vercel.app", @"proxy-mu-seven-70.vercel.app", @"cors-bypasser-pro.vercel.app", @"md.succ.ai",
                    @"markdown.new", @"allorigins.hexlet.app", @"md.dhr.wtf", @"proxymule.com", @"corsmirror.com", @"cors.isomorphic-git.org",
                    @"urltomarkdown.herokuapp.com", @"cors-anywhere.herokuapp.com", @"cors-anywhere.com", @"proxy.corsfix.com", @"cors.sh",
                    @"cors.eu.org", @"microlink.io", @"ctxr.me", @"thenacken-python-cors-proxy.hf.space", @"api.ocr.space", @"dev.thedrive.ai",
                    @"httpbingo.org", @"httpbin.kennethreitz.org", @"pie.dev", @"paste.centos.org", @"paste.linuxiarz.pl", @"bytebin.rkslot.nl",
                    @"da.gd", @"vanderbi.lt", @"maximail.fyi"];
    });
    BOOL (^matches)(NSArray<NSString *> *) = ^BOOL(NSArray<NSString *> *list) {
        for (NSString *d in list) if ([host isEqualToString:d] || [host hasSuffix:[@"." stringByAppendingString:d]]) return YES;
        return NO;
    };
    if (matches(blocked)) return SCLinkBlock;
    return matches(trusted) ? SCLinkOpen : SCLinkAsk;
}

- (BOOL)askTitle:(NSString *)title info:(NSString *)info okButton:(NSString *)ok {
    if (self.snapshotPath) return NO;  // headless runs never open anything
    NSAlert *alert = [NSAlert new];
    alert.messageText = title;
    alert.informativeText = info ?: @"";
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:ok];
    [alert addButtonWithTitle:@"Cancel"];
    return [alert runModal] == NSAlertFirstButtonReturn;
}

- (void)openExternal:(NSURL *)url confirmed:(BOOL)confirmed {
    switch ([AppDelegate policyForURL:url]) {
        case SCLinkBlock:
            fprintf(stderr, "[link] blocked %s\n", url.host.UTF8String ?: "(no host)");
            return;
        case SCLinkOpen:
            [[NSWorkspace sharedWorkspace] openURL:url];
            return;
        case SCLinkAsk:
            if (confirmed || [self askTitle:[NSString stringWithFormat:@"Open %@ in your browser?", url.host]
                                       info:@"It isn't on the trusted list, and pages linked from agent activity can host hostile content."
                                   okButton:@"Open"])
                [[NSWorkspace sharedWorkspace] openURL:url];
            return;
    }
}

// JavaScript confirm()/alert() need native panels in WKWebView; without these, confirm() silently returns NO.
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame
    completionHandler:(void (^)(BOOL))completionHandler {
    NSArray<NSString *> *parts = [message componentsSeparatedByString:@"\n\n"];
    NSString *info = parts.count > 1 ? [[parts subarrayWithRange:NSMakeRange(1, parts.count - 1)] componentsJoinedByString:@"\n\n"] : @"";
    completionHandler([self askTitle:parts.firstObject info:info okButton:@"OK"]);
}
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame
    completionHandler:(void (^)(void))completionHandler {
    if (!self.snapshotPath) { NSAlert *alert = [NSAlert new]; alert.messageText = @"SwarmChaser"; alert.informativeText = message; [alert runModal]; }
    completionHandler();
}

- (void)applicationDidBecomeActive:(NSNotification *)note { NSApp.dockTile.badgeLabel = nil; }
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)app { return YES; }
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app { return YES; }

#pragma mark web delegates

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)action
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *s = action.request.URL.scheme.lowercaseString;
    if ([s isEqualToString:kScheme] || [s isEqualToString:@"about"]) { decisionHandler(WKNavigationActionPolicyAllow); return; }
    if ([s isEqualToString:@"http"] || [s isEqualToString:@"https"]) [self openExternal:action.request.URL confirmed:NO];
    decisionHandler(WKNavigationActionPolicyCancel);  // any other scheme (file:, mailto:, custom app links) never leaves the app
}

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
    forNavigationAction:(WKNavigationAction *)action windowFeatures:(WKWindowFeatures *)features {
    NSString *s = action.request.URL.scheme.lowercaseString;
    if ([s isEqualToString:@"http"] || [s isEqualToString:@"https"]) [self openExternal:action.request.URL confirmed:NO];
    return nil;  // target=_blank links go through the link policy to the default browser, never a new web view
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (!self.snapshotPath) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.web evaluateJavaScript:@"JSON.stringify({vis:document.visibilityState,fps:(document.querySelector('#fFps')||{}).textContent,tab:typeof curTab!=='undefined'?curTab:null,S:typeof S!=='undefined'&&!!S})"
                   completionHandler:^(id r, NSError *e) { fprintf(stderr, "[snapshot state] %s\n", [[r description] ?: e.description UTF8String]); }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.web takeSnapshotWithConfiguration:[WKSnapshotConfiguration new] completionHandler:^(NSImage *image, NSError *error) {
            NSData *png = nil;
            if (image) {
                NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:image.TIFFRepresentation];
                png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
            }
            if (![png writeToFile:self.snapshotPath atomically:YES]) fprintf(stderr, "snapshot failed: %s\n", error.description.UTF8String ?: "no image");
            else printf("snapshot written: %s\n", self.snapshotPath.UTF8String);
            [NSApp terminate:nil];
        }];
    });
}

- (void)userContentController:(WKUserContentController *)ucc didReceiveScriptMessage:(WKScriptMessage *)message {
    if (![message.body isKindOfClass:[NSDictionary class]]) return;
    NSDictionary *b = message.body;
    NSString *cmd = b[@"cmd"];
    if ([cmd isEqualToString:@"copy"] && [b[@"text"] isKindOfClass:[NSString class]]) {
        [NSPasteboard.generalPasteboard clearContents];
        [NSPasteboard.generalPasteboard setString:b[@"text"] forType:NSPasteboardTypeString];
    } else if ([cmd isEqualToString:@"reveal"]) {
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[self.projectRoot]];
    } else if ([cmd isEqualToString:@"openExternal"] && [b[@"url"] isKindOfClass:[NSString class]]) {
        NSURL *u = [NSURL URLWithString:b[@"url"]];
        if (u) [self openExternal:u confirmed:YES];  // the page already asked; blocked hosts still never open
    } else if ([cmd isEqualToString:@"attention"]) {
        // new activity while the app is in the background: bounce once and badge the Dock icon
        if (!NSApp.isActive) {
            NSString *badge = [b[@"badge"] isKindOfClass:[NSString class]] ? [b[@"badge"] substringToIndex:MIN((NSUInteger)2, [b[@"badge"] length])] : @"●";
            NSApp.dockTile.badgeLabel = badge;
            [NSApp requestUserAttention:NSInformationalRequest];
        }
    } else if ([cmd isEqualToString:@"clearBadge"]) {
        NSApp.dockTile.badgeLabel = nil;  // the page asked to clear notifications
    } else if ([cmd isEqualToString:@"store"] && [b[@"key"] isKindOfClass:[NSString class]] && [b[@"value"] isKindOfClass:[NSString class]]) {
        NSString *key = b[@"key"], *value = b[@"value"];
        if ([key hasPrefix:@"sc."] && key.length <= 64 && value.length <= 512) {
            NSMutableDictionary *d = [([[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SCStore"] ?: @{}) mutableCopy];
            d[key] = value;
            [[NSUserDefaults standardUserDefaults] setObject:d forKey:@"SCStore"];
            if ([key isEqualToString:@"sc.theme"]) [self applyThemePref:value];
        }
    } else if ([cmd isEqualToString:@"log"]) {
        fprintf(stderr, "[web %s] %s\n", [[b[@"level"] description] UTF8String], [[b[@"msg"] description] UTF8String]);
    }
}

// light / dark / system: the web view's prefers-color-scheme follows the window's appearance
- (void)applyThemePref:(NSString *)pref {
    if ([pref isEqualToString:@"light"]) self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    else if ([pref isEqualToString:@"dark"]) self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    else self.window.appearance = nil;  // follow macOS
}

#pragma mark menu

- (void)reloadData:(id)sender { [self.web evaluateJavaScript:@"window.SC&&SC.refresh()" completionHandler:nil]; }
- (void)reloadInterface:(id)sender { [self.web reload]; }
- (void)revealProject:(id)sender { [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[self.projectRoot]]; }
- (void)setZoom:(double)z {
    z = MAX(0.8, MIN(1.6, round(z * 10) / 10));
    self.web.pageZoom = z;
    [[NSUserDefaults standardUserDefaults] setDouble:z forKey:@"SCZoom"];
}
- (void)zoomIn:(id)sender { [self setZoom:self.web.pageZoom + 0.1]; }
- (void)zoomOut:(id)sender { [self setZoom:self.web.pageZoom - 0.1]; }
- (void)zoomReset:(id)sender { [self setZoom:1.0]; }
- (void)runScan:(id)sender { [self.web evaluateJavaScript:@"window.SC&&SC.runScan()" completionHandler:nil]; }
- (void)showTab:(NSMenuItem *)sender {
    NSArray *tabs = @[@"overview", @"timeline", @"runlog", @"interp", @"threads", @"vectors", @"transcripts", @"intel", @"archives"];
    [self.web evaluateJavaScript:[NSString stringWithFormat:@"window.SC&&SC.setTab('%@')", tabs[sender.tag]] completionHandler:nil];
}

- (NSMenu *)buildMenu {
    NSMenu *bar = [NSMenu new];
    NSMenuItem *(^add)(NSMenu *, NSString *, SEL, NSString *, id) = ^NSMenuItem *(NSMenu *m, NSString *t, SEL a, NSString *k, id target) {
        NSMenuItem *it = [m addItemWithTitle:t action:a keyEquivalent:k];
        it.target = target;
        return it;
    };
    NSMenu *(^top)(NSString *) = ^NSMenu *(NSString *title) {
        NSMenuItem *item = [NSMenuItem new];
        NSMenu *m = [[NSMenu alloc] initWithTitle:title];
        item.submenu = m;
        [bar addItem:item];
        return m;
    };

    NSMenu *app = top(@"SwarmChaser");
    add(app, @"About SwarmChaser", @selector(orderFrontStandardAboutPanel:), @"", nil);
    [app addItem:NSMenuItem.separatorItem];
    add(app, @"Hide SwarmChaser", @selector(hide:), @"h", nil);
    add(app, @"Hide Others", @selector(hideOtherApplications:), @"h", nil).keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagOption;
    add(app, @"Show All", @selector(unhideAllApplications:), @"", nil);
    [app addItem:NSMenuItem.separatorItem];
    add(app, @"Quit SwarmChaser", @selector(terminate:), @"q", nil);

    NSMenu *file = top(@"File");
    add(file, @"Sweep and Reload Data", @selector(runScan:), @"S", self);
    add(file, @"Show Data Folder in Finder", @selector(revealProject:), @"O", self);
    [file addItem:NSMenuItem.separatorItem];
    add(file, @"Close Window", @selector(performClose:), @"w", nil);

    NSMenu *edit = top(@"Edit");
    add(edit, @"Copy", @selector(copy:), @"c", nil);
    add(edit, @"Select All", @selector(selectAll:), @"a", nil);

    NSMenu *view = top(@"View");
    add(view, @"Refresh Data", @selector(reloadData:), @"r", self);
    add(view, @"Reload Interface", @selector(reloadInterface:), @"R", self);
    [view addItem:NSMenuItem.separatorItem];
    add(view, @"Bigger Text", @selector(zoomIn:), @"=", self);
    add(view, @"Smaller Text", @selector(zoomOut:), @"-", self);
    add(view, @"Actual Size", @selector(zoomReset:), @"0", self);
    [view addItem:NSMenuItem.separatorItem];
    NSArray *names = @[@"Overview", @"Timeline", @"Run Log", @"Interpretation", @"Threads", @"Vectors", @"Transcripts", @"Intel", @"Archives"];
    for (NSUInteger i = 0; i < names.count; i++)
        add(view, names[i], @selector(showTab:), [NSString stringWithFormat:@"%lu", (unsigned long)i + 1], self).tag = (NSInteger)i;
    [view addItem:NSMenuItem.separatorItem];
    add(view, @"Enter Full Screen", @selector(toggleFullScreen:), @"f", nil).keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagControl;

    NSMenu *win = top(@"Window");
    add(win, @"Minimize", @selector(performMiniaturize:), @"m", nil);
    add(win, @"Zoom", @selector(performZoom:), @"", nil);
    NSApp.windowsMenu = win;
    return bar;
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = NSApplication.sharedApplication;
        AppDelegate *delegate = [AppDelegate new];
        app.delegate = delegate;
        app.activationPolicy = NSApplicationActivationPolicyRegular;
        [app run];
    }
    return 0;
}
