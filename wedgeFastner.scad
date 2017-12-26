//! Wedge retention fastener pin
/*!
A fully parametric wedge pin for a printable fastener.

\param radius Ideal radius of the shaft of the peg
*/

module wf_pin(radius = 2, extra = 3,clearance = 0.2, wedgeWidth = 0.3, 
           radiusTip = 0.7, width = 0.3, wedgeClearance = 0.15, length = 10, 
	   widthLimit = 0.4, cutSize=false, handleDepth = 3, handleRadius = 5, 
	   hiltDepth = 2, hiltRadius = 4 ) {
	actual = length+extra-radius;
	difference() {
	union() {
		wf_wedge(radius, radiusTip, width, wedgeClearance, length, 
		      widthLimit);
		wf_handle(handleDepth, handleRadius, hiltDepth, hiltRadius);
	}
	
	// Create splay hole
	difference() {
		union() {
			translate([0,0,-extra+radius+clearance]) 
				sphere(radius+clearance);
			translate([0,0,-extra+radius+clearance]) 
				cylinder(h=actual,r=radius+clearance);
		}
		cube([radius*4,(radius*wedgeWidth)*2,actual*2],center=true);
	}
	}
}


module wf_peg(radius = 2, length = 10, clearance = 0.2, extra = 3, 
           wedgewidth = 0.3, wedgeClearance = 0.15 ) {
	union() {
		wf_splay(radius, length, clearance, extra, wedgewidth, 
		      wedgeClearance );
		wf_handle(mountDepth=1.5);
	}
}


module wf_handle( depth = 3, radius = 5, hiltDepth = 2, hiltRadius = 4 ) {
	translate ([0,0,-depth*2-hiltDepth]) union() {
	cylinder(h=depth,r=radius);
	translate([0,0,depth]) {
		cylinder(h=depth*0.3,r1=radius,r2=hiltRadius*0.75);
	}
	translate([0,0,depth*1.3]) {
		cylinder(h=depth*0.4,r=hiltRadius*0.75);
	}
	translate([0,0,depth*1.70]){
		cylinder(h=depth*0.3,r1=hiltRadius*0.75,r2=hiltRadius);
	}
	translate([0,0,depth*2]){
		cylinder(h=hiltDepth,r=hiltRadius);
	}
	}
}


module wf_wedge(radius = 2, radiusTip = 0.7, width = 0.3, clearance = 0.15, 
             length = 10, widthLimit = 0.4, cutSize=false, ) {
	add = cutSize ? clearance : 0;
	mult = cutSize ? 2 : 1;
	size = (radius-clearance)*mult;
	cutPosition = widthLimit/(((width*2)*radius)/length);

	points = [
		[ -size, -radius*width-add,  0 ],
		[ size, -radius*width-add,  0 ],
		[ size, radius*width+add,  0 ],
		[ -size, radius*width+add,  0 ],
		[ -radius*radiusTip*mult,  0, length+add ],
		[ radius*radiusTip*mult,  0, length+add ]
	];
	  
	faces = [
		[0,1,2,3],
		[4,5,1,0],
		[5,2,1],
		[5,4,3,2],
		[4,0,3]
	 ];
	
	difference() {
		polyhedron( points, faces );
		if(!cutSize) {
			translate([0,0,
			          length*1.5-cutPosition-(cutSize?0:clearance)]) 
				cube(size=[radius*2,radius*2,length],
				     center=true);
		}
	}
}


module wf_splay(radius = 2, length = 10, clearance = 0.2, extra = 3, 
             radiusTip = 0.7, wedgeWidth = 0.3, widthLimit = 0.4, 
	     wedgeClearance = 0.15 ) {
	actual = length+extra-radius;
	difference() {
	union() {
		cylinder(h=actual,r=radius-clearance);
		translate([0,0,actual]) sphere(radius-clearance);
	}
	translate([0,0,actual]) {
		rotate ([0,180,0]) 
			wf_wedge(radius, radiusTip, wedgeWidth, wedgeClearance, 
			      length, widthLimit, cutSize = true);
		translate([0,0,radius/2*0.999]) 
			cube([radius*4,(radius*wedgeWidth+wedgeClearance)*2,
			     radius],center=true);
	}
	}
}

$fn=50; // Resolution

translate( [0,-10,0] ) {
wf_pin(length=10);
}

translate( [0,10,0] ) {
wf_peg(length = 10);
}

