size = [70, 44, 9];

//translate([0, 0, 0]) clamp();
//translate([0, 50, 0]) plate();

module plate() {
    difference() {
        union() {

            points_cube = [[0, 0], [44, 0], [44, 9-1], [44-1, 9], [1, 9], [0, 9-1]];
            translate([0, , 0]) rotate([90, 0, 90]) linear_extrude(height=70) polygon(points_cube);
        }    
        
        dist = 7;
        translate([0, 0, -1]) {
            translate([dist, dist]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, dist]) cylinder($fn=32, h=12, d=5.3);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
        }
        translate([0, 0, 3.5]) {
            translate([dist, dist]) cylinder($fn=32, h=12, d=9);
            translate([size[0]-dist, dist]) cylinder($fn=32, h=12, d=9);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=9);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=9);
        }
        translate([size[0]/2, size[1]/2, -1]) cylinder($fn=32, h=12, d=7);
        translate([size[0]/2, size[1]/2, -0.01]) cylinder($fn=6, h=6+1, d=13.2);  // +1 safety margin for long fastening screws
    }
}

module clamp() {
difference() {
    union() {
        difference() {
            union() {
                //cube(size);
                
                
                points_cube = [[0, 0], [44, 0], [44, 9-1], [44-1, 9], [1, 9], [0, 9-1]];
                translate([0, , 0]) rotate([90, 0, 90]) linear_extrude(height=70) polygon(points_cube);
            
                points = [[0, 0], [10, 0], [10, 9], [9, 10], [1, 10], [0, 9]];
                translate([0, 15, 0]) rotate([90, 0, 90]) linear_extrude(height=30) polygon(points);
            }
                    
            tol = 0.2;
            translate([15-tol, -2, 1]) color("red") cube([40+2*tol, 40+tol, 10]);
            
            dist = 7;
            translate([0, 0, -1]) {
                translate([dist, dist]) cylinder($fn=32, h=12, d=5.3);
                translate([size[0]-dist, dist]) cylinder($fn=32, h=12, d=5.3);
                translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
                translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
            }
            translate([0, 0, 4]) {
                translate([dist, dist]) cylinder($fn=6, h=12, d=11.6);
                translate([size[0]-dist, dist]) cylinder($fn=6, h=12, d=11.6);
                translate([dist, size[1]-dist]) cylinder($fn=6, h=12, d=11.6);
                translate([size[0]-dist, size[1]-dist]) cylinder($fn=6, h=12, d=11.6);
            }
        }
        
        points = [[4, 1.4], [0.4, 4], [4, 4]];
        translate([15+40-4+0.2, 40, 1]) rotate([90, 0, 0]) color("blue") linear_extrude(height=40) polygon(points);
        translate([15+4-0.2, 0, 1]) rotate([90, 0, 180]) color("blue") linear_extrude(height=40) polygon(points);

    }

    translate([-1, 20, 5]) rotate([0, 90, 0]) cylinder($fn=32, h=40, d=5.3);
    translate([-9, 20, 5]) rotate([0, 90, 0]) cylinder($fn=32, h=10, d=9);
    translate([15-0.2, 20, 5]) rotate([0, 90, 0]) cylinder($fn=32, h=10, d=8);
        
    // translate([10, 15.75, 1.6]) cube([3, 8.3, 9]); // square nut
    translate([7, 15, 0.6]) cube([3, 10, 10]); // normal M5 nut

}

//translate([15, -2, 1]) color("green") cube([40, 40, 10]);

//translate([-10, 20, 5]) color("blue") {
//    translate([0, 0, 0]) rotate([0, 90, 0]) cylinder($fn=32, h=10, d=5);
//    translate([-3, 0, 0]) rotate([0, 90, 0]) cylinder($fn=32, h=5, d=8.5);
//}
}