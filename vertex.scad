use <profile2040.scad>;

module vertex_profile(angle=120) {
    width=60;
    height=40;
    difference() {
        union() {
            // main body
            square([width, height], true);
            
            // arms
            for (side=[0,1]) {
                mirror([side, 0,0]) {
                    translate([width/2,0,0])
                    rotate([0,0,90-angle/2])
                    square([50,10]);            
                
                    translate([width/2,0,0])
                    circle(d=height);
                }
            }
            
            // bridge
            pulley_space=23;
            bridge_pos=20 + 5/2 + pulley_space;
            translate([0,bridge_pos])
            square([2*40/sin(angle/2), 5], true);
            
            // bridge enforcers
            for (side=[0,1]) {
                mirror([side,0,0]) {
                    translate([width/2,height/2-5])
                    rotate([0,0,30])
                    square([5, (pulley_space+5)/cos(30)]);
                    
                    translate([width-2.5,height/2-5/2])
                    rotate([0,0,30])
                    square([5, (pulley_space+5)/cos(30)]);
                    
                }
            }
        }
        
        // vertical profile cut
        offset(delta=0.2) // give some space
        union() {
            profile_2040();        
            // center fill
            square([37,17], true);
        }
        
        // side profile cut
        for (side=[0,1]) {
                mirror([side, 0,0])
                translate([width/2+10,1+10*cos(angle/2)-20/cos(90-angle/2),0])
                rotate([0,0,90-angle/2])
                square([100,20]);            
        }
    }
}


module vertex_profile2(angle=120) {
    width=40;
    height=60;
    difference() {
        union() {
            // main body
            square([width, height], true);
            
            // arms
            for (side=[0,1]) {
                mirror([side, 0,0]) {
                    translate([width/2,0,0])
                    rotate([0,0,90-angle/2])
                    square([50,10]);            
                
                    translate([width/2,0,0])
                    circle(d=height);
                }
            }
            
            // bridge
            pulley_space=23;
            bridge_pos=20 + 5/2 + pulley_space;
            translate([0,bridge_pos])
            square([2*40/sin(angle/2), 5], true);
            
            // bridge enforcers
            for (side=[0,1]) {
                mirror([side,0,0]) {
                    translate([width/2,height/2-5])
                    rotate([0,0,30])
                    square([5, (pulley_space+5)/cos(30)]);
                    
                    translate([width-2.5,height/2-5/2])
                    rotate([0,0,30])
                    square([5, (pulley_space+5)/cos(30)]);
                    
                }
            }
        }
        
        // vertical profile cut
        offset(delta=0.2) // give some space
        rotate([0,0,90])
        union() {
            profile_2040();        
            // center fill
            square([37,17], true);
        }
        
        // side profile cut
        for (side=[0,1]) {
                mirror([side, 0,0])
                translate([width/2+10,1+10*cos(angle/2)-20/cos(90-angle/2),0])
                rotate([0,0,90-angle/2])
                square([100,20]);            
        }
    }
}


module printing_tabs() {
    for (pos=[[72,25], [68,34], [40, -16.5], [46, 47]]) {
        for (side=[0,1])
            mirror([side,0,0])
        translate([pos[0], pos[1], 0])
        cylinder(d=10, h=0.5);
    }
    
}


module pulley_vertex() {
    difference() {
        union() {
            // main profile
            linear_extrude(20, center=true, convexity=10)
            vertex_profile();

            // wheel spacer
            translate([0,32,0])
            rotate([90,0,0])
            cylinder(d=8, h=24, center=true);            
        }
            
        // idler cut
        translate([0,31,0])
        cube([20, 12, 1000], true);
        
        // shaft hole
        translate([0,30,0])
        rotate([90,0,0])
        cylinder(d=5, h=40, center=true);
        
        // extrusion fixing holes
        for (j=[-1,1]) {
            translate([10*j,0,0])
            rotate([90,0,0])
            cylinder(d=5, h=50, center=true);
        }
        
        // side extrusion fixing holes
        for (side=[0,1]) {
            mirror([side,0,0]) {
                translate([-55,0,0])
                rotate([0,0,-30])
                rotate([90,0,0])
                cylinder(d=5, h=200, center=true);

                translate([-80,0,0])
                rotate([0,0,-30])
                rotate([90,0,0])
                cylinder(d=5, h=200, center=true);
            }
        }
        
    }
    
    // idler for measurement
    *translate([0,31,0])
    rotate([90,0,0])
    cylinder(d=18, h=12, center=true);
    
}


module dummy_vertex() {
    difference() {
        union() {
            // main profile
            linear_extrude(20, center=true, convexity=10)
            vertex_profile();
        }
            
        // idler cut
        translate([0,31,0])
        cube([20, 12, 1000], true);
        
        // shaft hole
        translate([0,30,0])
        rotate([90,0,0])
        cylinder(d=5, h=40, center=true);
        
        // extrusion fixing holes
        for (j=[-1,1]) {
            translate([10*j,0,0])
            rotate([90,0,0])
            cylinder(d=5, h=50, center=true);
        }
        
        // side extrusion fixing holes
        for (side=[0,1]) {
            mirror([side,0,0]) {
                translate([-55,0,0])
                rotate([0,0,-30])
                rotate([90,0,0])
                cylinder(d=5, h=200, center=true);

                translate([-80,0,0])
                rotate([0,0,-30])
                rotate([90,0,0])
                cylinder(d=5, h=200, center=true);
            }
        }
        
    }
    
    // idler for measurement
    *translate([0,31,0])
    rotate([90,0,0])
    cylinder(d=18, h=12, center=true);
    
}

module nema17_holes(length=100, extra=0.6) {
    translate([0,10,0])
    for (i=[-1,1])
        for (j=[-1,1]) {
            translate([i*31/2, 0, j*31/2])
            rotate([90,0,0])
            cylinder(d=3+extra, h=length);
        }

    translate([0,10,0])
    rotate([90,0,0])
    cylinder(d=22+extra, h=12);

    translate([0,10,0])
    rotate([90,0,0])
    cylinder(d=7+extra, h=length);

}

module nema17_motor() {
    length = 47;
    shaft=24;

    difference() {
        cube([43.3, length, 43.3], true);
        
        translate([0,5-length/2,0])
        for (i=[-1,1])
            for (j=[-1,1]) {
                translate([i*31/2, 0, j*31/2])
                rotate([90,0,0])
                cylinder(d=4, h=100);
            }
    }
    
    rotate([90,0,0])
    cylinder(d=5, h=length/2+shaft);
    
    rotate([90,0,0])
    cylinder(d=22, h=length/2+2);
}

module motor_vertex() {
    height=50;
    difference() {
        union() {
            // main profile
            linear_extrude(height, center=true, convexity=10)
            vertex_profile();

            // wheel spacer
            *translate([0,32,0])
            rotate([90,0,0])
            cylinder(d=8, h=24, center=true);            
        }
        
        translate([0,48,0])
        nema17_holes(30);
        
        // nema17 bolt holes
        for (i=[-1,1])
            for (j=[-1,1])
                translate([31/2*i, 43, 31/2*j])
                    rotate([90,0,0])
                    cylinder(d=6, h=10);
                
        // extrusion fixing holes
        for (j=[-1,1]) {
            translate([10*j,0,0])
            rotate([90,0,0])
            cylinder(d=5, h=50, center=true);
        }
        
        // side extrusion fixing holes
        for (i=[0,1]) {
            translate([0,0,height/2-i*20-10])
        for (side=[0,1]) {
            mirror([side,0,0]) {
                translate([-55,0,0])
                rotate([0,0,-30])
                rotate([90,0,0])
                cylinder(d=5, h=200, center=true);

                translate([-80,0,0])
                rotate([0,0,-30])
                rotate([90,0,0])
                cylinder(d=5, h=200, center=true);
            }
        }
        }
    }
    
    // idler for measurement
    *translate([0,31,0])
    rotate([90,0,0])
    cylinder(d=18, h=12, center=true);
    
}


*translate([0,72,0])
color([0.5, 0.8, 0.4])
nema17_motor();


//motor_vertex();
linear_extrude(50, center=true)
vertex_profile2();

*translate([0,0,-50/2])
printing_tabs();

use <profile2040.scad>;
color("lime")
rotate([0,0,90])
linear_extrude(100)
profile_2040();


*color("lime")
translate([35,-8,5])
rotate([0,0,30])
rotate([0,90,0])
linear_extrude(100)
profile_2040();

color("lime")
translate([25,-8.5,5])
rotate([0,0,30])
rotate([0,90,0])
linear_extrude(100)
profile_2040();
