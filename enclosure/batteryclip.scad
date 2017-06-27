crad    = 4;

w  = 1.2;
bw = 1.2;

clip_height = 4.5;

size    = [44,43];   // 42 - 2*1.2 = 39.6 
battery = [41,40,80];

%translate([1.2, 1.2, 100]) color("green") cube(battery);

difference() {
    block(height=2.4, crad=crad);
    translate([0, 0, bw]) block(height=20, crad=crad, red=w);;
    translate([size[0]/2, size[1]/2, -2]) cylinder($fn=64, h=10, d=20);
}

offset_clip = (size[1]-32)/2;

translate([0, offset_clip, 0]) cube([w, 32, clip_height]);
points = [[0, 0], [1.2, 1.2], [0, 1.2]];
translate([1.2, 32+offset_clip, clip_height-1.2]) rotate([90, 0, 0]) linear_extrude(height=32) polygon(points);

translate([size[0]-1.2, offset_clip, 0]) cube([w, 32, clip_height]);
translate([size[0]-1.2, offset_clip, clip_height-1.2]) rotate([90, 0, 180]) linear_extrude(height=32) polygon(points);

module block(size=size, crad=1, height=10, red=0) {
    hull() {
        translate([crad+red, crad+red]) cylinder($fn=32, r=crad, h=height);
        translate([size[0]-crad-red, crad+red]) cylinder($fn=32, r=crad, h=height);
        translate([crad+red, size[1]-crad-red]) cylinder($fn=32, r=crad, h=height);
        translate([size[0]-crad-red, size[1]-crad-red]) cylinder($fn=32, r=crad, h=height);
    }
}