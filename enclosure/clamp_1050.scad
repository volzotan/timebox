include <camera.scad>;

size = [80, 43, 11]; // only clamp

fins = [[4, 1.4], [0.4, 4], [4, 4]];

tol2 = 0.45;

offset_screw = 11;

// translate([-165/2+40, 10, -1]) color("green") difference() {
//     cube([165, 48, 99]);
//     translate([1, -1, 1]) cube([165-2, 48, 99-2]);
// }
// translate([115, 10, 13]) rotate([0, 0, 180]) camera();

//translate([0, 0, 0]) clamp();
//translate([0, 0, -10]) angle_corrector();
//translate([0, 50, 0]) plate();
//translate([20, 14, 1.5]) rotate([0, -90, 0]) pressure_nose();

//clamp();
//translate([0, size[1], 5]) rotate([180, 0, 0]) angle_corrector();
//translate([0, size[1], 6]) rotate([180, 0, 0]) plate();
//pressure_nose();

translate([0, 0, 0]) clamp();
translate([0, 0, -5]) angle_corrector();
translate([80, 3, -7]) rotate([180, 0, 180]) plate();
translate([100, 0, 0]) pressure_nose();


module angle_corrector() {
    intersection() {
    difference() {
        translate([0, 0, 0]) cube([80, 43, 4.3]);
        translate([size[0]+1, size[1]+.01, -.01]) rotate([0, 0, 180]) cutter(3.8, length=82); 

        dist    = 7;
        offset  = 3;
        translate([0, 0, -1]) {
            translate([dist, dist+offset]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, dist+offset]) cylinder($fn=32, h=12, d=5.3);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
        }
    }
    
    block(size[2]+10);
    }
}

module plate() {
    size = [80, 40, 5.5];

    difference() {
        intersection() {
            union() {

                points_cube = [[0, 0], [size[1], 0], [size[1], size[2]-1], [size[1]-1, size[2]], [1, size[2]], [0, size[2]-1]];
                translate([0, , 0]) rotate([90, 0, 90]) linear_extrude(height=size[0]) polygon(points_cube);

                intersection() {
                    translate([-1, size[1]+2, 0]) rotate([180, 0, 0]) cutter(3.0, length=82); 
                    translate([0, 0, -size[2]]) cube(size);
                }
            }    
            translate([0, 0, -10]) block(20, size=size);
        }
        
        dist = 7;
        translate([0, 0, -10]) {
            translate([dist, dist]) cylinder($fn=32, h=22, d=5.3);
            translate([size[0]-dist, dist]) cylinder($fn=32, h=22, d=5.3);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=22, d=5.3);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=22, d=5.3);
        }
        translate([0, 0, 1.5]) {
            translate([dist, dist]) cylinder($fn=32, h=12, d=9);
            translate([size[0]-dist, dist]) cylinder($fn=32, h=12, d=9);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=9);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=9);
        }
        translate([size[0]/2, size[1]/2, -10]) cylinder($fn=32, h=22, d=7);
        translate([size[0]/2, size[1]/2, -10]) cylinder($fn=6, h=10+6+1-2-0.5, d=13.15);  // +1 safety margin for long fastening screws
    }
}

module clamp() {
    difference() {
        union() {
            difference() {
                intersection() {
                    union() {
                        points_cube = [ [0, 0], 
                                        [size[1], 0], 
                                        [size[1], size[2]-1], 
                                        [size[1]-1, size[2]], 
                                        [1, size[2]], 
                                        [0, size[2]-1]];
                        //translate([0, , 0]) rotate([90, 0, 90]) linear_extrude(height=size[0]) polygon(points_cube);
                    
                        hull() {
                            block(.1);
                            translate([0, 0, 10.5-.1]) block(.1);
                            translate([0, 0, 11-.1]) block(.1, red=0.5);
                        }
                        
                        points = [  [0, 0], 
                                    [14, 0], 
                                    [14, size[2]], 
                                    [14-1, size[2]+1], 
                                    [1, size[2]+1], 
                                    [0, size[2]]];
                        //translate([0, 5+offset_screw, 0]) rotate([90, 0, 90]) linear_extrude(height=30) polygon(points);
                    }
                    
                    block(size[2]+10);
                }
                        
                tol = 0.2;
                translate([17-tol, -2, 2]) color("red") cube([40+2*tol, 40+tol, 10]);
                
                dist    = 7;
                offset  = 3;
                translate([0, 0, -1]) {
                    translate([dist, dist+offset]) cylinder($fn=32, h=12, d=5.3);
                    translate([size[0]-dist, dist+offset]) cylinder($fn=32, h=12, d=5.3);
                    translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
                    translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
                }
                translate([0, 0, 3.5]) {
                    translate([dist, dist+offset]) cylinder($fn=6, h=12, d=9.6);
                    translate([size[0]-dist, dist+offset]) cylinder($fn=6, h=12, d=9.6);
                    translate([dist, size[1]-dist]) cylinder($fn=6, h=12, d=9.6);
                    translate([size[0]-dist, size[1]-dist]) cylinder($fn=6, h=12, d=9.6);
                }
            }
     
            difference() {
                union() {
                    translate([17+40-4+0.2, 40, 2.2]) rotate([90, 0, 0]) color("blue") linear_extrude(height=40) polygon(fins);
                    translate([17+4-0.2, 0, 2.2]) rotate([90, 0, 180]) color("blue") linear_extrude(height=40) polygon(fins);
                }
                points_cutter = [[0, 0], [4, 0], [0, 4]];
                translate([53+0.2, 0, 2]) rotate([0, 0, 0]) color("green") linear_extrude(height=10) polygon(points_cutter);
                translate([21-0.2, 0, 2]) rotate([0, 0, 90]) color("green") linear_extrude(height=10) polygon(points_cutter);
            }
        }

        translate([0, offset_screw, 0]) {
            translate([-1, 12, 5.5]) rotate([0, 90, 0]) cylinder($fn=32, h=40, d=5.3);
            translate([-8.0, 12, 5.5]) rotate([0, 90, 0]) cylinder($fn=32, h=10.5, d=9);
                
            // translate([10, 15.75, 1.6]) cube([3, 8.3, 9]); // square nut
            translate([4.8, 7.85, 1.1]) cube([4.2, 8.3, 10]); // normal M5 nut

            // pressure nose
            points = [  [0, 0], 
                                [18, 0], 
                                [18, 4+1+0.2], 
                                [18-2, 6+1],
                                [18-2, 8+2],
                                [18-3, 9+2],
                                [3, 9+2], 
                                [2, 8+2],  
                                [2, 6+1],  
                                [0, 4+1+0.2], 
                                ];
            translate([11, 3, 1.0]) rotate([90, 0, 90]) linear_extrude(height=12) polygon(points);
        }
    }
}

module pressure_nose() {
   translate([0, 0, 5.2]) rotate([0, 90, 0]) {
       
        bottom_height = 2;
        height = 5.2;
        
        difference() {
            // body
            points = [  [tol2, 0], 
                        [18-tol2, 0],   
                        [18-tol2, size[2]-bottom_height-5], 
                        [18-2-tol2, size[2]-bottom_height-3],
                        [18-2-tol2, size[2]-bottom_height], 
                        [18-3, size[2]+1-tol2-bottom_height], 
                        [1, size[2]+1-tol2-bottom_height], 
                        [0, size[2]+1-tol2-bottom_height-3],
                        [-2, size[2]+1-tol2-bottom_height-5], 
                        [0+tol2, size[2]-bottom_height]];
            points = [  [tol2, 0], 
                        [18-tol2, 0], 
                        [18-tol2, 4-tol2+1], 
                        [18-2-tol2, 6-tol2+1],
                        [18-2-tol2, 8-tol2+1],
                        [18-3-tol2, 9-tol2+1],
                        [3+tol2, 9-tol2+1], 
                        [2+tol2, 8-tol2+1],  
                        [2+tol2, 6-tol2+1],  
                        [tol2, 4-tol2+1], 
                        ];
            translate([0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=height) polygon(points);
                              
            // screw hole
            translate([-1, 9, 1+5.5-bottom_height-tol2]) rotate([0, 90, 0]) cylinder($fn=32, h=1.5, d=5.4);    
        }   
    }
}

module block(height, size=size, red=0) {
    crad = 2;
    hull() {
        translate([crad+red, crad+red]) cylinder($fn=32, h=height, r=crad);
        translate([size[0]-crad-red, crad+red]) cylinder($fn=32, h=height, r=crad);
        translate([crad+red, size[1]-crad-red]) cylinder($fn=32, h=height, r=crad);
        translate([size[0]-crad-red, size[1]-crad-red]) cylinder($fn=32, h=height, r=crad);
    }
}

module cutter(height, length=100) {
    points = [[0, 0], [48, 0], [0, height]];
    rotate([90, 0, 90]) color("red") linear_extrude(height=length) polygon(points);
}