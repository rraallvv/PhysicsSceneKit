//
//  GameViewController.m
//  PhysicsSceneKit
//
//  Created by Rhody Lugo on 2/22/15.
//  Copyright (c) 2015 Rhody Lugo. All rights reserved.
//

#import "GameViewController.h"
#import <GLKit/GLKit.h>

#define RPM_TO_RADS(x)	(x*2.0f*M_PI/60.0f)
#define str(s)	#s

@implementation GameViewController {
	SCNScene *_scene;
	SCNMaterial *_material;
	CADisplayLink *_displayLink;
	SCNPhysicsBody *_containerBody;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Create a new scene
	_scene = [SCNScene scene];

	// Create and add a camera to the scene
	SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.camera.yFov = 68.0;
	[_scene.rootNode addChildNode:cameraNode];

	// Place the camera
	cameraNode.position = SCNVector3Make(0.0f, 0.0f, 40.0f);

	// Create and add a light
	SCNNode *lightNode = [SCNNode node];
	lightNode.light = [SCNLight light];
	lightNode.light.color = [UIColor redColor];
	lightNode.light.type = SCNLightTypeDirectional;
	[_scene.rootNode addChildNode:lightNode];

	// Rotate the light
	lightNode.eulerAngles = SCNVector3Make(-45.0f, 0.0f, 0.0f);

	// Create a material
	_material = [SCNMaterial material];
	_material.diffuse.contents = [UIColor whiteColor];
	_material.specular.contents = [UIColor whiteColor];
	_material.specular.intensity = 0.2;
	_material.locksAmbientWithDiffuse = YES;

	// Add the geometry and physics bodies
	[self addContainerAtPosition:SCNVector3Make(0.0f, 0.0f, 0.0f)];

	[self addBoxesAtPosition:SCNVector3Make(-4.5f, 0.0f, 0.0f)];
	[self addBoxesAtPosition:SCNVector3Make(4.5f, 0.0f, 0.0f)];

	// retrieve the SCNView
	SCNView *scnView = (SCNView *)self.view;

	// Set the scene to the view
	scnView.scene = _scene;

	// Allows the user to manipulate the camera
	scnView.allowsCameraControl = YES;

	// Show statistics such as fps and timing information
	scnView.showsStatistics = YES;
	
	// Configure the view
	scnView.backgroundColor = [UIColor colorWithRed:0.65f green:0.65f blue:0.65f alpha:1.0f];

	// Start updating the scene
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	_displayLink.frameInterval = 1;
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize {
	// retrieve the SCNView
	SCNView *scnView = (SCNView *)self.view;

	// check what nodes are tapped
	CGPoint p = [gestureRecognize locationInView:scnView];
	NSArray *hitResults = [scnView hitTest:p options:nil];

	// check that we clicked on at least one object
	if([hitResults count] > 0){
		// retrieved the first clicked object
		SCNHitTestResult *result = [hitResults objectAtIndex:0];

		// get its material
		SCNMaterial *material = result.node.geometry.firstMaterial;

		// highlight it
		[SCNTransaction begin];
		[SCNTransaction setAnimationDuration:0.5];

		// on completion - unhighlight
		[SCNTransaction setCompletionBlock:^{
			[SCNTransaction begin];
			[SCNTransaction setAnimationDuration:0.5];

			material.emission.contents = [UIColor blackColor];

			[SCNTransaction commit];
		}];

		material.emission.contents = [UIColor redColor];

		[SCNTransaction commit];
	}
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskAllButUpsideDown;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)addBoxesAtPosition:(SCNVector3)position {
	// Add box nodes to the scene
	for (int i=0; i<3; ++i) {
		for (int j=0; j<3; ++j) {
			for (int k=0; k<3; ++k) {
				SCNNode *node = [SCNNode node];
				CGFloat rdx = 3*(i - 1) + position.x;
				CGFloat rdy = 3*(j - 1) + position.y;
				CGFloat rdz = 3*(k - 1) + position.z;
				node.position = SCNVector3Make(rdx, rdy, rdz);
				SCNBox *box = [SCNBox boxWithWidth:2.0f height:2.0f length:2.0f chamferRadius:0.0f];
				node.geometry = box;

				// Set the material to the 3D object geometry
				node.geometry.firstMaterial = _material;

				SCNPhysicsShape *boxShape = [SCNPhysicsShape shapeWithGeometry:box options:nil];
				SCNPhysicsBody *boxBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:boxShape];
				boxBody.mass = 0.01f;

				node.physicsBody = boxBody;
				[_scene.rootNode addChildNode:node];
			}
		}
	}
}

- (void)addContainerAtPosition:(SCNVector3)position {

	// Create the geometry in container's walls

	SCNBox *boxA = [SCNBox boxWithWidth:22.0f height:2.0f length:22.0f chamferRadius:0.0f];

	SCNNode *node1 = [SCNNode node];
	node1.position = SCNVector3Make(0.0f, -10.0f, 0.0f);
	node1.geometry = boxA;
	node1.geometry.firstMaterial = _material;

	SCNNode *node2 = [SCNNode node];
	node2.position = SCNVector3Make(0.0f, 10.0f, 0.0f);
	node2.geometry = boxA;
	node2.geometry.firstMaterial = _material;



	SCNBox *boxB = [SCNBox boxWithWidth:2.0f height:22.0f length:22.0f chamferRadius:0.0f];

	SCNNode *node3 = [SCNNode node];
	node3.position = SCNVector3Make(-10.0f, 0.0f, 0.0f);
	node3.geometry = boxB;
	node3.geometry.firstMaterial = _material;

	SCNNode *node4 = [SCNNode node];
	node4.position = SCNVector3Make(10.0f, 0.0f, 0.0f);
	node4.geometry = boxB;
	node4.geometry.firstMaterial = _material;



	SCNNode *containerNode = [SCNNode node];
	containerNode.position = position;
	[containerNode addChildNode:node1];
	[containerNode addChildNode:node2];
	[containerNode addChildNode:node3];
	[containerNode addChildNode:node4];


	// Create the physics bodies in the container

	SCNBox *boxC = [SCNBox boxWithWidth:22.0f height:22.0f length:2.0f chamferRadius:0.0f];

	SCNPhysicsShape *boxShapeA = [SCNPhysicsShape shapeWithGeometry:boxA options:nil];

	SCNPhysicsShape *boxShapeB = [SCNPhysicsShape shapeWithGeometry:boxB options:nil];

	SCNPhysicsShape *boxShapeC = [SCNPhysicsShape shapeWithGeometry:boxC options:nil];

	SCNPhysicsShape *containerShape = [SCNPhysicsShape shapeWithShapes:@[boxShapeA, boxShapeA, boxShapeB, boxShapeB, boxShapeC, boxShapeC]
												   transforms:@[[NSValue valueWithSCNMatrix4:SCNMatrix4MakeTranslation(0.0f, -10.0f, 0.0f)],
																[NSValue valueWithSCNMatrix4:SCNMatrix4MakeTranslation(0.0f, 10.0f, 0.0f)],
																[NSValue valueWithSCNMatrix4:SCNMatrix4MakeTranslation(-10.0f, 0.0f, 0.0f)],
																[NSValue valueWithSCNMatrix4:SCNMatrix4MakeTranslation(10.0f, 0.0f, 0.0f)],
																[NSValue valueWithSCNMatrix4:SCNMatrix4MakeTranslation(0.0f, 0.0f, -10.0f)],
																[NSValue valueWithSCNMatrix4:SCNMatrix4MakeTranslation(0.0f, 0.0f, 10.0f)]]];

	_containerBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:containerShape];
	_containerBody.mass = 1.0f;


	// Attach the physcis body to the container geometry
	containerNode.physicsBody = _containerBody;
	[_scene.rootNode addChildNode:containerNode];


	// Create and attach the hinge joint to the container
	SCNPhysicsHingeJoint *joint = [SCNPhysicsHingeJoint jointWithBody:_containerBody axis:SCNVector3Make(0.0f, 0.0f, 1.0f) anchor:SCNVector3Make(0.0f, 0.0f, 0.0f)];

	[_scene.physicsWorld addBehavior:joint];
}

- (void)update {
	[_containerBody setAngularVelocity:SCNVector4Make(0.0f, 0.0f, 1.0f, -RPM_TO_RADS(2))];
}

- (void)dealloc {
	[_displayLink invalidate];
}

@end
