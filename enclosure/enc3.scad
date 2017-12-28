include <camera.scad>;

size_bottom = [160, 92];
height_bottom = 110-42;

lens_hole_pos = [61, 45, -1];

w = 3.2;

* % translate([193, 71-46, 16]) color("blue") camera(longlens=false);

//bottom();
frontplate();

translate([180, 0, 0]) {
    translate([size_bottom[0], 0, 0]) rotate([90, 0, 180]) bottom();    
    translate([0, -10, 0]) rotate([90, 0, 0]) frontplate();    
    
    translate([2.4+0.5, 70, 90-8-41+0.8]) rotate([90, 0, 0]) squarenut();
    
    translate([48, 10, 0]) import("clamp_enc3_plate.stl");
    translate([128, -00+55, 2.4]) rotate([0, 0, 180]) clamp();
}


module clamp() {
    
    size = [80, 43, 11]; // only clamp

    fins = [[4, 1.4], [0.4, 4], [4, 4]];
    offset_screw = 11;
    
    crad = 3;
    
    difference() {
        union() {
            difference() {
              
                hull() {
                    translate([0, 0, 0]) block([size[0], size[1]+10], .1, crad=crad);
                    translate([0, 0, 10.5-.1]) block(size, .1, crad=crad);
                    translate([0, 0, 11-.1]) block(size, .1, crad=crad, red=0.5);
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

module bottom() { 
    crad = 5;
    
    difference() {
        union() {
            difference() {
                // outer shell
                block(size_bottom, height_bottom, crad=crad);
                
                // inside cutout
                translate([0, 0, 2]) block(size_bottom, height_bottom, crad=crad, red=w);
            }
            
            // top left
            intersection() {
                block(size_bottom, height_bottom, crad=crad);
                union() {
                    translate([0, size_bottom[1]-12]) cube([12, 12, height_bottom]);
                }
            }
            
            // bottom center
            translate([32, 0, 52]) hull() {
                cube([16.8, 13.4-.5, 16]);
                translate([.5, 13.4-.1, 0])cube([16.8-.5, .1, 16]);
            }
            
            // center right
            points1 = [[0, 0], [12, 5], [12, 5+10], [0, 5*2+10]];
            translate([size_bottom[0], size_bottom[1]/2+10, 0]) rotate([0, 0, 180]) linear_extrude(height=height_bottom) polygon(points1);
            
            // reinforcement
            points2 = [[0, 0], [5, 5], [5, 5+10], [0, 5*2+10]];
            translate([0, 50, 0]) rotate() linear_extrude(height=height_bottom) polygon(points2);
            translate([size_bottom[0]/2-10, size_bottom[1], 0]) rotate([0, 0, 270]) linear_extrude(height=height_bottom) polygon(points2);
        }
        
        // lens hole
        translate(lens_hole_pos) cylinder($fn=64, h=10, d=70);
        
        // screw holes
        translate([40, 7, height_bottom-10])                                cylinder($fn=32, h=20, d=5.3);
        translate([size_bottom[0]-7, size_bottom[1]/2, height_bottom-10])   cylinder($fn=32, h=20, d=5.3);
        translate([7, size_bottom[1]-7, height_bottom-10])                  cylinder($fn=32, h=20, d=5.3);
    }
   
}

module frontplate() {
    height = 10;
    
    difference() {
        union() {
            block(size_bottom, 3, crad=5);
            translate([size_bottom[0]-lens_hole_pos[0], lens_hole_pos[1], 3]) 
                cylinder($fn=64, h=2, d1=84, d2=80);
            translate([size_bottom[0]-lens_hole_pos[0], lens_hole_pos[1]]) 
                cylinder($fn=64, h=height, d=80);
        }
        translate([size_bottom[0]-lens_hole_pos[0], lens_hole_pos[1], lens_hole_pos[2]]) 
            cylinder($fn=64, h=20, d=67); // lens diameter: 62mm
    }
}

// --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

module squarenut() {
    color("grey") difference() {
        cube([8, 8, 2.55]);
        translate([4, 4, -1]) cylinder($fn=32, d=5, h=5);
    }
}

module block(dim, height, crad=3, red=0) {
    hull() {
        translate([crad+red, crad+red])         cylinder($fn=32, h=height, r=crad);
        translate([dim[0]-crad-red, crad+red])          cylinder($fn=32, h=height, r=crad);
        translate([crad+red, dim[1]-crad-red])          cylinder($fn=32, h=height, r=crad);
        translate([dim[0]-crad-red, dim[1]-crad-red])   cylinder($fn=32, h=height, r=crad);
    }
}