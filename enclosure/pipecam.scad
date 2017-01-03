height          = 140;
socket_diameter = 70;
outer_diameter  = 67;
inner_diameter  = 60;
nudge_diameter  = 62;
cutout_start    = 30;

translate([-100, 0, 0]) lower_half();
translate([0, 0, cutout_start]) upper_half();

module upper_half() {
    uh_height = height-cutout_start;
    
    translate([0, 0, uh_height]) cylinder(h=5, d=socket_diameter, $fn=64);
    
    difference() {
        union() {
            difference() {
                cylinder(h=uh_height, d=outer_diameter, $fn=64);
                translate([-outer_diameter/2, 0,  -1]) cube([outer_diameter, outer_diameter/2, uh_height+2]);
            }
            
            difference() {
                cylinder(h=uh_height, d=nudge_diameter, $fn=64);
                translate([-outer_diameter/2, 5, -1]) cube([outer_diameter, outer_diameter/2, uh_height+2]);
            }
        }
        translate([0, 0, -1]) cylinder(h=uh_height+2, d=inner_diameter, $fn=64);
        
        // nub
        
        translate([-5, -35, -30]) {
            cube([10, 10, 30]);
            translate([5, 10, 30]) rotate([90, 0, 0]) cylinder(h=10, d=10, $fn=64);
        }
    }
    
    // nub2
    intersection() {
        translate([-5, 34, 135-cutout_start]) rotate([90, 0, 0]) threadhole(10, 5, 8, 15, 5); 
        translate([0, 0, 5]) cylinder(h=uh_height, d=outer_diameter, $fn=64);
    }
    
}

module lower_half() {
difference() {
    union() {
        difference() {
            union() {
                // socket cylinder
                cylinder(h=10, d=socket_diameter, $fn=64);
                
                // normal cylinder
                translate([]) cylinder(h=140, d=outer_diameter, $fn=64);
            }
            
            translate([0, 0, -1]) cylinder(h=142, d=inner_diameter, $fn=64);
            translate([0, 0, -1]) cylinder(h=3, d=66, $fn=64);
            difference() {
                translate([-50, -100, cutout_start]) cube([100, 100, height]);
                translate([-5, -37, 0]) {
                    
                    // nub
                    cube([10, 10, 30], $fn=64);
                    translate([5, 10, 30]) rotate([90, 0, 0]) cylinder(h=10, d=10);
                }
            }
        }
        translate([-15, inner_diameter/2-4, 2]) cube([30, 2, height-2]);
        translate([-10, inner_diameter/2-2, 2]) cube([20, 2, height-2]);
    }
    translate([-3.5, 36, 30]) rotate([90, 0, 0]) camera_threadhole();  translate([-3.5, 36, 65]) rotate([90, 0, 0]) camera_threadhole();
    
    translate([0, 0, cutout_start-5]) {
        difference() {
            cylinder(h=140, d=nudge_diameter+0.5, $fn=64); // +0.5 to accomodate printer precision
            translate([-outer_diameter/2, 5, 0]) cube([outer_diameter, outer_diameter/2, height]);
        }
    }
    
    translate([-5, 34, 135]) rotate([90, 0, 0]) threadhole(10, 5, 10, 15, 5);  
    translate([0, 35, 110]) rotate([90, 0, 0]) cylinder(h=10, d=5, $fn=64);
    translate([0, 35, 110]) rotate([90, 0, 0]) cylinder(h=3, d=8, $fn=64);
    translate([0, 28, 110]) rotate([90, 0, 0]) cylinder(h=3, d=8, $fn=64);
}

}

// -------------------------------------------------------------

module camera_threadhole() {
    // 1/4 inch = 0,635cm
    screw_hole_diameter = 7;
    socket_diameter     = 24;
    socket_height       = 8;
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
        cylinder(h=height, d=screw_hole_diameter, $fn=32);
    }
    
    translate([screw_hole_diameter/2, length, 0]) {
        cylinder(h=height, d=screw_hole_diameter, $fn=32);
    }
    
    translate([-(socket_diameter/2 - screw_hole_diameter/2), 0, 0]) {
        cube([socket_diameter, length, socket_height]);
    }
    
    translate([screw_hole_diameter/2, 0, 0]) {
        cylinder(h=socket_height, d=socket_diameter, $fn=32);
    }
    
    translate([screw_hole_diameter/2, length, 0]) {
        cylinder(h=socket_height, d=socket_diameter, $fn=32);
    }
}