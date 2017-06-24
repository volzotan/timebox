crad    = 4;
height  = 1.2;

size    = [43,42];
battery = [41,40,80];

translate([1, 1, -battery[2]+0.01]) color("green") cube(battery);

difference() {
hull() {
    translate([crad, crad]) cylinder($fn=32, h=height, r=crad);
    translate([size[0]-crad, crad]) cylinder($fn=32, h=height, r=crad);
    translate([crad, size[1]-crad]) cylinder($fn=32, h=height, r=crad);
    translate([size[0]-crad, size[1]-crad]) cylinder($fn=32, h=height, r=crad);
    
}
    translate([size[0]/2, size[1]/2, -2]) cylinder($fn=64, h=10, d=20);
}