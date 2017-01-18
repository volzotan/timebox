// controllerHolder();

module controllerHolder() {

    width = 160; // +2
    depth = 95;  // -1
    height = 2;
    curvature_height = 3;
    
    draw_pcb = false;
    
    pcb_offset = [55, 17, 5];

    translate(pcb_offset) {
        if (draw_pcb) {
        color([0.7, 0.7, 0.7]) translate([0, 0, 3]) import(file = "controller4.dxf");
        }
    }


    difference() {
        translate([width, 0, height+curvature_height]) rotate([0, 180, 0]) baseplate();
        
        translate(pcb_offset) {
            translate([0,   53.3,   -10]) pug();
            translate([33,  65,     -10]) pug();
            translate([33,  10,     -10]) pug();
            translate([66,  3.5,  -10]) pug();
            translate([89,  3.5,  -10]) pug();
            translate([66,  61.5, -10]) pug();
            translate([89,  61.5, -10]) pug();
        }
        
        // viewfinder cutout
        translate([32.5, 7.5, -1]) cube([40, 25, 10]);
    
        // pi cutout
        translate([124.5, 18.5, -1]) {
            cube([16, 62, 10]);    
        }
        translate([118.5, 24, -1]) {
            cube([28, 51, 10]);    
        }
        
//        // pressure cutouts
//        translate([width-1.6, 10, -1]) {
//            cube([0.8, depth-20, 10]);    
//        }
//        
//        translate([width-3.2, 10, -1]) {
//            cube([0.8, depth-20, 10]);    
//        }
    }
    


    // modules
    
    module baseplate() {
        
        rounding_diameter   = 5;
        rounding_diameter2  = 10;
        
        difference() {
            union() {
                intersection() {
                    diameter = 772;
                    offset = -diameter/2 + height + curvature_height;
                    
                    translate([0, 0, height]) cube([width, depth, curvature_height]);
                    translate([0, depth/2, offset]) rotate([0, 90, 0]) {
                        cylinder(h=width, d=diameter, $fn=512);
                    }
                }        
                translate([0, 0, 0]) cube([width, depth, height]);

            }
        
            translate([-0.01, -0.01, 0]) difference() {
                cube([width+0.02, rounding_diameter/2, rounding_diameter/2]);
                translate([0, rounding_diameter/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter, $fn=128);
            }
            translate([width-0.01, depth-0.01, 0]) rotate([180, 180, 0]) difference() {
                cube([width+0.02, rounding_diameter/2, rounding_diameter/2]);
                translate([0, rounding_diameter/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter, $fn=128);
            }
            translate([width+0.01, 0.01, 0]) rotate([0, 0, 90]) difference() {
                cube([depth+0.02, rounding_diameter2/2, rounding_diameter2/2]);
                translate([0, rounding_diameter2/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter2, $fn=128);
            }
            translate([-0.01, depth-0.01, 0]) rotate([0, 0, 270]) difference() {
                cube([depth+0.02, rounding_diameter2/2, rounding_diameter2/2]);
                translate([0, rounding_diameter2/2, 0]) rotate([0, 90, 0]) cylinder(h=width, d=rounding_diameter2, $fn=128);
            }
        }
        
        
//                    translate([-0.01, -0.01, -1])           rotate([0, 0, 0]) cornercutout(10);
//                    translate([width+0.01, -0.01, -1])      rotate([0, 0, 90]) cornercutout(10);
//                    translate([width+0.01, depth+0.01, -1]) rotate([0, 0, 180]) cornercutout(10);
//                    translate([-0.01, depth+0.01, -1])      rotate([0, 0, 270]) cornercutout(10);
            
    }

    module pug() {
        cylinder(h=20, d=2.8, $fn=32);
    }

    module cornercutout(diameter) {
        difference() {
            cube([diameter, diameter, 10]);
            translate([diameter, diameter, 0]) cylinder(h=12, d=diameter*2);
        } 
    }
}
