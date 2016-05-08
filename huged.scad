use <MCAD/bearing.scad>;
use <MCAD/shapes.scad>;
use <MCAD/metric_fastners.scad>
use <profile2040.scad>;
use <vertex.scad>;
use <openrail.scad>;
use <carriage.scad>;
use <effector.scad>;

height=1000;

bed_dia = 400;
bed_to_column_spacing=80;
extrusion_width=40;
extrusion_height=20;


module rod(length) {
    tube(length, 6/2, 1);
}




module cap(profile_distance, angle=120, s=0, e=2) {
    
    w = profile_distance+extrusion_height/2;
    
    points = [for (i=[s:e], j=[-1,1]) let (x=w, y=j*extrusion_width/2, a=i*angle-90) [x*cos(a)-y*sin(a), x*sin(a) + y*cos(a)]];
        
    polygon(points);
    
    i=1;
    echo("sidebeam", sqrt(pow(points[i][0]-points[i+1][0],2)+pow(points[i][1]-points[i+1][1],2)));

/*    projection()
    rotate([0,0,30])
    hexagon(580, 3);*/
}


module bed_heater() {
    color([0.4, 0.4, 0.4])
    rotate([0,0,0])
    cylinder(d=bed_dia / cos (180 / 6), h=10, $fn=6);    
}


module spider_rod(x,y, colx, coly, L, offset=0) {
    azrot = atan2(colx-x,coly-y);
    adist = sqrt(pow(colx-x,2)+pow(coly-y,2));
    axrot = asin(adist/L);    
    if (colx==0) {
    echo("azrot", azrot, "axrot", axrot);
    }
    rotate([-axrot, 0,-azrot])
        cylinder(d=6, h=L);
    
}

module offset(angle, distance) {
    translate([distance*cos(angle), distance*sin(angle)])
    children();
}

module spider(x, y, z, L=450) {
    /*
    
Avx/Avy -- virtual location of column A
    
Acz = sqrt(L^2 - (X - Avx)^2 - (Y - Avy)^2)
Bcz = sqrt(L^2 - (X - Bvx)^2 - (Y - Bvy)^2)
Ccz = sqrt(L^2 - (X - Cvx)^2 - (Y – Cvy)^2)


Az = Z + Acz + Hcz    
    */
    effector_radius=40;
    rod_offset=100;
    carriage_r_offset=22.6+10;
    carriage_z_offset=30;
    
    Hcz = 48;
    R = bed_dia/2 + bed_to_column_spacing-effector_radius-carriage_r_offset;
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
    
    Az = z + Acz + Hcz-carriage_z_offset;
    Bz = z + Bcz + Hcz-carriage_z_offset;
    Cz = z + Ccz + Hcz-carriage_z_offset;
    
    echo("Az", Az);
    echo("Bz", Bz);
    echo("Cz", Cz);

    translate([0,R+72,30+Az])
    carriage(32.1,20);

    rotate([0,0,-120])
    translate([0,R+72,30+Bz])
    carriage(32.1,20);
    
    rotate([0,0,120])
    translate([0,R+72,30+Cz])
    carriage(32.1,20);

    // spider arm
    color([0.5,0.7,0.1])
    translate([x,y,z+Hcz]) {
        translate([0,effector_radius,0]) {
            for (i=[-1,1])
                offset(0, i*rod_offset/2)
                    spider_rod(x,y, Avx, Avy, L, offset=i*rod_offset/2);
        }
        
        translate([effector_radius*sin(120),effector_radius*cos(120),0])
        for (i=[-1,1])
            offset(-120, i*rod_offset/2)
                spider_rod(x,y, Bvx, Bvy, L);
        translate([-effector_radius*sin(120),effector_radius*cos(120),0])
        for (i=[-1,1])
            offset(120, i*rod_offset/2)
        spider_rod(x,y, Cvx, Cvy, L);
    }

    // hotend
    color([0.1,0.5,0.8])
    translate([x,y,z]) {
        translate([0,0,40])
            effector(100, effector_radius);
            //cylinder(d=effector_radius*2, h=8);
        cylinder(d=20, h=40);
    }
}


module psu() {  
    translate([0,0,25]) {
        difference() {
            cube([199, 99, 50], true);
            
            for (side=[0,1]) {
                rotate([180*side,0,0])
                translate([0,0,22])
                linear_extrude(4)
                text("24V PSU", size=14, halign="center", valign="center");
                
            }
        }
    }
}



module filament_reel() {
    total_height=85.7;
    
    translate([0,0,total_height-4])
    cylinder(d=203, h=4);
    translate([0,0,4])
    cylinder(d=160, h=total_height-4*2);
    cylinder(d=203, h=4);
    
}

module frame6() {
    profile_distance = bed_dia/2 + extrusion_height/2 + bed_to_column_spacing;


    echo(profile_distance);

    echo(profile_distance*sin(60)*2);

    translate([0,0,5])
    bed_heater();
    
    // columns
    for (i=[0:5]) {
        rotate([0,0,60*i-90])
        translate([profile_distance,0,0]) {
            if (i>0) {
                linear_extrude(height)
                rotate([0,0,90])
                profile_2040();
            }
            
            // linear rail gude
            color("green")
            //translate([-2.5,0,0])
            if (i%2==1) {
                translate([-extrusion_height/2-0.1,-10,0])
                rotate([0,0,-90])
                openrail(1000);

                mirror([0,1,0])
               translate([-extrusion_height/2-0.1,-10,0])
                rotate([0,0,-90])
                //mirror([1,0,0])
                openrail(1000);
            }

            // bottom vertexes
            translate([0,0,10])
            rotate([0,0,90])
            if (i%2 == 1 && i!=0) 
                pulley_vertex();
            else
                dummy_vertex();

            // top vertexes
            *translate([0,0,height-10])
            rotate([0,0,90])
            if (i%2 == 1 && i!=0) 
                motor_vertex();
            else
                dummy_vertex();
            
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
    
    // filament reel
    translate([0,0,height+10])
    filament_reel();
    
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

z_offset = 0;

translate([0,00,z_offset]) {
    translate([0,0,60])
    frame6();
    
    psu();
}
sp_d=200;
sp_x = cos($t*360*4)*sp_d;
sp_y = sin($t*360*4)*sp_d;
sp_z = 0;//sin($t*180)*100;

translate([0,0,15+60+z_offset])
spider(sp_x,sp_y,sp_z, L=450); //492




translate([350,0,0])
cube([50,10,180*10]);


//!pulley_vertex();