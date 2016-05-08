
module openrail(length) {
    t=4.75;
    d=t*sin(45);
    w=22.4970;
    mount_w=19.529;
    
    render()
    mirror([0,1,0])
    translate([-mount_w/2,0,0])
    difference() {
        union() {
            // edge
            translate([w-d*cos(45),0,length/2])
            rotate([0,0,45])
            cube([d,d, length], true);
            
            // main body
            translate([0,-t/2,0])
            cube([w-d*cos(45), t, length]);
        }
        
        // mounting cut
        translate([-1,-t/2-1, -1])
        cube([mount_w+1, t/2+1, length+2]);
        
        // mounting holes
        for (z=[20:30:length]) {
            translate([0,0,z])
            hull() {
                for (i=[-1,1]) {
                    translate([mount_w/2+i*3.5,0,0])
                    rotate([90,0,0])
                    cylinder(d=5, h=100, center=true,$fn=20);
                }
            }
        }
    }    
}


module v_wheel(width=7.5,bore=5) {
    render()
    rotate_extrude()   
    difference() {
        union() {
            // main body
            translate([18.75/4,0])
            square([18.75/2,width], true);
            
            // v
            translate([18.75/2,0,0])
            for (i=[-1,1]) {
                translate([0,5.12/2*i,0])
                rotate([0,0,45])
                square([5.12*cos(45),5.12*cos(45)], true);
            }
            
        }

        
        translate([0,width/2])
        square([100,10.23]);
        //square([15.974/2,10.23]);

        mirror([0,1,0])
        translate([0,width/2])
        square([15.974/2,10.23]);

        //translate([0,-5])
        //square([13.89/2,10]);

        square([bore, width*2], true);

    }
}

