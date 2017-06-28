include <camera.scad>;

translate([]) {
    difference() {
        cube([184+2, 78, 121+2]);
        translate([1, 1, 1]) cube([184, 78, 121]);
    }
}

%translate([20, 25, 30]) color("blue") %camera(longlens=true);