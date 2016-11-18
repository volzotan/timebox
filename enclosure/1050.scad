// GLOBAL VARS

dim_case_interior   = [160,     55,     93  ];
dim_battery_holder  = [21.54,40.21,     77.7];


translate([5, 126, 12]) camera();

//color([0.2, 0.3, 0.9, 0.9]) enclosure();
//translate([200, 0, 0]) color([0.2, 0.3, 0.9]) enclosure1120();

translate([134, 10, 5]) battery_holder();

translate([84, 0, 45]) color([0.5, 0.5, 0.5, 0.5]) uv_filter();

// pelicase 
//color([0, 0, 0, 0.1]) cube([160, 70, 93]);

//color([0.3, 0.3, 0.3, 0.8]) translate([110, 60, 14]) {
//    rotate([135, 0, 180]) {
//    //rotate([ 90, 0, 180]) {
//        cube([50.8, 65, 2]);
//        translate([55, 0, 0]) cube([31, 65, 2]);
//        translate([50, 38, 0]) cube([5, 20, 2]);
//        translate([-23, 10, 0]) cube([20, 20, 2]);
//        
//        translate([0, 50, 0]) cube([20, 14, 2]);
//    }
//}

// --------- modules --------- //

module enclosure1120() {
            
    difference() {
        cube([184, 78, 121]);
        translate([4, 4, 4]) cube([176, 78, 113]);
    }
}

module enclosure() {
            
    difference() {
       
        union() {
            difference() {
                cube(dim_case_interior);
                
                translate([4, -1, 4]) {
                    cube([152, 80, 85]);    
                }
                
                translate([12, 58, 72]) {
                    rotate([90, 0, 0]) {
                        cylinder(h=45, d=20);
                    }
                } 
            
            }

            // socket triangle
            translate([54, 16, 3.5]) {
                rotate([0, 0, 0])
                triangle(60, 12);
            }
            // socket block
            translate([54, 16, 0]) {
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
                cube([160, 3, 93]);
                translate([84,4,46]) {
                    rotate([90, 0, 0]) {
                        cylinder(h=10, d=80);
                    }
                }
            }
            
            battery_holder_distance = dim_case_interior[0] - 4 - dim_battery_holder[0] - 2;
            translate([battery_holder_distance, 0, 0]) {
                cube([2, dim_case_interior[1], 10]);
            }
            translate([battery_holder_distance, 0, dim_case_interior[2] - 15]) {
                cube([2, dim_case_interior[1], 15]);
            }
            
        }
        
        // edges
        
//        translate([-1, 0, -1]) {
//            rotate([270, 0, 0]) triangle(162, 3);
//        }
//        
//        translate([0-1, 0, 94]) {
//            rotate([270, 90, 0]) triangle(95, 3);
//        }
//        
//        translate([-1, 0, 94]) {
//            rotate([180, 0, 0]) triangle(162, 3);
//        }
//        
//        translate([161, 0, 94]) {
//            rotate([180, 90, 0]) triangle(95, 3);
//        }
        
        // threadhole
        translate([81, 28, -1]) {
            camera_threadhole();
        }
        
        // battery holder holes
        translate([161, 20, 93/2]) {
            rotate([90, 90, 270]) threadhole(3, 6, 3, 3, 10);
        }
        translate([161, 40, 93/2]) {
            rotate([90, 90, 270]) threadhole(3, 6, 3, 3, 10);
        }
        
        // camera battery door hole
        translate([4, 15, 1]) {
            roundcube(46, 34, 10, 5);
            
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
        translate([-2, 10, 10]) cube([10, 50, 75]);
    }
}

module triangle(height=3, length=15) {    
    polyhedron(
        points=[ 
        [ 0, 0, 0], [length, 0, 0], [0, length, 0],
        [ 0, 0, height], [length, 0, height], [0, length, height]],
        faces=[
        [0, 1, 2], [3, 4, 5], [0, 1, 4, 3],
        [1, 2, 5, 4], [0, 2, 5, 3]
        ]
    );
}

module camera_threadhole() {
    // 1/4 inch = 0,635cm
    screw_hole_diameter = 7;
    socket_diameter     = 24;
    socket_height       = 4;
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
    translate([-1, 20, 57]) {
        rotate([90, 90, 0]) {
            cylinder(h = 2, d = 3.5);
        }
    }
    translate([121, 20, 57]) {
        rotate([90, 90, 0]) {
            cylinder(h = 2, d = 3.5);
        }
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

module uv_filter() {
    rotate([90, 0, 0]) cylinder(h=5, d=82);
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

module roundcube(x, y, height, cornerdiameter) {
    
    module corner_rounder(height, cornerdiameter) {
        translate(0, 0, 0) {
            difference() {   
                cube([cornerdiameter+2, cornerdiameter+2, height+2]);
                cylinder(h=height+2, d = cornerdiameter);
            }
        }
    }
    
    difference() {
        cube([x, y, height]);
        translate([cornerdiameter/2, cornerdiameter/2, -1]) {
            rotate([0, 0, 180]) {
                corner_rounder(height, cornerdiameter);
            }
        }

        translate([cornerdiameter/2, y-cornerdiameter/2, -1]) {
            rotate([0, 0, 90]) {
                corner_rounder(height, cornerdiameter);
            }
        }
        
        translate([x-cornerdiameter/2, cornerdiameter/2, -1]) {
            rotate([0, 0, 270]) {
                corner_rounder(height, cornerdiameter);
            }
        }
        
        translate([x-cornerdiameter/2, y-cornerdiameter/2, -1]) {
            rotate([0, 0, 0]) {
                corner_rounder(height, cornerdiameter);
            }
        }
    }
}