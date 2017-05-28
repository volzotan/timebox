cube([100, 50, 6]);

difference() {
    translate([0, 0, 6]) rotate([0, 90, 0]) cylinder(h=100, d=12);
    translate([-1, 0, 6]) rotate([0, 90, 0]) cylinder(h=110, d=5.3);
}

    translate([0, 0, 6]) rotate([12, 0, 0]) difference() {
        cube([100, 50, 6]);
        translate([10, 5, 5]) cube([80+0.4, 40+0.4, 6]);
        
        translate([5, 45, -1])cylinder(h=20, d=5.3);
    }