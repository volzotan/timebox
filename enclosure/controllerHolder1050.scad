// controllerHolder();

module controllerHolder() {

    width = 158;
    depth = 96;
    height = 1.5;
    
    draw_pcb = false;

    translate([54, 17, 0]) {
        if (draw_pcb) {
        color([0.7, 0.7, 0.7]) translate([0, 0, 3]) import(file = "controller4.dxf");
        }

        translate([0,   53.3,   0]) pug();
        translate([33,  65,     0]) pug();
        translate([33,  10,     0]) pug();
        translate([65,  3.5,    0]) pug();
        translate([88,  3.5,    0]) pug();
        translate([65,  61.5,   0]) pug();
        translate([88,  61.5,   0]) pug();
    }


    difference() {
        baseplate();
        
        // viewfinder cutout
        translate([31.5, 7.5, -1]) cube([40, 25, 10]);
    
        // pi cutout
        translate([122, 18.5, -1]) {
            cube([17, 62, 10]);    
        }
        translate([117, 24, -1]) {
            cube([27, 51, 10]);    
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
        translate([0, depth, height])
        rotate([180, 0, 0])
        hull() {
            translate([0, 0, 0]) {

                difference() {
                    union() {
                        translate([0, 0, 0]) color([1, 1, 1, 0.3]) cube([width, depth, 0.1]);
                        // side pressure nose
                        // translate([width, depth/2, 0]) cylinder(h=height, d=3, $fn=32);
                    }

                    translate([-0.01, -0.01, -1])           rotate([0, 0, 0]) cornercutout(10);
                    translate([width+0.01, -0.01, -1])      rotate([0, 0, 90]) cornercutout(10);
                    translate([width+0.01, depth+0.01, -1]) rotate([0, 0, 180]) cornercutout(10);
                    translate([-0.01, depth+0.01, -1])      rotate([0, 0, 270]) cornercutout(10);
                }
            }
            translate([1, 1, height]) {

                scale([0.98, 0.98]) difference() {
                    union() {
                        translate([0, 0, 0]) color([1, 1, 1, 0.3]) cube([width, depth, 0.1]);
                        // side pressure nose
                        // translate([width, depth/2, 0]) cylinder(h=height, d=3, $fn=32);
                    }

                    translate([-0.01, -0.01, -1])           rotate([0, 0, 0]) cornercutout(10);
                    translate([width+0.01, -0.01, -1])      rotate([0, 0, 90]) cornercutout(10);
                    translate([width+0.01, depth+0.01, -1]) rotate([0, 0, 180]) cornercutout(10);
                    translate([-0.01, depth+0.01, -1])      rotate([0, 0, 270]) cornercutout(10);
                }
            }
        }
    }

    module pug() {
        cylinder(h=5, d=2.5, $fn=32);
        translate([0, 0, 4.5]) cylinder(h=0.5, r1=1.4, r2=1.25, $fn=32);
        translate([0, 0, 4]) cylinder(h=0.5, r1=1.25, r2=1.4, $fn=32);
    }

    module cornercutout(diameter) {
        difference() {
            cube([diameter, diameter, 10]);
            translate([diameter, diameter, 0]) cylinder(h=12, d=diameter*2);
        } 
    }
}
