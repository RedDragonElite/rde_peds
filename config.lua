Config = {
    Debug = false,
    DefaultScenario = 'WORLD_HUMAN_STAND_IMPATIENT',
    AdminGroups = {'admin', 'superadmin'}, -- Add any additional admin groups here
    DatabaseTable = 'rde_pedmanager', -- Table name for easy reference

    PedModels = {
        {label = 'Business Man', value = 'a_m_m_business_01'},
        {label = 'Business Woman', value = 'a_f_m_business_02'},
        {label = 'Security Guard', value = 's_m_m_security_01'},
        {label = 'Police Officer', value = 's_m_y_cop_01'},
        {label = 'Construction Worker', value = 's_m_y_construct_01'},
        {label = 'Dealer', value = 'g_m_y_dealer_01'},
        {label = 'Beach Woman', value = 'a_f_y_beach_01'},
        {label = 'Banker', value = 'ig_bankman'},
        {label = 'Mechanic', value = 's_m_y_xmech_02'},
        {label = 'Waiter', value = 's_m_y_waiter_01'},
        {label = 'Doctor', value = 's_m_m_doctor_01'},
        {label = 'Nurse', value = 's_f_y_scrubs_01'},
        {label = 'Firefighter', value = 's_m_y_fireman_01'},
        {label = 'Paramedic', value = 's_m_m_paramedic_01'},
        {label = 'Chef', value = 's_m_m_chef_01'},
        {label = 'Farmer', value = 'a_m_m_farmer_01'},
        {label = 'Gardener', value = 'a_m_m_gardener_01'},
        {label = 'Lifeguard', value = 's_m_y_lifeguard_01'},
        {label = 'Pilot', value = 's_m_m_pilot_01'},
        {label = 'Prisoner', value = 's_m_y_prisoner_01'},
        {label = 'Scientist', value = 's_m_m_scientist_01'},
        {label = 'Sheriff', value = 's_m_y_sheriff_01'},
        {label = 'SWAT', value = 's_m_y_swat_01'},
        {label = 'Teacher', value = 's_m_m_trucker_01'},
        {label = 'Vagrant', value = 'u_m_m_jesus_01'},
        {label = 'Yoga Instructor', value = 'a_f_y_yoga_01'},
        {label = 'Bartender', value = 's_m_y_barman_01'},
        {label = 'Bouncer', value = 's_m_m_bouncer_01'},
        {label = 'Boxer', value = 's_m_y_boxer_01'},
        {label = 'Clown', value = 's_m_y_clown_01'},
        {label = 'DJ', value = 's_m_y_dj_01'},
        {label = 'Golf Caddy', value = 's_m_y_golfcaddy_01'},
        {label = 'Hiker', value = 'a_m_y_hiker_01'},
        {label = 'Jogger', value = 'a_f_y_jog_01'},
        {label = 'Lifeguard', value = 's_f_y_lifeguard_01'},
        {label = 'Marathon Runner', value = 'a_m_y_runner_01'},
        {label = 'Road Worker', value = 's_m_y_roadwork_01'},
        {label = 'Shop Assistant', value = 's_f_y_shop_high_01'},
        {label = 'Tennis Player', value = 'a_f_y_tennis_01'},
        {label = 'Tourist', value = 'a_m_m_tourist_01'},
        {label = 'Valet', value = 's_m_y_valet_01'},
        {label = 'Wincleaner', value = 's_m_y_winclean_01'},
        {label = 'Yoga Instructor', value = 'a_f_y_yoga_01'},
        {label = 'Ambient Female', value = 'a_f_y_ambient_01'},
        {label = 'Ambient Male', value = 'a_m_y_ambient_01'},
        {label = 'Animal', value = 'a_c_deer'},
        {label = 'Cutscene', value = 'cs_bankman'},
        {label = 'Gang Female', value = 'g_f_y_ballas_01'},
        {label = 'Gang Male', value = 'g_m_y_ballaorig_01'},
        {label = 'Multiplayer', value = 'mp_m_freemode_01'},
        {label = 'Scenario Female', value = 's_f_y_hooker_01'},
        {label = 'Scenario Male', value = 's_m_y_hwaycop_01'},
        {label = 'Story', value = 'cs_amandatownley'},
        {label = 'Story Scenario Female', value = 'cs_patricia'},
        {label = 'Story Scenario Male', value = 'cs_lamardavis'}
    },

    GuardWeapons = {
        {label = 'Pistol', value = 'WEAPON_PISTOL'},
        {label = 'Combat Pistol', value = 'WEAPON_COMBATPISTOL'},
        {label = 'SMG', value = 'WEAPON_SMG'},
        {label = 'Nightstick', value = 'WEAPON_NIGHTSTICK'},
        {label = 'Stungun', value = 'WEAPON_STUNGUN'},
        {label = 'Assault Rifle', value = 'WEAPON_ASSAULTRIFLE'},
        {label = 'Carbine Rifle', value = 'WEAPON_CARBINERIFLE'},
        {label = 'Shotgun', value = 'WEAPON_PUMPSHOTGUN'},
        {label = 'Sniper Rifle', value = 'WEAPON_SNIPERRIFLE'},
        {label = 'Knife', value = 'WEAPON_KNIFE'},
        {label = 'Bat', value = 'WEAPON_BAT'},
        -- {label = 'Grenade', value = 'WEAPON_GRENADE'},
        -- {label = 'Molotov', value = 'WEAPON_MOLOTOV'},
        -- {label = 'RPG', value = 'WEAPON_RPG'},
        -- {label = 'Minigun', value = 'WEAPON_MINIGUN'}
    },

    Scenarios = {
        {label = 'Standing', value = 'WORLD_HUMAN_STAND_IMPATIENT'},
        {label = 'Phone Call', value = 'WORLD_HUMAN_STAND_MOBILE'},
        {label = 'Smoking', value = 'WORLD_HUMAN_SMOKING'},
        {label = 'Drinking Coffee', value = 'WORLD_HUMAN_AA_COFFEE'},
        {label = 'Cleaning', value = 'WORLD_HUMAN_MAID_CLEAN'},
        {label = 'Taking Photos', value = 'WORLD_HUMAN_PAPARAZZI'},
        {label = 'Sitting', value = 'PROP_HUMAN_SEAT_CHAIR'},
        {label = 'Clipboard', value = 'WORLD_HUMAN_CLIPBOARD'},
        {label = 'Leaning', value = 'WORLD_HUMAN_LEANING'},
        {label = 'Sunbathing', value = 'WORLD_HUMAN_SUNBATHE'},
        {label = 'Yoga', value = 'WORLD_HUMAN_YOGA'},
        {label = 'Gardening', value = 'WORLD_HUMAN_GARDENER_PLANT'},
        {label = 'Musician', value = 'WORLD_HUMAN_MUSICIAN'},
        {label = 'Welding', value = 'WORLD_HUMAN_WELDING'},
        {label = 'Mechanic Work', value = 'WORLD_HUMAN_VEHICLE_MECHANIC'},
        {label = 'Binoculars', value = 'WORLD_HUMAN_BINOCULARS'},
        {label = 'Bum Sleeping', value = 'WORLD_HUMAN_BUM_SLUMPED'},
        {label = 'Cheering', value = 'WORLD_HUMAN_CHEERING'},
        {label = 'Clipboard Checking', value = 'CODE_HUMAN_MEDIC_TIME_OF_DEATH'},
        {label = 'Drinking', value = 'WORLD_HUMAN_DRINKING'},
        {label = 'Drug Dealer', value = 'WORLD_HUMAN_DRUG_DEALER'},
        {label = 'Drug Dealer Hard', value = 'WORLD_HUMAN_DRUG_DEALER_HARD'},
        {label = 'Film Shocking', value = 'WORLD_HUMAN_FILM_SHOCKING'},
        {label = 'Fishing', value = 'WORLD_HUMAN_FISHING'},
        {label = 'Flexing', value = 'WORLD_HUMAN_MUSCLE_FLEX'},
        {label = 'Golfing', value = 'WORLD_HUMAN_GOLF_PLAYER'},
        {label = 'Guard Patrol', value = 'WORLD_HUMAN_GUARD_PATROL'},
        {label = 'Hammering', value = 'WORLD_HUMAN_HAMMERING'},
        {label = 'Hiker Standing', value = 'WORLD_HUMAN_HIKER_STANDING'},
        {label = 'Janitor', value = 'WORLD_HUMAN_JANITOR'},
        {label = 'Jogging', value = 'WORLD_HUMAN_JOG_STANDING'},
        {label = 'Leaf Blower', value = 'WORLD_HUMAN_GARDENER_LEAF_BLOWER'},
        {label = 'Parking Meter', value = 'WORLD_HUMAN_PARKING_METER'},
        {label = 'Party', value = 'WORLD_HUMAN_PARTYING'},
        {label = 'Picnic', value = 'WORLD_HUMAN_PICNIC'},
        {label = 'Prostitute High Class', value = 'WORLD_HUMAN_PROSTITUTE_HIGH_CLASS'},
        {label = 'Prostitute Low Class', value = 'WORLD_HUMAN_PROSTITUTE_LOW_CLASS'},
        {label = 'Push Ups', value = 'WORLD_HUMAN_PUSH_UPS'},
        {label = 'Seat Ledger', value = 'PROP_HUMAN_SEAT_LEDGE'},
        {label = 'Seat Steps', value = 'PROP_HUMAN_SEAT_STEPS'},
        {label = 'Seat Wall Tablet', value = 'PROP_HUMAN_SEAT_WALL_TABLET'},
        {label = 'Security Shine Torch', value = 'WORLD_HUMAN_SECURITY_SHINE_TORCH'},
        {label = 'Sit Ups', value = 'WORLD_HUMAN_SIT_UPS'},
        {label = 'Statue', value = 'WORLD_HUMAN_STATUE'},
        {label = 'Strip Watch Stand', value = 'WORLD_HUMAN_STRIP_WATCH_STAND'},
        {label = 'Stupor', value = 'WORLD_HUMAN_STUPOR'},
        {label = 'Sunbathe Back', value = 'WORLD_HUMAN_SUNBATHE_BACK'},
        {label = 'Superhero', value = 'WORLD_HUMAN_SUPERHERO'},
        {label = 'Tennis Player', value = 'WORLD_HUMAN_TENNIS_PLAYER'},
        {label = 'Tourist Map', value = 'WORLD_HUMAN_TOURIST_MAP'},
        {label = 'Tourist Mobile', value = 'WORLD_HUMAN_TOURIST_MOBILE'},
        {label = 'Vehicle Mechanic', value = 'WORLD_HUMAN_VEHICLE_MECHANIC'},
        {label = 'Wash Up', value = 'WORLD_HUMAN_WASH_UP'},
        {label = 'Window Shopping', value = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE'},
        {label = 'Yoga', value = 'WORLD_HUMAN_YOGA'},
        {label = 'Drilling', value = 'WORLD_HUMAN_CONST_DRILL'},
        {label = 'Paparazzi', value = 'WORLD_HUMAN_PAPARAZZI'},
        {label = 'Road Worker', value = 'WORLD_HUMAN_CONST_DRILL'},
        {label = 'ATM', value = 'PROP_HUMAN_ATM'},
        {label = 'BBQ', value = 'PROP_HUMAN_BBQ'},
        {label = 'Bum Wash', value = 'PROP_HUMAN_BUM_BIN'},
        {label = 'Muscle', value = 'WORLD_HUMAN_MUSCLE_FREE_WEIGHTS'},
        {label = 'Parking Meter', value = 'PROP_HUMAN_PARKING_METER'},
        {label = 'Seat Computer', value = 'PROP_HUMAN_SEAT_COMPUTER'},
        {label = 'Seat Sunbathe', value = 'PROP_HUMAN_SEAT_SUNLOUNGER'},
        {label = 'Street Magic', value = 'WORLD_HUMAN_STREET_MAGICIAN'},
        {label = 'Street Performer', value = 'WORLD_HUMAN_STREET_PERFORMER'},
        {label = 'Tourist', value = 'WORLD_HUMAN_TOURIST_MAP'},
        {label = 'Tourist Mobile', value = 'WORLD_HUMAN_TOURIST_MOBILE'},
        {label = 'Vehicle Mechanic', value = 'WORLD_HUMAN_VEHICLE_MECHANIC'},
        {label = 'Window Shopping', value = 'WORLD_HUMAN_WINDOW_SHOP_BROWSE'},
        {label = 'Yoga', value = 'WORLD_HUMAN_YOGA'}
    }
}
