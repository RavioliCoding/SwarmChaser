// Draws the SwarmChaser app icon (1024×1024 PNG): a strand torus around the "watch" neuron,
// a particle swarm behind it and one red alert node, on a dark macOS-style squircle.
// Build: clang -fobjc-arc -framework Cocoa make_icon.m -o make_icon     Usage: make_icon <out.png>
#import <Cocoa/Cocoa.h>
#include <math.h>

static uint64_t rs = 0x5EEDCAFEULL;
static double rnd(void) { rs = rs * 6364136223846793005ULL + 1442695040888963407ULL; return (double)(rs >> 11) / (double)(1ULL << 53); }
static double gauss(void) { double u = fmax(rnd(), 1e-12), v = rnd(); return sqrt(-2 * log(u)) * cos(2 * M_PI * v); }
static CGColorRef col(uint32_t hex, double a) {
    return CGColorCreateSRGB(((hex >> 16) & 255) / 255.0, ((hex >> 8) & 255) / 255.0, (hex & 255) / 255.0, a);
}
static void fillC(CGContextRef c, uint32_t hex, double a) { CGColorRef k = col(hex, a); CGContextSetFillColorWithColor(c, k); CGColorRelease(k); }
static void strokeC(CGContextRef c, uint32_t hex, double a) { CGColorRef k = col(hex, a); CGContextSetStrokeColorWithColor(c, k); CGColorRelease(k); }
static CGGradientRef grad(CGColorSpaceRef cs, uint32_t a, double aa, uint32_t b, double ba) {
    CGColorRef c1 = col(a, aa), c2 = col(b, ba);
    CFArrayRef arr = (__bridge CFArrayRef)@[(__bridge id)c1, (__bridge id)c2];
    CGGradientRef g = CGGradientCreateWithColors(cs, arr, (CGFloat[]){0, 1});
    CGColorRelease(c1); CGColorRelease(c2); return g;
}

enum { AMBER = 0xF4A940, BLUE = 0x5AB4FF, STEEL = 0x8FB0E8, WHITE = 0xEEF1F5, RED = 0xFF5A52, INK = 0x05070A };

// torus → screen
static const double R = 1.0, r = 0.36, D = 6.0, SC = 232.0, CX = 512.0, CY = 498.0;
static double ct, st, cr, sr;
static CGPoint project(double x, double y, double z, double *depth) {
    double y1 = y * ct - z * st, z1 = y * st + z * ct;
    double x2 = x * cr - y1 * sr, y2 = x * sr + y1 * cr, f = SC * D / (D - z1);
    if (depth) *depth = z1;
    return CGPointMake(CX + x2 * f, CY + y2 * f);
}

#define NS 1150
#define NP 26
static CGPoint strandPts[NS][NP];
static double strandDepth[NS];
static uint32_t strandCol[NS];

static void drawStrands(CGContextRef c, BOOL front, double alpha) {
    CGContextSetBlendMode(c, kCGBlendModePlusLighter);
    CGContextSetLineWidth(c, 1.6); CGContextSetLineCap(c, kCGLineCapRound);
    for (int i = 0; i < NS; i++) {
        if ((strandDepth[i] >= 0) != front) continue;
        strokeC(c, strandCol[i], alpha);
        CGContextAddLines(c, strandPts[i], NP); CGContextStrokePath(c);
    }
    CGContextSetBlendMode(c, kCGBlendModeNormal);
}

static void node(CGContextRef c, CGColorSpaceRef cs, double u, double v, uint32_t hex, double rad, BOOL ring) {
    double rr = R + r * cos(v);
    CGPoint p = project(rr * cos(u), rr * sin(u), r * sin(v), NULL);
    CGGradientRef g = grad(cs, hex, 0.6, hex, 0);
    CGContextDrawRadialGradient(c, g, p, 0, p, rad * 4, 0); CGGradientRelease(g);
    fillC(c, hex, 1); CGContextFillEllipseInRect(c, CGRectMake(p.x - rad, p.y - rad, rad * 2, rad * 2));
    if (ring) { strokeC(c, hex, 0.8); CGContextSetLineWidth(c, 3); CGContextStrokeEllipseInRect(c, CGRectMake(p.x - rad * 2.2, p.y - rad * 2.2, rad * 4.4, rad * 4.4)); }
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 2) { fprintf(stderr, "usage: make_icon <out.png>\n"); return 1; }
        CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
        CGContextRef c = CGBitmapContextCreate(NULL, 1024, 1024, 8, 0, cs, kCGImageAlphaPremultipliedLast);
        double tilt = -1.12, roll = -0.38; ct = cos(tilt); st = sin(tilt); cr = cos(roll); sr = sin(roll);

        // squircle body (Apple icon grid: 824 body, ~185 corners) with a soft drop shadow
        CGRect body = CGRectMake(100, 100, 824, 824);
        CGPathRef shape = CGPathCreateWithRoundedRect(body, 185, 185, NULL);
        CGContextSaveGState(c);
        CGColorRef sh = col(0x000000, 0.5); CGContextSetShadowWithColor(c, CGSizeMake(0, -14), 30, sh); CGColorRelease(sh);
        CGContextAddPath(c, shape); fillC(c, INK, 1); CGContextFillPath(c);
        CGContextRestoreGState(c);

        CGContextSaveGState(c);
        CGContextAddPath(c, shape); CGContextClip(c);
        {
            CGColorRef a = col(0x141B25, 1), b = col(0x080B10, 1), d = col(0x020305, 1);
            CGGradientRef g = CGGradientCreateWithColors(cs, (__bridge CFArrayRef)@[(__bridge id)a, (__bridge id)b, (__bridge id)d], (CGFloat[]){0, 0.55, 1});
            CGContextDrawRadialGradient(c, g, CGPointMake(512, 560), 0, CGPointMake(512, 512), 640, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(g); CGColorRelease(a); CGColorRelease(b); CGColorRelease(d);
        }
        // particle swarm
        for (int i = 0; i < 2800; i++) {
            double x = 512 + gauss() * 230, y = 500 + gauss() * 190, s = rnd() < 0.07 ? 3.2 : (rnd() < 0.4 ? 2.2 : 1.5);
            fillC(c, WHITE, 0.05 + pow(rnd(), 2.2) * 0.5); CGContextFillRect(c, CGRectMake(x, y, s, s));
        }
        // strands: amber on one side of the ring, blue on the other, a few white
        for (int i = 0; i < NS; i++) {
            double u0 = rnd() * 2 * M_PI, du = (rnd() - 0.5) * 0.6, v0 = rnd() * 2 * M_PI, vs = 2 * M_PI * (0.45 + rnd() * 0.5), rf = 0.85 + rnd() * 0.32, zs = 0;
            for (int k = 0; k < NP; k++) {
                double t = k / (double)(NP - 1), u = u0 + du * t, v = v0 + vs * t, rr = r * rf, z;
                strandPts[i][k] = project((R + rr * cos(v)) * cos(u), (R + rr * cos(v)) * sin(u), rr * sin(v), &z); zs += z;
            }
            strandDepth[i] = zs / NP;
            double side = (1 + cos(u0 - 2.6)) / 2;
            strandCol[i] = rnd() < 0.08 ? WHITE : (side > 0.55 ? AMBER : (side < 0.35 ? BLUE : STEEL));
        }
        drawStrands(c, NO, 0.075);

        // the watch: a neuron at the centre
        CGPoint nc = CGPointMake(CX, CY);
        CGGradientRef glow = grad(cs, WHITE, 0.42, WHITE, 0);
        CGContextDrawRadialGradient(c, glow, nc, 0, nc, 130, 0); CGGradientRelease(glow);
        CGContextSetLineWidth(c, 2.6); CGContextSetLineCap(c, kCGLineCapRound);
        for (int k = 0; k < 30; k++) {
            double a = k / 30.0 * 2 * M_PI + rnd() * 0.12, len = 46 + rnd() * 84, x = nc.x + cos(a) * 34, y = nc.y + sin(a) * 24, g = a;
            CGPoint pts[6] = {CGPointMake(x, y)};
            for (int s = 1; s < 6; s++) { g += (rnd() - 0.5) * 0.45; x += cos(g) * len / 5; y += sin(g) * len / 5; pts[s] = CGPointMake(x, y); }
            strokeC(c, WHITE, 0.72); CGContextAddLines(c, pts, 6); CGContextStrokePath(c);
            if (rnd() < 0.5) {
                double fg = g + (rnd() < 0.5 ? 0.7 : -0.7); CGPoint f[2] = {pts[2], CGPointMake(pts[2].x + cos(fg) * len * 0.3, pts[2].y + sin(fg) * len * 0.3)};
                CGContextAddLines(c, f, 2); CGContextStrokePath(c);
            }
            fillC(c, WHITE, 0.9); CGContextFillEllipseInRect(c, CGRectMake(x - 3, y - 3, 6, 6));
        }
        CGContextSaveGState(c);
        CGContextTranslateCTM(c, nc.x, nc.y); CGContextRotateCTM(c, 0.35);
        fillC(c, INK, 0.95); CGContextFillEllipseInRect(c, CGRectMake(-44, -30, 88, 60));
        strokeC(c, WHITE, 0.95); CGContextSetLineWidth(c, 4.5); CGContextStrokeEllipseInRect(c, CGRectMake(-44, -30, 88, 60));
        strokeC(c, WHITE, 0.5); CGContextSetLineWidth(c, 2.2);
        CGContextStrokeEllipseInRect(c, CGRectMake(-29, -19.5, 58, 39)); CGContextStrokeEllipseInRect(c, CGRectMake(-15, -10, 30, 20));
        CGColorRef wg = col(WHITE, 1); CGContextSetShadowWithColor(c, CGSizeZero, 22, wg); CGColorRelease(wg);
        fillC(c, WHITE, 1); CGContextFillEllipseInRect(c, CGRectMake(-8, -8, 16, 16));
        CGContextRestoreGState(c);

        drawStrands(c, YES, 0.13);

        // report-link "fur" on the near side
        CGContextSetBlendMode(c, kCGBlendModePlusLighter); CGContextSetLineWidth(c, 1.7);
        for (int i = 0; i < 380; i++) {
            double u = -2.5 + rnd() * 2.7, v = (rnd() - 0.5) * 0.8, r0 = R + r * cos(v) * 0.98, len = 0.06 + pow(rnd(), 1.6) * 0.36;
            CGPoint seg[2] = {project(r0 * cos(u), r0 * sin(u), r * sin(v), NULL), project((r0 + len) * cos(u), (r0 + len) * sin(u), r * sin(v) * 1.15, NULL)};
            strokeC(c, WHITE, 0.3); CGContextAddLines(c, seg, 2); CGContextStrokePath(c);
        }
        CGContextSetBlendMode(c, kCGBlendModeNormal);

        node(c, cs, -0.55, 0.9, RED, 12, YES);
        node(c, cs, 2.75, -0.4, AMBER, 7, NO);

        // glass: top sheen, then a hairline rim
        CGGradientRef sheen = grad(cs, WHITE, 0.08, WHITE, 0);
        CGContextDrawLinearGradient(c, sheen, CGPointMake(512, 924), CGPointMake(512, 640), 0); CGGradientRelease(sheen);
        CGContextRestoreGState(c);
        CGContextAddPath(c, shape); strokeC(c, WHITE, 0.12); CGContextSetLineWidth(c, 2); CGContextStrokePath(c);

        CGImageRef img = CGBitmapContextCreateImage(c);
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:img];
        NSData *png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        BOOL ok = [png writeToFile:[NSString stringWithUTF8String:argv[1]] atomically:YES];
        CGImageRelease(img); CGPathRelease(shape); CGContextRelease(c); CGColorSpaceRelease(cs);
        if (!ok) { fprintf(stderr, "could not write %s\n", argv[1]); return 1; }
    }
    return 0;
}
