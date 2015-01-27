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

-(void) evolveStep {
    // Update each Creature's neighbor count
    [self countNeighbors];
    
    // Update each Creature's state
    [self updateCreatures];
    
    // Update the generation so the lable's text will display the correct generation
    _generation++;
}

-(void) countNeighbors {
    // Iterate through the rows
    // Note that NSArray has a method 'count' that will return the number of elements in the array
    for (int i = 0; i < [_gridArray count]; i++) {
        // Iterate through all the columns for a given row
        for (int j = 0; j < [_gridArray[i] count]; j++) {
            // Access the creature in the cell that corresponds to the curret row/column
            Creature * currentCreature = _gridArray[i][j];
            
            // Remember that every creature has a 'livingNeighbors' property that we created earlier
            currentCreature.livingNeighbors = 0;
            
            // Now examine every cell around the current one
            
            // Go through the row on top of the current cell, te row the cell is in, and the row past the current cell
            for (int x = (i-1); x <= (i+1); x++) {
                // Go through the column to the left of the current cell, the column the cell is in, and the column to the right of the current cell
                for (int y = (j-1); y <= (j+1); y++) {
                    // Check that the cell we're checking isn't off the screen
                    BOOL isIndexValid;
                    isIndexValid = [self isIndexValidForX: x andY:y];
                    
                    // Skip over all cells that are off screen AND the cell that contains the creature we are currently updating
                    if ( !((x == i) && (y == j)) && isIndexValid) {
                        Creature *neighbor = _gridArray[x][y];
                        if (neighbor.isAlive) {
                            currentCreature.livingNeighbors += 1;
                        }
                    }
                }
            }
        }
    }
}

-(BOOL) isIndexValidForX:(int)x andY:(int)y {
    BOOL isIndexValid = YES;
    if (x < 0 || y < 0 || x >= GRID_ROWS || y >= GRID_COLUMNS) {
        isIndexValid = NO;
    }
    return isIndexValid;
}

-(void) updateCreatures {
    
    int numAlive = 0;
    
    for (int i = 0; i < [_gridArray count]; i++) {
        for (int j = 0; j < [_gridArray[i] count]; j++) {
            Creature * currentCreature = _gridArray[i][j];
        
            NSInteger neighbors = currentCreature.livingNeighbors;
            
            if (neighbors == 3) {
                currentCreature.isAlive = YES;
            } else if (neighbors <= 1 || neighbors >= 4) {
                currentCreature.isAlive = NO;
            }
            
            if (currentCreature.isAlive) {
                numAlive += 1;
            }
        }
    }
    
    _totalAlive = numAlive;
}

@end
