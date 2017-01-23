 include <camera.scad>;

size_top    = [165, 98, 0.1];
size_bottom = [155, 90, 0.1]; 
height      = 50;

translation_x = (size_top[0]-size_bottom[0])/2;
translation_y = (size_top[1]-size_bottom[1])/2;    

radius_b = 6;
radius_t = 10;

corner_radius = 2.5;

// ---
/*
TODO:

Aussparungen für Schrauben
Halterung für Batterie
Pressure Noses

*/

difference() {
    translate([size_top[0], 0, 0]) rotate([90, 0, 180]) enclosure();
    
    // strap holder opening
    translate([0, 31, 65]) {
        translate([-1, 5, 5]) rotate([0, 90, 0]) cylinder(h=10, d=10);
        translate([-1, 5, 0]) cube([10, 15, 10]);
    }
    
    // tripod test hole
    translate([87, 42, -1]) cylinder(h=10, d=10);
}

//translate([9, 27, 12]) camera();

//difference() {
//    union() {
//
//        // socket triangle
//        translate([49, 13, 0]) {
//            rotate([0, 0, 0]) triangle(60, 17);
//        }
//
//        // socket block
//        translate([49, 13, 0]) {
//            difference() {  
//                cube([60, 46, 12]);    
//                translate([-10, 42, 4]) {
//                    rotate([0, 90, 0]) {
//                        difference() {
//                            cube([12, 12, 80]);
//                            translate([0, 0, -10]) {
//                                cylinder(h = 100, d = 8, $fn=64); 
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    // threadhole
//    translate([75, 28, -1]) {
//        camera_threadhole();
//    }
//}


// ------------------------------------------------------------------

module camera_threadhole() {
    // 1/4 inch = 0,635cm
    screw_hole_diameter = 7;
    socket_diameter     = 24;
    socket_height       = 8;
    length              = 22;
    height              = 18;
    
    threadhole(screw_hole_diameter, 
                    socket_diameter,
                    socket_height,
                    length,
                    height);
}

module threadhole(  screw_hole_diameter, 
                    socket_diameter,
                    socket_height,
                    length,
                    height) {
                        
    cube([screw_hole_diameter, length, height]);
    
    translate([screw_hole_diameter/2, 0, 0]) cylinder(h=height, d=screw_hole_diameter, $fn=64);
    translate([screw_hole_diameter/2, length, 0]) cylinder(h=height, d=screw_hole_diameter, $fn=64);
    translate([-(socket_diameter/2 - screw_hole_diameter/2), 0, 0]) cube([socket_diameter, length, socket_height]);
    translate([screw_hole_diameter/2, 0, 0]) cylinder(h=socket_height, d=socket_diameter, $fn=128);
    translate([screw_hole_diameter/2, length, 0]) cylinder(h=socket_height, d=socket_diameter, $fn=128);
}

// ------------------------------------------------------------------

module enclosure() {
    difference() {
        block4(size_top, size_bottom, height, radius_b, radius_t);
        
        translate([1, 1, 1]) block2(
            [163, 96, 0.1],
            [153, 88, 0.1],
            height+0.1,
            10, 15
        );
        
        translate([ size_top[0]/2,
                    size_top[1]/2,
                    -1]) {
            cylinder(h=10, d=80, $fn=64);
        }
    }
}

module block4() {
    difference() {
        block3(size_top, size_bottom, height, radius_b, radius_t);
        
        translate([translation_x-0.2, translation_y-0.2, 0])
        rotate([0, 0, 0]) cornercutter_sphere();
  
        translate([ size_bottom[0] + translation_x+0.2, 
                    translation_y-0.2, 0])
        rotate([0, 0, 90]) cornercutter_sphere();

        translate([ size_bottom[0] + translation_x+0.2, 
                    size_bottom[1] + translation_y+0.2, 0])
        rotate([0, 0, 180]) cornercutter_sphere();
    
        translate([ translation_x-0.2, 
                    size_bottom[1] + translation_y+0.2, 0])
        rotate([0, 0, 270]) cornercutter_sphere();
    }
    
}

module cornercutter_sphere() {

    difference() {
        cube([radius_b, radius_b, corner_radius]);
        translate([radius_b, radius_b, 0]) cylinder(h=corner_radius, d=radius_b+corner_radius*2, $fn=64);
    

        translate([radius_b, radius_b, corner_radius]) rotate([0, 0, 180])
        intersection() {
            translate([0, 0, -corner_radius])
            cube([radius_t, radius_t, 10]);
                rotate_extrude(convexity = 10, $fn = 64)
                    translate([radius_b-corner_radius, 0, 0])
                    circle(r = corner_radius, $fn = 64);
        }
    }
}


module block3(top, bottom, h, r1, r2) {    
    difference() {
        block2(top, bottom, h, r1, r2);
       
        translate([ 0,
                    translation_y-1,
                    -0.1])
        cornercutter(top[0], corner_radius*2);
    
        translate([ top[0],
                    top[1] - translation_y+1,
                    -0.1])
        rotate([0, 0, 180])
        cornercutter(top[0], corner_radius*2);
        
        translate([ top[0] - translation_x+1,
                    0,
                    -0.1])
        rotate([0, 0, 90])
        cornercutter(top[1], corner_radius*2);

        translate([ translation_x-1,
                    top[1],
                    -0.1])
        rotate([0, 0, 270])
        cornercutter(top[1], corner_radius*2);  
    }
   
}

module cornercutter(width, corner_radius) {
    translate([-0.01, -0.01, -0.01])
    difference() {
        translate([ 0,
                    0,
                    0])
        cube([width+0.02, corner_radius, corner_radius]);
      
        translate([ 0,
                    0 + corner_radius,
                    corner_radius]) 
        rotate([0, 90, 0]) 
        cylinder(h=width+0.02, d=corner_radius*2, $fn=32);
    }
    
}

module block2(top, bottom, h, r1, r2) {
    block(top, bottom, h);
}

module cornercutter_vert(r, h) {    
    translate([0, 0, -0.01]) {
        difference() {
        cube([r, r, h+1]);
        translate([r, r, 0])
            cylinder(h=h+1, r=r, $fn=65);
        }
    }    
}

module block(top, bottom, h) {    
    hull() {
        translate([ (top[0]-bottom[0])/2, 
                    (top[1]-bottom[1])/2, 
                    0]) {
            
            difference() {
                cube(bottom);
                
                translate([0, 0, 0]) rotate([0, 0, 0]) cornercutter_vert(radius_b, 1);
                translate([bottom[0]+0.01, -0.01, 0]) rotate([0, 0, 90]) cornercutter_vert(radius_b, 1);
                translate([bottom[0]+0.01, bottom[1]+0.01, 0]) rotate([0, 0, 180]) cornercutter_vert(radius_b, 1);
                translate([-0.01, bottom[1]+0.01, 0]) rotate([0, 0, 270]) cornercutter_vert(radius_b, 1);
            }
        }
        translate([0, 0, h]) {
            difference() {
                cube(top);
                
                translate([0, 0, 0]) rotate([0, 0, 0]) cornercutter_vert(radius_t, 1);
                translate([top[0]+0.01, -0.01, 0]) rotate([0, 0, 90]) cornercutter_vert(radius_t, 1);
                translate([top[0]+0.01, top[1]+0.01, 0]) rotate([0, 0, 180]) cornercutter_vert(radius_t, 1);
                translate([-0.01, top[1]+0.01, 0]) rotate([0, 0, 270]) cornercutter_vert(radius_t, 1);
            }
        }
    }
}

// ------------------------------------------------------------------

module triangle(width, height) {
   
    // a^2 = c^2
    // a = sqrt ( c^2 / 2 )
                
    a = sqrt(pow(height, 2) / 2);
                
    translate([0, 0, -a]) {
        intersection() {
            rotate([45, 0, 0]) cube([width, height, height]);
            translate([0, -a, a]) cube([width, a, a]);
        }
    } 
}   