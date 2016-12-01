module controllerHolder() {

    width = 160;
    depth = 93;

    translate([54, 14, 0]) {
        color([0.7, 0.7, 0.7]) translate([0, 0, 3]) import(file = "controller4.dxf");

        translate([0,   53.3,   0]) pug();
        translate([33,  65,     0]) pug();
        translate([33,  10,     0]) pug();
        translate([61,  3.5,    0]) pug();
        translate([84,  3.5,    0]) pug();
        translate([61,  61.5,   0]) pug();
        translate([84,  61.5,   0]) pug();
    }


    difference() {
        union() {
            translate([0, 0, 0]) cube([width, depth, 1]);
            color([0.3, 0.3, 0.3]) translate([10, depth-10, 0]) cube([width-20, 1, 1.1]);
        }

        translate([-0.01, -0.01, -1])           rotate([0, 0, 0]) cornercutout(10);
        translate([width+0.01, -0.01, -1])      rotate([0, 0, 90]) cornercutout(10);
        translate([width+0.01, depth+0.01, -1]) rotate([0, 0, 180]) cornercutout(10);
        translate([-0.01, depth+0.01, -1])      rotate([0, 0, 270]) cornercutout(10);
    }

    // modules

    module pug() {
        cylinder(h=5, d=2.5, $fn=32);
        translate([0, 0, 4]) cylinder(h=1, r1=1.5, r2=1.25, $fn=32);
    }

    module cornercutout(diameter) {
        difference() {
            cube([diameter, diameter, 10]);
            translate([diameter, diameter, 0]) cylinder(h=12, d=diameter*2);
        } 
    }
}
