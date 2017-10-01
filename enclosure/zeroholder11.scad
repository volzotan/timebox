include </Users/volzotan/GIT/timebox/enclosure/controller11.scad>

crad = 5;
height = 4;

% translate([2, 32+0.5, -20+2+.7+10-09.8]) pizero();
translate([2, 35-2.5, 10]) rotate([0, 0, 180]) controller();
//% translate([2, 35-2.5, 35+1.2]) rotate([0, 0, -90]) color("purple") import(file = "controller11_2.dxf");
    
bottom();
translate([0, -40, 0]) rotate([0, 0, 0]) top();
translate([0, 35, 20]) rotate([180, 0, 0]) color([0.6, 1, 0.6], 0.1) top();
//translate([0, -2, 7]) rotate([180, 0, 0]) top();
//translate([0, 0, 8.2]) rotate([0, 0, 0]) top();

//translate([72, -2, 0]) rotate([0, 0, 0]) mirror([0, 1]) controller_top();

//% translate([6, 6, 41.2]) rotate([180, 0, 0]) screw();

module top() {
    height = 10;
    size = [69, 35];
    
    height2 = 8;
    
    difference() {
        intersection() {
            union() {
                difference() {               
                    block(size[0], size[1], height, crad=4);
                    
                    // pi cutout
                    hull() {
                        translate([0, 0, 3]) {
                            block(size[0], size[1], 0.1, crad=4, red=1.2+.1+1);
                        }
                        translate([0, 0, 4]) {
                            block(size[0], size[1], height, crad=4, red=1.2+.1);
                        } 
                    }
                }
//                translate([]) cube([5.7, 7.5, height2]);
//                translate([]) cube([8, 5.7, height2]);
//                translate([6, 5.5]) cylinder($fn=32, h=height2, d=4);
//                
//                translate([size[0]-5.7, 0]) cube([5.7, 7.5, height2]);
//                translate([size[0]-8, 0]) cube([7.5, 5.7, height2]);
//                translate([size[0]-6, 5.5]) cylinder($fn=32, h=height2, d=4);
//                
                translate([size[0]-5.7, size[1]-8.5]) cube([5.7, 8.5, height2]);
                translate([size[0]-8, size[1]-6.5]) cube([7.5, 6.5, height2]);
                translate([size[0]-6, size[1]-6.5]) cylinder($fn=32, h=height2, d=4);
                
                translate([0, size[1]-8.5]) cube([5.7, 8.5, height2]);
                translate([0, size[1]-6.5]) cube([8, 5.7, height2]);
                translate([6, size[1]-6.5]) cylinder($fn=32, h=height2, d=4);
            }
            
            block(size[0], size[1], height, crad=4);
        }
        
        // pi cutout
        * translate([0, 0, 6.5]) {
            color("red") block(size[0], size[1], height, crad=3, red=1.2);
        } 
        
        // sd card connector cutout
//        translate([-0.1, (34-18)/2, -0.1]) {
//            //translate([0, 0, 3+3.0-0.3]) cube([0.1, 18, 0.1]);
//            cube([3.1, 18, 3.5]);
//            
//            points = [[0, 0], [18.2, 0], [18.2-2, 3], [2, 3]];
//            translate([-0.1, 18.1, 0]) rotate([0, 0, -90]) linear_extrude([]) polygon(points);
//        }
       
        // connector cutout
        translate([size[0]-19-8.0, size[1]-4.5, 3-1]) cube([19, 5, height]);         // power
        translate([size[0]-8-30.75, size[1]-4.5, 6]) {                               // audio jack
            cube([7, 5, 6]);
            translate([7/2, 5, 0]) rotate([90, 0, 0]) cylinder($fn=32, d=7, h=2.8);
        }     
        translate([8.0+1.5, size[1]-4.5+5, 3]) rotate([90, 0, 0]) block(11, 10, 3, crad=1); // cube([11, 5, height]);         // USB        
        translate([-1, 9, 8]) rotate([90, 0, 90]) block(18, 5, 3, crad=1);          // switch
        translate([20, 24.5, -1]) block(9.5, 7, 10, crad=1); // SPI
        translate([40.7, 27, -1]) cylinder($fn=32, h=10, d=3);  // LED hole
        translate([39.4, 6, -1]) cylinder($fn=32, h=10, d=3);  // switch hole
        
        // screws
        translate([0, -.5, -1]) {
//            translate([5.5, 5.5]) cylinder($fn=32, h=20, d=2.5+.3);
//            translate([5.5+58, 5.5]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([5.5, 5.5+24]) cylinder($fn=32, h=20, d=2.5+.3);
            translate([5.5+58, 5.5+24]) cylinder($fn=32, h=20, d=2.5+.3);
            
    //        translate([6-.5, 6]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5+58, 6]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5, 6+23]) cylinder($fn=6, h=3-.5, d=6);
    //        translate([6-.5+58, 6+23]) cylinder($fn=6, h=3-.5, d=6);
            
//            translate([5.5, 5.5, -1]) cylinder($fn=6, h=4, d=6.1);
//            translate([5.5+58, 5.5, -1]) cylinder($fn=6, h=4, d=6.1);
            translate([5.5, 5.5+24, -1]) cylinder($fn=6, h=4, d=6.1);
            translate([5.5+58, 5.5+24, -1]) cylinder($fn=6, h=4, d=6.1);
        }
      
        // force printer to do holes at once
        translate([0, 0, 0]) {
//            translate([0, 5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([0, 34-5-.1/2, -1]) cube([7, 0.1, 1.2]);
//            translate([69-7, 5-.1/2, -1]) cube([7, 0.1, 1.2]);
            translate([69-7, 34-5-.1/2, -1]) cube([7, 0.1, 1.2]);
        }
    } 
    
    // hole reinforcements
    * translate([0, 0, 20]) {
//        translate([6-5/2, 6-3, 4.8])         cube([5, 5, .2]);
//        translate([6+58-5/2, 6-3, 4.8])      cube([5, 5, .2]);
        translate([6-5/2, 6+23-3, 4.8])      cube([5, 5, .2]);
        translate([6+58-5/2, 6+23-3, 4.8])   cube([5, 5, .2]);
    }
}

module bottom() {
    
    height = 8;
        
    difference() {
        union() {
            hull() {
                block(69, 35, height, crad=4);
            }
        }
        
        // pi cutout
        translate([0, 0, 4-1.3]) hull() {
            block(69, 35, height, crad=4, red=1.2+.1);
        }    
        
        // through hole pin cutout
        translate([(70-51)/2, 26-.25, 0.8]) color("yellow") cube([51, 6.5, 2]);
        
        // screws
        translate([0.5, -.5, -1]) {
            translate([6-1, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-1+58, 6.5]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-1, 6.5+23]) cylinder($fn=32, h=10, d=2.5+.3);
            translate([6-1+58, 6.5+23]) cylinder($fn=32, h=10, d=2.5+.3);
            
            translate([6-1, 6.5]) cylinder($fn=32, h=3-.2, d=4.9);
            translate([6-1+58, 6.5]) cylinder($fn=32, h=3-.2, d=4.9);
            translate([6-1, 6.5+23]) cylinder($fn=32, h=3-.2, d=4.9);
            translate([6-1+58, 6.5+23]) cylinder($fn=32, h=3-.2, d=4.9);
        }
        
        // camera connector cutout
        translate([65, (34-19)/2, 3]) cube([10, 19, 10]);
        
        // sd card connector cutout
        translate([-0.1, (34-18)/2, 0.5]) hull() {
            translate([0, 0, 2.2]) cube([2.61, 18, 10]);
            cube([0.1, 18, 0.1]);
        }
        
        // USB cutout
        translate([37.5, 0, 3]) hull() {
            translate([0, 2]) cube([24, 0.1, 10]);
            translate([-3/2, -1]) cube([24+3, 0.1, 10]);
        }

        // force printer to do holes at once
        translate([0, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([0, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-7, 5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        translate([69-7, 34-5.5-.1/2, -1]) cube([7, 0.1, 1.2]);
        
        translate([30, 37, -1]) cube([5, 0.1, 1.2]);
    }

    // hole reinforcements
    translate([6-.5-5/2, 6-3, 1.8])         cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6-3, 1.8])      cube([5, 5, .2]);
    translate([6-.5-5/2, 6+23-3, 1.8])      cube([5, 5, .2]);
    translate([6-.5+58-5/2, 6+23-3, 1.8])   cube([5, 5, .2]);
}

module controller() {
    //rotate([0, 0, 90]) color("purple") import(file = "controller10.dxf");
    rotate([0, 0, 90]) controller11();
    
//    translate([-75+0.2, 12.75, 0]) color("yellow") cube([10, 5, 6]);
//    translate([-75+0.2, 12.75+14, 0]) color("yellow") cube([10, 5, 6]);
//    
//    translate([-5, 10, 0]) color("grey") cube([5, 8, 3]);
//    //translate([0-22-8, 0, 0]) color("white") cube([22, 7.5, 3]);
//   
//    translate([0-14-6.5, 40-3, 1]) color("black") cube([14, 6, 5]);
//    //translate([0-10-6.5, 22, 1]) color("black") cube([10, 5, 9+1]);
//    translate([-65+6.5, 40-3, 1]) color("black") cube([16, 5, 5]);
}

module pizero() {
    rotate([90, 0, 0]) color("green") import(file = "RaspberryPiZero.STL");
}

module screw() { // M2.5 screw
    color("grey") { 
        translate([]) cylinder($fn=32, h=2.5, d=4.5);
        translate([0, 0, 2.5]) cylinder($fn=32, h=10, d=2.5);
    }
}

module block(width, depth, height, crad=3, red=0) {
    hull() {    
        translate([crad, crad]) cylinder($fn=32, h=height, r=crad-red);
        translate([width-crad, crad]) cylinder($fn=32, h=height, r=crad-red);
        translate([crad, depth-crad]) cylinder($fn=32, h=height, r=crad-red);
        translate([width-crad, depth-crad]) cylinder($fn=32, h=height, r=crad-red);
    }
}
