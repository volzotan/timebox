
size = [40, 40, 90];
corn = 10;

union() {
    difference() {
        hull() {
            translate([corn/2, corn/2]) cylinder($fn=32, h=size[2], d=corn);
            translate([size[0]-corn/2, corn/2]) cylinder($fn=32, h=size[2], d=corn);
            //translate([corn/2, size[1]-corn/2]) cylinder($fn=32, h=size[2], d=corn);
            translate([size[0]-1, size[1]-1]) cube([1, 1, size[2]]);
            translate([0, size[1]-1]) cube([1, 1, size[2]]);
        }
        
        translate([-0.5, 0-0.01, 2]) cube([size[0]+1, 4, 90-4]);
        translate([2, size[1]-4+0.01, 2]) cube([size[0]+1, 4, 90-4]);
        
        translate([-10, 0, size[2]/2]) rotate([0, 90, 0]) cylinder($fn=64, h=100, d=30);
        translate([-10, size[1], size[2]/2]) rotate([0, 90, 0]) cylinder($fn=64, h=100, d=30);


    translate([0, 0, 2.5]) {
        translate([18/2+2, 10, 0]) color("grey") cylinder($fn=32, h=85, d=18);
        translate([19+18/2+2, 10, 0]) color("grey") cylinder($fn=32, h=85, d=18);
        translate([18/2+2, 30, 0]) color("grey") cylinder($fn=32, h=85, d=18);
        translate([19+18/2+2, 30, 0]) color("grey") cylinder($fn=32, h=85, d=18);

        translate([2, -10-9, 0]) color("black") cube([18, 30, 85]);
        translate([19+2, -10-9, 0]) color("black") cube([18, 30, 85]);
        translate([2, 20+9, 0]) color("black") cube([18, 30, 85]);
        translate([19+2, 20+9, 0]) color("black") cube([18, 30, 85]);
    }

    }
    
    translate([-4, size[1], 20]) rotate([90, 0, 0]) cylinder($fn=32, h=2, d=7);
    translate([-4, size[1]-2, 20-3.5]) cube([6, 2, 7]);
    translate([-4, size[1], size[2]-20]) rotate([90, 0, 0]) cylinder($fn=32, h=2, d=7);
    translate([-4, size[1]-2, size[2]-20-3.5]) cube([6, 2, 7]);
    
}