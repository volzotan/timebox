// GLOBAL VARS

// dim_case_interior   = [160,     55,     93  ];
dim_case_interior   = [160,     55,     94  ];
dim_battery_holder  = [21.54,40.21,     77.7];
connector_diameter  = 4;

assembled           = false;

// ----------------------------------------------

if (assembled) {
    translate([6, 0, 0]) cage_bottom();
    cage_side_right();
    translate([159, 0, 0]) cage_side_left();
    translate([6, 0, dim_case_interior[2]-10]) cage_top();
} else {
    translate([0, 65, 10])      rotate([180, 0, 0]) cage_bottom();
    translate([0, 70, 0])       rotate([0, 0, 0]) cage_top();
    translate([0, 135, 4])      rotate([0, 90, 0])  cage_side_right();
    translate([195, 135, 0])    rotate([0, -90, 0]) cage_side_left();
}

// translate([240, 0, 0]) color([0.2, 0.3, 0.9, 0.9]) enclosure();

// translate([134, 10, 8]) battery_holder();
// translate([7, 26, 12]) camera();
// translate([dim_case_interior[0]/2, 0, 46]) color([0.5, 0.5, 0.5, 1]) filter_adapter();

// pelicase 
//color([0, 0, 0, 0.1]) cube([160, 70, 93]);

color([0.3, 0.3, 0.3, 0.8]) translate([95, 60, 14]) pcb();

// --------- modules --------- //

module cage_side_right() {
    height                      = dim_case_interior[2];
    depth                       = dim_case_interior[1];
    width                       = 4;
    connector_bottom_distance   = 5;

    difference() {
        cube([width, depth, height]);

        // side door
        translate([-2, 20, 62]) {
            union() {
                cube([10, 25, 14]);
                translate([0, 25, 7]) {
                    rotate([0, 90, 0]) cylinder(h=10, d=14);
                }
                translate([0, 0, 7]) {
                    rotate([0, 90, 0]) cylinder(h=10, d=14);
                }
            }
        }

        // connector holes
        translate([-0.5, 10, height-connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([-0.5, 45, height-connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([-0.5, 10, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([-0.5, 45, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);

        // edge
        translate([0,       -0.01,  -0.01])                          rotated_prism(width, 3, 3);
        translate([-0.01,   -0.01,      0]) rotate([-90, -90, 0])    rotated_prism(height, 3, 3);
        translate([0,       0,     height]) rotate([-90,   0, 0])    rotated_prism(width, 3, 3);
    }
}

module cage_side_left() {
    height                      = dim_case_interior[2];
    depth                       = dim_case_interior[1];
    width                       = 4;
    connector_bottom_distance   = 5;

    difference() {
        cube([width, depth, height]);

        // battery holder holes
        translate([width+0.5, 24, height/2]) {
            rotate([90, 90, 270]) threadhole(3, 6, 3, 10, 10);
        }
        translate([width+0.5, 44, height/2]) {
            rotate([90, 90, 270]) threadhole(3, 6, 3, 10, 10);
        }

        // connector holes
        translate([width-0.5, 10, height-connector_bottom_distance])    rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([width-0.5, 45, height-connector_bottom_distance])    rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([width-0.5, 10, connector_bottom_distance])           rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([width-0.5, 45, connector_bottom_distance])           rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);

        // edge
        translate([0,           -0.01, height+0.01])    rotate([-90, 0, 0]) rotated_prism(width, 3, 3);
        translate([width+0.01,  -0.01, 0])              rotate([0, -90, 0]) rotated_prism(height, 3, 3);
        translate([0,           -0.01, -0.01])          rotate([0, 0, 0])   rotated_prism(width, 3, 3);
    }
}

module cage_top() {
    top_length                  = dim_case_interior[0]-8;
    depth                       = dim_case_interior[1];
    sideblock_length            = 10;
    sideblock_height            = 10;
    baseplate_height            = 4;
    connector_bottom_distance   = 5;

    difference() {
        union() {
            translate([0, 0, sideblock_height-baseplate_height]) cube([top_length, depth, baseplate_height]); // baseplate

            // sideblocks
            translate([0, 0, 0]) cube([sideblock_length, depth, sideblock_height]);
            translate([top_length-sideblock_length, 0, 0]) cube([sideblock_length, depth, sideblock_height]);
        }

        // connector holes
        translate([-0.5, 10, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([-0.5, 45, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([top_length-0.5, 10, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([top_length-0.5, 45, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);

        // spacer holes
        translate([20,          10,         sideblock_height-baseplate_height-0.5]) cylinder(h=1, d=connector_diameter);
        translate([20,          depth-10,   sideblock_height-baseplate_height-0.5]) cylinder(h=1, d=connector_diameter);
        translate([top_length-20, 10,       sideblock_height-baseplate_height-0.5]) cylinder(h=1, d=connector_diameter);
        translate([top_length-20, depth-10, sideblock_height-baseplate_height-0.5]) cylinder(h=1, d=connector_diameter);
        translate([20,          10,         sideblock_height-0.5])                  cylinder(h=1, d=connector_diameter);
        translate([20,          depth-10,   sideblock_height-0.5])                  cylinder(h=1, d=connector_diameter);
        translate([top_length-20, 10,       sideblock_height-0.5])                  cylinder(h=1, d=connector_diameter);
        translate([top_length-20, depth-10, sideblock_height-0.5])                  cylinder(h=1, d=connector_diameter);

        // edge
        translate([0, -0.01, sideblock_height+0.01]) rotate([-90, 0, 0]) rotated_prism(top_length, 3, 3);
    }
}

module cage_bottom() {
    bottom_length               = dim_case_interior[0]-8;
    depth                       = dim_case_interior[1];
    sideblock_length            = 10;
    sideblock_height            = 10;
    baseplate_height            = 4;
    connector_bottom_distance   = 5;

    difference() {
        union() {
            cube([bottom_length, depth, baseplate_height]); // baseplate

            // socket block
            translate([48, 16, 0]) {
                difference() {  
                    cube([60, 50, 10]);    
                    translate([-10, 40, 10]) {
                        rotate([0, 90, 0]) {
                            difference() {
                                cube([12, 12, 80]);
                                translate([0, 0, -10]) {
                                    cylinder(h = 100, d = 20); 
                                }
                            }
                        }
                    }
                }
            }

            // sideblocks
            translate([0, 0, 0]) cube([sideblock_length, depth, sideblock_height]);
            translate([bottom_length-sideblock_length, 0, 0]) cube([sideblock_length, depth, sideblock_height]);

        }

        // threadhole
        translate([75, 28, -1]) {
            camera_threadhole();
        }

        // connector holes
        translate([-0.5, 10, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([-0.5, 45, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([bottom_length-0.5, 10, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);
        translate([bottom_length-0.5, 45, connector_bottom_distance]) rotate([0, 90, 0]) cylinder(h=1, d=connector_diameter);

        // edge
        translate([0, -0.01, -0.01]) rotated_prism(bottom_length, 3, 3);
    }

}

module enclosure() {
            
    difference() {
        union() {
            difference() {
                cube(dim_case_interior);
                
                translate([4, -1, 4]) {
                    cube([152, 80, 86]);    
                }
            }

            // socket triangle
            translate([52, 16, 0]) {
                rotate([0, 0, 0])
                
                
                triangle(60, 17);
            }
            // socket block
            translate([52, 16, 0]) {
                difference() {  
                    cube([60, 50, 12]);    
                    translate([-10, 40, 10]) {
                        rotate([0, 90, 0]) {
                            difference() {
                                cube([12, 12, 80]);
                                translate([0, 0, -10]) {
                                    cylinder(h = 100, d = 20); 
                                }
                            }
                        }
                    }
                }
            }
            
            // front
            difference() {
                cube([dim_case_interior[0], 3, dim_case_interior[2]]);
                translate([dim_case_interior[0]/2,4,46]) {
                    rotate([90, 0, 0]) {
                        cylinder(h=10, d=80);
                    }
                }
            }
            
            battery_holder_distance = dim_case_interior[0] - 7 - dim_battery_holder[0] - 2;
            translate([battery_holder_distance, 0, 0]) {
                cube([2, dim_case_interior[1], 7]);
            }
            translate([battery_holder_distance, 0, dim_case_interior[2] - 12]) {
                cube([2, dim_case_interior[1], 12]);
            }
            
        }
        
        // edges
        
        translate([0, 0, -0.01]) rotated_prism(dim_case_interior[0], dim_case_interior[1], 2.5);
        translate([0, 0, dim_case_interior[2]]) rotate([0, 90, 0]) rotated_prism(dim_case_interior[2], dim_case_interior[1], 2.5);
        translate([dim_case_interior[0], 0, dim_case_interior[2] + 0.01]) rotate([0, 180, 0]) rotated_prism(dim_case_interior[0], dim_case_interior[1], 2.5);
        translate([dim_case_interior[0] + 0.01, 0, 0]) rotate([0, 270, 0]) rotated_prism(dim_case_interior[2], dim_case_interior[1], 2.5);
        
        // threadhole
        translate([79, 28, -1]) {
            camera_threadhole();
        }
        
        // battery holder holes
        translate([dim_case_interior[0], 24, dim_case_interior[2]/2]) {
            rotate([90, 90, 270]) threadhole(3, 6, 3, 10, 10);
        }
        translate([dim_case_interior[0], 44, dim_case_interior[2]/2]) {
            rotate([90, 90, 270]) threadhole(3, 6, 3, 10, 10);
        }
        
        // tripod mount holes
        translate([dim_case_interior[0]/2, 22, -1]) {
            space = [83, 40];
            height = 4;
            diameter = 13; //7.5;

            //cube([space[0], space[1], 10], center=true);
            
            translate([30, 0, 0]) cylinder(h=height, d=diameter);
            translate([-30, 0, 0]) cylinder(h=height, d=diameter);
        }

        // camera battery door hole
        translate([4, 14, 1]) {
        //     cube([46, 42, 10]);
            
            // cuttingholes
//            translate([1, 1, -1]) {
//                cylinder(h=2, d=2);
//            }
//            translate([46-2, 1, -1]) {
//                cylinder(h=2, d=2);
//            }
//            translate([1, 34-2, -1]) {
//                cylinder(h=2, d=2);
//            }
//            translate([46-2, 34-2, -1]) {
//                cylinder(h=2, d=2);
//            }
        }
        
        // side door
        translate([-2, 20, 62]) 
        union() {
            cube([10, 25, 14]);
            translate([0, 25, 7]) {
                rotate([0, 90, 0]) cylinder(h=10, d=14);
            }
            translate([0, 0, 7]) {
                rotate([0, 90, 0]) cylinder(h=10, d=14);
            }
        }
    }
}

module camera_threadhole() {
    // 1/4 inch = 0,635cm
    screw_hole_diameter = 7;
    socket_diameter     = 24;
    socket_height       = 5;
    length              = 25;
    height              = 14;
    
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
        cylinder(h=height, d=screw_hole_diameter);
    }
    
    translate([screw_hole_diameter/2, length, 0]) {
        cylinder(h=height, d=screw_hole_diameter);
    }
    
    translate([-(socket_diameter/2 - screw_hole_diameter/2), 0, 0]) {
        cube([socket_diameter, length, socket_height]);
    }
    
    translate([screw_hole_diameter/2, 0, 0]) {
        cylinder(h=socket_height, d=socket_diameter);
    }
    
    translate([screw_hole_diameter/2, length, 0]) {
        cylinder(h=socket_height, d=socket_diameter);
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

module pcb() {
// rotate([105, 0, 180]) {
//  difference() {
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
//}
}

module rotated_prism(l, w, h) {
    translate([l, w, 0]) rotate([0, 0, 180]) prism(l, w, h);
}

// ----- support ------- //

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