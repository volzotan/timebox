module controller10(){
	board_thickness = 1.600000;
	eta = 0.1;
	board_size = [36.830000,64.770000,board_thickness];
	fn = 18;
	board_origin = [0.000000,0.000000];
	union(){
		color("red")difference(){
			translate(board_origin)cube(board_size); //Board
			translate([3.353,3.505,-eta])cylinder(r=1.400000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([3.340,61.506,-eta])cylinder(r=1.400000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([34.350,57.880,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([34.350,53.880,-eta])cylinder(r=0.600000, h=board_thickness+eta*2,$fn=fn); //hole
			translate([31.115,18.542,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 1
			translate([33.655,18.542,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 2
			translate([31.115,16.002,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 3
			translate([33.655,16.002,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 4
			translate([31.115,13.462,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 5
			translate([33.655,13.462,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 6
			translate([31.115,10.922,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 7
			translate([33.655,10.922,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 8
			translate([31.115,8.382,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 9
			translate([33.655,8.382,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //AVR_ICSP 10
			translate([31.115,48.895,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3 1
			translate([33.655,48.895,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3 2
			translate([31.115,46.355,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3 3
			translate([33.655,46.355,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3 4
			translate([31.115,43.815,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3 5
			translate([33.655,43.815,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X3 6
			translate([22.860,15.240,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 1
			translate([25.400,15.240,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 2
			translate([22.860,12.700,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 3
			translate([25.400,12.700,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 4
			translate([22.860,10.160,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 5
			translate([25.400,10.160,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 6
			translate([22.860,7.620,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 7
			translate([25.400,7.620,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //2X4 8
			translate([16.688,61.595,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //1X02_LOCK 1
			translate([13.792,61.595,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //1X02_LOCK 2
			translate([30.658,61.595,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //1X02_LOCK 1
			translate([27.762,61.595,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //1X02_LOCK 2
			translate([6.452,27.381,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //TACTILE-PTH 1
			translate([6.452,20.879,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //TACTILE-PTH 2
			translate([1.930,27.381,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //TACTILE-PTH 3
			translate([1.930,20.879,-eta])cylinder(r=0.508000, h=board_thickness+eta*2,$fn=fn); //TACTILE-PTH 4
			translate([8.255,45.085,-eta])cylinder(r=0.400000, h=board_thickness+eta*2,$fn=fn); //SO08 P$1
			translate([29.600,57.780,-eta])cylinder(r=0.550000, h=board_thickness+eta*2,$fn=fn); //1501_05 1
			translate([26.600,55.880,-eta])cylinder(r=0.550000, h=board_thickness+eta*2,$fn=fn); //1501_05 2
			translate([29.600,53.980,-eta])cylinder(r=0.550000, h=board_thickness+eta*2,$fn=fn); //1501_05 3
			translate([17.570,2.150,-eta])cylinder(r=0.750000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S1
			translate([10.370,2.150,-eta])cylinder(r=0.750000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S2
			translate([11.545,5.050,-eta])cylinder(r=0.350000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S3
			translate([16.395,5.050,-eta])cylinder(r=0.350000, h=board_thickness+eta*2,$fn=fn); //ZX62D-B-5PA8 S4
		}
	}
}

//controller10(); //Show module
//Created by generate-scad.ulp version 0.1
