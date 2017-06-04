size = [70, 44, 10];

fins = [[4, 1.4], [0.4, 4], [4, 4]];

tol2 = 0.3;

difference() {
    translate([0, 0, 0]) clamp();
    //translate([0, 0, 2.0]) cube([100, 100, 100]);
    
}    
//translate([0, 50, 0]) plate();

module plate() {
    difference() {
        union() {

            points_cube = [[0, 0], [44, 0], [44, 8-1], [44-1, 8], [1, 8], [0, 8-1]];
            translate([0, , 0]) rotate([90, 0, 90]) linear_extrude(height=70) polygon(points_cube);
        }    
        
        dist = 7;
        translate([0, 0, -1]) {
            translate([dist, dist]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, dist]) cylinder($fn=32, h=12, d=5.3);
            translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
            translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
        }
        translate([0, 0, 2.5]) {
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

                points_cube = [ [0, 0], 
                                [size[1], 0], 
                                [size[1], size[2]-1], 
                                [size[1]-1, size[2]], 
                                [1, size[2]], 
                                [0, size[2]-1]];
                translate([0, , 0]) rotate([90, 0, 90]) linear_extrude(height=70) polygon(points_cube);
            
                points = [  [0, 0], 
                            [14, 0], 
                            [14, size[2]], 
                            [14-1, size[2]+1], 
                            [1, size[2]+1], 
                            [0, size[2]]];
                translate([0, 15, 0]) rotate([90, 0, 90]) linear_extrude(height=30) polygon(points);
            }
                    
            tol = 0.2;
            translate([17-tol, -2, 2]) color("red") cube([40+2*tol, 40+tol, 10]);
            
            dist = 7;
            translate([0, 0, -1]) {
                translate([dist, dist]) cylinder($fn=32, h=12, d=5.3);
                translate([size[0]-dist, dist]) cylinder($fn=32, h=12, d=5.3);
                translate([dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
                translate([size[0]-dist, size[1]-dist]) cylinder($fn=32, h=12, d=5.3);
            }
            translate([0, 0, 4]) {
                translate([dist, dist]) cylinder($fn=6, h=12, d=9.6);
                translate([size[0]-dist, dist]) cylinder($fn=6, h=12, d=9.6);
                translate([dist, size[1]-dist]) cylinder($fn=6, h=12, d=9.6);
                translate([size[0]-dist, size[1]-dist]) cylinder($fn=6, h=12, d=9.6);
            }
        }
 
        difference() {
            union() {
                translate([17+40-4+0.2, 40, 2.2]) rotate([90, 0, 0]) color("blue") linear_extrude(height=40) polygon(fins);
                translate([17+4-0.2, 0, 2.2]) rotate([90, 0, 180]) color("blue") linear_extrude(height=40) polygon(fins);
            }
            points_cutter = [[0, 0], [4, 0], [0, 4]];
            translate([53+0.2, 0, 2]) rotate([0, 0, 0]) color("green") linear_extrude(height=10) polygon(points_cutter);
            translate([21-0.2, 0, 2]) rotate([0, 0, 90]) color("green") linear_extrude(height=10) polygon(points_cutter);
        }
    }

    translate([-1, 22, 5.5]) rotate([0, 90, 0]) cylinder($fn=32, h=40, d=5.3);
    translate([-8.0, 22, 5.5]) rotate([0, 90, 0]) cylinder($fn=32, h=10, d=9);
        
    // translate([10, 15.75, 1.6]) cube([3, 8.3, 9]); // square nut
    translate([3, 17.85, 1.1]) cube([4.2, 8.3, 10]); // normal M5 nut
    
    //translate([9, 15, 2.0]) cube([7, 14, 7.5]); // pressure nose
    points = [  [0, 0], 
                            [14, 0], 
                            [14, 7], 
                            [14-1, 7+1], 
                            [1, 7+1], 
                            [0, 7]];
    translate([9, 15, 2.0]) rotate([90, 0, 90]) linear_extrude(height=7) polygon(points);
    translate([15, 17, 2.0]) cube([7, 10, 7.5]); // pressure nose

}

    translate([9+tol2, 15, 2]) {
    //translate([10, 50, 0]) rotate([0, -90, 0]) {
       
        bottom_height = 2;
        height = 4;
        x=2;
        
        translate([0, tol2, 0]) cube([0.4, 14-2*tol2, 0.3]);
        translate([4-0.4, tol2, 0]) cube([0.4, 14-2*tol2, 0.3]);
        translate([7-0.2, 2+tol2, 0]) cube([0.4, 14-2*tol2-4, 0.3]);
        
        translate([0, 0, 0.3]) difference() {
            // body
            union() {
                
                
                points = [[tol2, 0], [14-tol2, 0], [14-tol2, size[2]-bottom_height-x], [14-1, size[2]+1-tol2-bottom_height-x], [1, size[2]+1-tol2-bottom_height-x], [0+tol2, size[2]-bottom_height-x]];
                translate([0, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=height) polygon(points);
                translate([height, 2+tol2, 0]) cube([3.2, 10-2*tol2, size[2]+1-tol2-bottom_height-x]);  
            }
            //translate([0, tol2, 0]) cube([height, 14-2*tol2, 6.5]);
            
            // screw hole
            translate([-1, 7, 5.5-bottom_height-tol2]) rotate([0, 90, 0]) cylinder($fn=32, h=3, d=5.4);    
        }
        
        // fins
        //translate([height+4, tol2, -tol2+0.2]) rotate([90, 0, 180]) color("blue") linear_extrude(height=14-2*tol2) polygon(fins);
    
    } 
}