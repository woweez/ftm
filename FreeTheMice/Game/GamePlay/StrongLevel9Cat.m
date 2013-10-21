//
//  StrongLevel9Cat.m
//  FreeTheMice
//
//  Created by Muhammad Kamran on 10/16/13.
//
//

#import "StrongLevel9Cat.h"

@implementation StrongLevel9Cat

- (id)init
{
    self = [super init];
    if (self) {
        catYPos = 298;
        moveXend = 810;
        moveXstart = 230;
    }
    return self;
}

-(void) runCurrentSequence{
    
    catSprite.position = ccp(moveXstart, catYPos);
    catSprite.flipX = 0;
    CCMoveTo *rightMove = [self getMoveRightAction:CGPointMake(moveXstart, catYPos) endPoint:CGPointMake(moveXend, catYPos)];
    CCMoveTo *leftMove = [self getMoveRightAction:CGPointMake(moveXend, catYPos) endPoint:CGPointMake(moveXstart, catYPos)];
    CCCallFuncN *flip1 = [CCCallFuncN actionWithTarget:self selector:@selector(flipLeft:)];
    CCCallFuncN *flip2 = [CCCallFuncN actionWithTarget:self selector:@selector(flipRight:)];
    CCAnimate *turn = [self getTurningAction];
    CCCallFuncN *afterMoveLeftOrRight = [CCCallFuncN actionWithTarget:self selector:@selector(afterLeft:)];
    CCSequence *sequence = [CCSequence actions: rightMove, afterMoveLeftOrRight, turn,flip1, leftMove, afterMoveLeftOrRight,turn, flip2, nil];
    
    sequence.tag = 15;
    [catSprite runAction:[CCRepeatForever actionWithAction:sequence]];
    [self applyRunningAnimation];
}

@end
