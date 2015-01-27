//
//  Grid.m
//  GameOfLife
//
//  Created by Maria Luisa on 1/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Grid.h"
#import "Creature.h"

// These are variables that cannot be changed
static const int GRID_ROWS = 8;
static const int GRID_COLUMNS = 10;

@implementation Grid

NSMutableArray * _gridArray;
float _cellWidth;
float _cellHeight;

-(void) onEnter {
    [super onEnter];
    
    [self setupGrid];
    
    // Accept touches on the grid
    self.userInteractionEnabled = YES;
}

-(void) setupGrid {
    // Divide the grid's size by the number of columns/rows to figure out the right width and height of each cell
    _cellWidth = self.contentSize.width / GRID_COLUMNS;
    _cellHeight = self.contentSize.height / GRID_ROWS;
    
    float x = 0;
    float y = 0;
    
    // Initialize the array as a blank NSMutableArray
    _gridArray = [NSMutableArray array];
    
    // Initialize Creatures
    for (int i = 0; i < GRID_ROWS; i++) {
        // This is how you create two dimensional arrays in Objective-C. You put arrays into arrays
        _gridArray[i] = [NSMutableArray array];
        x = 0;
        
        for (int j = 0; j < GRID_COLUMNS; j++) {
            Creature *creature = [[Creature alloc] initCreature];
            creature.anchorPoint = ccp(0, 0);
            creature.position = ccp(x, y);
            [self addChild:creature];
            
            // This is shothand to access an array inside an array
            _gridArray[i][j] = creature;
            
            // Make creatures visible to test this method, remove this once we know we have filled the grid properly
            //creature.isAlive = YES;
            
            x += _cellWidth;
        }
        
        y += _cellHeight;
    }
}

- (void) touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    // Get the x, y coordinates fo the touch
    CGPoint touchLocation = [touch locationInNode:self];
    
    // Get the Creature at that location
    Creature *creature = [self creatureForTouchPosition:touchLocation];
    
    // Invert it's state - kill it if it's alive, bring it to life if it's dead
    creature.isAlive = !creature.isAlive;
}

-(Creature *) creatureForTouchPosition:(CGPoint)touchPosition {
    // Get the row and column that was touched, return the Creature inside the corresponding cell
    int row = touchPosition.y / _cellHeight;
    int column = touchPosition.x / _cellWidth;
    
    return _gridArray[row][column];
}

@end
