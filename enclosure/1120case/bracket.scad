
difference() {
    union() {
        
//        translate([]) block2(50, 60, 4);
//        hull() {
//            translate([0, 0, 20]) rotate([0, 90, 0]) block2(20, 60, 4);
//            translate([0, 0,  0]) rotate([0, 0, 0]) block2(20, 60, 4);
//        }
//        hull() {
//            translate([0, 20-2.05/2,  4-1]) cube([50, 2.05, 1]);
//            translate([0, 20-2.05/2,  19]) cube([4, 2.05, 1]);
//        }
//        hull() {
//            translate([0, 40-2.05/2,  4-1]) cube([50, 2.05, 1]);
//            translate([0, 40-2.05/2,  19]) cube([4, 2.05, 1]);
//        }
        
//        translate([]) block2(50, 40, 4);
//        hull() {
//            translate([0, 0, 20]) rotate([0, 90, 0]) block2(20, 40, 4);
//            translate([0, 0,  0]) rotate([0, 0, 0]) block2(20, 40, 4);
//        }
//        hull() {
//            translate([0, 20-2.05/2,  4-1]) cube([50, 2.05, 1]);
//            translate([0, 20-2.05/2,  19]) cube([4, 2.05, 1]);
//        }
        
        translate([]) block2(50, 20, 4);
        hull() {
            translate([0, 0, 20]) rotate([0, 90, 0]) block2(20, 20, 4);
            translate([0, 0,  0]) rotate([0, 0, 0]) block2(20, 20, 4);
        }
        
        translate([40, 0+10, 4])  cylinder($fn=32, d1=14, d2=12, h=2);
//        translate([40, 20+10, 4]) cylinder($fn=32, d1=14, d2=12, h=2);
//        translate([40, 40+10, 4]) cylinder($fn=32, d1=14, d2=12, h=2);
    }
    
    // screws
    
    translate([40, 0+10, -1])   rotate([]) cylinder($fn=32, d=5.3, h=20);
    translate([40, 20+10, -1])  rotate([]) cylinder($fn=32, d=5.3, h=20);
    translate([40, 40+10, -1])  rotate([]) cylinder($fn=32, d=5.3, h=20);
    translate([40, 0+10, 4])   rotate([]) cylinder($fn=32, d=9, h=20);
    translate([40, 20+10, 4])  rotate([]) cylinder($fn=32, d=9, h=20);
    translate([40, 40+10, 4])  rotate([]) cylinder($fn=32, d=9, h=20);
    translate([-1, 0+10, 10])   rotate([0, 90]) cylinder($fn=32, d=5.3, h=20);
    translate([-1, 20+10, 10])  rotate([0, 90]) cylinder($fn=32, d=5.3, h=20);
    translate([-1, 40+10, 10])  rotate([0, 90]) cylinder($fn=32, d=5.3, h=20);
    translate([7, 0+10, 10])   rotate([0, 90]) cylinder($fn=32, d=9, h=20);
    translate([7, 20+10, 10])  rotate([0, 90]) cylinder($fn=32, d=9, h=20);
    translate([7, 40+10, 10])  rotate([0, 90]) cylinder($fn=32, d=9, h=20);
}

module block2(width, depth, height, crad=3, red=0) {
    
    // pythagorean theorem
    redp = sqrt(red*red + red*red) - red;
    
    points = [  [0+red, crad+redp], [crad+redp, 0+red],
                [width-crad-redp, 0+red], [width-red, crad+redp],
                [width-red, depth-crad-redp], [width-crad-redp, depth-red],
                [crad+redp, depth-red], [0+red, depth-crad-redp]];
    
    linear_extrude(height=height) polygon(points);
}