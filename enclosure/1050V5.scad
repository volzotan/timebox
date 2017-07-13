include <clamp_1050.scad>;

size_btm    = [157, 90];
size_top    = [165, 99];
height      = 48;

difference() {
    union() {
        translate([80, 50, 7]) rotate([0, 0, 180]) clamp();
        translate([0, 8, 0.01]) angle_corrector();
    }
    translate([-1, 0, 0]) cutter();
}

translate([100, 0, 0]) { //difference() {
    union() {
        translate([0, 42+7, 10]) rotate([180, 0, 0]) plate();
    }
    translate([0, 5, 10]) cutter(length=80);
}



module cutter(length=100) {
    points = [[0, 0], [48, 0], [0, 4.5]];
    rotate([90, 0, 90]) color("red") linear_extrude(height=length) polygon(points);
}

module angle_corrector() {
    difference() {
        translate([0, 0, 0]) cube([80, 42, 4]);

        dist    = 7;
        offset  = 2;
        translate([0, -2, -1]) {
            translate([dist, dist+offset]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, dist+offset]) cylinder($fn=32, h=12, d=5.3);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
        }
    }
}


// ---------------------------------------------------------




// ---------------------------------------------------------
