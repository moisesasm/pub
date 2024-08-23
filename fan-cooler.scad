//switch level of detail: lower for preview than render
detail = $preview ? 50 : 100;


//EXAMPLE BLADE ASSEMBLY:
translate([200,0,0]){
    //placeholder hub
    cylinder(h=55,d=50,$fn=detail);
    difference() {
        //blades
        for (i=[0:4]){
            rotate([0,0,i*365/5])translate([0,0,-1])bladeElement(30,30,15,120,50,5,0.5);
        }
        //clip the blade tips
        difference() {
            cylinder(h=60,d=300,$fn=detail);
            cylinder(h=60,d=240,$fn=detail);
        }
        //cut the blade trailing edges to sit flat on the build plate
        //  => NB: still might need a brim
        translate([0,0,-60])cylinder(h=60,d=300,$fn=detail);
    }
}


//blade surface (only)
module bladeElement(spanPoints,chordPoints,span1,span2,chord,thick,minThick) {
    
    bladeThickFac = 0.2;
    ripums = 1000;      //rpm
    inflow = 5;         //m/s
    alpha = 10;         //incidence for all spanwise positions
    sweep = -10;

    //POINTS
    //  =>  define the basic geometry of the points along the blade
    topFoil = [for(j=[0:spanPoints-1])for(i=[0:chordPoints-1])
        yaw(
            tw(
                [
                    map(i,0,chordPoints-1,0,1)*(chord/sin(delta(ripums,map(j,0,spanPoints-1,span1,span2)/1000,inflow)+alpha)),
                    map(j,0,spanPoints-1,span1,span2),
                    sin(map(i,0,chordPoints-1,0,180))*(thick-minThick)+minThick
                ],
                delta(ripums,map(j,0,spanPoints-1,span1,span2)/1000,inflow)+alpha),
                map(j,0,spanPoints-1,0,-sweep)
            )
        ];

    btmFoil = [for(j=[0:spanPoints-1])for(i=[0:chordPoints-1])
        yaw(
            tw(
                [
                    map(i,0,chordPoints-1,0,1)*(chord/sin(delta(ripums,map(j,0,spanPoints-1,span1,span2)/1000,inflow)+alpha)),
                    map(j,0,spanPoints-1,span1,span2),
                    bladeThickFac*thick*sin(map(i,0,chordPoints-1,0,180))
                ],
                delta(ripums,map(j,0,spanPoints-1,span1,span2)/1000,inflow)+alpha),
                map(j,0,spanPoints-1,0,-sweep))
        ];
    
    foil = concat(btmFoil,topFoil);
    
    //QUADS
    off = spanPoints*chordPoints;   //offset in the point list to shift from bottom to top
    
    //define the bottom quads
    btm = [for(j=[0:spanPoints-2])for(i=[0:chordPoints-2])[
        i+(j*chordPoints),
        i+1+(j*chordPoints),
        i+1+chordPoints+(j*chordPoints),
        i+chordPoints+(j*chordPoints)]];
        
    //define the top quads (NB: changed the order for maninfold faces)
    top = [for(j=[0:spanPoints-2])for(i=[0:chordPoints-2])[
        i+(j*chordPoints)+off,
        i+chordPoints+(j*chordPoints)+off,
        i+1+chordPoints+(j*chordPoints)+off,
        i+1+(j*chordPoints)+off]];
    
    root = [for(i=[0:chordPoints-2])[
        i,
        i+off,
        i+off+1,
        i+1]];
 
    tip = [for(i=[0:chordPoints-2])[
        i+off-chordPoints,
        i+1+off-chordPoints,
        i+off+1+off-chordPoints,
        i+off+off-chordPoints]];

    le = [for(i=[0:spanPoints-2])[
        i*chordPoints,
        i*chordPoints+chordPoints,
        i*chordPoints+chordPoints+off,
        i*chordPoints+off,
        ]];
        
    te = [for(i=[0:spanPoints-2])[
        i*chordPoints+chordPoints-1,
        i*chordPoints+chordPoints+off-1,
        i*chordPoints+2*chordPoints+off-1,
        i*chordPoints+2*chordPoints-1
        ]];
    
    surf = concat(btm,top,root,tip,le,te); //join the surface quad lists
    
    polyhedron(points = foil, faces = surf,convexity=10);    
}
//

//basic twist function (similar to pitch, legacy code that I didn't remove - sorry)
function tw(pt,twst) = [pt[0]*cos(twst)-pt[2]*sin(twst),pt[1],pt[0]*sin(twst)+pt[2]*cos(twst)];

//yaw, pitch and roll functions used in the blade to shift the points of the blade
function yaw(pt,t) = [pt[0]*cos(t)-pt[1]*sin(t),pt[0]*sin(t)+pt[1]*cos(t),pt[2]];


//mapping function to define how a value maps to a range
function map(in,inFrom,inTo,outFrom,outTo) = outFrom+(((in-inFrom)/(inTo-inFrom))*(outTo-outFrom));

function pi() = 3.141592654;

//aero functions to define the geometry of the blade
//  => vel gives the velocity at each station spanwise
//  => delta gives the angle that the air meets the blade so
//     a zero-incidence blade producing no lift would have
//     this angle to the flow. Incidince is added onto this
//     angle to twist the blade enough to produce lift
function vel(rpm,b) = (pi()*b*rpm)/30;
function delta(rpm,b,inVel) = atan2(inVel,vel(rpm,b));

