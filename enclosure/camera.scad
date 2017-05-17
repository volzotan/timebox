module camera(longlens=false) {

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

            if (longlens) {
                translate([0, 0, 5]) {
                    cylinder(h = 63, d = 73);
                }
            } else {
                translate([0, 0, 5]) {
                    cylinder(h = 23, d = 62);
                }
            }
        }
    }
    
    // port door
    translate([120, 8, 9]) cube([9, 1, 27]);
}
