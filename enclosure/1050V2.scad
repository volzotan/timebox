 include <controllerHolder1050V2.scad>;

// GLOBAL VARS

// dim_case_interior   = [160,     55,     94  ];
dim_case_interior   = [160,     55,     90  ];
dim_battery_holder  = [21.54,40.21,     77.7];

// ----------------------------------------------

color([0.2, 0.3, 0.9, 0.9]) enclosure();
// translate([134, 30, 5]) battery_holder();    
// translate([1, 26, 12]) camera();

holder_width = 160;
holder_height = 95;
// translate([holder_width - (holder_width-dim_case_interior[0])/2, 80, holder_height - (holder_height-dim_case_interior[2])/2 ]) rotate([-90, 0, 180]) color([0.5, 0.5, 0.5, 0.2]) controllerHolder();

// translate([dim_case_interior[0]/2, 0, 46]) color([0.5, 0.5, 0.5, 1]) filter_adapter();

// pelicase 
//color([0, 0, 0, 0.1]) cube([160, 70, 93]);

//color([0.3, 0.3, 0.3, 0.8]) translate([95, 60, 14]) {
//    rotate([105, 0, 180]) {
//    //rotate([ 90, 0, 180]) {
//        difference() {
//            union() {
//                cube([50.8, 65, 2]);
//                translate([55, 0, 0]) cube([31, 65, 2]);
//                translate([50, 38, 0]) cube([5, 20, 2]);
//                translate([-23, 10, 0]) cube([20, 20, 2]);
//                
//                translate([87, 10, 0]) cube([10, 20, 2]);
//            }
//            translate([0, 51, -1]) cube([6, 14, 4]);
//        }
//    }
//}

// --------- modules --------- //

module enclosure() {
            
    difference() {
        union() {
            difference() {
                cube(dim_case_interior);
                
                translate([4, -1, 4]) {
                    cube([151, 80, 82]);    
                }
            }

            // socket triangle
            translate([49, 13, 0]) {
                rotate([0, 0, 0]) triangle(60, 17);
            }
            
            // socket block
            translate([49, 13, 0]) {
                difference() {  
                    cube([60, 46, 12]);    
                    translate([-10, 42, 4]) {
                        rotate([0, 90, 0]) {
                            difference() {
                                cube([12, 12, 80]);
                                translate([0, 0, -10]) {
                                    cylinder(h = 100, d = 8, $fn=64); 
                                }
                            }
                        }
                    }
                }
                  
            }
            
            // pressure nose top
            translate([48, 0, dim_case_interior[2]-4]) {
                cube([60, 62, 4]);
                translate([0, 62, 2]) rotate([0, 90, 0]) cylinder(d=4, h=60, $fn=32);
            }
            
            // pressure nose bottom right
            translate([0, 0, 0]) {
                cube([20, 62, 4]);
                translate([0, 62, 2]) rotate([0, 90, 0]) cylinder(d=4, h=20, $fn=32);
                translate([20+5, dim_case_interior[1]+5, 0]) {
                    difference() {
                        translate([-5, -5, 0]) cube([5, 5, 4]);
                        translate([0, 0, -1]) cylinder(d=10, h=4+2, $fn=32);
                    }
                }
            }
            
            // pressure nose bottom left
            translate([dim_case_interior[0]-20, 0, 0]) {
                cube([20, 62, 4]);
                translate([0, 62, 2]) rotate([0, 90, 0]) cylinder(d=4, h=20, $fn=32);
                translate([0, dim_case_interior[1]+5, 0]) {
                    difference() {
                        translate([-5, -5, 0]) cube([5, 5, 4]);
                        translate([-5, 0, -1]) cylinder(d=10, h=4+2, $fn=32);
                    }
                }
            }
            
            // front
            difference() {
                cube([dim_case_interior[0], 2, dim_case_interior[2]]);
                translate([dim_case_interior[0]/2,4,dim_case_interior[2]/2]) {
                    rotate([90, 0, 0]) {
                        cylinder(h=10, d=80, $fn=64);
                    }
                }
            }
            
            // battery holder ridges
            
            umts_stick_depth = 10;
            
            translate([152-20.5, 0, 0]) cube([2, dim_case_interior[1]-umts_stick_depth, 15]);
            translate([152-20.5, 0, dim_case_interior[2]-15]) cube([2, dim_case_interior[1]-umts_stick_depth, 15]);
            
            translate([152-13, 0, 0]) cube([2, dim_case_interior[1]-umts_stick_depth, 7]);
            translate([152-13, 0, dim_case_interior[2]-7]) cube([2, dim_case_interior[1]-umts_stick_depth, 7]);
            translate([152-3, 0, dim_case_interior[2]-7]) cube([2, dim_case_interior[1]-umts_stick_depth, 7]);
            
        } // end union
        
        // edges
        
        translate([0, 0, -0.01]) rotated_prism(dim_case_interior[0], dim_case_interior[1], 2.5);
        translate([0, 0, dim_case_interior[2]]) rotate([0, 90, 0]) rotated_prism(dim_case_interior[2], dim_case_interior[1], 2.5);
        translate([dim_case_interior[0], 0, dim_case_interior[2] + 0.01]) rotate([0, 180, 0]) rotated_prism(dim_case_interior[0], dim_case_interior[1], 2.5);
        translate([dim_case_interior[0] + 0.01, 0, 0]) rotate([0, 270, 0]) rotated_prism(dim_case_interior[2], dim_case_interior[1], 2.5);
        
        // threadhole
        translate([75, 28, -1]) {
            camera_threadhole();
        }
        
        // umts stick cutout
        translate([dim_case_interior[0]-32, dim_case_interior[1], dim_case_interior[2]-10]) roundcube(27, 27, 20, 10);        //translate([dim_case_interior[0]-31, dim_case_interior[1], 0]) roundcube(27, 27, 20, 10);
        
        
        // side holes
        
//        offset_l = 5;
//        range_l  = dim_case_interior[2];
//        
//        translate([dim_case_interior[0], 42, offset_l+range_l/5*1]) {
//            rotate([90, 90, 270]) threadhole(10, 6, 3, 20, 10);
//        }
//        translate([dim_case_interior[0], 42, offset_l+range_l/5*2]) {
//            rotate([90, 90, 270]) threadhole(10, 6, 3, 20, 10);
//        }
//        translate([dim_case_interior[0], 42, offset_l+range_l/5*3]) {
//            rotate([90, 90, 270]) threadhole(10, 6, 3, 20, 10);
//        }        
//        translate([dim_case_interior[0], 42, offset_l+range_l/5*4]) {
//            rotate([90, 90, 270]) threadhole(10, 6, 3, 20, 10);
//        }
//        
//        offset_t = 12;
//        range_t  = 100;
//
//        translate([offset_t+range_t/5*0, 22, dim_case_interior[2]-10]) {
//            threadhole(10, 6, 3, 20, 15);
//        }
//        translate([offset_t+range_t/5*1, 22, dim_case_interior[2]-10]) {
//            threadhole(10, 6, 3, 20, 15);
//        }
//        translate([offset_t+range_t/5*2, 22, dim_case_interior[2]-10]) {
//            threadhole(10, 6, 3, 20, 15);
//        }
//        translate([offset_t+range_t/5*3, 22, dim_case_interior[2]-10]) {
//            threadhole(10, 6, 3, 20, 15);
//        }
//        translate([offset_t+range_t/5*4, 22, dim_case_interior[2]-10]) {
//            threadhole(10, 6, 3, 20, 15);
//        }
//        translate([offset_t+range_t/5*5, 22, dim_case_interior[2]-10]) {
//            threadhole(10, 6, 3, 20, 15);
//        }
        
        // side door
        translate([-1, 6, 11]) {
            height = 70;
            width  = 10;
            depth  = 55;
            prism_diff = 2;

            union() {
                cube([width, depth, height]);
                translate([width, 0, 0]) rotate([0, 180, 0]) prism(width, depth, prism_diff);
                translate([0, 0, height]) rotate([0, 0, 0]) prism(width, depth, prism_diff);
            }
}
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
    
    translate([screw_hole_diameter/2, 0, 0]) {
        cylinder(h=height, d=screw_hole_diameter, $fn=64);
    }
    
    translate([screw_hole_diameter/2, length, 0]) {
        cylinder(h=height, d=screw_hole_diameter, $fn=64);
    }
    
    translate([-(socket_diameter/2 - screw_hole_diameter/2), 0, 0]) {
        cube([socket_diameter, length, socket_height]);
    }
    
    translate([screw_hole_diameter/2, 0, 0]) {
        cylinder(h=socket_height, d=socket_diameter, $fn=128);
    }
    
    translate([screw_hole_diameter/2, length, 0]) {
        cylinder(h=socket_height, d=socket_diameter, $fn=128);
    }
}

module camera() {

    translate([0, -17, 0]) {
        cube([40, 17, 67]);
    }
    translate([88, 27, 51]) {
        cube([36, 10, 20]);
    }

    // tripod screw thread
    difference() {
        cube([120, 27, 67]); // <--
        translate([78, 15, -1]) {
            cylinder(h = 5, d = 8);
        }
    }
    translate([78, 15, 3]) {
        color([1, 0, 0]) cylinder(h = 1, d = 8);
    }
    
    // knobs
    translate([20, 15, 67]) {
        cylinder(h = 1.5, d = 14);
    }
    translate([40, 15, 67]) {
        cylinder(h = 1.5, d = 14);
    }
    
    // belt attachment holder
    translate([-6, 20, 54]) {
        cube([6, 1, 6]);
    }
    translate([120, 20, 54]) {
        cube([6, 1, 6]);
    }

    // lens mount and lens
    translate([78, 0, 32]) {
        rotate([90]) {
            color([1,0,0]) cylinder(h = 5, d = 60);
            
            // lens
            translate([0, 0, 5]) {
            cylinder(h = 23, d = 62);
            }
        }
    }
    
    // port door
    translate([120, 8, 9]) cube([9, 1, 27]);
}

module battery_18650() {
    difference() {
        cylinder(h = 65, d = 18);
        translate([0, 0, 64.5]) {
            cylinder(h = 1, d = 14); 
        }  
    }
    
    translate([0, 0, 64]) {
        cylinder(h = 2, d = 8); 
    }   
}

module battery_holder() {
    difference() {
        color([1, 1, 1]) cube(dim_battery_holder);
        translate([-2, 1, 1]) {
            cube([22.54, 38.21, 75.7]);
        }
    }
    
    translate([10, 29, 5]) {
        battery_18650();
    }
    
    translate([10, 10, 5]) {
        battery_18650();
    }    
}

module filter_adapter() {
    difference() {
        rotate([90, 0, 0]) cylinder(h=3, d=82);
        translate([0, 1, 0]) rotate([90, 0, 0]) cylinder(h=5, d=77);
    }
}

module rotated_prism(l, w, h) {
    translate([l, w, 0]) rotate([0, 0, 180]) prism(l, w, h);
}

// ----- support ------- //

module roundcube(width, depth, height, radius) {
    
    cube([width-radius, depth-radius, height]);
    
    translate([-radius, 0, 0]) cube([width-radius, depth-radius, height]);    
    translate([radius, 0, 0]) cube([width-radius, depth-radius, height]);
    translate([0, radius, 0]) cube([width-radius, depth-radius, height]);
    translate([0, -radius, 0]) cube([width-radius, depth-radius, height]);

    translate([0, 0, 0]) cylinder(h=height, d=radius*2, $fn=64);
    translate([width-radius, 0, 0]) cylinder(h=height, d=radius*2, $fn=64);
    translate([0, depth-radius, 0]) cylinder(h=height, d=radius*2, $fn=64);
    translate([width-radius, depth-radius, 0]) cylinder(h=height, d=radius*2, $fn=64);
    
}

module triangle(width, height) {
   
    // a^2 = c^2
    // a = sqrt ( c^2 / 2 )
                
    a       = sqrt(pow(height, 2) / 2);
                
    translate([0, 0, -a]) {
        intersection() {
            rotate([45, 0, 0]) cube([width, height, height]);
            translate([0, -a, a]) cube([width, a, a]);
        }
    } 
}   

module prism(l, w, h){
    polyhedron(points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]], faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]);
}