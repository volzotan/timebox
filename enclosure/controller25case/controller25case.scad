size = [61, 78, 13];

h1 = 0.4;

module foo(height=10, h1=0) {
    shell = [
        [h1             , h1],
        [size[0]-h1     , h1],
        [size[0]-h1     , size[1]-10-h1],
        [size[0]-10-h1   , size[1]-h1],
        [10+h1           , size[1]-h1],
        [h1             , size[1]-10-h1]
    ];
         
    linear_extrude(height=height) polygon(points = shell);
}

module case() {
    union() {
        difference() {
            foo(height=15, h1=0);    
            translate([0, 0, 15-0.8]) foo(height=10, h1=0.4);  
            translate([0, 0, 1.2]) foo(height=20, h1=1.2);    
        }   
        cube([5.9, 9.95, 3]);
        cube([9.45, 6.4, 3]);
        translate([0.5, 39.45, 0]) cube([5.4, 7.3, 3]);
        translate([52.5, 25.55, 0]) cube([8, 7.3, 3]);
        
        translate([2, 2.5, 1]) {    
            translate([3.8, 3.8, 0]) color("green") cylinder($fn=32, h=2, d=7.3);
            translate([3.8, 40.6, 0]) color("green") cylinder($fn=32, h=2, d=7.3);
            translate([50.8, 26.7, 0]) color("green") cylinder($fn=32, h=2, d=7.3);
        }
    }
}

module board() {
    translate([2, 2.5, 1]) {
        color("black") import("/Users/volzotan/GIT/timebox/enclosure/controller25case/controller2.5.dxf");
        
        translate([3.8, 3.8, 0]) color("green") cylinder($fn=32, h=10, d=3.3);
        translate([3.8, 40.6, 0]) color("green") cylinder($fn=32, h=10, d=3.3);
        translate([50.8, 26.7, 0]) color("green") cylinder($fn=32, h=10, d=3.3);

        translate([3.8, 3.8, 0]) color("green") cylinder($fn=32, h=1, d=7.3);
        translate([3.8, 40.6, 0]) color("green") cylinder($fn=32, h=1, d=7.3);
        translate([50.8, 26.7, 0]) color("green") cylinder($fn=32, h=1, d=7.3);
    }    
}


difference() {
    case();
    //translate([8.5, -1, 2]) cube([17, 3, 3]);
    translate([-1, 12, 5]) cube([3, 27, 20]);
    translate([-1, 10, 6.5]) cube([3, 10, 20]);
    translate([-1, 13, 6.4]) rotate([0, 90, 0]) cylinder(h=3, d=6, $fn=32);
    
    translate([2, 2.5, -1]) {    
        translate([3.8, 3.8, 0]) color("green") cylinder($fn=32, h=10, d=3.4);
        translate([3.8, 40.6, 0]) color("green") cylinder($fn=32, h=10, d=3.4);
        translate([50.8, 26.7, 0]) color("green") cylinder($fn=32, h=10, d=3.4);
    
        translate([3.8, 3.8, 0]) color("green") cylinder($fn=6, h=2, d=6.5);
        translate([3.8, 40.6, 0]) color("green") cylinder($fn=6, h=2, d=6.5);
        translate([50.8, 26.7, 0]) color("green") cylinder($fn=6, h=2, d=6.5);
  
    }
    
    translate([48, -0.01, 5]) {
        cube([20, 25, 20]);
    }
}

translate([2, 2.5, 1]) {    
    translate([3.8, 3.8, 0]) cylinder($fn=32, h=0.2, d=7);
    translate([3.8, 40.6, 0]) cylinder($fn=32, h=0.2, d=7);
    translate([50.8, 26.7, 0])cylinder($fn=32, h=0.2, d=7);
}
 board();

// ---

module top() {
    translate([0, 0, 50]) {
        difference() {
            cube([size[0], size[1], 1.2]);
            
            // buttons
            translate([46, 0-0.01, -1]) cube([20, 25, 10]);
            
            // display
            translate([10, 10, -1]) cube([30, 15, 10]);
        }
        
        translate([2, 2.5, -3]) {
      
            translate([3.8, 3.8, 0]) color("green") cylinder($fn=32, h=10, d=3.0);
            translate([3.8, 40.6, 0]) color("green") cylinder($fn=32, h=10, d=3.0);
            translate([50.8, 26.7, 0]) color("green") cylinder($fn=32, h=10, d=3.0);

            translate([3.8, 3.8, 0]) color("green") cylinder($fn=32, h=1, d=6.0);
            translate([3.8, 40.6, 0]) color("green") cylinder($fn=32, h=1, d=6.0);
            translate([50.8, 26.7, 0]) color("green") cylinder($fn=32, h=1, d=6.0);
        }
    }    
}
