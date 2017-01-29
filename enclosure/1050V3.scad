include <camera.scad>;

size_top    = [165, 98, 0.1];
size_bottom = [157, 91, 0.1];
height      = 47;

translation_x = (size_top[0]-size_bottom[0])/2;
translation_y = (size_top[1]-size_bottom[1])/2;    

radius_b = 6;
radius_t = 10;

corner_radius = 2.5;

wall_thickness = 2.0;

render_simplified = false;

// ---
/*
TODO:

Halterung für Batterie
Pressure Noses

*/

// translate([size_top[0]/2 - 40, 40, -12]) socketplate();

 //translate([9, 27, 16]) camera();

inset();

// block2(size_top, size_bottom, height, radius_b, radius_t);

// translate([0, 80, 0]) clamp();
    
module clamp() {
    offset = size_top[0]/2 - 40;
    screw_offset = 6;
    rot_screw = -4;
    screw_inner_diam = 4;
    screw_outer_diam = 10;
    screw_bottom_f = 6;
    screw_bottom_b = 3;
    plate_offset = 24;
    
    translate([offset+plate_offset, 62, 3]) cube([42, 20, 12]);
    
    translate([130, 28, 8]) rotate([0, 90, 0]) cylinder(h=20, d=4, $fn=32);
    
    difference() {
        translate([offset, 0, 0]) cube([80, 50, 15]);
        
        translate([offset+plate_offset, 12, 3]) cube([42, 40, 13]);
    
        // negative outer shell
        translate([size_top[0], 0, 0]) rotate([90, 0, 180]) {
            difference() {
                translate([-20, -20, -20]) cube([size_top[0]+40, size_top[1]+40, height+20]);
                block(size_top, size_bottom, height);
            }
        }
        
        // fastener
        translate([100, 28, 8]) rotate([0, 90, 0]) cylinder(h=50, d=4.4, $fn=32);
        
        // nut hole
        /* m4 nyloc nut: 
         * depth  = 6
         * height = 7.66
         * width  = 7
         */
        translate([112, 24, 3]) cube([6.2, 8, 30]);
        
        // sidecut
        translate([35, -1, 0]) rotate([0, -45, 0]) cube([40, 80, 10]);
        
        // screw holes
        translate([offset, 4, 0]) {
            translate([screw_offset, screw_offset, screw_bottom_f]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=32);
            translate([80-screw_offset, screw_offset, screw_bottom_f]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=32);
            translate([screw_offset, 40-screw_offset, screw_bottom_b]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=32);
            translate([80-screw_offset, 40-screw_offset, screw_bottom_b]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=32);
        
            translate([screw_offset, screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=32);
            translate([80-screw_offset, screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=32);
            translate([screw_offset, 40-screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=32);
            translate([80-screw_offset, 40-screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=32);
        }
    }
}

module inset() {

difference() {
    union() {
        difference() {
            translate([size_top[0], 0, 0]) rotate([90, 0, 180]) enclosure();
            
            // strap holder opening
            translate([0, 31, 65]) {
                translate([-1, 7, 5]) rotate([0, 90, 0]) cylinder(h=14, d=10);
                translate([-1, 7, 0]) cube([14, 15, 10]);
            }
        }

        // socket triangle
        translate([39, 10, 0]) {
            rotate([0, 0, 0]) triangle(88, 17);
        }

        // socket block
        translate([39, 10, 0]) {
            difference() {  
                cube([88, 49, 12]);    
                translate([-10, 45, 4]) {
                    rotate([0, 90, 0]) {
                        difference() {
                            cube([12, 12, 100]);
                            translate([0, 0, -10]) {
                                cylinder(h = 120, d = 8, $fn=64); 
                            }
                        }
                    }
                }
            }
        }
    }
    
    // negative outer shell
    translate([size_top[0], 0, 0]) rotate([90, 0, 180]) {
        difference() {
            translate([-20, -20, -20]) cube([size_top[0]+40, size_top[1]+40, height+20]);
            block(size_top, size_bottom, height);
        }
    }

    // threadhole
    translate([82, 28, -1]) {
        camera_threadhole();
    }
    
    // screw tunnels
    tunnel_height = 3;
    translate([0, 0, -0.1]) intersection() {
        translate([size_top[0], 0, 0]) rotate([90, 0, 180]) difference() {
            block(size_top, size_bottom, height);
            translate([0, tunnel_height, 0]) block(size_top, size_bottom, height);
        }
        
        union() { 
            translate([43, 13, 0]) {
                cube([12, 100, 10]);
                translate([6, 0, 0])cylinder(h=10, d=12, $fn=32);
            }
            
            translate([111, 13, 0]) {
                cube([12, 100, 10]);
                translate([6, 0, 0]) cylinder(h=10, d=12, $fn=32);
            }    
        }
    }
    translate([43, 40, -0.01]) cube([12, 20, tunnel_height]);
    translate([111, 40, -0.01]) cube([12, 20, tunnel_height]);
}

    // tripod test hole    
    // translate([87, 42, -1]) cylinder(h=10, d=10);
}

// ------------------------------------------------------------------

module socketplate() {
    union() {
        dist = 6;
        
        cube([80, 40, 10]);
        
        translate([dist,    dist,       -1]) cylinder(d=4, h=18);
        translate([80-dist, dist,       -1]) cylinder(d=4, h=18);
        translate([dist,    40-dist,    -1]) cylinder(d=4, h=18);
        translate([80-dist, 40-dist,    -1]) cylinder(d=4, h=18);
        
        translate([80/4, 40/2, -1]) cylinder(d=7, h=12);  
        translate([80/2, 40/2, -1]) cylinder(d=7, h=12);  
        translate([(80/4)*3, 40/2, -1]) cylinder(d=7, h=12);        
    }
}

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
    union() {
        difference() {
            if (!render_simplified) {
                block4(size_top, size_bottom, height, radius_b, radius_t);
            } else {
                block2(size_top, size_bottom, height, radius_b, radius_t);
            }
                        
            translate([ size_top[0]/2,
                        size_top[1]/2,
                        -1]) {
                cylinder(h=10, d=80, $fn=64);
            }
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
    union() {
        difference() {
            block(top, bottom, h);
            
            translate([wall_thickness, wall_thickness, 1]) block(
                        [size_top[0]-wall_thickness*2, size_top[1]-wall_thickness*2, 0.1],
                        [size_bottom[0]-wall_thickness*2, size_bottom[1]-wall_thickness*2, 0.1],
                        height+0.1
                    );
        }
        
        trans_x = (top[0] - bottom[0])/2;
        trans_y = (top[1] - bottom[1])/2;
        
        support_triangle_size = 3;
        translate([bottom[0] + trans_x, trans_y + wall_thickness, 1]) rotate([0, 0, 180]) triangle(size_bottom[0], support_triangle_size);
        translate([trans_x, trans_y + bottom[1] - wall_thickness, 1]) rotate([0, 0, 0]) triangle(size_bottom[0], support_triangle_size);
        translate([trans_x + wall_thickness, trans_y, 1]) rotate([0, 0, 90]) triangle(size_bottom[1], support_triangle_size);
        translate([trans_x + bottom[0] - wall_thickness, trans_y, 1]) rotate([270, 0, 90]) triangle(size_bottom[1], support_triangle_size);
    }
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