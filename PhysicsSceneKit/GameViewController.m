//
//  GameViewController.m
//  PhysicsSceneKit
//
//  Created by Rhody Lugo on 2/22/15.
//  Copyright (c) 2015 Rhody Lugo. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController {
	SCNScene *_scene;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Create a new scene
	_scene = [SCNScene scene];

	// Create and add a camera t the scene
   SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
	cameraNode.camera.yFov = 60.0f;
    [_scene.rootNode addChildNode:cameraNode];

    // place the camera
	cameraNode.position = SCNVector3Make(0.0f, 0.0f, 40.0f);

	// Make floor node
	SCNNode *floorNode = [SCNNode node];

	SCNFloor *floor = [SCNFloor floor];
	floor.reflectivity = 0.25;
	floorNode.geometry = floor;
	floorNode.position = SCNVector3Make(0, -10, 0);

	// Floor Physics
	SCNPhysicsShape *floorShape = [SCNPhysicsShape shapeWithGeometry: floor options: nil];
	SCNPhysicsBody *floorBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeStatic shape:floorShape];

	floorNode.physicsBody = floorBody;

	[_scene.rootNode addChildNode:floorNode];

	[self addBoxesAtPosition:SCNVector3Make(-4.5f, 0.0f, 0.0f)];
	[self addBoxesAtPosition:SCNVector3Make(+4.5f, 0.0f, 0.0f)];

    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;

	// Set the scene to the view
	scnView.scene = _scene;

	// Allows the user to manipulate the camera
	scnView.allowsCameraControl = YES;

	// Show statistics such as fps and timing information
	scnView.showsStatistics = YES;

	// Configure the view
	scnView.backgroundColor = [UIColor blackColor];
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
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

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)addBoxesAtPosition:(SCNVector3)position
{
	// Add box nodes to the scene
	for (int i=0; i<3; ++i)
	{
		for (int j=0; j<3; ++j)
		{
			for (int k=0; k<3; ++k)
			{
				SCNNode *node = [SCNNode node];
				CGFloat rdx = 3*(i - 1) + position.x;
				CGFloat rdy = 3*(j - 1) + position.y;
				CGFloat rdz = 3*(k - 1) + position.z;
				node.position = SCNVector3Make(rdx, rdy, rdz);
				SCNBox *box = [SCNBox boxWithWidth:2.0 height:2.0 length:2.0 chamferRadius:0.0];
				node.geometry = box;

				// Create and configure a material
				SCNMaterial *material = [SCNMaterial material];
				material.diffuse.contents = [UIColor blueColor];
				material.specular.contents = [UIColor blueColor];
				material.locksAmbientWithDiffuse = true;

				// Set shaderModifiers properties
				material.shaderModifiers = @{SCNShaderModifierEntryPointSurface : @"\n"
											 "float flakeSize = sin(u_time * 0.2);\n"
											 "float flakeIntensity = 0.7;\n"
											 "vec3 paintColor0 = vec3(0.9, 0.4, 0.3);\n"
											 "vec3 paintColor1 = vec3(0.9, 0.75, 0.2);\n"
											 "vec3 flakeColor = vec3(flakeIntensity, flakeIntensity, flakeIntensity);\n"
											 "vec3 rnd = vec3(0.5);\n"
											 "vec3 nrm1 = normalize(0.05 * rnd + 0.95 * _surface.normal);\n"
											 "vec3 nrm2 = normalize(0.3 * rnd + 0.4 * _surface.normal);\n"
											 "float fresnel1 = clamp(dot(nrm1, _surface.view), 0.0, 1.0);\n"
											 "float fresnel2 = clamp(dot(nrm2, _surface.view), 0.0, 1.0);\n"
											 "vec3 col = mix(paintColor0, paintColor1, fresnel1);\n"
											 "col += pow(fresnel2, 106.0) * flakeColor;\n"
											 "_surface.normal = nrm1;\n"
											 "_surface.diffuse = vec4(col.r,col.b,col.g, 1.0);\n"
											 "_surface.emission = (_surface.reflective * _surface.reflective) * 2.0;\n"
											 "_surface.reflective = vec4(0.0);\n"};

				// Set the material to the 3D object geometry
				node.geometry.firstMaterial = material;

				SCNPhysicsShape *boxShape = [SCNPhysicsShape shapeWithGeometry:box options:nil];
				SCNPhysicsBody *boxBody = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeDynamic shape:boxShape];

				node.physicsBody = boxBody;
				[_scene.rootNode addChildNode:node];
			}
		}
	}
}

@end
