use <MCAD/bearing.scad>;
use <MCAD/shapes.scad>;
use <MCAD/metric_fastners.scad>
use <profiles.scad>;

height=1000;

bed_dia = 400;
bed_to_column_spacing=80;
extrusion_width=40;
extrusion_height=20;


module rod(length) {
    tube(length, 6/2, 1);
}

module profile_2040() {
    difference() {
    union() {
        translate([-10,0,0])
        profile_tslot_generic (pitch = 20, slot = 6, lip = 2, web = 2.6, core = 9, hole = 5.5);
        translate([10,0,0])
        profile_tslot_generic (pitch = 20, slot = 6, lip = 2, web = 2.6, core = 9, hole = 5.5);
    }
    square([4,16], true);
    }
}

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

module carriage(hspacing=32.1, vspacing=20) {
    y_spacing = 8;
    body_thickness=5;
    for (i=[-1,1]) {
        for (j=[-1,1]) {
            translate([hspacing*j,0,vspacing*i]) {
                
                // wheel
                rotate([90,0,0])
                v_wheel();                
            
                // shaft
                translate([-0,-y_spacing-7.5,0])
                rotate([-90,0,0])
                cap_bolt(5, 25);
                
                // spacer
                translate([0,-y_spacing+body_thickness-1,0])
                rotate([90,0,0])
                cylinder(d=10, h=6.35);
                
                // nut
                translate([0,8,0])
                rotate([90,0,0])
                flat_nut(5);
                
            }
        }
    }
    
    // body
    hoffset = 10;
    voffset = 10;
    
    carriage_width = (hspacing+hoffset)*2;
    carriage_height = (vspacing+voffset)*2;
    
    //echo("carriage size", carriage_width, carriage_height);
    
    color([0.5,0.5,0.5])
    translate([-hspacing-hoffset, -y_spacing-body_thickness-2.5, -vspacing-voffset])
    cube([carriage_width, body_thickness, carriage_height]);
}


module cap(profile_distance, angle=120, s=0, e=2) {
    
    w = profile_distance+extrusion_height/2;
    
    points = [for (i=[s:e], j=[-1,1]) let (x=w, y=j*extrusion_width/2, a=i*angle-90) [x*cos(a)-y*sin(a), x*sin(a) + y*cos(a)]];
        
    polygon(points);

/*    projection()
    rotate([0,0,30])
    hexagon(580, 3);*/
}


module bed_heater() {
    color([0.4, 0.4, 0.4])
    cylinder(d=bed_dia, h=10);    
}


module spider_rod(x,y, colx, coly, L, offset=0, offset_angle=0) {
    azrot = atan2(colx-x,coly-y);
    adist = sqrt(pow(colx-x,2)+pow(coly-y,2));
    axrot = asin(adist/L);
    echo("azrot", azrot);
    translate([offset*cos(offset_angle),offset*sin(offset_angle),0])
    rotate([-axrot, 0,-azrot])
        cylinder(d=8, h=L);
    
}

module spider(x, y, z, L=450) {
    /*
    
Avx/Avy -- virtual location of column A
    
Acz = sqrt(L^2 - (X - Avx)^2 - (Y - Avy)^2)
Bcz = sqrt(L^2 - (X - Bvx)^2 - (Y - Bvy)^2)
Ccz = sqrt(L^2 - (X - Cvx)^2 - (Y – Cvy)^2)


Az = Z + Acz + Hcz    
    */
    effector_radius=100/2;
    rod_offset=60;
    carriage_width = 60;
    
    Hcz = 48;
    R = bed_dia/2 + bed_to_column_spacing-effector_radius;
    Avx = 0;
    Avy = R;
    
    Bvx =  R*sin(120);
    Bvy = R*cos(120);

    Cvx =  -R*sin(120);
    Cvy = R*cos(120);
    
    echo("A", Avx, Avy);
    echo("B", Bvx, Bvy);
    echo("C", Cvx, Cvy);

    Acz = sqrt(pow(L, 2) - pow(x-Avx, 2) - pow(y-Avy, 2));
    Bcz = sqrt(pow(L, 2) - pow(x-Bvx, 2) - pow(y-Bvy, 2));
    Ccz = sqrt(pow(L, 2) - pow(x-Cvx, 2) - pow(y-Cvy, 2));
    
    echo("Acz", Acz);
    echo("Bcz", Bcz);
    echo("Ccz", Ccz);
    
    Az = z + Acz + Hcz;
    Bz = z + Bcz + Hcz;
    Cz = z + Ccz + Hcz;
    
    echo("Az", Az);
    echo("Bz", Bz);
    echo("Cz", Cz);

    translate([0,R+50,30+Az])
    carriage(32.1,20);

    rotate([0,0,-120])
    translate([0,R+50,30+Bz])
    carriage(32.1,20);
    
    rotate([0,0,120])
    translate([0,R+50,30+Cz])
    carriage(32.1,20);
    //cube([carriage_width,20,40], center=true);

    // spider arm
    color([0.5,0.7,0.1])
    translate([x,y,z+Hcz]) {
        translate([0,effector_radius,0]) {
            for (i=[-1,1]) {
                spider_rod(x,y, Avx, Avy, L, offset=i*rod_offset/2);
            }
        }
        
        translate([effector_radius*sin(120),effector_radius*cos(120),0])
        spider_rod(x,y, Bvx, Bvy, L);
        translate([-effector_radius*sin(120),effector_radius*cos(120),0])
        spider_rod(x,y, Cvx, Cvy, L);
    }

    // hotend
    color([0.1,0.5,0.8])
    translate([x,y,z]) {
        translate([0,0,40])
            cylinder(d=effector_radius*2, h=8);
        cylinder(d=20, h=40);
    }
}

module frame6() {
    profile_distance = bed_dia/2 + extrusion_height/2 + bed_to_column_spacing;


    echo(profile_distance);

    echo(profile_distance*sin(60)*2);

    translate([0,0,5])
    bed_heater();
    
    // columns
    for (i=[1:5]) {
        rotate([0,0,60*i-90])
        translate([profile_distance,0,0]) {
            linear_extrude(height)
            rotate([0,0,90])
            profile_2040();
            
            // linear rail gude
            *if (i%2==1) {
                color([0.8,0.8,0.9])
                translate([-23,0,height/2])
                cube([6,80,height], center=true);
            }
            color("green")
            if (i%2==1) {
                translate([-extrusion_height/2-0.1,-10,0])
                rotate([0,0,-90])
                openrail(1000);

                mirror([0,1,0])
                translate([-extrusion_height/2-0.1,-10,0])
                rotate([0,0,-90])
                openrail(1000);
            }
            
        }
    }

    translate([0,0,height])
    linear_extrude(3)
    cap(profile_distance, 60, 0, 5);

    // bottom cap
    linear_extrude(3)
    cap(profile_distance, 60, 0, 5);
    
    
    // covers
    *color([0.95,0.95,0.95],0.8)
    for (i=[1:4]) {
        rotate([0,0,60*i+30])
        translate([profile_distance-20,0,height/2]) {
            cube([6, 330, height], center=true);
        }
    }
    
}



module frame3() {
    profile_distance = (bed_dia/2 + 20) / cos(60);

    echo(profile_distance);

    echo(profile_distance*sin(60)*2);

    translate([0,0,5])
    bed_heater();
    
    // columns
    for (i=[0:2]) {
        rotate([0,0,120*i])
        translate([profile_distance,0,0]) {
            linear_extrude(height)
            //rotate([0,0,90])
            profile_2040();            
        }      
    }

    translate([0,0,height])
    linear_extrude(3)
    cap(profile_distance);

    // bottom cap
    linear_extrude(3)
    cap(profile_distance);    
}


module effector_joint(rod_spacing=50) {
    for (i=[-1,1]) {
        translate([i*rod_spacing/2,0,-bearingWidth(623)/2])
        bearing(model=623);

        translate([i*(rod_spacing/2+10),0,0])
            bearing(model=623, angle=[0,i*90,0]);
        

    }
    
}

*translate([0,0,100])
rotate([-20,0,0])
effector_joint();  

*translate([0,-500,0]) {
    frame3();

    translate([-bed_dia/2+30,0,0])
    rotate([0,0,180]) 
    rotate([0,-90+20,0])
    rod(600);    


    translate([-bed_dia/2+30,0,0])
    rotate([0,0,180-95]) 
    rotate([0,-90+58,0])
    rod(600);    

}

translate([0,00,0]) {
    frame6();   
}
sp_d=200;
sp_x = cos($t*360*4)*sp_d;
sp_y = sin($t*360*4)*sp_d;
sp_z = 0;//sin($t*180)*100;

translate([0,0,15])
spider(sp_x,sp_y,sp_z, L=492);

