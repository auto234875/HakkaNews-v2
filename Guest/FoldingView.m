//
//  AppDelegate.m
//  FoldingView
//
//  Created by John on 11/1/14.
//  Copyright (c) 2014 John. All rights reserved.
//

#import "FoldingView.h"
#import <POP/POP.h>
#import <Colours/Colours.h>
#import "UIImage+ImageEffects.h"
#import <FBShimmeringLayer.h>

typedef NS_ENUM(NSInteger, LayerSection) {
    LayerSectionTop,
    LayerSectionBottom
};

@interface FoldingView() <POPAnimationDelegate,UIGestureRecognizerDelegate>
- (void)addTopView;
- (void)addBottomView;
- (void)addGestureRecognizers;
- (void)rotateToOriginWithVelocity:(CGFloat)velocity;
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
- (CATransform3D)transform3D;
- (UIImage *)imageForSection:(LayerSection)section withImage:(UIImage *)image;
- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view;

@property(nonatomic) UIImage *image;
@property(nonatomic) CALayer *topView;
@property(nonatomic) CAGradientLayer *backGradientLayer;
@property(nonatomic)CALayer *bottomView;
@property(nonatomic) CAGradientLayer *bottomShadowLayer;
@property(nonatomic) CAGradientLayer *topShadowLayer;
@property(nonatomic) NSUInteger initialLocation;
@property(nonatomic)CALayer *superViewLayer;
@property(nonatomic)CATransformLayer *scaleNTranslationLayer;
@property(nonatomic)CGFloat angle;
@property(nonatomic)BOOL adjustRotationSpeed;
@property(nonatomic,strong)CALayer *imprintLayer1;
@property(nonatomic,strong)CALayer *imprintLayer2;
@property(nonatomic,strong)CALayer *backImageLayer;
@property(nonatomic,strong)UIImage *superViewImage;
@property(nonatomic,readwrite)UIPanGestureRecognizer *foldGestureRecognizer;
@property(nonatomic,strong)CALayer *avatarLayer;
@property(nonatomic,strong)CATextLayer *backTextLayer;
@property(nonatomic,strong)CATextLayer *backBottomTextLayer;

@end

@implementation FoldingView
-(void)dealloc{
    [self.foldGestureRecognizer setDelegate:nil];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _subclassView=[[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_subclassView];
        [self addGestureRecognizers];
        _adjustRotationSpeed=YES;
    }
    return self;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
-(CATransformLayer*)scaleNTranslationLayer{
    if (!_scaleNTranslationLayer) {
        _scaleNTranslationLayer=[CATransformLayer layer];
        _scaleNTranslationLayer.frame=self.bounds;
    }
    return _scaleNTranslationLayer;
}

- (void)updateBottomAndTopView {
    [self updateContentSnapshot:self afterScreenUpdate:YES];
    [self addTopView];
    [self addBottomView];
}
- (void)updateContentSnapshot:(UIView *)view afterScreenUpdate:(BOOL)update
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:update];
    self.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)captureSuperViewScreenShot:(UIView *)view afterScreenUpdate:(BOOL)update
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:update];
    self.superViewImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}
-(CALayer*)superViewLayer{
    if (!_superViewLayer) {
        _superViewLayer=[CALayer layer];
        _superViewLayer.frame=self.bounds;
    }
    return _superViewLayer;
}
-(CAGradientLayer*)topShadowLayer{
    if (!_topShadowLayer) {
        _topShadowLayer = [CAGradientLayer layer];
        _topShadowLayer.frame = self.topView.bounds;
        _topShadowLayer.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor blackColor].CGColor];
    }
    return _topShadowLayer;
}
- (void)addTopView
{
    [self.layer addSublayer:self.superViewLayer];
   [self.layer addSublayer:self.scaleNTranslationLayer];
    self.topView=[CALayer layer];
    self.topView.backgroundColor=[UIColor whiteColor].CGColor;
    self.topView.opaque=YES;
    self.topView.allowsEdgeAntialiasing=YES;
    self.topView.shadowColor=[UIColor whiteColor].CGColor;
    self.topView.shadowOpacity = 0.01f;
    self.topView.transform = [self transform3D];
    self.topView.contentsScale=[UIScreen mainScreen].scale;
    self.topView.frame=CGRectMake(0.0f,
                              0.0f,
                              CGRectGetWidth(self.scaleNTranslationLayer.bounds),
                              CGRectGetMidY(self.scaleNTranslationLayer.bounds));
    self.topView.anchorPoint = CGPointMake(0.5f, 1.0f);
    self.topView.position = CGPointMake(CGRectGetMidX(self.scaleNTranslationLayer.bounds), CGRectGetMidY(self.scaleNTranslationLayer.bounds));
    self.topShadowLayer.opacity = 0;
    self.backImageLayer.opacity=0.0;
    self.backGradientLayer.opacity = 0.0;
   [self.topView addSublayer:self.backImageLayer];
    //[self.backImageLayer addSublayer:self.backTextLayer];
    [self.backImageLayer addSublayer:self.backBottomTextLayer];
    //[self.backImageLayer addSublayer:self.avatarLayer];
    [self.backImageLayer addSublayer:self.backGradientLayer];

    [self.topView addSublayer:self.topShadowLayer];
    [self.scaleNTranslationLayer addSublayer:self.topView];
}

-(CALayer*)backImageLayer{
    if (!_backImageLayer) {
        _backImageLayer=[CALayer layer];
        _backImageLayer.frame=self.topView.bounds;
        _backImageLayer.contents=(__bridge id)[UIImage imageNamed:@"ad"].CGImage;
        //_backImageLayer.contentsGravity=kCAGravityResizeAspect;

        _backImageLayer.opaque=YES;
    }
    return _backImageLayer;
}
-(CAGradientLayer*)backGradientLayer{
    if (!_backGradientLayer) {
        _backGradientLayer=[CAGradientLayer layer];
        _backGradientLayer.frame=self.topView.bounds;
        UIColor *fluorescentColor=[UIColor colorWithRed:141/255.0f green:218/255.0f blue:247/255.0f alpha:0.0f];
        _backGradientLayer.colors=@[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)fluorescentColor.CGColor,(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)fluorescentColor.CGColor,(__bridge id)[UIColor clearColor].CGColor];
        _backGradientLayer.startPoint=CGPointMake(0, -0.5f);
        _backGradientLayer.endPoint=CGPointMake(1, 1);
    }
    return _backGradientLayer;
}
-(CATextLayer*)backTextLayer{
    if (!_backTextLayer) {
        NSString *text = @"Please help support this app by donating & leaving a review";
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f];
        CGRect textSize = [text boundingRectWithSize:CGSizeMake(self.backImageLayer.bounds.size.width-30, self.backImageLayer.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0] } context:nil];
        _backTextLayer=[CATextLayer layer];
        _backTextLayer.opacity=0.0;
        _backTextLayer.frame=CGRectMake((self.backImageLayer.bounds.size.width/2)-(textSize.size.width/2), self.backImageLayer.bounds.size.height - textSize.size.height- 15.0f, textSize.size.width,textSize.size.height);
        _backTextLayer.backgroundColor=[UIColor blackColor].CGColor;
        _backTextLayer.opaque=YES;
        _backTextLayer.foregroundColor=[UIColor whiteColor].CGColor;
        _backTextLayer.alignmentMode = kCAAlignmentCenter;
        _backTextLayer.wrapped=YES;
        _backTextLayer.contentsScale=[[UIScreen mainScreen] scale];
        _backTextLayer.allowsEdgeAntialiasing=YES;
        
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        _backTextLayer.font = fontRef;
        _backTextLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
        CATransform3D  rot = CATransform3DMakeRotation(M_PI, 1, 0, 0);
        _backTextLayer.transform=rot;
        _backTextLayer.string = text;
    }
    return _backTextLayer;
}


-(CATextLayer*)backBottomTextLayer{
    if (!_backBottomTextLayer) {
        NSString *text = @"@HakkaNews";
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        CGRect textSize = [text boundingRectWithSize:CGSizeMake(self.backImageLayer.bounds.size.width-30, self.backImageLayer.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : font } context:nil];
        _backBottomTextLayer=[CATextLayer layer];
        _backBottomTextLayer.opacity=0.0;
        _backBottomTextLayer.frame=CGRectMake(20, 20.0f, textSize.size.width,textSize.size.height);
        _backBottomTextLayer.backgroundColor=[UIColor clearColor].CGColor;
        _backBottomTextLayer.opaque=NO;
        _backBottomTextLayer.foregroundColor=[UIColor crimsonColor].CGColor;
        _backBottomTextLayer.alignmentMode = kCAAlignmentCenter;
        _backBottomTextLayer.wrapped=YES;
        _backBottomTextLayer.contentsScale=[[UIScreen mainScreen] scale];
        _backBottomTextLayer.allowsEdgeAntialiasing=YES;
        
        CFStringRef fontName = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontName);
        _backBottomTextLayer.font = fontRef;
        _backBottomTextLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
        CATransform3D  rot = CATransform3DMakeRotation(M_PI, 1, 0, 0);
        _backBottomTextLayer.transform=rot;
        _backBottomTextLayer.string = text;
    }
    return _backBottomTextLayer;
}
- (void)addBottomView
{
    self.bottomView=[CALayer layer];
    self.bottomView.backgroundColor=[UIColor blackColor].CGColor;
    self.bottomView.frame =CGRectMake(0.0f,
                                      CGRectGetMidY(self.scaleNTranslationLayer.bounds),
                                      CGRectGetWidth(self.scaleNTranslationLayer.bounds),
                                      CGRectGetMidY(self.scaleNTranslationLayer.bounds));
    self.bottomView.opaque=YES;
    self.bottomView.shadowColor=[UIColor blackColor].CGColor;
    self.bottomView.shadowOffset=CGSizeMake(0,0);
    self.bottomView.shadowOpacity =0.85f ;
    self.bottomView.shadowRadius = 25.0f;
    [self.bottomView addSublayer:self.imprintLayer1];
    [self.bottomView addSublayer:self.imprintLayer2];
    self.bottomShadowLayer.opacity = 0;
    [self.bottomView addSublayer:self.bottomShadowLayer];
    [self.scaleNTranslationLayer addSublayer:self.bottomView];
}
-(CALayer*)imprintLayer2{
    if (!_imprintLayer2) {
        _imprintLayer2=[CALayer layer];
        _imprintLayer2.frame=CGRectMake(0, self.bottomView.bounds.origin.y+1.7f, self.bottomView.bounds.size.width, 0.3f);
        _imprintLayer2.backgroundColor=[UIColor blackColor].CGColor;
        _imprintLayer2.opacity=0.03f;
    }
    return _imprintLayer2;
}
-(CALayer*)imprintLayer1{
    if (!_imprintLayer1) {
        _imprintLayer1=[CALayer layer];
        _imprintLayer1.frame=CGRectMake(0, self.bottomView.bounds.origin.y+0.6f, self.bottomView.bounds.size.width, 0.3f);
        _imprintLayer1.backgroundColor=[UIColor blackColor].CGColor;
        _imprintLayer1.opacity=0.06f;

    }
    return _imprintLayer1;
}
-(CAGradientLayer*)bottomShadowLayer{
    if (!_bottomShadowLayer) {
        _bottomShadowLayer = [CAGradientLayer layer];
        _bottomShadowLayer.frame = self.bottomView.bounds;
        _bottomShadowLayer.colors = @[(id)[UIColor blackColor].CGColor, (id)[UIColor clearColor].CGColor];
    }
    return _bottomShadowLayer;
}
- (void)addGestureRecognizers
{
    self.foldGestureRecognizer= [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];
    self.foldGestureRecognizer.delegate=self;
    [self addGestureRecognizer:self.foldGestureRecognizer];
}

- (void)createFoldLayers
{
    [self updateBottomAndTopView];
    self.superViewLayer.contents=(__bridge id)self.superViewImage.CGImage;
    UIImage *topImage = [self imageForSection:LayerSectionTop withImage:self.image];
    self.topView.contents = (__bridge id)(topImage.CGImage);
    //self.backImageLayer.contents=(__bridge id)([topImage applyDarkEffect].CGImage);
    self.backImageLayer.backgroundColor=[UIColor blackColor].CGColor;
    UIImage *bottomImage = [self imageForSection:LayerSectionBottom withImage:self.image];
    self.bottomView.contents = (__bridge id)(bottomImage.CGImage);
}
-(void)handlePanControl{
    //do not delete
    //method for subclass
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    CGPoint startingPoint=[recognizer translationInView:self];
    [self handlePanControl];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.y;
        [self createFoldLayers];
    }
    
    if ([[self.topView valueForKeyPath:@"transform.rotation.x"] floatValue] < -M_PI_2) {
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.backGradientLayer.opacity = 0.3f;
        self.backImageLayer.opacity=1.0f;
        self.backTextLayer.opacity=1.0f;
        self.backBottomTextLayer.opacity=1.0f;
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        [CATransaction commit];
    } else {
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.backGradientLayer.opacity = 0.0f;
        self.backImageLayer.opacity=0.0f;
        self.backTextLayer.opacity=0.0f;
        self.backBottomTextLayer.opacity=0.0f;
        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        self.bottomShadowLayer.opacity = opacity;
        self.topShadowLayer.opacity = opacity;
        [CATransaction commit];
    }
    
    if ([self isLocation:location inView:self]) {
        CGFloat angle=(-([[self.topView valueForKeyPath:@"transform.rotation.x"]floatValue]*(180/M_PI)));
        [self animateViewWithRotation:angle translation:startingPoint.x verticalPoint:location.y];
        [self.bottomView setShadowPath:[UIBezierPath bezierPathWithRect:CGRectMake(self.bottomView.bounds.origin.x, self.bottomView.bounds.origin.y+50, self.bottomView.bounds.size.width, self.bottomView.bounds.size.height-50)].CGPath];
        CGFloat shineGradientFactor=angle*0.02071429f;
        [CATransaction begin];
        [CATransaction setValue:@0.016f forKey:kCATransactionAnimationDuration];
        self.backGradientLayer.locations=@[[NSNumber numberWithFloat:-2.45f+shineGradientFactor],[NSNumber numberWithFloat:-2.4f+shineGradientFactor],[NSNumber numberWithFloat:-2.34f+shineGradientFactor],[NSNumber numberWithFloat:-2.09f+shineGradientFactor],[NSNumber numberWithFloat:-2.05f+shineGradientFactor],[NSNumber numberWithFloat:-2.0f+shineGradientFactor]];
        [CATransaction commit];

}
    else {
        recognizer.enabled = NO;
        recognizer.enabled = YES;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat angle=(-([[self.topView valueForKeyPath:@"transform.rotation.x"]floatValue]*(180.0f/M_PI)));

        if (angle < 45.0f){
        [self rotateToOriginWithVelocity:0.f];
        [self rescaleLayer];
        recognizer.enabled=NO;}
        else{
            [self closeWithVelocity:0.0f];
            
        }
    }
}

-(void)animateViewWithRotation:(CGFloat)angle translation:(CGFloat)startingpoint verticalPoint:(CGFloat)verticalPoint{
    POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
    POPBasicAnimation *scaleAnimation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    POPBasicAnimation *translateAnimation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerTranslationX];
    CGFloat rotationAngle;
    CGFloat hypotenuse=self.bounds.size.height/2.0f;
    CGFloat adjacent=ABS(hypotenuse-verticalPoint);
    CGFloat nonadjustedAngle= -(acos(adjacent/hypotenuse));
    if (verticalPoint >(self.center.y)){
        rotationAngle=-M_PI-nonadjustedAngle;
}
    else{
        rotationAngle=nonadjustedAngle;
    }
    const CGFloat scaleConversionFactor= 1.0f-(angle/650.0f);
    const CGFloat maxScaleAngle=90.0f;
    const CGFloat maxDownScaleConversionFactor= 1.0f-(maxScaleAngle/650.0f);
    
    translateAnimation.toValue=@(startingpoint);
    translateAnimation.duration=0.01f;
    scaleAnimation.duration=0.01f;
    if (angle > 0.0f  && angle <= maxScaleAngle) {
        scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(scaleConversionFactor,scaleConversionFactor)];
    }
    else if (angle > maxScaleAngle){
        scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(maxDownScaleConversionFactor, maxDownScaleConversionFactor)];
    }
    else{
        scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    }
    if (self.adjustRotationSpeed) {
    rotationAnimation.duration=(-rotationAngle*(180.0f/M_PI))/1400.0f;
    }
    else{
        rotationAnimation.duration=0.01f;
    }
    [rotationAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            self.adjustRotationSpeed=NO;
        }
    }];
    rotationAnimation.toValue = @(rotationAngle);
    [self.scaleNTranslationLayer pop_addAnimation:translateAnimation forKey:@"translateAnimation"];
    [self.topView pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [self.scaleNTranslationLayer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
}
-(void)rescaleLayer{
    
    const CGFloat scaleConversionFactor= 1.0f-(self.angle/650.0f);
    const CGFloat maxScaleAngle=90.0f;
    const CGFloat maxDownScaleConversionFactor= 1-(maxScaleAngle/650.0f);
    POPSpringAnimation *scaleAnimation=[POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    POPSpringAnimation *translateAnimation=[POPSpringAnimation animationWithPropertyNamed:kPOPLayerTranslationX];
    translateAnimation.toValue=@(0.0f);
    
    if (self.angle > 0.0f  && self.angle <= maxScaleAngle) {
        scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(scaleConversionFactor, scaleConversionFactor)];
    }
    else if (self.angle > maxScaleAngle){
        scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(maxDownScaleConversionFactor, maxDownScaleConversionFactor)];
    }
    else{
        scaleAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    }
    [self.scaleNTranslationLayer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [self.scaleNTranslationLayer pop_addAnimation:translateAnimation forKey:@"translateAnimation"];
}

-(void)closeWithVelocity:(CGFloat)velocity{
    POPSpringAnimation *rotateToCloseAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
    POPBasicAnimation *scaleToCloseAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleToCloseAnimation.toValue=[NSValue valueWithCGSize:CGSizeMake(0.0f, 0.0f)];
    scaleToCloseAnimation.duration=0.4f;
    if (velocity > 0.0f) {
        rotateToCloseAnimation.velocity = @(velocity);
    }
    rotateToCloseAnimation.springBounciness = 0.0f;
    rotateToCloseAnimation.dynamicsMass = 2.0f;
    rotateToCloseAnimation.dynamicsTension = 200.0f;
    rotateToCloseAnimation.toValue = @(-M_PI);
    rotateToCloseAnimation.delegate = self;
    [scaleToCloseAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(foldingViewHasClosed)]) {
                [self.delegate foldingViewHasClosed];
            }
            [self removeFromSuperview];
        }
    }];
    [self.topView pop_addAnimation:rotateToCloseAnimation forKey:@"rotationToCloseAnimation"];
    [self.scaleNTranslationLayer pop_addAnimation:scaleToCloseAnimation forKey:@"scaleToCloseAnimation"];
}
-(void)rotateToOriginCompletionBlockMethod{
    
}
- (void)rotateToOriginWithVelocity:(CGFloat)velocity
{
    POPSpringAnimation *rotationAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
    POPBasicAnimation *imprintLayerAnimation=[POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    imprintLayerAnimation.toValue=@(0);
    imprintLayerAnimation.duration=0.04f;
   [self.imprintLayer1 pop_addAnimation:imprintLayerAnimation forKey:nil];
    [self.imprintLayer2 pop_addAnimation:imprintLayerAnimation forKey:nil];
    [imprintLayerAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished){
            self.imprintLayer1=nil;
            self.imprintLayer2=nil;
            self.bottomView.shadowOpacity=0.0f;
        }
    }];
    [rotationAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        if (finished) {
        [self.superViewLayer removeFromSuperlayer];
        [self.topView removeFromSuperlayer];
        [self.bottomView removeFromSuperlayer];
        [self rotateToOriginCompletionBlockMethod];
        self.foldGestureRecognizer.enabled=YES;
        self.adjustRotationSpeed=YES;
           
        }
    }];
     if (velocity > 0.0f) {
        rotationAnimation.velocity = @(velocity);
    }
    rotationAnimation.springBounciness = 0.0f;
    rotationAnimation.dynamicsMass = 2.0f;
    rotationAnimation.dynamicsTension = 200.0f;
    rotationAnimation.toValue = @(0.0f);
    rotationAnimation.delegate = self;
    [self.topView pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
- (CATransform3D)transform3D
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5f / -4600.0f;
    return transform;
}

- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view
{
    if ((location.x > 0 && location.x < CGRectGetWidth(self.bounds)) &&
        (location.y > 0 && location.y < CGRectGetHeight(self.bounds))) {
        return YES;
    }
    return NO;
}

- (UIImage *)imageForSection:(LayerSection)section withImage:(UIImage *)image
{
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width*[UIScreen mainScreen].scale, image.size.height*([UIScreen mainScreen].scale/2));
    if (section == LayerSectionBottom) {
        rect.origin.y =image.size.height*([UIScreen mainScreen].scale/2.0f);
    }
    
    CGImageRef imgRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    UIImage *imagePart = [UIImage imageWithCGImage:imgRef scale:[UIScreen mainScreen].scale orientation:image.imageOrientation];
    CGImageRelease(imgRef);
    
    return imagePart;
}
#pragma mark - POPAnimationDelegate

- (void)pop_animationDidApply:(POPAnimation *)anim
{
    self.angle=(-([[self.topView valueForKeyPath:@"transform.rotation.x"]floatValue]*(180.0f/M_PI)));
    if (self.angle > 90.0f){
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.backImageLayer.opacity=1.0f;
        
        [CATransaction commit];

        
    }else{
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.backImageLayer.opacity=0.0f;
        [CATransaction commit];
        
    }
}

@end