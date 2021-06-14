///scr_playershoot(super)
if(argument0 == 0){

    with(instance_create(x,y+12,obj_player_shoot)){
        
        depth = 1;
        hspeed = hspeed+(8+other.extraspeed/2);
        vspeed = other.vspeed;
    };
};
else{

    with(instance_create(x,y+12,obj_player_shoot)){
        
        depth = 1;
        hspeed = hspeed+(8+other.extraspeed/2);
        vspeed = other.vspeed;
        sprite_index = spr_player_supershoot;
    };
};
