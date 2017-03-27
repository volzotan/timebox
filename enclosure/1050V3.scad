include <camera.scad>;
include <enclosure_util.scad>;

size_top    = [165, 98, 0.1];
size_bottom = [157, 91, 0.1];
height      = 47;
nose_depth  = 66;

translation_x = (size_top[0]-size_bottom[0])/2;
translation_y = (size_top[1]-size_bottom[1])/2;    

radius_b = 6;
radius_t = 10;

corner_radius       = 2.5;

wall_thickness      = 2.4;
bottom_thickness    = 1.2;

render_simplified   = true;
clamp_print         = false;
mat_saving_holes    = true;

// ---
/*
TODO:

Halterung für Batterie

*/

//translate([size_top[0]/2 - 40, 43, -12]) socketplate();

// socketplate2();

// translate([8, 27, 12]) camera();

// pressureNose();
inset();

// translate([size_top[0], 0, 0]) rotate([90, 0, 180]) enclosure();
//block2(size_top, size_bottom, height, radius_b, radius_t);
//translate([87, 152, 10]) cylinder(h=10, d=10);
// translate([0, -4, 0]) clamp();
    
module clamp() {
    
    offset = size_top[0]/2 - 40;
    screw_offset = 6;
    rot_screw = -4;
    screw_inner_diam = 4.2;
    screw_outer_diam = 9;
    screw_bottom_f = 6;
    screw_bottom_b = 4;
    plate_offset = 23;
    
    translate([offset+plate_offset+41, 82, 4.5]) union() {
        cube([2, 33, 10.5]);
        translate([2, 0, 3.7]) cube([1, 33, 1.8]);
        translate([-4+0.1, 0, 5]) rotate([180, 0, 90]) prism(33, 3.8, 4.8);       
           
    }
    
    if (!clamp_print) { 
        translate([offset+plate_offset, 30, 5]) {
            difference() {
                cube([40, 40, 10]);
        
                translate([-0.01, -1, -0.01]) rotate([90, 0, 90]) prism(42, 5, 4);
                translate([36+0.01, -1, 5-0.01]) rotate([180, 0, 90]) prism(42, 4, 5);
                
                translate([20, 22, -1]) cylinder(h=15, d=6.35, $fn=32);
            }
        }
        
        
        
        //translate([130, 28, 8]) rotate([0, 90, 0]) cylinder(h=20, d=4, $fn=32);
    }
        
    union() {
                
        difference() {
            translate([offset, 0, 0]) cube([80, 45, 15]);
            
            translate([offset+plate_offset, 12, 4+0.01]) cube([43, 40, 11]);
            
            translate([offset+plate_offset+43-0.01, 12, 8]) cube([1.2, 40, 2]);
            translate([offset+plate_offset+44-0.01+0.2, 12, 10-0.01]) rotate([0, 0, 90]) prism(41, 1.2, 1.2);       
            
            // corner triangle front
            translate([offset-0.1, 5-0.1, 3]) rotate([270, 0, 0]) triangle(80+1, 2);
            
            // negative outer shell
            translate([size_top[0], 5, 0]) rotate([90, 0, 180]) {
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
                translate([screw_offset, screw_offset, screw_bottom_f]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=64);
                translate([80-screw_offset, screw_offset, screw_bottom_f]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=64);
                translate([screw_offset, 40-screw_offset, screw_bottom_b]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=64);
                translate([80-screw_offset, 40-screw_offset, screw_bottom_b]) rotate([rot_screw, 0, 0]) cylinder(h=30, d=screw_outer_diam, $fn=64);
            
                translate([screw_offset, screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=64);
                translate([80-screw_offset, screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=64);
                translate([screw_offset, 40-screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=64);
                translate([80-screw_offset, 40-screw_offset, 0]) rotate([rot_screw, 0, 0]) cylinder(h=32, d=screw_inner_diam, $fn=64);
            }
            
            // test
            // translate([28, -1, -1]) cube([20, 100, 30]);
        }
    }
    translate([offset+plate_offset-0.01, 8, 5]) rotate([90, 0, 90]) prism(37, 4.8, 3.8);
    //translate([38+offset+plate_offset+0.01, 8, 5+5]) rotate([180, 0, 90]) prism(42, 3.8, 4.8);
}

module inset() {

    difference() {
        union() {
            difference() {
                translate([size_top[0], 0, 0]) rotate([90, 0, 180]) enclosure();
                
                // strap holder opening
                translate([0, 31, 64]) {
                    translate([-1, 6, 6]) rotate([0, 90, 0]) cylinder(h=10, d=12);
                    translate([-1, 6, 0]) cube([10, 15, 12]);
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
            
            // pressure noses            
            translate([size_top[0]/2 - 20/2, 0, size_top[1]-wall_thickness]) pressureNose();
            translate([size_top[0]- wall_thickness, 0, 40]) rotate([0, 90, 0]) pressureNose();
            translate([wall_thickness, 0, 40-20]) rotate([0, -90, 0]) pressureNose();
        
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
            threadhole();
        }
        
        // screw tunnels
        tunnel_height = 2.8;
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

module pressureNose() {
    
    nose_width = 20;
    curvature  = 3;
    
    depth = nose_depth - 5;

    translate([0, 5, 0]) difference() {
        union() {           
            translate([nose_width/2, 0, -2]) {
                translate([0, 0, 4]) rotate([270, 0, 0]) scale([1, 0.5, 1]) cylinder(h=depth, d=nose_width, $fn=64);
                translate([0, depth-4+2, 2]) rotate([0, 180, 180]) prism(2,2,2);
                    
            }     
        } 
        difference() {
            offset = 0.85;
            
            translate([0, depth-curvature/2, offset]) cube([nose_width, 10, 10]);
            translate([0, depth-curvature/2, offset]) rotate([0, 90, 0]) cylinder(h=nose_width, d=curvature, $fn=32);
        }
  
        translate([0, depth-20, wall_thickness]) cube([nose_width, 20, 10]);
    }
    
}

// ------------------------------------------------------------------

module socketplate() {
    rotate([-4, 0, 0])
    difference() {
        dist = 6;

        cube([80, 40, 10]);
        
        translate([dist,    dist,       -1]) cylinder(d=5, h=18, $fn=32);
        translate([80-dist, dist,       -1]) cylinder(d=5, h=18, $fn=32);
        translate([dist,    40-dist,    -1]) cylinder(d=5, h=18, $fn=32);
        translate([80-dist, 40-dist,    -1]) cylinder(d=5, h=18, $fn=32);
        
        translate([80/4, 40/2, -1]) cylinder(d=7, h=12, $fn=32);  
        translate([80/2, 40/2, -1]) cylinder(d=7, h=12, $fn=32);  
        translate([(80/4)*3, 40/2, -1]) cylinder(d=7, h=12, $fn=32);  
  
        // test
        // translate([-1, -1, -1]) cube([7, 100, 30]);
    }
}

module socketplate2() { // for actual printing with non perfect hole spacing
    union() {
    difference() {
        dist        = 7;
        nutM5       = 11; // ?
        nut14Inch   = 13; // ?

        cube([80, 40, 8]);
        
        translate([dist,    dist,       -1]) {
            cylinder(d=5.3, h=18, $fn=32);
            translate([0, 0, 4]) cylinder(d=nutM5, h=6, $fn=6); 
        }
        translate([80-dist, dist,       -1]) {
            cylinder(d=5.3, h=18, $fn=32);
            translate([0, 0, 4]) cylinder(d=nutM5, h=6, $fn=6); 
        }
        translate([dist,    40-dist,    -1]) {
            cylinder(d=5.3, h=18, $fn=32);
            translate([0, 0, 4]) cylinder(d=nutM5, h=6, $fn=6); 
        }
        translate([80-dist, 40-dist,    -1]) {
            cylinder(d=5.3, h=18, $fn=32);
            translate([0, 0, 4]) cylinder(d=nutM5, h=6, $fn=6); 
        }
        
//        translate([80/4, 40/2, -1]) {
//            cylinder(d=6.4, h=12, $fn=32);  
//            cylinder(d=nut14Inch, h=8, $fn=6);  
//        }
        translate([80/2, 40/2, -1]) {
            cylinder(d=6.4, h=12, $fn=32);  
            translate([0, 0, 2]) cylinder(d=nut14Inch, h=10, $fn=6); // h=6
        }
//        translate([(80/4)*3, 40/2, -1]) {
//            cylinder(d=6.4, h=12, $fn=32);  
//            translate([0, 0, 2]) cylinder(d=nut14Inch, h=6, $fn=6); 
//        }
            
        // test
        // translate([-1, -1, -1]) cube([7, 100, 30]);
    }
        // support layer to properly print hole
        translate([0, 0, 3]) color([1,1,1,0.5]) cube([15, 15, 0.2]);
    }
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
                    
            // lens
            translate([ size_top[0]/2,
                        size_top[1]/2,
                        -1]) {
                cylinder(h=10, d=80, $fn=64);
            }
            
            // material saving holes
            if (mat_saving_holes) {
                distance = 27;
                translate([ distance,
                            distance,
                            -1]) cylinder(h=10, d=30, $fn=32);
                
                translate([ distance,
                            size_top[1]-distance,
                            -1]) cylinder(h=10, d=30, $fn=32);
                
                translate([ size_top[0]-distance,
                            distance,
                            -1]) cylinder(h=10, d=30, $fn=32);
                
                translate([ size_top[0]-distance,
                            size_top[1]-distance,
                            -1]) cylinder(h=10, d=30, $fn=32);
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
            
            translate([wall_thickness, wall_thickness, bottom_thickness]) block(
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

module prism(l, w, h){
    polyhedron(points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]], faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]);
}