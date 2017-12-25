// Configuration
PIN = 1;
PEG = 2;
WHOLE = 0;

PARTNO = WHOLE; // part number
$fn=50; // Resolution

// Pin Info
handleRadius = 8;
handleDepth = 2.5;

// Hole Info
shaftLength = 10;
shaftRadius = 4;

shaftHiltRadius = 6;


// Tolerances
clearance = 0.2; // Clearance between mating parts
wedgeClearance = 0.15; // Clearance to use for the wedge


// Advanced Configuration
shaftEndProtrusion = 3;
wedgeWidth = 0.3; // Percentage of shaftRadius
wedgeTipWidth = 0.7; // Percentage of shaftRadius
wedgeTipMinimum = 0.45; // Minimum wedge tip with because it prints flat when it's thinner than the nozzle

// Calculations
cylH = shaftLength+shaftEndProtrusion-shaftRadius;
wedgeCutPosition = wedgeTipMinimum/(((wedgeWidth*2)*shaftRadius)/shaftLength);


module handle(mountRadius=shaftHiltRadius,mountDepth=handleDepth) {
    translate ([0,0,-handleDepth*2-mountDepth]) union() {
	cylinder(h=handleDepth,r=handleRadius);
	translate([0,0,handleDepth]) {
	    cylinder(h=handleDepth*0.3,r1=handleRadius,r2=mountRadius*0.75);
	}
	translate([0,0,handleDepth*1.3]) {
	    cylinder(h=handleDepth*0.4,r=mountRadius*0.75);
	}
	translate([0,0,handleDepth*1.70]){
	    cylinder(h=handleDepth*0.3,r1=mountRadius*0.75,r2=mountRadius);
	}
	translate([0,0,handleDepth*2]){
	    cylinder(h=mountDepth,r=mountRadius);
	}
    }
}


module wedge(cutSize=false) {
    add = cutSize ? wedgeClearance : 0;
    mult = cutSize ? 2 : 1;
    size = (shaftRadius-clearance)*mult;
    wedgePoints = [
      [ -size,  -shaftRadius*wedgeWidth-add,  0 ],  //0
      [ size,  -shaftRadius*wedgeWidth-add,  0 ],  //1
      [ size,  shaftRadius*wedgeWidth+add,  0 ],  //2
      [ -size,  shaftRadius*wedgeWidth+add,  0 ],  //3
      [ -shaftRadius*wedgeTipWidth*mult,  0,  shaftLength+add ],  //0
      [ shaftRadius*wedgeTipWidth*mult,  0,  shaftLength+add ]];  //3
      
    wedgeFaces = [
      [0,1,2,3],  // bottom
      [4,5,1,0],  // front
    
      [5,2,1],  // right
      [5,4,3,2],  // back
      [4,0,3]]; // left
    
    difference() {
	polyhedron( wedgePoints, wedgeFaces );
	if(!cutSize) {
	    translate([0,0,shaftLength*1.5-wedgeCutPosition-(cutSize?0:clearance)]) cube(size=[shaftRadius*2,shaftRadius*2,shaftLength],center=true);
	}
    }
}


module splay() {
    difference() {
	union() {
	    cylinder(h=cylH,r=shaftRadius-clearance);
	    translate([0,0,cylH]) sphere(shaftRadius-clearance);
	}
	translate([0,0,cylH]) {
	    rotate ([0,180,0]) wedge(true);
	    translate([0,0,shaftRadius/2*0.999]) cube([shaftRadius*4,(shaftRadius*wedgeWidth+wedgeClearance)*2,shaftRadius],center=true);
	}
    }
}

module pin(){
    difference() {
	union() {
	    wedge();
	    handle(mountDepth=1.5);
	}
	
	difference() {
	    union() {
		translate([0,0,-shaftEndProtrusion+shaftRadius+clearance]) sphere(shaftRadius+clearance);
		translate([0,0,-shaftEndProtrusion+shaftRadius+clearance]) cylinder(h=cylH,r=shaftRadius+clearance);
	    }
	    cube([shaftRadius*4,(shaftRadius*wedgeWidth)*2,cylH*2],center=true);
	}
    }
}

module peg() {
    union() {
	splay();
	handle(mountDepth=1.5);
    }
}


if (PARTNO == 1) pin();
if (PARTNO == 2) peg();

// optionally use 0 for whole object
if (PARTNO == 0) {
    translate( [0,-10,0] ) {
	pin();
    }

    translate( [0,10,0] ) {
	peg();
    }
}

