include <camera.scad>;
include <enclosure_util.scad>;

size_bottom = [155, 105, 82];
size_top = [155, 105, 3];

wall_thickness = 1.6;
bottom_thickness = 1.2;

screw_bar_width = 9;
pug_diameter_top = 3.3;
pug_diameter_btm = 6.8;
uv_filter_diameter  = 67; // ?
uv_filter_diameter2 = 68; // ?

oring_bottom = 0.8;
oring_top = 1.2;

translate([12, 31, 10]) camera();

render_bottom   = false;
render_top      = false;

// 

height  = 80;
w       = 2.0;
b       = 2.0;

shell =   [ [0,     15],
            [15,     5],
            [40,     5],
            [50,     0],
            [130,    0],
            [140,   10],
            [140,   25],
            [150,   35],
            [150,  100],
            [140,  110],
            [10,   110],
            [0,   100]
            ];
                        
cavity =  [ [w,     15+w],
            [15+w,     5+w],
            [40+w,     5+w],
            [50+w,     0+w],
            [130-w,    0+w],
            [130-w,    15+w],
            [140-w,   25+w],
            [140-w,   25+w],
            [150-w,   35+w],
            [150-w,   90-w],
            [130-w,  110-w],
            [20+w,   110-w],
            [0+w,     90-w]
            ];
            
 trianglecut_faces =   [[0, 1, 2],
                        [2, 1, 4, 5],
                        [0, 2, 5, 3],
                        [3, 5, 4],
                        [3, 4, 1, 0]];
                        
 trcut_bottom_right =  [[140,   25,  0],  // 0
                        [150,   25,  0],  // 1
                        [150,   25, 10],  // 2
                        [140,   110, 0],  // 3
                        [150,   110, 0],  // 4
                        [150,   110,10]]; // 5

difference() {
    union() {
        difference() {
            linear_extrude(height=height) polygon(points = shell);
            
            translate([0, 0, 0]) polyhedron(trcut_bottom_right, trianglecut_faces);
            
            union() {
                translate([0, 0, b]) linear_extrude(height=height) polygon(points = cavity);
            }
        }
    
        intersection() {
            translate([90, 0, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=2, r1=(uv_filter_diameter/2)+4, r2=uv_filter_diameter/2, $fn=128);
            translate([0, -size_bottom[1]+1, 0]) cube(size_bottom);
        }
        
        // socket
        translate([60, 25, 0]) {                    
            translate([0, 0, 0]) cube([60, 46, 10]);    
        }
    }
    
    translate([86, 42, -2.5]) threadhole(length=10);
                
    // front hole
    translate([90, 5, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=10, d=uv_filter_diameter, $fn=256);
    translate([90, 0, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=10, d=uv_filter_diameter2, $fn=256);                

    pug_height = 30;

    translate([0, 0, height-pug_height+0.1]) {
        translate([]) pug(pug_height, pug_diameter_top);
        translate([130, 10, 0]) pug(pug_height, pug_diameter_top);
        translate([136, 97, 0]) pug(pug_height, pug_diameter_top);
        translate([4, 97, 0]) pug(pug_height, pug_diameter_top);
    }
                
}


module innercut() {
    difference() {
        translate([wall_thickness, wall_thickness, bottom_thickness])           
            cube([size_bottom[0]-wall_thickness*2, size_bottom[1]-wall_thickness*2, 100]);         

        translate([wall_thickness, -24+wall_thickness, -1]) rotate([0, 0, 45]) cube([30, 30, size_bottom[2]+2]);
        translate([size_bottom[0]-wall_thickness, -24+wall_thickness, -1]) rotate([0, 0, 45]) cube([30, 30, size_bottom[2]+2]);
                
    }    
}

if (render_bottom) {
    translate([0, 0, 0]) {
        difference() {
            union() {

                 
                
                difference() {
                    cube(size_bottom);
                    
                    translate([0, -24, -1]) rotate([0, 0, 45]) cube([30, 30, size_bottom[2]+2]);
                    translate([size_bottom[0], -24, -1]) rotate([0, 0, 45]) cube([30, 30, size_bottom[2]+2]);
                
                    
                    innercut();
                }
                
                intersection() {
                    translate([90, 0, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=2, r1=(uv_filter_diameter/2)+4, r2=uv_filter_diameter/2, $fn=128);
                    translate([0, -size_bottom[1]+1, 0]) cube(size_bottom);
                }
                
                oring(size_bottom, wall_thickness, screw_bar_width, oring_bottom);
                
                // screw bars
//                translate([]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
//                translate([size_bottom[0]-screw_bar_width, 0, 0]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
//                translate([size_bottom[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
//                translate([0, size_bottom[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_bottom[2]]);
//            
                // socket
                translate([60, 25, 0]) {                    
                    translate([0, 0, 0]) cube([60, 46, 10]);    
                }
            }
            
            // front hole
            translate([90, 5, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=10, d=uv_filter_diameter, $fn=256);
            translate([90, 0, size_bottom[2]/2]) rotate([90, 0, 0]) cylinder(h=10, d=uv_filter_diameter2, $fn=256);
                
            pug_height = 30;
            
            translate([0, 0, size_bottom[2]-pug_height+0.1]) {
                translate([]) pug(pug_height, pug_diameter_top);
                translate([size_bottom[0]-screw_bar_width, 0, 0]) pug(pug_height, pug_diameter_top);
                translate([size_bottom[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) pug(pug_height, pug_diameter_top);
                translate([0, size_bottom[1]-screw_bar_width, 0]) pug(pug_height, pug_diameter_top);
            }
                
//            translate([70, 80, -1]) {
//                cylinder(h=12, d=3.3, $fn=32);
//                cylinder(h=3, d=7.0, $fn=6);
//                translate([40, 0, 0]) {
//                    cylinder(h=12, d=3.3, $fn=32);
//                    cylinder(h=3, d=7.0, $fn=6);
//                }
//            }
            
            translate([86, 42, -2.5]) threadhole(length=10);
//            translate([60, 25, 7]) {                    
//                translate([0, 0, 0]) cube([60, 46, 10]);    
//            }
                
            nut_distance = 10;
            nut_size     = 7.4;
            
            translate([0.8-0.01, -0.01, size_bottom[2]-nut_distance]) cube([7.4, 7.4, 3]);
            translate([size_bottom[0]-nut_size-0.8, -0.01, size_bottom[2]-nut_distance]) cube([nut_size, nut_size, 3]);
            translate([0.8-0.01, size_bottom[1]-nut_size+0.01, size_bottom[2]-nut_distance]) cube([nut_size, nut_size, 3]);
            translate([size_bottom[0]-nut_size-0.8+0.01, size_bottom[1]-nut_size+0.01, size_bottom[2]-nut_distance]) cube([nut_size, nut_size, 3]);
        }
    }
}

if (render_top) {
    translate([0, size_bottom[1], 100]) rotate([180, 0, 0]) {  //translate([size_bottom[0] + 20, 0, 0]) {
        difference() {
            union() {
                difference() {
                    cube(size_top);
                    
                    translate([wall_thickness, wall_thickness, bottom_thickness]) 
                        cube([size_top[0]-wall_thickness*2, size_top[1]-wall_thickness*2, 100]);
                }
                      
             
                translate([]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
                translate([size_top[0]-screw_bar_width, 0, 0]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
                translate([size_top[0]-screw_bar_width, size_top[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
                translate([0, size_top[1]-screw_bar_width, 0]) cube([screw_bar_width, screw_bar_width, size_top[2]]);
            }
            
            translate([]) pug(100, pug_diameter_top);
            translate([size_top[0]-screw_bar_width, 0, 0]) pug(100, pug_diameter_top);
            translate([size_top[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) pug(100, pug_diameter_top);
            translate([0, size_top[1]-screw_bar_width, 0]) pug(100, pug_diameter_top);
            
            translate([]) pug(1.5, pug_diameter_btm);
            translate([size_bottom[0]-screw_bar_width, 0, 0]) pug(1.5, pug_diameter_btm);
            translate([size_bottom[0]-screw_bar_width, size_bottom[1]-screw_bar_width, 0]) pug(1.5, pug_diameter_btm);
            translate([0, size_bottom[1]-screw_bar_width, 0]) pug(1.5, pug_diameter_btm);
            
            translate([0, 0, -oring_bottom+0.01]) oring(size_top, wall_thickness, screw_bar_width, oring_top);  
        }
    }
}

module oring(base, thickness, bar_width, ring_width) {
    translate([thickness-ring_width, bar_width-ring_width, base[2]]) cube([ring_width, base[1] - bar_width*2 + ring_width*2, ring_width]);
    translate([base[0]-thickness, bar_width-ring_width, base[2]]) cube([ring_width, base[1] - bar_width*2 + ring_width*2, ring_width]);
    translate([bar_width-ring_width, thickness-ring_width, base[2]]) cube([base[0] - bar_width*2 + ring_width*2, ring_width, ring_width]);
    translate([bar_width-ring_width, base[1]-thickness, base[2]]) cube([base[0] - bar_width*2 + ring_width*2, ring_width, ring_width]);
    
    translate([thickness-ring_width, bar_width-ring_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([bar_width-ring_width, thickness-ring_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
   
    translate([thickness-ring_width, base[1]-bar_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([bar_width-ring_width, base[1]-bar_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
      
    translate([base[0] - bar_width, bar_width-ring_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([base[0] - bar_width, thickness-ring_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
   
    translate([base[0] - bar_width, base[1]-bar_width, base[2]]) cube([bar_width-(thickness-ring_width), ring_width, ring_width]);
    translate([base[0] - bar_width, base[1]-bar_width, base[2]]) cube([ring_width, bar_width-(thickness-ring_width), ring_width]);
}

module nutcut(height, diameter, hole=-1) {
    rotate([0, 0, 270-45]) {
        difference() {
            union() {
                rotate([0, 0, 30]) cylinder(h=height, d=diameter, $fn=6);
                translate([0, -diameter/2, 0]) rotate([0, 0, 0]) cube([20, diameter, height]);
            } 
            if (hole>0) {
                translate([0, 0, -1]) cylinder(h=height+2, d=hole, $fn=32);
            }
        }
    }
}

module pug(height, pug_diameter) {
    translate([screw_bar_width/2, screw_bar_width/2, -0.01]) cylinder(h=height, d=pug_diameter, $fn=32);
}