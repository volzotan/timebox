pi_size = [65, 30, 1];
bottom_thickness = 2;
enclosure_bottom = [67, 32, bottom_thickness];

screw_inner_diam = 3.2;
screw_outer_diam = 6;
screw_quality = 32;

translate([0, 0, 10]) example();
translate([20, -20, 0]) usb();

translate([0, 0, 50]) pi_spacer(3, 10);
translate([0, 0, 30]) corner_holder();



//

difference() {
    union() {
        cube(enclosure_bottom);
        corner_holder();
        translate([enclosure_bottom[0], 0, 0])           rotate([0, 0, 90]) corner_holder();
        translate([enclosure_bottom[0], enclosure_bottom[1], 0])  rotate([0, 0, 180]) corner_holder();
        translate([0, enclosure_bottom[1], 0])           rotate([0, 0, 270]) corner_holder();
    }
    translate([1, 1, 7.01]) pi_bottom();
}

translate([75, 0, 0]) rotate([0, 90, 0]) difference() {
    cube([0.8, 32, 50]);
    translate([-1, (32-5)/2, 25]) cube([3, 5, 2]);
}

translate([-10, 0, 0]) rotate([0, -90, 0]) difference() {
    cube([0.8, 32, 50]);
    translate([-1, (32-10)/2, 15]) cube([3, 10, 5]);
    translate([-1, 20, 25]) rotate([0, 90, 0]) cylinder(h=3, d=5, $fn=32);
}

module corner_holder() {
    translate([3, 3, 0]) cylinder(h=8, d=screw_outer_diam, $fn=screw_quality);
    translate([0, 0, 0]) cube([screw_outer_diam, screw_outer_diam/2, 8]);
    translate([0, 0, 0]) cube([screw_outer_diam/2, screw_outer_diam, 8]);
}

module pi_spacer(distance, height) {
    translate([distance, distance, 0]) difference() {
        cylinder(h=height, d=screw_outer_diam, $fn=screw_quality);
        translate([0, 0, -1]) cylinder(h=height+2, d=screw_inner_diam, $fn=screw_quality);
    }
}

// --------

module example() {
    translate([]) pi(1);             // USB
    translate([0, 0, 10]) pi(5);     // pi
    translate([0, 0, 20]) pi(8);     // power
    translate([0, 0, 30]) pi(12);     // controller
    translate([0, 0, 40]) pi(12);     // display
}

module usb() {
    translate([6, 0, 4]) rotate([90, 0, 0]) cylinder(h=100, d=3, $fn=32);
    translate([0, -25, 0]) cube([12, 20, 8]);
    translate([1, -5, 2]) cube([10, 5, 4]);
}

module pi_bottom(r=3) {
    hull() {
        translate([r, r, 0]) cylinder(h=pi_size[2], d=r*2, $fn=32);
        translate([pi_size[0]-r, r, 0]) cylinder(h=pi_size[2], d=r*2, $fn=32);
        translate([r, pi_size[1]-r, 0]) cylinder(h=pi_size[2], d=r*2, $fn=32);
        translate([pi_size[0]-r, pi_size[1]-r, 0]) cylinder(h=pi_size[2], d=r*2, $fn=32);
    }
}

module pi(pins=20) {
    r = 3;
    dist_screw = 4;
    d_screw = 2.8;
        
    color("green") difference() {
        pi_bottom(r);
        translate([dist_screw, dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
        translate([pi_size[0]-dist_screw, dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
        translate([dist_screw, pi_size[1]-dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
        translate([pi_size[0]-dist_screw, pi_size[1]-dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
    }
    
    color("black") translate([56, 6.5, 0]) rotate([0, 0, 180]) cube([(pins-1)*2.54, 2*2.54, 5]);
}