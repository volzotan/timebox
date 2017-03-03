size = [62, 14, 10];

difference() {
union() {    
translate([0, 00, 0]) cube(size);
translate([0, 15, 0]) cube(size);
translate([0, 30, 0]) cube(size);
translate([0, 45, 0]) cube(size);
translate([0, 60, 0]) cube(size);
translate([0, 75, 0]) cube(size);
}

translate([0, 7, -1]) hole(1.5, 2.5);
translate([0, 22, -1]) hole(2.5, 3.2);
translate([0, 37, -1]) hole(3.2, 3.8);
translate([0, 52, -1]) hole(3.9, 4.3, subtract=0);
translate([0, 67, -1]) hole(4.4, 4.8, subtract=0);
translate([0, 82, -1]) hole(4.9, 5.3, subtract=0);

}

module hole(start, end, subtract=0.1) {
    offset = 5 + start/2;
    distance = (size[0] - offset*2)/((end-start-subtract)*10);
    
    for (i = [start:0.1:end]) {
        translate([offset+(i-start)*distance*10, 0, 0]) cylinder(h=12, d=start+i, $fn=64);
        //echo(i);
    }
    
    //echo("---");
    
    translate([size[0]-1, -4, 4]) rotate([90, 0, 90]) linear_extrude(height=2) text(str(start), size=4);
}