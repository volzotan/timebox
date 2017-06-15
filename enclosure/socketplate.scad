include <camera.scad>;
include <enclosure_util.scad>;

size_top    = [165, 98, 0.1];

translate([size_top[0]/2 - 39.5, 43, -12]) socketplate();

module socketplate(marker=false) { 
    
    // 1/4 Nut Height: 5.6  Width: 11.1
    // M5 Nut  Height: 3.2  Width: 8 
    
//    color("green") {
//        translate([3, 3.3, 10]) cube([8,8,2]);
//        translate([34, 14.7, 10]) cube([11.1,11.1,2]);
//    }

    dist        = 7; // should be 6 actually
    nutM5       = 10; // ?
    nut14Inch   = 13.5; // ?

    if (marker) {
        translate([dist,    dist,       -1]) cylinder(d=5.3, h=50, $fn=32);
        translate([80-dist, dist,       -1]) cylinder(d=5.3, h=50, $fn=32);
        translate([dist,    40-dist,    -1]) cylinder(d=5.3, h=50, $fn=32); 
        translate([80-dist, 40-dist,    -1]) cylinder(d=5.3, h=50, $fn=32);
    }
    
    union() {
    difference() {
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
            cylinder(d=nut14Inch, h=7, $fn=6); // h=6
        }
//        translate([(80/4)*3, 40/2, -1]) {
//            cylinder(d=6.4, h=12, $fn=32);  
//            translate([0, 0, 2]) cylinder(d=nut14Inch, h=6, $fn=6); 
//        }
            
        // test
        // translate([-1, -1, -1]) cube([7, 100, 30]);
    }
    
        // support layer to properly print hole
        //translate([0, 0, 3]) color([1,1,1,0.5]) cube([15, 15, 0.2]);
    
        translate([25, 5, 6]) color("green") cube([30, 30, 0.2]);
    }
}