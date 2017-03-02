pi_size = [65, 30, 1];
bottom_thickness = 1.2;
enclosure_bottom = [69, 35, bottom_thickness];

screw_inner_diam = 3.3;
screw_outer_diam = 8.2;
screw_quality = 32;

translate([2, 2, 7.5]) example();
//translate([20, -20, 0]) usb();

// translate([0, 0, 50]) pi_spacer(3, 10);
// translate([0, 0, 30]) corner_holder();

translate([0, -70, 0]) sidedoor();
translate([0, 0, 0]) korpus2();

// 

module korpus2() {
    difference() {
        korpus();
        
        offset_x = (enclosure_bottom[0]-(pi_size[0]))/2 + 3.5;
        
        // screw holes
        translate([ offset_x,
                    28.5,-1]) cylinder(h=100, d=screw_inner_diam, $fn=screw_quality);
        translate([ enclosure_bottom[0]-offset_x,
                    28.5,-1]) cylinder(h=100, d=screw_inner_diam, $fn=screw_quality);
    
        // corners
        translate([0, enclosure_bottom[1], -1]) cornercutter(3);
        translate([enclosure_bottom[0], enclosure_bottom[1], -1]) cornercutter(3);
    }
}

module korpus() {
    
    height = 60;
    
    translate([0, enclosure_bottom[1]-1.2, 0]) cube([enclosure_bottom[0], 1.2, height]);      
  
    // right
    translate([enclosure_bottom[0]-1.2, 0, 0]) rotate([0, 0, 0]) difference() {
        cube([1.2, enclosure_bottom[1], height]);
        translate([-1, 12, 8]) cube([3, 10, 5]); // USB
        translate([-1, 9, 18]) cube([3, 15, 3]); // SD
    }
    
    // left
    translate([0, 0, 0]) rotate([0, 0, 0]) difference() {
        cube([1.2, enclosure_bottom[1], height]);
        translate([-1, (32-10)/2, 15]) cube([3, 10, 5]);
        translate([-1, 20, 25]) rotate([0, 90, 0]) cylinder(h=3, d=5, $fn=32);
    }  
    
    difference() {
        union() {
            cube(enclosure_bottom);
            
            translate([0, 0,  0]) corner_holder_set(half=true);
        }
        
        add = [0.2, 0.2, 1];
        
        translate([ (enclosure_bottom[0]-(pi_size[0]+add[0]))/2, 
                    (enclosure_bottom[1]-(pi_size[1]+add[1]))/2, 
                    7  + 0.01]) pi_bottom(add=add);
        
        translate([ (enclosure_bottom[0]-(pi_size[0]+add[0]))/2, 
                    (enclosure_bottom[1]-(pi_size[1]+add[1]))/2, 
                    17 - 0.01]) pi_bottom(add=add);
        
        translate([ (enclosure_bottom[0]-(pi_size[0]+add[0]))/2, 
                    (enclosure_bottom[1]-(pi_size[1]+add[1]))/2, 
                    27 + 0.01]) pi_bottom(add=add);
        
        translate([ (enclosure_bottom[0]-(pi_size[0]+add[0]))/2, 
                    (enclosure_bottom[1]-(pi_size[1]+add[1]))/2, 
                    37 - 0.01]) pi_bottom(add=add);
        
        translate([ (enclosure_bottom[0]-(pi_size[0]+add[0]))/2, 
                    (enclosure_bottom[1]-(pi_size[1]+add[1]))/2, 
                    47 + 0.01]) pi_bottom(add=add);
 
    }
}

module sidedoor() {
    cube([65, 60, 1.2]);
}

// --------

module corner_holder_set(half=false) {
    if (!half) {
        corner_holder();
        translate([enclosure_bottom[0], 0, 0]) rotate([0, 0, 90]) corner_holder();
    }
    
    translate([enclosure_bottom[0], enclosure_bottom[1], 0])    rotate([0, 0, 180]) corner_holder(add=[0,1,0]);
    translate([0, enclosure_bottom[1], 0])                      rotate([0, 0, 270]) corner_holder(add=[1,0,0]);   
}

module corner_holder(add=[0, 0, 0]) {
    height = 60;
    radius = 3;

    difference() {
        cube([screw_outer_diam+add[0], screw_outer_diam+add[1], height]);
        
        difference() {
            translate([(screw_outer_diam-radius/2)+add[0], (screw_outer_diam-radius/2)+add[1], -1]) cube([radius, radius, height+2]);
            translate([(screw_outer_diam-radius/2)+add[0], (screw_outer_diam-radius/2)+add[1], -1]) cylinder(h=height+2, d=radius, $fn=screw_quality);
        }
    }
    
    //translate([screw_outer_diam/2, screw_outer_diam/2, 0]) cylinder(h=height, d=screw_outer_diam, $fn=screw_quality);
    //translate([0, 0, 0]) cube([screw_outer_diam, screw_outer_diam/2, height]);
    //translate([0, 0, 0]) cube([screw_outer_diam/2, screw_outer_diam, height]);
}

module pi_spacer(distance, height) {
    translate([distance, distance, 0]) difference() {
        cylinder(h=height, d=screw_outer_diam, $fn=screw_quality);
        translate([0, 0, -1]) cylinder(h=height+2, d=screw_inner_diam, $fn=screw_quality);
    }
}

module cornercutter(side) {
    translate([0, -sqrt(pow(side/2, 2) + pow(side/2, 2)), 0]) rotate([0, 0, 45]) cube([side, side, 100]); 
}

module slot(height, length) {
    cube([]);
}

// --------

module example() {
    translate([]) pi(0);             // USB
    translate([0, 0, 10]) pi(5);     // pi
    translate([0, 0, 20]) pi(8);     // power
    translate([0, 0, 30]) pi(12);     // controller
    translate([0, 0, 40]) pi(20);     // display
}

module usb() {
    translate([6, 0, 4]) rotate([90, 0, 0]) cylinder(h=100, d=3, $fn=32);
    translate([0, -25, 0]) cube([12, 20, 8]);
    translate([1, -5, 2]) cube([10, 5, 4]);
}

module pi_bottom(r=3, add=[0, 0, 0]) {
    hull() {
        translate([r, r, 0]) cylinder(h=pi_size[2]+add[2], d=r*2, $fn=32);
        translate([pi_size[0]+add[0]-r, r, 0]) cylinder(h=pi_size[2]+add[2], d=r*2, $fn=32);
        translate([r, pi_size[1]+add[1]-r, 0]) cylinder(h=pi_size[2]+add[2], d=r*2, $fn=32);
        translate([pi_size[0]+add[0]-r, pi_size[1]+add[1]-r, 0]) cylinder(h=pi_size[2]+add[2], d=r*2, $fn=32);
    }
}

module pi(pins=20) {
    r = 3;
    dist_screw = 3.5;
    d_screw = 2.75;
        
    color("green") difference() {
        pi_bottom(r);
        translate([dist_screw, dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
        translate([pi_size[0]-dist_screw, dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
        translate([dist_screw, pi_size[1]-dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
        translate([pi_size[0]-dist_screw, pi_size[1]-dist_screw, -1]) cylinder(h=pi_size[2]*3, d=d_screw, $fn=32);
    }
    
    color("silver") translate([6.5, 30-7, 0])cube([25, 7, 3]);
    
    color("black") translate([58, 6.5, 0]) rotate([0, 0, 180]) cube([pins*2.54, 2*2.54, 5]);
}